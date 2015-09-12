/* test2.s  -- derived from test1.s	*/
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
# lites		=	0xFF + KISS68030_IO	/* output only */
# switches	=	lites			/* input only */

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


_start:
# 	move.b	#0x81,(lites).w		/* display in the lights */

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

/* start the SRAM test */
# 	move.b	#0x5A,(lites).w		/* display in the lights */C

	move.l	#0xFFFE8000,%a0		/* SRAM end+1 */
	move.l	#0xFFFE0000,%a1		/* SRAM start */
	clr.l	%d0
	lea	(retp0,%pc),%a6
	jbra	_memtest
retp0:
# 	move.b	#0xA5,(lites).w		/* display in the lights */
	move.l	#2,%d0
	lea	(retp1,%pc),%a5
	jbra	_Blink
retp1:
#	move.l	#1,%d6		/* FORCE ERROR */
	move.l	%d6,%d0			/* test error count */

	beq.s	SRAM_okay
	move.l	#6,%d0			/* eight blinks if not okay */
	lea	(stop0,%pc),%a5		/* end up at STOP */
	jbra	_Blink
/***** STOP *****/
	
SRAM_okay:

/* initialize the UART at this point */
	lea	(t2uini,%pc),%a6
	jbra	_uart_init
t2uini:

	lea	(str0,%pc),%a0
	bsr	uart_putstr


	move.l	#1000000,%d5		/* delay */

	br.s	run0
run2:	swap	%d5
run1:	nop
run0:	dbra	%d5,run1
	swap	%d5
	dbra	%d5,run2

# 	move.b	#0xCC,(lites).w		/* display in the lights */
.if 0
	move.l	#100000,%d5		/* delay */
	br.s	rr0
rr2:	swap	%d5
rr1:	reset
rr0:	dbra	%d5,rr1
	swap	%d5
	dbra	%d5,rr2
.endif

/* end of test1, now do the memory test */

SRAM_Utest:
	lea	(str1,%pc),%a0
	bsr	uart_putstr

/* test the byte parity	*/
	move.l	#0xFFFE0000,%a1		/* begin SRAM  */

	lea	breturn1,%a6
	jbra	_bytetest
breturn1:
	move.l	%d6,%d6
	beq.s	bsram
	lea	(str5fail,%pc),%a0
	bsr	uart_putstr
	jbra	SRAM_Utest
bsram:	
	lea	(str5pass,%pc),%a0
	bsr	uart_putstr


/************************************************************************/
/*   below this point we may use the SRAM stack		*/
/************************************************************************/


DRAM_tests:
	clr.l	%d7			/* test no memory */
	move.l	#3,%d6			/* test the banks of DRAM */
ds0:
	move.l	%d6,%d1
	ror.l	#8,%d1			/* form start address */
	move.l	%d1,%a1
	clr.l	(%a1)			/* set location to zero */
	move.l	#0xa5a6a7a8,4(%a1)
	nop
.if 0
	move.l	(%a1),%d0
	bsr	lout
	bsr	crlf
	nop
.endif
	move.l	(%a1),%d0
	bne.s	ds9
	bset	%d6,%d7
ds9:
	dbra.w	%d6,ds0			/* loop through 4 memory banks */

	or.b	#1,%d7			/* must have Bank 0 */
	br.s	dt00

/* start the major outer loop */
dt0:
	add.l	#0x100,%d7

	lea.l	(str3,%pc),%a0
	bsr	uart_putstr
	move.l	%d7,%d0
	swap	%d0
	bsr	wout
	move.l	%d7,%d0
	lsr.w	#8,%d0
	bsr	bout
	bsr	crlf
dt00:
	bsr	crlf
	lea	(dram,%pc),%a3
# 	move.b	#0x12,(lites).w

/* start a new test from the table entry */
dt1:
	move.l	(%a3)+,%d0
	cmp.l	#-1,%d0
	beq.s	dt0
	rol.l	#8,%d0
	btst	%d0,%d7
	beq.s	dt6			/* skip the test */
	ror.l	#8,%d0
	move.l	(%a3),%d1
	sub.l	#1,%d1			/* move back by 1 */
	rol.l	#8,%d1
	btst	%d1,%d7
	beq.s	dt6			/* skip the test */
