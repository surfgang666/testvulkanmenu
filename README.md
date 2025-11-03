# testvulkanmenu

C++20 static library for rendering ImGui overlays on Android native windows using Vulkan or OpenGL ES.

## Features

- Vulkan and OpenGL ES graphics backends
- Android native window creation and management
- ImGui integration with touch input
- Font loading with Freetype support
- Texture loading and management
- Java runtime integration via JNI

## Quick Start

### Building the Demo

```bash
# Set Android NDK path
export ANDROID_NDK=/path/to/android-ndk

# Build and run demo
./scripts/build_demo.sh
./scripts/run_demo.sh --vk  # or --gl for OpenGL
```

### Building the Library

```bash
cmake -S . -B build-android \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-24 \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake

cmake --build build-android
```

## Documentation

See `DEMO_README.md` for detailed demo usage and build instructions.

## Dependencies

- Android NDK
- CMake 3.22+
- ImGui (submodule)
- Freetype (optional, for font support)
- Vulkan/OpenGL ES drivers