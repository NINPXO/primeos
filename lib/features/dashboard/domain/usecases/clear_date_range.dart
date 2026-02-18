import '../../../core/types/app_result.dart';
import '../repositories/dashboard_repository.dart';
import 'params.dart';

abstract interface class ClearDateRange {
  Future<AppResult<void>> call(ClearDateRangeParams params);
}

final class ClearDateRangeImpl implements ClearDateRange {
  final DashboardRepository _repository;

  ClearDateRangeImpl(this._repository);

  @override
  Future<AppResult<void>> call(ClearDateRangeParams params) async {
    // Validate that startDate is before or equal to endDate
    if (params.startDate.isAfter(params.endDate)) {
      return AppResult.failure(
        ValidationFailure(
          'Start date must be before or equal to end date',
        ),
      );
    }

    return _repository.clearDateRange(params.startDate, params.endDate);
  }
}
