import '../../../core/models/app_result.dart';
import '../entities/goal.dart';
import '../repositories/goals_repository.dart';
import 'params.dart';

abstract interface class GetGoalsByCategory {
  Future<AppResult<List<Goal>>> call(GetGoalsByCategoryParams params);
}

final class GetGoalsByCategoryImpl implements GetGoalsByCategory {
  final GoalsRepository _repository;

  GetGoalsByCategoryImpl(this._repository);

  @override
  Future<AppResult<List<Goal>>> call(GetGoalsByCategoryParams params) {
    return _repository.getGoalsByCategory(params.categoryId);
  }
}
