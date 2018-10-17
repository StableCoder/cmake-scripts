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

## USAGE:
# To enable any code coverage instrumentation/targets, the single CMake option of `CODE_COVERAGE` needs
# to be set to 'ON', either by GUI, ccmake, or on the command line.
#
# From this point, there are two primary methods for adding instrumentation to targets:
# 1 - A blanket instrumentation by calling `add_code_coverage()`, where all targets in that directory and all
#     subdirectories are automatically instrumented.
# 2 - Per-target instrumentation by calling `target_code_coverage(<TARGET_NAME>)`, where the target is given
#     and thus only that target is instrumented. This applies to both libraries and executables.
#
# To add coverage targets, such as calling `make ccov` to generate the actual coverage information for perusal
# or consumption, either `target_code_coverage(<TARGET_NAME>)` or `target_auto_code_coverage(<TARGET_NAME>)`
# needs to be called on an *executable* target.
#
# NOTE: To add coverage targets to an executable target, but *not* instrument it, call the macro with the
# `NO_INSTRUMENTATION` option, such as `target_code_coverage(<TARGET_NAME> NO_INSTRUMENTATION)`

# Options
OPTION(CODE_COVERAGE "Builds targets with code coverage instrumentation. (Requires GCC or Clang)" OFF)

# Programs
FIND_PROGRAM(LLVM_COV_PATH llvm-cov)
FIND_PROGRAM(LCOV_PATH lcov)
FIND_PROGRAM(GENHTML_PATH genhtml)

# Variables
set(CMAKE_COVERAGE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/ccov)

