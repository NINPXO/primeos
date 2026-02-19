#!/bin/bash
# PrimeOS Angular Web App - Mac/Linux Setup Script
# This script will diagnose and install the app

set -e

echo "========================================"
echo "PrimeOS Angular Web App - Setup"
echo "========================================"
echo ""

# Check Node.js
echo "[1/5] Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js not found!"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi
NODE_VERSION=$(node --version)
echo "OK: Node.js $NODE_VERSION found"

# Check npm
echo "[2/5] Checking npm..."
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm not found!"
    exit 1
fi
NPM_VERSION=$(npm --version)
echo "OK: npm $NPM_VERSION found"

# Navigate to web directory
echo "[3/5] Navigating to web directory..."
cd "$(dirname "$0")/web"
echo "OK: In web directory"

# Clear npm cache
echo "[4/5] Clearing npm cache..."
npm cache clean --force > /dev/null 2>&1 || true
echo "OK: Cache cleaned"

# Install dependencies with fallback options
echo "[5/5] Installing dependencies (this may take 2-5 minutes)..."
echo ""

# First try: standard npm install
echo "Attempt 1: Standard npm install..."
if npm install; then
    echo ""
    echo "========================================"
    echo "SUCCESS! Dependencies installed"
    echo "========================================"
    echo ""
    echo "Starting Angular development server..."
    echo "App will open at: http://localhost:4200"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    npm start
else
    echo "Attempt 1 failed, trying with legacy peer deps..."
    if npm install --legacy-peer-deps; then
        echo ""
        echo "========================================"
        echo "SUCCESS! Dependencies installed"
        echo "========================================"
        echo ""
        echo "Starting Angular development server..."
        echo "App will open at: http://localhost:4200"
        echo ""
        echo "Press Ctrl+C to stop the server"
        echo ""
        npm start
    else
        echo "Attempt 2 failed, trying with no optional..."
        if npm install --no-optional --legacy-peer-deps; then
            echo ""
            echo "========================================"
            echo "SUCCESS! Dependencies installed"
            echo "========================================"
            echo ""
            echo "Starting Angular development server..."
            echo "App will open at: http://localhost:4200"
            echo ""
            echo "Press Ctrl+C to stop the server"
            echo ""
            npm start
        else
            echo ""
            echo "ERROR: npm install failed after 3 attempts"
            echo ""
            echo "Troubleshooting tips:"
            echo "1. Check internet connection"
            echo "2. Try again in 1-2 minutes"
            echo "3. Check available disk space (need 1 GB minimum)"
            echo "4. Run: npm cache clean --force"
            echo "5. Delete node_modules and package-lock.json, try again"
            echo ""
            exit 1
        fi
    fi
fi
