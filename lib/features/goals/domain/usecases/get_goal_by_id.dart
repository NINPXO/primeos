import '../../../core/failures/failures.dart';
import '../../../core/models/app_result.dart';
import '../entities/goal.dart';
import '../repositories/goals_repository.dart';
import 'params.dart';

abstract interface class GetGoalById {
  Future<AppResult<Goal>> call(GetGoalByIdParams params);
}

final class GetGoalByIdImpl implements GetGoalById {
  final GoalsRepository _repository;

  GetGoalByIdImpl(this._repository);

  @override
  Future<AppResult<Goal>> call(GetGoalByIdParams params) async {
    final result = await _repository.getGoalById(params.goalId);
    return result.fold(
      (failure) => AppResult.failure(failure),
      (goal) {
        if (goal == null) {
          return AppResult.failure(NotFoundFailure('Goal not found'));
        }
        return AppResult.success(goal);
      },
    );
  }
}
