# PrimeOS Development Setup Guide

## Quick Start (3 Easy Steps)

### Step 1: Run Setup Script
```bash
# Right-click Command Prompt or PowerShell
# Select "Run as Administrator"

cd C:\ClodueSpace\PrimeOS
powershell -ExecutionPolicy Bypass -File install-flutter-android.ps1
```

**⏳ This takes 10-15 minutes. It will:**
- Download & install Chocolatey (Windows package manager)
- Download & install Flutter SDK
- Download & install Android Studio
- Configure environment variables
- Verify installations

**Just let it run! Don't interrupt.**

### Step 2: Accept Android Licenses
```bash
# CLOSE the previous window and open a NEW Command Prompt/PowerShell
# Run as Administrator again

flutter doctor --android-licenses
# Type 'y' and press Enter for EACH license prompt (there will be 4-5)
```

### Step 3: Create Android Emulator

**Open Android Studio**:
1. Start menu → Search "Android Studio"
2. Wait for it to fully load (first launch takes a minute)
3. Click **Tools** → **Device Manager**
4. Click **Create Device**

**Configure Device**:
1. Select **Pixel 5** (good balance of speed & features)
2. Click **Next**
3. Select **Android 13** or higher (if not downloaded, click Download)
4. Click **Next**
5. Change **RAM** to **4096 MB** (important!)
6. Click **Finish**

**Launch Emulator**:
- In Device Manager, click **Play button** (▶️)
- **Wait 30-60 seconds** for emulator to fully boot
- You should see Android home screen

---

## Now Run PrimeOS

```bash
# In Command Prompt/PowerShell (can be same window)

cd C:\ClodueSpace\PrimeOS
flutter run

# Emulator should launch, then app appears in 3-5 minutes
```

**Press `r` while running to hot reload** (instant code updates!)

---

## Verification Checklist

After setup, verify:

```bash
flutter --version
# Should show: Flutter 3.x.x

flutter devices
# Should show: Android SDK built for x86 • emulator-5554

flutter doctor
# Should show mostly green checkmarks (a few warnings are OK)
```

---

## Troubleshooting

### Problem: "Flutter not found" or "command not found"

**Solution**: Close all PowerShell/Command Prompt windows and **open a NEW one**.
Environment variables only update in new windows.

```bash
# Old window: ❌ flutter not found
# Close this window

# New window: ✅ flutter --version works
```

### Problem: Emulator won't start

**Solution**: Increase RAM allocation
1. Android Studio → Tools → Device Manager
2. Right-click device → Edit
3. Change RAM to 4096 MB
4. Try launching again

### Problem: "Gradle sync failed" or build errors

**Solution**: Clean build
```bash
flutter clean
flutter pub get
flutter run
```

### Problem: App crashes on startup

**Solution**: Fresh database
```bash
# App uses SQLite database
# First launch initializes it automatically
# Just wait 10 seconds for splash screen to appear

# If it still crashes, try:
flutter clean
flutter run
```

### Problem: Too slow/laggy emulator

**Solution**:
1. Use **x86 or x86_64** emulator (not ARM)
2. Allocate **4GB+ RAM**
3. Close other apps
4. Use SSD (not HDD)

### Problem: Port/device already in use

**Solution**:
```bash
# Kill existing flutter process
pkill -f flutter

# Or restart emulator via Device Manager
```

### Problem: "ANDROID_HOME not set"

**Solution**: Manually set it
```bash
# Right-click "This PC" or "My Computer" → Properties
# Advanced system settings → Environment Variables
# Create new User Variable:
#   Name: ANDROID_HOME
#   Value: C:\Users\[YourUsername]\AppData\Local\Android\Sdk
# Click OK, close all windows, reopen PowerShell
```

---

## Development Workflow

While app is running in emulator:

```bash
# In the PowerShell window where "flutter run" is active

r          # Hot reload - changes appear instantly
R          # Full restart - 10 seconds
q          # Quit the session

# Make code changes, press 'r' to see them
```

### Hot Reload Works For:
- ✅ Widget changes
- ✅ Logic changes
- ✅ Provider changes

### Hot Reload Won't Work For:
- ❌ Database schema changes (use `R` for restart)
- ❌ New dependencies (use `R`)

---

## Testing the App

Once app loads in emulator:

1. **See 5 bottom tabs**: Dashboard, Daily Log, Goals, Progress, Notes
2. **Goals**: Click FAB (+) to create a goal
3. **Progress**: Add progress linked to a goal
4. **Daily Log**: Create a log entry
5. **Notes**: Create a note with text
6. **Search**: Tap search, find your items
7. **Settings**: Toggle theme (Light/Dark/System)

---

## Files Created

After setup, you'll have:

```
C:\tools\flutter\          ← Flutter SDK
C:\Program Files\Android\  ← Android Studio
C:\Users\[You]\AppData\Local\Android\Sdk\  ← Android SDK
```

---

## Need Help?

If you get stuck:

1. **Check error message** - often tells you exactly what's wrong
2. **Run `flutter doctor`** - shows all issues
3. **Check "Troubleshooting" section above**
4. **Google the error** - Flutter errors usually have solutions online

---

## Next: Try Making Changes

Once app is running:

1. Edit `lib/app.dart` - change "PrimeOS" to something else
2. Press `r` in the flutter run window
3. See changes in emulator in 1-2 seconds!

This is **hot reload** - Flutter's superpower for fast development.

---

**Good luck! You're about to have a fully functional offline productivity app running locally.** 🚀
