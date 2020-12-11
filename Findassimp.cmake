#[=======================================================================[.rst:
Findassimp
----------

A library to import and export various 3d-model-formats including
scene-post-processing to generate missing render data.

http://assimp.org/

IMPORTED Targets
^^^^^^^^^^^^^^^^

This module defines :prop_tgt:`IMPORTED` target ``assimp::assimp``, if
yaml-cpp has been found.


Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables::

  assimp_FOUND          - "True" if yaml-cpp was found
  assimp_INCLUDE_DIRS   - include directories for yaml-cpp
  assimp_LIBRARIES      - link against this library to use yaml-cpp

The module will also define three cache variables::

  assimp_INCLUDE_DIR        - the yaml-cpp include directory
  assimp_LIBRARY            - the path to the yaml-cpp library

#]=======================================================================]

find_path(assimp_INCLUDE_DIR NAMES assimp/types.h)
find_library(assimp_LIBRARY NAMES assimp assimpd)

set(assimp_INCLUDE_DIRS ${assimp_INCLUDE_DIR})
set(assimp_LIBRARIES ${assimp_LIBRARY})

find_package_handle_standard_args(assimp DEFAULT_MSG assimp_INCLUDE_DIR
                                  assimp_LIBRARY)

mark_as_advanced(assimp_INCLUDE_DIR assimp_LIBRARY)

if(assimp_FOUND AND NOT TARGET assimp::assimp)
  add_library(assimp::assimp UNKNOWN IMPORTED)
  set_target_properties(
    assimp::assimp
    PROPERTIES IMPORTED_LOCATION "${assimp_LIBRARIES}"
               INTERFACE_INCLUDE_DIRECTORIES "${assimp_INCLUDE_DIRS}")
endif()
