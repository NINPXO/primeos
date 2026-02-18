import '../../../core/models/app_result.dart';
import '../repositories/trash_repository.dart';
import 'params.dart';

abstract interface class HardDeleteItem {
  Future<AppResult<void>> call(HardDeleteItemParams params);
}

final class HardDeleteItemImpl implements HardDeleteItem {
  final TrashRepository _repository;

  HardDeleteItemImpl(this._repository);

  @override
  Future<AppResult<void>> call(HardDeleteItemParams params) {
    final validTypes = ['goal', 'progress', 'log'];
    if (!validTypes.contains(params.itemType)) {
      return Future.value(
        AppResult<void>.failure(
          Exception('Invalid item type: ${params.itemType}. Must be one of: $validTypes'),
        ),
      );
    }
    return _repository.hardDeleteItem(params.itemId, params.itemType);
  }
}
