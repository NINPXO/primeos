import 'package:uuid/uuid.dart';

import '../../../core/types/app_result.dart';
import '../entities/progress_entry.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class CreateProgressEntry {
  Future<AppResult<ProgressEntry>> call(CreateProgressEntryParams params);
}

final class CreateProgressEntryImpl implements CreateProgressEntry {
  final ProgressRepository _repository;

  CreateProgressEntryImpl(this._repository);

  @override
  Future<AppResult<ProgressEntry>> call(CreateProgressEntryParams params) async {
    final now = DateTime.now();
    final entry = ProgressEntry(
      id: const Uuid().v4(),
      goalId: params.goalId,
      categoryId: params.categoryId,
      value: params.value,
      unit: params.unit,
      note: params.note,
      trackingPeriod: params.trackingPeriod,
      loggedDate: params.loggedDate,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createProgressEntry(entry).then(
      (result) => result.fold(
        (failure) => AppError(failure),
        (_) => AppSuccess(entry),
      ),
    );
  }
}
