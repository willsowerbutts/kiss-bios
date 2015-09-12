/* test3.s  -- derived from test2.s/test1.s	*/
/*   makes test4.o when SIZE is defined */
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
HEXOUT		=	0	/* 1 for pre 6-Aug-2015 output */


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



STACK		=	0xFFFE7FF0
PASS		=	STACK+4			/* memory loc. */
EPASS		=	PASS+4			/* memory loc. */
UART_DATA	=	EPASS+4
UART_REG	=	UART_DATA+1
UART_TYPE	=	UART_REG+1

	.globl	location_zero

location_zero:
	.long	STACK			/* Reset:  initial SSP */
	.long	_start			/* Reset:  initial PC  */


_start:
# 	move.b	#0x81,(lites).w		/* display in the lights */

/* DRAM startup */
	move.w	#8-1,%d2		/* outer counter */
DRAM_start00:
	lea	(dram,%pc),%a3
DRAM_start:
	move.l	(%a3)+,%d0
	jbmi	DRAM_started

	move	%d0,%a0			/* use A0 */
	move.w	#4096,%d1		/* count 4K addresses  */
DRAM_s0:
	move.l	(%a0)+,%d0		/* D0 is scratch */
	dbra	%d1,DRAM_s0		/* just do 4K read refreshes */

	lea	8(%a3),%a3		/* bump to next address */
	jbra	DRAM_start
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

	jbeq	SRAM_okay
	move.l	#6,%d0			/* eight blinks if not okay */
stop1:
	lea	(stop2,%pc),%a5
	jbra	_Blink
stop2:
	move.l	#20,%d5			/* 2 second delay */
	lea	(stop0,%pc),%a6		/* end up at STOP */
	jbra	_LED_off
/***** STOP *****/
	
SRAM_okay:

/* find the UART */
	move.w	#dev_uart,%d0
	lea	(ufound1,%pc),%a6
	jbra	_uart_find
ufound1:
	move.b	%d0,(UART_DATA)
	move.w	%d1,(UART_TYPE)
	move.b	%d2,(UART_REG)

	move.w	%d1,%d1
#	beq.s	stop1			/* D1 == 0 means no UART */
	jbne	t1uini

	move.l	#3,%d0			/* five blinks total */
	lea	(uinierr,%pc),%a5
	jbra	_Blink
uinierr:

t1uini:
/* initialize the UART at this point */
	lea	(t2uini,%pc),%a6
	jbra	_uart_init
t2uini:
	lea	(strID,%pc),%a0
	jbsr	uart_putstr

	lea	(str5,%pc),%a0
	jbsr	uart_putstr
	lsl.l	#3,%d1
	lea.l	(strU,%pc,%d1),%a0
	jbsr	uart_putstr

	lea	(str0,%pc),%a0
	jbsr	uart_putstr

.if 1
	move.w	(UART_TYPE),%d0
	jbne	uNoErr			/* skip printout if no error */
	jbsr	bout
	jbsr	space
	move.b	(UART_REG),%d0
	jbsr	bout
	jbsr	space
	move.b	(UART_DATA),%d0
	jbsr	bout
	jbsr	crlf
uNoErr:
.endif


	move.l	#1000000,%d5		/* delay */

	jbra	run0
run2:	swap	%d5
run1:	nop
run0:	dbra	%d5,run1
	swap	%d5
	dbra	%d5,run2

# 	move.b	#0xCC,(lites).w		/* display in the lights */
.if 0
	move.l	#100000,%d5		/* delay */
	jbra	rr0
rr2:	swap	%d5
rr1:	reset
rr0:	dbra	%d5,rr1
	swap	%d5
	dbra	%d5,rr2
.endif

/* end of test1, now do the memory test */

SRAM_Utest:
	lea	(str1,%pc),%a0
	jbsr	uart_putstr

/* test the byte parity	*/
	move.l	#0xFFFE0000,%a1		/* begin SRAM  */

	lea	breturn1,%a6
	jbra	_bytetest
breturn1:
	move.l	%d6,%d6
	jbeq	bsram
	lea	(str5fail,%pc),%a0
	jbsr	uart_putstr
	jbsr	crlf
	jbra	SRAM_Utest
bsram:	
	lea	(str5pass,%pc),%a0
	jbsr	uart_putstr
	jbsr	crlf


/************************************************************************/
/*   below this point we may use the SRAM stack		*/
/************************************************************************/


