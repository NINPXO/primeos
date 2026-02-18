import 'package:flutter/material.dart';
import 'package:primeos/features/daily_log/domain/entities/daily_log_entry.dart';
import 'log_category_badge.dart';

/// Card displaying a single log entry
class LogEntryCard extends StatelessWidget {
  final DailyLogEntry entry;
  final String categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LogEntryCard({
    required this.entry,
    required this.categoryName,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: category badge and title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LogCategoryBadge(
                      categoryName: categoryName,
                      categoryId: entry.categoryId,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (entry.linkedType != null && entry.linkedType!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '📌 ${entry.linkedType}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Action buttons
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Detail text
                if (entry.detail != null && entry.detail!.isNotEmpty)
                  Text(
                    entry.detail!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                // Duration and other metadata
                if (entry.durationMins != null || entry.detail != null)
                  const SizedBox(height: 8),
                Row(
                  children: [
                    if (entry.durationMins != null)
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.durationMins} min',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    const SizedBox(width: 12),
                    if (entry.createdAt != null)
                      Text(
                        _formatTime(entry.createdAt!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