if(CODE_COVERAGE)
    if("${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
        message(STATUS "Building with llvm Code Coverage Tools")

        if(NOT LLVM_COV_PATH)
            message(FATAL_ERROR "llvm-cov not found! Aborting.")
        endif()

        add_custom_target(ccov-clean
            COMMAND rm -f ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/binaries.list
            COMMAND rm -f ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/profraw.list
        )

        add_custom_target(ccov-preprocessing
            COMMAND mkdir -p ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}
            DEPENDS ccov-clean
        )

        add_custom_target(ccov-all-processing
            COMMAND llvm-profdata merge -o ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/all-merged.profdata -sparse `cat ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/profraw.list`
        )

        add_custom_target(ccov-all-report
            COMMAND llvm-cov report `cat ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/binaries.list` -instr-profile=${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/all-merged.profdata
            DEPENDS ccov-all-processing
        )

        add_custom_target(ccov-all
            COMMAND llvm-cov show `cat ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/binaries.list` -instr-profile=${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/all-merged.profdata -show-line-counts-or-regions -output-dir=${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/all-merged -format="html"
            DEPENDS ccov-all-processing
        )

        add_custom_target(TARGET ccov-all POST_BUILD
            COMMAND ;
            COMMENT "Open ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/all-merged/index.html in your browser to view the coverage report."
        )

    elseif(CMAKE_COMPILER_IS_GNUCXX)
        message(STATUS "Building with lcov Code Coverage Tools")

        string(TOUPPER ${CMAKE_BUILD_TYPE} upper_build_type)
        if(NOT ${upper_build_type} STREQUAL "DEBUG")
            message(WARNING "Code coverage results with an optimized (non-Debug) build may be misleading")
        endif()
        if(NOT LCOV_PATH)
            message(FATAL_ERROR "lcov not found! Aborting...")
        endif()
        if(NOT GENHTML_PATH)
            message(FATAL_ERROR "genhtml not found! Aborting...")
        endif()

    else()
        message(FATAL_ERROR "Code coverage requires Clang or GCC. Aborting.")
    endif()
endif()

# Adds code coverage instrumentation to a library, or instrumentation/targets for an executable target.
#
# Required:
# TARGET_NAME - Name of the target to generate code coverage for.
# Optional:
# NO_INSTRUMENTATION - Turns off code coverage instrumentation on this particular target (if an executable target). This 
#                      is useful for adding test programs without instrumenting the test program itself.
macro(target_code_coverage TARGET_NAME)
    # Argument parsing
    set(options NO_INSTRUMENTATION)
    cmake_parse_arguments(target_code_coverage "${options}" "" "" ${ARGN})

    if(CODE_COVERAGE)
        # Instrumentation
        if(NOT target_code_coverage_NO_INSTRUMENTATION)
            if("${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
                target_compile_options(${TARGET_NAME} PRIVATE -fprofile-instr-generate -fcoverage-mapping)
                set_target_properties(${TARGET_NAME} PROPERTIES LINK_FLAGS "-fprofile-instr-generate -fcoverage-mapping")    
            elseif(CMAKE_COMPILER_IS_GNUCXX)
                target_compile_options(${TARGET_NAME} PRIVATE -fprofile-arcs -ftest-coverage)
                target_link_libraries(${TARGET_NAME} PRIVATE gcov)
            endif()
        endif()

        # Targets
        get_target_property(target_type ${TARGET_NAME} TYPE)
        if(target_type STREQUAL "EXECUTABLE")
            if("${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
                add_custom_target(ccov-run-${TARGET_NAME}
                    COMMAND LLVM_PROFILE_FILE=${TARGET_NAME}.profraw $<TARGET_FILE:${TARGET_NAME}>
                    COMMAND echo "-object=$<TARGET_FILE:${TARGET_NAME}>" >> ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/binaries.list
                    COMMAND echo "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}.profraw " >> ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/profraw.list
                    DEPENDS ccov-preprocessing ${TARGET_NAME}
                )

                add_custom_target(ccov-processing-${TARGET_NAME}
                    COMMAND llvm-profdata merge -sparse ${TARGET_NAME}.profraw -o ${TARGET_NAME}.profdata
                    DEPENDS ccov-run-${TARGET_NAME}
                )

                add_custom_target(ccov-show-${TARGET_NAME}
                    COMMAND llvm-cov show $<TARGET_FILE:${TARGET_NAME}> -instr-profile=${TARGET_NAME}.profdata -show-line-counts-or-regions
                    DEPENDS ccov-processing-${TARGET_NAME}
                )

                add_custom_target(ccov-rpt-${TARGET_NAME}
                    COMMAND llvm-cov report $<TARGET_FILE:${TARGET_NAME}> -instr-profile=${TARGET_NAME}.profdata
                    DEPENDS ccov-processing-${TARGET_NAME}
                )

                add_custom_target(ccov-${TARGET_NAME}
                    COMMAND llvm-cov show $<TARGET_FILE:${TARGET_NAME}> -instr-profile=${TARGET_NAME}.profdata -show-line-counts-or-regions -output-dir=${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET_NAME}-llvm-cov -format="html"
                    DEPENDS ccov-processing-${TARGET_NAME}
                )

                add_custom_command(TARGET ccov-${TARGET_NAME} POST_BUILD
                    COMMAND ;
                    COMMENT "Open ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET_NAME}-llvm-cov/index.html in your browser to view the coverage report."
                )

            elseif(CMAKE_COMPILER_IS_GNUCXX)
                set(COVERAGE_INFO "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${TARGET_NAME}.info")

                add_custom_target(ccov-${TARGET_NAME}
                    ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --zerocounters
                    COMMAND $<TARGET_FILE:${TARGET_NAME}>
                    COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --capture --output-file ${COVERAGE_INFO}
                    COMMAND ${LCOV_PATH} --remove ${COVERAGE_INFO} 'tests/*' '/usr/*' --output-file ${COVERAGE_INFO}
                    COMMAND ${GENHTML_PATH} -o ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET_NAME}-lcov ${COVERAGE_INFO}
                    COMMAND ${CMAKE_COMMAND} -E remove ${COVERAGE_INFO}
                    DEPENDS ${TARGET_NAME}
                )

                add_custom_command(TARGET ccov-${TARGET_NAME} POST_BUILD
                    COMMAND ;
                    COMMENT "Open ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET_NAME}-lcov/index.html in your browser to view the coverage report."
                )
            endif()
        endif()
    endif()
endmacro()

# Adds code coverage instrumentation to a library, or instrumentation/targets for an executable target.
# As well, adds the target to the auto created ccov and ccov-report targets for easier automated running.
#
# Required:
# TARGET_NAME - Name of the target to generate code coverage for.
# Optional:
# NO_INSTRUMENTATION - Turns off code coverage instrumentation on this particular target (if an executable target). This 
#                      is useful for adding test programs without instrumenting the test program itself.
macro(target_auto_code_coverage TARGET_NAME)
    if(CODE_COVERAGE)
        target_code_coverage(${TARGET_NAME} ${ARGN})

        if(NOT TARGET ccov)
            add_custom_target(ccov)
        endif()
        add_dependencies(ccov ccov-${TARGET_NAME})

        if(NOT CMAKE_COMPILER_IS_GNUCXX)
            if(NOT TARGET ccov-report)
                add_custom_target(ccov-report)
            endif()
            add_dependencies(ccov-report ccov-rpt-${TARGET_NAME})

            add_dependencies(ccov-all-processing ccov-run-${TARGET_NAME})
        endif()
    endif()
endmacro()

# Adds code coverage instrumentation to all targets in the current directory and any subdirectories. To add coverage instrumentation to only
# specific targets, use `target_code_coverage`.
macro(add_code_coverage)
    if("${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
        add_compile_options(-fprofile-instr-generate -fcoverage-mapping)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fprofile-instr-generate -fcoverage-mapping")
    elseif(CMAKE_COMPILER_IS_GNUCXX)
        add_compile_options(-fprofile-arcs -ftest-coverage)
        link_libraries(gcov)
    endif()
endmacro()