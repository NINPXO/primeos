# PrimeOS - Personal Multi-Utility Life Tracker

A fully offline Flutter mobile application that tracks personal productivity across multiple dimensions: Goals, Progress, Daily Logs, and Notes. All data is stored locally with no cloud dependency.

## Features

- **Goals**: Create and track goals with custom categories (Learning, Fitness, Nutrition, General + user-created)
- **Progress**: Log progress entries against goals with daily/weekly/monthly tracking
- **Daily Log**: Track daily activities by predefined categories (Location, Mobile Usage, App Usage)
- **Notes**: Rich text notes with tags and search
- **Dashboard**: Summary view of today's/week's/month's activities with quick export/clear actions
- **Global Search**: Full-text search across all modules
- **Trash & Restore**: Soft delete with restore capability
- **CSV Import/Export**: Export per module, per category, or full database ZIP
- **Dark/Light Theme**: Material 3 design with persistent theme preference

## Architecture

- **Pattern**: Clean Architecture (Presentation/Domain/Data layers)
- **State Management**: Riverpod (AsyncNotifierProvider, Provider)
- **Database**: SQLite (sqflite) with 9 tables, soft delete pattern, FTS5 search
- **Navigation**: GoRouter with StatefulShellRoute (5-tab bottom navigation)
- **Design**: Material 3 with light/dark theme support

## Tech Stack

- Flutter 3.19+
- Dart 3.3+
- Riverpod 2.5+
- GoRouter 14.2+
- SQLite via sqflite 2.3+
- Material 3 design

## Project Structure

```
lib/
├── core/              # Database, routing, services, theme, utilities
├── shared/            # Reusable widgets, models, search
├── features/          # Feature modules (Goals, Progress, DailyLog, Notes, Dashboard, Trash)
└── settings/          # Settings screen and logic
```

## Getting Started

### Prerequisites

- Flutter SDK 3.19.0 or later
- Dart 3.3.0 or later
- Android SDK (for Android builds) or Xcode (for iOS builds)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/primeos.git
   cd primeos
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   flutter pub run build_runner build
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Build

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

## Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Generate Code
```bash
flutter pub run build_runner build
```

## Implementation Phases

- **Phase 0**: Bootstrap (Flutter project setup) ✓
- **Phase 1**: Database foundation (schema, migrations)
- **Phase 2**: Core services & navigation
- **Phase 3-7**: Feature modules (Goals, Progress, DailyLog, Notes, Dashboard)
- **Phase 8-10**: Trash, global search, settings
- **Phase 11**: QA & polish

## Architecture Notes

### Database Design
- All PKs: UUID v4 TEXT (not SQLite rowid)
- All dates: ISO-8601 strings
- Soft delete: `is_deleted=1, deleted_at=timestamp`
- Foreign keys: enabled with `PRAGMA foreign_keys = ON`

### Clean Architecture Pattern
- **Data Layer**: Models (Freezed), local datasources (sqflite), repository implementations
- **Domain Layer**: Pure Dart entities, repository interfaces, use cases (one per action)
- **Presentation Layer**: Riverpod providers, UI pages, reusable widgets

### State Management
- Use `AsyncNotifierProvider` for feature state
- Use `Provider` for services (database, repositories, routers)
- Use `FutureProvider` for async initialization
- Never use `StateNotifier` - use `AsyncNotifier` instead

## Contributing

This is a solo development project. Contributions welcome via pull requests.

## License

MIT License - see LICENSE file for details.

## Roadmap

- Phase 1-11 implementation as per `plans/mossy-brewing-oasis.md`
- Testing and QA
- Production release
- Post-launch features: advanced analytics, data visualization, additional categories
