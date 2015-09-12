/* main68.h */
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
#ifndef _MAIN68_H
#define _MAIN68_H
#include "mytypes.h"
#include "portab.h"

#define nelem(x)	(sizeof(x)/sizeof(*x))
// #define toupper(x) ((x)>='a'&&(x)<='z'?(x)+('A'-'a'):(x))
#define GETLINE(buf) getline(buf,nelem(buf))
#define GETUCLINE(buf) uc_string(buf,getline(buf,nelem(buf)))

typedef
struct NVRAM {
	byte	sio_div_lo;
	byte	sio_div_hi;
	byte	century;			/* in BCD */
	signed boot_disk_1 : 4;
	signed boot_disk_2 : 4;
	byte	nboards;
	struct BOARD {
		byte	port;
		byte	type;
	} board[4];
	struct FLOPPY_NV {
		byte	port;
		byte	type;
	} floppy[2];
} T_nv_struct;

extern long h_m_a;
extern char debug;

int cprintf(char const *fmt, ...);
int uc_string(char *str, int length);
int getline(char *line, int linesize);
void prbuf(dword addr, byte *buf, int n);
void regdump(void);

#endif  // _MAIN68_H

