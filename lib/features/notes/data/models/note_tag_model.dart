import '../../domain/entities/note_tag.dart';

class NoteTagModel extends NoteTag {
  const NoteTagModel({
    required super.id,
    required super.name,
    super.colorHex,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory NoteTagModel.fromMap(Map<String, dynamic> map) {
    return NoteTagModel(
      id: map['id'] as String,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isDeleted: (map['is_deleted'] as int?) == 1 ? true : false,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory NoteTagModel.fromEntity(NoteTag noteTag) {
    return NoteTagModel(
      id: noteTag.id,
      name: noteTag.name,
      colorHex: noteTag.colorHex,
      createdAt: noteTag.createdAt,
      updatedAt: noteTag.updatedAt,
      isDeleted: noteTag.isDeleted,
      deletedAt: noteTag.deletedAt,
    );
  }
}
