import 'package:primeos/core/types/app_result.dart';
import '../../domain/entities/daily_log_entry.dart';
import '../../domain/entities/daily_log_category.dart';
import '../../domain/repositories/daily_log_repository.dart';
import '../datasources/daily_log_local_datasource.dart';
import '../models/daily_log_entry_model.dart';
import '../models/daily_log_category_model.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  final DailyLogLocalDatasource _datasource;

  DailyLogRepositoryImpl(this._datasource);

  @override
  Future<AppResult<List<DailyLogEntry>>> getEntriesByDate(
    DateTime date, {
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getEntriesByDate(
        date,
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<DailyLogEntry>>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
    String? categoryId, {
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getEntriesByDateRange(
        start,
        end,
        categoryId,
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<DailyLogEntry>>> getEntriesByCategory(
    String categoryId, {
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getEntriesByCategory(
        categoryId,
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<DailyLogEntry?>> getEntryById(String id) async {
    try {
      final model = await _datasource.getEntryById(id);
      return AppSuccess(model);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> createEntry(DailyLogEntry entry) async {
    try {
      final model = DailyLogEntryModel.fromEntity(entry);
      await _datasource.createEntry(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> updateEntry(DailyLogEntry entry) async {
    try {
      final model = DailyLogEntryModel.fromEntity(entry);
      await _datasource.updateEntry(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> softDeleteEntry(String id) async {
    try {
      await _datasource.softDeleteEntry(id);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<DailyLogCategory>>> getAllCategories({
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getAllCategories(
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<DailyLogCategory?>> getCategoryById(String id) async {
    try {
      final model = await _datasource.getCategoryById(id);
      return AppSuccess(model);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Map<String, dynamic>>>> exportEntriesForCsv(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final data = await _datasource.exportEntriesForCsv(startDate, endDate);
      return AppSuccess(data);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }
}
