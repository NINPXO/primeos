import 'package:primeos/core/types/app_result.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDatasource _datasource;

  DashboardRepositoryImpl(this._datasource);

  @override
  Future<AppResult<DashboardSummary>> getDashboardSummary() async {
    try {
      final summary = await _datasource.getDashboardSummary();
      return AppSuccess(summary);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> clearDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      await _datasource.clearDateRange(startDate, endDate);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Map<String, dynamic>>>> exportAllData() async {
    try {
      final data = await _datasource.exportAllData();
      return AppSuccess(data);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }
}
