import '../../../core/models/app_result.dart';
import '../../../core/utils/id_generator.dart';
import '../entities/goal.dart';
import '../repositories/goals_repository.dart';
import 'params.dart';

abstract interface class CreateGoal {
  Future<AppResult<Goal>> call(CreateGoalParams params);
}

final class CreateGoalImpl implements CreateGoal {
  final GoalsRepository _repository;
  final IdGenerator _idGenerator;

  CreateGoalImpl(this._repository, this._idGenerator);

  @override
  Future<AppResult<Goal>> call(CreateGoalParams params) async {
    final now = DateTime.now();
    final goal = Goal(
      id: _idGenerator.generateUuid(),
      categoryId: params.categoryId,
      title: params.title,
      description: params.description,
      status: params.status,
      targetValue: params.targetValue,
      targetUnit: params.targetUnit,
      targetDate: params.targetDate,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
    return _repository.createGoal(goal);
  }
}
