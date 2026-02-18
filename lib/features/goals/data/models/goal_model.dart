import '../../../goals/domain/entities/goal.dart';

class GoalModel extends Goal {
  const GoalModel({
    required super.id,
    required super.categoryId,
    required super.title,
    required super.status,
    super.description,
    super.targetValue,
    super.targetUnit,
    super.targetDate,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      title: map['title'] as String,
      status: map['status'] as String,
      description: map['description'] as String?,
      targetValue: map['target_value'] as double?,
      targetUnit: map['target_unit'] as String?,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'] as String)
          : null,
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
      'category_id': categoryId,
      'title': title,
      'status': status,
      'description': description,
      'target_value': targetValue,
      'target_unit': targetUnit,
      'target_date': targetDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      categoryId: goal.categoryId,
      title: goal.title,
      status: goal.status,
      description: goal.description,
      targetValue: goal.targetValue,
      targetUnit: goal.targetUnit,
      targetDate: goal.targetDate,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
      isDeleted: goal.isDeleted,
      deletedAt: goal.deletedAt,
    );
  }
}
