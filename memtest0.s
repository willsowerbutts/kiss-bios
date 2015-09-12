#  memtest.s
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
#
maxaddr		=	2*1024*1024
maxchip		=	32*1024
maxcount	=	maxaddr/maxchip
chiplong	=	maxchip/4

/*
   Enter with:
	A0 is the highest address to test + 1
	A6 is the return address

   Returns:
	D6 is the compare failure count (>0 is okay)
	A4 is the lowest address tested (should be 0)
	A5 is the highest address okay + 1

*/	
memtest:
	clr.l	%d6

	move.l	%a0,%d2
/* assume that maxchip is 32k */
	lsr.l	#8,%d2
	lsr.l	#7,%d2
	sub.w	#1,%d2

	beq.s	l0
	sub.w	#1,%d2
l0:

	move.l	%a0,%a5
	move.l	#0x12EDB748,%d4

l1:
	move.w	#chiplong-1,%d3
	move.l	%a0,%a1

#	move.l	%a1,%d0
#	bsr	lout

# fill loop
l12:
	move.l	%d4,-(%a1)
	dbra.w	%d3,l12

	move.w	#chiplong-1,%d3
	move.l	%a0,%a1
# compare loop
l13:
	cmp.l	-(%a1),%d4

	dbne.w	%d3,l13
	beq.s	l19
	move.l	%a1,%a5
	add.l	#1,%d6

	lea.l	-maxchip+4(%a1),%a1
l16:
	cmp.l	(%a1)+,%d4
	dbne.w	%d3,l16
	beq.s	l19
	lea.l	-4(%a1),%a5
	add.l	#1,%d6
l19:

	lea.l	-maxchip(%a0),%a0
   	dbra.w	%d2,l1
	
	move.l	%a0,%a4
/* return A5 = highest address + 1
	  A4 = lowest address tested	*/

	move.l	%a6,-(%sp)
	rts



#################################################


