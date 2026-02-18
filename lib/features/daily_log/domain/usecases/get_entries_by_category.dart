import '../../../core/types/app_result.dart';
import '../entities/daily_log_entry.dart';
import '../repositories/daily_log_repository.dart';
import 'params.dart';

abstract interface class GetEntriesByCategory {
  Future<AppResult<List<DailyLogEntry>>> call(GetEntriesByCategoryParams params);
}

final class GetEntriesByCategoryImpl implements GetEntriesByCategory {
  final DailyLogRepository _repository;

  GetEntriesByCategoryImpl(this._repository);

  @override
  Future<AppResult<List<DailyLogEntry>>> call(GetEntriesByCategoryParams params) {
    return _repository.getEntriesByCategory(params.categoryId);
  }
}
