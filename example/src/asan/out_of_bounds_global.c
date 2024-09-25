// this is an example of an out-of-bounds error with global data
#include <stdio.h>

int array[1];

int main(int argc, char **argv) {
    printf("val: %i\n", array[1]); // failure point
    return 0;
}