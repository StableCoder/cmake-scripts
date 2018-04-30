# CMake Scripts

This is a collection of quite useful scripts that expand the possibilities for building software with CMake, by making some things easier and otherwise adding new build types.

## C++ Standards

`c++-standards.cmake`

Using the functions `_Cxx11()`, `_Cxx14()` or `_Cxx17()` this adds the appropriated flags for both unix and MSVC compilers, even for those before 3.11 with improper support.

## Sanitizer Builds

`sanitizer-builds.cmake`

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

These are used by changing the build type to one of the following:
- asan
- lsan
- tsan
- msan
- ubsan
Like so `-DCMAKE_BUILD_TYPE=asan`.

## Tools

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

_ClangFormat(stec_audio ${ALL_CODE_FILES})
```

### clang-tidy

When detected, [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) is automatically added and run, unless it is disabled via `-DNO_CLANG_TIDY=ON`.

### include-what-you-use

This tool helps to organize headers for all files encompass all items being used in that file, without accidentally relying upon headers deep down a chain of other headers. This is disabled by default, and can be enabled via have the program installed and adding `-DADD_IWYU=ON`.

### cppcheck

This tool is another static analyzer in the vein of clang-tidy, which focuses on having no false positives. This is by default disabled, and can be enabled via have the program installed and adding `-DADD_CPPCHECK=ON`.