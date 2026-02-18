import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/trash/presentation/providers/trash_provider.dart';
import 'package:primeos/features/trash/presentation/widgets/trash_item_card.dart';
import 'package:primeos/features/trash/presentation/widgets/trash_section_header.dart';
import 'package:primeos/features/trash/presentation/widgets/trash_empty_state.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final trashAsync = ref.watch(trashProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: trashAsync.when(
                data: (items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: items.isEmpty ? null : () => _confirmEmptyTrash(context),
                        child: const Text(
                          'Empty',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(trashProvider.notifier).refreshTrash(),
        child: Column(
          children: [
            // Type filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedFilter == 'all',
                      onSelected: (_) {
                        setState(() => _selectedFilter = 'all');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('Goals'),
                      selected: _selectedFilter == 'goal',
                      onSelected: (_) {
                        setState(() => _selectedFilter = 'goal');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('Progress'),
                      selected: _selectedFilter == 'progress',
                      onSelected: (_) {
                        setState(() => _selectedFilter = 'progress');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('Logs'),
                      selected: _selectedFilter == 'log',
                      onSelected: (_) {
                        setState(() => _selectedFilter = 'log');
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Trash items list
            Expanded(
              child: trashAsync.when(
                data: (allItems) {
                  final filteredItems = ref
                      .read(trashProvider.notifier)
                      .filterByType(_selectedFilter);

                  if (filteredItems.isEmpty) {
                    return const TrashEmptyState();
                  }

                  // Group items by type
                  final groupedItems = <String, List<dynamic>>{};
                  for (final item in filteredItems) {
                    final type = item.sourceType;
                    groupedItems.putIfAbsent(type, () => []).add(item);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _selectedFilter == 'all'
                        ? groupedItems.length * 2 + filteredItems.length
                        : filteredItems.length,
                    itemBuilder: (context, index) {
                      if (_selectedFilter == 'all') {
                        // Calculate which group and position
                        int itemIndex = 0;
                        for (final type in groupedItems.keys) {
                          if (index == itemIndex) {
                            // Return section header
                            return TrashSectionHeader(
                              type: type,
                              count: groupedItems[type]!.length,
                            );
                          }
                          itemIndex++;

                          // Return items for this type
                          for (final item in groupedItems[type]!) {
                            if (index == itemIndex) {
                              return TrashItemCard(
                                item: item,
                                onRestore: () => _restoreItem(context, item.id, item.sourceType),
                                onDelete: () => _confirmHardDelete(context, item.id, item.sourceType),
                              );
                            }
                            itemIndex++;
                          }
                        }
                      } else {
                        // Single type - no headers
                        return TrashItemCard(
                          item: filteredItems[index],
                          onRestore: () => _restoreItem(
                            context,
                            filteredItems[index].id,
                            filteredItems[index].sourceType,
                          ),
                          onDelete: () => _confirmHardDelete(
                            context,
                            filteredItems[index].id,
                            filteredItems[index].sourceType,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
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
                        'Error loading trash',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('$error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(trashProvider),
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
    );
  }

  void _restoreItem(BuildContext context, String id, String type) {
    ref.read(trashProvider.notifier).restoreItem(id, type).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item restored successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  void _confirmHardDelete(BuildContext context, String id, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: const Text(
          'This item will be permanently deleted and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(trashProvider.notifier).hardDeleteItem(id, type).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Item deleted permanently'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: $error'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash'),
        content: const Text(
          'All items in trash will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(trashProvider.notifier).emptyTrash().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Trash emptied'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to empty trash: $error'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              });
            },
            child: const Text(
              'Empty',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
