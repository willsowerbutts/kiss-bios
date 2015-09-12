#  bioscall.s
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
/*  C-callable:

      int bios_call ( struct REGS *in, struct REGS *out );
*/
	.globl	bios_call
bios_call:
	link	%a6,#0
	movm.l	%d2-%d7/%a2-%a5,-(%sp)

	move.l	8(%a6),%a0
	movm.l	(%a0),%d0-%d7/%a0-%a5
	trap	#8
	move.w	%sr,-(%sp)
	clr.w	-(%sp)
	move.l	%a5,-(%sp)
	move.l	12(%a6),%a5
	movm.l	%d0-%d7/%a0-%a4,(%a5)
	move.l	(%sp)+,52(%a5)
	move.l	(%sp)+,56(%a5)

	movm.l	-40(%a6),%d2-%d7/%a2-%a5
	unlk	%a6
	rts

	.end

