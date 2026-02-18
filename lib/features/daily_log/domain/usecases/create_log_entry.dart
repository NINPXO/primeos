import 'package:uuid/uuid.dart';

import '../../../core/types/app_result.dart';
import '../entities/daily_log_entry.dart';
import '../repositories/daily_log_repository.dart';
import 'params.dart';

abstract interface class CreateLogEntry {
  Future<AppResult<DailyLogEntry>> call(CreateLogEntryParams params);
}

final class CreateLogEntryImpl implements CreateLogEntry {
  final DailyLogRepository _repository;

  CreateLogEntryImpl(this._repository);

  @override
  Future<AppResult<DailyLogEntry>> call(CreateLogEntryParams params) async {
    final now = DateTime.now();
    final entry = DailyLogEntry(
      id: const Uuid().v4(),
      logDate: params.logDate,
      categoryId: params.categoryId,
      title: params.title,
      detail: params.detail,
      durationMins: params.durationMins,
      linkedType: params.linkedType,
      linkedId: params.linkedId,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      deletedAt: null,
    );
    return _repository.createEntry(entry).then(
      (result) => result.fold(
        (failure) => AppError(failure),
        (_) => AppSuccess(entry),
      ),
    );
  }
}
