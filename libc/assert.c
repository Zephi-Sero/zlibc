#include "assert.h"
#include "stdlib.h"

void _assert_failed(char const *const assertion)
{
	puts("Assertion failed:");
	puts(assertion);
	exit(ASSERT_EXIT);
}
