import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/search_result.dart';
import '../providers/search_provider.dart';
import '../widgets/search_result_card.dart';
import '../widgets/search_result_section_header.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search input field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).setQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search goals, progress, logs, notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Results or placeholder
          Expanded(
            child: searchResults.when(
              loading: () => const LoadingOverlay(message: 'Searching...'),
              error: (error, stack) => ErrorStateWidget(
                error: error.toString(),
                onRetry: () {
                  ref.refresh(searchResultsProvider);
                },
              ),
              data: (results) {
                if (query.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search,
                    title: 'Start Searching',
                    message: 'Enter keywords to search across all modules',
                  );
                }

                if (results.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.not_found,
                    title: 'No Results',
                    message: 'Try different keywords',
                  );
                }

                return _buildResultsList(results);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    // Group results by type
    final grouped = <String, List<SearchResult>>{};
    for (final result in results) {
      final type = result.sourceType;
      grouped.putIfAbsent(type, () => []).add(result);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grouped.length * 2 + results.length, // Headers + results
      itemBuilder: (context, index) {
        // Calculate which group and item
        var itemIndex = index;
        for (final type in grouped.keys) {
          final count = grouped[type]!.length;
          final groupSize = count + 1; // +1 for header

          if (itemIndex == 0) {
            // Render header
            return SearchResultSectionHeader(
              type: type,
              count: count,
            );
          }

          itemIndex--;

          if (itemIndex < count) {
            // Render result item
            return SearchResultCard(
              result: grouped[type]![itemIndex],
              onTap: () {
                context.push(grouped[type]![itemIndex].deepLinkRoute);
              },
            );
          }

          itemIndex -= count;
        }

        return const SizedBox.shrink();
      },
    );
  }
}
