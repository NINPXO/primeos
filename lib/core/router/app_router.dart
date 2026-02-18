import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_scaffold.dart';

// Placeholder screens
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard'));
  }
}

class DailyLogScreen extends StatelessWidget {
  const DailyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Daily Log'));
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Goals'));
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Progress'));
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Notes'));
  }
}

class GlobalSearchScreen extends StatelessWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Global Search'));
  }
}

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Trash'));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings'));
  }
}

/// GoRouter configuration for PrimeOS app.
/// Defines all routes with a StatefulShellRoute for bottom navigation tabs.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(child: navigationShell);
      },
      branches: [
        // Branch 0: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Branch 1: Daily Log
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/daily-log',
              name: 'daily-log',
              builder: (context, state) => const DailyLogScreen(),
            ),
          ],
        ),
        // Branch 2: Goals
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              name: 'goals',
              builder: (context, state) => const GoalsScreen(),
            ),
          ],
        ),
        // Branch 3: Progress
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              name: 'progress',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        ),
        // Branch 4: Notes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              name: 'notes',
              builder: (context, state) => const NotesScreen(),
            ),
          ],
        ),
      ],
    ),
    // Non-tabbed routes
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const GlobalSearchScreen(),
    ),
    GoRoute(
      path: '/trash',
      name: 'trash',
      builder: (context, state) => const TrashScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
