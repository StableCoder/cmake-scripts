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

macro(_BuildDocs)
    find_package(Doxygen)

    option(BUILD_DOCUMENTATION "Build API documentation using Doxygen. (make doc)" ${DOXYGEN_FOUND})

    if(BUILD_DOCUMENTATION AND NOT TARGET doc)
        # Only build if documentation is wanted and if this also happens to be the root project.
        if (NOT DOXYGEN_FOUND)
            message(FATAL_ERROR "Doxygen is needed to build the documentation.")
        endif ()

        # Global all .dox files to add to the doxygen input
        file(GLOB_RECURSE DOXY_INPUTS
            ${CMAKE_CURRENT_SOURCE_DIR}/*.dox
        )
        set(DOXY_INPUTS "${CMAKE_CURRENT_SOURCE_DIR} ${DOXY_INPUTS}")

        set(doxyfile_in ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
        set(doxyfile ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

        configure_file(${doxyfile_in} ${doxyfile} @ONLY)

        # Generate the directory where the docs would be placed.
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc)

        add_custom_target(
            doc
            COMMAND ${DOXYGEN_EXECUTABLE} ${doxyfile}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
            COMMENT "Generating ${PROJECT_NAME} documentation with Doxygen."
            VERBATIM
        )

        install(
            DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc
            COMPONENT documentation
            DESTINATION share/doc
        )
    endif()
endmacro()