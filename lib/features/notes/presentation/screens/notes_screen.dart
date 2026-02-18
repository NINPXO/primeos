import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/notes/domain/entities/note.dart';
import 'package:primeos/features/notes/presentation/providers/notes_provider.dart';
import 'package:primeos/features/notes/presentation/providers/note_tags_provider.dart';
import 'package:primeos/features/notes/presentation/widgets/note_card.dart';
import 'package:primeos/features/notes/presentation/widgets/note_tag_filter.dart';
import 'package:primeos/features/notes/presentation/widgets/note_search_delegate.dart';
import 'note_editor_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String? _selectedTagName;
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(ref),
              );
            },
            tooltip: 'Search Notes',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notesProvider.notifier).refreshNotes(),
        child: Column(
          children: [
            // Tag filter chips
            NoteTagFilter(
              selectedTagName: _selectedTagName,
              onTagsSelected: (selectedTags) {
                setState(() {
                  _selectedTagName =
                      selectedTags.isEmpty ? null : selectedTags.first;
                });
              },
            ),
            // Notes list/grid
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  // Filter by selected tag
                  final filteredNotes = _selectedTagName == null
                      ? notes
                      : notes
                          .where((n) =>
                              n.tags != null && n.tags!.contains(_selectedTagName))
                          .toList();

                  // Separate pinned and regular notes
                  final pinnedNotes =
                      filteredNotes.where((n) => n.tags?.contains('pinned') ?? false).toList();
                  final regularNotes =
                      filteredNotes.where((n) => !n.tags?.contains('pinned') ?? true).toList();

                  final allNotes = [...pinnedNotes, ...regularNotes];

                  if (allNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notes yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTagName != null
                                ? 'No notes with tag "$_selectedTagName"'
                                : 'Create a new note to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_isGridView) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: allNotes.length,
                      itemBuilder: (context, index) {
                        final note = allNotes[index];
                        return NoteCard(
                          note: note,
                          onTap: () => _navigateToEditor(note),
                          onArchive: () => _archiveNote(note.id),
                          onDelete: () => _deleteNote(note.id),
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: allNotes.length,
                      itemBuilder: (context, index) {
                        final note = allNotes[index];
                        return NoteCard(
                          note: note,
                          onTap: () => _navigateToEditor(note),
                          onArchive: () => _archiveNote(note.id),
                          onDelete: () => _deleteNote(note.id),
                        );
                      },
                    );
                  }
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading notes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('$error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(notesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(null),
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToEditor(Note? note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );
  }

  void _archiveNote(String noteId) {
    ref.read(notesProvider.notifier).archiveNote(noteId).then(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note archived')),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }

  void _deleteNote(String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notesProvider.notifier).deleteNote(noteId).then(
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted')),
                  );
                },
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                },
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
