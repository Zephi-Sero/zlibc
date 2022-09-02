#include "stdio.h"
#include "string.h"

int main()
{
	char *const str = "Hello, world!";
	puts(memset(str, 'b', 8));
}
