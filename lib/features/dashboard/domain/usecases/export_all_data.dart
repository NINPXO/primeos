import 'dart:typed_data';

import '../../../core/services/csv_export_service.dart';
import '../../../core/types/app_result.dart';
import '../repositories/dashboard_repository.dart';
import 'params.dart';

abstract interface class ExportAllData {
  Future<AppResult<Uint8List>> call(ExportAllDataParams params);
}

final class ExportAllDataImpl implements ExportAllData {
  final DashboardRepository _repository;
  final CsvExportService _csvExportService;

  ExportAllDataImpl(this._repository, this._csvExportService);

  @override
  Future<AppResult<Uint8List>> call(ExportAllDataParams params) async {
    // Fetch all data from the repository
    final result = await _repository.exportAllData();

    return result.fold(
      (failure) => AppResult.failure(failure),
      (rows) {
        // Define headers for the combined export (covering all tables)
        // Headers should include fields from goals, progress, daily_log, and notes
        final headers = [
          'id',
          'type', // goal, progress, log, note
          'title',
          'description',
          'value',
          'unit',
          'status',
          'category_id',
          'category_name',
          'goal_id',
          'logged_date',
          'tracking_period',
          'note',
          'tags',
          'is_archived',
          'created_at',
          'updated_at',
        ];

        // Export to CSV bytes
        final csvBytes = _csvExportService.exportToCsvBytes(rows, headers);
        return AppResult.success(csvBytes);
      },
    );
  }
}
