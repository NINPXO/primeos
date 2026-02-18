import '../../domain/entities/progress_entry.dart';

class ProgressEntryModel extends ProgressEntry {
  const ProgressEntryModel({
    required super.id,
    required super.goalId,
    required super.categoryId,
    required super.value,
    super.unit,
    super.note,
    required super.trackingPeriod,
    required super.loggedDate,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory ProgressEntryModel.fromMap(Map<String, dynamic> map) {
    return ProgressEntryModel(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      categoryId: map['category_id'] as String,
      value: (map['value'] as num).toDouble(),
      unit: map['unit'] as String?,
      note: map['note'] as String?,
      trackingPeriod: map['tracking_period'] as String,
      loggedDate: DateTime.parse(map['logged_date'] as String),
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
      'goal_id': goalId,
      'category_id': categoryId,
      'value': value,
      'unit': unit,
      'note': note,
      'tracking_period': trackingPeriod,
      'logged_date': loggedDate.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory ProgressEntryModel.fromEntity(ProgressEntry entry) {
    return ProgressEntryModel(
      id: entry.id,
      goalId: entry.goalId,
      categoryId: entry.categoryId,
      value: entry.value,
      unit: entry.unit,
      note: entry.note,
      trackingPeriod: entry.trackingPeriod,
      loggedDate: entry.loggedDate,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      isDeleted: entry.isDeleted,
      deletedAt: entry.deletedAt,
    );
  }
}
