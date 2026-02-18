import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/goals/presentation/providers/goals_provider.dart';
import 'package:primeos/features/goals/presentation/providers/goal_categories_provider.dart';
import 'package:primeos/features/goals/presentation/widgets/goal_card.dart';
import 'package:primeos/features/goals/presentation/widgets/goal_category_tab.dart';
import 'package:primeos/features/goals/presentation/screens/goal_form_screen.dart';
import 'package:primeos/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:primeos/features/goals/presentation/widgets/category_manage_sheet.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);
    final categoriesAsync = ref.watch(goalCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showCategoryManageSheet(context),
            tooltip: 'Manage Categories',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(goalsProvider.notifier).refreshGoals(),
        child: Column(
          children: [
            // Category tabs
            categoriesAsync.when(
              data: (categories) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) {
                          setState(() => _selectedCategoryId = null);
                        },
                      ),
                    ),
                    ...categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GoalCategoryTab(
                          category: category,
                          isSelected: _selectedCategoryId == category.id,
                          onTap: () {
                            setState(() => _selectedCategoryId = category.id);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, st) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Error loading categories: $error'),
              ),
            ),
            // Goals list
            Expanded(
              child: goalsAsync.when(
                data: (goals) {
                  final filteredGoals = _selectedCategoryId == null
                      ? goals
                      : goals
                          .where((g) => g.categoryId == _selectedCategoryId)
                          .toList();

                  if (filteredGoals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No goals yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new goal to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredGoals.length,
                    itemBuilder: (context, index) {
                      final goal = filteredGoals[index];
                      return GoalCard(
                        goal: goal,
                        onEdit: () => _showEditGoalSheet(context, goal),
                        onDelete: () => _confirmDeleteGoal(context, goal.id),
                        onTap: () => _navigateToDetail(context, goal.id),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading goals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('$error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(goalsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(context),
        tooltip: 'Add Goal',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const GoalFormSheet(),
    );
  }

  void _showEditGoalSheet(BuildContext context, dynamic goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => GoalFormSheet(existingGoal: goal),
    );
  }

  void _showCategoryManageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CategoryManageSheet(),
    );
  }

  void _navigateToDetail(BuildContext context, String goalId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoalDetailScreen(goalId: goalId),
      ),
    );
  }

  void _confirmDeleteGoal(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(goalsProvider.notifier).deleteGoal(goalId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
