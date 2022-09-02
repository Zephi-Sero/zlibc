#include "stdlib.h"
#include "stdio.h"



#define ASSERT_EXIT 1
#define assert(x) ((x) ?: _assert_failed(#x))

void _assert_failed(char const *const assertion);
