import '../../../core/types/app_result.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class UnarchiveNote {
  Future<AppResult<void>> call(UnarchiveNoteParams params);
}

final class UnarchiveNoteImpl implements UnarchiveNote {
  final NotesRepository _repository;

  UnarchiveNoteImpl(this._repository);

  @override
  Future<AppResult<void>> call(UnarchiveNoteParams params) {
    return _repository.unarchiveNote(params.noteId);
  }
}
