import 'package:primeos/core/types/app_result.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_tag.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';
import '../models/note_tag_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDatasource _datasource;

  NotesRepositoryImpl(this._datasource);

  @override
  Future<AppResult<List<Note>>> getAllNotes({
    bool includeArchived = true,
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _datasource.getAllNotes(
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Note>>> getArchivedNotes(
      {bool includeDeleted = false}) async {
    try {
      final models =
          await _datasource.getArchivedNotes(includeDeleted: includeDeleted);
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Note>>> getNotesByTag(
    String tagName, {
    bool includeArchived = true,
  }) async {
    try {
      final models = await _datasource.getNotesByTag(
        tagName,
        includeArchived: includeArchived,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Note>>> searchNotes(
    String query, {
    bool includeArchived = true,
  }) async {
    try {
      final models = await _datasource.searchNotes(
        query,
        includeArchived: includeArchived,
      );
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<Note?>> getNoteById(String id) async {
    try {
      final model = await _datasource.getNoteById(id);
      return AppSuccess(model);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> createNote(Note note, List<String> tagNames) async {
    try {
      final model = NoteModel.fromEntity(note);
      await _datasource.createNote(model, tagNames);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> updateNote(Note note, List<String> tagNames) async {
    try {
      final model = NoteModel.fromEntity(note);
      await _datasource.updateNote(model, tagNames);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> archiveNote(String id) async {
    try {
      await _datasource.archiveNote(id);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> unarchiveNote(String id) async {
    try {
      await _datasource.unarchiveNote(id);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> softDeleteNote(String id) async {
    try {
      await _datasource.softDeleteNote(id);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<NoteTag>>> getAllTags(
      {bool includeDeleted = false}) async {
    try {
      final models =
          await _datasource.getAllTags(includeDeleted: includeDeleted);
      return AppSuccess(models);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<NoteTag?>> getTagById(String id) async {
    try {
      final model = await _datasource.getTagById(id);
      return AppSuccess(model);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> createTag(NoteTag tag) async {
    try {
      final model = NoteTagModel.fromEntity(tag);
      await _datasource.createTag(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> updateTag(NoteTag tag) async {
    try {
      final model = NoteTagModel.fromEntity(tag);
      await _datasource.updateTag(model);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<void>> softDeleteTag(String id) async {
    try {
      await _datasource.softDeleteTag(id);
      return const AppSuccess(null);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<AppResult<List<Map<String, dynamic>>>> exportNotesForCsv() async {
    try {
      final data = await _datasource.exportNotesForCsv();
      return AppSuccess(data);
    } catch (e) {
      return AppError(DatabaseFailure(e.toString()));
    }
  }
}
