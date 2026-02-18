import 'package:flutter/material.dart';
import 'package:primeos/features/goals/domain/entities/goal_category.dart';

class GoalCategoryTab extends StatelessWidget {
  final GoalCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalCategoryTab({
    required this.category,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(category.name),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        width: isSelected ? 2 : 0,
      ),
    );
  }
}
