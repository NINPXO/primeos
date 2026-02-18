import '../../../core/models/app_result.dart';
import '../repositories/goals_repository.dart';
import 'params.dart';

abstract interface class SoftDeleteGoal {
  Future<AppResult<void>> call(SoftDeleteGoalParams params);
}

final class SoftDeleteGoalImpl implements SoftDeleteGoal {
  final GoalsRepository _repository;

  SoftDeleteGoalImpl(this._repository);

  @override
  Future<AppResult<void>> call(SoftDeleteGoalParams params) {
    return _repository.softDeleteGoal(params.goalId);
  }
}
