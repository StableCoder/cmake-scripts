// this is an example of an out-of-bounds error with heap data
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    int *array = malloc(sizeof(int));
    printf("val: %i\n", array[1]); // failure point
    free(array);
    return 0;
}