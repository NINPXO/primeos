import 'package:flutter/material.dart';
import 'package:primeos/features/daily_log/domain/entities/daily_log_category.dart';

/// Horizontal scrollable chip list for category filtering
class LogCategoryFilter extends StatelessWidget {
  final List<DailyLogCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const LogCategoryFilter({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "All" chip
          FilterChip(
            label: const Text('All'),
            selected: selectedCategoryId == null,
            onSelected: (selected) {
              onCategorySelected(null);
            },
            backgroundColor: Colors.transparent,
            selectedColor: primaryColor.withAlpha(30),
            side: BorderSide(
              color: selectedCategoryId == null ? primaryColor : Colors.grey,
              width: selectedCategoryId == null ? 2 : 1,
            ),
          ),
          const SizedBox(width: 8),
          // Category chips
          ...categories.map((category) {
            final isSelected = selectedCategoryId == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (selected) {
                  onCategorySelected(selected ? category.id : null);
                },
                backgroundColor: Colors.transparent,
                selectedColor: primaryColor.withAlpha(30),
                side: BorderSide(
                  color: isSelected ? primaryColor : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
