cmake_minimum_required(VERSION 3.16)
project(SmartCacheSimulator VERSION 1.0.0 LANGUAGES CXX)

# ── C++ Standard ──────────────────────────────────────────────────────────────
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ── Compiler Warnings ─────────────────────────────────────────────────────────
if (MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Wshadow -Wno-unused-parameter)
endif()

# ── Include Paths ─────────────────────────────────────────────────────────────
include_directories(${PROJECT_SOURCE_DIR}/include)

# ── Source Files ──────────────────────────────────────────────────────────────
set(SOURCES
    src/main.cpp
    src/DataItem.cpp
    src/CacheManager.cpp
)

# ── Executable ────────────────────────────────────────────────────────────────
add_executable(SmartCacheSimulator ${SOURCES})

# ── Installation ─────────────────────────────────────────────────────────────
install(TARGETS SmartCacheSimulator DESTINATION bin)

# ── Optional: Release/Debug Build Types ──────────────────────────────────────
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

message(STATUS "Build type  : ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ standard: C++${CMAKE_CXX_STANDARD}")
