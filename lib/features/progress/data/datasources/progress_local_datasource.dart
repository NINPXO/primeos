import 'package:sqflite/sqflite.dart';
import '../models/progress_entry_model.dart';

abstract interface class ProgressLocalDatasource {
  Future<List<ProgressEntryModel>> getAllProgress({bool includeDeleted = false});
  Future<List<ProgressEntryModel>> getProgressForGoal(
    String goalId, {
    bool includeDeleted = false,
  });
  Future<List<ProgressEntryModel>> getProgressByPeriod(
    DateTime startDate,
    DateTime endDate,
    String? categoryId, {
    bool includeDeleted = false,
  });
  Future<List<ProgressEntryModel>> getProgressByTrackingPeriod(
    String trackingPeriod, {
    String? categoryId,
    bool includeDeleted = false,
  });
  Future<ProgressEntryModel?> getProgressById(String id);
  Future<void> createProgressEntry(ProgressEntryModel entry);
  Future<void> updateProgressEntry(ProgressEntryModel entry);
  Future<void> softDeleteProgressEntry(String id);
  Future<List<Map<String, dynamic>>> exportProgressForCsv(String? categoryId);
}

class ProgressLocalDatasourceImpl implements ProgressLocalDatasource {
  static const _progressTable = 'progress_entries';
  static const _goalsTable = 'goals';
  static const _categoriesTable = 'goal_categories';
  static const _ftsTable = 'fts_search';

  final Database _db;

  ProgressLocalDatasourceImpl(this._db);

  @override
  Future<List<ProgressEntryModel>> getAllProgress(
      {bool includeDeleted = false}) async {
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final maps = await _db.query(
      _progressTable,
      where: whereClause,
    );
    return maps.map((m) => ProgressEntryModel.fromMap(m)).toList();
  }

  @override
  Future<List<ProgressEntryModel>> getProgressForGoal(
    String goalId, {
    bool includeDeleted = false,
  }) async {
    final whereClause = includeDeleted
        ? 'goal_id = ?'
        : 'goal_id = ? AND is_deleted = 0';
    final maps = await _db.query(
      _progressTable,
      where: whereClause,
      whereArgs: [goalId],
    );
    return maps.map((m) => ProgressEntryModel.fromMap(m)).toList();
  }

  @override
  Future<List<ProgressEntryModel>> getProgressByPeriod(
    DateTime startDate,
    DateTime endDate,
    String? categoryId, {
    bool includeDeleted = false,
  }) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    final baseWhere = includeDeleted
        ? 'logged_date >= ? AND logged_date <= ?'
        : 'logged_date >= ? AND logged_date <= ? AND is_deleted = 0';

    final finalWhere = categoryId != null
        ? '$baseWhere AND category_id = ?'
        : baseWhere;

    final args =
        categoryId != null ? [startStr, endStr, categoryId] : [startStr, endStr];

    final maps = await _db.query(
      _progressTable,
      where: finalWhere,
      whereArgs: args,
    );
    return maps.map((m) => ProgressEntryModel.fromMap(m)).toList();
  }

  @override
  Future<List<ProgressEntryModel>> getProgressByTrackingPeriod(
    String trackingPeriod, {
    String? categoryId,
    bool includeDeleted = false,
  }) async {
    final baseWhere = includeDeleted
        ? 'tracking_period = ?'
        : 'tracking_period = ? AND is_deleted = 0';

    final finalWhere = categoryId != null
        ? '$baseWhere AND category_id = ?'
        : baseWhere;

    final args = categoryId != null
        ? [trackingPeriod, categoryId]
        : [trackingPeriod];

    final maps = await _db.query(
      _progressTable,
      where: finalWhere,
      whereArgs: args,
    );
    return maps.map((m) => ProgressEntryModel.fromMap(m)).toList();
  }

  @override
  Future<ProgressEntryModel?> getProgressById(String id) async {
    final maps = await _db.query(
      _progressTable,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ProgressEntryModel.fromMap(maps.first);
  }

  @override
  Future<void> createProgressEntry(ProgressEntryModel entry) async {
    await _db.insert(_progressTable, entry.toMap());
    await _insertFtsEntry(
      sourceType: 'progress_entry',
      sourceId: entry.id,
      title: 'Progress for ${entry.goalId}',
      body: '${entry.trackingPeriod} progress: ${entry.value} ${entry.unit ?? ''} ${entry.note ?? ''}',
    );
  }

  @override
  Future<void> updateProgressEntry(ProgressEntryModel entry) async {
    await _db.update(
      _progressTable,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    await _db.delete(
      _ftsTable,
      where: 'source_type = ? AND source_id = ?',
      whereArgs: ['progress_entry', entry.id],
    );
    await _insertFtsEntry(
      sourceType: 'progress_entry',
      sourceId: entry.id,
      title: 'Progress for ${entry.goalId}',
      body: '${entry.trackingPeriod} progress: ${entry.value} ${entry.unit ?? ''} ${entry.note ?? ''}',
    );
  }

  @override
  Future<void> softDeleteProgressEntry(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      _progressTable,
      {
        'is_deleted': 1,
        'deleted_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _db.delete(
      _ftsTable,
      where: 'source_type = ? AND source_id = ?',
      whereArgs: ['progress_entry', id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> exportProgressForCsv(
    String? categoryId,
  ) async {
    final baseQuery = '''
      SELECT
        p.id,
        p.goal_id,
        g.title as goal_title,
        p.category_id,
        gc.name as category_name,
        p.value,
        p.unit,
        p.note,
        p.tracking_period,
        p.logged_date,
        p.created_at,
        p.updated_at
      FROM $_progressTable p
      LEFT JOIN $_goalsTable g ON p.goal_id = g.id
      LEFT JOIN $_categoriesTable gc ON p.category_id = gc.id
      WHERE p.is_deleted = 0
    ''';

    final query = categoryId != null
        ? '$baseQuery AND p.category_id = ?'
        : baseQuery;

    final args = categoryId != null ? [categoryId] : [];
    final results = await _db.rawQuery(query, args);
    return results;
  }

  Future<void> _insertFtsEntry({
    required String sourceType,
    required String sourceId,
    required String title,
    required String body,
  }) async {
    await _db.insert(_ftsTable, {
      'source_type': sourceType,
      'source_id': sourceId,
      'title': title,
      'body': body,
    });
  }
}
