import '../../../goals/domain/entities/goal_category.dart';

class GoalCategoryModel extends GoalCategory {
  const GoalCategoryModel({
    required super.id,
    required super.name,
    required super.isSystem,
    super.colorHex,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory GoalCategoryModel.fromMap(Map<String, dynamic> map) {
    return GoalCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isSystem: (map['is_system'] as int) == 1,
      colorHex: map['color_hex'] as String?,
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
      'name': name,
      'is_system': isSystem ? 1 : 0,
      'color_hex': colorHex,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory GoalCategoryModel.fromEntity(GoalCategory entity) {
    return GoalCategoryModel(
      id: entity.id,
      name: entity.name,
      isSystem: entity.isSystem,
      colorHex: entity.colorHex,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
      deletedAt: entity.deletedAt,
    );
  }
}
