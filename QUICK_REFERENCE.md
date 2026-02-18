# PrimeOS Quick Reference Commands

## Initial Setup (Run Once)

```bash
# 1. Run setup script (as Administrator)
cd C:\ClodueSpace\PrimeOS
powershell -ExecutionPolicy Bypass -File install-flutter-android.ps1

# 2. Accept licenses (new PowerShell window)
flutter doctor --android-licenses
# Type 'y' for each prompt

# 3. Create emulator (via Android Studio GUI)
# Tools → Device Manager → Create Device
# Select Pixel 5, API 33+, set RAM to 4GB
```

## Running the App

```bash
# Terminal 1: Start emulator (if not already running)
# Android Studio → Tools → Device Manager → Play button

# Terminal 2: Run app
cd C:\ClodueSpace\PrimeOS
flutter run

# While running, press:
r              # Hot reload (code changes instantly)
R              # Full restart (DB schema changes)
q              # Quit
```

## Common Commands

```bash
# Check device connection
flutter devices

# View logs in real-time
flutter logs

# Clean build
flutter clean
flutter pub get
flutter run

# Build APK for release
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Diagnose issues
flutter doctor
flutter doctor -v  # Verbose
```

## Development Workflow

```bash
# 1. Start emulator (Android Studio GUI or command)
emulator -avd Pixel_5_API_33 &

# 2. Run app
flutter run

# 3. Make changes to Dart files

# 4. Hot reload (fast!)
# Press 'r' in the flutter run terminal

# 5. See changes instantly in emulator
```

## Database Inspection

```bash
# Connect to emulator shell
adb shell

# Access app database
cd /data/data/com.example.primeos/databases
sqlite3 app.db

# Inside sqlite3:
.tables                          # List tables
SELECT * FROM goals;             # Query goals
SELECT COUNT(*) FROM notes;      # Count notes
.exit                            # Exit sqlite3
```

## Environment Setup

```bash
# Set ANDROID_HOME (if needed)
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"

# Check PATH includes flutter
$env:PATH -split ';' | ? { $_ -like '*flutter*' }

# Refresh Flutter
flutter pub get
flutter pub upgrade
```

## Troubleshooting Commands

```bash
# Everything check
flutter doctor

# Just Android
flutter doctor --android-licenses

# Kill hung processes
taskkill /F /IM java.exe     # Kill Java/Gradle
pkill -f flutter              # Kill Flutter process

# Restart emulator
adb emu kill                  # Kill emulator

# List all emulators
emulator -list-avds

# Check phone is connected (if using physical device)
adb devices
```

## Project-Specific

```bash
# PrimeOS directory
cd C:\ClodueSpace\PrimeOS

# Run tests (when available)
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Generate code (Freezed, Riverpod)
dart run build_runner build

# Clean and rebuild everything
flutter clean
flutter pub get
flutter run
```

## Hot Reload Tips

```bash
# Works instantly:
- Widget UI changes
- Logic/function changes
- Riverpod provider state changes
- Dart/theme code

# Requires 'R' (full restart):
- Database schema changes
- New imports/dependencies
- Native code changes
- Asset/resource additions
```

## First Run Checklist

- [ ] Run setup script (10-15 min)
- [ ] Accept licenses (2 min)
- [ ] Create emulator (5 min)
- [ ] Run `flutter devices` (shows emulator)
- [ ] Run `flutter run` (3-5 min first time)
- [ ] See 5 tabs in app (Goals, Progress, Daily Log, Notes, Dashboard)
- [ ] Create a goal (FAB + button)
- [ ] Navigate between tabs
- [ ] Press `r` to hot reload (instant!)

---

## File Locations

```
C:\ClodueSpace\PrimeOS\              # Project root
├── lib/                             # Source code
│   ├── main.dart                    # App entry
│   ├── app.dart                     # Root widget
│   ├── core/                        # Database, router, services
│   ├── features/                    # Goals, Progress, Notes, etc.
│   └── settings/                    # Theme, app settings
├── pubspec.yaml                     # Dependencies
├── SETUP.bat                        # Setup script (run first!)
├── SETUP_GUIDE.md                   # Detailed guide
└── QUICK_REFERENCE.md               # This file

Android SDK:
C:\Users\[You]\AppData\Local\Android\Sdk\

Android Studio:
C:\Program Files\Android\Android Studio\

Flutter SDK:
C:\tools\flutter\
```

## Useful Links

- **Flutter Docs**: https://flutter.dev/docs
- **Flutter Install**: https://flutter.dev/docs/get-started/install/windows
- **Dart Docs**: https://dart.dev
- **Riverpod**: https://riverpod.dev
- **GoRouter**: https://pub.dev/packages/go_router

---

**Stuck? Check SETUP_GUIDE.md for detailed troubleshooting!**
