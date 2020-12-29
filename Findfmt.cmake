#[=======================================================================[.rst:
Findfmt
----------

A library to import and export various 3d-model-formats including
scene-post-processing to generate missing render data.

http://fmt.org/

IMPORTED Targets
^^^^^^^^^^^^^^^^

This module defines :prop_tgt:`IMPORTED` target ``fmt::fmt``, if
yaml-cpp has been found.


Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables::

  fmt_FOUND          - "True" if yaml-cpp was found
  fmt_INCLUDE_DIRS   - include directories for yaml-cpp
  fmt_LIBRARIES      - link against this library to use yaml-cpp

The module will also define three cache variables::

  fmt_INCLUDE_DIR        - the yaml-cpp include directory
  fmt_LIBRARY            - the path to the yaml-cpp library

#]=======================================================================]

find_path(fmt_INCLUDE_DIR NAMES fmt/format.h)
find_library(fmt_LIBRARY NAMES fmt fmtd)

set(fmt_INCLUDE_DIRS ${fmt_INCLUDE_DIR})
set(fmt_LIBRARIES ${fmt_LIBRARY})

get_filename_component(fmt_INCLUDE_DIRS ${fmt_INCLUDE_DIRS} DIRECTORY)
if(WIN32 OR APPLE)
  set(fmt_INCLUDE_DIRS ${fmt_INCLUDE_DIRS}/include)
endif()

find_package_handle_standard_args(fmt DEFAULT_MSG fmt_INCLUDE_DIR fmt_LIBRARY)

mark_as_advanced(fmt_INCLUDE_DIR fmt_LIBRARY)

if(fmt_FOUND AND NOT TARGET fmt::fmt)
  add_library(fmt::fmt UNKNOWN IMPORTED)
  set_target_properties(
    fmt::fmt PROPERTIES IMPORTED_LOCATION "${fmt_LIBRARIES}"
                        INTERFACE_INCLUDE_DIRECTORIES "${fmt_INCLUDE_DIRS}")
endif()
