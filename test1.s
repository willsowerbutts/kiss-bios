/* test1.s	*/
/*
	Copyright (C) 2015 John R. Coffman.
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
	.text

#.include "cache.s"

#  Cache control bits in the CACR

CACR_EI		=	1	/* Enable Instruction Cache		*/
CACR_FI		=	1<<1	/* Freeze Instruction Cache		*/
CACR_CEI	=	1<<2	/* Clear Entry in Instr. Cache		*/
CACR_CI		=	1<<3	/* Clear Instruction Cache		*/
CACR_IBE	=	1<<4	/* Instr. Cache Burst Enable		*/

CACR_ED		=	1<<8	/* Enable Data Cache			*/
CACR_FD		=	1<<9	/* Freeze Data Cache			*/
CACR_CED	=	1<<10	/* Clear Entry in Data Cache		*/
CACR_CD		=	1<<11	/* Clear Data Cache			*/
CACR_DBE	=	1<<12	/* Data Cache Burst Enable		*/
CACR_WA		=	1<<13	/* Write Allocate the Data Cache	*/



KISS68030_IO	=	0xFFFF8000	/* needed to do I/O */

/* debugging lights and switches:				*/
lites		=	0xFF + KISS68030_IO	/* output only */
switches	=	lites			/* input only */

/* values for switch control */
HOE		=	0x80		/* Halt On Error */
LOOP		=	0x40		/* Loop Continuously */
NOBLINK		=	0x20		/* Suppress blink */

BANK0		=	1
BANK1		=	2
BANK3		=	4
BANK4		=	8



	.globl	location_zero

location_zero:
	.long	0xFFFE7FF0		/* Reset:  initial SSP */
	.long	_start			/* Reset:  initial PC  */

    .globl _start
_start:
	move.b	#0x81,(lites).w		/* display in the lights */

/* DRAM startup */
	move.w	#8-1,%d2		/* outer counter */
DRAM_start00:
	lea	(dram,%pc),%a3
DRAM_start:
	move.l	(%a3)+,%d0
	bmi.s	DRAM_started

	move	%d0,%a0			/* use A0 */
	move.w	#4096,%d1		/* count 4K addresses  */
DRAM_s0:
	move.l	(%a0)+,%d0		/* D0 is scratch */
	dbra	%d1,DRAM_s0		/* just do 4K read refreshes */

	lea	8(%a3),%a3		/* bump to next address */
	br.s	DRAM_start
DRAM_started:
	dbra	%d2,DRAM_start00	/* loop back 8 times */

CACR_DIAG = CACR_CD + CACR_CI + CACR_EI

	move	#CACR_DIAG,%d6		/* enable instruction cache */
	movec	%d6,%cacr

	move.b	#0x5A,(lites).w		/* display in the lights */

	move.l	#0xFFFF0000,%a0		/* SRAM end+1 */
	move.l	#0xFFFE8000,%a1		/* SRAM start */
	clr.l	%d0
	lea	retp0,%a6
	jbra	_memput
retp0:
	move.b	#0xA5,(lites).w		/* display in the lights */

.if 0
	move.l	#0xFFFE8000,%a1		/* SRAM end */
	move.l	#0xFFFE0000,%a1		/* SRAM start */
	lea	retc0,%a6
	jbra	_memcmp
retc0:
	move.l	%d6,%d6			/* test for zero */
	bne.w	stop0
.endif

	move.l	#1000000,%d5		/* delay */

	br.s	run0
run2:	swap	%d5
run1:	nop
run0:	dbra	%d5,run1
	swap	%d5
	dbra	%d5,run2

	move.b	#0xCC,(lites).w		/* display in the lights */
.if 0
	move.l	#100000,%d5		/* delay */
	br.s	rr0
rr2:	swap	%d5
rr1:	reset
rr0:	dbra	%d5,rr1
	swap	%d5
	dbra	%d5,rr2
.endif
	move.b	(switches).w,%d5
	move.b	%d5,(lites).w		/* display in the lights */
.if 0
	move.l	#50000,%d5		/* delay */
	br.s	rs0
rs2:	swap	%d5
rs1:	reset
rs0:	dbra	%d5,rs1
	swap	%d5
	dbra	%d5,rs2
.endif

/* end of test1, now do the memory test */

	move.b	#0x33,(lites).w

	move.l	#0xFFFF0000,%a0		/* end SRAM, begin I/O */
	move.l	#0xFFFE0000,%a1		/* begin SRAM  */
	lea	return1,%a6
	jbra	_memtest
return1:
	clr.b	%d7			/* no errors */
	cmp.l	#0xFFFE0000,%a4		/* end SRAM, begin I/O */
	beq.s	ok1
	or.b	#1,%d7
ok1:	cmp.l	#0xFFFF0000,%a5
	beq.s	ok2
	or.b	#2,%d7
ok2:	or.l	%d6,%d6
	beq.s	ok3
	or.b	#4,%d7
