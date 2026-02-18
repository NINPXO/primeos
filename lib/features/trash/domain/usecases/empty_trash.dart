import '../../../core/models/app_result.dart';
import '../repositories/trash_repository.dart';
import 'params.dart';

abstract interface class EmptyTrash {
  Future<AppResult<void>> call(EmptyTrashParams params);
}

final class EmptyTrashImpl implements EmptyTrash {
  final TrashRepository _repository;

  EmptyTrashImpl(this._repository);

  @override
  Future<AppResult<void>> call(EmptyTrashParams params) {
    return _repository.emptyTrash();
  }
}
