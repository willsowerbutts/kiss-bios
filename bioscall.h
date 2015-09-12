/* bioscall.h */
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


typedef
struct REGS {
	unsigned int	D0,D1,D2,D3,D4,D5,D6,D7;
	void	*A0,*A1,*A2,*A3,*A4,*A5;
	unsigned	unused : 27;
	unsigned	X : 1;
	unsigned	N : 1;
	unsigned	Z : 1;
	unsigned	V : 1;
	unsigned	C : 1;
} T_regs;


int bios_call ( struct REGS *in, struct REGS *out );

/* bioscall.h */
