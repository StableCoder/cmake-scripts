cmake_minimum_required(VERSION 3.10)
project(code-coverage-hook C CXX)

# Set the searching location for cmake 'include' locations
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../..;")
# Include the code coverage module
cmake_policy(SET CMP0077 NEW)

set(CCOV_TARGETS_HOOK ON)
set(CCOV_TARGETS_HOOK_ARGS "ALL")

include(code-coverage)

# Require C++11
include(c++-standards)
cxx_11()
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# This introduces the 'ccov-all' targets Also excludes the main file via a regex
add_code_coverage_all_targets(EXCLUDE coverage.main.cpp)

# The library
add_library(lib ../src/coverage.cpp)

# The executable
add_executable(main ../src/coverage.main.cpp)
target_link_libraries(main PUBLIC lib)

# The second executable
add_executable(main2 ../src/coverage.main.cpp)
target_link_libraries(main2 PUBLIC lib)
