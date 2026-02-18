import 'package:sqflite/sqflite.dart';
import 'migration_v1.dart';

/// Executes all pending migrations from oldVersion to newVersion.
Future<void> runMigrations(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  // For each version from oldVersion+1 to newVersion, execute the appropriate migration
  if (oldVersion < 1 && newVersion >= 1) {
    final batch = db.batch();
    createV1Schema(batch);
    await batch.commit();
  }

  // Future migrations would be added here:
  // if (oldVersion < 2 && newVersion >= 2) {
  //   final batch = db.batch();
  //   createV2Schema(batch);
  //   await batch.commit();
  // }
}
