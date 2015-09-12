#  memtest2.s  -- derived from 'memtest.s'
/*
	Copyright (C) 2011,2015 John R. Coffman.
	Licensed for hobbyist use only.
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


/*
   Enter with:
	A0 is the highest address to test + 1
	A1 is the lowest address to test
	A6 is the return address

   Returns:
	D6 is the compare failure count (>0 is okay)


*/	.globl	memtest
	.globl	_memtest
memtest:
	move.l	(%sp)+,%a6		/* return always from A6  */

_memtest:				/* entry to use no stack  */
	clr.l	%d6

	move.l	%a0,%d2
	sub.l	%a1,%d2			/* D2 is the length in bytes */
/* assume that maxchip is 32k */
	lsr.l	#2,%d2			/* D2 is the length in long words */

l1:
	move.l	%d2,%d3
	move.l	%a0,%a1			/* A1 is copy of high address */

	move.l	#0x12EDB748,%d4
	or	#0x10,%ccr		/* set the X-bit */

# fill loop
	jbra	l13	
l11:
	swap	%d3
l12:
	move.l	%d4,-(%a1)
	roxl.l	#1,%d4
l13:	dbra.w	%d3,l12
	swap	%d3
	dbra.w	%d3,l11

# 	move.b	#0x14,(lites).w

	move.l	%a0,%a1			/* copy high address to A1 */
	move.l	%d2,%d3

	move.l	#0x12EDB748,%d4
	or	#0x10,%ccr		/* set the X-bit */
# compare loop
	jbra	l23
l21:
	swap	%d3
l22:
	move.l	%d4,%d5
	roxl.l	#1,%d4
	cmp.l	-(%a1),%d5	/* does not affect the X bit */
	jbeq	l222

	move	%ccr,%d0
	add.l	#1,%d6
# 	move.b	#0x15,(lites).w
	move	%d0,%ccr	/* restore the X bit */

l222:	dbra.w	%d3,l22
l23:	swap	%d3
	dbra.w	%d3,l21

# 	move.b	#0x16,(lites).w
	jmp	(%a6)		/* return to caller */

#################################################
#################################################
#################################################

/*
   Enter with:
	A1 is the address to test
	A6 is the return address

   Returns:
	D6 is the compare failure count

*/

bytetest:
	move.l	(%sp)+,%a6		/* return through A6 */

_bytetest:
	clr.l	%d6

	move.l	#0x01020408,(%a1)
	nop

	cmp.b	#0x01,0(%a1)
	jbeq	bt1
	add	#1,%d6
bt1:
	cmp.b	#0x02,1(%a1)
	jbeq	bt2
	add	#2,%d6
bt2:
	cmp.b	#0x04,2(%a1)
	jbeq	bt4
	add	#4,%d6
bt4:
	cmp.b	#0x08,3(%a1)
	jbeq	bt8
	add	#8,%d6
bt8:

	cmp.w	#0x0408,2(%a1)
	jbeq	bw2
	add	#32,%d6
bw2:
	cmp.w	#0x0102,(%a1)
	jbeq	bw1
	add	#16,%d6
bw1:

	cmp.w	#0x0204,1(%a1)
	jbeq	bw3
	add	#64,%d6
bw3:

	move.b	#0x10,0(%a1)
	cmp.l	#0x10020408,(%a1)
	jbeq	bb1
	add	#1,%d6
bb1:
	move.b	#0x20,1(%a1)
	cmp.l	#0x10200408,(%a1)
	jbeq	bb2
	add	#2,%d6
bb2:
	move.b	#0x30,2(%a1)
	cmp.l	#0x10203008,(%a1)
	jbeq	bb3
	add	#4,%d6
bb3:
	move.b	#0x80,3(%a1)
	cmp.l	#0x10203080,(%a1)
	jbeq	bb4
	add	#8,%d6
bb4:
	move.w	#0x0204,1(%a1)
	cmp.l	#0x10020480,(%a1)
	jbeq	bb5
	add	#64,%d6
bb5:
	move.w	#0x1122,0(%a1)
	cmp.l	#0x11220480,(%a1)
	jbeq	bb6
	add	#16,%d6
bb6:
	move.w	#0x3344,2(%a1)
	cmp.l	#0x11223344,(%a1)
	jbeq	bb7
	add	#32,%d6
bb7:

