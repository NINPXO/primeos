import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:primeos/features/progress/presentation/providers/progress_provider.dart';
import 'package:primeos/features/goals/presentation/providers/goals_provider.dart';

class ProgressChartScreen extends ConsumerStatefulWidget {
  final String goalId;

  const ProgressChartScreen({
    required this.goalId,
    super.key,
  });

  @override
  ConsumerState<ProgressChartScreen> createState() =>
      _ProgressChartScreenState();
}

class _ProgressChartScreenState extends ConsumerState<ProgressChartScreen> {
  String _selectedPeriod = 'weekly'; // daily|weekly|monthly

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: goalsAsync.whenData(
          (goals) {
            final goal =
                goals.firstWhere((g) => g.id == widget.goalId, orElse: () => null);
            return Text(goal?.title ?? 'Progress Chart');
          },
        ).when(
          data: (text) => Text(text),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Progress Chart'),
        ),
      ),
      body: progressAsync.when(
        data: (entries) {
          final goalEntries =
              entries.where((e) => e.goalId == widget.goalId).toList();

          if (goalEntries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No progress data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log progress entries to see a chart',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort by logged date
          goalEntries.sort((a, b) => a.loggedDate.compareTo(b.loggedDate));

          // Filter by period if needed
          final now = DateTime.now();
          List<dynamic> filteredEntries = goalEntries;

          if (_selectedPeriod == 'weekly') {
            filteredEntries = goalEntries
                .where((e) =>
                    now.difference(e.loggedDate).inDays <= 7)
                .toList();
          } else if (_selectedPeriod == 'monthly') {
            filteredEntries = goalEntries
                .where((e) =>
                    now.difference(e.loggedDate).inDays <= 30)
                .toList();
          }

          if (filteredEntries.isEmpty) {
            return Center(
              child: Text(
                'No data for selected period',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          // Create chart data points
          final spots = <FlSpot>[];
          for (int i = 0; i < filteredEntries.length; i++) {
            final entry = filteredEntries[i];
            spots.add(FlSpot(i.toDouble(), entry.value));
          }

          return Column(
            children: [
              // Period selector
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPeriodButton('Daily', 'daily'),
                    _buildPeriodButton('Weekly', 'weekly'),
                    _buildPeriodButton('Monthly', 'monthly'),
                  ],
                ),
              ),
              // Chart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: null,
                        verticalInterval: 1,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _calculateInterval(spots),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < filteredEntries.length) {
                                final entry = filteredEntries[index];
                                return Text(
                                  '${entry.loggedDate.month}/${entry.loggedDate.day}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primaryContainer,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha((0.3 * 255).toInt()),
                                Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withAlpha((0.1 * 255).toInt()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                'Error loading progress data',
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
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedPeriod = period);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(label),
    );
  }

  double _calculateInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final maxValue = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    if (maxValue <= 1) return 0.25;
    if (maxValue <= 10) return 1;
    if (maxValue <= 100) return 10;
    return (maxValue / 10).roundToDouble();
  }
}
