import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/core/providers/database_provider.dart';
import 'package:primeos/core/types/app_result.dart';
import 'package:primeos/features/daily_log/data/datasources/daily_log_local_datasource.dart';
import 'package:primeos/features/daily_log/data/repositories/daily_log_repository_impl.dart';
import 'package:primeos/features/daily_log/domain/entities/daily_log_category.dart';
import 'package:primeos/features/daily_log/domain/entities/daily_log_entry.dart';
import 'package:primeos/features/daily_log/domain/repositories/daily_log_repository.dart';

/// Repository provider for dependency injection
final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  final database = ref.watch(databaseProvider).valueOrNull;
  if (database == null) {
    throw Exception('Database not initialized');
  }
  final dataSource = DailyLogLocalDataSource(database);
  return DailyLogRepositoryImpl(dataSource);
});

/// State provider for selected date
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Main daily log entries AsyncNotifierProvider for state management
class DailyLogNotifier extends AsyncNotifier<List<DailyLogEntry>> {
  late DailyLogRepository _repository;

  @override
  Future<List<DailyLogEntry>> build() async {
    _repository = ref.read(dailyLogRepositoryProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    return _fetchEntriesForDate(selectedDate);
  }

  Future<List<DailyLogEntry>> _fetchEntriesForDate(DateTime date) async {
    final result = await _repository.getEntriesByDate(date);
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load daily log entries',
    };
  }

  /// Select a new date and refresh entries
  Future<void> selectDate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    ref.read(selectedDateProvider.notifier).state = normalizedDate;
    // The build method will be called again due to selectedDate dependency
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetchEntriesForDate(normalizedDate),
    );
  }

  /// Create a new log entry with optimistic update
  Future<void> createEntry(DailyLogEntry entry) async {
    final previousEntries = state.value ?? [];
    state = AsyncValue.data([...previousEntries, entry]);

    final result = await _repository.createEntry(entry);

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

  /// Update an existing log entry
  Future<void> updateEntry(DailyLogEntry updatedEntry) async {
    final previousEntries = state.value ?? [];

    // Optimistic update
    final newEntries = previousEntries
        .map((e) => e.id == updatedEntry.id ? updatedEntry : e)
        .toList();
    state = AsyncValue.data(newEntries);

    // Call repository
    final result = await _repository.updateEntry(updatedEntry);

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

  /// Soft delete a log entry by ID
  Future<void> deleteEntry(String entryId) async {
    final previousEntries = state.value ?? [];

    // Optimistic update
    final newEntries = previousEntries.where((e) => e.id != entryId).toList();
    state = AsyncValue.data(newEntries);

    // Call repository
    final result = await _repository.softDeleteEntry(entryId);

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

  /// Manually refresh entries for current date
  Future<void> refreshEntries() async {
    state = const AsyncValue.loading();
    final selectedDate = ref.read(selectedDateProvider);
    state = await AsyncValue.guard(
      () => _fetchEntriesForDate(selectedDate),
    );
  }

  /// Get entries filtered by date range and optional category
  Future<List<DailyLogEntry>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
    String? categoryId,
  ) async {
    final result = await _repository.getEntriesByDateRange(start, end, categoryId);
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }
}

final dailyLogProvider =
    AsyncNotifierProvider<DailyLogNotifier, List<DailyLogEntry>>(
  DailyLogNotifier.new,
);

/// Separate provider for loading categories (for form dropdowns)
class DailyLogCategoriesNotifier extends AsyncNotifier<List<DailyLogCategory>> {
  late DailyLogRepository _repository;

  @override
  Future<List<DailyLogCategory>> build() async {
    _repository = ref.read(dailyLogRepositoryProvider);
    final result = await _repository.getAllCategories();
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load categories',
    };
  }

  Future<void> refreshCategories() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllCategories();
    state = switch (result) {
      AppSuccess(:final data) => AsyncValue.data(data),
      AppError(:final failure) => AsyncValue.error(
        Exception(_getFailureMessage(failure)),
        StackTrace.current,
      ),
    };
  }
}

final dailyLogCategoriesProvider =
    AsyncNotifierProvider<DailyLogCategoriesNotifier, List<DailyLogCategory>>(
  DailyLogCategoriesNotifier.new,
);
