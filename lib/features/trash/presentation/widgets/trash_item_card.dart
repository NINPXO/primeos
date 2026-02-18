import 'package:flutter/material.dart';
import 'package:primeos/features/trash/domain/entities/trash_item.dart';

class TrashItemCard extends StatelessWidget {
  final TrashItem item;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const TrashItemCard({
    required this.item,
    required this.onRestore,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // Show dialog to confirm delete
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Permanently'),
                content: const Text('This item will be permanently deleted.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              onDelete();
            }
            return false;
          }
          return false;
        },
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerLeft,
          child: const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(Icons.restore, color: Colors.white),
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          child: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and type badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildTypeBadge(context),
                  ),
                  // Title
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'restore') {
                        onRestore();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'restore',
                        child: Row(
                          children: [
                            Icon(Icons.restore, size: 20),
                            SizedBox(width: 8),
                            Text('Restore'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Permanently', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Deleted date
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Deleted ${_formatDeletedDate(item.deletedAt)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Preview/description
              _buildItemPreview(context),
              const SizedBox(height: 8),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onRestore,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final typeColor = switch (item.sourceType) {
      'goal' => Colors.blue,
      'progress' => Colors.green,
      'log' => Colors.orange,
      _ => Colors.grey,
    };

    final typeLabel = switch (item.sourceType) {
      'goal' => 'Goal',
      'progress' => 'Progress',
      'log' => 'Log',
      _ => 'Item',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        typeLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: typeColor,
        ),
      ),
    );
  }

  String _formatDeletedDate(DateTime deletedAt) {
    final now = DateTime.now();
    final difference = now.difference(deletedAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'now';
      } else if (difference.inHours == 1) {
        return '1 hour ago';
      } else {
        return '${difference.inHours} hours ago';
      }
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  Widget _buildItemPreview(BuildContext context) {
    String preview = '';

    switch (item) {
      case TrashGoal(:final goal):
        preview = goal.description ?? 'No description';
        break;
      case TrashProgressEntry(:final entry):
        preview = entry.note ?? 'No note';
        break;
      case TrashLogEntry(:final entry):
        preview = entry.detail ?? 'No detail';
        break;
    }

    if (preview.length > 100) {
      preview = '${preview.substring(0, 100)}...';
    }

    return Text(
      preview,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
