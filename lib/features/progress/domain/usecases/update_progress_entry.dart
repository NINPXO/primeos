import '../../../core/types/app_result.dart';
import '../entities/progress_entry.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class UpdateProgressEntry {
  Future<AppResult<ProgressEntry>> call(UpdateProgressEntryParams params);
}

final class UpdateProgressEntryImpl implements UpdateProgressEntry {
  final ProgressRepository _repository;

  UpdateProgressEntryImpl(this._repository);

  @override
  Future<AppResult<ProgressEntry>> call(UpdateProgressEntryParams params) async {
    final result =
        await _repository.getProgressById(params.progressId);
    return result.fold(
      (failure) => AppError(failure),
      (existing) async {
        if (existing == null) {
          return AppError(
            DatabaseFailure('Progress entry not found'),
          );
        }
        final updated = existing.copyWith(
          value: params.value ?? existing.value,
          note: params.note ?? existing.note,
          unit: params.unit ?? existing.unit,
          loggedDate: params.loggedDate ?? existing.loggedDate,
          updatedAt: DateTime.now(),
        );
        return _repository.updateProgressEntry(updated).then(
          (result) => result.fold(
            (failure) => AppError(failure),
            (_) => AppSuccess(updated),
          ),
        );
      },
    );
  }
}
