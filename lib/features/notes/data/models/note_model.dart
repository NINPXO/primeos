import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.contentJson,
    required super.contentPlain,
    super.tags,
    super.isArchived,
    super.archivedAt,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      contentJson: map['content_json'] as String,
      contentPlain: map['content_plain'] as String,
      tags: const [], // Tags populated separately via junction table
      isArchived: (map['is_archived'] as int?) == 1 ? true : false,
      archivedAt: map['archived_at'] != null
          ? DateTime.parse(map['archived_at'] as String)
          : null,
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
      'title': title,
      'content_json': contentJson,
      'content_plain': contentPlain,
      'is_archived': isArchived ? 1 : 0,
      'archived_at': archivedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      contentJson: note.contentJson,
      contentPlain: note.contentPlain,
      tags: note.tags,
      isArchived: note.isArchived,
      archivedAt: note.archivedAt,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isDeleted: note.isDeleted,
      deletedAt: note.deletedAt,
    );
  }

  NoteModel copyWithTags(List<String> newTags) {
    return NoteModel(
      id: id,
      title: title,
      contentJson: contentJson,
      contentPlain: contentPlain,
      tags: newTags,
      isArchived: isArchived,
      archivedAt: archivedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );
  }
}
