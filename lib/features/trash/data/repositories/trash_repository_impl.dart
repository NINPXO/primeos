import 'package:primeos/core/types/app_result.dart';
import '../../domain/entities/trash_item.dart';
import '../../domain/repositories/trash_repository.dart';
import '../datasources/trash_local_datasource.dart';

class TrashRepositoryImpl implements TrashRepository {
  final TrashLocalDatasource _datasource;

  TrashRepositoryImpl(this._datasource);

  @override
  Future<AppResult<List<TrashItem>>> getAllTrash() async {
    try {
      final items = await _datasource.getAllTrash();
      return AppSuccess(items);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<TrashItem>>> getTrashByType(String type) async {
    try {
      final items = await _datasource.getTrashByType(type);
      return AppSuccess(items);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> restoreItem(String id, String type) async {
    try {
      await _datasource.restoreItem(id, type);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> hardDeleteItem(String id, String type) async {
    try {
      await _datasource.hardDeleteItem(id, type);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> emptyTrash() async {
    try {
      await _datasource.emptyTrash();
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }
}
