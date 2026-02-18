import 'package:flutter/material.dart';

/// Reusable bottom navigation bar for PrimeOS.
/// Displays 5 tabs: Dashboard, Daily Log, Goals, Progress, Notes.
class PrimeOSBottomNavBar extends StatelessWidget {
  /// Currently selected tab index (0-4)
  final int selectedIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  const PrimeOSBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: theme.colorScheme.surfaceContainer,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Daily Log',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag_outlined),
          activeIcon: Icon(Icons.flag),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_outlined),
          activeIcon: Icon(Icons.trending_up),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note_outlined),
          activeIcon: Icon(Icons.note),
          label: 'Notes',
        ),
      ],
    );
  }
}
