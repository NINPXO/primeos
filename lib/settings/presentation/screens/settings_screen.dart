import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: appSettings.when(
        loading: () => const LoadingOverlay(message: 'Loading settings...'),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Theme section
              _buildSectionHeader(context, 'Display'),
              _buildThemeSelector(context, ref, themeMode),
              const Divider(height: 32),

              // Data Management section
              _buildSectionHeader(context, 'Data Management'),
              _buildDataManagementTiles(context),
              const Divider(height: 32),

              // Navigation section
              _buildSectionHeader(context, 'Navigation'),
              _buildNavigationTiles(context),
              const Divider(height: 32),

              // About section
              _buildSectionHeader(context, 'About'),
              _buildAboutTiles(context),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.system,
                  'System',
                  'Use device settings',
                  currentMode,
                ),
                Divider(
                  height: 0,
                  color: Colors.grey[300],
                ),
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.light,
                  'Light',
                  'Always light theme',
                  currentMode,
                ),
                Divider(
                  height: 0,
                  color: Colors.grey[300],
                ),
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.dark,
                  'Dark',
                  'Always dark theme',
                  currentMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    String title,
    String subtitle,
    ThemeMode currentMode,
  ) {
    final isSelected = mode == currentMode;
    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: currentMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          ref.read(themeModeProvider.notifier).setThemeMode(value);
        }
      },
      title: Text(title),
      subtitle: Text(subtitle),
      dense: true,
    );
  }

  Widget _buildDataManagementTiles(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Full Database Backup'),
          subtitle: const Text('Export entire .db file'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup feature coming soon')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Export as ZIP'),
          subtitle: const Text('CSVs + database file'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export feature coming soon')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Import from CSV'),
          subtitle: const Text('Merge or replace mode'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import feature coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavigationTiles(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Trash'),
          subtitle: const Text('View deleted items'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/trash');
          },
        ),
      ],
    );
  }

  Widget _buildAboutTiles(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About PrimeOS'),
          subtitle: const Text('Version 1.0.0'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showAboutDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Licenses'),
          subtitle: const Text('Open source software'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showLicensePage(context: context, applicationName: 'PrimeOS');
          },
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PrimeOS',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '© 2026 PrimeOS\n\nA personal multi-utility life tracker with local-only storage.',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Track your goals, progress, daily activities, and notes all in one place.',
          ),
        ),
      ],
    );
  }
}
