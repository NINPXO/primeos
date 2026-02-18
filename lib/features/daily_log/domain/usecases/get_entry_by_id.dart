import '../../../core/types/app_result.dart';
import '../entities/daily_log_entry.dart';
import '../repositories/daily_log_repository.dart';
import 'params.dart';

abstract interface class GetEntryById {
  Future<AppResult<DailyLogEntry>> call(GetEntryByIdParams params);
}

final class GetEntryByIdImpl implements GetEntryById {
  final DailyLogRepository _repository;

  GetEntryByIdImpl(this._repository);

  @override
  Future<AppResult<DailyLogEntry>> call(GetEntryByIdParams params) async {
    final result = await _repository.getEntryById(params.entryId);
    return result.fold(
      (failure) => AppError(failure),
      (entry) {
        if (entry == null) {
          return AppError(
            DatabaseFailure('Daily log entry not found'),
          );
        }
        return AppSuccess(entry);
      },
    );
  }
}
