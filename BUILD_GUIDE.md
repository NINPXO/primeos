# PrimeOS APK Build & Distribution Guide

## Quick Build (Automated)

### Step 1: Ensure Environment is Ready

```bash
# Verify Flutter is installed
flutter --version

# Verify device/emulator is available (optional, for testing)
flutter devices
```

### Step 2: Build Release APK

**Option A: Use Script (Easiest)**
```bash
cd C:\ClodueSpace\PrimeOS
powershell -ExecutionPolicy Bypass -File build-apk.ps1

# Or double-click:
# BUILD_APK.bat
```

**Option B: Manual Build**
```bash
cd C:\ClodueSpace\PrimeOS
flutter clean
flutter pub get
flutter build apk --release
```

### Step 3: APK Output Location

After successful build:
```
C:\ClodueSpace\PrimeOS\build\app\outputs\flutter-apk\app-release.apk
```

**File size**: ~40-50 MB

---

## Testing the APK

### Option A: Test on Emulator (Easiest)

```bash
# With emulator running
adb install -r build/app/outputs/flutter-apk/app-release.apk

# App appears in emulator launcher
# Click to open and test
```

### Option B: Test on Physical Phone

**Prerequisites**:
- USB cable
- Phone with USB debugging enabled
- Android SDK Platform-Tools installed

**Steps**:

1. **Enable USB Debugging on Phone**:
   - Settings → Developer Options → USB Debugging (turn ON)
   - If Developer Options not visible:
     - Settings → About Phone → Build Number
     - Tap Build Number 7 times
     - Developer Options appears

2. **Connect Phone via USB**:
   - Plug in phone
   - Allow USB debugging on phone prompt

3. **Verify Connection**:
   ```bash
   adb devices
   # Should show your device with "device" status
   ```

4. **Install APK**:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

5. **Launch App**:
   - Phone home screen → Find "PrimeOS"
   - Tap to open
   - Test all features!

### Option C: Manual Installation via USB

1. Connect phone to computer via USB
2. Copy APK to phone:
   ```bash
   adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/
   ```

3. On phone:
   - File manager → Downloads
   - Tap PrimeOS APK
   - If prompted, enable "Install from Unknown Sources"
   - Tap Install

---

## Build Variants

### Debug Build (for development)
```bash
flutter build apk --debug
# Larger, slower, more logging
# Location: build/app/outputs/apk/debug/app-debug.apk
```

### Release Build (for production)
```bash
flutter build apk --release
# Optimized, smaller, signed
# Location: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
# Better compression for Play Store distribution
# Location: build/app/outputs/bundle/release/app-release.aab
```

---

## Signing APK for Distribution

### Automatic Signing (Included)

Flutter handles signing automatically using a debug keystore. The release APK is already signed and ready to distribute!

### Custom Signing (Optional)

If you want to use your own key:

1. **Create Keystore**:
   ```bash
   keytool -genkey -v -keystore primeos-key.jks ^
     -keyalg RSA -keysize 2048 -validity 10000 ^
     -alias primeos-key

   # Follow prompts for password and info
   ```

2. **Create Signing Config**:
   Create `android/key.properties`:
   ```
   storePassword=your_password
   keyPassword=your_password
   keyAlias=primeos-key
   storeFile=../primeos-key.jks
   ```

3. **Build with Custom Key**:
   ```bash
   flutter build apk --release
   # Flutter automatically uses key.properties if present
   ```

---

## APK Optimization

### App Size Optimization

If APK is too large, optimize:

```bash
# Enable app shrinking
flutter build apk --release --split-per-abi
# Outputs separate APK per CPU architecture
# Smaller per-APK size, but more APKs to distribute
```

### Reduce Build Size

Edit `pubspec.yaml`:
- Remove unused dependencies
- Use conditional imports
- Minimize assets

---

## Distribution Options

### Option 1: Direct APK Distribution
- Email APK to users
- Upload to GitHub releases
- Host on website

**Pros**: Simple, no store review process
**Cons**: Users must enable "Unknown Sources", no auto-updates

