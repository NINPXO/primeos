import 'package:flutter/material.dart';

class GoalStatusBadge extends StatelessWidget {
  final String status;

  const GoalStatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (Color backgroundColor, Color textColor, String displayName) = switch (status) {
      'active' => (
        Colors.green.withOpacity(0.2),
        Colors.green.shade700,
        'Active',
      ),
      'paused' => (
        Colors.orange.withOpacity(0.2),
        Colors.orange.shade700,
        'Paused',
      ),
      'completed' => (
        Colors.blue.withOpacity(0.2),
        Colors.blue.shade700,
        'Completed',
      ),
      'abandoned' => (
        Colors.grey.withOpacity(0.2),
        Colors.grey.shade700,
        'Abandoned',
      ),
      _ => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        status,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
