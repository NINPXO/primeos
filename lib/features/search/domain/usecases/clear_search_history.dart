import '../../../../core/types/app_result.dart';
import '../repositories/search_repository.dart';

class ClearSearchHistory {
  final SearchRepository repository;

  ClearSearchHistory(this.repository);

  Future<AppResult<void>> call() {
    return repository.clearSearchHistory();
  }
}
