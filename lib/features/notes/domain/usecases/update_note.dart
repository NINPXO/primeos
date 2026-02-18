import '../../../core/types/app_result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class UpdateNote {
  Future<AppResult<Note>> call(UpdateNoteParams params);
}

final class UpdateNoteImpl implements UpdateNote {
  final NotesRepository _repository;

  UpdateNoteImpl(this._repository);

  @override
  Future<AppResult<Note>> call(UpdateNoteParams params) async {
    // Fetch existing note
    final result = await _repository.getNoteById(params.noteId);

    if (result is AppError<Note?>) {
      return AppResult.failure((result as AppError<Note?>).failure);
    }

    final existingNote = (result as AppSuccess<Note?>).data;
    if (existingNote == null) {
      return AppResult.failure(
        NotFoundFailure(message: 'Note not found'),
      );
    }

    final now = DateTime.now();
    final updated = existingNote.copyWith(
      title: params.title ?? existingNote.title,
      contentJson: params.contentJson ?? existingNote.contentJson,
      contentPlain: params.contentPlain ?? existingNote.contentPlain,
      tags: params.tagNames ?? existingNote.tags,
      updatedAt: now,
    );
    final tagNames = params.tagNames ?? existingNote.tags ?? [];
    await _repository.updateNote(updated, tagNames);
    return AppResult.success(updated);
  }
}
