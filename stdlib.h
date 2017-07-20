#ifndef __STDLIB_DOT_H__
#define __STDLIB_DOT_H__

typedef unsigned int size_t;

/* various bits of gcc we need */
extern void *malloc (size_t __size) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__malloc__)) ;

extern void *realloc (void *__ptr, size_t __size)
         __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__warn_unused_result__));

extern void free (void *__ptr) __attribute__ ((__nothrow__ , __leaf__));

#ifndef NULL
# if defined __GNUG__ && \
        (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 8))
#  define NULL (__null)
# else
#  if !defined(__cplusplus)
#   define NULL ((void*)0)
#  else
#   define NULL (0)
#  endif
# endif
#endif

#endif
