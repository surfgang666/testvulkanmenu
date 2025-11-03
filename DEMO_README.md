# AndroidImgui Demo

This directory contains a demo executable for the AndroidImgui library.

## Building the Demo

### Prerequisites

1. Initialize git submodules: `git submodule update --init --recursive`
2. Android NDK (set ANDROID_NDK environment variable)
3. CMake 3.22 or higher
4. Android development tools (adb for running)

### Build Commands

```bash
# Configure and build the demo
cmake -S . -B build-android \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-24 \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DBUILD_DEMO=ON

cmake --build build-android -j
```

### Using the Build Scripts

```bash
# Build the demo
./scripts/build_demo.sh

# Run the demo (Vulkan backend - default)
./scripts/run_demo.sh

# Run with OpenGL backend
./scripts/run_demo.sh --gl

# Run with Vulkan backend (explicit)
./scripts/run_demo.sh --vk
```

## Demo Features

The demo executable (`testvulkanmenu_demo`) provides:

- **Backend Selection**: Choose between Vulkan and OpenGL ES backends
  - Command line: `--vk` or `--gl`  
  - Environment variable: `DEMO_BACKEND=vulkan` or `DEMO_BACKEND=opengl`
  - Default: Vulkan

- **Two Execution Paths**:
  - **Native Path** (default): Uses `ANativeWindowCreator` to create windows
  - **Java Path** (optional): Uses `JavaFunc` for Java integration
    - Enable with: `-DUSE_JAVA_DEMO=ON` during CMake configuration

- **Demo Window**: Shows an ImGui window with:
  - "Hello, world!" text
  - Current backend information
  - Test texture loading status (attempts to load `/sdcard/test.png`)

## CMake Options

- `BUILD_DEMO=ON|OFF`: Build the demo executable (default: ON)
- `USE_JAVA_DEMO=ON|OFF`: Enable JavaFunc code path in demo (default: OFF)

## Running on Device

The demo requires:
- Android device with USB debugging enabled
- Appropriate permissions for overlay creation
- Some features may require root depending on SurfaceComposer access

The demo will:
1. Create a window or view
2. Initialize the selected graphics backend
3. Load system fonts
4. Display an ImGui demo window
5. Clean shutdown when window is closed

## Dependencies

The demo links against:
- AndroidImgui static library
- Android system libraries: `log`, `android`, `EGL`, `GLESv3`, `jnigraphics`, `z`, `dl`
- Vulkan (if available - uses dynamic loading logic)
- Optional: Freetype (for font support)

## Troubleshooting

- **Build fails**: Ensure ANDROID_NDK is set and points to a valid NDK installation
- **Runtime permissions**: Overlay creation may need root access depending on device
- **Backend not supported**: Some devices may not support Vulkan, try OpenGL with `--gl`
- **Missing fonts**: If Freetype is not available, font support will be limited