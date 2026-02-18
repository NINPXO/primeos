import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize database and other async services

  runApp(
    const ProviderScope(
      child: PrimeOSApp(),
    ),
  );
}
