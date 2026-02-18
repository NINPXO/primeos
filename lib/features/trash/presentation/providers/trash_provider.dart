import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/trash/domain/entities/trash_item.dart';
import 'package:primeos/features/trash/domain/repositories/trash_repository.dart';
import 'package:primeos/features/trash/data/repositories/trash_repository_impl.dart';
import 'package:primeos/core/providers/database_provider.dart';
import 'package:primeos/features/trash/data/datasources/trash_local_datasource.dart';
import 'package:primeos/core/types/app_result.dart';

/// Repository provider for dependency injection
final trashRepositoryProvider = Provider<TrashRepository>((ref) {
  final database = ref.watch(databaseProvider).valueOrNull;
  if (database == null) {
    throw Exception('Database not initialized');
  }
  final dataSource = TrashLocalDatasource(database);
  return TrashRepositoryImpl(dataSource);
});

/// Main trash AsyncNotifierProvider for state management
class TrashNotifier extends AsyncNotifier<List<TrashItem>> {
  late TrashRepository _repository;

  @override
  Future<List<TrashItem>> build() async {
    _repository = ref.read(trashRepositoryProvider);
    final result = await _repository.getAllTrash();
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load trash',
    };
  }

  /// Manually refresh trash items from database
  Future<void> refreshTrash() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllTrash();
    state = switch (result) {
      AppSuccess(:final data) => AsyncValue.data(data),
      AppError(:final failure) => AsyncValue.error(
        Exception(_getFailureMessage(failure)),
        StackTrace.current,
      ),
    };
  }

  /// Restore an item from trash back to its original location
  Future<void> restoreItem(String id, String type) async {
    final previousItems = state.value ?? [];

    // Optimistic update: remove from trash
    final newItems = previousItems.where((item) => item.id != id).toList();
    state = AsyncValue.data(newItems);

    // Call repository
    final result = await _repository.restoreItem(id, type);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousItems);
        rethrow;
    }
  }

  /// Permanently delete an item from trash
  Future<void> hardDeleteItem(String id, String type) async {
    final previousItems = state.value ?? [];

    // Optimistic update: remove from trash
    final newItems = previousItems.where((item) => item.id != id).toList();
    state = AsyncValue.data(newItems);

    // Call repository
    final result = await _repository.hardDeleteItem(id, type);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousItems);
        rethrow;
    }
  }

  /// Empty entire trash (hard delete all items)
  Future<void> emptyTrash() async {
    // Optimistic update: clear all
    state = const AsyncValue.data([]);

    // Call repository
    final result = await _repository.emptyTrash();

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error - refresh
        await refreshTrash();
        rethrow;
    }
  }

  /// Get filtered trash items by type
  List<TrashItem> filterByType(String type) {
    final items = state.value ?? [];
    if (type == 'all') {
      return items;
    }
    return items.where((item) => item.sourceType == type).toList();
  }
}

final trashProvider = AsyncNotifierProvider<TrashNotifier, List<TrashItem>>(
  TrashNotifier.new,
);
