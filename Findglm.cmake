#[=======================================================================[.rst:
Findglm
----------

OpenGL Mathematics (GLM) is a header only C++ mathematics library for
graphics software based on the OpenGL Shading Language (GLSL) specifications.

https://glm.g-truc.net/

INTERFACE Targets
^^^^^^^^^^^^^^^^^

This module defines the `INTERFACE` target ``glm``, if the glm header
glm/glm.hpp has been found.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables::

  glm_FOUND          - "True" if glm was found
  glm_INCLUDE_DIRS   - include directories for glm

The module will also define these cache variables::

  glm_INCLUDE_DIR        - the glm include directory

#]=======================================================================]

find_path(glm_INCLUDE_DIR NAMES glm/glm.hpp)

set(glm_INCLUDE_DIRS ${glm_INCLUDE_DIR})

find_package_handle_standard_args(glm DEFAULT_MSG glm_INCLUDE_DIR)

mark_as_advanced(glm_INCLUDE_DIR)
if(glm_FOUND AND NOT TARGET glm)
  add_library(glm INTERFACE)
  target_include_directories(glm INTERFACE ${glm_INCLUDE_DIRS})
endif()
