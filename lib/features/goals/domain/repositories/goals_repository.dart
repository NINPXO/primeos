import 'package:primeos/core/types/app_result.dart';
import '../entities/goal.dart';
import '../entities/goal_category.dart';

abstract interface class GoalsRepository {
  Future<AppResult<List<Goal>>> getAllGoals({bool includeDeleted = false});
  Future<AppResult<List<Goal>>> getGoalsByCategory(
    String categoryId, {
    bool includeDeleted = false,
  });
  Future<AppResult<Goal?>> getGoalById(String id);
  Future<AppResult<void>> createGoal(Goal goal);
  Future<AppResult<void>> updateGoal(Goal goal);
  Future<AppResult<void>> softDeleteGoal(String id);
  Future<AppResult<List<GoalCategory>>> getAllCategories({
    bool includeDeleted = false,
  });
  Future<AppResult<GoalCategory?>> getCategoryById(String id);
  Future<AppResult<void>> createCategory(GoalCategory category);
  Future<AppResult<void>> updateCategory(GoalCategory category);
  Future<AppResult<void>> softDeleteCategory(String id);
  Future<AppResult<List<Map<String, dynamic>>>> exportGoalsForCsv(
    String? categoryId,
  );
}
