/*  serial.s  */
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
.include  "siodef.s"
############################################################
.include  "biostrap.s"
############################################################

	.globl	bios_good_return
	.comm	nvram,32

	.text

	.even

	.globl	sio_init
sio_init:
sio_divisor	=	1843200/16 / 9600
	clr.b	sio_ier			/* disable interrupts */
	move.b	#sio_lcr_dlab,sio_lcr	/* set divisor latch bit */
	move.b	nvram+1,%d0		/* MSbyte of divisor */
.if 0
	cmp.b	#0,%d0			/* compare to zero */
	beq.s	sio_ms_is_zero
	move.b	#sio_divisor&255,sio_dll	/* LSbyte divisor, 9600 bps */
	move.b	#sio_divisor/256,sio_dlm	/* MSbyte divisor, 9600 bps */
	bra.s	sio_continue
sio_ms_is_zero:	
.endif
	move.b	nvram,sio_dll		/* LSbyte divisor, 9600 bps */
	move.b	nvram+1,sio_dlm		/* MSbyte divisor */
sio_continue:
	move.b	#sio_lcr_8bits,sio_lcr			/* 8n1 */
/***	move.b	#sio_lcr_8bits+sio_lcr_stb2,sio_lcr	/* 8n2 */

/* set TERMINAL (MODEM) signals depending on MF/PIC jumpers
		DTR (DSR), RTS (CTS), out1 (CD)	*/
	move.b	#sio_mcr_dtr+sio_mcr_rts+sio_mcr_out1,sio_mcr

/*	move.b	#sio_ier_erbfi,sio_ier		/* enable RBF interrupt */

	rts

	.globl	_con_out
/*  C-callable entry */
_con_out:
	move.b	4+3(%sp),%d0
	br.s	sio_put
	
/* bios call entry point */
	.globl	bios_sioput
bios_sioput:
.if 0
	btst	#sio_lsr_thre_bit,sio_lsr  	/* test THRE */
	bne.s	bios_sio_putit

	move.l	%d1,-(%sp)
	muls	%d1,%d1
	move.l	(%sp)+,%d1
	br.s	bios_sioput

bios_sio_putit:
	move.b	%d1,sio_thr		/* send data byte in D1 */
	clr.l	%d0
	jmp	bios_good_return
.else
	move.b	%d1,%d0
	pea	bios_good_return
#	br.s	sio_put
.endif

/* character put routine */
	.globl	sio_put
sio_put:
	btst	#sio_lsr_thre_bit,sio_lsr  	/* test THRE */
	bne.s	sio_putit

	move.l	%d0,-(%sp)
	muls	%d0,%d0
	move.l	(%sp)+,%d0
	br.s	sio_put

sio_putit:
	move.b	%d0,sio_thr		/* send data byte in D0 */
	rts

		
	.globl	sio_get
/* get a byte from the serial input, else return -1 */
sio_get:
	move.l	#-1,%d0
	btst	#sio_lsr_dr_bit,sio_lsr	  /* test Data Ready */
	beq.s	sio_gotit		/* return if nothing there */

	clr.l	%d0			/* D0 = 0 */
	move.b	sio_rbr,%d0
sio_gotit:
	rts




/* BIOS_sioget -- get a character input when available */
	.globl	bios_sioget
bios_sioget:
	bsr.s	sio_get		/* get a character or -1 */
	cmp.l	#-1,%d0		/* check for -1 */
	beq.s	bios_sioget	/* re-try if -1 */
	move.l	%d0,%d1		/* character returned in D1 */
	clr.l	%d0		/* good return code */
	jmp	bios_good_return	/* exit from BIOS call */



/* bios_siotst -- return number of charcters waiting */
	.globl	bios_siotst
bios_siotst:
	clr.l	%d0			  /* say none in buffer */
	btst	#sio_lsr_dr_bit,sio_lsr	  /* test Data Ready */
	beq.s	siotst_return
	add.l	#1,%d0			/* 1 character is waiting */
siotst_return:
	jmp	bios_good_return	/* exit from BIOS call */
	

/*  put_string
	A0 = address of NULL terminated string to put out
*/
	.globl	put_string
put_string:
	tst.b	(%a0)
	beq.s	put_string_done
	move.w	%d0,-(%sp)
	move.b	(%a0)+,%d0
	bsr.s	sio_put
	move.w	(%sp)+,%d0
	bra.s	put_string
put_string_done:
	rts

/* BIOS call to put out a D1.b terminated string. */
	.globl	bios_siostr
bios_siostr:
	move.l	%a0,%a6
siostr_loop:
	move.b	(%a6)+,%d0
	cmp.b	%d0,%d1
	beq.s	siostr_done
	bsr.s	sio_put
	br.s	siostr_loop
siostr_done:
	sub.l	%a0,%a6
	move.l	%a6,%d0
	sub.l	#1,%d0
	jmp	bios_good_return


	.end
