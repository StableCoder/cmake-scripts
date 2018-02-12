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

option(BUILD_TESTS "Build the test programs." OFF)

macro(_BuildTests)
    if(BUILD_TESTS)
        if(NOT TARGET catch)
            add_library(catch INTERFACE)
            
            find_file(HAVE_CATCH_HPP catch.hpp)

            if(NOT HAVE_CATCH_HPP)
                # Cloning
                message(STATUS "No Catch header detected, cloning via Git.")
                include(ExternalProject)
                find_package(Git REQUIRED)

                ExternalProject_Add(
                    catch2
                    PREFIX ${CMAKE_BINARY_DIR}/catch2
                    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
                    TIMEOUT 10
                    UPDATE_COMMAND ${GIT_EXECUTABLE} pull
                    CONFIGURE_COMMAND ""
                    BUILD_COMMAND ""
                    INSTALL_COMMAND ""
                    LOG_DOWNLOAD ON
                )

                ExternalProject_Get_Property(catch2 source_dir)
                add_dependencies(catch catch2)
                target_include_directories(catch INTERFACE ${source_dir}/single_include)
            endif()
        endif()

        enable_testing()
        if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test)
            add_subdirectory(test)
        endif()
    endif()
endmacro()