cmake_minimum_required(VERSION 3.10)
project(sanitizer-tests C CXX)

# Set the searching location for cmake 'include' locations
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../..;")

include(c++-standards)
include(code-coverage)
include(formatting)
include(tools)
include(dependency-graph)

# Require C++11
cxx_11()

# Tools
if(UNIX AND NOT APPLE)
  file(GLOB_RECURSE FFILES *.[hc] *.[hc]pp)
  clang_format(format ${FFILES})

  cmake_format(cmake-format ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
               CMakeLists.txt)

  clang_tidy(-format-style=file -checks=*
             -header-filter='${CMAKE_SOURCE_DIR}/*')
  include_what_you_use(-Xiwyu)
  cppcheck(
    --enable=warning,performance,portability,missingInclude
    --template="[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)"
    --suppress=missingIncludeSystem --quiet --verbose --force)
endif()

enable_testing()

# Sanitizers
include(sanitizers)

set_sanitizer_options(address DEFAULT -fsanitize-address-use-after-scope
                      -fsanitize-address-use-after-return=runtime)
set_sanitizer_options(leak DEFAULT)
set_sanitizer_options(memory DEFAULT)
set_sanitizer_options(memorywithorigins DEFAULT SANITIZER memory
                      -fsanitize-memory-track-origins)
set_sanitizer_options(undefined DEFAULT)
set_sanitizer_options(thread DEFAULT)

set(EXAMPLE_USE_SANITIZER
    ""
    CACHE STRING "Sanitizer to use with examples")

if(EXAMPLE_USE_SANITIZER)
  add_sanitizer_support(${EXAMPLE_USE_SANITIZER})
endif()

# Fails with ThreadSanitizer
add_executable(tsanFail ../src/tsan_fail.cpp)
target_code_coverage(tsanFail AUTO ALL)
if(UNIX)
  target_link_libraries(tsanFail PUBLIC pthread)
endif()
add_test(tsan tsanFail)

# Fails with LeakSanitizer
add_executable(lsan_direct_leak ../src/lsan/direct_leak.c)
target_code_coverage(lsan_direct_leak AUTO ALL)
add_test(lsan_direct_leak lsan_direct_leak)

add_executable(lsan_indirect_leak ../src/lsan/indirect_leak.c)
target_code_coverage(lsan_indirect_leak AUTO ALL)
add_test(lsan_indirect_leak lsan_indirect_leak)

# Fails with AddressSanitizer
if(EXAMPLE_USE_SANITIZER STREQUAL "address")
  # double-free now has solid detection without sanitizers too
  add_executable(asan_double_free ../src/asan/double_free.c)
  target_code_coverage(asan_double_free AUTO ALL)
  add_test(asan_double_free asan_double_free)
endif()

add_executable(asan_out_of_bounds_global ../src/asan/out_of_bounds_global.c)
target_code_coverage(asan_out_of_bounds_global AUTO ALL)
add_test(asan_out_of_bounds_global asan_out_of_bounds_global)

add_executable(asan_out_of_bounds_heap ../src/asan/out_of_bounds_heap.c)
target_code_coverage(asan_out_of_bounds_heap AUTO ALL)
add_test(asan_out_of_bounds_heap asan_out_of_bounds_heap)

add_executable(asan_out_of_bounds_stack ../src/asan/out_of_bounds_stack.c)
target_code_coverage(asan_out_of_bounds_stack AUTO ALL)
add_test(asan_out_of_bounds_stack asan_out_of_bounds_stack)

add_executable(asan_use_after_free ../src/asan/use_after_free.c)
target_code_coverage(asan_use_after_free AUTO ALL)
add_test(asan_use_after_free asan_use_after_free)

add_executable(asan_use_after_return ../src/asan/use_after_return.c)
target_code_coverage(asan_use_after_return AUTO ALL)
add_test(asan_use_after_return asan_use_after_return)

add_executable(asan_use_after_scope ../src/asan/use_after_scope.c)
target_code_coverage(asan_use_after_scope AUTO ALL)
add_test(asan_use_after_scope asan_use_after_scope)

# Fails with MemorySanitizer
add_executable(msanFail ../src/msan_fail.cpp)
target_code_coverage(msanFail AUTO ALL)
add_test(msan msanFail)

# Fails with UndefinedBehaviourSanitizer
add_executable(ubsanFail ../src/ubsan_fail.cpp)
target_code_coverage(ubsanFail AUTO ALL)
add_test(ubsan ubsanFail)
