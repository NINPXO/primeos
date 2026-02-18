import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations/migration_runner.dart';

/// Singleton class for managing the PrimeOS SQLite database.
/// Ensures only one database instance exists throughout the app lifecycle.
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  Database? _database;

  static const String _dbName = 'primeos.db';
  static const int _currentVersion = 1;

  /// Private constructor for singleton pattern.
  AppDatabase._internal();

  /// Factory constructor returns the singleton instance.
  factory AppDatabase() {
    return _instance;
  }

  /// Lazy-initializes and returns the SQLite Database instance.
  /// On first call, initializes the database with migration and foreign key constraints.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  /// Initializes the database with foreign key pragma, onCreate, and onUpgrade handlers.
  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _dbName);

    return await openDatabase(
      path,
      version: _currentVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Enables foreign key constraints before database operations.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Called when database is first created (version 0 -> _currentVersion).
  /// Runs the initial migration to create all tables.
  Future<void> _onCreate(Database db, int version) async {
    await _runMigration(db, 0, version);
  }

  /// Called when database version increases.
  /// Runs all migrations between oldVersion and newVersion.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _runMigration(db, oldVersion, newVersion);
  }

  /// Delegates to migration_runner to execute all pending migrations.
  Future<void> _runMigration(Database db, int oldVersion, int newVersion) async {
    await runMigrations(db, oldVersion, newVersion);
  }

  /// Closes the database connection.
  /// Call this during app shutdown.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
