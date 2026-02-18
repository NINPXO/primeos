import 'package:primeos/core/types/app_result.dart';
import '../entities/progress_entry.dart';

abstract interface class ProgressRepository {
  Future<AppResult<List<ProgressEntry>>> getAllProgress(
      {bool includeDeleted = false});
  Future<AppResult<List<ProgressEntry>>> getProgressForGoal(
    String goalId, {
    bool includeDeleted = false,
  });
  Future<AppResult<List<ProgressEntry>>> getProgressByPeriod(
    DateTime startDate,
    DateTime endDate,
    String? categoryId, {
    bool includeDeleted = false,
  });
  Future<AppResult<List<ProgressEntry>>> getProgressByTrackingPeriod(
    String trackingPeriod, {
    String? categoryId,
    bool includeDeleted = false,
  });
  Future<AppResult<ProgressEntry?>> getProgressById(String id);
  Future<AppResult<void>> createProgressEntry(ProgressEntry entry);
  Future<AppResult<void>> updateProgressEntry(ProgressEntry entry);
  Future<AppResult<void>> softDeleteProgressEntry(String id);
  Future<AppResult<List<Map<String, dynamic>>>> exportProgressForCsv(
    String? categoryId,
  );
}