ok3:	or.b	#0x70,%d7
	move.b	%d7,(lites).w
	and.b	#0x0F,%d7
	bne	stop0	

/* test the byte parity	*/
	move.l	#0xFFFE0000,%a1		/* begin SRAM  */

	lea	breturn1,%a6
	jbra	_bytetest
breturn1:
	move.l	%d6,%d6
	beq.s	bsram
	move.b	%d6,(lites).w
	jbra	stop0
bsram:	

/************************************************************************/
/*   below this point we may begin to use the SRAM stack		*/
/************************************************************************/
.if 0
	move.l	#25,%d5
	bsr	LED_off
.endif
	move.l	#5,%d0
	bsr	Blink
.if 0
	move.l	#25,%d5
	bsr	LED_off
.endif

DRAM_tests:
	lea	(dram,%pc),%a3

dt1:
	move.b	(switches).w,%d7
	move.l	(%a3)+,%d0
	bpl	dt2
	and.b	#LOOP,%d7
	bne.s	DRAM_tests
	jbra	stop0

dt2:
	move.l	%d0,%a1			/* beginning address */
	move.l	(%a3),%a0		/* ending address + 1 */

	rol.l	#8,%d0			/* check begin address */
	btst	%d0,%d7	
	beq.s	dt_skip			/* skip the test if 0 */

	move.l	%a0,%d0			/* test the end address, too */
	sub.l	#1,%d0			/* move back into bank */
	rol.l	#8,%d0			/* check end address */
	btst	%d0,%d7	
	bne.s	dt3			/* do the test if 1 */
	
dt_skip:
	lea	8(%a3),%a3
	jbra	dt1

dt3:
	bsr	memtest

	lea	-4(%a3),%a3		/* move back to beginning */

	clr.l	%d7			/* no errors */
	cmp.l	(%a3)+,%a4		/* end SRAM, begin I/O */
	beq.s	drok1
	or.b	#1,%d7
drok1:	cmp.l	(%a3)+,%a5		/* compare to end */
	beq.s	drok2
	or.b	#2,%d7
drok2:	or.l	%d6,%d6
	beq.s	drok3
	or.b	#4,%d7
drok3:	or.l	(%a3)+,%d7		/* put display prefix in D0.b */
	move.b	%d7,(lites).w

	and.b	#0x0F,%d7
	beq.s	drok5
	move.b	(switches).w,%d0
	btst	#7,%d0			/* test HOE setting */
	bne	stop0

drok5:
	and.b	#0x0F,%d7
	bne.s	dt1			/* skip test if error above */
	move	%a4,%a1

	bsr	bytetest

	move.l	%d6,%d6
	beq.s	drok9

     	move.b	%d6,(lites).w

	move.b	(switches).w,%d0
	btst	#7,%d0			/* test HOE setting */
	bne	stop0

drok9:
	move.l	#3,%d0
	bsr	Blink
	jbra	dt1



dram:	.long	0x00000000
	.long	0x01000000		/* 16 meg */
	.long	0x000000E0		/* display */

	.long	0x00000001		/* unaligned */
	.long	0x00400001
	.long	0x00000010

	.long	0x00400001
	.long	0x00800001
	.long	0x00000020

	.long	0x00800001
	.long	0x00C00001
	.long	0x00000040

	.long	0x00C00001
	.long	0x01000001-32*1024
	.long	0x00000080

	.long	0x01000000		/* second 16 meg */
	.long	0x02000000
	.long	0x000000D0		/* display */

	.long	0x01000001
	.long	0x01400001
	.long	0x00000010

	.long	0x01400001
	.long	0x01800001
	.long	0x00000020

	.long	0x01800001
	.long	0x01C00001
	.long	0x00000040

	.long	0x01C00001
	.long	0x02000001-32*1024
	.long	0x00000080

	.long	0x00000002
	.long	0x02000002-32*1024
	.long	0x000000C0

	.long	0x02000000		/* third 16 meg */
	.long	0x03000000
	.long	0x000000B0		/* display */

	.long	0x02000001
	.long	0x02400001
	.long	0x00000010

	.long	0x02400001
	.long	0x02800001
	.long	0x00000020

	.long	0x02800001
	.long	0x02C00001
	.long	0x00000040

	.long	0x02C00001
	.long	0x03000001-32*1024
	.long	0x00000080

	.long	0x03000000		/* fourth 16 meg */
	.long	0x04000000
	.long	0x00000070		/* display */

	.long	0x03000001
	.long	0x03400001
	.long	0x00000010

	.long	0x03400001
	.long	0x03800001
	.long	0x00000020

	.long	0x03800001
	.long	0x03C00001
	.long	0x00000040

	.long	0x03C00001
	.long	0x04000001-32*1024
	.long	0x00000080

	.long	-1			/* end marker */



	/* now STOP, we are all done here */
stop0:	stop	#0x2701
	br.s	stop0		/* loop on NMI */
/* only a hardware RESET gets us beyond here */

.include  "memtest.s"