DRAM_tests:
	clr.l	(PASS).l		/* set PASS = 0 */
	clr.l	(EPASS).l		/* set EPASS = 0   error pass */
	clr.l	%d7			/* test no memory */
	move.l	#3,%d6			/* test the banks of DRAM */
ds0:
	move.l	%d6,%d1
.ifdef SIZE
	ror.l	#6,%d1			/* form start address 64Mb DRAM */
.else
	ror.l	#8,%d1			/* form start address 16Mb DRAM */
.endif
	move.l	%d1,%a1
	clr.l	(%a1)			/* set location to zero */
	move.l	#0xa5a6a7a8,4(%a1)
	nop
.if 0
	move.l	(%a1),%d0
	jbsr	lout
	jbsr	crlf
	nop
.endif
	move.l	(%a1),%d0
	jbne	ds9
	bset	%d6,%d7
ds9:
	dbra.w	%d6,ds0			/* loop through 4 memory banks */

	or.b	#1,%d7			/* must have Bank 0 */
	jbra	dt00

/* start the major outer loop */
dt0:
	add.l	#0x100,%d7

	lea.l	(str3,%pc),%a0
	jbsr	uart_putstr
	move.l	%d7,%d0
.if HEXOUT
	swap	%d0
	jbsr	wout
	move.l	%d7,%d0
	lsr.w	#8,%d0
	jbsr	bout
.else
	lsr.l	#8,%d0
	jbsr	woutD
.endif
	lea.l	(str4,%pc),%a0
	jbsr	uart_putstr
	move.l	(EPASS).l,%d0
.if HEXOUT
	jbsr	wout
.else
	jbsr	woutD
.endif
	jbsr	crlf
dt00:
	jbsr	crlf
	lea	(dram,%pc),%a3			/* get table address */
	add.l	#1,(PASS).l			/* increment the pass counter */
# 	move.b	#0x12,(lites).w

/* start a new test from the table entry */
dt1:
	move.l	(%a3)+,%d0
	cmp.l	#-1,%d0
	jbeq	dt0
	rol.l	#8,%d0
.ifdef SIZE
	lsr.b	#2,%d0			/* DRAMs are 64Mb, not 16Mb */
.endif
	btst	%d0,%d7
	jbeq	dt6			/* skip the test */
.ifdef SIZE
	move.l	-4(%a3),%d0
.else
	ror.l	#8,%d0			/* 16Mb DRAM */
.endif

	move.l	(%a3),%d1
	sub.l	#8,%d1			/* move back by 1 */
	rol.l	#8,%d1
.ifdef SIZE
	lsr.b	#2,%d1			/* DRAMs are 64Mb, not 16Mb */
.endif
	btst	%d1,%d7
	jbeq	dt6			/* skip the test */
dt2:
	move.l	%d0,%a1			/* beginning address */
	move.l	(%a3),%a0		/* ending address + 1 */
	move.l	%d0,%d1			/* copy start address to D1 */

	jbsr	lout			/* put out Address */
	move.b	#040,%d0
	jbsr	uart_put
	move.l	%a0,%d0
	jbsr	lout
	move.b	#040,%d0
	jbsr	uart_put
	move.b	#0x41,%d0		/* "A" */
	and.b	#3,%d1
	jbeq	dt20
	move.b	#0x55,%d0		/* "U" */
dt20:	jbsr	uart_put


dt3:
	jbsr	memtest
# 	move.b	#0x17,(lites).w
	jbsr	passfail

	move.l	%d6,%d6			/* test error count */
	jbne	dt5
# error count was zero, so do the byte test
	lea.l	(strB,%pc),%a0
	jbsr	uart_putstr
	move.l	-4(%a3),%a1		/* get address to test */
	jbsr	bytetest

	jbsr	passfail
# 	move.b	#0x18,(lites).w

dt5:
	jbsr	crlf
dt6:
	lea	8(%a3),%a3	
	jbra	dt1


.if 0
drok5:
	and.b	#0x0F,%d7
	jbne	dt1			/* skip test if error above */
	move	%a4,%a1

	jbsr	bytetest

	move.l	%d6,%d6
	jbeq	drok9

#      	move.b	%d6,(lites).w

	move.b	(switches).w,%d0
	btst	#7,%d0			/* test HOE setting */
	jbne	stop0

drok9:
	move.l	#3,%d0
	jbsr	Blink
	jbra	dt1
.endif


