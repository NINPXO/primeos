import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_bar.dart';

/// Main application scaffold with persistent navigation.
/// Provides AppBar with search/settings and BottomNavigationBar for tab switching.
class AppScaffold extends StatefulWidget {
  /// The main content widget (typically from GoRouter's navigationShell)
  final Widget child;

  const AppScaffold({
    required this.child,
    super.key,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  /// Current selected tab index for bottom nav
  int _selectedIndex = 0;

  /// Map route paths to bottom nav indices
  static const Map<String, int> _routeToIndex = {
    '/': 0,
    '/daily-log': 1,
    '/goals': 2,
    '/progress': 3,
    '/notes': 4,
  };

  @override
  Widget build(BuildContext context) {
    // Update selected index based on current route
    final currentRoute = GoRouterState.of(context).uri.path;
    if (_routeToIndex.containsKey(currentRoute)) {
      _selectedIndex = _routeToIndex[currentRoute]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PrimeOS'),
        elevation: 0,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.go('/search');
            },
            tooltip: 'Search',
          ),
          // Settings menu button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                context.go('/settings');
              } else if (value == 'trash') {
                context.go('/trash');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'trash',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Trash'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu',
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: PrimeOSBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          // Navigate to corresponding route
          final routePaths = ['/', '/daily-log', '/goals', '/progress', '/notes'];
          if (index >= 0 && index < routePaths.length) {
            context.go(routePaths[index]);
          }
        },
      ),
    );
  }
}
