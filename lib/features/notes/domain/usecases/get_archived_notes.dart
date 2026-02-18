import '../../../core/types/app_result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class GetArchivedNotes {
  Future<AppResult<List<Note>>> call(GetArchivedNotesParams params);
}

final class GetArchivedNotesImpl implements GetArchivedNotes {
  final NotesRepository _repository;

  GetArchivedNotesImpl(this._repository);

  @override
  Future<AppResult<List<Note>>> call(GetArchivedNotesParams params) {
    return _repository.getArchivedNotes();
  }
}
