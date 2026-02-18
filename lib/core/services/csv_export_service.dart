import 'dart:typed_data';
import 'dart:convert';
import 'package:csv/csv.dart';

class CsvExportService {
  /// Exports a list of data rows with headers to CSV bytes.
  /// Returns UTF-8 encoded bytes with BOM for Excel compatibility.
  static Future<Uint8List> exportToCsvBytes(
    List<Map<String, dynamic>> rows,
    List<String> headers,
  ) async {
    final csvRows = <List<dynamic>>[
      headers,
      ...rows.map((row) => headers.map((header) => row[header] ?? '').toList())
    ];

    final csvString = const ListToCsvConverter().convert(csvRows);
    final csvWithBom = '\uFEFF' + csvString;
    return Uint8List.fromList(utf8.encode(csvWithBom));
  }
}
