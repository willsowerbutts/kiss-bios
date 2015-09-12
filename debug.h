/* debug.h  -- Declarations for the mini-M68k debugger  */
/*
	Copyright (C) 2011,2012 John R. Coffman.
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
#ifndef _DEBUG_H
#define _DEBUG_H 1
#include "mytypes.h"

#define BREAK_LIMIT_LOW 0x1000
#if (M68000==68008)
#define BREAK_LIMIT_HIGH 0x00380000
#define BREAK_LIMIT_MASK 0x003FFFFF
#elif (M68000<68020)
#define BREAK_LIMIT_HIGH 0x00F80000
#define BREAK_LIMIT_MASK 0x00FFFFFF
#else
#define BREAK_LIMIT_HIGH 0xFFFF0000
#define BREAK_LIMIT_MASK 0xFFFFFFFF
#endif

extern
struct STATUS {
	long	d[8];
	long	a[7];		/* saved A7 is always SSP */
	long	ssp;		/* Supervisor SP */
	long	usp;		/* the USP */
	long	pc;
	word	unused;
	word	sr;		/* high word MBZ; low word is SR */
} state;

typedef
struct BREAK {
	long	where;	/* word location of the breakpoint */
	word	instr;	/* original instruction at the location */
	word	status;	/* status bits */
} T_break;

#define	MAXBREAKS  16	/* maximum number of breakpoints */
		/* actually there is one more, break[0] is used to step over a call */
#define	INSBREAK		0x4AFC		/* ILLEGAL instruction */
/* status bits:			*/
#define BR_USED	0x01		/* breakpoint entry is used */
#define BR_ENBL	0x02		/* breakpoint is enabled ==> used is set */


/* definition for symbol table usage */
typedef
struct SYMBOL {
	long	value;	/* value of the symbol */
	char *name;		/* pointer to the name string */
	word	length;	/* strlen(name) */
} T_symbol;


void debug68(int);
void Trace(int);
void Go(int);

void install_breaks(void);
void remove_breaks(void);

#endif
