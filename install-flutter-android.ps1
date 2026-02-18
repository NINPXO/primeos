# PrimeOS Development Environment Setup Script
# Windows 11 - Flutter + Android Studio + Emulator
# Run as Administrator!

# Requires admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell → 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "🚀 PrimeOS Development Environment Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if Chocolatey is installed
Write-Host "`n📦 Checking for Chocolatey..." -ForegroundColor Yellow
$choco = Get-Command choco -ErrorAction SilentlyContinue
if ($null -eq $choco) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "✅ Chocolatey installed" -ForegroundColor Green
} else {
    Write-Host "✅ Chocolatey already installed" -ForegroundColor Green
}

# Refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install Flutter
Write-Host "`n📱 Installing Flutter..." -ForegroundColor Yellow
choco install flutter-sdk -y --no-progress
Write-Host "✅ Flutter installed (or already present)" -ForegroundColor Green

# Install Android Studio
Write-Host "`n🤖 Installing Android Studio..." -ForegroundColor Yellow
Write-Host "⏳ This may take 5-10 minutes..." -ForegroundColor Cyan
choco install android-studio -y --no-progress
Write-Host "✅ Android Studio installed (or already present)" -ForegroundColor Green

# Refresh environment again
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set ANDROID_HOME if not already set
Write-Host "`n⚙️  Configuring environment variables..." -ForegroundColor Yellow
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
if (-NOT [System.Environment]::GetEnvironmentVariable("ANDROID_HOME", "User")) {
    [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
    Write-Host "✅ ANDROID_HOME set to: $sdkPath" -ForegroundColor Green
} else {
    Write-Host "✅ ANDROID_HOME already configured" -ForegroundColor Green
}

# Update PATH for Flutter and Android tools
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$updates = @(
    "C:\tools\flutter\bin",
    "$sdkPath\cmdline-tools\latest\bin",
    "$sdkPath\platform-tools"
)

foreach ($path in $updates) {
    if ($userPath -notlike "*$path*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$userPath;$path", "User")
        Write-Host "✅ Added to PATH: $path" -ForegroundColor Green
    }
}

# Refresh environment one more time
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify installations
Write-Host "`n✅ Verification" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutter) {
    Write-Host "✅ Flutter: $(flutter --version)" -ForegroundColor Green
} else {
    Write-Host "⚠️  Flutter not found in PATH yet. Close and reopen PowerShell." -ForegroundColor Yellow
}

$java = Get-Command java -ErrorAction SilentlyContinue
if ($java) {
    Write-Host "✅ Java: $(java -version 2>&1 | Select-Object -First 1)" -ForegroundColor Green
} else {
    Write-Host "❌ Java not found" -ForegroundColor Red
}

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Close this PowerShell window"
Write-Host "2. Open a NEW PowerShell window (important!)"
Write-Host "3. Run: flutter doctor"
Write-Host "4. Run: flutter doctor --android-licenses (type 'y' for each)"
Write-Host "5. Open Android Studio and create an emulator (Tools → Device Manager)"
Write-Host "6. Then run: flutter run (in PrimeOS directory)"
Write-Host ""
Write-Host "❓ Questions? Check SETUP_HELP.txt for troubleshooting" -ForegroundColor Cyan
