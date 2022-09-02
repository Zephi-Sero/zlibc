#pragma once
#include "unistd.h"



// Emits a formatted null-terminated string onto a file descriptor, excluding
// newline and null terminator.
ssize_t fprintf(size_t const fd, char const *const format, ...);


// Emits a single character onto a file stream descriptor
ssize_t fputc(char const ch, size_t const fd);

// Emits a single character onto a file stream descriptor (Same as fputc)
ssize_t putc(char const ch, size_t const fd);

// Emits a single character onto stdout
ssize_t putchar(char const ch);



// Emits a null-terminated string onto a file descriptor, excluding newline
// and null terminator.
ssize_t fputs(char const *const str, size_t fd);

// Emits a null-terminated string onto a file descriptor, excluding null terminator,
// but suffixed by a newline.
ssize_t puts(char const *const str);
