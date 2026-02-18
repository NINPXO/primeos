import 'package:flutter/material.dart';

/// Small badge widget showing category name with fixed colors
class LogCategoryBadge extends StatelessWidget {
  final String categoryName;
  final String categoryId;

  const LogCategoryBadge({
    required this.categoryName,
    required this.categoryId,
    super.key,
  });

  /// Get color based on category name (fixed categories)
  Color _getCategoryColor() {
    switch (categoryName.toLowerCase()) {
      case 'location':
        return const Color(0xFF2196F3); // Blue
      case 'mobile usage':
        return const Color(0xFF4CAF50); // Green
      case 'app usage':
        return const Color(0xFFFF9800); // Orange
      case 'exercise':
        return const Color(0xFF9C27B0); // Purple
      case 'sleep':
        return const Color(0xFF3F51B5); // Indigo
      case 'food':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getCategoryColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        categoryName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
