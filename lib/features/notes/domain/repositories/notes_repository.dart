import 'package:primeos/core/types/app_result.dart';
import '../entities/note.dart';
import '../entities/note_tag.dart';

abstract interface class NotesRepository {
  Future<AppResult<List<Note>>> getAllNotes({
    bool includeArchived = true,
    bool includeDeleted = false,
  });
  Future<AppResult<List<Note>>> getArchivedNotes({bool includeDeleted = false});
  Future<AppResult<List<Note>>> getNotesByTag(
    String tagName, {
    bool includeArchived = true,
  });
  Future<AppResult<List<Note>>> searchNotes(
    String query, {
    bool includeArchived = true,
  });
  Future<AppResult<Note?>> getNoteById(String id);
  Future<AppResult<void>> createNote(Note note, List<String> tagNames);
  Future<AppResult<void>> updateNote(Note note, List<String> tagNames);
  Future<AppResult<void>> archiveNote(String id);
  Future<AppResult<void>> unarchiveNote(String id);
  Future<AppResult<void>> softDeleteNote(String id);
  Future<AppResult<List<NoteTag>>> getAllTags({bool includeDeleted = false});
  Future<AppResult<NoteTag?>> getTagById(String id);
  Future<AppResult<void>> createTag(NoteTag tag);
  Future<AppResult<void>> updateTag(NoteTag tag);
  Future<AppResult<void>> softDeleteTag(String id);
  Future<AppResult<List<Map<String, dynamic>>>> exportNotesForCsv();
}
