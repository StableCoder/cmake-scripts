cmake_minimum_required(VERSION 3.10)
project(code-covare-all C CXX)

# Set the searching location for cmake 'include' locations
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../..;")
# Include the sanitizer module
include(code-coverage)

# Require C++11
include(c++-standards)
cxx_11()
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# The library
add_library(lib ../src/coverage.cpp)

# Instruments the library
target_code_coverage(lib AUTO)

# The executable
add_executable(main ../src/coverage.main.cpp)
target_link_libraries(main PUBLIC lib)

# Adds the executable to the 'ccov' target
target_code_coverage(main AUTO EXTERNAL)
