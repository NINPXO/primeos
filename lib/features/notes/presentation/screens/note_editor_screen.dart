import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/notes/domain/entities/note.dart';
import 'package:primeos/features/notes/presentation/providers/notes_provider.dart';
import 'package:primeos/features/notes/presentation/providers/note_tags_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditorScreen({
    super.key,
    this.note,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late quill.QuillController _contentController;
  late Set<String> _selectedTags;
  late DateTime _lastAutoSave;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _lastAutoSave = DateTime.now();
    _selectedTags = Set.from(widget.note?.tags ?? []);

    // Parse content JSON or create empty document
    if (widget.note?.contentJson != null && widget.note!.contentJson.isNotEmpty) {
      try {
        final delta = quill.Delta.fromJson(
          List<Map<String, dynamic>>.from(
            (widget.note!.contentJson as dynamic is String)
                ? []
                : widget.note!.contentJson,
          ),
        );
        _contentController = quill.QuillController(
          document: quill.Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _contentController = quill.QuillController.basic();
      }
    } else {
      _contentController = quill.QuillController.basic();
    }

    // Setup auto-save timer
    Future.delayed(const Duration(seconds: 5), _autoSave);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _autoSave() {
    if (!mounted) return Future.value();

    final now = DateTime.now();
    if (now.difference(_lastAutoSave).inSeconds >= 5) {
      _lastAutoSave = now;
      // Could optionally auto-save here
    }

    if (mounted) {
      Future.delayed(const Duration(seconds: 5), _autoSave);
    }
    return Future.value();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final contentJson = _contentController.document.toDelta().toJson();
    final contentPlain = _contentController.document.toPlainText();

    if (contentPlain.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id ?? '',
        title: _titleController.text.trim(),
        contentJson: contentJson.toString(),
        contentPlain: contentPlain.trim(),
        tags: _selectedTags.toList(),
        isArchived: widget.note?.isArchived ?? false,
        archivedAt: widget.note?.archivedAt,
        createdAt: widget.note?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
        deletedAt: null,
      );

      if (widget.note == null) {
        // Create new note
        await ref.read(notesProvider.notifier).createNote(note, _selectedTags.toList());
      } else {
        // Update existing note
        await ref
            .read(notesProvider.notifier)
            .updateNote(note, _selectedTags.toList());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note == null) {
      Navigator.pop(context);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(notesProvider.notifier).deleteNote(widget.note!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting note: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _archiveNote() async {
    if (widget.note == null) return;

    try {
      await ref.read(notesProvider.notifier).archiveNote(widget.note!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note archived')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error archiving note: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(noteTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
            tooltip: 'Save',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteNote();
              } else if (value == 'archive') {
                _archiveNote();
              }
            },
            itemBuilder: (BuildContext context) => [
              if (widget.note != null)
                const PopupMenuItem<String>(
                  value: 'archive',
                  child: Text('Archive'),
                ),
              if (widget.note != null)
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Note Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
            ),
          ),
          // Quill toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: quill.QuillSimpleToolbar(
              controller: _contentController,
              configurations: const quill.QuillSimpleToolbarConfigurations(
                showBackgroundColorButton: false,
                showClearFormat: false,
                showCodeBlock: false,
                showDirection: false,
                showDividers: false,
                showFontFamily: false,
                showFontSize: false,
                showHeaderStyle: true,
                showHistory: true,
                showIndent: false,
                showInlineCode: true,
                showLineHeightButton: false,
                showLink: true,
                showQuote: true,
                showRedo: true,
                showSearchButton: false,
                showSmallButton: true,
                showStrikeThrough: true,
                showSubscript: true,
                showSuperscript: true,
                showTextColorButton: false,
                showUndo: true,
                showUnderLineButton: true,
                showLeftAlignment: true,
                showCenterAlignment: true,
                showRightAlignment: true,
                showJustifyAlignment: true,
                showListNumbers: true,
                showListBullets: true,
              ),
            ),
          ),
          // Content editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: quill.QuillEditor.basic(
                configurations: quill.QuillEditorConfigurations(
                  controller: _contentController,
                  readOnly: false,
                  autoFocus: true,
                  scrollPhysics: const BouncingScrollPhysics(),
                  expands: true,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          // Tag selector
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tags',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                tagsAsync.when(
                  data: (tags) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...tags.map((tag) {
                          final isSelected = _selectedTags.contains(tag.name);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(tag.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(tag.name);
                                  } else {
                                    _selectedTags.remove(tag.name);
                                  }
                                });
                              },
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ActionChip(
                            label: const Text('New Tag'),
                            icon: const Icon(Icons.add),
                            onPressed: () => _showNewTagDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (error, st) => Text('Error loading tags: $error'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewTagDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Tag name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _selectedTags.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
