import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/notes/domain/entities/note.dart';
import 'package:primeos/features/notes/presentation/providers/notes_provider.dart';
import 'package:primeos/features/notes/presentation/screens/note_editor_screen.dart';

class NoteSearchDelegate extends SearchDelegate<Note?> {
  final WidgetRef ref;
  List<Note> _searchResults = [];
  bool _isSearching = false;

  NoteSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Search notes...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontSize: 16);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResultsList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Search your notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return _buildSearchResultsList(context);
  }

  Widget _buildSearchResultsList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Enter a search term',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return FutureBuilder<List<Note>>(
      future: ref.read(notesProvider.notifier).searchNotes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No notes found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final note = results[index];
            return _buildSearchResultTile(context, note, query);
          },
        );
      },
    );
  }

  Widget _buildSearchResultTile(BuildContext context, Note note, String query) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteEditorScreen(note: note),
            ),
          );
          close(context, note);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with highlight
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Content preview with highlighting
              _buildHighlightedText(
                context,
                note.contentPlain.length > 100
                    ? '${note.contentPlain.substring(0, 100)}...'
                    : note.contentPlain,
                query,
              ),
              const SizedBox(height: 8),
              // Tags
              if (note.tags != null && note.tags!.isNotEmpty)
                Row(
                  children: note.tags!.take(2).map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Chip(
                        label: Text(tag),
                        labelStyle: const TextStyle(fontSize: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    BuildContext context,
    String text,
    String query,
  ) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matches = <TextSpan>[];
    int lastIndex = 0;

    int index = lowerText.indexOf(lowerQuery);
    while (index != -1) {
      // Add text before match
      if (index > lastIndex) {
        matches.add(TextSpan(text: text.substring(lastIndex, index)));
      }

      // Add highlighted match
      matches.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: Colors.yellow[200],
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastIndex = index + query.length;
      index = lowerText.indexOf(lowerQuery, lastIndex);
    }

    // Add remaining text
    if (lastIndex < text.length) {
      matches.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        children: matches,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
