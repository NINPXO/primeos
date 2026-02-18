/// Database table and column name constants
class DbConstants {
  // Table names
  static const String appSettingsTable = 'app_settings';
  static const String goalCategoriesTable = 'goal_categories';
  static const String goalsTable = 'goals';
  static const String progressEntriesTable = 'progress_entries';
  static const String dailyLogCategoriesTable = 'daily_log_categories';
  static const String dailyLogEntriesTable = 'daily_log_entries';
  static const String noteTagsTable = 'note_tags';
  static const String notesTable = 'notes';
  static const String notesTagsJunctionTable = 'notes_tags_junction';

  // Common column names
  static const String idColumn = 'id';
  static const String nameColumn = 'name';
  static const String titleColumn = 'title';
  static const String createdAtColumn = 'created_at';
  static const String updatedAtColumn = 'updated_at';
  static const String isDeletedColumn = 'is_deleted';
  static const String deletedAtColumn = 'deleted_at';

  // Settings table columns
  static const String keyColumn = 'key';

  // Category columns
  static const String categoryIdColumn = 'category_id';

  // Goals table columns
  static const String statusColumn = 'status';
  static const String descriptionColumn = 'description';
  static const String targetValueColumn = 'target_value';
  static const String targetUnitColumn = 'target_unit';
  static const String targetDateColumn = 'target_date';

  // Progress entries columns
  static const String goalIdColumn = 'goal_id';
  static const String valueColumn = 'value';
  static const String unitColumn = 'unit';
  static const String noteColumn = 'note';
  static const String trackingPeriodColumn = 'tracking_period';
  static const String loggedDateColumn = 'logged_date';

  // Daily log columns
  static const String logDateColumn = 'log_date';
  static const String detailColumn = 'detail';
  static const String durationMinsColumn = 'duration_mins';
  static const String linkedTypeColumn = 'linked_type';
  static const String linkedIdColumn = 'linked_id';

  // Notes columns
  static const String contentJsonColumn = 'content_json';
  static const String contentPlainColumn = 'content_plain';
  static const String isArchivedColumn = 'is_archived';
  static const String archivedAtColumn = 'archived_at';

  // Junction table columns
  static const String noteIdColumn = 'note_id';
  static const String tagIdColumn = 'tag_id';
}
