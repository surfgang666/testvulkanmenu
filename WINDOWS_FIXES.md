# Windows Build Fixes

## Issues Fixed

### 1. Batch Script Syntax Error
**Problem**: `batch` is not recognized command
**Solution**: Created proper `build_demo.bat` with correct syntax

### 2. Path Navigation Error  
**Problem**: `SCRIPT%..` incorrect syntax
**Solution**: Use `%~dp0..` to get parent directory

### 3. CMake Generator Issues
**Problem**: Visual Studio generator creates wrong project type
**Solution**: 
- Use `-G "Ninja"` when available (faster)
- Fallback to MSBuild for Android toolchain
- Added automatic detection

### 4. MSBuild Configuration Errors
**Problem**: Wrong platform/configuration for Android builds
**Solution**: 
- Explicit generator selection
- Proper toolchain configuration
- Android-specific CMake settings

## New Files Added

- `scripts/build_demo.bat` - Windows build script
- `scripts/run_demo.bat` - Windows run script  
- `WINDOWS_SETUP.md` - Complete Windows setup guide
- `WINDOWS_FIXES.md` - This file

## Usage

```cmd
# Quick start (after setup)
scripts\build_demo.bat
scripts\run_demo.bat --vk
```

## Requirements

- Android NDK r27+
- CMake 3.22+
- Git (for submodules)
- Android SDK Platform Tools (adb)
- Optional: Ninja (for faster builds)

All scripts handle missing dependencies gracefully and provide helpful error messages.