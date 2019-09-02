#include "coverage.hpp"

#include <cmath>

int tested_func(double param1) { return std::sqrt(param1); }

int untested_func(double param1) { return std::sqrt(param1); }