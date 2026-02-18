import 'package:sqflite/sqflite.dart';

/// Executes a callback within a database transaction.
/// Automatically rolls back on error.
Future<void> executeTransaction(
  Database db,
  Future<void> Function() callback,
) async {
  await db.transaction((txn) async {
    await callback();
  });
}

/// Queries all rows from a table with optional WHERE clause.
Future<List<Map<String, dynamic>>> queryAll(
  Database db,
  String table, {
  String? where,
  List<Object?>? whereArgs,
}) async {
  return await db.query(
    table,
    where: where,
    whereArgs: whereArgs,
  );
}

/// Inserts multiple rows into a table as a batch operation.
Future<void> insertBatch(
  Database db,
  String table,
  List<Map<String, dynamic>> rows,
) async {
  if (rows.isEmpty) return;

  final batch = db.batch();
  for (final row in rows) {
    batch.insert(table, row);
  }
  await batch.commit();
}
