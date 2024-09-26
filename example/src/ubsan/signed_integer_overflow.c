// example program that performs a signed integer overflow
int main(int argc, char **argv) {
    int k = 0x7fffffff;
    k += argc; // failure point
    return 0;
}