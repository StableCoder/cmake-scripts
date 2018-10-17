# CMake Scripts

This is a collection of quite useful scripts that expand the possibilities for building software with CMake, by making some things easier and otherwise adding new build types.

## C++ Standards

`c++-standards.cmake`

Using the functions `_Cxx11()`, `_Cxx14()` or `_Cxx17()` this adds the appropriated flags for both unix and MSVC compilers, even for those before 3.11 with improper support.

## Sanitizer Builds

`sanitizers.cmake`

Sanitizers are tools that perform checks during a program’s runtime and returns issues, and as such, along with unit testing, code coverage and static analysis, is another tool to add to the programmers toolbox. And of course, like the previous tools, are tragically simple to add into any project using CMake, allowing any project and developer to quickly and easily use.

A quick rundown of the tools available, and what they do:
- [LeakSanitizer](https://clang.llvm.org/docs/LeakSanitizer.html) detects memory leaks, or issues where memory is allocated and never deallocated, causing programs to slowly consume more and more memory, eventually leading to a crash.
- [AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html) is a fast memory error detector. It is useful for detecting most issues dealing with memory, such as:
    - Out of bounds accesses to heap, stack, global
    - Use after free
    - Use after return
    - Use after scope
    - Double-free, invalid free
    - Memory leaks (using LeakSanitizer)
- [ThreadSanitizer](https://clang.llvm.org/docs/ThreadSanitizer.html) detects data races for multi-threaded code.
- [UndefinedBehaviourSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html) detects the use of various features of C/C++ that are explicitly listed as resulting in undefined behaviour. Most notably:
    - Using misaligned or null pointer.
    - Signed integer overflow
    - Conversion to, from, or between floating-point types which would overflow the destination
    - Division by zero
    - Unreachable code
- [MemorySanitizer](https://clang.llvm.org/docs/MemorySanitizer.html) detects uninitialized reads.

These are used by declaring the `USE_SANITIZER` CMake variables as one of:
- Address
- Memory
- MemoryWithOrigins
- Undefined
- Thread
- Address;Undefined
- Undefined;Address
- Leak

## Code Coverage

`code-coverage.cmake`

Generating code coverage during a run of a program can help determine which blocks, regions, or even lines of code are being used, and for how many times.

Coverage here is supported on both GCC and Clang. GCC requires the `lcov` program, and Clang requires `llvm-cov` and `llvm-profdata`, often provided with the llvm toolchain.

To enable, turn on the `CODE_COVERAGE` variable.

### Added Targets

- GCOV/LCOV:
    - ccov : Generates HTML code coverage report for every executable target added via `target_auto_code_coverage`.
    - ccov-${TARNGET_NAME} : Generates HTML code coverage report for the associated named target.
- LLVM-COV:
    - ccov : Generates HTML code coverage report for every executable target added via `target_auto_code_coverage`.
    - ccov-${TARGET_NAME} : Generates HTML code coverage report.
    - ccov-rpt-${TARGET_NAME} : Prints to command line summary per-file coverage information.
    - ccov-show-${TARGET_NAME} : Prints to command line detailed per-line coverage information.
    - ccov-all : Generates HTML code coverage report, merging every target added via `target_auto_code_coverage` into a single detailed report.
    - ccov-all-report : Prints summary per-file coverage infromation of all targets added via `target_auto_code_coverage` to the command line.

### Usage

To enable any code coverage instrumentation/targets, the single CMake option of `CODE_COVERAGE` needs to be set to 'ON', either by GUI, ccmake, or on the command line.

From this point, there are two primary methods for adding instrumentation to targets:
1. A blanket instrumentation by calling `add_code_coverage()`, where all targets in that directory and all subdirectories are automatically instrumented.
2. Per-target instrumentation by calling `target_code_coverage(<TARGET_NAME>)`, where the target is given and thus only that target is instrumented. This applies to both libraries and executables.

To add coverage targets, such as calling `make ccov` to generate the actual coverage information for perusal or consumption, either `target_code_coverage(<TARGET_NAME>)` or `target_auto_code_coverage(<TARGET_NAME>)` needs to be called on an *executable* target.

NOTE: To add coverage targets to an executable target, but *not* instrument it, call the macro with the `NO_INSTRUMENTATION` option, such as `target_code_coverage(<TARGET_NAME> NO_INSTRUMENTATION)`.

#### Example 1 - All targets instrumented

In this case, the coverage information reported will will be that of the `theLib` library target and `theExe` executable.

##### 1a - Via global command

```
add_code_coverage() # Adds instrumentation to all targets

add_library(theLib lib.cpp)

add_executable(theExe main.cpp)
target_link_libraries(theExe PRIVATE theLib)
target_code_coverage(theExe) # As an executable target, adds the 'ccov-theExe' target (instrumentation already added via global anyways) for generating code coverage reports.
```

##### 1b - Via target commands

```
add_library(theLib lib.cpp)
target_code_coverage(theLib) # As a library target, adds coverage instrumentation but no targets.

add_executable(theExe main.cpp)
target_link_libraries(theExe PRIVATE theLib)
target_code_coverage(theExe) # As an executable target, adds the 'ccov-theExe' target and instrumentation for generating code coverage reports.
```

#### Example 2 - Library target instrumented, executable targets added but not instrumented

In this case, the coverage information reported will just be that of the `theLib` library target, but this information will be collected via running the `theExe` executable.

```
add_library(theLib lib.cpp)
target_code_coverage(theLib) # As a library target, adds coverage instrumentation but no targets.

add_executable(theExe main.cpp)
target_link_libraries(theExe PRIVATE theLib)
target_code_coverage(theExe NO_INSTRUMENTATION) # As an executable target, adds the 'ccov-theExe' target for generating code coverage reports, but no instrumentation
```

## Compiler Options

`compiler-options.cmake`

Allows for easy use of some pre-made compiler options for the major compilers.

### Enable All Warnings

Using `-DENABLE_ALL_WARNINGS=ON` will enable almost all of the warnings available for a compiler:

| Compiler | Options                |
|:---------|:-----------------------|
| MSVC     | /W4                    |
| GCC      | -Wall -Weffc++ -Wextra |
| Clang    | -Wall -Weffc++ -Wextra |

## Tools

`tools.cmake`

### clang-format

Allows to automatically perform code formatting using the clang-format program, by calling an easy-to-use target ala `make format`. It requires a target name, and the list of files to format.

```
file(GLOB_RECURSE ALL_CODE_FILES
    ${PROJECT_SOURCE_DIR}/src/*.[ch]pp
    ${PROJECT_SOURCE_DIR}/src/*.[ch]
    ${PROJECT_SOURCE_DIR}/include/*.[h]pp
    ${PROJECT_SOURCE_DIR}/include/*.[h]
    ${PROJECT_SOURCE_DIR}/example/*.[ch]pp
    ${PROJECT_SOURCE_DIR}/example/*.[ch]
)

_ClangFormat(${TARGET_NAME} ${ALL_CODE_FILES})
```

### clang-tidy

When detected, [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) can be enabled by using the option of `-DCLANG_TIDY=ON`.

### include-what-you-use

This tool helps to organize headers for all files encompass all items being used in that file, without accidentally relying upon headers deep down a chain of other headers. This is disabled by default, and can be enabled via have the program installed and adding `-DADD_IWYU=ON`.

### cppcheck

This tool is another static analyzer in the vein of clang-tidy, which focuses on having no false positives. This is by default disabled, and can be enabled via have the program installed and adding `-DADD_CPPCHECK=ON`.