/*  malloc.c	*/
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
#include <stdlib.h>

void * mem_chain;		/* points at next block to allocate */

void *malloc(size_t size)
{
	register void * memory;
	register int sizee;
	
	sizee = (size + (sizeof(int)-1)) & (-sizeof(int));
	memory = mem_chain;
	mem_chain += sizee;
	memset(memory, 0, sizee);

	return memory;
}


