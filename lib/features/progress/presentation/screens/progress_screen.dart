import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/progress/presentation/providers/progress_provider.dart';
import 'package:primeos/features/goals/presentation/providers/goal_categories_provider.dart';
import 'package:primeos/features/progress/presentation/widgets/progress_entry_card.dart';
import 'package:primeos/features/progress/presentation/screens/progress_form_screen.dart';
import 'package:primeos/features/progress/presentation/widgets/progress_period_selector.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String _selectedPeriod = 'daily'; // daily|weekly|monthly
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(progressProvider);
    final categoriesAsync = ref.watch(goalCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(progressProvider.notifier).refreshProgress(),
        child: Column(
          children: [
            // Period selector
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ProgressPeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: (period) {
                  setState(() => _selectedPeriod = period);
                },
              ),
            ),

            // Category filter chips
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
                        child: FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) {
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

            // Progress entries list
            Expanded(
              child: progressAsync.when(
                data: (entries) {
                  // Filter by category and period
                  final filteredEntries = entries
                      .where((e) =>
                          _selectedCategoryId == null ||
                          e.categoryId == _selectedCategoryId)
                      .where((e) => e.trackingPeriod == _selectedPeriod)
                      .toList();

                  // Group by date
                  final groupedByDate = <DateTime, List<dynamic>>{};
                  for (final entry in filteredEntries) {
                    final dateKey = DateTime(
                      entry.loggedDate.year,
                      entry.loggedDate.month,
                      entry.loggedDate.day,
                    );
                    groupedByDate.putIfAbsent(dateKey, () => []).add(entry);
                  }

                  if (filteredEntries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_up_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No progress entries',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log your progress to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Sort dates descending (most recent first)
                  final sortedDates = groupedByDate.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final entriesForDate = groupedByDate[date] ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              _formatDate(date),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          ...entriesForDate.map((entry) {
                            return ProgressEntryCard(
                              entry: entry,
                              onEdit: () =>
                                  _showEditProgressSheet(context, entry),
                              onDelete: () =>
                                  _confirmDeleteEntry(context, entry.id),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
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
                        'Error loading progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('$error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(progressProvider),
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
        onPressed: () => _showAddProgressSheet(context),
        tooltip: 'Add Progress',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  void _showAddProgressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const ProgressFormScreen(),
    );
  }

  void _showEditProgressSheet(BuildContext context, dynamic entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ProgressFormScreen(existingEntry: entry),
    );
  }

  void _confirmDeleteEntry(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(progressProvider.notifier).deleteEntry(entryId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
