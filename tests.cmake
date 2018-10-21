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

option(BUILD_TESTS "Build the test programs." OFF)
option(FORCE_CATCH_CLONE "Forces cloning of the Catch test headers rather than using local." OFF)

find_file(HAVE_CATCH_HPP catch.hpp PATH_SUFFIXES catch2 catch)

function(build_tests)
    if(BUILD_TESTS)
        if(NOT TARGET catch)
            add_library(catch INTERFACE)

            if(NOT HAVE_CATCH_HPP OR FORCE_CATCH_CLONE)
                # Cloning
                message(STATUS "No local Catch header detected, cloning via Git.")
                include(ExternalProject)
                find_package(Git REQUIRED)

                if(CMAKE_CXX_STANDARD AND CMAKE_CXX_STANDARD GREATER 10)
                    message(STATUS "Detected C++11 or better, using Catch2")
                    ExternalProject_Add(
                        git_catch
                        PREFIX ${CMAKE_BINARY_DIR}/catch2
                        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
                        TIMEOUT 10
                        UPDATE_COMMAND ${GIT_EXECUTABLE} pull
                        CONFIGURE_COMMAND ""
                        BUILD_COMMAND ""
                        INSTALL_COMMAND ""
                        LOG_DOWNLOAD ON
                    )
                else()
                    message(STATUS "Did not detect C++11 or better, using Catch1")
                    ExternalProject_Add(
                        git_catch
                        PREFIX ${CMAKE_BINARY_DIR}/catch1
                        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
                        GIT_TAG Catch1.x
                        TIMEOUT 10
                        UPDATE_COMMAND ${GIT_EXECUTABLE} pull
                        CONFIGURE_COMMAND ""
                        BUILD_COMMAND ""
                        INSTALL_COMMAND ""
                        LOG_DOWNLOAD ON
                    )
                endif()

                ExternalProject_Get_Property(git_catch source_dir)
                add_dependencies(catch git_catch)
                target_include_directories(catch INTERFACE ${source_dir}/single_include  ${source_dir}/single_include/catch2)
            else()
                # Using Local
                message(STATUS "Local Catch header detected at: " ${HAVE_CATCH_HPP})
                get_filename_component(CATCH_PATH ${HAVE_CATCH_HPP} DIRECTORY)
                target_include_directories(catch INTERFACE ${CATCH_PATH})
            endif()
        endif()

        enable_testing()
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/test/CMakeLists.txt)
            add_subdirectory(test)
        endif()
    endif()
endfunction()