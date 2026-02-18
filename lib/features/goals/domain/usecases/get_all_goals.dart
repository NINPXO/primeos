import '../../../core/models/app_result.dart';
import '../entities/goal.dart';
import '../repositories/goals_repository.dart';
import 'params.dart';

abstract interface class GetAllGoals {
  Future<AppResult<List<Goal>>> call(NoParams params);
}

final class GetAllGoalsImpl implements GetAllGoals {
  final GoalsRepository _repository;

  GetAllGoalsImpl(this._repository);

  @override
  Future<AppResult<List<Goal>>> call(NoParams params) {
    return _repository.getAllGoals();
  }
}
