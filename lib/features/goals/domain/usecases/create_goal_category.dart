import '../../../core/models/app_result.dart';
import '../../../core/utils/id_generator.dart';
import '../entities/goal_category.dart';
import '../repositories/goals_repository.dart';
import 'params.dart';

abstract interface class CreateGoalCategory {
  Future<AppResult<GoalCategory>> call(CreateGoalCategoryParams params);
}

final class CreateGoalCategoryImpl implements CreateGoalCategory {
  final GoalsRepository _repository;
  final IdGenerator _idGenerator;

  CreateGoalCategoryImpl(this._repository, this._idGenerator);

  @override
  Future<AppResult<GoalCategory>> call(CreateGoalCategoryParams params) async {
    final now = DateTime.now();
    final category = GoalCategory(
      id: _idGenerator.generateUuid(),
      name: params.name,
      isSystem: params.isSystem,
      colorHex: params.colorHex,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createCategory(category);
  }
}
