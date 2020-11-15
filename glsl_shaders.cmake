#
# Copyright (C) 2020 by George Cave - gcave@stablecoder.ca
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

#
# glslangValidator
#
find_program(GLSLANGVALIDATOR_EXE "glslangValidator")
mark_as_advanced(FORCE GLSLANGVALIDATOR_EXE)
if(GLSLANGVALIDATOR_EXE)
  message(STATUS "glslangValidator found: ${GLSLANGVALIDATOR_EXE}")
else()
  message(STATUS "glslangValidator not found!")
endif()

# This function acts much like the 'target_sources' function, as in raw GLSL
# shader files can be passed in and will be compiled using 'glslangValidator',
# provided it is available, where the compiled files will be located where the
# sources files are but with the '.spv' suffix appended.
#
# The first argument is the target that the files are associated with, and will
# be compiled as if it were a source file for it. All provided shaders are also
# only recompiled if the source shader file has been modified since the last
# compilation.
#
# ~~~
# Required:
# TARGET_NAME - Name of the target the shader files are associated with and to be compiled for.
#
# Optional:
# INTERFACE <files> - When the following shader files are added to a target, they are done so as 'INTERFACE' type files
# PUBLIC <files> - When the following shader files are added to a target, they are done so as 'PUBLIC' type files
# PRIVATE <files> - When the following shader files are added to a target, they are done so as 'PRIVATE' type files
# COMPILE_OPTIONS <options> - These are other options passed straight to the 'glslangValidator' call with the source shader file
#
# Example:
# When calling `make vk_lib` the shaders will also be compiled with the library's `.c` files.
#
# add_library(vk_lib lib.c, shader_manager.c)
# target_glsl_shaders(vk_lib
#       PRIVATE test.vert test.frag
#       COMPILE_OPTIONS --target-env vulkan1.1)
# ~~~
function(target_glsl_shaders TARGET_NAME)
  if(NOT GLSLANGVALIDATOR_EXE)
    message(
      FATAL_ERROR "Cannot compile GLSL to SPIR-V is glslangValidator not found!"
    )
  endif()

  set(OPTIONS)
  set(SINGLE_VALUE_KEYWORDS)
  set(MULTI_VALUE_KEYWORDS INTERFACE PUBLIC PRIVATE COMPILE_OPTIONS)
  cmake_parse_arguments(
    target_glsl_shaders "${OPTIONS}" "${SINGLE_VALUE_KEYWORDS}"
    "${MULTI_VALUE_KEYWORDS}" ${ARGN})

  foreach(GLSL_FILE IN LISTS target_glsl_shaders_INTERFACE)
    add_custom_command(
      OUTPUT ${GLSL_FILE}.spv
      COMMAND ${GLSLANGVALIDATOR_EXE} ${target_glsl_shaders_COMPILE_OPTIONS} -V
              "${GLSL_FILE}" -o "${GLSL_FILE}.spv"
      MAIN_DEPENDENCY ${GLSL_FILE})

    target_sources(${TARGET_NAME} INTERFACE ${GLSL_FILE}.spv)
  endforeach()

  foreach(GLSL_FILE IN LISTS target_glsl_shaders_PUBLIC)
    add_custom_command(
      OUTPUT ${GLSL_FILE}.spv
      COMMAND ${GLSLANGVALIDATOR_EXE} ${target_glsl_shaders_COMPILE_OPTIONS} -V
              "${GLSL_FILE}" -o "${GLSL_FILE}.spv"
      MAIN_DEPENDENCY ${GLSL_FILE})

    target_sources(${TARGET_NAME} PUBLIC ${GLSL_FILE}.spv)
  endforeach()

  foreach(GLSL_FILE IN LISTS target_glsl_shaders_PRIVATE)
    add_custom_command(
      OUTPUT ${GLSL_FILE}.spv
      COMMAND ${GLSLANGVALIDATOR_EXE} ${target_glsl_shaders_COMPILE_OPTIONS} -V
              "${GLSL_FILE}" -o "${GLSL_FILE}.spv"
      MAIN_DEPENDENCY ${GLSL_FILE})

    target_sources(${TARGET_NAME} PRIVATE ${GLSL_FILE}.spv)
  endforeach()
endfunction()
