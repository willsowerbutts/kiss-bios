#include "string.h"
#include "ctype.h"

/* Based on string.c
 * Copyright (C) 1995,1996 Robert de Bath <rdebath@cix.compulink.co.uk>
 * This file was part of the Linux-8086 C library and is distributed
 * under the GNU Library General Public License.
 */  

void *memcpy(void *dest, const void *src, size_t len)
{
    unsigned char *dp = dest;
    const unsigned char *sp = src;
    while(len-- > 0)
        *dp++=*sp++;
    return dest;
}

int memcmp(const void *mem1, const void *mem2, size_t len)
{
    const signed char *p1 = mem1, *p2 = mem2;

    if (!len)
        return 0;

    while (--len && *p1 == *p2) {
        p1++;
        p2++;
    }

    return *p1 - *p2;
}

void *memset(void *dest, int data, size_t len)
{
    char *p = dest;
    char v = (char)data;

    while(len--)
        *p++ = v;

    return dest;
}

void *memmove(void *dest, const void *src, size_t len)
{
    unsigned char *dp = dest;
    const unsigned char *sp = src;

    if (sp < dp) {
        dp += len;
        sp += len;
        while(len--)
            *--dp = *--sp;
    } else {
        while(len--)
            *dp++ = *sp++;
    }
    return dest;
}

void *memchr(const void *str, int c, size_t l) 
{
    const char *p = str;

    while (l-- != 0) {
        if (*p == c)
            return (void*) p;
        p++;
    }

    return NULL;
}

char *strchr(const char *s, int c) 
{
    for (;;) {
        if (*s == c)
            return (char*)s;
        if (*s == 0)
            return 0;
        s++;
    }
}

size_t strlen(const char *t)
{
    size_t l = 0;
    while (*t++)
        l++;
    return l;
}

int strcasecmp(const char *s, const char *d)
{
    for(;;)
    {
        if( *s != *d )
        {
            if( tolower(*s) != tolower(*d) )
                return *s - *d;
        }
        else if( *s == '\0' ) break;
        s++; d++;
    }
    return 0;
}

int strncasecmp(const char *s, const char *d, size_t l)
{
    while(l>0)
    {
        if( *s != *d )
        {
            if( tolower(*s) != tolower(*d) )
                return *s - *d;
        }
        else
            if( *s == '\0' ) return 0;
        s++; d++; l--;
    }
    return 0;
}

char *strncat(char *d, const char *s, size_t l) 
{
    char *s1 = d + strlen(d), *s2 = memchr(s, 0, l);

    if (s2)
        memcpy(s1, s, s2 - s + 1);
    else {
        memcpy(s1, s, l);
        s1[l] = '\0';
    }
    return d;
}

unsigned long int strtoul(const char *nptr, char **endptr, int base)
{
    unsigned long int number;

    /* Sanity check the arguments */
    if (base==1 || base>36 || base<0)
        base=0;

    /* advance beyond any leading whitespace */
    while (isspace(*nptr))
        nptr++;

    /* check for optional '+' or '-' */
    if (*nptr=='-')
        nptr++;
    else
        if (*nptr=='+')
            nptr++;

    /* If base==0 and the string begins with "0x" then we're supposed
     *      to assume that it's hexadecimal (base 16). */
    if (base==0 && *nptr=='0')
    {
        if (toupper(*(nptr+1))=='X')
        {
            base=16;
            nptr+=2;
        }
        /* If base==0 and the string begins with "0" but not "0x",
         *      then we're supposed to assume that it's octal (base 8). */
        else
        {
            base=8;
            nptr++;
        }
    }

    /* If base is still 0 (it was 0 to begin with and the string didn't begin
     *      with "0"), then we are supposed to assume that it's base 10 */
    if (base==0)
        base=10;

    number=0;
    while (isascii(*nptr) && isalnum(*nptr))
    {
        int ch = *nptr;
        if (islower(ch)) ch = toupper(ch);
        ch -= (ch<='9' ? '0' : 'A'-10);
        if (ch>base)
            break;

        number= (number*base)+ch;
        nptr++;
    }

    /* Some code is simply _impossible_ to write with -Wcast-qual .. :-\ */
    if (endptr!=NULL)
        *endptr=(char *)nptr;

    /* All done */
    return number;
}

int atoi(const char *nptr)
{
    return strtol(nptr, NULL, 10);
}

long int strtol(const char *nptr, char **endptr, int base)
{
    const char * ptr;
    unsigned short negative;
    long int number;

    ptr=nptr;

    while (isspace(*ptr))
        ptr++;

    negative=0;
    if (*ptr=='-')
        negative=1;

    number=(long int)strtoul(nptr, endptr, base);

    return (negative ? -number:number);
}

char *strncpy(char *d, const char *s, size_t l) 
{
    char *s1 = d;
    const char *s2 = s;

    while (l) {
        l--;
        if ((*s1++ = *s2++) == '\0')
            break;
    }

    /* This _is_ correct strncpy is supposed to zap */ 
    while (l-- != 0)
        *s1++ = '\0';
    return d;
}

int strcmp(const char *d, const char *s) 
{
    char *s1 = (char *) d, *s2 = (char *) s, c1, c2;

    while ((c1 = *s1++) == (c2 = *s2++) && c1);
    return c1 - c2;
}

int tolower(int c)
{
	unsigned char cb = c;
	if ((cb >= 'A') && (cb <= 'Z'))
		cb ^= 0x20;
	return cb;
}

int toupper(int c)
{
	unsigned char cb = c;
	if ((cb >= 'a') && (cb <= 'z'))
		cb ^= 0x20;
	return cb;
}

int isalnum(int c)
{
	return isdigit(c) || isalpha(c);
}

int isalpha(int c)
{
	return isupper(c) || islower(c);
}

int isascii(int c)
{
	return !((unsigned char)c & 0x80);
}

int isblank(int c)
{
	return ((unsigned char)c == ' ') || ((unsigned char)c == '\t');
}

int iscntrl(int c)
{
	return (((unsigned char)c >= 0) && ((unsigned char)c <= 31)) || ((unsigned char)c == 127);
}

int isdigit(int c)
{
	return ((unsigned char)c >= '0') && ((unsigned char)c <= '9');
}

int isgraph(int c)
{
	return ((unsigned char)c >= 33) && ((unsigned char)c <= 126);
}

int islower(int c)
{
	return ((unsigned char)c >= 'a') && ((unsigned char)c <= 'z');
}

int isprint(int c)
{
	return ((unsigned char)c >= 32) && ((unsigned char)c <= 126);
}

int ispunct(int c)
{
	return isascii(c) && !iscntrl(c) && !isalnum(c) && !isspace(c);
}

int isspace(int c)
{
	return ((unsigned char)c == ' ') ||
	       ((unsigned char)c == '\t') ||
		   ((unsigned char)c == '\n') ||
		   ((unsigned char)c == '\r') ||
		   ((unsigned char)c == '\f') ||
		   ((unsigned char)c == '\v');
}

int isupper(int c)
{
	return ((unsigned char)c >= 'A') && ((unsigned char)c <= 'Z');
}

int isxdigit(int c)
{
	unsigned char bc = c;
	if (isdigit(bc))
		return 1;
	bc |= 0x20;
	return ((bc >= 'a') && (bc <= 'f'));
}
