import '../../../core/models/app_result.dart';
import '../entities/trash_item.dart';
import '../repositories/trash_repository.dart';
import 'params.dart';

abstract interface class GetAllTrash {
  Future<AppResult<List<TrashItem>>> call(NoParams params);
}

final class GetAllTrashImpl implements GetAllTrash {
  final TrashRepository _repository;

  GetAllTrashImpl(this._repository);

  @override
  Future<AppResult<List<TrashItem>>> call(NoParams params) {
    return _repository.getAllTrash();
  }
}
