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

if(NOT TOOLS_ADDED)
set(TOOLS_ADDED ON)

# Generates a 'format' target using a custom name, files, and include directories all being parameters.
#
# FORMAT_TARGET_NAME - The name of the target to create. If it's a real target name, then the files for it will
#   be inherited, and the target name will have the prefix of 'format_' added.
# ARGN - The list of files to format
#
# Do note that in order for sources to be inherited properly, the source paths must be reachable from where the macro
# is called, or otherwise require a full path for proper inheritance.
find_program(CLANG_FORMAT_EXE "clang-format")
if (CLANG_FORMAT_EXE)
    message(STATUS "clang-format found: ${CLANG_FORMAT_EXE}")
else()
    message(STATUS "clang-format not found!")
endif()
function(_ClangFormat FORMAT_TARGET_NAME)
    if(CLANG_FORMAT)
        if(TARGET ${FORMAT_TARGET_NAME})
            get_target_property(_TARGET_TYPE ${FORMAT_TARGET_NAME} TYPE)
            # Add target sources
            if(NOT _TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
                get_property(_TEMP
                    TARGET ${FORMAT_TARGET_NAME}
                    PROPERTY SOURCES
                )
                foreach(iter IN LISTS _TEMP)
                    if(EXISTS ${iter})
                        set(FORMAT_CODE_FILES "${FORMAT_CODE_FILES}" "${iter}")
                    elseif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${iter})
                        set(TIDY_CODE_FILES "${FORMAT_CODE_FILES}" "${CMAKE_CURRENT_SOURCE_DIR}/${iter}")
                    endif()
                endforeach()
            endif()

            set(FORMAT_TARGET_NAME format_${FORMAT_TARGET_NAME})
        endif()

        add_custom_target(
            ${FORMAT_TARGET_NAME}
            COMMAND clang-format
            -i
            -style=file
            ${ARGN} ${FORMAT_CODE_FILES}
        )

        if(NOT TARGET format)
            add_custom_target(format)
        endif()

        add_dependencies(format ${FORMAT_TARGET_NAME})
    endif()
endfunction()


##############
# clang-tidy #
##############
option(NO_CLANG_TIDY "Turns off clang-tidy processing if it is found." OFF)

find_program (CLANG_TIDY_EXE NAMES "clang-tidy")
if (CLANG_TIDY_EXE)
    message(STATUS "clang-tidy found: ${CLANG_TIDY_EXE}")
    if(NOT NO_CLANG_TIDY)
        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE};-format-style=file;-header-filter='${CMAKE_SOURCE_DIR}/*'" CACHE STRING "" FORCE)
    else()
        message(STATUS "clang-tidy DISABLED via 'NO_CLANG_TIDY' variable!")
    endif()
else()
    message(STATUS "clang-tidy not found!")
    set(CMAKE_CXX_CLANG_TIDY "" CACHE STRING "" FORCE) # delete it
endif()

########################
# include what you use #
########################
option(ADD_IWYU "Turns on include-what-you-use processing if it is found." OFF)

find_program(IWYU_EXE NAMES "include-what-you-use")
if (IWYU_EXE)
    message(STATUS "include-what-you-use found: ${IWYU_EXE}")
    if(ADD_IWYU)
        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${IWYU_EXE};-Xiwyu;" CACHE STRING "" FORCE)
    else()
        message(STATUS "include-what-you-use NOT_ENABLED via 'ADD_IWYU' variable!")
    endif()
else()
    message(STATUS "include-what-you-use not found!")
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "" CACHE STRING "" FORCE) # delete it
endif()

############
# cppcheck #
############
option(ADD_CPPCHECK "Turns on cppcheck processing if it is found." OFF)

find_program(CPPCHECK_EXE NAMES "cppcheck")
if (CPPCHECK_EXE)
    message(STATUS "cppcheck found: ${CPPCHECK_EXE}")
    if(ADD_CPPCHECK)
        set(CMAKE_CXX_CPPCHECK "${CPPCHECK_EXE};--enable=warning,performance,portability,missingInclude;--template=\"[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)\";--suppress=missingIncludeSystem;--quiet;--verbose;--force" CACHE STRING "" FORCE)
    else()
        message(STATUS "cppcheck NOT ENABLED via 'ADD_CPPCHECK' variable!")
    endif()
else()
    message(STATUS "cppcheck not found!")
    set(CMAKE_CXX_CPPCHECK "" CACHE STRING "" FORCE) # delete it
endif()

endif()