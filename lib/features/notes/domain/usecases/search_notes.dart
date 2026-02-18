import '../../../core/types/app_result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class SearchNotes {
  Future<AppResult<List<Note>>> call(SearchNotesParams params);
}

final class SearchNotesImpl implements SearchNotes {
  final NotesRepository _repository;

  SearchNotesImpl(this._repository);

  @override
  Future<AppResult<List<Note>>> call(SearchNotesParams params) async {
    if (params.query.trim().isEmpty) {
      return AppResult.failure(
        ValidationFailure(message: 'Search query cannot be empty'),
      );
    }
    return _repository.searchNotes(params.query);
  }
}
