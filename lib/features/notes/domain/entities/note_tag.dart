import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_tag.freezed.dart';

@freezed
class NoteTag with _$NoteTag {
  const factory NoteTag({
    required String id,
    required String name,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
  }) = _NoteTag;
}
