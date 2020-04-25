cmake_minimum_required(VERSION 3.13)
project(test C)

include(../../code-coverage.cmake)

add_library(head INTERFACE)
target_code_coverage(head INTERFACE)

add_executable(test code.c)
target_link_libraries(test PRIVATE head)
# target_code_coverage(test)
