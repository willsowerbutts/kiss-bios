/* strtoul.c	String to unsigned long			*/
/*
	Copyright (C) 2011 John R. Coffman.
	Licensed for hobbyist use on the N8VEM baby M68k CPU board.
***********************************************************************

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    in the file COPYING in the distribution directory along with this
    program.  If not, see <http://www.gnu.org/licenses/>.

**********************************************************************/
#include <stdlib.h>		// for errno
#include <limits.h>
#include "mytypes.h"

#define SP 040
#define HT 011
#define RUB 0377
/* 
 *  radix may be in [2..16] or zero for automatic determination of radix
 *
 *  cp is first advanced over whitespaces (SP or HT), then the conversion
 *  is done.
 *
 *  errno is set if an error occurs
 *
 */

int errno;		/* should be in stdlib */

int atoi(const char *cp)
{
	return (int)strtoul(cp, NULL, 0);
}

static
char ndigit(char ch)
{
    register char c;
    
    c = ch;
    
    if (c >= '0' && c <= '9') c -= '0';
    else if (c >= 'A' && c <= 'Z') c -= ('A'-10);
    else if (c >= 'a' && c <= 'z') c -= ('a'-10);
    else c = RUB;

//    printf("exit ndigit   c = %d\n", (int)c);    
    return c;
}

unsigned long strtoul(const char *cptr, char **endptr, int radix)
{
    signed char sign = 0;
    unsigned long int  value = 0UL;
    const char *cp;
    byte digit;
    unsigned long int  max;
    byte maxdigit;

    cp = cptr;    
    errno = 0;
    while (*cp == SP  ||  *cp == HT) ++cp;
    
    if (*cp == '-') sign = -1, ++cp;
    else if (*cp == '+') sign = 1, ++cp;
    
    digit = ndigit(*cp);
//    printf("stage 1   digit=%d\n", (int)digit);
    if (radix == 0) {
        if (digit == 0) {
            radix = 8;
            ++cp;
            if (ndigit(*cp) == 'X'-'A'+10 /* 33 == 'X' */ ) {
                radix = 16;
                digit = ndigit(*++cp);
            }
            else --cp;
        }
        else radix = 10;
    }
    else if (radix == 16  &&  digit == 0  &&  ndigit(cp[1]) == 33) ++cp;
    
//    printf("stage 2   radix=%d\n", (int)radix);
    if (digit >= radix) {	/* invalid digit */
        cp = cptr;
		  cp--;
        errno = 1;
    }
    else {
//        printf("stage 3\n");
        max = ULONG_MAX / radix;
        maxdigit = ULONG_MAX % radix;

//        printf("stage 4\n");
        value = digit;
        while ( (digit = ndigit(*++cp)) != RUB) {
            if (digit < radix  &&  (value < max || (value == max && digit <= maxdigit)) ) {
                value *= radix;
                value += digit;
            }
            else {
                errno = 1;
                value = 0;
                ++cp;
            }
        }
        --cp;
        if (sign<0) value = -(signed long int)value;
    }
    if (endptr) *endptr = (char*) ++cp;    
    
    return value;
}





