import '../../../core/types/app_result.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class SoftDeleteNote {
  Future<AppResult<void>> call(SoftDeleteNoteParams params);
}

final class SoftDeleteNoteImpl implements SoftDeleteNote {
  final NotesRepository _repository;

  SoftDeleteNoteImpl(this._repository);

  @override
  Future<AppResult<void>> call(SoftDeleteNoteParams params) {
    return _repository.softDeleteNote(params.noteId);
  }
}
