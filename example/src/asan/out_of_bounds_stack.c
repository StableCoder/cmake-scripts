// this is an example of an out-of-bounds error with stack data
#include <stdio.h>

int main(int argc, char **argv) {
    int array[1];
    printf("val: %i\n", array[1]); // failure point
    return 0;
}