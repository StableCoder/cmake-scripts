#
# Copyright (C) 2018 by George Cave - gcave@stablecoder.ca
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# Options
option(FORCE_CATCH_CLONE
       "Forces cloning of the Catch test headers rather than using local" OFF)

# Attempts to find a local header of the Catch test frameword
find_file(HAVE_CATCH_HPP catch.hpp PATH_SUFFIXES catch2 catch)
mark_as_advanced(FORCE HAVE_CATCH_HPP)

# Attempts to add the infrastructure necessary for automatically adding C/C++
# tests using the Catch2 library, including either an interface or pre-compiled
# 'catch' target library.
#
# It first attempts to find the header on the local machine, and failing that,
# clones the single header variant for use. It does make the determination
# between pre-C++11 and will use Catch1.X rather than Catch2 (when cloned),
# automatically or forced.. Adds a subdirectory of tests/ if it exists from the
# macro's calling location.
#
# ~~~
# COMPILED_CATCH - If this option is specified, then generates the 'catch' target as a library with
#       catch already pre-compiled as part of the library. Otherwise acts just an interface library for
#       the header location.
# CATCH1 - Force the use of Catch1.X, rather than auto-detecting the C++ version in use.
# CLONE - Force cloning of Catch, rather than attempting to use a locally-found variant.
#
# !WARNING! - When switching between COMPILED_CATCH and non-COMPILED_CATCH, the binary folders will need
# to be cleared for it to take proper effect.
# !WARNING! - The parameters of the first processed instance of the macro will determine the catch target
# configuration. There's no mixing of configs here.
# ~~~
function(prepare_catch)
  set(options COMPILED_CATCH CATCH1 CLONE)
  cmake_parse_arguments(
    build_tests
    "${options}"
    ""
    ""
    ${ARGN})

  if(BUILD_TESTS AND NOT TARGET catch)
    if(NOT HAVE_CATCH_HPP
       OR FORCE_CATCH_CLONE
       OR build_tests_CLONE)
      # Cloning
      message(STATUS "No local Catch header detected, cloning via Git.")
      include(ExternalProject)
      find_package(Git REQUIRED)

      if(CMAKE_CXX_STANDARD
         AND CMAKE_CXX_STANDARD GREATER 10
         AND NOT build_tests_CATCH1)
        message(STATUS "Cloning Catch2")
        ExternalProject_Add(
          git_catch
          PREFIX ${CMAKE_BINARY_DIR}/catch2
          GIT_REPOSITORY https://github.com/catchorg/Catch2.git
          GIT_SHALLOW 1
          TIMEOUT 10
          UPDATE_COMMAND ${GIT_EXECUTABLE} pull
          CONFIGURE_COMMAND ""
          BUILD_COMMAND ""
          INSTALL_COMMAND ""
          LOG_DOWNLOAD ON)
      else()
        message(STATUS "Cloning Catch1")
        ExternalProject_Add(
          git_catch
          PREFIX ${CMAKE_BINARY_DIR}/catch1
          GIT_REPOSITORY https://github.com/catchorg/Catch2.git
          GIT_TAG Catch1.x
          GIT_SHALLOW 1
          TIMEOUT 10
          UPDATE_COMMAND ${GIT_EXECUTABLE} pull
          CONFIGURE_COMMAND ""
          BUILD_COMMAND ""
          INSTALL_COMMAND ""
          LOG_DOWNLOAD ON)
      endif()

      ExternalProject_Get_Property(git_catch source_dir)
      set(CATCH_PATH ${source_dir}/single_include
                     ${source_dir}/single_include/catch2)
    else()
      # Using Local
      message(STATUS "Local Catch header detected at: " ${HAVE_CATCH_HPP})
      get_filename_component(CATCH_PATH ${HAVE_CATCH_HPP} DIRECTORY)
    endif()

    if(build_tests_COMPILED_CATCH)
      # A pre-compiled catch library has been requested
      message(STATUS "Generating a pre-compiled Catch library")

      if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/pre_compiled_catch.cpp)
        file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/pre_compiled_catch.cpp
             "#define CATCH_CONFIG_MAIN\n#include <catch.hpp>\n")
      endif()
      if(WIN32)
        # Catch on WIN32 doesn't work when dynamically linked
        add_library(catch STATIC
                    ${CMAKE_CURRENT_BINARY_DIR}/pre_compiled_catch.cpp)
      else()
        # Make sure it's visible if it's a shared object.
        set(CMAKE_CXX_VISIBILITY_PRESET default)
        set(CMAKE_VISIBILITY_INLINES_HIDDEN 0)
        add_library(catch SHARED
                    ${CMAKE_CURRENT_BINARY_DIR}/pre_compiled_catch.cpp)
      endif()
      target_include_directories(catch PUBLIC ${CATCH_PATH})
    else()
      add_library(catch INTERFACE)
      target_include_directories(catch INTERFACE ${CATCH_PATH})
    endif()

    if(TARGET git_catch)
      # If cloning, make sure it's cloned BEFORE it's needed.
      add_dependencies(catch git_catch)
    endif()
  endif()
endfunction()
