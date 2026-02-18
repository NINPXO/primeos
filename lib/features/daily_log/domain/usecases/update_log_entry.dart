import '../../../core/types/app_result.dart';
import '../entities/daily_log_entry.dart';
import '../repositories/daily_log_repository.dart';
import 'params.dart';

abstract interface class UpdateLogEntry {
  Future<AppResult<DailyLogEntry>> call(UpdateLogEntryParams params);
}

final class UpdateLogEntryImpl implements UpdateLogEntry {
  final DailyLogRepository _repository;

  UpdateLogEntryImpl(this._repository);

  @override
  Future<AppResult<DailyLogEntry>> call(UpdateLogEntryParams params) async {
    final result = await _repository.getEntryById(params.entryId);
    return result.fold(
      (failure) => AppError(failure),
      (existing) async {
        if (existing == null) {
          return AppError(
            DatabaseFailure('Daily log entry not found'),
          );
        }
        final updated = existing.copyWith(
          title: params.title ?? existing.title,
          detail: params.detail ?? existing.detail,
          durationMins: params.durationMins ?? existing.durationMins,
          logDate: params.logDate ?? existing.logDate,
          updatedAt: DateTime.now(),
        );
        return _repository.updateEntry(updated).then(
          (result) => result.fold(
            (failure) => AppError(failure),
            (_) => AppSuccess(updated),
          ),
        );
      },
    );
  }
}
