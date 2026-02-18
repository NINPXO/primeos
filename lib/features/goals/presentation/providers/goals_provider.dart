import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/goals/domain/entities/goal.dart';
import 'package:primeos/features/goals/domain/repositories/goals_repository.dart';
import 'package:primeos/features/goals/data/repositories/goals_repository_impl.dart';
import 'package:primeos/core/providers/database_provider.dart';
import 'package:primeos/features/goals/data/datasources/goals_local_datasource.dart';
import 'package:primeos/core/types/app_result.dart';

/// Repository provider for dependency injection
final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final database = ref.watch(databaseProvider).valueOrNull;
  if (database == null) {
    throw Exception('Database not initialized');
  }
  final dataSource = GoalsLocalDataSource(database);
  return GoalsRepositoryImpl(dataSource);
});

/// Main goals AsyncNotifierProvider for state management
class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  late GoalsRepository _repository;

  @override
  Future<List<Goal>> build() async {
    _repository = ref.read(goalsRepositoryProvider);
    final result = await _repository.getAllGoals();
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load goals',
    };
  }

  /// Add a new goal with optimistic update
  Future<void> addGoal(Goal goal) async {
    // Optimistic update
    final previousGoals = state.value ?? [];
    state = AsyncValue.data([...previousGoals, goal]);

    // Call repository
    final result = await _repository.createGoal(goal);

    // Handle result
    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousGoals);
        rethrow;
    }
  }

  /// Update an existing goal
  Future<void> updateGoal(Goal updatedGoal) async {
    final previousGoals = state.value ?? [];

    // Optimistic update
    final newGoals = previousGoals.map((g) => g.id == updatedGoal.id ? updatedGoal : g).toList();
    state = AsyncValue.data(newGoals);

    // Call repository
    final result = await _repository.updateGoal(updatedGoal);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousGoals);
        rethrow;
    }
  }

  /// Soft delete a goal by ID
  Future<void> deleteGoal(String goalId) async {
    final previousGoals = state.value ?? [];

    // Optimistic update
    final newGoals = previousGoals.where((g) => g.id != goalId).toList();
    state = AsyncValue.data(newGoals);

    // Call repository
    final result = await _repository.softDeleteGoal(goalId);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousGoals);
        rethrow;
    }
  }

  /// Manually refresh goals from database
  Future<void> refreshGoals() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllGoals();
    state = switch (result) {
      AppSuccess(:final data) => AsyncValue.data(data),
      AppError(:final failure) => AsyncValue.error(
        Exception(_getFailureMessage(failure)),
        StackTrace.current,
      ),
    };
  }

  /// Get goals filtered by category ID
  Future<List<Goal>> getGoalsByCategory(String categoryId) async {
    final result = await _repository.getGoalsByCategory(categoryId);
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(
  GoalsNotifier.new,
);
