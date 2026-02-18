import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:primeos/features/dashboard/presentation/providers/dashboard_provider.dart';

/// Row with 2 action buttons: Export All Data and Clear Date Range
class QuickActionsRow extends ConsumerStatefulWidget {
  const QuickActionsRow({super.key});

  @override
  ConsumerState<QuickActionsRow> createState() => _QuickActionsRowState();
}

class _QuickActionsRowState extends ConsumerState<QuickActionsRow> {
  bool _isExporting = false;
  bool _isClearing = false;
  DateTimeRange? _selectedDateRange;

  Future<void> _handleExportAllData() async {
    setState(() => _isExporting = true);

    try {
      await ref.read(dashboardProvider.notifier).exportAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _showDateRangePicker() async {
    final colorScheme = Theme.of(context).colorScheme;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectedDateRange = picked;
      if (mounted) {
        _showClearConfirmationDialog(picked);
      }
    }
  }

  void _showClearConfirmationDialog(DateTimeRange dateRange) {
    final colorScheme = Theme.of(context).colorScheme;
    final startDate = DateFormat('MMM dd, yyyy').format(dateRange.start);
    final endDate = DateFormat('MMM dd, yyyy').format(dateRange.end);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete all entries from:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start: $startDate',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'End: $endDate',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(context);
              _performClearDateRange(dateRange.start, dateRange.end);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error.withOpacity(0.2),
              foregroundColor: colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _performClearDateRange(DateTime start, DateTime end) async {
    setState(() => _isClearing = true);

    try {
      await ref.read(dashboardProvider.notifier).clearDateRange(start, end);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entries cleared successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clear failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Export All Data Button
        Expanded(
          child: FilledButton.icon(
            onPressed: _isExporting || _isClearing ? null : _handleExportAllData,
            icon: _isExporting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Exporting...' : 'Export All Data'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Clear Date Range Button
        Expanded(
          child: FilledButton.icon(
            onPressed: _isExporting || _isClearing ? null : _showDateRangePicker,
            icon: _isClearing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onErrorContainer,
                      ),
                    ),
                  )
                : const Icon(Icons.delete_sweep),
            label: Text(_isClearing ? 'Clearing...' : 'Clear Date Range'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: colorScheme.error.withOpacity(0.8),
              foregroundColor: colorScheme.onError,
            ),
          ),
        ),
      ],
    );
  }
}
