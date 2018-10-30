#include <functional>
#include <map>
#include <stdio.h>
#include <string>
#include <thread>

typedef std::map<std::string, std::string> map_t;

void *threadfunc(void *p) {
    map_t &m = *(map_t *)p;
    m["foo"] = "bar";
    return 0;
}

int main() {
    map_t m;
    std::thread t(threadfunc, &m);
    printf("foo=%s\n", m["foo"].c_str());
    t.join();
}