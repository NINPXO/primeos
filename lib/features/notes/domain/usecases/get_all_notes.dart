import '../../../core/types/app_result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class GetAllNotes {
  Future<AppResult<List<Note>>> call(GetAllNotesParams params);
}

final class GetAllNotesImpl implements GetAllNotes {
  final NotesRepository _repository;

  GetAllNotesImpl(this._repository);

  @override
  Future<AppResult<List<Note>>> call(GetAllNotesParams params) {
    return _repository.getAllNotes(includeArchived: params.includeArchived);
  }
}
