import '../../../core/models/app_result.dart';
import '../entities/trash_item.dart';
import '../repositories/trash_repository.dart';
import 'params.dart';

abstract interface class GetTrashByType {
  Future<AppResult<List<TrashItem>>> call(GetTrashByTypeParams params);
}

final class GetTrashByTypeImpl implements GetTrashByType {
  final TrashRepository _repository;

  GetTrashByTypeImpl(this._repository);

  @override
  Future<AppResult<List<TrashItem>>> call(GetTrashByTypeParams params) {
    final validTypes = ['goal', 'progress', 'log'];
    if (!validTypes.contains(params.type)) {
      return Future.value(
        AppResult<List<TrashItem>>.failure(
          Exception('Invalid trash type: ${params.type}. Must be one of: $validTypes'),
        ),
      );
    }
    return _repository.getTrashByType(params.type);
  }
}
