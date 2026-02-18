import '../../../core/types/app_result.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class ArchiveNote {
  Future<AppResult<void>> call(ArchiveNoteParams params);
}

final class ArchiveNoteImpl implements ArchiveNote {
  final NotesRepository _repository;

  ArchiveNoteImpl(this._repository);

  @override
  Future<AppResult<void>> call(ArchiveNoteParams params) {
    return _repository.archiveNote(params.noteId);
  }
}
