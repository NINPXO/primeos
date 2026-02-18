import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeos/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:primeos/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:primeos/features/dashboard/presentation/widgets/active_progress_card.dart';
import 'package:primeos/features/dashboard/presentation/widgets/weekly_chart_card.dart';
import 'package:primeos/features/dashboard/presentation/widgets/quick_actions_row.dart';
import 'package:primeos/features/progress/domain/entities/progress_entry.dart';
import 'package:primeos/features/progress/presentation/providers/progress_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PrimeOS'),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.goNamed('settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(dashboardProvider.notifier).refreshDashboard(),
        child: dashboardAsync.when(
          // Loading state with skeleton
          loading: () => _buildLoadingSkeleton(context),
          // Error state with retry
          error: (error, st) => _buildErrorState(
            context,
            error,
            () => ref.read(dashboardProvider.notifier).refreshDashboard(),
          ),
          // Data state
          data: (summary) {
            // Get active progress entries (last 7 days)
            final activeProgressEntries = progressAsync.maybeWhen(
              data: (entries) => entries,
              orElse: () => <ProgressEntry>[],
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's stats row (3 cards)
                  Row(
                    children: [
                      SummaryCard(
                        title: "Today's Goals",
                        count: summary.todayGoalsCount,
                        icon: Icons.flag,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => context.goNamed('goals'),
                      ),
                      const SizedBox(width: 8),
                      SummaryCard(
                        title: "Week's Goals",
                        count: summary.weekGoalsCount,
                        icon: Icons.calendar_month,
                        color: Theme.of(context).colorScheme.secondary,
                        onTap: () => context.goNamed('goals'),
                      ),
                      const SizedBox(width: 8),
                      SummaryCard(
                        title: "Month's Goals",
                        count: summary.monthGoalsCount,
                        icon: Icons.trending_up,
                        color: Theme.of(context).colorScheme.tertiary,
                        onTap: () => context.goNamed('goals'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Active Progress Card
                  ActiveProgressCard(
                    progressEntries: activeProgressEntries,
                    totalActiveCount: summary.activeProgressCount,
                  ),
                  const SizedBox(height: 24),

                  // Weekly Summary Chart
                  WeeklyChartCard(
                    weeklyData: summary.weeklyChartData,
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions Row
                  const QuickActionsRow(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build loading skeleton
  Widget _buildLoadingSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton for summary cards
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 120,
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Skeleton for active progress card
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),

          // Skeleton for chart
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),

          // Skeleton for buttons
          Row(
            children: List.generate(
              2,
              (index) => Expanded(
                child: Container(
                  height: 48,
                  margin: EdgeInsets.only(right: index == 0 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState(
    BuildContext context,
    Object error,
    VoidCallback onRetry,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
