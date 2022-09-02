#include "stdlib.h"
#include "stdio.h"



#define ASSERT_EXIT 1
#define assert(x) ((x) ?: _assertion_failed(#x))

void _assertion_failed(char const *const assertion);
