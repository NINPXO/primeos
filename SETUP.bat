@echo off
REM PrimeOS Development Setup Script
REM Run this as Administrator

echo.
echo ====================================
echo  PrimeOS Development Environment
echo ====================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo.
    echo How to run as Administrator:
    echo 1. Right-click Command Prompt or PowerShell
    echo 2. Select "Run as Administrator"
    echo 3. Navigate to: cd C:\ClodueSpace\PrimeOS
    echo 4. Run: powershell -ExecutionPolicy Bypass -File install-flutter-android.ps1
    echo.
    pause
    exit /b 1
)

echo Running installation script...
echo.

REM Run PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0install-flutter-android.ps1"

echo.
echo Setup complete!
echo Please close this window and open a NEW PowerShell/Command Prompt
pause
