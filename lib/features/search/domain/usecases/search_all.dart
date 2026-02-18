import '../../../../core/types/app_result.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchAll {
  final SearchRepository repository;

  SearchAll(this.repository);

  Future<AppResult<List<SearchResult>>> call(String query) {
    return repository.search(query);
  }
}
