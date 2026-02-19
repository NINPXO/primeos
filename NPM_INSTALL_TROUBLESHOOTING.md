# npm install Failed - Troubleshooting Guide

## Quick Solution (Try These First)

### Option 1: Use the Setup Scripts
**Windows:**
```bash
cd C:\ClodueSpace\PrimeOS
SETUP_WINDOWS.bat
```

**Mac/Linux:**
```bash
cd /path/to/ClodueSpace/PrimeOS
chmod +x SETUP_MAC_LINUX.sh
./SETUP_MAC_LINUX.sh
```

### Option 2: Manual Fix Steps

```bash
# Navigate to web directory
cd C:\ClodueSpace\PrimeOS\web

# Step 1: Clean everything
rm -rf node_modules package-lock.json

# Step 2: Clear npm cache
npm cache clean --force

# Step 3: Install with legacy peer deps flag
npm install --legacy-peer-deps

# Step 4: Start the app
npm start

# Open http://localhost:4200 in browser
```

---

## Common Error Messages & Solutions

### Error 1: "ENETUNREACH" or "ENOTFOUND"
**Cause:** Network connectivity issue

**Solution:**
```bash
# Check internet connection
ping google.com

# Try with npm registry fallback
npm install --legacy-peer-deps --registry https://registry.npmjs.org/

# If still failing, try later when connection is stable
```

### Error 2: "ENOSPC: no space left on device"
**Cause:** Not enough disk space (need ~1 GB)

**Solution:**
```bash
# Check available space
df -h

# Free up space, then try again
npm install --legacy-peer-deps
```

### Error 3: "EPERM: operation not permitted"
**Cause:** Permission issues on your system

**Solution:**
```bash
# Windows: Run Command Prompt as Administrator
# Then run: npm install --legacy-peer-deps

# Mac/Linux:
sudo npm install --legacy-peer-deps
```

### Error 4: "ERR! code ERESOLVE"
**Cause:** Dependency conflict

**Solution:**
```bash
# Clear cache and try with legacy peer deps
npm cache clean --force
npm install --legacy-peer-deps

# Or use npm 7+ force resolution
npm install --force
```

### Error 5: "ELSPROBLEMS" or missing packages
**Cause:** Partial/corrupted installation

**Solution:**
```bash
# Complete clean reinstall
rm -rf node_modules package-lock.json .npm

# Clear cache
npm cache clean --force

# Verify Node and npm versions
node --version  # Must be v20.10.0+
npm --version   # Must be v10.2.3+

# Fresh install
npm install --legacy-peer-deps
```

### Error 6: "gyp ERR!" (native module compilation error)
**Cause:** Build tools missing for native modules

**Solution:**
```bash
# Windows: Install build tools
npm install --global windows-build-tools

# Mac: Install Xcode command line tools
xcode-select --install

# Linux: Install build essentials
sudo apt-get install build-essential python3

# Then retry
npm install --legacy-peer-deps
```

### Error 7: "Cannot find module..." after npm install succeeds
**Cause:** Incomplete installation despite success message

**Solution:**
```bash
# Verify installation
npm ls --depth=0

# If many packages missing, reinstall
rm -rf node_modules
npm install --legacy-peer-deps

# Force install if needed
npm install --force
```

---

## Step-by-Step Recovery Process

If npm install is completely broken, follow this nuclear option:

### Step 1: Clean Everything
```bash
cd C:\ClodueSpace\PrimeOS\web

# Remove all build artifacts
rm -rf node_modules package-lock.json .npm .angular/cache dist

# Clear npm cache
npm cache clean --force

# Clear npm temporary directory
npm cache verify
```

### Step 2: Verify Environment
```bash
# Check Node.js
node --version
# Expected: v20.10.0 or higher

# Check npm
npm --version
# Expected: v10.2.3 or higher

# If versions are old, update:
# npm install -g npm@latest
# node: download from https://nodejs.org/
```

### Step 3: Verify Package.json
```bash
# Make sure package.json exists and is valid
ls -la package.json

# Check it's valid JSON
npm ls --depth=0
```

### Step 4: Try Installation Methods (in order)

**Attempt 1: Standard install**
```bash
npm install
```

**Attempt 2: With legacy peer deps**
```bash
npm install --legacy-peer-deps
```

