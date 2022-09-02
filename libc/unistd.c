#include "unistd.h"

ssize_t write(size_t fd, const char *buf, size_t n)
{
	asm(
		"movq 24(%rsp), %rdi\n"
		"movq 16(%rsp), %rsi\n"
		"movq 8(%rsp), %rdx\n"
		"movl $1, %rax\n"
		"syscall\n"
	);
	return 0;
}
