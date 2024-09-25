// this is an example of a use-after-return error
#include <stdio.h>

int *array;

void setPointerWithEscapedData() {
    int internalArray[1];
    array = internalArray;
}

int main(int argc, char **argv) {
    setPointerWithEscapedData();
    printf("val: %i\n", array[0]); // failure point
    return 0;
}