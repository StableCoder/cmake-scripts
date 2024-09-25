// this is an example of a use-after-free error
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    int *array = malloc(sizeof(int));
    free(array);
    printf("val: %i\n", *array); // failure point
    return 0;
}