**Attempt 3: Force install**
```bash
npm install --force
```

**Attempt 4: Manual package install**
```bash
npm install --save \
  @angular/animations@19.1.0 \
  @angular/cdk@19.1.0 \
  @angular/common@19.1.0 \
  @angular/compiler@19.1.0 \
  @angular/core@19.1.0 \
  @angular/forms@19.1.0 \
  @angular/material@19.1.0 \
  @angular/platform-browser@19.1.0 \
  @angular/platform-browser-dynamic@19.1.0 \
  @angular/router@19.1.0 \
  chart.js@4.4.0 \
  dexie@4.0.8 \
  jszip@3.10.1 \
  ng2-charts@4.1.1 \
  ngx-quill@24.2.0 \
  papaparse@5.4.1 \
  quill@2.0.0 \
  rxjs@7.8.0 \
  tslib@2.3.0 \
  uuid@9.0.1 \
  zone.js@0.15.0
```

---

## Diagnostic Commands

Run these to understand what's wrong:

```bash
# Full npm status
npm status

# List all dependencies
npm ls --depth=0

# Check for problems
npm audit

# View npm configuration
npm config list

# Check registry
npm config get registry

# Verify package.json integrity
npm ls

# Check disk space
# Windows:
wmic logicaldisk get name,freespace

# Mac/Linux:
df -h
```

---

## Alternative: Use Docker (Advanced)

If npm install continues to fail, Docker provides a clean environment:

```bash
# Create a Dockerfile
cat > Dockerfile << EOF
FROM node:20-alpine
WORKDIR /app
COPY web/ .
RUN npm install --legacy-peer-deps
EXPOSE 4200
CMD ["npm", "start"]
EOF

# Build and run
docker build -t primeos-web .
docker run -p 4200:4200 primeos-web
```

Then open: http://localhost:4200

---

## When to Seek Help

If none of the above work, provide this info:

1. **System info:**
   ```bash
   node --version
   npm --version
   npm ls --depth=0
   ```

2. **Full error output:**
   ```bash
   npm install 2>&1 | tee npm-error.log
   ```

3. **Disk space:**
   ```bash
   # Windows:
   wmic logicaldisk get name,freespace,size

   # Mac/Linux:
   df -h
   ```

4. **npm config:**
   ```bash
   npm config list
   ```

---

## Quick Reference

| Issue | Command |
|-------|---------|
| Slow/failing | `npm install --legacy-peer-deps` |
| Permission denied | `sudo npm install` or run as admin |
| Out of space | Free up 1 GB, then retry |
| Network issues | Check internet, try later, use VPN if needed |
| Build tools missing | See "gyp ERR!" solution above |
| Corrupted install | `rm -rf node_modules && npm install` |
| All else fails | `npm install --force` |

---

## Expected vs Actual Output

### ✅ GOOD OUTPUT (Success)
```
added 1234 packages, and audited 1235 packages in 3m
found 0 vulnerabilities
```

### ✗ BAD OUTPUT (Failure)
```
ERR! code ENETUNREACH
ERR! errno ENETUNREACH
ERR! network request failed
```

### ⚠️ PARTIAL OUTPUT (Needs Legacy Flag)
```
npm WARN deprecated package-name@version
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
```
→ Try: `npm install --legacy-peer-deps`

---

## Prevention Tips

1. **Keep Node/npm updated:**
   ```bash
   npm install -g npm@latest
   ```

2. **Use exact versions when possible:**
   Edit `package.json` to use exact versions (remove `^` and `~`)

3. **Regular maintenance:**
   ```bash
   npm cache clean --force
   npm audit fix
   ```

4. **Check before you code:**
   ```bash
   npm ls --depth=0
   ```

---

## Support Resources

- **npm documentation:** https://docs.npmjs.com/
- **Angular documentation:** https://angular.io/
- **Stack Overflow:** https://stackoverflow.com/questions/tagged/npm+angular
- **GitHub Issues:** https://github.com/angular/angular/issues

---

**Last Updated:** February 20, 2026
**Status:** Comprehensive troubleshooting guide
**Recommended First Step:** Use setup script (SETUP_WINDOWS.bat or SETUP_MAC_LINUX.sh)
