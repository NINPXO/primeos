import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/search_result.dart';
import '../providers/search_provider.dart';
import 'search_result_card.dart';

/// Custom search delegate for in-app search bar functionality
class AppSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  AppSearchDelegate({required this.ref});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter search terms'),
      );
    }

    ref.read(searchQueryProvider.notifier).setQuery(query);
    final results = ref.watch(searchResultsProvider);

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (searchResults) {
        if (searchResults.isEmpty) {
          return const Center(
            child: Text('No results found'),
          );
        }

        return ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return SearchResultCard(
              result: searchResults[index],
              onTap: () {
                close(context, searchResults[index]);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Search across all modules',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    ref.read(searchQueryProvider.notifier).setQuery(query);
    final results = ref.watch(searchResultsProvider);

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (searchResults) {
        if (searchResults.isEmpty) {
          return Center(
            child: Text(
              'No suggestions for "$query"',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return SearchResultCard(
              result: searchResults[index],
              onTap: () {
                close(context, searchResults[index]);
              },
            );
          },
        );
      },
    );
  }
}
