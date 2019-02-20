#
# Copyright (C) 2019 by George Cave - gcave@stablecoder.ca
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

# This file includes the items for using the cmake-format formatter program
# easier. To use, in the CMake files, simple call `cmake_format(<FILES>)`, where
# <FILES> is the list of files to run the formatter on.

find_program(CMAKE_FORMAT_EXE "cmake-format")
if(CMAKE_FORMAT_EXE)
  message(STATUS "cmake-format found: ${CMAKE_FORMAT_EXE}")
else()
  message(STATUS "cmake-format not found!")
endif()

# When called, this function will call 'cmake-format' program on all listed
# files (if both the program and the files exist and are found)
#
# Each individual file is created as a separate target `cmake-format-<MD5>` hash
# of the file, and all these individual targets are then linked in as
# dependencies of the `cmake-format` final target. Optional: ARGN - Any
# arguments passed in will be considered as 'files' to perform the formatting
# on. Any items that are not files will be ignored.
function(cmake_format)
  if(CMAKE_FORMAT_EXE)
    foreach(iter IN LISTS ARGN)
      if(EXISTS ${iter})
        string(MD5 ${iter} hash)

        if(NOT TARGET cmake-format-${hash})
          add_custom_target(cmake-format-${hash}
                            COMMAND cmake-format -i ${iter})

          if(NOT TARGET cmake-format)
            add_custom_target(cmake-format)
          endif()
          add_dependencies(cmake-format cmake-format-${hash})
        endif()
      endif()
    endforeach()
  endif()
endfunction()
