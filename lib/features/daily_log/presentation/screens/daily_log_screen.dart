import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/daily_log/domain/entities/daily_log_entry.dart';
import 'package:primeos/features/daily_log/presentation/providers/daily_log_provider.dart';
import 'package:primeos/features/daily_log/presentation/widgets/log_category_filter.dart';
import 'package:primeos/features/daily_log/presentation/widgets/log_entry_card.dart';
import 'log_entry_form_screen.dart';

class DailyLogScreen extends ConsumerStatefulWidget {
  const DailyLogScreen({super.key});

  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(dailyLogProvider);
    final categoriesAsync = ref.watch(dailyLogCategoriesProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Log'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dailyLogProvider.notifier).refreshEntries();
        },
        child: entriesAsync.when(
          data: (entries) {
            final filteredEntries = _selectedCategoryId == null
                ? entries
                : entries
                    .where((e) => e.categoryId == _selectedCategoryId)
                    .toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Date navigation header
                  _buildDateHeader(selectedDate),

                  // Category filter
                  categoriesAsync.when(
                    data: (categories) => LogCategoryFilter(
                      categories: categories,
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: (categoryId) {
                        setState(() => _selectedCategoryId = categoryId);
                      },
                    ),
                    loading: () => const SizedBox(
                      height: 56,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (error, st) => const SizedBox(
                      height: 56,
                      child: Center(child: Text('Error loading categories')),
                    ),
                  ),

                  // Entries list or empty state
                  if (filteredEntries.isEmpty)
                    _buildEmptyState(selectedDate)
                  else
                    _buildEntriesList(filteredEntries),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading entries: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(dailyLogProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLogEntryForm(null, selectedDate);
        },
        tooltip: 'Add log entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateHeader(DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Date',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 7)),
                    );
                    if (pickedDate != null) {
                      await ref.read(dailyLogProvider.notifier).selectDate(pickedDate);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(selectedDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Previous button
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () async {
                  final previousDate = selectedDate.subtract(const Duration(days: 1));
                  await ref.read(dailyLogProvider.notifier).selectDate(previousDate);
                },
                tooltip: 'Previous day',
              ),
              // Today button
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final now = DateTime.now();
                  await ref.read(dailyLogProvider.notifier).selectDate(now);
                },
                tooltip: 'Today',
              ),
              // Next button
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () async {
                  final nextDate = selectedDate.add(const Duration(days: 1));
                  await ref.read(dailyLogProvider.notifier).selectDate(nextDate);
                },
                tooltip: 'Next day',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DateTime selectedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No entries yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first log entry for ${_formatDate(selectedDate)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showLogEntryForm(null, selectedDate);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesList(List<DailyLogEntry> entries) {
    // Group entries by category
    final Map<String, List<DailyLogEntry>> groupedEntries = {};
    for (final entry in entries) {
      if (!groupedEntries.containsKey(entry.categoryId)) {
        groupedEntries[entry.categoryId] = [];
      }
      groupedEntries[entry.categoryId]!.add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...groupedEntries.entries.map((groupEntry) {
          final categoryId = groupEntry.key;
          final categoryEntries = groupEntry.value;

          // Get category name from provider
          return ref.watch(dailyLogCategoriesProvider).when(
            data: (categories) {
              final category =
                  categories.firstWhere((c) => c.id == categoryId, orElse: () => null);
              final categoryName = category?.name ?? 'Unknown';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  ...categoryEntries.map((entry) {
                    return LogEntryCard(
                      entry: entry,
                      categoryName: categoryName,
                      onTap: () {
                        _showLogEntryForm(entry, entry.logDate);
                      },
                      onEdit: () {
                        _showLogEntryForm(entry, entry.logDate);
                      },
                      onDelete: () {
                        _showDeleteConfirmation(entry);
                      },
                    );
                  }),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, st) => const SizedBox.shrink(),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showLogEntryForm(DailyLogEntry? entry, DateTime initialDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return LogEntryFormSheet(
          existingEntry: entry,
          initialDate: initialDate,
        );
      },
    );
  }

  void _showDeleteConfirmation(DailyLogEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry?'),
          content: Text('Are you sure you want to delete "${entry.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(dailyLogProvider.notifier).deleteEntry(entry.id).then(
                  (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entry deleted')),
                    );
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $error'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
