cmake_minimum_required(VERSION 3.22)

project(AndroidImgui)

set(CMAKE_CXX_STANDARD 20)

# Demo build options
option(BUILD_DEMO "Build demo executable" ON)
option(USE_JAVA_DEMO "Enable JavaFunc code path in demo" OFF)

# Android-specific configuration (only when cross-compiling for Android)
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    # Set Android-specific properties
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    
    # Add freetype if available (as submodule or system)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/freetype/CMakeLists.txt")
        add_subdirectory(freetype)
        include_directories(freetype/include)
        set(FREETYPE_TARGET freetype)
    else()
        # Try to find system freetype
        find_package(Freetype QUIET)
        if(FREETYPE_FOUND)
            include_directories(${FREETYPE_INCLUDE_DIRS})
            set(FREETYPE_TARGET Freetype::Freetype)
        else()
            message(WARNING "Freetype not found. Font support may be limited.")
            set(FREETYPE_TARGET "")
        endif()
    endif()
    
    # Android-specific compile definitions
    set(ANDROID_COMPILE_DEFINITIONS
        VK_USE_PLATFORM_ANDROID_KHR
        IMGUI_IMPL_VULKAN_NO_PROTOTYPES
        IMGUI_ENABLE_FREETYPE
    )
else()
    # Non-Android build (for testing purposes)
    message(STATUS "Building for non-Android system (testing mode)")
    
    # Try to find freetype on the system
    find_package(Freetype QUIET)
    if(FREETYPE_FOUND)
        include_directories(${FREETYPE_INCLUDE_DIRS})
        set(FREETYPE_TARGET Freetype::Freetype)
    else()
        message(WARNING "Freetype not found. Font support may be limited.")
        set(FREETYPE_TARGET "")
    endif()
    
    # Non-Android compile definitions
    set(ANDROID_COMPILE_DEFINITIONS
        IMGUI_IMPL_VULKAN_NO_PROTOTYPES
        IMGUI_ENABLE_FREETYPE
    )
endif()

file(GLOB SOURCES src/*.cpp)

# Add ImGui sources if available
set(IMGUI_SOURCES "")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui.cpp")
    list(APPEND IMGUI_SOURCES
        imgui/imgui.cpp
        imgui/imgui_draw.cpp
        imgui/imgui_widgets.cpp
        imgui/imgui_tables.cpp
        imgui/imgui_demo.cpp
        imgui/backends/imgui_impl_opengl3.cpp
        imgui/backends/imgui_impl_vulkan.cpp
        imgui/misc/freetype/imgui_freetype.cpp
    )
    
    # Add ImGui include directories
    set(IMGUI_INCLUDE_DIRS
        imgui
        imgui/backends
    )
else()
    message(WARNING "ImGui not found. Please initialize git submodules.")
endif()

add_library(AndroidImgui STATIC
        ${SOURCES}
        ${IMGUI_SOURCES}

        stb/stb_image.c
        src/ELF/elf_util.cpp
        src/Jenv/JavaFunc.cpp
)

target_include_directories(AndroidImgui PUBLIC
        src
        ${IMGUI_INCLUDE_DIRS}
        stb
)

target_compile_definitions(AndroidImgui PUBLIC
        ${ANDROID_COMPILE_DEFINITIONS})

target_link_libraries(AndroidImgui
        ${FREETYPE_TARGET}
    )

# Android-specific libraries for main library
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    target_link_libraries(AndroidImgui
        log
        android
        EGL
        GLESv3
        z
    )
endif()

# Demo executable
if(BUILD_DEMO)
    add_executable(testvulkanmenu_demo
        examples/main.cpp
    )
    
    target_include_directories(testvulkanmenu_demo PRIVATE
        src
        ${IMGUI_INCLUDE_DIRS}
        stb
    )
    
    target_compile_definitions(testvulkanmenu_demo PRIVATE
        ${ANDROID_COMPILE_DEFINITIONS}
    )
    
    if(USE_JAVA_DEMO)
        target_compile_definitions(testvulkanmenu_demo PRIVATE USE_JAVA_DEMO)
        target_sources(testvulkanmenu_demo PRIVATE
            src/Jenv/JavaFunc.cpp
        )
    endif()
    
    target_link_libraries(testvulkanmenu_demo
        AndroidImgui
    )
    
    # Android-specific libraries
    if (CMAKE_SYSTEM_NAME STREQUAL "Android")
        target_link_libraries(testvulkanmenu_demo
            log
            android
            EGL
            GLESv3
            jnigraphics
            z
            dl
        )
        
        # Link Vulkan if available (keep dynamic-load logic intact)
        find_library(VULKAN_LIBRARY vulkan)
        if(VULKAN_LIBRARY)
            target_link_libraries(testvulkanmenu_demo ${VULKAN_LIBRARY})
        endif()
    endif()
endif()


#[[add_executable(AndroidImguiTest
        test/main3.cpp
        test/TouchHelperA.cpp)

target_link_libraries(AndroidImguiTest
        AndroidImgui
)]]


#[[git submodule update --remote imgui]]
