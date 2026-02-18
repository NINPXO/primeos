import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

/// Provides singleton access to the SQLite [Database] instance.
///
/// Usage:
/// ```dart
/// final db = await ref.watch(databaseProvider.future);
/// // OR
/// ref.watch(databaseProvider).whenData((db) => ...);
/// ```
final databaseProvider = FutureProvider<Database>((ref) async {
  final appDb = AppDatabase();
  return appDb.database;
});
