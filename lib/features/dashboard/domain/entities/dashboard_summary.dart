import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';

@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required int todayGoalsCount,
    required int weekGoalsCount,
    required int monthGoalsCount,
    required int activeProgressCount,
    required List<WeeklyDataPoint> weeklyChartData,
    required int totalNotes,
  }) = _DashboardSummary;
}

@freezed
class WeeklyDataPoint with _$WeeklyDataPoint {
  const factory WeeklyDataPoint({
    required DateTime date,
    required double value,
    required String dayLabel,
  }) = _WeeklyDataPoint;
}
