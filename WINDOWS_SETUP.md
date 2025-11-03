# Windows Setup Guide

This guide helps you set up the AndroidImgui project on Windows.

## Prerequisites

1. **Android NDK** - Download from [Android NDK Releases](https://developer.android.com/ndk/downloads)
   - Recommended: NDK r27 or later
   - Extract to: `C:\android-ndk-r27d` (or your preferred location)

2. **CMake** - Download from [CMake Download](https://cmake.org/download/)
   - Version 3.22 or later
   - Add to PATH during installation

3. **Git** - Download from [Git Download](https://git-scm.com/download/win)
   - Add to PATH during installation

4. **Android SDK Platform Tools** - Download from [Android SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools)
   - Extract and add `platform-tools` to PATH (contains `adb.exe`)

5. **Build Tools** (optional but recommended)
   - **Ninja** - Download from [Ninja Releases](https://github.com/ninja-build/ninja/releases)
   - Add `ninja.exe` to PATH for faster builds

## Quick Setup

### 1. Set Environment Variables

Open Command Prompt and set:

```cmd
set ANDROID_NDK=C:\android-ndk-r27d
```

Or set permanently in System Properties:
1. Press `Win + R`, type `sysdm.cpl`
2. Go to `Advanced` → `Environment Variables`
3. Add `ANDROID_NDK` with your NDK path

### 2. Clone and Initialize Project

```cmd
git clone <your-repo-url> testvulkanmenu
cd testvulkanmenu
git submodule update --init --recursive
```

### 3. Build and Run Demo

```cmd
# Using batch scripts (recommended)
scripts\build_demo.bat
scripts\run_demo.bat --vk

# Or manually
cmake -S . -B build-android ^
    -DANDROID_ABI=arm64-v8a ^
    -DANDROID_PLATFORM=android-24 ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%\build\cmake\android.toolchain.cmake ^
    -DBUILD_DEMO=ON ^
    -G "Ninja"

cmake --build build-android --config Release
```

## Troubleshooting

### "batch is not recognized" Error
- Make sure you're running: `scripts\build_demo.bat` (not `batch`)

### MSBuild Configuration Errors
- Install Ninja for faster, more reliable builds
- Or use `-G "NMake Makefiles"` instead of default generator

### "adb not found" Error
- Add Android SDK platform-tools to PATH
- Or run from platform-tools directory

### "ANDROID_NDK not set" Error
- Set environment variable: `set ANDROID_NDK=C:\path\to\ndk`
- Or enter path when prompted by build script

### Build Fails with Visual Studio
- Ensure you have Visual Studio 2019+ with C++ development tools
- Or use Visual Studio Build Tools

## Device Setup

1. Enable Developer Options on Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `adb devices` to verify connection

## Performance Tips

- Use Ninja generator for faster builds
- Use SSD for build directory
- Parallel builds: `-j%NUMBER_OF_PROCESSORS%`
- Use Release configuration for production builds