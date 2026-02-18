import 'package:primeos/core/types/app_result.dart';
import '../entities/trash_item.dart';

abstract interface class TrashRepository {
  Future<AppResult<List<TrashItem>>> getAllTrash();
  Future<AppResult<List<TrashItem>>> getTrashByType(String type);
  Future<AppResult<void>> restoreItem(String id, String type);
  Future<AppResult<void>> hardDeleteItem(String id, String type);
  Future<AppResult<void>> emptyTrash();
}
