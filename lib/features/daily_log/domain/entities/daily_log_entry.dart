import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_log_entry.freezed.dart';

@freezed
class DailyLogEntry with _$DailyLogEntry {
  const factory DailyLogEntry({
    required String id,
    required DateTime logDate,
    required String categoryId,
    required String title,
    String? detail,
    int? durationMins,
    String? linkedType, // 'goal_change' | 'progress_change'
    String? linkedId,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
  }) = _DailyLogEntry;
}
