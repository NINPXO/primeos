import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  /// Exports the database file as a backup and shares it.
  /// Creates a timestamped copy in the downloads directory.
  static Future<void> exportDatabaseBackup(Database db) async {
    final databasesPath = await getDatabasesPath();
    final sourceDbPath = join(databasesPath, 'primeos.db');
    final sourceFile = File(sourceDbPath);

    final downloadDir = await getDownloadsDirectory();
    if (downloadDir == null) {
      throw Exception('Downloads directory not available');
    }

    final timestamp = DateTime.now().toIso8601String();
    final backupFileName = 'primeos_backup_$timestamp.db';
    final backupPath = join(downloadDir.path, backupFileName);

    await sourceFile.copy(backupPath);

    await Share.shareXFiles(
      [XFile(backupPath, mimeType: 'application/octet-stream')],
    );
  }
}
