import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_log_category.freezed.dart';

@freezed
class DailyLogCategory with _$DailyLogCategory {
  const factory DailyLogCategory({
    required String id,
    required String name,
    required bool isFixed,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
  }) = _DailyLogCategory;
}
