sealed class NotesUseCaseParams {}

final class NoParams extends NotesUseCaseParams {
  const NoParams();
}

final class GetAllNotesParams extends NotesUseCaseParams {
  final bool includeArchived;
  const GetAllNotesParams({this.includeArchived = true});
}

final class GetArchivedNotesParams extends NotesUseCaseParams {
  const GetArchivedNotesParams();
}

final class GetNotesByTagParams extends NotesUseCaseParams {
  final String tagName;
  const GetNotesByTagParams(this.tagName);
}

final class SearchNotesParams extends NotesUseCaseParams {
  final String query;
  const SearchNotesParams(this.query);
}

final class GetNoteByIdParams extends NotesUseCaseParams {
  final String noteId;
  const GetNoteByIdParams(this.noteId);
}

final class CreateNoteParams extends NotesUseCaseParams {
  final String title;
  final String contentJson;
  final String contentPlain;
  final List<String> tagNames;

  const CreateNoteParams({
    required this.title,
    required this.contentJson,
    required this.contentPlain,
    this.tagNames = const [],
  });
}

final class UpdateNoteParams extends NotesUseCaseParams {
  final String noteId;
  final String? title;
  final String? contentJson;
  final String? contentPlain;
  final List<String>? tagNames;

  const UpdateNoteParams({
    required this.noteId,
    this.title,
    this.contentJson,
    this.contentPlain,
    this.tagNames,
  });
}

final class ArchiveNoteParams extends NotesUseCaseParams {
  final String noteId;
  const ArchiveNoteParams(this.noteId);
}

final class UnarchiveNoteParams extends NotesUseCaseParams {
  final String noteId;
  const UnarchiveNoteParams(this.noteId);
}

final class SoftDeleteNoteParams extends NotesUseCaseParams {
  final String noteId;
  const SoftDeleteNoteParams(this.noteId);
}

final class ExportNotesCsvParams extends NotesUseCaseParams {
  const ExportNotesCsvParams();
}
