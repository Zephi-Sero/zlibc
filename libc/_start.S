.global _start
.global _exit
_start:
	xorl %ebp, %ebp
	movq 0(%rsp), %rdi
	lea 8(%rsp), %rsi
	call main
	movq %rax, %rdi
_exit:
	movq $60, %rax
	syscall
	hlt
