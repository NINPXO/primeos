import 'dart:typed_data';

import '../../../core/models/app_result.dart';
import '../../../core/services/csv_export_service.dart';
import '../repositories/goals_repository.dart';
import 'params.dart';

abstract interface class ExportGoalsCsv {
  Future<AppResult<Uint8List>> call(ExportGoalsCsvParams params);
}

final class ExportGoalsCsvImpl implements ExportGoalsCsv {
  final GoalsRepository _repository;
  final CsvExportService _csvExportService;

  ExportGoalsCsvImpl(this._repository, this._csvExportService);

  @override
  Future<AppResult<Uint8List>> call(ExportGoalsCsvParams params) async {
    final result = await _repository.exportGoalsForCsv(params.categoryId);
    return result.fold(
      (failure) => AppResult.failure(failure),
      (rows) {
        final headers = [
          'id',
          'category_id',
          'category_name',
          'title',
          'description',
          'status',
          'target_value',
          'target_unit',
          'target_date',
          'created_at',
          'updated_at'
        ];
        final csvBytes = _csvExportService.exportToCsvBytes(rows, headers);
        return AppResult.success(csvBytes);
      },
    );
  }
}
