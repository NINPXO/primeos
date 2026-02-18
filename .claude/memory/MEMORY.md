# PrimeOS Development Session Memory

## Current Status
- **Phase**: 1 Complete, Phase 2 Starting
- **Last Update**: Session 1, Feb 18, 2026
- **Git Repo**: Initialized with Phase 0-1 commits

## Completed Phases
- ✅ Phase 0: Flutter project scaffold (pubspec.yaml, main.dart, app.dart, folder structure)
- ✅ Phase 1: Database foundation (app_database.dart, migration_v1.dart, migration_runner.dart, database_helper.dart, database_provider.dart)

## In Progress
- Phase 2: Core services & navigation (csv_export_service, csv_import_service, backup_service, zip_export_service, app_router, app_scaffold)

## Next Up
- Phase 3: Goals module (data layer, domain layer, presentation layer)

## Key Decisions Made
- App name: PrimeOS
- Language: Dart/Flutter
- DB: SQLite via sqflite
- State Mgmt: Riverpod (AsyncNotifierProvider)
- Navigation: GoRouter with StatefulShellRoute
- Design: Material 3 (light/dark theme)
- Module structure: 5 tabs (Dashboard, Daily Log, Goals, Progress, Notes)
- Architecture: Clean (presentation/domain/data)

## Critical Success Factors
1. **Database**: Must get schema right in Phase 1 (9 tables, FKs, indexes)
2. **CSV Import**: Duplicate PK resolution (merge vs replace mode)
3. **Soft Delete**: Consistent pattern across all features
4. **FTS Search**: Maintain index on every write/soft-delete
5. **Theme Persistence**: Read/write app_settings table

## Architecture Patterns
- Datasources handle raw SQL + FTS index maintenance
- Repositories implement domain interfaces (one per feature)
- Use cases are one-method classes (pure Dart, no Flutter)
- Presentation layer watches Riverpod AsyncNotifierProviders
- Models (Freezed) bridge DB rows ↔ domain entities

## File Structure Quick Ref
```
lib/
├── core/          (DB, router, services, theme, errors, extensions)
├── shared/        (reusable widgets, search, models)
├── features/      (Goals, Progress, DailyLog, Notes, Dashboard, Trash)
└── settings/      (Settings screen + logic)
```

## Implementation Notes

### Phase 1 Database Schema (COMPLETE)
- 9 tables: app_settings, goal_categories, goals, progress_entries, daily_log_categories, daily_log_entries, note_tags, notes, notes_tags_junction
- FTS5 virtual table for global search
- All PKs are UUID TEXT
- All dates are ISO-8601 TEXT strings
- Soft delete pattern: is_deleted=1, deleted_at=timestamp
- Foreign keys enforced: PRAGMA foreign_keys = ON
- Seed data: 4 goal_categories (Learning, Fitness, Nutrition, General), 3 daily_log_categories (Location, Mobile Usage, App Usage)

### Phase 1 Files
- `lib/core/database/app_database.dart` (78 lines) - Singleton, FK pragma, migration runner
- `lib/core/database/migrations/migration_v1.dart` (269 lines) - Complete schema with 9 tables
- `lib/core/database/migrations/migration_runner.dart` (23 lines) - Migration executor
- `lib/core/database/database_helper.dart` (41 lines) - Transaction/query helpers
- `lib/core/providers/database_provider.dart` (13 lines) - Riverpod FutureProvider

## Resumption Notes
- If interrupted, check git log for last commit
- Verify MEMORY.md updated with current phase status
- Check task list (#1-12) for completion status
- Phase 2 depends on Phase 1 being correct - all 9 tables must exist with proper schema
- Phase 3+ feature modules depend on Phase 2 (routing, CSV services) being complete

