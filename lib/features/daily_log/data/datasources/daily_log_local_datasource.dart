import 'package:sqflite/sqflite.dart';
import '../models/daily_log_entry_model.dart';
import '../models/daily_log_category_model.dart';

abstract interface class DailyLogLocalDatasource {
  Future<List<DailyLogEntryModel>> getEntriesByDate(
    DateTime date, {
    bool includeDeleted = false,
  });
  Future<List<DailyLogEntryModel>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
    String? categoryId, {
    bool includeDeleted = false,
  });
  Future<List<DailyLogEntryModel>> getEntriesByCategory(
    String categoryId, {
    bool includeDeleted = false,
  });
  Future<DailyLogEntryModel?> getEntryById(String id);
  Future<void> createEntry(DailyLogEntryModel entry);
  Future<void> updateEntry(DailyLogEntryModel entry);
  Future<void> softDeleteEntry(String id);
  Future<List<DailyLogCategoryModel>> getAllCategories({
    bool includeDeleted = false,
  });
  Future<DailyLogCategoryModel?> getCategoryById(String id);
  Future<List<Map<String, dynamic>>> exportEntriesForCsv(
    DateTime? startDate,
    DateTime? endDate,
  );
}

class DailyLogLocalDatasourceImpl implements DailyLogLocalDatasource {
  static const _entriesTable = 'daily_log_entries';
  static const _categoriesTable = 'daily_log_categories';
  static const _ftsTable = 'fts_search';

  final Database _db;

  DailyLogLocalDatasourceImpl(this._db);

  @override
  Future<List<DailyLogEntryModel>> getEntriesByDate(
    DateTime date, {
    bool includeDeleted = false,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    final whereClause = includeDeleted
        ? 'log_date = ?'
        : 'log_date = ? AND is_deleted = 0';
    final maps = await _db.query(
      _entriesTable,
      where: whereClause,
      whereArgs: [dateStr],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => DailyLogEntryModel.fromMap(m)).toList();
  }

  @override
  Future<List<DailyLogEntryModel>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
    String? categoryId, {
    bool includeDeleted = false,
  }) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    String whereClause = includeDeleted
        ? 'log_date BETWEEN ? AND ?'
        : 'log_date BETWEEN ? AND ? AND is_deleted = 0';

    List<dynamic> whereArgs = [startStr, endStr];

    if (categoryId != null) {
      whereClause += ' AND category_id = ?';
      whereArgs.add(categoryId);
    }

    final maps = await _db.query(
      _entriesTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'log_date DESC, created_at DESC',
    );
    return maps.map((m) => DailyLogEntryModel.fromMap(m)).toList();
  }

  @override
  Future<List<DailyLogEntryModel>> getEntriesByCategory(
    String categoryId, {
    bool includeDeleted = false,
  }) async {
    final whereClause = includeDeleted
        ? 'category_id = ?'
        : 'category_id = ? AND is_deleted = 0';
    final maps = await _db.query(
      _entriesTable,
      where: whereClause,
      whereArgs: [categoryId],
      orderBy: 'log_date DESC, created_at DESC',
    );
    return maps.map((m) => DailyLogEntryModel.fromMap(m)).toList();
  }

  @override
  Future<DailyLogEntryModel?> getEntryById(String id) async {
    final maps = await _db.query(
      _entriesTable,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DailyLogEntryModel.fromMap(maps.first);
  }

  @override
  Future<void> createEntry(DailyLogEntryModel entry) async {
    await _db.insert(_entriesTable, entry.toMap());
    await _insertFtsEntry(
      sourceType: 'daily_log_entry',
      sourceId: entry.id,
      title: entry.title,
      body: '${entry.title} ${entry.detail ?? ''}',
    );
  }

  @override
  Future<void> updateEntry(DailyLogEntryModel entry) async {
    await _db.update(
      _entriesTable,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    await _db.delete(
      _ftsTable,
      where: 'source_type = ? AND source_id = ?',
      whereArgs: ['daily_log_entry', entry.id],
    );
    await _insertFtsEntry(
      sourceType: 'daily_log_entry',
      sourceId: entry.id,
      title: entry.title,
      body: '${entry.title} ${entry.detail ?? ''}',
    );
  }

  @override
  Future<void> softDeleteEntry(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      _entriesTable,
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
      whereArgs: ['daily_log_entry', id],
    );
  }

  @override
  Future<List<DailyLogCategoryModel>> getAllCategories({
    bool includeDeleted = false,
  }) async {
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final maps = await _db.query(
      _categoriesTable,
      where: whereClause,
      orderBy: 'name ASC',
    );
    return maps.map((m) => DailyLogCategoryModel.fromMap(m)).toList();
  }

  @override
  Future<DailyLogCategoryModel?> getCategoryById(String id) async {
    final maps = await _db.query(
      _categoriesTable,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DailyLogCategoryModel.fromMap(maps.first);
  }

  @override
  Future<List<Map<String, dynamic>>> exportEntriesForCsv(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    String baseQuery = '''
      SELECT
        dle.id,
        dle.log_date,
        dle.category_id,
        dlc.name as category_name,
        dle.title,
        dle.detail,
        dle.duration_mins,
        dle.linked_type,
        dle.linked_id,
        dle.created_at,
        dle.updated_at
      FROM $_entriesTable dle
      LEFT JOIN $_categoriesTable dlc ON dle.category_id = dlc.id
      WHERE dle.is_deleted = 0
    ''';

    List<dynamic> args = [];

    if (startDate != null && endDate != null) {
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];
      baseQuery += ' AND dle.log_date BETWEEN ? AND ?';
      args.addAll([startStr, endStr]);
    } else if (startDate != null) {
      final startStr = startDate.toIso8601String().split('T')[0];
      baseQuery += ' AND dle.log_date >= ?';
      args.add(startStr);
    } else if (endDate != null) {
      final endStr = endDate.toIso8601String().split('T')[0];
      baseQuery += ' AND dle.log_date <= ?';
      args.add(endStr);
    }

    baseQuery += ' ORDER BY dle.log_date DESC, dle.created_at DESC';

    final results = await _db.rawQuery(baseQuery, args);
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
