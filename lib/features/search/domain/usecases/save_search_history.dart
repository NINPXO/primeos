import '../../../../core/types/app_result.dart';
import '../repositories/search_repository.dart';

class SaveSearchHistory {
  final SearchRepository repository;

  SaveSearchHistory(this.repository);

  Future<AppResult<void>> call(String query) {
    return repository.saveSearchHistory(query);
  }
}
