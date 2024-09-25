// this is an example of a double-free error
#include <stdlib.h>

int main(int argc, char **argv) {
    int *array = (int *)malloc(sizeof(int));
    free(array);
    free(array); // failure point
    return 0;
}