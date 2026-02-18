import 'dart:typed_data';

import '../../../core/services/csv_export_service.dart';
import '../../../core/types/app_result.dart';
import '../repositories/daily_log_repository.dart';
import 'params.dart';

abstract interface class ExportLogsCsv {
  Future<AppResult<Uint8List>> call(ExportLogsCsvParams params);
}

final class ExportLogsCsvImpl implements ExportLogsCsv {
  final DailyLogRepository _repository;
  final CsvExportService _csvExportService;

  ExportLogsCsvImpl(this._repository, this._csvExportService);

  @override
  Future<AppResult<Uint8List>> call(ExportLogsCsvParams params) async {
    final result = await _repository.exportEntriesForCsv(
      params.startDate,
      params.endDate,
    );
    return result.fold(
      (failure) => AppError(failure),
      (rows) {
        final headers = [
          'id',
          'log_date',
          'category_id',
          'category_name',
          'title',
          'detail',
          'duration_mins',
          'linked_type',
          'linked_id',
          'created_at',
          'updated_at',
        ];
        final csvBytes = _csvExportService.exportToCsvBytes(rows, headers);
        return AppSuccess(csvBytes);
      },
    );
  }
}
