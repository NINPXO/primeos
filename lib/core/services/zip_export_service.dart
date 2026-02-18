import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'csv_export_service.dart';

/// Service for exporting the entire database as a ZIP archive.
/// Includes CSV exports of all data tables and the database file itself.
class ZipExportService {
  /// Tables to export as CSV (excludes app_settings, note_tags, notes_tags_junction)
  static const List<String> _tableNames = [
    'goals',
    'progress_entries',
    'daily_log_entries',
    'notes',
  ];

  /// Exports the full database as a ZIP file.
  /// Includes CSV files for each table and the SQLite database file.
  /// The ZIP is written to temp storage and shared via share_plus.
  ///
  /// Parameters:
  ///   - db: The SQLite Database instance
  ///
  /// Returns: Future that completes when export is done
  static Future<void> exportFullDatabaseAsZip(Database db) async {
    try {
      // Create archive in memory
      final archive = Archive();

      // Export each data table as CSV
      for (final tableName in _tableNames) {
        await _addTableToArchive(archive, db, tableName);
      }

      // Get database file and add to archive
      await _addDatabaseFileToArchive(archive, db);

      // Encode archive to bytes
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);

      if (zipBytes == null || zipBytes.isEmpty) {
        throw Exception('Failed to encode archive');
      }

      // Write to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final zipFilePath = '${tempDir.path}/primeos_backup_$timestamp.zip';
      final zipFile = File(zipFilePath);

      await zipFile.writeAsBytes(zipBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(zipFilePath)],
        subject: 'PrimeOS Database Backup',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Adds a single table's CSV export to the archive.
  static Future<void> _addTableToArchive(
    Archive archive,
    Database db,
    String tableName,
  ) async {
    // Query all rows from table
    final rows = await db.query(tableName);

    if (rows.isEmpty) {
      // Create empty CSV with headers only
      final emptyHeaders = <String>[];
      final csvBytes = await CsvExportService.exportToCsvBytes(
        [],
        emptyHeaders,
      );
      archive.addFile(
        ArchiveFile('$tableName.csv', csvBytes.length, csvBytes),
      );
      return;
    }

    // Extract headers from first row
    final headers = rows.first.keys.toList();

    // Export to CSV bytes
    final csvBytes = await CsvExportService.exportToCsvBytes(rows, headers);

    // Add file to archive
    archive.addFile(
      ArchiveFile('$tableName.csv', csvBytes.length, csvBytes),
    );
  }

  /// Adds the SQLite database file to the archive.
  static Future<void> _addDatabaseFileToArchive(
    Archive archive,
    Database db,
  ) async {
    // Get database file path
    final dbPath = db.path;
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception('Database file not found at $dbPath');
    }

    // Read file bytes
    final dbBytes = await dbFile.readAsBytes();

    // Add to archive
    final fileName = dbFile.path.split('/').last;
    archive.addFile(
      ArchiveFile(fileName, dbBytes.length, dbBytes),
    );
  }
}
