/* mytypes.h	*/
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
#ifndef _MYTYPES_H
#define _MYTYPES_H 1

#define M68000 68030

typedef signed char			int8;
typedef signed short int	int16;
typedef signed long int		int32;

typedef unsigned char		uint8;
typedef unsigned short int	uint16;
typedef unsigned long int	uint32;

typedef unsigned char		byte;
typedef unsigned short int	word;
typedef unsigned long int	dword;

#ifdef M68000
typedef unsigned long long	qword;
typedef unsigned long long	uint64;
typedef signed long long	int64;
#endif

#ifndef NULL
#define NULL ((void*)0)
#endif	// NULL


#endif	// _MYTYPES_H
