import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/goals/domain/entities/goal_category.dart';
import 'package:primeos/features/goals/domain/repositories/goals_repository.dart';
import 'package:primeos/core/types/app_result.dart';
import 'goals_provider.dart';

/// Main goal categories AsyncNotifierProvider for state management
class GoalCategoriesNotifier extends AsyncNotifier<List<GoalCategory>> {
  late GoalsRepository _repository;

  @override
  Future<List<GoalCategory>> build() async {
    _repository = ref.read(goalsRepositoryProvider);
    final result = await _repository.getAllCategories();
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load categories',
    };
  }

  /// Add a new category with optimistic update
  Future<void> addCategory(GoalCategory category) async {
    final previousCategories = state.value ?? [];
    state = AsyncValue.data([...previousCategories, category]);

    final result = await _repository.createCategory(category);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousCategories);
        rethrow;
    }
  }

  /// Update an existing category
  Future<void> updateCategory(GoalCategory updatedCategory) async {
    final previousCategories = state.value ?? [];

    final newCategories = previousCategories
        .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
        .toList();
    state = AsyncValue.data(newCategories);

    final result = await _repository.updateCategory(updatedCategory);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousCategories);
        rethrow;
    }
  }

  /// Soft delete a category by ID (only non-system categories)
  Future<void> deleteCategory(String categoryId) async {
    final previousCategories = state.value ?? [];

    // Optimistic update - only delete if not system category
    final newCategories = previousCategories.where((c) {
      if (c.id == categoryId && !c.isSystem) {
        return false;
      }
      return true;
    }).toList();

    state = AsyncValue.data(newCategories);

    final result = await _repository.softDeleteCategory(categoryId);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousCategories);
        rethrow;
    }
  }

  /// Manually refresh categories from database
  Future<void> refreshCategories() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllCategories();
    state = switch (result) {
      AppSuccess(:final data) => AsyncValue.data(data),
      AppError(:final failure) => AsyncValue.error(
        Exception(_getFailureMessage(failure)),
        StackTrace.current,
      ),
    };
  }
}

final goalCategoriesProvider =
    AsyncNotifierProvider<GoalCategoriesNotifier, List<GoalCategory>>(
  GoalCategoriesNotifier.new,
);
