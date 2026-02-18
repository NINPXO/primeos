import '../../domain/entities/search_result.dart';

/// Models extending SearchResult for use in presentation layer
class SearchResultModel {
  SearchResultModel._();

  /// Create a goal search result
  static SearchResult goalResult({
    required String id,
    required String title,
    required String categoryName,
    required String status,
    required DateTime createdAt,
  }) =>
      SearchResult.goalResult(
        id: id,
        title: title,
        categoryName: categoryName,
        status: status,
        createdAt: createdAt,
      );

  /// Create a progress search result
  static SearchResult progressResult({
    required String id,
    required String goalTitle,
    required double value,
    required String unit,
    required DateTime loggedDate,
  }) =>
      SearchResult.progressResult(
        id: id,
        goalTitle: goalTitle,
        value: value,
        unit: unit,
        loggedDate: loggedDate,
      );

  /// Create a daily log search result
  static SearchResult dailyLogResult({
    required String id,
    required String title,
    required String categoryName,
    required DateTime logDate,
  }) =>
      SearchResult.dailyLogResult(
        id: id,
        title: title,
        categoryName: categoryName,
        logDate: logDate,
      );

  /// Create a note search result
  static SearchResult noteResult({
    required String id,
    required String title,
    required String contentPreview,
    required List<String> tags,
    required DateTime createdAt,
  }) =>
      SearchResult.noteResult(
        id: id,
        title: title,
        contentPreview: contentPreview,
        tags: tags,
        createdAt: createdAt,
      );
}
