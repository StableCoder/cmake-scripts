// example of an indirect memory leak, where a pointer to the memory still exists
#include <stdlib.h>

int main() {
    void *p = malloc(7);
    return 0;
} // failure point