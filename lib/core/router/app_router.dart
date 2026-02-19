import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../features/search/presentation/screens/global_search_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/trash/presentation/screens/trash_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';

// Placeholder screens for features not yet implemented
class DailyLogScreen extends StatelessWidget {
  const DailyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Log')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Daily Log Feature'),
            SizedBox(height: 8),
            Text('Coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Goals Feature'),
            SizedBox(height: 8),
            Text('Coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Progress Feature'),
            SizedBox(height: 8),
            Text('Coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Notes Feature'),
            SizedBox(height: 8),
            Text('Coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
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
      pageBuilder: (context, state) => MaterialPage(
        fullscreenDialog: true,
        child: const GlobalSearchScreen(),
      ),
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
