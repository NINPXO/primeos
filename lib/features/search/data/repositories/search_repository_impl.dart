import '../../../../core/types/app_result.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_local_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDataSource localDataSource;

  SearchRepositoryImpl({required this.localDataSource});

  @override
  Future<AppResult<List<SearchResult>>> search(String query) async {
    try {
      if (query.trim().isEmpty) {
        return AppResult.success([]);
      }

      final results = await localDataSource.searchAll(query);
      return AppResult.success(results);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure( 'Search failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AppResult<List<String>>> getSearchHistory() async {
    try {
      // TODO: Implement search history retrieval from app_settings table
      return AppResult.success([]);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure( 'Failed to retrieve search history: $e'),
      );
    }
  }

  @override
  Future<AppResult<void>> saveSearchHistory(String query) async {
    try {
      // TODO: Implement search history saving to app_settings table
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure( 'Failed to save search history: $e'),
      );
    }
  }

  @override
  Future<AppResult<void>> clearSearchHistory() async {
    try {
      // TODO: Implement search history clearing
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure( 'Failed to clear search history: $e'),
      );
    }
  }
}
