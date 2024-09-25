// this is an example of a use-after-scope error
#include <stdio.h>

int main(int argc, char **argv) {
    int *array;
    {
        int internalArray[1];
        array = internalArray;
    }
    printf("val: %i\n", array[0]); // failure point
    return 0;
}