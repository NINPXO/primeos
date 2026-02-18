import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_entry.freezed.dart';

@freezed
class ProgressEntry with _$ProgressEntry {
  const factory ProgressEntry({
    required String id,
    required String goalId,
    required String categoryId,
    required double value,
    String? unit,
    String? note,
    required String trackingPeriod, // daily|weekly|monthly
    required DateTime loggedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
  }) = _ProgressEntry;
}
