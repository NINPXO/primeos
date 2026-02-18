# PrimeOS Development Environment Setup Script
# Windows 11 - Flutter + Android Studio + Emulator
# Run as Administrator!

# Requires admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  PrimeOS Development Environment Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if Chocolatey is installed
Write-Host "`nChecking for Chocolatey..." -ForegroundColor Yellow
$choco = Get-Command choco -ErrorAction SilentlyContinue
if ($null -eq $choco) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "OK: Chocolatey installed" -ForegroundColor Green
} else {
    Write-Host "OK: Chocolatey already installed" -ForegroundColor Green
}

# Refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install Flutter
Write-Host "`nInstalling Flutter..." -ForegroundColor Yellow
choco install flutter-sdk -y --no-progress
Write-Host "OK: Flutter installed" -ForegroundColor Green

# Install Android Studio
Write-Host "`nInstalling Android Studio..." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes..." -ForegroundColor Cyan
choco install android-studio -y --no-progress
Write-Host "OK: Android Studio installed" -ForegroundColor Green

# Refresh environment again
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set ANDROID_HOME if not already set
Write-Host "`nConfiguring environment variables..." -ForegroundColor Yellow
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
if (-NOT [System.Environment]::GetEnvironmentVariable("ANDROID_HOME", "User")) {
    [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
    Write-Host "OK: ANDROID_HOME set to: $sdkPath" -ForegroundColor Green
} else {
    Write-Host "OK: ANDROID_HOME already configured" -ForegroundColor Green
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
        Write-Host "OK: Added to PATH: $path" -ForegroundColor Green
    }
}

# Refresh environment one more time
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify installations
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutter) {
    flutter --version
    Write-Host "OK: Flutter found" -ForegroundColor Green
} else {
    Write-Host "WARNING: Flutter not in PATH yet" -ForegroundColor Yellow
    Write-Host "Close and reopen PowerShell to refresh PATH" -ForegroundColor Yellow
}

$java = Get-Command java -ErrorAction SilentlyContinue
if ($java) {
    Write-Host "OK: Java found" -ForegroundColor Green
} else {
    Write-Host "ERROR: Java not found" -ForegroundColor Red
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Close this PowerShell window"
Write-Host "2. Open a NEW PowerShell as Administrator"
Write-Host "3. Run: flutter doctor"
Write-Host "4. Run: flutter doctor --android-licenses"
Write-Host "   (type 'y' for each prompt)"
Write-Host "5. Open Android Studio"
Write-Host "   Tools > Device Manager > Create Device"
Write-Host "6. Then run: flutter run"
Write-Host ""
