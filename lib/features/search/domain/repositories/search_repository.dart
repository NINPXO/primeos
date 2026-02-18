import '../../../../core/types/app_result.dart';
import '../entities/search_result.dart';

/// Repository interface for cross-module full-text search
abstract class SearchRepository {
  /// Search across all modules using FTS5
  /// Returns list of SearchResult variants
  Future<AppResult<List<SearchResult>>> search(String query);

  /// Get recent search history
  Future<AppResult<List<String>>> getSearchHistory();

  /// Save search query to history
  Future<AppResult<void>> saveSearchHistory(String query);

  /// Clear all search history
  Future<AppResult<void>> clearSearchHistory();
}
