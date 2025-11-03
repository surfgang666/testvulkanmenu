@echo off
setlocal enabledelayedexpansion

:: Build script for AndroidImgui demo
:: Prerequisites: ANDROID_NDK environment variable set, cmake in PATH

:: Check prerequisites
if "%ANDROID_NDK%"=="" (
    echo Error: ANDROID_NDK environment variable not set
    echo.
    echo You can set it now temporarily for this script, or set it system-wide and restart the command prompt.
    echo.
    set /p ANDROID_NDK_INPUT="Enter the path to Android NDK (or press Enter to exit): "
    if "!ANDROID_NDK_INPUT!"=="" (
        exit /b 1
    )
    set ANDROID_NDK=!ANDROID_NDK_INPUT!
)

where cmake >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: cmake not found in PATH
    exit /b 1
)

:: Build configuration
set BUILD_DIR=build-android
set ANDROID_ABI=arm64-v8a
set ANDROID_PLATFORM=android-24

echo Building AndroidImgui demo...
echo NDK: %ANDROID_NDK%
echo Build directory: %BUILD_DIR%
echo Target ABI: %ANDROID_ABI%
echo Platform: %ANDROID_PLATFORM%

:: Get script directory and move to project root
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."

:: Clean previous build if exists
if exist "%BUILD_DIR%" (
    echo Cleaning previous build...
    rmdir /s /q "%BUILD_DIR%"
)

:: Configure CMake
echo Configuring CMake...

:: Try Ninja first (faster), fallback to MSBuild
where ninja >nul 2>&1
if %errorlevel% equ 0 (
    echo Using Ninja generator...
    cmake -S . -B "%BUILD_DIR%" ^
        -DANDROID_ABI="%ANDROID_ABI%" ^
        -DANDROID_PLATFORM="%ANDROID_PLATFORM%" ^
        -DCMAKE_TOOLCHAIN_FILE="%ANDROID_NDK%\build\cmake\android.toolchain.cmake" ^
        -DBUILD_DEMO=ON ^
        -DCMAKE_BUILD_TYPE=Release ^
        -G "Ninja"
    
    if %errorlevel% neq 0 exit /b %errorlevel%
    
    echo Building demo with Ninja...
    cmake --build "%BUILD_DIR%" -j%NUMBER_OF_PROCESSORS%
) else (
    echo Ninja not found, using MSBuild generator...
    cmake -S . -B "%BUILD_DIR%" ^
        -DANDROID_ABI="%ANDROID_ABI%" ^
        -DANDROID_PLATFORM="%ANDROID_PLATFORM%" ^
        -DCMAKE_TOOLCHAIN_FILE="%ANDROID_NDK%\build\cmake\android.toolchain.cmake" ^
        -DBUILD_DEMO=ON ^
        -DCMAKE_BUILD_TYPE=Release
    
    if %errorlevel% neq 0 exit /b %errorlevel%
    
    echo Building demo with MSBuild...
    cmake --build "%BUILD_DIR%" --config Release
)

if %errorlevel% neq 0 exit /b %errorlevel%

:: Check if binary was created
set DEMO_BINARY=%BUILD_DIR%\testvulkanmenu_demo.exe
if exist "%DEMO_BINARY%" (
    echo ✓ Demo binary built successfully: %DEMO_BINARY%
    for %%F in ("%DEMO_BINARY%") do echo Binary size: %%~zF bytes
) else (
    echo ✗ Demo binary not found after build
    exit /b 1
)

echo Build completed successfully!
endlocal