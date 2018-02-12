# Copyright 2018 Stable Tec
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function(_CheckUnix)
    if (NOT UNIX)
        message(FATAL_ERROR "Error: ${ARGV0} requires a Unix environment.")
    endif()
endfunction()

function(_CheckClang)
    if (NOT ("${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang"))
        message(FATAL_ERROR "Error: ${ARGV0} requires the clang compiler.")
    endif()
endfunction()

# Build Types
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}
    CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel tsan asan lsan msan ubsan"
    FORCE)

# ThreadSanitizer
set(CMAKE_C_FLAGS_TSAN
    "-fsanitize=thread -g -O1"
    CACHE STRING "Flags used by the C compiler during ThreadSanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_TSAN
    "-fsanitize=thread -g -O1"
    CACHE STRING "Flags used by the C++ compiler during ThreadSanitizer builds."
    FORCE)

# AddressSanitize
set(CMAKE_C_FLAGS_ASAN
    "-fsanitize=address -fno-optimize-sibling-calls -fsanitize-address-use-after-scope -fno-omit-frame-pointer -g -O1"
    CACHE STRING "Flags used by the C compiler during AddressSanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_ASAN
    "-fsanitize=address -fno-optimize-sibling-calls -fsanitize-address-use-after-scope -fno-omit-frame-pointer -g -O1"
    CACHE STRING "Flags used by the C++ compiler during AddressSanitizer builds."
    FORCE)

# LeakSanitizer
set(CMAKE_C_FLAGS_LSAN
    "-fsanitize=leak -fno-omit-frame-pointer -g -O1"
    CACHE STRING "Flags used by the C compiler during LeakSanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_LSAN
    "-fsanitize=leak -fno-omit-frame-pointer -g -O1"
    CACHE STRING "Flags used by the C++ compiler during LeakSanitizer builds."
    FORCE)

# MemorySanitizer
set(CMAKE_C_FLAGS_MSAN
    "-fsanitize=memory -fno-optimize-sibling-calls -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer -g -O2"
    CACHE STRING "Flags used by the C compiler during MemorySanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_MSAN
    "-fsanitize=memory -fno-optimize-sibling-calls -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer -g -O2"
    CACHE STRING "Flags used by the C++ compiler during MemorySanitizer builds."
    FORCE)

# UndefinedBehaviour
set(CMAKE_C_FLAGS_UBSAN
    "-fsanitize=undefined"
    CACHE STRING "Flags used by the C compiler during UndefinedBehaviourSanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_UBSAN
    "-fsanitize=undefined"
    CACHE STRING "Flags used by the C++ compiler during UndefinedBehaviourSanitizer builds."
    FORCE)

if(CMAKE_BUILD_TYPE STREQUAL "tsan")
    # Thread Sanitizer
    message("Building for ThreadSanitizer")
    _CheckUnix(CMAKE_BUILD_TYPE)

elseif(CMAKE_BUILD_TYPE STREQUAL "asan")
    # Address Sanitizer (also Leak Sanitizer)
    message("Building for AddressSanitizer (with LeakSanitizer)")
    _CheckUnix()

elseif(CMAKE_BUILD_TYPE STREQUAL "lsan")
    # Leak Sanitizer (Standalone)
    message("Building for LeakSanitizer")
    _CheckUnix(CMAKE_BUILD_TYPE)

elseif(CMAKE_BUILD_TYPE STREQUAL "msan")
    # Memory Sanitizer
    message("Building for MemorySanitizer")
    _CheckUnix(CMAKE_BUILD_TYPE)
    _CheckClang(CMAKE_BUILD_TYPE)

elseif(CMAKE_BUILD_TYPE STREQUAL "ubsan")
    # Undefined Behaviour Sanitizer
    message("Building for UndefinedBehaviourSanitizer")
    _CheckUnix(CMAKE_BUILD_TYPE)

else()
    if(UNIX)
        # If running on Linux, then enable the build types for the clang-based sanitizer tools
        message("On Unix, there are extra build configurations:")
        message("tsan : ThreadSanitizer")
        message("asan : AddressSanitizer")
        message("lsan : LeakSanitizer")
        message("msan : MemorySanitizer (Clang only)")
        message("ubsan : UndefinedBehaviourSanitizer")
    else()
        message("To enable sanitizer tools, run in a Unix environment.")
    endif()
endif()