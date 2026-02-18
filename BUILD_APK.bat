@echo off
REM PrimeOS APK Build Script
REM Builds release APK for testing and distribution

echo.
echo ====================================
echo  PrimeOS APK Build
echo ====================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Flutter not found!
    echo.
    echo Please run SETUP.bat first to install Flutter
    echo.
    pause
    exit /b 1
)

echo Building PrimeOS APK...
echo.

REM Run PowerShell build script
powershell -ExecutionPolicy Bypass -File "%~dp0build-apk.ps1"

pause
