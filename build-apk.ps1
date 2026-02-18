# PrimeOS APK Build Script
# Builds release APK for testing and distribution

Write-Host "🚀 PrimeOS APK Build Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if Flutter is available
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -eq $flutter) {
    Write-Host "❌ Flutter not found in PATH" -ForegroundColor Red
    Write-Host "Please run SETUP.bat first to install Flutter" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Flutter found: $(flutter --version)" -ForegroundColor Green

# Verify we're in the right directory
if (-NOT (Test-Path "pubspec.yaml")) {
    Write-Host "❌ pubspec.yaml not found" -ForegroundColor Red
    Write-Host "Please run this script from PrimeOS project directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n📦 Building APK..." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes on first build" -ForegroundColor Cyan

# Clean previous builds
Write-Host "`n🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "`n📚 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build release APK
Write-Host "`n⚙️  Building release APK..." -ForegroundColor Yellow
Write-Host "⏳ This will take several minutes..." -ForegroundColor Cyan
flutter build apk --release

# Check if build was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ APK Build Successful!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green

    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    $apkSize = (Get-Item $apkPath).Length / 1MB

    Write-Host "📱 APK Location:" -ForegroundColor Yellow
    Write-Host "   $apkPath" -ForegroundColor Cyan
    Write-Host "📊 APK Size: $([Math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan

    Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Copy APK to your phone via USB" -ForegroundColor White
    Write-Host "2. Enable 'Install from Unknown Sources' in Settings" -ForegroundColor White
    Write-Host "3. Open APK on phone to install" -ForegroundColor White
    Write-Host "4. Test the app!" -ForegroundColor White

    Write-Host "`n💡 Or test on emulator:" -ForegroundColor Yellow
    Write-Host "   adb install -r build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan

} else {
    Write-Host "`n❌ APK Build Failed!" -ForegroundColor Red
    Write-Host "Check the error messages above" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n" -ForegroundColor Cyan
