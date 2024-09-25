// example of using an uninitialized pointer
#include <stdio.h>

int main(int argc, char **argv) {
    int *val;
    printf("val: %i", *val);
    return 0;
}