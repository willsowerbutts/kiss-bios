#ifndef __STRING_DOT_H__
#define __STRING_DOT_H__

#include <stdlib.h>

void *memcpy(void *dest, const void *src, size_t len);
void *memmove(void *dest, const void *src, size_t len);
int memcmp(const void *mem1, const void *mem2, size_t len);
void *memset(void *dest, int data, size_t len);
void *memchr(const void *str, int c, size_t l);
char *strchr(const char *s, int c);
size_t strlen(const char *t);
int strncasecmp(const char *s, const char *d, size_t l);
int strcasecmp(const char *s, const char *d);   
char *strncat(char *d, const char *s, size_t l);
unsigned long int strtoul(const char *nptr, char **endptr, int base);
long int strtol(const char *nptr, char **endptr, int base);
char *strncpy(char *d, const char *s, size_t l);
int strcmp(const char *d, const char *s);

#endif
