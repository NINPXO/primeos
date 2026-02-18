import 'package:sqflite/sqflite.dart';
import '../models/note_model.dart';
import '../models/note_tag_model.dart';

abstract interface class NotesLocalDatasource {
  Future<List<NoteModel>> getAllNotes({
    bool includeArchived = true,
    bool includeDeleted = false,
  });
  Future<List<NoteModel>> getArchivedNotes({bool includeDeleted = false});
  Future<List<NoteModel>> getNotesByTag(
    String tagName, {
    bool includeArchived = true,
  });
  Future<List<NoteModel>> searchNotes(
    String query, {
    bool includeArchived = true,
  });
  Future<NoteModel?> getNoteById(String id);
  Future<void> createNote(NoteModel note, List<String> tagNames);
  Future<void> updateNote(NoteModel note, List<String> tagNames);
  Future<void> archiveNote(String id);
  Future<void> unarchiveNote(String id);
  Future<void> softDeleteNote(String id);
  Future<List<NoteTagModel>> getAllTags({bool includeDeleted = false});
  Future<NoteTagModel?> getTagById(String id);
  Future<void> createTag(NoteTagModel tag);
  Future<void> updateTag(NoteTagModel tag);
  Future<void> softDeleteTag(String id);
  Future<List<Map<String, dynamic>>> exportNotesForCsv();
}

class NotesLocalDatasourceImpl implements NotesLocalDatasource {
  static const _notesTable = 'notes';
  static const _tagsTable = 'note_tags';
  static const _junctionTable = 'notes_tags_junction';
  static const _ftsTable = 'fts_search';

  final Database _db;

  NotesLocalDatasourceImpl(this._db);

  @override
  Future<List<NoteModel>> getAllNotes({
    bool includeArchived = true,
    bool includeDeleted = false,
  }) async {
    String whereClause = 'is_deleted = 0';
    if (!includeArchived) {
      whereClause += ' AND is_archived = 0';
    }
    if (includeDeleted) {
      whereClause = '';
      if (!includeArchived) {
        whereClause = 'is_archived = 0';
      }
    }

    final maps = await _db.query(
      _notesTable,
      where: whereClause.isEmpty ? null : whereClause,
    );
    final notes = <NoteModel>[];
    for (final map in maps) {
      final note = NoteModel.fromMap(map);
      final tags = await _getNoteTags(note.id);
      notes.add(note.copyWithTags(tags));
    }
    return notes;
  }

  @override
  Future<List<NoteModel>> getArchivedNotes({bool includeDeleted = false}) async {
    final whereClause =
        includeDeleted ? 'is_archived = 1' : 'is_archived = 1 AND is_deleted = 0';
    final maps = await _db.query(
      _notesTable,
      where: whereClause,
    );
    final notes = <NoteModel>[];
    for (final map in maps) {
      final note = NoteModel.fromMap(map);
      final tags = await _getNoteTags(note.id);
      notes.add(note.copyWithTags(tags));
    }
    return notes;
  }

  @override
  Future<List<NoteModel>> getNotesByTag(
    String tagName, {
    bool includeArchived = true,
  }) async {
    final query = '''
      SELECT n.* FROM $_notesTable n
      INNER JOIN $_junctionTable ntj ON n.id = ntj.note_id
      INNER JOIN $_tagsTable t ON ntj.tag_id = t.id
      WHERE t.name = ? AND n.is_deleted = 0
    ''';

    final args = [tagName];

    if (!includeArchived) {
      final queryWithArchive = '''
        SELECT n.* FROM $_notesTable n
        INNER JOIN $_junctionTable ntj ON n.id = ntj.note_id
        INNER JOIN $_tagsTable t ON ntj.tag_id = t.id
        WHERE t.name = ? AND n.is_deleted = 0 AND n.is_archived = 0
      ''';
      final maps = await _db.rawQuery(queryWithArchive, args);
      final notes = <NoteModel>[];
      for (final map in maps) {
        final note = NoteModel.fromMap(map);
        final tags = await _getNoteTags(note.id);
        notes.add(note.copyWithTags(tags));
      }
      return notes;
    }

    final maps = await _db.rawQuery(query, args);
    final notes = <NoteModel>[];
    for (final map in maps) {
      final note = NoteModel.fromMap(map);
      final tags = await _getNoteTags(note.id);
      notes.add(note.copyWithTags(tags));
    }
    return notes;
  }

