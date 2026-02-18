import '../../../core/types/app_result.dart';
import '../../../core/utils/id_generator.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';
import 'params.dart';

abstract interface class CreateNote {
  Future<AppResult<Note>> call(CreateNoteParams params);
}

final class CreateNoteImpl implements CreateNote {
  final NotesRepository _repository;
  final IdGenerator _idGenerator;

  CreateNoteImpl(this._repository, this._idGenerator);

  @override
  Future<AppResult<Note>> call(CreateNoteParams params) async {
    final now = DateTime.now();
    final note = Note(
      id: _idGenerator.generateUuid(),
      title: params.title,
      contentJson: params.contentJson,
      contentPlain: params.contentPlain,
      tags: params.tagNames,
      isArchived: false,
      archivedAt: null,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      deletedAt: null,
    );
    await _repository.createNote(note, params.tagNames);
    return AppResult.success(note);
  }
}
