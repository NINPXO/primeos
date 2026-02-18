import '../../../core/types/app_result.dart';
import '../entities/daily_log_entry.dart';
import '../repositories/daily_log_repository.dart';
import 'params.dart';

abstract interface class GetEntriesByDateRange {
  Future<AppResult<List<DailyLogEntry>>> call(GetEntriesByDateRangeParams params);
}

final class GetEntriesByDateRangeImpl implements GetEntriesByDateRange {
  final DailyLogRepository _repository;

  GetEntriesByDateRangeImpl(this._repository);

  @override
  Future<AppResult<List<DailyLogEntry>>> call(GetEntriesByDateRangeParams params) {
    return _repository.getEntriesByDateRange(
      params.startDate,
      params.endDate,
      params.categoryId,
    );
  }
}
