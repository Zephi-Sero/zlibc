#include "string.h"

void *memset(void *const data, unsigned char const setTo, size_t const len)
{
	unsigned char *const d = data;
	for (size_t i = 0; i < len; d[i++] = setTo);
	return data;
}
