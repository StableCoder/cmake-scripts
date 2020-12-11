#[=======================================================================[.rst:
Findyamlcpp
----------

yaml-cpp is a YAML parser and emitter in C++ matching the YAML 1.2 spec.

https://github.com/jbeder/yaml-cpp

IMPORTED Targets
^^^^^^^^^^^^^^^^

This module defines :prop_tgt:`IMPORTED` target ``yamlcpp::yamlcpp``, if
yaml-cpp has been found.


Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables::

  yamlcpp_FOUND          - "True" if yaml-cpp was found
  yamlcpp_INCLUDE_DIRS   - include directories for yaml-cpp
  yamlcpp_LIBRARIES      - link against this library to use yaml-cpp

The module will also define three cache variables::

  yamlcpp_INCLUDE_DIR        - the yaml-cpp include directory
  yamlcpp_LIBRARY            - the path to the yaml-cpp library

#]=======================================================================]

find_path(yamlcpp_INCLUDE_DIR NAMES yaml-cpp/yaml.h)
find_library(yamlcpp_LIBRARY NAMES yaml-cpp yaml-cppd)

set(yamlcpp_INCLUDE_DIRS ${yamlcpp_INCLUDE_DIR})
set(yamlcpp_LIBRARIES ${yamlcpp_LIBRARY})

find_package_handle_standard_args(yamlcpp DEFAULT_MSG yamlcpp_INCLUDE_DIR
                                  yamlcpp_LIBRARY)

mark_as_advanced(yamlcpp_INCLUDE_DIR yamlcpp_LIBRARY)

if(yamlcpp_FOUND AND NOT TARGET yamlcpp::yamlcpp)
  add_library(yamlcpp::yamlcpp UNKNOWN IMPORTED)
  set_target_properties(
    yamlcpp::yamlcpp
    PROPERTIES IMPORTED_LOCATION "${yamlcpp_LIBRARIES}"
               INTERFACE_INCLUDE_DIRECTORIES "${yamlcpp_INCLUDE_DIRS}")
endif()
