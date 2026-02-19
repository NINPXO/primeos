@echo off
REM PrimeOS Angular Web App - Windows Setup Script
REM This script will diagnose and install the app

echo ========================================
echo PrimeOS Angular Web App - Setup
echo ========================================
echo.

REM Check Node.js
echo [1/5] Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not found!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo OK: Node.js %NODE_VERSION% found

REM Check npm
echo [2/5] Checking npm...
npm --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: npm not found!
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo OK: npm %NPM_VERSION% found

REM Navigate to web directory
echo [3/5] Navigating to web directory...
cd /d "%~dp0web"
if errorlevel 1 (
    echo ERROR: Could not navigate to web directory
    pause
    exit /b 1
)
echo OK: In web directory

REM Clear npm cache
echo [4/5] Clearing npm cache...
call npm cache clean --force >nul 2>&1
echo OK: Cache cleaned

REM Install dependencies with fallback options
echo [5/5] Installing dependencies (this may take 2-5 minutes)...
echo.

REM First try: standard npm install
echo Attempt 1: Standard npm install...
call npm install
if errorlevel 1 (
    echo Attempt 1 failed, trying with legacy peer deps...
    call npm install --legacy-peer-deps
    if errorlevel 1 (
        echo Attempt 2 failed, trying with no optional...
        call npm install --no-optional --legacy-peer-deps
        if errorlevel 1 (
            echo.
            echo ERROR: npm install failed after 3 attempts
            echo.
            echo Troubleshooting tips:
            echo 1. Check internet connection
            echo 2. Try again in 1-2 minutes
            echo 3. Check available disk space (need 1 GB minimum)
            echo 4. Run: npm cache clean --force
            echo 5. Delete node_modules and package-lock.json, try again
            echo.
            pause
            exit /b 1
        )
    )
)

echo.
echo ========================================
echo SUCCESS! Dependencies installed
echo ========================================
echo.
echo Starting Angular development server...
echo App will open at: http://localhost:4200
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the app
call npm start
