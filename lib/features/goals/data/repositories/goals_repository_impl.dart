import 'package:primeos/core/types/app_result.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_category.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_local_datasource.dart';
import '../models/goal_category_model.dart';
import '../models/goal_model.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  final GoalsLocalDatasource _datasource;

  GoalsRepositoryImpl(this._datasource);

  @override
  Future<AppResult<List<Goal>>> getAllGoals({bool includeDeleted = false}) async {
    try {
      final models = await _datasource.getAllGoals(includeDeleted: includeDeleted);
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Goal>>> getGoalsByCategory(
    String categoryId, {
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getGoalsByCategory(
        categoryId,
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<Goal?>> getGoalById(String id) async {
    try {
      final model = await _datasource.getGoalById(id);
      return AppSuccess(model);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> createGoal(Goal goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      await _datasource.createGoal(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> updateGoal(Goal goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      await _datasource.updateGoal(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> softDeleteGoal(String id) async {
    try {
      await _datasource.softDeleteGoal(id);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<GoalCategory>>> getAllCategories(
      {bool includeDeleted = false}) async {
    try {
      final models =
          await _datasource.getAllCategories(includeDeleted: includeDeleted);
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<GoalCategory?>> getCategoryById(String id) async {
    try {
      final model = await _datasource.getCategoryById(id);
      return AppSuccess(model);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> createCategory(GoalCategory category) async {
    try {
      final model = GoalCategoryModel.fromEntity(category);
      await _datasource.createCategory(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> updateCategory(GoalCategory category) async {
    try {
      final model = GoalCategoryModel.fromEntity(category);
      await _datasource.updateCategory(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> softDeleteCategory(String id) async {
    try {
      await _datasource.softDeleteCategory(id);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Map<String, dynamic>>>> exportGoalsForCsv(
    String? categoryId,
  ) async {
    try {
      final data = await _datasource.exportGoalsForCsv(categoryId);
      return AppSuccess(data);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }
}
