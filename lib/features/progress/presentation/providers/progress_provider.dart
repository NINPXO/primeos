import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/progress/domain/entities/progress_entry.dart';
import 'package:primeos/features/progress/domain/repositories/progress_repository.dart';
import 'package:primeos/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:primeos/core/providers/database_provider.dart';
import 'package:primeos/features/progress/data/datasources/progress_local_datasource.dart';
import 'package:primeos/core/types/app_result.dart';

/// Repository provider for dependency injection
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final database = ref.watch(databaseProvider).valueOrNull;
  if (database == null) {
    throw Exception('Database not initialized');
  }
  final dataSource = ProgressLocalDataSource(database);
  return ProgressRepositoryImpl(dataSource);
});

/// Main progress AsyncNotifierProvider for state management
class ProgressNotifier extends AsyncNotifier<List<ProgressEntry>> {
  late ProgressRepository _repository;

  @override
  Future<List<ProgressEntry>> build() async {
    _repository = ref.read(progressRepositoryProvider);
    final result = await _repository.getAllProgress();
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load progress entries',
    };
  }

  /// Create a new progress entry with optimistic update
  Future<void> createEntry(ProgressEntry entry) async {
    // Optimistic update
    final previousEntries = state.value ?? [];
    state = AsyncValue.data([...previousEntries, entry]);

    // Call repository
    final result = await _repository.createProgressEntry(entry);

    // Handle result
    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousEntries);
        rethrow;
    }
  }

  /// Update an existing progress entry
  Future<void> updateEntry(ProgressEntry updatedEntry) async {
    final previousEntries = state.value ?? [];

    // Optimistic update
    final newEntries = previousEntries
        .map((e) => e.id == updatedEntry.id ? updatedEntry : e)
        .toList();
    state = AsyncValue.data(newEntries);

    // Call repository
    final result = await _repository.updateProgressEntry(updatedEntry);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousEntries);
        rethrow;
    }
  }

  /// Soft delete a progress entry by ID
  Future<void> deleteEntry(String entryId) async {
    final previousEntries = state.value ?? [];

    // Optimistic update
    final newEntries = previousEntries.where((e) => e.id != entryId).toList();
    state = AsyncValue.data(newEntries);

    // Call repository
    final result = await _repository.softDeleteProgressEntry(entryId);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousEntries);
        rethrow;
    }
  }

  /// Manually refresh progress entries from database
  Future<void> refreshProgress() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllProgress();
    state = switch (result) {
      AppSuccess(:final data) => AsyncValue.data(data),
      AppError(:final failure) => AsyncValue.error(
        Exception(_getFailureMessage(failure)),
        StackTrace.current,
      ),
    };
  }

  /// Get progress entries filtered by goal ID
  Future<List<ProgressEntry>> getProgressForGoal(String goalId) async {
    final result = await _repository.getProgressForGoal(goalId);
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  /// Get progress entries filtered by date range and optional category
  Future<List<ProgressEntry>> getProgressByPeriod(
    DateTime start,
    DateTime end,
    String? categoryId,
  ) async {
    final result =
        await _repository.getProgressByPeriod(start, end, categoryId);
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }
}

final progressProvider =
    AsyncNotifierProvider<ProgressNotifier, List<ProgressEntry>>(
  ProgressNotifier.new,
);
