import 'package:flutter/material.dart';

class ProgressPeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const ProgressPeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(
            value: 'daily',
            label: Text('Daily'),
            icon: Icon(Icons.calendar_view_day),
          ),
          ButtonSegment<String>(
            value: 'weekly',
            label: Text('Weekly'),
            icon: Icon(Icons.calendar_view_week),
          ),
          ButtonSegment<String>(
            value: 'monthly',
            label: Text('Monthly'),
            icon: Icon(Icons.calendar_view_month),
          ),
        ],
        selected: {selectedPeriod},
        onSelectionChanged: (value) {
          if (value.isNotEmpty) {
            onPeriodChanged(value.first);
          }
        },
      ),
    );
  }
}
