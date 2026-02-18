import '../../../core/types/app_result.dart';
import '../entities/progress_entry.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class GetAllProgress {
  Future<AppResult<List<ProgressEntry>>> call(NoParams params);
}

final class GetAllProgressImpl implements GetAllProgress {
  final ProgressRepository _repository;

  GetAllProgressImpl(this._repository);

  @override
  Future<AppResult<List<ProgressEntry>>> call(NoParams params) {
    return _repository.getAllProgress();
  }
}
