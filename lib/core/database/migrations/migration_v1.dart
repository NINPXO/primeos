import 'package:sqflite/sqflite.dart';

/// Creates version 1 schema with all 9 tables, indexes, FTS virtual table, and seed data.
void createV1Schema(Batch batch) {
  // 1. app_settings table
  batch.execute('''
    CREATE TABLE app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  // 2. goal_categories table
  batch.execute('''
    CREATE TABLE goal_categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      is_system INTEGER NOT NULL DEFAULT 0,
      color_hex TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT
    )
  ''');

  // 3. goals table
  batch.execute('''
    CREATE TABLE goals (
      id TEXT PRIMARY KEY,
      category_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      status TEXT NOT NULL DEFAULT 'active',
      target_value REAL,
      target_unit TEXT,
      target_date TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT,
      FOREIGN KEY (category_id) REFERENCES goal_categories(id)
    )
  ''');

  batch.execute('''
    CREATE INDEX idx_goals_category_id ON goals(category_id)
  ''');

  batch.execute('''
    CREATE INDEX idx_goals_status ON goals(status)
  ''');

  // 4. progress_entries table
  batch.execute('''
    CREATE TABLE progress_entries (
      id TEXT PRIMARY KEY,
      goal_id TEXT NOT NULL,
      category_id TEXT NOT NULL,
      value REAL NOT NULL,
      unit TEXT,
      note TEXT,
      tracking_period TEXT NOT NULL,
      logged_date TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT,
      FOREIGN KEY (goal_id) REFERENCES goals(id),
      FOREIGN KEY (category_id) REFERENCES goal_categories(id)
    )
  ''');

  batch.execute('''
    CREATE INDEX idx_progress_goal_id ON progress_entries(goal_id)
  ''');

  batch.execute('''
    CREATE INDEX idx_progress_logged_date ON progress_entries(logged_date)
  ''');

  // 5. daily_log_categories table
  batch.execute('''
    CREATE TABLE daily_log_categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      is_fixed INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT
    )
  ''');

  // 6. daily_log_entries table
  batch.execute('''
    CREATE TABLE daily_log_entries (
      id TEXT PRIMARY KEY,
      log_date TEXT NOT NULL,
      category_id TEXT NOT NULL,
      title TEXT NOT NULL,
      detail TEXT,
      duration_mins INTEGER,
      linked_type TEXT,
      linked_id TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT,
      FOREIGN KEY (category_id) REFERENCES daily_log_categories(id)
    )
  ''');

  batch.execute('''
    CREATE INDEX idx_daily_log_date ON daily_log_entries(log_date)
  ''');

  batch.execute('''
    CREATE INDEX idx_daily_log_category_id ON daily_log_entries(category_id)
  ''');

  // 7. note_tags table
  batch.execute('''
    CREATE TABLE note_tags (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      color_hex TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT
    )
  ''');

  // 8. notes table
  batch.execute('''
    CREATE TABLE notes (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      content_json TEXT NOT NULL,
      content_plain TEXT NOT NULL,
      is_archived INTEGER NOT NULL DEFAULT 0,
      archived_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT
    )
  ''');

  batch.execute('''
    CREATE INDEX idx_notes_is_archived ON notes(is_archived)
  ''');

  // 9. notes_tags_junction table
  batch.execute('''
    CREATE TABLE notes_tags_junction (
      note_id TEXT NOT NULL,
      tag_id TEXT NOT NULL,
      PRIMARY KEY (note_id, tag_id),
      FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
      FOREIGN KEY (tag_id) REFERENCES note_tags(id) ON DELETE CASCADE
    )
  ''');

  // 10. FTS5 Virtual Table
  batch.execute('''
    CREATE VIRTUAL TABLE fts_search USING fts5(
      source_type,
      source_id,
      title,
      body,
      content='',
      tokenize='porter unicode61'
    )
  ''');

  // Seed: app_settings
  batch.insert('app_settings', {
    'key': 'theme_mode',
    'value': 'system',
    'updated_at': DateTime.now().toIso8601String(),
  });

  batch.insert('app_settings', {
    'key': 'db_version',
    'value': '1',
    'updated_at': DateTime.now().toIso8601String(),
  });

  // Seed: goal_categories (4 system categories)
  final now = DateTime.now().toIso8601String();

  batch.insert('goal_categories', {
    'id': 'gc-learning-001',
    'name': 'Learning',
    'is_system': 1,
    'color_hex': '#2196F3',
    'created_at': now,
    'updated_at': now,
    'is_deleted': 0,
    'deleted_at': null,
  });

  batch.insert('goal_categories', {
    'id': 'gc-fitness-001',
    'name': 'Fitness',
    'is_system': 1,
    'color_hex': '#4CAF50',
    'created_at': now,
    'updated_at': now,
    'is_deleted': 0,
    'deleted_at': null,
  });

  batch.insert('goal_categories', {
    'id': 'gc-nutrition-001',
    'name': 'Nutrition',
    'is_system': 1,
    'color_hex': '#FF9800',
    'created_at': now,
    'updated_at': now,
    'is_deleted': 0,
    'deleted_at': null,
  });

  batch.insert('goal_categories', {
    'id': 'gc-general-001',
    'name': 'General',
    'is_system': 1,
    'color_hex': '#9C27B0',
    'created_at': now,
    'updated_at': now,
    'is_deleted': 0,
    'deleted_at': null,
  });

  // Seed: daily_log_categories (3 fixed categories)
  batch.insert('daily_log_categories', {
    'id': 'dlc-location-001',
    'name': 'Location',
    'is_fixed': 1,
    'created_at': now,
    'updated_at': now,
    'is_deleted': 0,
    'deleted_at': null,
  });

  batch.insert('daily_log_categories', {
    'id': 'dlc-mobile-usage-001',
    'name': 'Mobile Usage',
    'is_fixed': 1,
    'created_at': now,
    'updated_at': now,
    'is_deleted': 0,
    'deleted_at': null,
  });

  batch.insert('daily_log_categories', {
    'id': 'dlc-app-usage-001',
    'name': 'App Usage',
    'is_fixed': 1,
    'created_at': now,
    'updated_at': now,
    'is_deleted': 0,
    'deleted_at': null,
  });
}
