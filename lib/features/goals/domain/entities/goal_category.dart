import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_category.freezed.dart';

@freezed
class GoalCategory with _$GoalCategory {
  const factory GoalCategory({
    required String id,
    required String name,
    required bool isSystem,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
  }) = _GoalCategory;
}
