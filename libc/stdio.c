#include "unistd.h"
#include "stdio.h"



ssize_t fputc(char const ch, size_t fd)
{
	return write(fd, &ch, 1);
}

ssize_t putc(char const ch, size_t fd)
{
	return fputc(ch, fd);
}

ssize_t putchar(char const ch)
{
	return fputc(ch, 1);
}



ssize_t fputs(char const *const str, size_t fd)
{
	size_t len = 0;
	while(str[len++] != '\0');
	write(fd, str, len - 1);
	fputc('\n', fd);
	return 0;
}

ssize_t puts(char const *const str)
{
	return fputs(str, 1);
}



ssize_t fprintf(size_t const fd, char const *const format, ...)
{

}

ssize_t printf(char const *const format, ...)
{

}
