import '../../domain/entities/daily_log_entry.dart';

class DailyLogEntryModel extends DailyLogEntry {
  const DailyLogEntryModel({
    required super.id,
    required super.logDate,
    required super.categoryId,
    required super.title,
    super.detail,
    super.durationMins,
    super.linkedType,
    super.linkedId,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory DailyLogEntryModel.fromMap(Map<String, dynamic> map) {
    return DailyLogEntryModel(
      id: map['id'] as String,
      logDate: DateTime.parse(map['log_date'] as String),
      categoryId: map['category_id'] as String,
      title: map['title'] as String,
      detail: map['detail'] as String?,
      durationMins: map['duration_mins'] as int?,
      linkedType: map['linked_type'] as String?,
      linkedId: map['linked_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isDeleted: (map['is_deleted'] as int?) == 1 ? true : false,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'log_date': logDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'category_id': categoryId,
      'title': title,
      'detail': detail,
      'duration_mins': durationMins,
      'linked_type': linkedType,
      'linked_id': linkedId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory DailyLogEntryModel.fromEntity(DailyLogEntry entry) {
    return DailyLogEntryModel(
      id: entry.id,
      logDate: entry.logDate,
      categoryId: entry.categoryId,
      title: entry.title,
      detail: entry.detail,
      durationMins: entry.durationMins,
      linkedType: entry.linkedType,
      linkedId: entry.linkedId,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      isDeleted: entry.isDeleted,
      deletedAt: entry.deletedAt,
    );
  }
}
