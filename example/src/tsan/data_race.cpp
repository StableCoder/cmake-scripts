#include <stdio.h>
#include <thread>

void threadfunc(int *p) { *p = 1; }

int main() {
    int val = 0;
    std::thread t(threadfunc, &val);
    printf("foo=%i\n", val);
    t.join();
}