/* the sulfuric acid test */

	move.l	%a6,-(%sp)		/* save return address */

	movm.l	%d0-%d7/%a0-%a6,-(%sp)

	movm.l	%d0-%d7/%a0-%a6,2(%a1)	/* pound into memory */
	movm.l	2(%a1),%d0-%d7/%a0-%a6	/* retrieve from mem. */

	cmp.l	(%sp),%d0
	jbne	err6
	cmp.l	4(%sp),%d1
	jbne	err6
	cmp.l	8(%sp),%d2
	jbne	err6
	cmp.l	12(%sp),%d3
	jbne	err6
	cmp.l	16(%sp),%d4
	jbne	err6
	cmp.l	20(%sp),%d5
	jbne	err6
	cmp.l	24(%sp),%d6
	jbne	err6
	cmp.l	28(%sp),%d7
	jbne	err6
	cmp.l	32(%sp),%a0
	jbne	err6

	lea	36(%sp),%a0
	cmp.l	(%a0)+,%a1
	jbne	err6
	cmp.l	(%a0)+,%a2
	jbne	err6
	cmp.l	(%a0)+,%a3
	jbne	err6
	cmp.l	(%a0)+,%a4
	jbne	err6
	cmp.l	(%a0)+,%a5
	jbne	err6
	cmp.l	(%a0)+,%a6
	jbne	err6

	movm.l	(%sp)+,%d0-%d7/%a0-%a6	/* restore */
	jbra	noerr7	
err6:
	movm.l	(%sp)+,%d0-%d7/%a0-%a6	/* restore */
	add.b	#128,%d6		/* set error code */
noerr7:
	move.l	(%sp)+,%a6		/* restore return */


	jmp	(%a6)

#################################################

/*
   Enter with:
	A0 is the highest address to test + 1
	A1 is the lowest address to test
	A6 is the return address

	D0 is the pattern to put into memory

   Returns:
	Nothing
*/

.if 0
memput:
	move.l	(%sp)+,%a6
_memput:
	move.l	%a0,%d7
	sub.l	%a1,%d7			/* D2 is the length in bytes */
	lsr.l	#2,%d7			/* count in longs */

	move.l	%a1,%a2			/* A2 is the working address reg. */
	jbra	mmpt2
mmpt0:	swap	%d7
mmpt1:	move.l	%d0,(%a2)+
mmpt2:	dbra.w	%d7,mmpt1
	swap	%d7
	dbra.w	%d7,mmpt0
	swap	%d7
	jmp	(%a6)
.endif

/*
   Enter with:
	A0 is the highest address to test + 1
	A1 is the lowest address to test
	A6 is the return address

	D0 is the pattern to compare with memory

   Returns:
	D6 is the error count
*/

memcmp:
	move.l	(%sp)+,%a6
_memcmp:
	clr.l	%d6			/* zero the error count */
	move	%a1,%a2			/* A2 is the working address reg. */
mc1:	cmp.l	(%a2)+,%d0
	jbeq	mc2
	add.l	#1,%d6
mc2:
	nop
	cmp	%a2,%a0
	jbne	mc1
	jmp	(%a6)


/*  The LED flashing stuff is below */


/*
   Enter with:
	D5 is the R/G LED 'on' time in tenths of a second
	Instruction Cache enabled

   Returns:
	D5 is trashed
*/

LED_on:
	move.l	(%sp)+,%a6
_LED_on:
	mulu.l	#3000,%d5
	jbra	lon0
lon2:	swap	%d5
lon1:	reset
lon0:	dbra.w	%d5,lon1
	swap	%d5
	dbra.w	%d5,lon2
	jmp	(%a6)
	

/*
   Enter with:
	D5 is the R LED 'off' time in tenths of a second
	  Instruction Cache enabled

   Returns:
	D5 is trashed
*/

LED_off:
	move.l	(%sp)+,%a6
_LED_off:
	mulu.l	#200000,%d5
	jbra	loff0
loff2:	swap	%d5
loff1:	nop
loff0:	dbra.w	%d5,loff1
	swap	%d5
	dbra.w	%d5,loff2
	jmp	(%a6)
	


/*  Blink
	skip if (switches) bit 5 set


   Enter with:
	D0.w	blink count

   Returns:
	D0 is trashed
	D5 is trashed
*/

Blink:
	move.l	(%sp)+,%a5
_Blink:
#	btst	#5,(switches).w
#	jbne	blink9			/* skip if switch set */

	jbra	blink0
blink1:
	move.l	#3,%d5			/* 0.3 sec off */
	lea	(bld1,%pc),%a6		/* JSR LED_off */
	jbra	_LED_off
bld1:	move.l	#5,%d5			/* 0.5 sec on */
	lea	(bld2,%pc),%a6
	jbra	_LED_on
bld2:	move.l	#3,%d5	      		/* 0.2 sec off */
	lea	(bld3,%pc),%a6
	jbra	_LED_off
bld3:
blink0:
	dbra.w	%d0,blink1
blink9:
	jmp	(%a5)
 
