@echo off
REM PrimeOS - Run on Web Browser
REM One-click script to launch app in Chrome

echo.
echo ====================================
echo  PrimeOS - Running on Web
echo ====================================
echo.

REM Check if Flutter exists
where flutter >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Flutter not found!
    echo.
    echo Make sure Flutter is installed at C:\src\flutter
    echo.
    pause
    exit /b 1
)

echo Launching PrimeOS in Chrome...
echo (First run takes 2-3 minutes)
echo.

REM Navigate to project
cd /d "%~dp0"

REM Ensure dependencies are ready
echo Preparing dependencies...
call flutter pub get

REM Run on Chrome
echo.
echo Starting web server and Chrome...
echo.
call flutter run -d chrome

REM If flutter run returns, show message
echo.
echo ====================================
echo App closed or error occurred
echo ====================================
pause
