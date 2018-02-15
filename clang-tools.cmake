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

# Recursively runs through the given target and its libraries, collecting the include directories.
#
# _RETURN_VAR The variable that will return the include directories
# _TARGET_NAME Name of the target that will be processed.
macro(_GetLibraryIncludeDirectories _RETURN_VAR _TARGET_NAME)
    if(TARGET ${_TARGET_NAME})
        get_target_property(_TARGET_TYPE ${_TARGET_NAME} TYPE)

        # Run through libraries
        if(_TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
            get_property(_TEMP
                TARGET ${_TARGET_NAME}
                PROPERTY INTERFACE_LINK_LIBRARIES
            )
        else()
            get_property(_TEMP
                TARGET ${_TARGET_NAME}
                PROPERTY LINK_LIBRARIES
            )
        endif()
        foreach(iter IN LISTS _TEMP)
            _GetLibraryIncludeDirectories(_TEMP_VAR ${iter})
            foreach(iter IN LISTS _TEMP_VAR)
                set(_LOCAL_VAR ${_LOCAL_VAR} ${iter})
            endforeach()
        endforeach()

        # This target includes
        get_target_property(_TARGET_TYPE ${_TARGET_NAME} TYPE)
        if(_TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
            get_property(_TEMP
                TARGET ${_TARGET_NAME}
                PROPERTY INTERFACE_INCLUDE_DIRECTORIES
            )
        else()
            get_property(_TEMP
                TARGET ${_TARGET_NAME}
                PROPERTY INCLUDE_DIRECTORIES
            )
        endif()
        foreach(iter IN LISTS _TEMP)
            set(_LOCAL_VAR ${_LOCAL_VAR} ${_TEMP})
        endforeach()
        set(${_RETURN_VAR} ${_LOCAL_VAR})
    endif()
endmacro()

# Generates a 'format' target using a custom name, files, and include directories all being parameters.
#
# FORMAT_TARGET_NAME - The name of the target to create. If it's a real target name, then the files for it will
#   be inherited, and the target name will have the suffix of '_format' added.
# ARGN - The list of files to format
#
# Do note that in order for sources to be inherited properly, the source paths must be reachable from where the macro
# is called, or otherwise require a full path for proper inheritance.
function(_ClangFormat FORMAT_TARGET_NAME)
    if(NOT CLANG_FORMAT)
        find_program(CLANG_FORMAT "clang-format")
    endif()
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

            set(FORMAT_TARGET_NAME ${FORMAT_TARGET_NAME}_format)
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

# Generates a 'tidy' target using a custom name, files, and include directories all being parameters.
#
# TIDY_TARGET_NAME - The name of the target to create. If it's a real target name, then the files for it will
#   be inherited, and the include directories as well, and the target name will have the suffix of '_tidy' added.
# ARGN - The list of files to process, and any items prefixed by '-I' will become an include directory instead.
#
# Do note that in order for sources to be inherited properly, the source paths must be reachable from where the macro
# is called, or otherwise require a full path for proper inheritance.
function(_ClangTidy TIDY_TARGET_NAME)
    if(NOT CLANG_TIDY)
        find_program(CLANG_TIDY "clang-tidy")
    endif()
    if(CLANG_TIDY)
        # Process the target if it is a real target files attached with it.
        if(TARGET ${TIDY_TARGET_NAME})
            get_target_property(_TARGET_TYPE ${TIDY_TARGET_NAME} TYPE)
            # Sources
            if(NOT _TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
                get_property(_TEMP
                    TARGET ${TIDY_TARGET_NAME}
                    PROPERTY SOURCES
                )
                foreach(iter IN LISTS _TEMP)
                    if(EXISTS ${iter})
                        set(TIDY_CODE_FILES "${TIDY_CODE_FILES}" "${iter}")
                    elseif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${iter})
                        set(TIDY_CODE_FILES "${TIDY_CODE_FILES}" "${CMAKE_CURRENT_SOURCE_DIR}/${iter}")
                    endif()
                endforeach()
            endif()

            # Includes
            _GetLibraryIncludeDirectories(_TEMP ${TIDY_TARGET_NAME})
            foreach(iter IN LISTS _TEMP)
                    set(TIDY_INCLUDE_DIRS "${TIDY_INCLUDE_DIRS}" "-I${iter}")
            endforeach()

            set(TIDY_TARGET_NAME ${TIDY_TARGET_NAME}_tidy)
        endif()

        # Go through the parameters and figure out which are code files and which are include directories
        set(params "${ARGN}")
        foreach(param IN LISTS params)
            string(SUBSTRING ${param} 0 2 TIDY_TEMP_STRING)
            if(TIDY_TEMP_STRING STREQUAL "-I")
                set(TIDY_INCLUDE_DIRS "${TIDY_INCLUDE_DIRS}" "${param}")
            else()
                set(TIDY_CODE_FILES "${TIDY_CODE_FILES}" "${param}")
            endif()
        endforeach()

        if(NOT TIDY_CODE_FILES STREQUAL "")
            add_custom_target(
                ${TIDY_TARGET_NAME}
                COMMAND clang-tidy
                ${TIDY_CODE_FILES}
                -format-style=file
                --
                -std=c++${CMAKE_CXX_STANDARD}
                ${TIDY_INCLUDE_DIRS}
            )

            if(NOT TARGET tidy)
                add_custom_target(tidy)
            endif()

            add_dependencies(tidy ${TIDY_TARGET_NAME})
        endif()
    endif()
endfunction()