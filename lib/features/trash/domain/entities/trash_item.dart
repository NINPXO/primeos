import 'package:primeos/features/goals/domain/entities/goal.dart';
import 'package:primeos/features/progress/domain/entities/progress_entry.dart';
import 'package:primeos/features/daily_log/domain/entities/daily_log_entry.dart';

sealed class TrashItem {
  final String id;
  final String title;
  final DateTime deletedAt;
  final String sourceType;

  TrashItem({
    required this.id,
    required this.title,
    required this.deletedAt,
    required this.sourceType,
  });

  factory TrashItem.fromMap(Map<String, dynamic> map, String sourceType) {
    final id = map['id'] as String;
    final title = map['title'] as String;
    final deletedAt = _parseDateTime(map['deletedAt']);

    switch (sourceType) {
      case 'goal':
        return TrashGoal(
          goal: Goal(
            id: id,
            categoryId: map['categoryId'] as String? ?? '',
            title: title,
            status: map['status'] as String? ?? '',
            description: map['description'] as String?,
            targetValue: (map['targetValue'] as num?)?.toDouble(),
            targetUnit: map['targetUnit'] as String?,
            targetDate: _parseDateTime(map['targetDate']),
            createdAt: _parseDateTime(map['createdAt']),
            updatedAt: _parseDateTime(map['updatedAt']),
            isDeleted: (map['isDeleted'] as int?) == 1,
            deletedAt: _parseDateTime(map['deletedAt']),
          ),
          deletedAt: deletedAt,
        );
      case 'progress':
        return TrashProgressEntry(
          entry: ProgressEntry(
            id: id,
            goalId: map['goalId'] as String? ?? '',
            categoryId: map['categoryId'] as String? ?? '',
            value: (map['value'] as num?)?.toDouble() ?? 0.0,
            unit: map['unit'] as String?,
            note: map['note'] as String?,
            trackingPeriod: map['trackingPeriod'] as String? ?? 'daily',
            loggedDate: _parseDateTime(map['loggedDate']) ?? DateTime.now(),
            createdAt: _parseDateTime(map['createdAt']),
            updatedAt: _parseDateTime(map['updatedAt']),
            isDeleted: (map['isDeleted'] as int?) == 1,
            deletedAt: _parseDateTime(map['deletedAt']),
          ),
          deletedAt: deletedAt,
        );
      case 'log':
        return TrashLogEntry(
          entry: DailyLogEntry(
            id: id,
            logDate: _parseDateTime(map['logDate']) ?? DateTime.now(),
            categoryId: map['categoryId'] as String? ?? '',
            title: title,
            detail: map['detail'] as String?,
            durationMins: map['durationMins'] as int?,
            linkedType: map['linkedType'] as String?,
            linkedId: map['linkedId'] as String?,
            createdAt: _parseDateTime(map['createdAt']),
            updatedAt: _parseDateTime(map['updatedAt']),
            isDeleted: (map['isDeleted'] as int?) == 1,
            deletedAt: _parseDateTime(map['deletedAt']),
          ),
          deletedAt: deletedAt,
        );
      default:
        throw ArgumentError('Unknown sourceType: $sourceType');
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

final class TrashGoal extends TrashItem {
  final Goal goal;

  TrashGoal({
    required this.goal,
    required DateTime deletedAt,
  }) : super(
    id: goal.id,
    title: goal.title,
    deletedAt: deletedAt,
    sourceType: 'goal',
  );
}

final class TrashProgressEntry extends TrashItem {
  final ProgressEntry entry;

  TrashProgressEntry({
    required this.entry,
    required DateTime deletedAt,
  }) : super(
    id: entry.id,
    title: entry.note ?? 'Progress Entry',
    deletedAt: deletedAt,
    sourceType: 'progress',
  );
}

final class TrashLogEntry extends TrashItem {
  final DailyLogEntry entry;

  TrashLogEntry({
    required this.entry,
    required DateTime deletedAt,
  }) : super(
    id: entry.id,
    title: entry.title,
    deletedAt: deletedAt,
    sourceType: 'log',
  );
}
