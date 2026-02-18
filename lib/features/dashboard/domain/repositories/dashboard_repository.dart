import 'package:primeos/core/types/app_result.dart';
import '../entities/dashboard_summary.dart';

abstract interface class DashboardRepository {
  Future<AppResult<DashboardSummary>> getDashboardSummary();
  Future<AppResult<void>> clearDateRange(DateTime startDate, DateTime endDate);
  Future<AppResult<List<Map<String, dynamic>>>> exportAllData();
}
