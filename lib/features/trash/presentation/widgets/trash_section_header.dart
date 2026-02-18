import 'package:flutter/material.dart';

class TrashSectionHeader extends StatelessWidget {
  final String type;
  final int count;

  const TrashSectionHeader({
    required this.type,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final typeName = switch (type) {
      'goal' => 'Goals',
      'progress' => 'Progress',
      'log' => 'Logs',
      _ => 'Items',
    };

    final typeColor = switch (type) {
      'goal' => Colors.blue,
      'progress' => Colors.green,
      'log' => Colors.orange,
      _ => Colors.grey,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                typeName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withAlpha(77),
          ),
        ],
      ),
    );
  }
}
