import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String title,
    required String contentJson,
    required String contentPlain,
    List<String>? tags,
    @Default(false) bool isArchived,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
  }) = _Note;
}
