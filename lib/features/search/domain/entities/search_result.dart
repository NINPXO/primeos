import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';

/// Sealed union type representing search results across all modules
@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult.goalResult({
    required String id,
    required String title,
    required String categoryName,
    required String status,
    required DateTime createdAt,
  }) = GoalResult;

  const factory SearchResult.progressResult({
    required String id,
    required String goalTitle,
    required double value,
    required String unit,
    required DateTime loggedDate,
  }) = ProgressResult;

  const factory SearchResult.dailyLogResult({
    required String id,
    required String title,
    required String categoryName,
    required DateTime logDate,
  }) = DailyLogResult;

  const factory SearchResult.noteResult({
    required String id,
    required String title,
    required String contentPreview,
    required List<String> tags,
    required DateTime createdAt,
  }) = NoteResult;
}

/// Extension providing helper methods for SearchResult
extension SearchResultHelpers on SearchResult {
  /// Get human-readable type
  String get sourceType => map(
    goalResult: (_) => 'Goal',
    progressResult: (_) => 'Progress',
    dailyLogResult: (_) => 'Daily Log',
    noteResult: (_) => 'Note',
  );

  /// Get route for deep linking
  String get deepLinkRoute => map(
    goalResult: (goal) => '/goals/${goal.id}',
    progressResult: (progress) => '/progress',
    dailyLogResult: (log) => '/daily-log',
    noteResult: (note) => '/notes/${note.id}',
  );
}
