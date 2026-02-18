import 'dart:typed_data';

import '../../../core/types/app_result.dart';
import '../../../core/services/csv_export_service.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class ExportNotesCsv {
  Future<AppResult<Uint8List>> call(ExportNotesCsvParams params);
}

final class ExportNotesCsvImpl implements ExportNotesCsv {
  final NotesRepository _repository;
  final CsvExportService _csvExportService;

  ExportNotesCsvImpl(this._repository, this._csvExportService);

  @override
  Future<AppResult<Uint8List>> call(ExportNotesCsvParams params) async {
    final result = await _repository.exportNotesForCsv();

    if (result is AppError<List<Map<String, dynamic>>>) {
      return AppResult.failure((result as AppError<List<Map<String, dynamic>>>).failure);
    }

    final rows = (result as AppSuccess<List<Map<String, dynamic>>>).data;
    final headers = [
      'id',
      'title',
      'content_plain',
      'tags',
      'is_archived',
      'archived_at',
      'created_at',
      'updated_at'
    ];

    // Transform tags from pipe-separated string or list
    final transformedRows = rows.map((row) {
      final rowCopy = Map<String, dynamic>.from(row);
      if (rowCopy.containsKey('tags')) {
        final tags = rowCopy['tags'];
        if (tags is List) {
          rowCopy['tags'] = tags.join('|');
        } else if (tags != null) {
          rowCopy['tags'] = tags.toString();
        } else {
          rowCopy['tags'] = '';
        }
      }
      return rowCopy;
    }).toList();

    final csvBytes = await _csvExportService.exportToCsvBytes(transformedRows, headers);
    return AppResult.success(csvBytes);
  }
}
