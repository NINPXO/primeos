# PrimeOS - Run on Web Browser
# PowerShell script to launch app in Chrome

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  PrimeOS - Running on Web" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check Flutter
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -eq $flutter) {
    Write-Host "`nERROR: Flutter not found!" -ForegroundColor Red
    Write-Host "Make sure Flutter is at C:\src\flutter" -ForegroundColor Yellow
    Write-Host "Or add to PATH: `$env:Path += ';C:\src\flutter\bin'" -ForegroundColor Cyan
    exit 1
}

Write-Host "`nFlutter found: $(flutter --version)" -ForegroundColor Green

# Navigate to project
Set-Location $PSScriptRoot

Write-Host "`nPreparing dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "Launching in Chrome..." -ForegroundColor Cyan
Write-Host "First run takes 2-3 minutes" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Run on Chrome
flutter run -d chrome

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "App closed" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
