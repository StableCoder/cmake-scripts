cmake_minimum_required(VERSION 3.10)
project(sanitizer-tests C CXX)

# Set the searching location for cmake 'include' locations
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../..;")

include(c++-standards)
include(code-coverage)
include(formatting)
include(sanitizers)
include(tools)
include(dependency-graph)

# Require C++11
cxx_11()

# Tools
file(GLOB_RECURSE FFILES *.[hc] *.[hc]pp)
clang_format(format ${FFILES})

cmake_format(cmake-format ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
             CMakeLists.txt)

clang_tidy(-format-style=file -checks=* -header-filter='${CMAKE_SOURCE_DIR}/*')
include_what_you_use(-Xiwyu)
cppcheck(
  --enable=warning,performance,portability,missingInclude
  --template="[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)"
  --suppress=missingIncludeSystem --quiet --verbose --force)

enable_testing()

# Fails with ThreadSanitizer
add_executable(tsanFail ../src/tsan_fail.cpp)
target_code_coverage(tsanFail AUTO ALL)
if(UNIX)
  target_link_libraries(tsanFail PUBLIC pthread)
endif()
add_test(tsan tsanFail)

# Fails with LeakSanitizer
add_executable(lsanFail ../src/lsan_fail.c)
target_code_coverage(lsanFail AUTO ALL)
add_test(lsan lsanFail)

# Fails with AddressSanitizer
if(USE_SANITIZER MATCHES "[Aa]ddress")
  add_executable(asanFail ../src/asan_fail.cpp)
  target_code_coverage(asanFail AUTO ALL)
  add_test(asan asanFail)
endif()

# Fails with MemorySanitizer
add_executable(msanFail ../src/msan_fail.cpp)
target_code_coverage(msanFail AUTO ALL)
add_test(msan msanFail)

# Fails with UndefinedBehaviourSanitizer
add_executable(ubsanFail ../src/ubsan_fail.cpp)
target_code_coverage(ubsanFail AUTO ALL)
add_test(ubsan ubsanFail)
