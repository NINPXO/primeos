import '../../../core/types/app_result.dart';
import '../entities/progress_entry.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class GetProgressByTrackingPeriod {
  Future<AppResult<List<ProgressEntry>>> call(
    GetProgressByTrackingPeriodParams params,
  );
}

final class GetProgressByTrackingPeriodImpl
    implements GetProgressByTrackingPeriod {
  final ProgressRepository _repository;

  GetProgressByTrackingPeriodImpl(this._repository);

  @override
  Future<AppResult<List<ProgressEntry>>> call(
    GetProgressByTrackingPeriodParams params,
  ) {
    return _repository.getProgressByTrackingPeriod(
      params.trackingPeriod,
      categoryId: params.categoryId,
    );
  }
}
