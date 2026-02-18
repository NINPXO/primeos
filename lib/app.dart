import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

class PrimeOSApp extends ConsumerWidget {
  const PrimeOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Watch theme provider
    // final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'PrimeOS',
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
