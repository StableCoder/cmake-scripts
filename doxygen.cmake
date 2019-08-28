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

find_package(Doxygen)

option(BUILD_DOCUMENTATION "Build API documentation using Doxygen. (make doc)"
       ${DOXYGEN_FOUND})

# Builds doxygen documentation with a default 'Doxyfile.in' or with a specified
# one, and can make the results installable (under the `doc` install target)
#
# This can only be used once per project, as each target generated is as
# `doc-${PROJECT_NAME}` unless TARGET_NAME is specified.
# ~~~
# Optional Arguments:
#
# ADD_TO_DOC
#   If specified, adds this generated target to be a dependency of the more general
#   `doc` target.
#
# INSTALLABLE
#   Adds the generated documentation to the generic `install` target, under the
#   `documentation` installation group.
#
# PROCESS_DOXYFILE
#   If set, then will process the found Doxyfile through the CMAKE `configure_file`
#   function for macro replacements before using it. (@ONLY)
#
# TARGET_NAME <str>
#   The name to give the doc target. (Default: doc-${PROJECT_NAME})
#
# OUTPUT_DIR <str>
#   The directory to place the generated output. (Default: ${CMAKE_CURRENT_BINARY_DIR}/doc)
#
# INSTALL_PATH <str>
#   The path to install the documenttation under. (if not specified, defaults to
#  'share/${PROJECT_NAME})
#
# DOXYFILE_PATH <str>
#   The given doxygen file to use/process. (Defaults to'${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile')
# ~~~
function(build_docs)
  set(OPTIONS ADD_TO_DOC INSTALLABLE PROCESS_DOXYFILE)
  set(SINGLE_VALUE_KEYWORDS
      TARGET_NAME
      INSTALL_PATH
      DOXYFILE_PATH
      OUTPUT_DIR)
  set(MULTI_VALUE_KEYWORDS)
  cmake_parse_arguments(build_docs
                        "${OPTIONS}"
                        "${SINGLE_VALUE_KEYWORDS}"
                        "${MULTI_VALUE_KEYWORDS}"
                        ${ARGN})

  if(BUILD_DOCUMENTATION)
    if(NOT DOXYGEN_FOUND)
      message(FATAL_ERROR "Doxygen is needed to build the documentation.")
    endif()

    if(NOT build_docs_DOXYFILE_PATH)
      set(DOXYFILE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile)
    elseif(EXISTS ${build_docs_DOXYFILE_PATH})
      set(DOXYFILE_PATH ${build_docs_DOXYFILE_PATH})
    else()
      set(DOXYFILE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${build_docs_DOXYFILE_PATH})
    endif()

    if(NOT EXISTS ${DOXYFILE_PATH})
      message(
        SEND_ERROR
          "Could not find Doxyfile to use for procesing documentation at: ${DOXYFILE_PATH}"
        )
      return()
    endif()

    if(build_docs_PROCESS_DOXYFILE)
      set(DOXYFILE ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
      configure_file(${DOXYFILE_PATH} ${DOXYFILE} @ONLY)
    else()
      set(DOXYFILE ${DOXYFILE_PATH})
    endif()

    if(build_docs_OUTPUT_DIR)
      set(OUT_DIR ${build_docs_OUTPUT_DIR})
    else()
      set(OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/doc)
    endif()

    file(MAKE_DIRECTORY ${OUT_DIR})

    if(build_docs_TARGET_NAME)
      set(TARGET_NAME ${build_docs_TARGET_NAME})
    else()
      set(TARGET_NAME doc-${PROJECT_NAME})
    endif()

    add_custom_target(${TARGET_NAME}
                      COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE}
                      WORKING_DIRECTORY ${OUT_DIR}
                      VERBATIM)

    if(build_docs_ADD_TO_DOC)
      if(NOT TARGET doc)
        add_custom_target(doc)
      endif()

      add_dependencies(doc ${TARGET_NAME})
    endif()

    if(build_docs_INSTALLABLE)
      if(NOT build_docs_INSTALL_PATH)
        set(build_docs_INSTALL_PATH share/${PROJECT_NAME})
      endif()
      install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc/
              COMPONENT documentation
              DESTINATION ${build_docs_INSTALL_PATH})
    endif()
  endif()
endfunction()
