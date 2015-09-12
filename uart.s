#  uart.s
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
dev_uart	=	0x48	/* MF/PIC UART location */

rbr		=	0	/* receive buffer register */
thr		=	0	/* transmitter holding register */
ier		=	1	/* interrupt enable register */
iir		=	2	/* interrupt ident. register */
fcr		=	2	/* FIFO control register */
lcr		=	3	/* line control register */
mcr		=	4	/* modem control register */
lsr		=	5	/* line status register */
msr		=	6	/* modem status register */
scr		=	7	/* scratch register */

dll		=	0	/* divisor latch LSByte */
dlm		=	1	/* divisor latch MSByte */

lcr_8n2		=	0x03	/* 8-data bits, no parity, 2 stop bits */
lcr_dla		=	0x80	/* divisor latch access */
divisor		=	1843200/16 / 9600		/* divisor */


/***********************************************************************
*  uart_find
***********************************************************************

   Enter with:
	D0.b	device code to check

   Return:
	D1 is UART type, if present
		0	none
		1	8250
		2	16450		SCR
		3	16550		SCR
		4	16550A		FIFO-16,SCR
		5	16550C		FIFO-16,AFC,SCR
		6	16750		FIFO-64,AFC,SCR
	D2 is last register examined
	D0 is last data read

	D0, A5, A6  are used

***********************************************************************
*/
_uart_find:
#	reset				/* does no harm/good */

	or.l	#KISS68030_IO,%d0		/* form word address */
	move.l	%d0,%a5			/* reference regs from here */

	clr.l	%d1			/* no uart found */
	move.l	#ier,%d2
	move.b	ier(%a5),%d0		/* IER resets to 00 */
	jbne	fnd9e

	move.l	#iir,%d2
	move.b	iir(%a5),%d0		/* IIR resets to 01 */
	cmp.b	#01,%d0
	jbne	fnd9e

	move.l	#lcr,%d2
	move.b	lcr(%a5),%d0		/* LCR resets to 00 */
	jbne	fnd9e

	move.l	#mcr,%d2
	move.b	mcr(%a5),%d0		/* MCR resets to 00 */
	jbne	fnd9e

	move.l	#lsr,%d2
	move.b	lsr(%a5),%d0		/* LCR resets to 0x60 */
#	cmp.b	#0x60,%d0		/* but sometimes to 0x00 */
 	and.b	#~0x60,%d0		/* ignore 2 bits */
	jbne	fnd9e
.if 1
# This test is failing from time to time on the MDB -- ????
	move.l	#msr,%d2
	move.b	msr(%a5),%d0		/* MSR resets to 0x?0 */
	and.b	#0x0F,%d0
	jbne	fnd9e
.endif
	move.b	%d0,%d3			/* save data in D3 */

	move.b	#0xE7,fcr(%a5)		/* enable all FIFO's */
	move.b	iir(%a5),%d0		/* IIR and FCR are the same */
	btst	#6,%d0			/* test bit 6 */
	jbeq	test16450
/* we have at least a 16550  */
	move.l	#3,%d1			/* set 16550 response */
	btst	#7,%d0
	jbeq	fnd9		/* it is a 16550 */
/* we have at least a 16550A */
	move.l	#6,%d1			/* set 16750 response */
	btst	#5,%d0			/* test bit 5 */
	jbne	fnd9		/* it is a 16750 */
	move.b	#0x20,mcr(%a5)		/* set AFC */
	move.l	#4,%d1			/* say 16550A */
	btst	#5,mcr(%a5)		/* stuck on zero? */
	jbeq	fnd9		/* it is a 16550A */
	move.l	#5,%d1
	jbra	fnd9		/* it is a 16550C */
test16450:
	move.l	#1,%d1			/* say 8250 */
	move.b	#0x2A,scr(%a5)
	clr.b	mcr(%a5)		/* disturb the data bus */
	cmp.b	#0x2A,scr(%a5)
	jbne	fnd9		/* it is an 8250 */
	move.l	#2,%d1		/* it is a 16450 */
