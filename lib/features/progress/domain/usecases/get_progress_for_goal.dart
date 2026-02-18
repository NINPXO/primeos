import '../../../core/types/app_result.dart';
import '../entities/progress_entry.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class GetProgressForGoal {
  Future<AppResult<List<ProgressEntry>>> call(GetProgressForGoalParams params);
}

final class GetProgressForGoalImpl implements GetProgressForGoal {
  final ProgressRepository _repository;

  GetProgressForGoalImpl(this._repository);

  @override
  Future<AppResult<List<ProgressEntry>>> call(GetProgressForGoalParams params) {
    return _repository.getProgressForGoal(params.goalId);
  }
}
