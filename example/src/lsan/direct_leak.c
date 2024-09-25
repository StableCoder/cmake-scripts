// example of a direct memory leak, where no pointer to the memory exists
#include <stdlib.h>

int main() {
    void *p = malloc(7);
    p = 0; // failure point
    return 0;
}