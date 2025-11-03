#include <iostream>
#include <string>
#include <cstring>
#include <cstdlib>
#include "ANativeWindowCreator.h"
#include "GraphicsManager.h"
#include "my_imgui.h"
#include "TouchHelperA.h"

#ifdef USE_JAVA_DEMO
#include "Jenv/JavaFunc.h"
#include <android/native_window_jni.h>
#include <thread>
#include <unistd.h>
#endif

GraphicsManager::GraphicsAPI getBackendFromArgs(int argc, char* argv[]) {
    // Check environment variable first
    const char* env_backend = std::getenv("DEMO_BACKEND");
    if (env_backend) {
        if (strcmp(env_backend, "gl") == 0 || strcmp(env_backend, "opengl") == 0) {
            return GraphicsManager::OPENGL;
        } else if (strcmp(env_backend, "vk") == 0 || strcmp(env_backend, "vulkan") == 0) {
            return GraphicsManager::VULKAN;
        }
    }
    
    // Check command line arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--gl") == 0 || strcmp(argv[i], "--opengl") == 0) {
            return GraphicsManager::OPENGL;
        } else if (strcmp(argv[i], "--vk") == 0 || strcmp(argv[i], "--vulkan") == 0) {
            return GraphicsManager::VULKAN;
        }
    }
    
    // Default to Vulkan
    return GraphicsManager::VULKAN;
}

#ifdef USE_JAVA_DEMO
int runJavaDemo(int argc, char* argv[]) {
    if (JavaFunc::init() < 0) {
        std::cerr << "JavaFunc init failed" << std::endl;
        return -1;
    }
    
    auto display = JavaFunc::getDisplayInfo();
    if (display.height > display.width) {
        std::swap(display.height, display.width);
    }
    
    jobject view = JavaFunc::getView(display.width, display.width, false, false);
    GraphicsManager::GraphicsAPI backend = getBackendFromArgs(argc, argv);
    
    std::thread([&] {
        jobject surface = nullptr;
        for (int i = 0; i < 5; i++) {
            sleep(1);
            surface = JavaFunc::getSurface(view);
            if (surface) {
                break;
            }
        }
        
        if (!surface) {
            std::cerr << "Failed to get surface after 5 attempts" << std::endl;
            JavaFunc::removeView(view);
            exit(1);
        }
        
        auto window = ANativeWindow_fromSurface(JavaFunc::GetJavaEnv(), surface);
        auto graphics = GraphicsManager::getGraphicsInterface(backend);
        
        if (!graphics->Init(window, display.width, display.width)) {
            std::cerr << "Graphics initialization failed" << std::endl;
            JavaFunc::removeView(view);
            exit(1);
        }
        
        ImGui::Android_LoadSystemFont(26);
        Touch::Init({(float)display.width, (float)display.height}, true);
        
        // Try to load a test texture
        auto* testTexture = graphics->LoadTextureFromFile("/sdcard/test.png");
        if (testTexture) {
            std::cout << "Loaded test texture from /sdcard/test.png" << std::endl;
        }
        
        static bool flag = true;
        while (flag) {
            graphics->NewFrame();
            Touch::setOrientation(JavaFunc::getDisplayInfo().orientation);
            ImGui::SetNextWindowSize({500, 500}, ImGuiCond_Once);
            
            if (ImGui::Begin("test", &flag)) {
                ImGui::Text("Hello, world!");
                ImGui::Text("Backend: %s", backend == GraphicsManager::VULKAN ? "Vulkan" : "OpenGL");
                
                if (testTexture) {
                    ImGui::Text("Test texture loaded successfully");
                }
            }
            ImGui::End();
            
            graphics->EndFrame();
        }
        
        if (testTexture) {
            graphics->DeleteTexture(testTexture);
        }
        
        graphics->Shutdown();
        JavaFunc::removeView(view);
        sleep(1);
        exit(0);
    }).detach();
    
    JavaFunc::loop();
    return 0;
}
#endif

int runNativeDemo(int argc, char* argv[]) {
    auto display = android::ANativeWindowCreator::GetDisplayInfo();
    if (display.height > display.width) {
        std::swap(display.height, display.width);
    }
    
    auto window = android::ANativeWindowCreator::Create("test", display.width, display.width);
    if (!window) {
        std::cerr << "Failed to create native window" << std::endl;
        return -1;
    }
    
    GraphicsManager::GraphicsAPI backend = getBackendFromArgs(argc, argv);
    auto graphics = GraphicsManager::getGraphicsInterface(backend);
    
    if (!graphics->Init(window, display.width, display.width)) {
        std::cerr << "Graphics initialization failed" << std::endl;
        return -1;
    }
    
    ImGui::Android_LoadSystemFont(26);
    Touch::Init({(float)display.width, (float)display.height}, true);
    
    // Try to load a test texture
    auto* testTexture = graphics->LoadTextureFromFile("/sdcard/test.png");
    if (testTexture) {
        std::cout << "Loaded test texture from /sdcard/test.png" << std::endl;
    }
    
    static bool flag = true;
    while (flag) {
        graphics->NewFrame();
        Touch::setOrientation(android::ANativeWindowCreator::GetDisplayInfo().orientation);
        ImGui::SetNextWindowSize({500, 500}, ImGuiCond_Once);
        
        if (ImGui::Begin("test", &flag)) {
            ImGui::Text("Hello, world!");
            ImGui::Text("Backend: %s", backend == GraphicsManager::VULKAN ? "Vulkan" : "OpenGL");
            
            if (testTexture) {
                ImGui::Text("Test texture loaded successfully");
            }
        }
        ImGui::End();
        
        graphics->EndFrame();
    }
    
    if (testTexture) {
        graphics->DeleteTexture(testTexture);
    }
    
    graphics->Shutdown();
    return 0;
}

int main(int argc, char* argv[]) {
    std::cout << "AndroidImgui Demo starting..." << std::endl;
    
#ifdef USE_JAVA_DEMO
    return runJavaDemo(argc, argv);
#else
    return runNativeDemo(argc, argv);
#endif
}