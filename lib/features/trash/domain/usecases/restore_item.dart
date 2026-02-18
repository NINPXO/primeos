import '../../../core/models/app_result.dart';
import '../repositories/trash_repository.dart';
import 'params.dart';

abstract interface class RestoreItem {
  Future<AppResult<void>> call(RestoreItemParams params);
}

final class RestoreItemImpl implements RestoreItem {
  final TrashRepository _repository;

  RestoreItemImpl(this._repository);

  @override
  Future<AppResult<void>> call(RestoreItemParams params) {
    return _repository.restoreItem(params.itemId, params.itemType);
  }
}
