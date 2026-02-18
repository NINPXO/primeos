import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeos/features/notes/domain/entities/note.dart';
import 'package:primeos/features/notes/domain/repositories/notes_repository.dart';
import 'package:primeos/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:primeos/features/notes/data/datasources/notes_local_datasource.dart';
import 'package:primeos/core/providers/database_provider.dart';
import 'package:primeos/core/types/app_result.dart';

/// Repository provider for dependency injection
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final database = ref.watch(databaseProvider).valueOrNull;
  if (database == null) {
    throw Exception('Database not initialized');
  }
  final dataSource = NotesLocalDataSource(database);
  return NotesRepositoryImpl(dataSource);
});

/// Main notes AsyncNotifierProvider for state management
class NotesNotifier extends AsyncNotifier<List<Note>> {
  late NotesRepository _repository;

  @override
  Future<List<Note>> build() async {
    _repository = ref.read(notesRepositoryProvider);
    final result = await _repository.getAllNotes(includeArchived: false);
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  String _getFailureMessage(Failure failure) {
    return switch (failure) {
      DatabaseFailure(:final message) => message,
      ValidationFailure(:final message) => message,
      _ => 'Failed to load notes',
    };
  }

  /// Create a new note with optimistic update
  Future<void> createNote(Note note, List<String> tags) async {
    // Optimistic update
    final previousNotes = state.value ?? [];
    state = AsyncValue.data([...previousNotes, note]);

    // Call repository
    final result = await _repository.createNote(note, tags);

    // Handle result
    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousNotes);
        rethrow;
    }
  }

  /// Update an existing note
  Future<void> updateNote(Note updatedNote, List<String> tags) async {
    final previousNotes = state.value ?? [];

    // Optimistic update
    final newNotes =
        previousNotes.map((n) => n.id == updatedNote.id ? updatedNote : n).toList();
    state = AsyncValue.data(newNotes);

    // Call repository
    final result = await _repository.updateNote(updatedNote, tags);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousNotes);
        rethrow;
    }
  }

  /// Archive a note by ID (soft archive)
  Future<void> archiveNote(String noteId) async {
    final previousNotes = state.value ?? [];

    // Optimistic update - remove from list since we only show non-archived
    final newNotes = previousNotes.where((n) => n.id != noteId).toList();
    state = AsyncValue.data(newNotes);

    // Call repository
    final result = await _repository.archiveNote(noteId);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousNotes);
        rethrow;
    }
  }

  /// Unarchive a note by ID (restore from archive)
  Future<void> unarchiveNote(String noteId) async {
    final previousNotes = state.value ?? [];

    // Call repository first to get the note
    final getNoteResult = await _repository.getNoteById(noteId);
    final unarchivedNote = switch (getNoteResult) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => null,
    };

    if (unarchivedNote != null) {
      // Optimistic update
      state = AsyncValue.data([...previousNotes, unarchivedNote]);

      // Call repository to unarchive
      final result = await _repository.unarchiveNote(noteId);

      switch (result) {
        case AppSuccess():
          // Keep optimistic update
          break;
        case AppError(:final failure):
          // Revert on error
          state = AsyncValue.data(previousNotes);
          rethrow;
      }
    }
  }

  /// Soft delete a note by ID
  Future<void> deleteNote(String noteId) async {
    final previousNotes = state.value ?? [];

    // Optimistic update
    final newNotes = previousNotes.where((n) => n.id != noteId).toList();
    state = AsyncValue.data(newNotes);

    // Call repository
    final result = await _repository.softDeleteNote(noteId);

    switch (result) {
      case AppSuccess():
        // Keep optimistic update
        break;
      case AppError(:final failure):
        // Revert on error
        state = AsyncValue.data(previousNotes);
        rethrow;
    }
  }

  /// Search notes by query (returns separate Future)
  Future<List<Note>> searchNotes(String query) async {
    final result = await _repository.searchNotes(query);
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  /// Get notes filtered by tag name
  Future<List<Note>> getNotesByTag(String tagName) async {
    final result = await _repository.getNotesByTag(tagName);
    return switch (result) {
      AppSuccess(:final data) => data,
      AppError(:final failure) => throw Exception(_getFailureMessage(failure)),
    };
  }

  /// Manually refresh notes from database
  Future<void> refreshNotes() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllNotes(includeArchived: false);
    state = switch (result) {
      AppSuccess(:final data) => AsyncValue.data(data),
      AppError(:final failure) => AsyncValue.error(
        Exception(_getFailureMessage(failure)),
        StackTrace.current,
      ),
    };
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);
