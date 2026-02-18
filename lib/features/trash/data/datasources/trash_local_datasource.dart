import 'package:sqflite/sqflite.dart';
import '../../domain/entities/trash_item.dart';

abstract interface class TrashLocalDatasource {
  Future<List<TrashItem>> getAllTrash();
  Future<List<TrashItem>> getTrashByType(String type);
  Future<void> restoreItem(String id, String type);
  Future<void> hardDeleteItem(String id, String type);
  Future<void> emptyTrash();
}

class TrashLocalDatasourceImpl implements TrashLocalDatasource {
  static const _goalsTable = 'goals';
  static const _progressTable = 'progress_entries';
  static const _logsTable = 'daily_log_entries';

  final Database _db;

  TrashLocalDatasourceImpl(this._db);

  @override
  Future<List<TrashItem>> getAllTrash() async {
    try {
      final items = <TrashItem>[];

      // Query soft-deleted goals
      final deletedGoals = await _db.rawQuery('''
        SELECT id, title, deleted_at as deletedAt, 'goal' as sourceType,
               category_id as categoryId, status, description, target_value as targetValue,
               target_unit as targetUnit, target_date as targetDate,
               created_at as createdAt, updated_at as updatedAt, is_deleted as isDeleted
        FROM $_goalsTable
        WHERE is_deleted = 1
        ORDER BY deleted_at DESC
      ''');

      for (var row in deletedGoals) {
        items.add(TrashItem.fromMap(row, 'goal'));
      }

      // Query soft-deleted progress entries
      final deletedProgress = await _db.rawQuery('''
        SELECT id, note as title, deleted_at as deletedAt, 'progress' as sourceType,
               goal_id as goalId, category_id as categoryId, value, unit, tracking_period as trackingPeriod,
               logged_date as loggedDate, created_at as createdAt, updated_at as updatedAt, is_deleted as isDeleted
        FROM $_progressTable
        WHERE is_deleted = 1
        ORDER BY deleted_at DESC
      ''');

      for (var row in deletedProgress) {
        items.add(TrashItem.fromMap(row, 'progress'));
      }

      // Query soft-deleted log entries
      final deletedLogs = await _db.rawQuery('''
        SELECT id, title, deleted_at as deletedAt, 'log' as sourceType,
               log_date as logDate, category_id as categoryId, detail, duration_mins as durationMins,
               linked_type as linkedType, linked_id as linkedId,
               created_at as createdAt, updated_at as updatedAt, is_deleted as isDeleted
        FROM $_logsTable
        WHERE is_deleted = 1
        ORDER BY deleted_at DESC
      ''');

      for (var row in deletedLogs) {
        items.add(TrashItem.fromMap(row, 'log'));
      }

      // Sort all items by deletedAt descending (most recent first)
      items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));

      return items;
    } catch (e) {
      throw DatabaseException('Failed to fetch trash items: $e');
    }
  }

  @override
  Future<List<TrashItem>> getTrashByType(String type) async {
    try {
      final items = <TrashItem>[];

      switch (type) {
        case 'goal':
          final deletedGoals = await _db.rawQuery('''
            SELECT id, title, deleted_at as deletedAt, 'goal' as sourceType,
                   category_id as categoryId, status, description, target_value as targetValue,
                   target_unit as targetUnit, target_date as targetDate,
                   created_at as createdAt, updated_at as updatedAt, is_deleted as isDeleted
            FROM $_goalsTable
            WHERE is_deleted = 1
            ORDER BY deleted_at DESC
          ''');

          for (var row in deletedGoals) {
            items.add(TrashItem.fromMap(row, 'goal'));
          }
          break;

        case 'progress':
          final deletedProgress = await _db.rawQuery('''
            SELECT id, note as title, deleted_at as deletedAt, 'progress' as sourceType,
                   goal_id as goalId, category_id as categoryId, value, unit, tracking_period as trackingPeriod,
                   logged_date as loggedDate, created_at as createdAt, updated_at as updatedAt, is_deleted as isDeleted
            FROM $_progressTable
            WHERE is_deleted = 1
            ORDER BY deleted_at DESC
          ''');

          for (var row in deletedProgress) {
            items.add(TrashItem.fromMap(row, 'progress'));
          }
          break;

        case 'log':
          final deletedLogs = await _db.rawQuery('''
            SELECT id, title, deleted_at as deletedAt, 'log' as sourceType,
                   log_date as logDate, category_id as categoryId, detail, duration_mins as durationMins,
                   linked_type as linkedType, linked_id as linkedId,
                   created_at as createdAt, updated_at as updatedAt, is_deleted as isDeleted
            FROM $_logsTable
            WHERE is_deleted = 1
            ORDER BY deleted_at DESC
          ''');

          for (var row in deletedLogs) {
            items.add(TrashItem.fromMap(row, 'log'));
          }
          break;

        default:
          throw ArgumentError('Unknown type: $type');
      }

      return items;
    } catch (e) {
      throw DatabaseException('Failed to fetch trash items by type: $e');
    }
  }

  @override
  Future<void> restoreItem(String id, String type) async {
    try {
      final table = _getTableForType(type);
      await _db.update(
        table,
        {
          'is_deleted': 0,
          'deleted_at': null,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to restore item: $e');
    }
  }

  @override
  Future<void> hardDeleteItem(String id, String type) async {
    try {
      final table = _getTableForType(type);
      await _db.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to hard delete item: $e');
    }
  }

  @override
  Future<void> emptyTrash() async {
    try {
      // Delete all soft-deleted items from all three tables
      await _db.delete(
        _goalsTable,
        where: 'is_deleted = 1',
      );

      await _db.delete(
        _progressTable,
        where: 'is_deleted = 1',
      );

      await _db.delete(
        _logsTable,
        where: 'is_deleted = 1',
      );
    } catch (e) {
      throw DatabaseException('Failed to empty trash: $e');
    }
  }

  String _getTableForType(String type) {
    switch (type) {
      case 'goal':
        return _goalsTable;
      case 'progress':
        return _progressTable;
      case 'log':
        return _logsTable;
      default:
        throw ArgumentError('Unknown type: $type');
    }
  }
}
