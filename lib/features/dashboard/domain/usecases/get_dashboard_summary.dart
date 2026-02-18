import '../../../core/types/app_result.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';
import 'params.dart';

abstract interface class GetDashboardSummary {
  Future<AppResult<DashboardSummary>> call(NoParams params);
}

final class GetDashboardSummaryImpl implements GetDashboardSummary {
  final DashboardRepository _repository;

  GetDashboardSummaryImpl(this._repository);

  @override
  Future<AppResult<DashboardSummary>> call(NoParams params) {
    return _repository.getDashboardSummary();
  }
}
