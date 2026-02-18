import 'package:sqflite/sqflite.dart';
import '../../../dashboard/domain/entities/dashboard_summary.dart';

abstract interface class DashboardLocalDatasource {
  Future<DashboardSummary> getDashboardSummary();
  Future<void> clearDateRange(DateTime startDate, DateTime endDate);
  Future<List<Map<String, dynamic>>> exportAllData();
}

class DashboardLocalDatasourceImpl implements DashboardLocalDatasource {
  static const _goalsTable = 'goals';
  static const _progressTable = 'progress_entries';
  static const _dailyLogTable = 'daily_log_entries';
  static const _notesTable = 'notes';

  final Database _db;

  DashboardLocalDatasourceImpl(this._db);

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final tomorrowStr = _formatDate(today.add(const Duration(days: 1)));
    final weekLaterStr = _formatDate(today.add(const Duration(days: 7)));
    final monthLaterStr = _formatDate(today.add(const Duration(days: 30)));
    final sevenDaysAgoStr = _formatDate(today.subtract(const Duration(days: 7)));

    // 1. Count today's goals
    final todayGoalsResult = await _db.rawQuery('''
      SELECT COUNT(*) as count FROM $_goalsTable
      WHERE status = 'active'
        AND target_date >= ?
        AND target_date < ?
        AND is_deleted = 0
    ''', [todayStr, tomorrowStr]);
    final todayGoalsCount = todayGoalsResult.first['count'] as int;

    // 2. Count week's goals (next 7 days)
    final weekGoalsResult = await _db.rawQuery('''
      SELECT COUNT(*) as count FROM $_goalsTable
      WHERE status = 'active'
        AND target_date >= ?
        AND target_date <= ?
        AND is_deleted = 0
    ''', [todayStr, weekLaterStr]);
    final weekGoalsCount = weekGoalsResult.first['count'] as int;

    // 3. Count month's goals (next 30 days)
    final monthGoalsResult = await _db.rawQuery('''
      SELECT COUNT(*) as count FROM $_goalsTable
      WHERE status = 'active'
        AND target_date >= ?
        AND target_date <= ?
        AND is_deleted = 0
    ''', [todayStr, monthLaterStr]);
    final monthGoalsCount = monthGoalsResult.first['count'] as int;

    // 4. Count active progress entries (last 7 days)
    final progressResult = await _db.rawQuery('''
      SELECT COUNT(*) as count FROM $_progressTable
      WHERE logged_date >= ?
        AND is_deleted = 0
    ''', [sevenDaysAgoStr]);
    final activeProgressCount = progressResult.first['count'] as int;

    // 5. Generate weekly chart data (7 days aggregated)
    final chartDataResult = await _db.rawQuery('''
      SELECT
        DATE(logged_date) as date,
        SUM(value) as total
      FROM $_progressTable
      WHERE logged_date >= ?
        AND is_deleted = 0
      GROUP BY DATE(logged_date)
      ORDER BY logged_date ASC
    ''', [sevenDaysAgoStr]);

    // Build 7-day chart data with all days
    final weeklyChartData = _buildWeeklyChartData(chartDataResult, today);

    // 6. Count non-deleted notes
    final notesResult = await _db.rawQuery('''
      SELECT COUNT(*) as count FROM $_notesTable
      WHERE is_archived = 0 AND is_deleted = 0
    ''');
    final totalNotes = notesResult.first['count'] as int;

    return DashboardSummary(
      todayGoalsCount: todayGoalsCount,
      weekGoalsCount: weekGoalsCount,
      monthGoalsCount: monthGoalsCount,
      activeProgressCount: activeProgressCount,
      weeklyChartData: weeklyChartData,
      totalNotes: totalNotes,
    );
  }

  @override
  Future<void> clearDateRange(DateTime startDate, DateTime endDate) async {
    final now = DateTime.now().toIso8601String();
    final startStr = _formatDate(startDate);
    final endStr = _formatDate(endDate.add(const Duration(days: 1)));

    // Soft delete progress entries in date range
    await _db.update(
      _progressTable,
      {
        'is_deleted': 1,
        'deleted_at': now,
      },
      where: 'logged_date >= ? AND logged_date < ? AND is_deleted = 0',
      whereArgs: [startStr, endStr],
    );

    // Soft delete daily log entries in date range
    await _db.update(
      _dailyLogTable,
      {
        'is_deleted': 1,
        'deleted_at': now,
      },
      where: 'log_date >= ? AND log_date < ? AND is_deleted = 0',
      whereArgs: [startStr, endStr],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> exportAllData() async {
    final List<Map<String, dynamic>> allData = [];

    // Export goals
    final goals = await _db.query(
      _goalsTable,
      where: 'is_deleted = 0',
    );
    allData.addAll(goals);

    // Export progress entries
    final progress = await _db.query(
      _progressTable,
      where: 'is_deleted = 0',
    );
    allData.addAll(progress);

    // Export daily log entries
    final dailyLog = await _db.query(
      _dailyLogTable,
      where: 'is_deleted = 0',
    );
    allData.addAll(dailyLog);

    // Export notes
    final notes = await _db.query(
      _notesTable,
      where: 'is_deleted = 0 AND is_archived = 0',
    );
    allData.addAll(notes);

    return allData;
  }

  /// Format DateTime to YYYY-MM-DD string for SQLite comparison
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Build 7-day weekly chart data, filling missing days with 0
  List<WeeklyDataPoint> _buildWeeklyChartData(
    List<Map<String, dynamic>> chartDataResult,
    DateTime today,
  ) {
    final result = <WeeklyDataPoint>[];
    final dataMap = <String, double>{};

    // Parse query results into map
    for (final row in chartDataResult) {
      final dateStr = row['date'] as String;
      final total = row['total'] as num;
      dataMap[dateStr] = total.toDouble();
    }

    // Generate 7 days back from today
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final value = dataMap[dateStr] ?? 0.0;
      final dayLabel = dayLabels[date.weekday - 1]; // weekday is 1-7 (Mon-Sun)

      result.add(WeeklyDataPoint(
        date: date,
        value: value,
        dayLabel: dayLabel,
      ));
    }

    return result;
  }
}
