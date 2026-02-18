import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/notes/domain/entities/note_tag.dart';
import 'package:primeos/features/notes/domain/repositories/notes_repository.dart';
import 'package:primeos/core/types/app_result.dart';
import 'notes_provider.dart';

/// Tags AsyncNotifierProvider for state management
class TagsNotifier extends AsyncNotifier<List<NoteTag>> {
  late NotesRepository _repository;

  @override
  Future<List<NoteTag>> build() async {
    _repository = ref.read(notesRepositoryProvider);
    final result = await _repository.getAllTags();
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load tags',
    };
  }

  /// Manually refresh tags from database
  Future<void> refreshTags() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllTags();
    state = switch (result) {
      AppSuccess(:final data) => AsyncValue.data(data),
      AppError(:final failure) => AsyncValue.error(
        Exception(_getFailureMessage(failure)),
        StackTrace.current,
      ),
    };
  }

  /// Create a new tag with optimistic update
  Future<void> createTag(NoteTag tag) async {
    // Optimistic update
    final previousTags = state.value ?? [];
    state = AsyncValue.data([...previousTags, tag]);

    // Call repository
    final result = await _repository.createTag(tag);

    // Handle result
    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousTags);
        rethrow;
    }
  }

  /// Soft delete a tag by ID
  Future<void> deleteTag(String tagId) async {
    final previousTags = state.value ?? [];

    // Optimistic update
    final newTags = previousTags.where((t) => t.id != tagId).toList();
    state = AsyncValue.data(newTags);

    // Call repository
    final result = await _repository.softDeleteTag(tagId);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousTags);
        rethrow;
    }
  }
}

final noteTagsProvider =
    AsyncNotifierProvider<TagsNotifier, List<NoteTag>>(TagsNotifier.new);
