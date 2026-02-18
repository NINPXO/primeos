import 'package:sqflite/sqflite.dart';
import '../models/goal_category_model.dart';
import '../models/goal_model.dart';

abstract interface class GoalsLocalDatasource {
  Future<List<GoalCategoryModel>> getAllCategories({bool includeDeleted = false});
  Future<GoalCategoryModel?> getCategoryById(String id);
  Future<void> createCategory(GoalCategoryModel category);
  Future<void> updateCategory(GoalCategoryModel category);
  Future<void> softDeleteCategory(String id);
  Future<List<GoalModel>> getAllGoals({bool includeDeleted = false});
  Future<List<GoalModel>> getGoalsByCategory(
    String categoryId, {
    bool includeDeleted = false,
  });
  Future<GoalModel?> getGoalById(String id);
  Future<void> createGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> softDeleteGoal(String id);
  Future<List<Map<String, dynamic>>> exportGoalsForCsv(String? categoryId);
}

class GoalsLocalDatasourceImpl implements GoalsLocalDatasource {
  static const _goalsTable = 'goals';
  static const _categoriesTable = 'goal_categories';
  static const _ftsTable = 'fts_search';

  final Database _db;

  GoalsLocalDatasourceImpl(this._db);

  @override
  Future<List<GoalCategoryModel>> getAllCategories(
      {bool includeDeleted = false}) async {
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final maps = await _db.query(
      _categoriesTable,
      where: whereClause,
    );
    return maps.map((m) => GoalCategoryModel.fromMap(m)).toList();
  }

  @override
  Future<GoalCategoryModel?> getCategoryById(String id) async {
    final maps = await _db.query(
      _categoriesTable,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return GoalCategoryModel.fromMap(maps.first);
  }

  @override
  Future<void> createCategory(GoalCategoryModel category) async {
    await _db.insert(_categoriesTable, category.toMap());
    await _insertFtsEntry(
      sourceType: 'goal_category',
      sourceId: category.id,
      title: category.name,
      body: category.name,
    );
  }

  @override
  Future<void> updateCategory(GoalCategoryModel category) async {
    await _db.update(
      _categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    await _db.delete(
      _ftsTable,
      where: 'source_type = ? AND source_id = ?',
      whereArgs: ['goal_category', category.id],
    );
    await _insertFtsEntry(
      sourceType: 'goal_category',
      sourceId: category.id,
      title: category.name,
      body: category.name,
    );
  }

  @override
  Future<void> softDeleteCategory(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      _categoriesTable,
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
      whereArgs: ['goal_category', id],
    );
  }

  @override
  Future<List<GoalModel>> getAllGoals({bool includeDeleted = false}) async {
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final maps = await _db.query(
      _goalsTable,
      where: whereClause,
    );
    return maps.map((m) => GoalModel.fromMap(m)).toList();
  }

  @override
  Future<List<GoalModel>> getGoalsByCategory(
    String categoryId, {
    bool includeDeleted = false,
  }) async {
    final whereClause = includeDeleted
        ? 'category_id = ?'
        : 'category_id = ? AND is_deleted = 0';
    final maps = await _db.query(
      _goalsTable,
      where: whereClause,
      whereArgs: [categoryId],
    );
    return maps.map((m) => GoalModel.fromMap(m)).toList();
  }

  @override
  Future<GoalModel?> getGoalById(String id) async {
    final maps = await _db.query(
      _goalsTable,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return GoalModel.fromMap(maps.first);
  }

  @override
  Future<void> createGoal(GoalModel goal) async {
    await _db.insert(_goalsTable, goal.toMap());
    await _insertFtsEntry(
      sourceType: 'goal',
      sourceId: goal.id,
      title: goal.title,
      body: '${goal.title} ${goal.description ?? ''}',
    );
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await _db.update(
      _goalsTable,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
    await _db.delete(
      _ftsTable,
      where: 'source_type = ? AND source_id = ?',
      whereArgs: ['goal', goal.id],
    );
    await _insertFtsEntry(
      sourceType: 'goal',
      sourceId: goal.id,
      title: goal.title,
      body: '${goal.title} ${goal.description ?? ''}',
    );
  }

  @override
  Future<void> softDeleteGoal(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      _goalsTable,
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
      whereArgs: ['goal', id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> exportGoalsForCsv(
    String? categoryId,
  ) async {
    final baseQuery = '''
      SELECT
        g.id,
        g.category_id,
        gc.name as category_name,
        g.title,
        g.description,
        g.status,
        g.target_value,
        g.target_unit,
        g.target_date,
        g.created_at,
        g.updated_at
      FROM $_goalsTable g
      LEFT JOIN $_categoriesTable gc ON g.category_id = gc.id
      WHERE g.is_deleted = 0
    ''';

    final query = categoryId != null
        ? '$baseQuery AND g.category_id = ?'
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