fnd9:
	move.b	%d3,%d0
fnd9e:
	move.b	#01,fcr(%a5)		/* reset */
	clr.b	mcr(%a5)		/* reset */
	jmp	(%a6)



/***********************************************************************
*  uart_init
***********************************************************************

   Enter with:
	nothing

   Return:
	nothing

	D0, A5, A6  are used

***********************************************************************
*/

uart_init:
	movl	(%sp)+,%a6	/* get return address */
_uart_init:
	lea	(0xF000+dev_uart).w,%a5		/* A0 = uart base address */
	movb	#0,ier(%a5)	/* clear interrupt enables */
	movb	#lcr_dla,lcr(%a5)	/* access divisor latch */
	movb	#(divisor&255),dll(%a5)
	movb	#(divisor/256),dlm(%a5)
	movb	#lcr_8n2,lcr(%a5)
	movb	#7,mcr(%a5)	/* set DTR, RTS, OUT1 */
	movb	#0x47,fcr(%a5)	/* enable the FIFO, if present; trigger=4 */

	movb	iir(%a5),%d0	/* clear out the interrupt ident. reg. */
	movb	lsr(%a5),%d0	/* clear out the line status */
	movb	lsr(%a5),%d0
	jmp	(%a6)		/* return through A6 */



/***********************************************************************
*  uart_put
***********************************************************************

   Enter with:
	D0	byte to put out

   Return:
	nothing

	D0, A5, A6  are used

***********************************************************************
*/

uart_put:
	movl	(%sp)+,%a6	/* get return address */
_uart_put:
	lea	(0xF000+dev_uart).w,%a5		/* A0 = uart base address */
up1:
	btst	#5,lsr(%a5)	/* test for transmitter ready */
	jbeq	up1	
#	movb	%d0,thr(%a5)
	movb	%d0,(%a5)
	jmp	(%a6)
	


/***********************************************************************
*  uart_putstr
***********************************************************************

   Enter with:
	A0	string to put out, null terminated

   Return:
	nothing

	A0, A4, A5, A6  are used

***********************************************************************
*/

uart_putstr:
	movl	(%sp)+,%a4	/* get return address */
_uart_putstr:
	movb	(%a0)+,%d0	/* get a char */
	jbeq	upsret
	lea	(_uart_putstr,%pc),%a6
	jbra	_uart_put
/*	jbra	_uart_putstr		*/
upsret:
	jmp	(%a4)



woutD:	/* put out a decimal word */
	and.l	#0x0000FFFF,%d0
	divu.w	#10,%d0			/* D0 =  R:Q */
	move.w	%d0,%d0
	jbeq	woutD1

	move.l	%d0,-(%sp)		/* save D0 */
	jbsr	woutD			/* put out the quotient */
	move.l	(%sp)+,%d0		/* restore D0 */

woutD1:
	swap	%d0			/* remainder to D0.w */
	jbra	nout			/* put out the nibble */


	
lout:	/* put out the long word in D0 */
	move.l	%d0,-(%sp)		/* save low word */
	swap	%d0
	jbsr	wout			/* write the high word */
	move.l	(%sp)+,%d0		/* get the low word */
wout:	/* put out the word in D0 */
	move.l	%d0,-(%sp)		/* save low byte */
	lsr.w	#8,%d0			/* shift high byte for output */
	jbsr	bout
	move.l	(%sp)+,%d0		/* put out the low byte */
bout:	/* put out the byte in D0 */
	move.l	%d0,-(%sp)		/* save low nibble */
	lsr.b	#4,%d0			/* position high nibble */
	jbsr	nout
	move.l	(%sp)+,%d0		/* fall in & output low nibble */
nout:	/* put out the nibble in D0 */
	and.w	#0x0F,%d0
	move.b	(digits,%pc,%d0.w),%d0
	jbra	uart_put		/* which will do the return */

digits:	.ascii	"0123456789ABCDEF"

# end uart.s

