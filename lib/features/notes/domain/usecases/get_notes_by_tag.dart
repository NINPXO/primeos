import '../../../core/types/app_result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class GetNotesByTag {
  Future<AppResult<List<Note>>> call(GetNotesByTagParams params);
}

final class GetNotesByTagImpl implements GetNotesByTag {
  final NotesRepository _repository;

  GetNotesByTagImpl(this._repository);

  @override
  Future<AppResult<List<Note>>> call(GetNotesByTagParams params) {
    return _repository.getNotesByTag(params.tagName);
  }
}