  @override
  Future<List<NoteModel>> searchNotes(
    String query, {
    bool includeArchived = true,
  }) async {
    final searchPattern = '%$query%';
    final whereClause = includeArchived
        ? 'is_deleted = 0 AND content_plain LIKE ?'
        : 'is_deleted = 0 AND is_archived = 0 AND content_plain LIKE ?';

    final maps = await _db.query(
      _notesTable,
      where: whereClause,
      whereArgs: [searchPattern],
    );
    final notes = <NoteModel>[];
    for (final map in maps) {
      final note = NoteModel.fromMap(map);
      final tags = await _getNoteTags(note.id);
      notes.add(note.copyWithTags(tags));
    }
    return notes;
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    final maps = await _db.query(
      _notesTable,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    final note = NoteModel.fromMap(maps.first);
    final tags = await _getNoteTags(note.id);
    return note.copyWithTags(tags);
  }

  @override
  Future<void> createNote(NoteModel note, List<String> tagNames) async {
    await _db.insert(_notesTable, note.toMap());
    await _insertFtsEntry(
      sourceType: 'note',
      sourceId: note.id,
      title: note.title,
      body: '${note.title} ${note.contentPlain}',
    );
    await _addTagsToNote(note.id, tagNames);
  }

  @override
  Future<void> updateNote(NoteModel note, List<String> tagNames) async {
    await _db.update(
      _notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    await _db.delete(
      _ftsTable,
      where: 'source_type = ? AND source_id = ?',
      whereArgs: ['note', note.id],
    );
    await _insertFtsEntry(
      sourceType: 'note',
      sourceId: note.id,
      title: note.title,
      body: '${note.title} ${note.contentPlain}',
    );
    // Remove old tags and add new ones
    await _db.delete(
      _junctionTable,
      where: 'note_id = ?',
      whereArgs: [note.id],
    );
    await _addTagsToNote(note.id, tagNames);
  }

  @override
  Future<void> archiveNote(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      _notesTable,
      {
        'is_archived': 1,
        'archived_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> unarchiveNote(String id) async {
    await _db.update(
      _notesTable,
      {
        'is_archived': 0,
        'archived_at': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> softDeleteNote(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      _notesTable,
      {
        'is_deleted': 1,
        'deleted_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _db.delete(
      _ftsTable,
      where: 'source_type = ? AND source_id = ?',
      whereArgs: ['note', id],
    );
  }

  @override
  Future<List<NoteTagModel>> getAllTags({bool includeDeleted = false}) async {
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final maps = await _db.query(
      _tagsTable,
      where: whereClause,
    );
    return maps.map((m) => NoteTagModel.fromMap(m)).toList();
  }

  @override
  Future<NoteTagModel?> getTagById(String id) async {
    final maps = await _db.query(
      _tagsTable,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return NoteTagModel.fromMap(maps.first);
  }

  @override
  Future<void> createTag(NoteTagModel tag) async {
    await _db.insert(_tagsTable, tag.toMap());
  }

  @override
  Future<void> updateTag(NoteTagModel tag) async {
    await _db.update(
      _tagsTable,
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  @override
  Future<void> softDeleteTag(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      _tagsTable,
      {
        'is_deleted': 1,
        'deleted_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> exportNotesForCsv() async {
    final query = '''
      SELECT
        n.id,
        n.title,
        n.content_plain,
        GROUP_CONCAT(t.name, '|') as tags,
        n.is_archived,
        n.created_at,
        n.updated_at
      FROM $_notesTable n
      LEFT JOIN $_junctionTable ntj ON n.id = ntj.note_id
      LEFT JOIN $_tagsTable t ON ntj.tag_id = t.id
      WHERE n.is_deleted = 0
      GROUP BY n.id
    ''';
    return _db.rawQuery(query);
  }

  Future<List<String>> _getNoteTags(String noteId) async {
    final query = '''
      SELECT t.name FROM $_tagsTable t
      INNER JOIN $_junctionTable ntj ON t.id = ntj.tag_id
      WHERE ntj.note_id = ? AND t.is_deleted = 0
    ''';
    final results = await _db.rawQuery(query, [noteId]);
    return results.map((m) => m['name'] as String).toList();
  }

  Future<void> _addTagsToNote(String noteId, List<String> tagNames) async {
    for (final tagName in tagNames) {
      // Get or create tag by name
      final tagMaps = await _db.query(
        _tagsTable,
        where: 'name = ? AND is_deleted = 0',
        whereArgs: [tagName],
      );

      String tagId;
      if (tagMaps.isEmpty) {
        // Create new tag if it doesn't exist
        tagId = DateTime.now().millisecondsSinceEpoch.toString();
        final now = DateTime.now().toIso8601String();
        await _db.insert(_tagsTable, {
          'id': tagId,
          'name': tagName,
          'color_hex': null,
          'created_at': now,
          'updated_at': now,
          'is_deleted': 0,
          'deleted_at': null,
        });
      } else {
        tagId = tagMaps.first['id'] as String;
      }

      // Add junction record
      await _db.insert(_junctionTable, {
        'note_id': noteId,
        'tag_id': tagId,
      });
    }
  }

  Future<void> _insertFtsEntry({
    required String sourceType,
    required String sourceId,
    required String title,
    required String body,
  }) async {
    await _db.insert(_ftsTable, {
      'source_type': sourceType,
      'source_id': sourceId,
      'title': title,
      'body': body,
    });
  }
}
