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

if(NOT COVERAGE_ADDED)
set(COVERAGE_ADDED ON)

# Options
OPTION(CODE_COVERAGE "Builds targets with code coverage tools. (Requires GCC or Clang)" OFF)

# Programs
FIND_PROGRAM(LLVM_COV_PATH llvm-cov)
FIND_PROGRAM(LCOV_PATH lcov)
FIND_PROGRAM(GENHTML_PATH genhtml)

# Variables
set(CMAKE_COVERAGE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/ccov)

set(CMAKE_C_FLAGS_COVERAGE
    "${CMAKE_C_FLAGS_RELEASE}"
    CACHE STRING "Flags used by the C compiler during Code Coverage builds."
    FORCE)
set(CMAKE_CXX_FLAGS_COVERAGE
    "${CMAKE_CXX_FLAGS_RELEASE}"
    CACHE STRING "Flags used by the C++ compiler during Code Coverage builds."
    FORCE)

if(CMAKE_BUILD_TYPE STREQUAL "coverage" OR CODE_COVERAGE)
    if("${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
        message("Building with llvm Code Coverage Tools")

        # Warning/Error messages
        if(NOT LLVM_COV_PATH)
            message(FATAL_ERROR "llvm-cov not found! Aborting.")
        endif()

        # set Flags
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-instr-generate -fcoverage-mapping")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-instr-generate -fcoverage-mapping")

        add_custom_target(ccov-clean
            COMMAND rm ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/binaries.list
            COMMAND rm ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/profraw.list
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
        message("Building with lcov Code Coverage Tools")

        # Warning/Error messages
        if(NOT (CMAKE_BUILD_TYPE STREQUAL "Debug"))
            message(WARNING "Code coverage results with an optimized (non-Debug) build may be misleading")
        endif()
        if(NOT LCOV_PATH)
            message(FATAL_ERROR "lcov not found! Aborting...")
        endif()
        if(NOT GENHTML_PATH)
            message(FATAL_ERROR "genhtml not found! Aborting...")
        endif()

        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage -fprofile-arcs -ftest-coverage")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage -fprofile-arcs -ftest-coverage")
    else()
        message(FATAL_ERROR "Code coverage requires Clang or GCC. Aborting.")
    endif()
endif()

# Adds code coverage targets to the named target, named '${TARGET_NAME}-ccov'.
#
# TARGET_NAME - Name of the target to generate code coverage for.
macro(target_add_code_coverage TARGET_NAME)
    if(CMAKE_BUILD_TYPE STREQUAL "coverage" OR CODE_COVERAGE)
        if("${CMAKE_C_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
            add_custom_target(${TARGET_NAME}-ccov-run
                COMMAND LLVM_PROFILE_FILE=${TARGET_NAME}.profraw $<TARGET_FILE:${TARGET_NAME}>
                COMMAND echo "-object=$<TARGET_FILE:${TARGET_NAME}>" >> ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/binaries.list
                COMMAND echo "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}.profraw " >> ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/profraw.list
                DEPENDS ${TARGET_NAME})

            add_custom_target(${TARGET_NAME}-ccov-preprocessing
                COMMAND llvm-profdata merge -sparse ${TARGET_NAME}.profraw -o ${TARGET_NAME}.profdata
                DEPENDS ${TARGET_NAME}-ccov-run)

            add_custom_target(${TARGET_NAME}-ccov-show
                COMMAND llvm-cov show $<TARGET_FILE:${TARGET_NAME}> -instr-profile=${TARGET_NAME}.profdata -show-line-counts-or-regions
                DEPENDS ${TARGET_NAME}-ccov-preprocessing)

            add_custom_target(${TARGET_NAME}-ccov-report
                COMMAND llvm-cov report $<TARGET_FILE:${TARGET_NAME}> -instr-profile=${TARGET_NAME}.profdata
                DEPENDS ${TARGET_NAME}-ccov-preprocessing)

            add_custom_target(${TARGET_NAME}-ccov
                COMMAND llvm-cov show $<TARGET_FILE:${TARGET_NAME}> -instr-profile=${TARGET_NAME}.profdata -show-line-counts-or-regions -output-dir=${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET_NAME}-llvm-cov -format="html"
                DEPENDS ${TARGET_NAME}-ccov-preprocessing)

            add_custom_command(TARGET ${TARGET_NAME}-ccov POST_BUILD
                COMMAND ;
                COMMENT "Open ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET_NAME}-llvm-cov/index.html in your browser to view the coverage report."
            )

        elseif(CMAKE_COMPILER_IS_GNUCXX)
            set(COVERAGE_INFO "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${TARGET_NAME}.info")
            set(COVERAGE_CLEANED "${coverage_info}.cleaned")

            add_custom_target(${TARGET_NAME}-ccov
                ${LCOV_PATH} --directory . --zerocounters
                COMMAND $<TARGET_FILE:${TARGET_NAME}>
                COMMAND ${LCOV_PATH} --directory . --capture --output-file ${COVERAGE_INFO}
                COMMAND ${LCOV_PATH} --remove ${COVERAGE_INFO} 'tests/*' '/usr/*' --output-file ${COVERAGE_CLEANED}
                COMMAND ${GENHTML_PATH} -o ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET_NAME}-lcov ${COVERAGE_CLEANED}
                COMMAND ${CMAKE_COMMAND} -E remove ${COVERAGE_INFO} ${COVERAGE_CLEANED}
                DEPENDS ${TARGET_NAME}
            )

            add_custom_command(TARGET ${TARGET_NAME}-ccov POST_BUILD
                COMMAND ;
                COMMENT "Open ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${TARGET_NAME}-lcov/index.html in your browser to view the coverage report."
            )
        endif()
    endif()
endmacro()

# Adds code coverage targets to the named target, as well as adds them to the auto
# created ccov and ccov-report targets for easier automated running.
#
# TARGET_NAME - Name of the target to generate code coverage for.
macro(target_add_auto_code_coverage TARGET_NAME)
    if(CMAKE_BUILD_TYPE STREQUAL "coverage" OR CODE_COVERAGE)
        target_add_code_coverage(${TARGET_NAME})

        if(NOT TARGET ccov)
            add_custom_target(ccov)
        endif()
        add_dependencies(ccov ${TARGET_NAME}-ccov)

        if(NOT CMAKE_COMPILER_IS_GNUCXX)
            if(NOT TARGET ccov-report)
                add_custom_target(ccov-report)
            endif()
            add_dependencies(ccov-report ${TARGET_NAME}-ccov-report)

            add_dependencies(ccov-all-processing ${TARGET_NAME}-ccov-run)
        endif()
    endif()
endmacro()

endif(NOT COVERAGE_ADDED)