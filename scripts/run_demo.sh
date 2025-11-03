#!/bin/bash

# Run script for AndroidImgui demo
# Prerequisites: adb in PATH, Android device connected with debug permissions

set -e

# Check prerequisites
if ! command -v adb &> /dev/null; then
    echo "Error: adb not found in PATH"
    echo "Install Android SDK platform-tools or add adb to PATH"
    exit 1
fi

# Check if device is connected
if ! adb get-state 1>/dev/null 2>&1; then
    echo "Error: No Android device connected"
    echo "Connect a device and enable USB debugging"
    exit 1
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
BUILD_DIR="$SCRIPT_DIR/build-android"
DEMO_BINARY="$BUILD_DIR/testvulkanmenu_demo"
REMOTE_PATH="/data/local/tmp/testvulkanmenu_demo"
LOG_PATH="/sdcard/testvulkanmenu_demo.log"

# Check if demo binary exists
if [ ! -f "$DEMO_BINARY" ]; then
    echo "Error: Demo binary not found at $DEMO_BINARY"
    echo "Run ./scripts/build_demo.sh first"
    exit 1
fi

# Parse command line arguments
BACKEND_ARGS=""
if [ $# -gt 0 ]; then
    if [ "$1" = "--vk" ] || [ "$1" = "--vulkan" ]; then
        BACKEND_ARGS="--vk"
        echo "Using Vulkan backend"
    elif [ "$1" = "--gl" ] || [ "$1" = "--opengl" ]; then
        BACKEND_ARGS="--gl"
        echo "Using OpenGL backend"
    else
        echo "Unknown argument: $1"
        echo "Usage: $0 [--vk|--vulkan|--gl|--opengl]"
        exit 1
    fi
else
    echo "Using default Vulkan backend"
fi

# Get device info
echo "Connected device:"
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
echo "Display info:"
adb shell wm size 2>/dev/null || echo "Could not get display size"

# Push binary to device
echo "Pushing demo binary to device..."
adb push "$DEMO_BINARY" "$REMOTE_PATH"
adb shell chmod 755 "$REMOTE_PATH"

# Clear previous log
adb shell rm -f "$LOG_PATH" 2>/dev/null || true

# Run the demo
echo "Starting demo on device..."
echo "Note: Overlay creation may require root depending on SurfaceComposer access"
echo "Log will be saved to: $LOG_PATH"

# Run with output redirection and capture exit code
 adb shell "$REMOTE_PATH $BACKEND_ARGS" 2>&1 | tee >(adb shell "cat > $LOG_PATH") || {
    echo "Demo execution completed or failed"
}

# Show log location
echo "Demo log saved to device at: $LOG_PATH"
echo "To view log: adb shell cat $LOG_PATH"
echo "To pull log: adb pull $LOG_PATH"

# Cleanup
echo "Cleaning up remote binary..."
adb shell rm -f "$REMOTE_PATH"

echo "Run script completed!"