dt2:
	move.l	%d0,%a1			/* beginning address */
	move.l	(%a3),%a0		/* ending address + 1 */

	bsr	lout			/* put out Address */
	move.b	#040,%d0
	bsr	uart_put
	move.l	%a0,%d0
	bsr	lout

dt3:
	bsr	memtest
# 	move.b	#0x17,(lites).w

	move.l	%d6,%d6			/* test error count */
	bne.s	dt5
# error count was zero, so do the byte test
	move.l	-4(%a3),%a1		/* get address to test */
	bsr	bytetest
dt5:
	bsr	passfail
# 	move.b	#0x18,(lites).w

dt6:
	lea	8(%a3),%a3	
	jbra	dt1


.if 0
drok5:
	and.b	#0x0F,%d7
	bne.s	dt1			/* skip test if error above */
	move	%a4,%a1

	bsr	bytetest

	move.l	%d6,%d6
	beq.s	drok9

#      	move.b	%d6,(lites).w

	move.b	(switches).w,%d0
	btst	#7,%d0			/* test HOE setting */
	bne	stop0

drok9:
	move.l	#3,%d0
	bsr	Blink
	jbra	dt1
.endif


/* say pass or fail based on D6 */
passfail:
	movm.l	%a0/%a1,-(%sp)
	lea	(str5pass,%pc),%a0
	move.l	%d6,%d6
	beq.s	pf2
	or.l	#0xFFFFFF00,%d7		/* reset pass counter */
	lea	(str5fail,%pc),%a0
pf2:	bsr	uart_putstr
	movm.l	(%sp)+,%a0/%a1
	rts


crlf:	move.b	#012,%d0
	bsr	uart_put
	move.b	#015,%d0
	bsr	uart_put
	rts

/*  message strings:		*/
str0:	.ascii	"\r\n\r\nSRAM present\r\n\0"
str1:	.ascii	"SRAM Btest\0"
str5pass:  .ascii  " pass\r\n\0"
str5fail:  .ascii  " fail\r\n\0"
str3:	.ascii	"\r\nPasses without error:  \0"

	.align	4
dram:	.long	0x00000000
	.long	0x01000000		/* 16 meg */
	.long	0x000000E0		/* display */

	.long	0x00000001		/* unaligned */
	.long	0x00400001
	.long	0x00000010

	.long	0x00400002
	.long	0x00800002
	.long	0x00000020

	.long	0x00800003
	.long	0x00C00003
	.long	0x00000040

	.long	0x00C00001
	.long	0x01000001-4
	.long	0x00000080

	.long	0x01000000		/* second 16 meg */
	.long	0x02000000
	.long	0x000000D0		/* display */

	.long	0x01000001
	.long	0x01400001
	.long	0x00000010

	.long	0x01400002
	.long	0x01800002
	.long	0x00000020

	.long	0x01800003
	.long	0x01C00003
	.long	0x00000040

	.long	0x01C00001
	.long	0x02000001-4
	.long	0x00000080

	.long	0x01C00001
	.long	0x02400001
	.long	0x00000080

	.long	0x00000002
	.long	0x02000002-4
	.long	0x000000C0

	.long	0x02000000		/* third 16 meg */
	.long	0x03000000
	.long	0x000000B0		/* display */

	.long	0x02000001
	.long	0x02400001
	.long	0x00000010

	.long	0x02400002
	.long	0x02800002
	.long	0x00000020

	.long	0x02800003
	.long	0x02C00003
	.long	0x00000040

	.long	0x02C00001
	.long	0x03000001-4
	.long	0x00000080

	.long	0x01000002
	.long	0x03000002-4
	.long	0x000000C0

	.long	0x03000000		/* fourth 16 meg */
	.long	0x04000000
	.long	0x00000070		/* display */

	.long	0x03000001
	.long	0x03400001
	.long	0x00000010

	.long	0x03400002
	.long	0x03800002
	.long	0x00000020

	.long	0x03800003
	.long	0x03C00003
	.long	0x00000040

	.long	0x03C00001
	.long	0x04000001-4
	.long	0x00000080

	.long	0x02000002
	.long	0x04000002-4
	.long	0x000000C0

	.long	-1			/* end marker */



	/* now STOP, we are all done here */
stop0:	stop	#0x2701
	br.s	stop0		/* loop on NMI */
/* only a hardware RESET gets us beyond here */

.include  "memtest2.s"

.include  "uart.s"


