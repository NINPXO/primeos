import '../../../core/types/app_result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class GetNoteById {
  Future<AppResult<Note>> call(GetNoteByIdParams params);
}

final class GetNoteByIdImpl implements GetNoteById {
  final NotesRepository _repository;

  GetNoteByIdImpl(this._repository);

  @override
  Future<AppResult<Note>> call(GetNoteByIdParams params) async {
    final result = await _repository.getNoteById(params.noteId);
    return result.fold(
      (failure) => AppResult.failure(failure),
      (note) {
        if (note == null) {
          return AppResult.failure(
            NotFoundFailure(message: 'Note not found'),
          );
        }
        return AppResult.success(note);
      },
    );
  }
}
