import '../../../core/types/app_result.dart';
import '../entities/progress_entry.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class GetProgressByPeriod {
  Future<AppResult<List<ProgressEntry>>> call(GetProgressByPeriodParams params);
}

final class GetProgressByPeriodImpl implements GetProgressByPeriod {
  final ProgressRepository _repository;

  GetProgressByPeriodImpl(this._repository);

  @override
  Future<AppResult<List<ProgressEntry>>> call(GetProgressByPeriodParams params) {
    return _repository.getProgressByPeriod(
      params.startDate,
      params.endDate,
      params.categoryId,
    );
  }
}