### Option 2: Google Play Store
- Build App Bundle: `flutter build appbundle --release`
- Sign up at https://play.google.com/console
- Upload App Bundle
- Follow store review process

**Pros**: Official distribution, auto-updates, user reviews
**Cons**: Review process, store fees, more complex

### Option 3: GitHub Releases
```bash
# Tag and push to GitHub
git tag v1.0.0
git push origin v1.0.0

# Create release on GitHub
# Attach APK file
# Users can download directly
```

---

## Troubleshooting Build Issues

### Problem: "Build failed" or Gradle error

**Solution**: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Problem: "SDK location not found"

**Solution**: Create `local.properties`
```bash
# In android/ directory
echo sdk.dir=$env:ANDROID_HOME | Out-File local.properties
```

### Problem: Keystore error

**Solution**: Use debug keystore
```bash
# Remove custom key.properties temporarily
del android/key.properties
flutter build apk --release
```

### Problem: Out of memory / build hangs

**Solution**: Increase Gradle memory
```bash
# Create gradle.properties in android/
org.gradle.jvmargs=-Xmx4096m
```

### Problem: APK very large (>100MB)

**Solution**: Split by architecture
```bash
flutter build apk --release --split-per-abi
# Creates separate APK for arm64, armv7, x86
# Each ~20-30MB instead of 50MB combined
```

---

## Verification Checklist

After building APK:

- [ ] APK file exists at expected location
- [ ] APK size is reasonable (~40-50MB)
- [ ] Can install on emulator: `adb install -r app-release.apk`
- [ ] App launches without crashing
- [ ] Can create goals, progress, notes
- [ ] Search works across modules
- [ ] Theme toggle works
- [ ] Navigation between tabs works
- [ ] No errors in logcat: `flutter logs` or `adb logcat`

---

## Testing on Device Checklist

Once installed on phone:

- [ ] App icon visible on home screen
- [ ] App launches (splash screen appears)
- [ ] All 5 tabs visible at bottom
- [ ] Can create items without crashes
- [ ] Database initializes automatically
- [ ] Search finds created items
- [ ] Theme persists after restart
- [ ] No crashes when navigating

---

## Performance Tips

1. **First build is slow** (5-10 min) because Gradle downloads dependencies
2. **Subsequent builds are faster** (2-3 min)
3. **Split per ABI** reduces size significantly
4. **App Bundle** is best for Play Store (better compression)
5. **Release APK** is much faster than debug APK

---

## File Locations After Build

```
build/app/outputs/
├── flutter-apk/
│   ├── app-release.apk          ← Single APK (all architectures)
│   ├── app-release-arm64-v8a.apk ← Split by arch
│   ├── app-release-armeabi-v7a.apk
│   └── app-release-x86_64.apk
└── apk/debug/
    └── app-debug.apk            ← Debug build

build/app/outputs/bundle/release/
└── app-release.aab              ← App Bundle for Play Store
```

---

## Next Steps

1. **Build APK**: `powershell -ExecutionPolicy Bypass -File build-apk.ps1`
2. **Test on device/emulator**: `adb install -r app-release.apk`
3. **Verify all features work**
4. **Share with others**: Email APK or upload to GitHub
5. **Consider Play Store**: If planning public distribution

---

## Useful Commands

```bash
# Build and install on emulator in one command
flutter build apk --release && adb install -r build/app/outputs/flutter-apk/app-release.apk

# View APK contents
unzip -l build/app/outputs/flutter-apk/app-release.apk

# Get APK size
(Get-Item "build\app\outputs\flutter-apk\app-release.apk").Length / 1MB

# Install and run
adb install -r build/app/outputs/flutter-apk/app-release.apk && adb shell am start -n com.example.primeos/.MainActivity

# View logs during testing
flutter logs
```

---

## Distribution Best Practices

1. **Version your builds**: Use semantic versioning (1.0.0, 1.0.1, etc.)
2. **Test thoroughly**: Before distributing to others
3. **Document features**: Create README for users
4. **Bug tracking**: Collect feedback from testers
5. **Update regularly**: Fix bugs, add features, distribute new versions

---

**Ready to build? Run `BUILD_APK.bat` or use the PowerShell command!** 🚀
