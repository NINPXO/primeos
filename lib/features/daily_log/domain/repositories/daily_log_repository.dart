import 'package:primeos/core/types/app_result.dart';
import '../entities/daily_log_entry.dart';
import '../entities/daily_log_category.dart';

abstract interface class DailyLogRepository {
  Future<AppResult<List<DailyLogEntry>>> getEntriesByDate(
    DateTime date, {
    bool includeDeleted = false,
  });
  Future<AppResult<List<DailyLogEntry>>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
    String? categoryId, {
    bool includeDeleted = false,
  });
  Future<AppResult<List<DailyLogEntry>>> getEntriesByCategory(
    String categoryId, {
    bool includeDeleted = false,
  });
  Future<AppResult<DailyLogEntry?>> getEntryById(String id);
  Future<AppResult<void>> createEntry(DailyLogEntry entry);
  Future<AppResult<void>> updateEntry(DailyLogEntry entry);
  Future<AppResult<void>> softDeleteEntry(String id);
  Future<AppResult<List<DailyLogCategory>>> getAllCategories({
    bool includeDeleted = false,
  });
  Future<AppResult<DailyLogCategory?>> getCategoryById(String id);
  Future<AppResult<List<Map<String, dynamic>>>> exportEntriesForCsv(
    DateTime? startDate,
    DateTime? endDate,
  );
}
