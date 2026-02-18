import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/notes/presentation/providers/note_tags_provider.dart';

typedef OnTagsSelected = Function(List<String> selectedTags);

class NoteTagFilter extends ConsumerWidget {
  final String? selectedTagName;
  final OnTagsSelected onTagsSelected;

  const NoteTagFilter({
    super.key,
    this.selectedTagName,
    required this.onTagsSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(noteTagsProvider);

    return tagsAsync.when(
      data: (tags) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: const Text('All'),
                  selected: selectedTagName == null,
                  onSelected: (_) {
                    onTagsSelected([]);
                  },
                ),
              ),
              // Tag chips
              ...tags.map((tag) {
                final isSelected = selectedTagName == tag.name;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(tag.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        onTagsSelected([tag.name]);
                      } else {
                        onTagsSelected([]);
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, st) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Error loading tags: $error'),
      ),
    );
  }
}
