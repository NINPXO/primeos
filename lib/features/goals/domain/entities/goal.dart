import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String categoryId,
    required String title,
    required String status,
    String? description,
    double? targetValue,
    String? targetUnit,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
  }) = _Goal;
}