/* say pass or fail based on D6 */
passfail:
	movm.l	%a0/%a1,-(%sp)
	lea	(str5pass,%pc),%a0
	move.l	%d6,%d6
	jbeq	pf2
	or.l	#0xFFFFFF00,%d7		/* reset pass counter */
	move.l	(PASS).l,(EPASS).l	/* mark the error pass */
	lea	(str5fail,%pc),%a0
pf2:	jbsr	uart_putstr
	movm.l	(%sp)+,%a0/%a1
	rts


crlf:	move.b	#012,%d0
	jbsr	uart_put
	move.b	#015,%d0
	jbsr	uart_put
	rts

space:	move.b	#040,%d0
	jbsr	uart_put
	rts

/*  message strings:		*/
str0:	.ascii	"\r\nSRAM present\r\n\0"
str1:	.ascii	"SRAM Btest\0"
str5pass:  .ascii  " pass\0"
str5fail:  .ascii  " fail\0"
str3:	.ascii	"\r\nPasses without error:  \0"
str4:	.ascii	"    Last error at pass:  \0"
str5:	.ascii	"\r\nMF/PIC UART is\0"
strB:	.ascii	"   B\0"
.ifdef SIZE
strID:	.ascii	"\r\n\r\nTEST4.BIN  18-Aug-2015  John R Coffman.  Licensed for hobbyist use only.\r\n\0"
.else
strID:	.ascii	"\r\n\r\nTEST3.BIN  18-Aug-2015  John R Coffman.  Licensed for hobbyist use only.\r\n\0"
.endif
	.ascii	"\0"
	.align	4
strU:
	.ascii	" ???   \0"	/* 0 */
	.ascii	" 8250  \0"	/* 1 */
	.ascii	" 16450 \0"	/* 2 */
	.ascii	" 16550 \0"
	.ascii	" 16550A\0"	/* 4 */
	.ascii	" 16550C\0"
	.ascii	" 16750 \0"	/* 6 */


	.align	4
dram:
.ifdef SIZE
dram64:
	.long	0x00000000		/* 64 meg */
	.long	0x04000000
	.long	0x000000E0		/* display */

	.long	0x00000001		/* 64 meg */
	.long	0x01000001
	.long	0x000000E0		/* display */

	.long	0x01000002		/* 64 meg */
	.long	0x02000002
	.long	0x000000E0		/* display */

	.long	0x02000003		/* 64 meg */
	.long	0x04000003-4
	.long	0x000000E0		/* display */

	.long	0x04000000
	.long	0x08000000
	.long	0x000000E0		/* display */

	.long	0x03ff0003
	.long	0x0400ffff
	.long	0x4f

	.long	0x04000001
	.long	0x05000001
	.long	0x000000E0		/* display */

	.long	0x05000002
	.long	0x06000002
	.long	0x000000E0		/* display */

	.long	0x06900003
	.long	0x07800003
	.long	0x000000E0		/* display */

	.long	0x33251231
	.long	0x7Aed3431
	.long	0x000000ae

	.long	0x08000000
	.long	0x0C000000
	.long	0x000000E0		/* display */

	.long	0x07ff0003
	.long	0x0800ffff
	.long	0x8f

	.long	0x08000001		/* 64 meg */
	.long	0x09800001
	.long	0x000000E0		/* display */

	.long	0x09800002		/* 64 meg */
	.long	0x0B000002
	.long	0x000000E0		/* display */

	.long	0x0B000003		/* 64 meg */
	.long	0x0C000003-4
	.long	0x000000E0		/* display */

	.long	0x0C000000
	.long	0x10000000
	.long	0x000000E0		/* display */

	.long	0x0C000001		/* 64 meg */
	.long	0x0D000001
	.long	0x000000E0		/* display */

	.long	0x0E000002		/* 64 meg */
	.long	0x0F000002
	.long	0x000000E0		/* display */

	.long	0x0Bff0003
	.long	0x0C00ffff
	.long	0xcf

	.long	0x0F000003		/* 64 meg */
	.long	0x10000003-4
	.long	0x000000E0		/* display */

	.long	0x03800003
	.long	0x04638293
	.long	0x40

	.long	0x70000002
	.long	0x8D000002
	.long	0xD0

	.long	0x0Bc00001
	.long	0x0ddddd01
	.long	0xdd

	.long	0x00000000
	.long	0x10000000
	.long	0x8F

.else

dram16:	.long	0x00000000
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
.endif
	.long	-1			/* end marker */



	/* now STOP, we are all done here */
stop0:	stop	#0x2701
	jbra	stop0		/* loop on NMI */
/* only a hardware RESET gets us beyond here */

.include  "memtest2.s"

.include  "uart.s"


