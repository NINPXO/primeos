import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../models/search_result_model.dart';

class SearchLocalDataSource {
  final Database database;
  final DatabaseHelper databaseHelper;

  SearchLocalDataSource({
    required this.database,
    required this.databaseHelper,
  });

  /// Search across all modules using FTS5 with ranking
  Future<List<SearchResultModel>> searchAll(String query) async {
    try {
      // FTS5 search with relevance ranking
      final results = await database.rawQuery('''
        SELECT
          fts.source_type,
          fts.source_id,
          fts.title,
          rank,
          CASE
            WHEN fts.source_type = 'goal' THEN (
              SELECT g.status FROM ${DbConstants.goalsTable} g
              WHERE g.id = fts.source_id LIMIT 1
            )
            WHEN fts.source_type = 'progress' THEN NULL
            WHEN fts.source_type = 'daily_log' THEN NULL
            WHEN fts.source_type = 'note' THEN NULL
          END as extra_data
        FROM fts_search AS fts
        WHERE fts.fts_search MATCH ?
        ORDER BY fts.rank, fts.source_id
        LIMIT 50
      ''', ['$query*']);

      // Fetch detailed data for each result and create models
      final List<SearchResultModel> modelResults = [];

      for (final row in results) {
        final sourceType = row['source_type'] as String;
        final sourceId = row['source_id'] as String;
        final title = row['title'] as String;

        try {
          final model = await _getDetailedResult(sourceType, sourceId, title);
          if (model != null) {
            modelResults.add(model);
          }
        } catch (_) {
          // Skip results that fail to fetch
          continue;
        }
      }

      return modelResults;
    } catch (e) {
      throw Exception('FTS search failed: $e');
    }
  }

  /// Fetch detailed data for a single search result
  Future<SearchResultModel?> _getDetailedResult(
    String sourceType,
    String sourceId,
    String title,
  ) async {
    switch (sourceType) {
      case 'goal':
        return _getGoalDetail(sourceId);
      case 'progress':
        return _getProgressDetail(sourceId);
      case 'daily_log':
        return _getDailyLogDetail(sourceId);
      case 'note':
        return _getNoteDetail(sourceId);
      default:
        return null;
    }
  }

  /// Get goal details
  Future<SearchResultModel?> _getGoalDetail(String goalId) async {
    final result = await database.query(
      DbConstants.goalsTable,
      where: '${DbConstants.idColumn} = ? AND ${DbConstants.isDeletedColumn} = 0',
      whereArgs: [goalId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final goal = result.first;
    final categoryId = goal[DbConstants.categoryIdColumn] as String;

    // Get category name
    final categoryResult = await database.query(
      DbConstants.goalCategoriesTable,
      columns: [DbConstants.nameColumn],
      where: '${DbConstants.idColumn} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );

    final categoryName = categoryResult.isNotEmpty
        ? categoryResult.first[DbConstants.nameColumn] as String
        : 'Unknown';

    return SearchResultModel.goalResult(
      id: goalId,
      title: goal[DbConstants.titleColumn] as String,
      categoryName: categoryName,
      status: goal['status'] as String? ?? 'active',
      createdAt: DateTime.parse(goal[DbConstants.createdAtColumn] as String),
    );
  }

  /// Get progress details
  Future<SearchResultModel?> _getProgressDetail(String progressId) async {
    final result = await database.query(
      DbConstants.progressEntriesTable,
      where: '${DbConstants.idColumn} = ? AND ${DbConstants.isDeletedColumn} = 0',
      whereArgs: [progressId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final entry = result.first;
    final goalId = entry[DbConstants.goalIdColumn] as String;

    // Get goal title
    final goalResult = await database.query(
      DbConstants.goalsTable,
      columns: [DbConstants.titleColumn],
      where: '${DbConstants.idColumn} = ?',
      whereArgs: [goalId],
      limit: 1,
    );

    final goalTitle = goalResult.isNotEmpty
        ? goalResult.first[DbConstants.titleColumn] as String
        : 'Unknown Goal';

    return SearchResultModel.progressResult(
      id: progressId,
      goalTitle: goalTitle,
      value: (entry['value'] as num).toDouble(),
      unit: entry['unit'] as String? ?? '',
      loggedDate: DateTime.parse(entry['logged_date'] as String),
    );
  }

  /// Get daily log details
  Future<SearchResultModel?> _getDailyLogDetail(String logId) async {
    final result = await database.query(
      DbConstants.dailyLogEntriesTable,
      where: '${DbConstants.idColumn} = ? AND ${DbConstants.isDeletedColumn} = 0',
      whereArgs: [logId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final log = result.first;
    final categoryId = log[DbConstants.categoryIdColumn] as String;

    // Get category name
    final categoryResult = await database.query(
      DbConstants.dailyLogCategoriesTable,
      columns: [DbConstants.nameColumn],
      where: '${DbConstants.idColumn} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );

    final categoryName = categoryResult.isNotEmpty
        ? categoryResult.first[DbConstants.nameColumn] as String
        : 'Unknown';

    return SearchResultModel.dailyLogResult(
      id: logId,
      title: log[DbConstants.titleColumn] as String,
      categoryName: categoryName,
      logDate: DateTime.parse(log['log_date'] as String),
    );
  }

  /// Get note details
  Future<SearchResultModel?> _getNoteDetail(String noteId) async {
    final result = await database.query(
      DbConstants.notesTable,
      where: '${DbConstants.idColumn} = ? AND ${DbConstants.isDeletedColumn} = 0',
      whereArgs: [noteId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final note = result.first;
    String contentPreview = note['content_plain'] as String? ?? '';
    if (contentPreview.length > 100) {
      contentPreview = '${contentPreview.substring(0, 100)}...';
    }

    // Get tags for this note
    final tagsResult = await database.rawQuery('''
      SELECT nt.${DbConstants.nameColumn}
      FROM ${DbConstants.noteTagsTable} nt
      INNER JOIN ${DbConstants.notesTagsJunctionTable} ntj
        ON nt.${DbConstants.idColumn} = ntj.${DbConstants.tagIdColumn}
      WHERE ntj.${DbConstants.noteIdColumn} = ?
    ''', [noteId]);

    final tags = tagsResult.map((t) => t[DbConstants.nameColumn] as String).toList();

    return SearchResultModel.noteResult(
      id: noteId,
      title: note[DbConstants.titleColumn] as String,
      contentPreview: contentPreview,
      tags: tags,
      createdAt: DateTime.parse(note[DbConstants.createdAtColumn] as String),
    );
  }
}
