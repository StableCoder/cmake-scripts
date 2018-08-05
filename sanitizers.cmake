#
# Copyright (C) 2018 by George Cave - gcave@stablecoder.ca
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

set(USE_SANITIZER "" CACHE STRING
"Compile with a sanitizer. Options are: Address, Memory, MemoryWithOrigins, Undefined, Thread, Leak, 'Address;Undefined'")

function(append value)
  foreach(variable ${ARGN})
    set(${variable} "${${variable}} ${value}" PARENT_SCOPE)
  endforeach(variable)
endfunction()

if(NOT SANITIZERS_ADDED)
    set(SANITIZERS_ADDED ON)

    if(USE_SANITIZER)
        append("-fno-omit-frame-pointer" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)

        if (UNIX)

            if (uppercase_CMAKE_BUILD_TYPE STREQUAL "DEBUG")
                append("-O1" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
            endif()
            
            if (USE_SANITIZER STREQUAL "Address")
                # Optional: -fno-optimize-sibling-calls -fsanitize-address-use-after-scope
                append("-fsanitize=address" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
            elseif (USE_SANITIZER MATCHES "Memory(WithOrigins)?")
                # Optional: -fno-optimize-sibling-calls -fsanitize-memory-track-origins=2
                append("-fsanitize=memory" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
                if(USE_SANITIZER STREQUAL "MemoryWithOrigins")
                    append("-fsanitize-memory-track-origins" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
                endif()
            elseif (USE_SANITIZER STREQUAL "Undefined")
                append("-fsanitize=undefined" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
                if (EXISTS "${BLACKLIST_FILE}")
                    append("-fsanitize-blacklist=${BLACKLIST_FILE}" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
                endif()
            elseif (USE_SANITIZER STREQUAL "Thread")
                append("-fsanitize=thread" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
            elseif (USE_SANITIZER STREQUAL "Address;Undefined" OR USE_SANITIZER STREQUAL "Undefined;Address")
                append("-fsanitize=address,undefined" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
            elseif (USE_SANITIZER STREQUAL "Leak")
                append("-fsanitize=leak" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
            else()
                message(FATAL_ERROR "Unsupported value of USE_SANITIZER: ${USE_SANITIZER}")
            endif()
        elseif(MSVC)
            if (USE_SANITIZER STREQUAL "Address")
                append("-fsanitize=address" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
            else()
                message(FATAL_ERROR "This sanitizer not yet supported in the MSVC environment: ${USE_SANITIZER}")
            endif()
        else()
            message(FATAL_ERROR "USE_SANITIZER is not supported on this platform.")
        endif()

    endif()

endif()