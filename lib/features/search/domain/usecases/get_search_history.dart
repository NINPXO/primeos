import '../../../../core/types/app_result.dart';
import '../repositories/search_repository.dart';

class GetSearchHistory {
  final SearchRepository repository;

  GetSearchHistory(this.repository);

  Future<AppResult<List<String>>> call() {
    return repository.getSearchHistory();
  }
}
