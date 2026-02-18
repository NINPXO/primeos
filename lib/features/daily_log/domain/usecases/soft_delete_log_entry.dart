import '../../../core/types/app_result.dart';
import '../repositories/daily_log_repository.dart';
import 'params.dart';

abstract interface class SoftDeleteLogEntry {
  Future<AppResult<void>> call(SoftDeleteLogEntryParams params);
}

final class SoftDeleteLogEntryImpl implements SoftDeleteLogEntry {
  final DailyLogRepository _repository;

  SoftDeleteLogEntryImpl(this._repository);

  @override
  Future<AppResult<void>> call(SoftDeleteLogEntryParams params) {
    return _repository.softDeleteEntry(params.entryId);
  }
}
