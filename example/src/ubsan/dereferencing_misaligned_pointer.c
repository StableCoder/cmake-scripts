// example of a program that dereferences a mis-aligned pointer
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
    int *array = malloc(10 * sizeof(int));
    memset(array, 0, 10 * sizeof(int));
    // aligned
    printf("aligned: %i", *array);
    // mis-aligned
    int *misArray = (int *)((char *)(array) + 1);
    printf("aligned: %i", *misArray); // failure point

    free(array);
    return 0;
}