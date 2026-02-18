import '../../../core/types/app_result.dart';
import '../entities/daily_log_entry.dart';
import '../repositories/daily_log_repository.dart';
import 'params.dart';

abstract interface class GetEntriesByDate {
  Future<AppResult<List<DailyLogEntry>>> call(GetEntriesByDateParams params);
}

final class GetEntriesByDateImpl implements GetEntriesByDate {
  final DailyLogRepository _repository;

  GetEntriesByDateImpl(this._repository);

  @override
  Future<AppResult<List<DailyLogEntry>>> call(GetEntriesByDateParams params) {
    return _repository.getEntriesByDate(params.date);
  }
}
