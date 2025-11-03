#!/bin/bash

# Build script for AndroidImgui demo
# Prerequisites: ANDROID_NDK environment variable set, cmake in PATH

set -e

# Check prerequisites
if [ -z "$ANDROID_NDK" ]; then
    echo "Error: ANDROID_NDK environment variable not set"
    echo "Set it to your Android NDK path, e.g.: export ANDROID_NDK=/path/to/android-ndk"
    exit 1
fi

if ! command -v cmake &> /dev/null; then
    echo "Error: cmake not found in PATH"
    exit 1
fi

# Build configuration
BUILD_DIR="build-android"
ANDROID_ABI="arm64-v8a"
ANDROID_PLATFORM="android-24"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

echo "Building AndroidImgui demo..."
echo "NDK: $ANDROID_NDK"
echo "Build directory: $BUILD_DIR"
echo "Target ABI: $ANDROID_ABI"
echo "Platform: $ANDROID_PLATFORM"

cd "$SCRIPT_DIR"

# Clean previous build if exists
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

# Configure CMake
echo "Configuring CMake..."
cmake -S . -B "$BUILD_DIR" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
    -DBUILD_DEMO=ON \
    -DCMAKE_BUILD_TYPE=Release

# Build
echo "Building demo..."
cmake --build "$BUILD_DIR" -j$(nproc)

# Check if binary was created
DEMO_BINARY="$BUILD_DIR/testvulkanmenu_demo"
if [ -f "$DEMO_BINARY" ]; then
    echo "✓ Demo binary built successfully: $DEMO_BINARY"
    echo "Binary size: $(du -h "$DEMO_BINARY" | cut -f1)"
else
    echo "✗ Demo binary not found after build"
    exit 1
fi

echo "Build completed successfully!"