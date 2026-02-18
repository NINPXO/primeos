import 'dart:typed_data';

import '../../../core/services/csv_export_service.dart';
import '../../../core/types/app_result.dart';
import '../repositories/progress_repository.dart';
import 'params.dart';

abstract interface class ExportProgressCsv {
  Future<AppResult<Uint8List>> call(ExportProgressCsvParams params);
}

final class ExportProgressCsvImpl implements ExportProgressCsv {
  final ProgressRepository _repository;
  final CsvExportService _csvExportService;

  ExportProgressCsvImpl(this._repository, this._csvExportService);

  @override
  Future<AppResult<Uint8List>> call(ExportProgressCsvParams params) async {
    final result = await _repository.exportProgressForCsv(params.categoryId);
    return result.fold(
      (failure) => AppError(failure),
      (rows) {
        final headers = [
          'id',
          'goal_id',
          'goal_title',
          'category_id',
          'category_name',
          'value',
          'unit',
          'note',
          'tracking_period',
          'logged_date',
          'created_at',
          'updated_at'
        ];
        final csvBytes = _csvExportService.exportToCsvBytes(rows, headers);
        return AppSuccess(csvBytes);
      },
    );
  }
}
