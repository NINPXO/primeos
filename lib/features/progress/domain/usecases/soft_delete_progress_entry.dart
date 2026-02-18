import '../../../core/types/app_result.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class SoftDeleteProgressEntry {
  Future<AppResult<void>> call(SoftDeleteProgressEntryParams params);
}

final class SoftDeleteProgressEntryImpl implements SoftDeleteProgressEntry {
  final ProgressRepository _repository;

  SoftDeleteProgressEntryImpl(this._repository);

  @override
  Future<AppResult<void>> call(SoftDeleteProgressEntryParams params) {
    return _repository.softDeleteProgressEntry(params.progressId);
  }
}
