@echo off
setlocal enabledelayedexpansion

:: Run script for AndroidImgui demo
:: Prerequisites: adb in PATH, Android device connected with debug permissions

:: Check prerequisites
where adb >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: adb not found in PATH
    echo Install Android SDK platform-tools or add adb to PATH
    exit /b 1
)

:: Check if device is connected
adb get-state >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: No Android device connected
    echo Connect a device and enable USB debugging
    exit /b 1
)

:: Configuration
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."
set BUILD_DIR=build-android
set DEMO_BINARY=%BUILD_DIR%\testvulkanmenu_demo.exe
set REMOTE_PATH=/data/local/tmp/testvulkanmenu_demo
set LOG_PATH=/sdcard/testvulkanmenu_demo.log

:: Check if demo binary exists
if not exist "%DEMO_BINARY%" (
    echo Error: Demo binary not found at %DEMO_BINARY%
    echo Run .\scripts\build_demo.bat first
    exit /b 1
)

:: Parse command line arguments
set BACKEND_ARGS=
if "%~1"=="--vk" set BACKEND_ARGS=--vk
if "%~1"=="--vulkan" set BACKEND_ARGS=--vk
if "%~1"=="--gl" set BACKEND_ARGS=--gl
if "%~1"=="--opengl" set BACKEND_ARGS=--gl

if "%BACKEND_ARGS%"=="--vk" (
    echo Using Vulkan backend
) else if "%BACKEND_ARGS%"=="--gl" (
    echo Using OpenGL backend
) else (
    echo Using default Vulkan backend
    set BACKEND_ARGS=--vk
)

:: Get device info
echo Connected device:
for /f "tokens=*" %%i in ('adb shell getprop ro.product.model') do echo %%i
for /f "tokens=*" %%i in ('adb shell getprop ro.build.version.release') do echo Android %%i
echo Display info:
adb shell wm size 2>nul || echo Could not get display size

:: Push binary to device
echo Pushing demo binary to device...
adb push "%DEMO_BINARY%" "%REMOTE_PATH%"
adb shell chmod 755 "%REMOTE_PATH%"

:: Clear previous log
adb shell rm -f "%LOG_PATH%" 2>nul

:: Run the demo
echo Starting demo on device...
echo Note: Overlay creation may require root depending on SurfaceComposer access
echo Log will be saved to: %LOG_PATH%

:: Run with output redirection
adb shell "%REMOTE_PATH% %BACKEND_ARGS%" 2>&1 | adb shell "cat > %LOG_PATH%" || (
    echo Demo execution completed or failed
)

:: Show log location
echo Demo log saved to device at: %LOG_PATH%
echo To view log: adb shell cat %LOG_PATH%
echo To pull log: adb pull %LOG_PATH%

:: Cleanup
echo Cleaning up remote binary...
adb shell rm -f "%REMOTE_PATH%"

echo Run script completed!
endlocal