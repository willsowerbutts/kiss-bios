/* packer.c -- pack and unpack structures		*/
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
#include "mytypes.h"
#include "packer.h"

void* unpack(char const *fmt, byte *pk, void *upk)
{
	dword temp;
	void *p = upk;

	while (*fmt) switch (*fmt++) {
		case 'c':	/* character requiring no alignment */
			*(byte*)p = *pk++;
			p += sizeof(byte);
			break;
		case 'b':	/* byte requiring alignment */
			temp = *pk++;
			temp <<= 8;
			*(word*)p = temp;
			p += sizeof(word);
			break;
		case 'w':
			temp = *pk++;
			temp <<= 8;
			temp |= *pk++;
			*(word*)p = wswap(temp);
			p += sizeof(word);
			break;
		case 'd':
			temp = *pk++;
			temp <<= 8;
			temp |= *pk++;
			temp <<= 8;
			temp |= *pk++;
			temp <<= 8;
			temp |= *pk++;
			*(dword*)p = bswap(temp);
			p += sizeof(dword);
			break;
	}
	return upk;
}


dword _uval(byte *p, byte size)
{
	dword value = 0;

	p += size;
	while (size--) {
		value <<= 8;
		value |= *--p;
	}
	return value;
}
