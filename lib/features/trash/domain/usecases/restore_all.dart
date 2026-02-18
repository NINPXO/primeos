import '../../../core/models/app_result.dart';
import '../entities/trash_item.dart';
import '../repositories/trash_repository.dart';
import 'params.dart';

abstract interface class RestoreAll {
  Future<AppResult<int>> call(NoParams params);
}

final class RestoreAllImpl implements RestoreAll {
  final TrashRepository _repository;

  RestoreAllImpl(this._repository);

  @override
  Future<AppResult<int>> call(NoParams params) async {
    try {
      // Get all trash items
      final allTrashResult = await _repository.getAllTrash();

      if (allTrashResult is AppResultFailure<List<TrashItem>>) {
        return AppResult<int>.failure(allTrashResult.exception);
      }

      final trashItems = (allTrashResult as AppResultSuccess<List<TrashItem>>).data;

      // Restore each item
      int restoredCount = 0;
      for (final item in trashItems) {
        final restoreResult = await _repository.restoreItem(item.id, item.sourceType);
        if (restoreResult is AppResultSuccess<void>) {
          restoredCount++;
        }
      }

      return AppResult<int>.success(restoredCount);
    } catch (e) {
      return AppResult<int>.failure(e as Exception);
    }
  }
}
