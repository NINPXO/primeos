import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/search_local_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_all.dart';

/// Provider for search repository (async)
final searchRepositoryProvider = FutureProvider((ref) async {
  final database = await ref.watch(databaseProvider.future);
  final datasource = SearchLocalDataSource(
    database: database,
    databaseHelper: null,
  );
  return SearchRepositoryImpl(localDataSource: datasource);
});

/// Provider for search use case
final searchUseCaseProvider = FutureProvider((ref) async {
  final repository = await ref.watch(searchRepositoryProvider.future);
  return SearchAll(repository);
});

/// State notifier for search query
class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void setQuery(String query) {
    state = query;
  }
}

/// Provider for search query state
final searchQueryProvider = StateNotifierProvider<SearchNotifier, String>((ref) {
  return SearchNotifier();
});

/// Provider for search results with debounce
final searchResultsProvider =
    FutureProvider.autoDispose<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final useCase = await ref.watch(searchUseCaseProvider.future);

  if (query.trim().isEmpty) {
    return [];
  }

  // Debounce: small delay to avoid excessive searches
  await Future.delayed(const Duration(milliseconds: 300));

  // Perform search
  final result = await useCase(query);
  return result.fold(
    (failure) => [],
    (data) => data,
  );
});
