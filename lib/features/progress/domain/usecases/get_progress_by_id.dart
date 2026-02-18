import '../../../core/types/app_result.dart';
import '../entities/progress_entry.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class GetProgressById {
  Future<AppResult<ProgressEntry>> call(GetProgressByIdParams params);
}

final class GetProgressByIdImpl implements GetProgressById {
  final ProgressRepository _repository;

  GetProgressByIdImpl(this._repository);

  @override
  Future<AppResult<ProgressEntry>> call(GetProgressByIdParams params) async {
    final result = await _repository.getProgressById(params.progressId);
    return result.fold(
      (failure) => AppError(failure),
      (entry) {
        if (entry == null) {
          return AppError(
            DatabaseFailure('Progress entry not found'),
          );
        }
        return AppSuccess(entry);
      },
    );
  }
}
