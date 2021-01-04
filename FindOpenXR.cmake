#[=======================================================================[.rst:
FindOpenXR
----------

A library to import and export various 3d-model-formats including
scene-post-processing to generate missing render data.

http://OpenXR.org/

IMPORTED Targets
^^^^^^^^^^^^^^^^

This module defines :prop_tgt:`IMPORTED` target ``OpenXR::OpenXR``, if
yaml-cpp has been found.


Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables::

  OpenXR_FOUND          - "True" if yaml-cpp was found
  OpenXR_INCLUDE_DIRS   - include directories for yaml-cpp
  OpenXR_LIBRARIES      - link against this library to use yaml-cpp

The module will also define three cache variables::

  OpenXR_INCLUDE_DIR        - the yaml-cpp include directory
  OpenXR_LIBRARY            - the path to the yaml-cpp library

#]=======================================================================]

find_path(OpenXR_INCLUDE_DIR NAMES openxr/openxr.h)
find_library(OpenXR_LIBRARY NAMES openxr_loader Debug/openxr_loader)

set(OpenXR_INCLUDE_DIRS ${OpenXR_INCLUDE_DIR})
set(OpenXR_LIBRARIES ${OpenXR_LIBRARY})

find_package_handle_standard_args(OpenXR DEFAULT_MSG OpenXR_INCLUDE_DIR
                                  OpenXR_LIBRARY)

mark_as_advanced(OpenXR_INCLUDE_DIR OpenXR_LIBRARY)

if(OpenXR_FOUND AND NOT TARGET OpenXR::OpenXR)
  add_library(OpenXR::OpenXR UNKNOWN IMPORTED)
  set_target_properties(
    OpenXR::OpenXR
    PROPERTIES IMPORTED_LOCATION "${OpenXR_LIBRARIES}"
               INTERFACE_INCLUDE_DIRECTORIES "${OpenXR_INCLUDE_DIRS}")
endif()
