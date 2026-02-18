import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';

class CsvParseResult {
  final List<String> headers;
  final List<List<dynamic>> rows;
  final int rowCount;

  CsvParseResult({
    required this.headers,
    required this.rows,
    required this.rowCount,
  });
}

class ImportValidationResult {
  final bool isValid;
  final List<String> errors;

  ImportValidationResult({
    required this.isValid,
    required this.errors,
  });
}

class ImportResult {
  final int successCount;
  final int skipCount;
  final List<String> errors;

  ImportResult({
    required this.successCount,
    required this.skipCount,
    required this.errors,
  });
}

class CsvImportService {
  /// Parses a CSV file selected by the user.
  /// Returns CsvParseResult with headers and data rows, or null if cancelled.
  static Future<CsvParseResult?> parseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    final csvString = await file.readAsString(encoding: utf8);

    final csvData = const CsvToListConverter(eol: '\n').convert(csvString);

    if (csvData.isEmpty) {
      return CsvParseResult(headers: [], rows: [], rowCount: 0);
    }

    final headers = csvData.first.cast<String>();
    final rows = csvData.skip(1).toList();

    return CsvParseResult(
      headers: headers,
      rows: rows,
      rowCount: rows.length,
    );
  }

  /// Validates that the parsed CSV matches expected headers.
  /// Checks header count, names (case-insensitive), and required columns.
  static ImportValidationResult validateImport(
    CsvParseResult parseResult,
    List<String> expectedHeaders,
  ) {
    final errors = <String>[];

    if (parseResult.headers.length != expectedHeaders.length) {
      errors.add(
        'Column count mismatch: expected ${expectedHeaders.length}, got ${parseResult.headers.length}',
      );
    }

    final headerLower = parseResult.headers.map((h) => h.toLowerCase()).toList();
    final expectedLower = expectedHeaders.map((h) => h.toLowerCase()).toList();

    for (final expectedHeader in expectedLower) {
      if (!headerLower.contains(expectedHeader)) {
        errors.add('Missing required column: $expectedHeader');
      }
    }

    final requiredColumns = ['id', 'title', 'created_at'];
    for (final required in requiredColumns) {
      if (!headerLower.contains(required)) {
        errors.add('Missing critical column: $required');
      }
    }

    return ImportValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Imports CSV data into a database table with conflict resolution.
  /// mergeMode=true: INSERT OR IGNORE (skips duplicates)
  /// mergeMode=false: INSERT OR REPLACE (overwrites duplicates)
  static Future<ImportResult> importWithMode(
    Database db,
    String table,
    CsvParseResult parseResult,
    bool mergeMode,
  ) async {
    int successCount = 0;
    int skipCount = 0;
    final errors = <String>[];

    try {
      await db.transaction((txn) async {
        for (final row in parseResult.rows) {
          try {
            final dataMap = <String, dynamic>{};

            for (int i = 0; i < parseResult.headers.length; i++) {
              if (i < row.length) {
                dataMap[parseResult.headers[i]] = row[i];
              }
            }

            final conflictClause =
                mergeMode ? 'OR IGNORE' : 'OR REPLACE';

            await txn.rawInsert(
              'INSERT $conflictClause INTO $table (${dataMap.keys.join(',')}) VALUES (${List.filled(dataMap.length, '?').join(',')})',
              dataMap.values.toList(),
            );

            successCount++;
          } catch (e) {
            if (mergeMode && e.toString().contains('UNIQUE constraint failed')) {
              skipCount++;
            } else {
              errors.add('Row error: ${e.toString()}');
            }
          }
        }
      });
    } catch (e) {
      errors.add('Transaction failed: ${e.toString()}');
    }

    return ImportResult(
      successCount: successCount,
      skipCount: skipCount,
      errors: errors,
    );
  }
}
