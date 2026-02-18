import '../../../core/models/app_result.dart';
import '../entities/goal.dart';
import '../repositories/goals_repository.dart';
import 'params.dart';

abstract interface class UpdateGoal {
  Future<AppResult<Goal>> call(UpdateGoalParams params);
}

final class UpdateGoalImpl implements UpdateGoal {
  final GoalsRepository _repository;

  UpdateGoalImpl(this._repository);

  @override
  Future<AppResult<Goal>> call(UpdateGoalParams params) async {
    final result = await _repository.getGoalById(params.goalId);
    return result.fold(
      (failure) => AppResult.failure(failure),
      (existing) async {
        if (existing == null) {
          return AppResult.failure(
            Exception('Goal not found') as dynamic,
          );
        }
        final updated = existing.copyWith(
          title: params.title ?? existing.title,
          description: params.description ?? existing.description,
          status: params.status ?? existing.status,
          targetValue: params.targetValue ?? existing.targetValue,
          targetUnit: params.targetUnit ?? existing.targetUnit,
          targetDate: params.targetDate ?? existing.targetDate,
          updatedAt: DateTime.now(),
        );
        return _repository.updateGoal(updated);
      },
    );
  }
}
