import 'package:primeos/core/types/app_result.dart';
import '../../domain/entities/progress_entry.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/progress_entry_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDatasource _datasource;

  ProgressRepositoryImpl(this._datasource);

  @override
  Future<AppResult<List<ProgressEntry>>> getAllProgress(
      {bool includeDeleted = false}) async {
    try {
      final models =
          await _datasource.getAllProgress(includeDeleted: includeDeleted);
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<ProgressEntry>>> getProgressForGoal(
    String goalId, {
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getProgressForGoal(
        goalId,
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<ProgressEntry>>> getProgressByPeriod(
    DateTime startDate,
    DateTime endDate,
    String? categoryId, {
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getProgressByPeriod(
        startDate,
        endDate,
        categoryId,
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<ProgressEntry>>> getProgressByTrackingPeriod(
    String trackingPeriod, {
    String? categoryId,
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getProgressByTrackingPeriod(
        trackingPeriod,
        categoryId: categoryId,
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<ProgressEntry?>> getProgressById(String id) async {
    try {
      final model = await _datasource.getProgressById(id);
      return AppSuccess(model);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> createProgressEntry(ProgressEntry entry) async {
    try {
      final model = ProgressEntryModel.fromEntity(entry);
      await _datasource.createProgressEntry(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> updateProgressEntry(ProgressEntry entry) async {
    try {
      final model = ProgressEntryModel.fromEntity(entry);
      await _datasource.updateProgressEntry(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> softDeleteProgressEntry(String id) async {
    try {
      await _datasource.softDeleteProgressEntry(id);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Map<String, dynamic>>>> exportProgressForCsv(
    String? categoryId,
  ) async {
    try {
      final data = await _datasource.exportProgressForCsv(categoryId);
      return AppSuccess(data);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }
}
