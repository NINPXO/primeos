import '../../domain/entities/daily_log_category.dart';

class DailyLogCategoryModel extends DailyLogCategory {
  const DailyLogCategoryModel({
    required super.id,
    required super.name,
    required super.isFixed,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory DailyLogCategoryModel.fromMap(Map<String, dynamic> map) {
    return DailyLogCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isFixed: (map['is_fixed'] as int?) == 1 ? true : false,
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
      'is_fixed': isFixed ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory DailyLogCategoryModel.fromEntity(DailyLogCategory category) {
    return DailyLogCategoryModel(
      id: category.id,
      name: category.name,
      isFixed: category.isFixed,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      isDeleted: category.isDeleted,
      deletedAt: category.deletedAt,
    );
  }
}
