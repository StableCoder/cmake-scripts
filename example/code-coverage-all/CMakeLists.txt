cmake_minimum_required(VERSION 3.10)
project(code-coverage-all C CXX)

# Set the searching location for cmake 'include' locations
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../..;")
# Include the code coverage module
include(code-coverage)

# Require C++11
include(c++-standards)
cxx_11()
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# This introduces the 'ccov-all' targets Also excludes the main file via a regex
add_code_coverage_all_targets(EXCLUDE coverage.main.cpp)

# The library
add_library(lib ../src/coverage.cpp)

# Instruments the library
target_code_coverage(lib AUTO ALL)

# The executable
add_executable(main ../src/coverage.main.cpp)
target_link_libraries(main PUBLIC lib)

# Adds the executable to the 'ccov' and 'ccov-all' targets and excludes the file
# itself via regex
target_code_coverage(main AUTO ALL EXTERNAL)

# The second executable
add_executable(main2 ../src/coverage.main.cpp)
target_link_libraries(main2 PUBLIC lib)

# Adds the executable to the 'ccov' and 'ccov-all' targets and excludes the file
# itself via regex
target_code_coverage(main2 AUTO ALL EXTERNAL)
