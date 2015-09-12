/*   pic202.s */
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
/*   */
/*   */
.include "mfpic.s"
############################################################
.include "ns202def.s"
############################################################


	.bss
	.comm	julian_day,4
	.comm	timer_ticks,4
	.comm	timeout,2		/* hi-byte only is used */

	.text

	.globl	interrupt_3_timer
interrupt_3_timer:
	move.l	%d0,-(%sp)	/* save at least D0 */
	add.w	#1,timer_ticks+2	/* increment low word */
#	bcc.s	end_of_interrupt
	bcc.s	timeout_check

	move.w	timer_ticks,%d0	/* get low count + rollover flag */
	add.w	#1,%d0		/* increment the low count byte */
	cmp.w	#high_byte,%d0
	bcs.s	no_zap

	add.l	#1,julian_day	/* increment the day counter */
	clr.l	%d0		/* reset the tick counter to midnight */
no_zap:
	move.w	%d0,timer_ticks
#	br.s	end_of_interrupt

timeout_check:
	move.b	timeout,%d0		/* move & test for zero */
	beq.s	end_of_interrupt
	sub.b	#1,%d0
	move.b	%d0,timeout		/* decrement it */
	bne.s	end_of_interrupt

	movm.l	%d1/%a0/%a1,-(%sp)
	jsr	floppy_timeout		/* may be written in C */
	movm.l	(%sp)+,%d1/%a0/%a1

	br.s	end_of_interrupt
	

	.globl	spurious_return
	.globl	end_of_interrupt
/*   */
/*    Return from a spurious interrupt */
/*   */
spurious_return:
	move.l	%d0,-(%sp)		/* stack a scratch register */

/*   fall into the EOI sequence */
/*   */
end_of_interrupt:
	move.b	(mf_202 + eoi*256),%d0
	move.l	(%sp)+,%d0		/* restore final register */
	rte			/* return from exception */


/**********************************************************************

 Delay in microseconds:

    Enter with:
	D0 = delay in microseconds (resolution is 16 usec)

**********************************************************************/
	.globl	usec_delay
usec_delay:
.if (M68000<68020)
	move.l	%d1,-(%sp)	/* save D1 */
	lsr	#4,%d0		/* divide by 16 */
	move.l	%d0,%d1		/* D0.w is the low count */
	swap	%d1		/* D1.w is high count, likely 0 */
ud1:
	jsr	usec1x		/* 16 microsecond delay */
	dbra.w	%d0,ud1		/* count down to -1 */
	dbra.w	%d1,ud1		/* count down to -1 */

	move.l	(%sp)+,%d1	/* restore D1 */
.else
**********************************************************************/
**********************************************************************/
	add.l	%d0,%d0		/* 0.5usec per count, approx. */
	br.s	ud3
ud1:	swap	%d0
ud2:	nop
ud3:	dbra	%d0,ud2
	swap	%d0
	dbra	%d0,ud1
.endif
**********************************************************************/
	rts

	.globl	usec20
	.globl	usec16
	.globl	usec12
	.globl	usec10
	.globl	usec09

.if (M68000<68020)
# delay XX usec (microseconds)
# on M68008 @ 8mhz 
#	JSR	().l	= 5 usec
#	RTS		= 4 usec
#	NOP		= 1 usec
usec20:
	nop
	nop
	nop
	nop
usec16:
	nop
	nop
	nop
usec1x:			/* positioned for 'usec_delay' above */
	nop
usec12:
	nop
	nop
usec10:
	nop
usec09:
	rts
.else
usec20:
usec16:
usec12:
usec10:
usec09:
	move.l	%d0,-(%sp)	/* save D0 */
	move.l	#20,%d0
	bsr.s	usec_delay
	move.l	(%sp)+,%d0	/* restore D0 */
	rts
.endif

/*
#--------------------------------------------------------------------------
#  bios_daytime
#--------------------------------------------------------------------------
#  date & time BIOS call
#
#    Call with:
#	D0 = 20	  function code
#	D1 = return format option:
#		0 = Julian day, tick count since midnight (binary)
#		1 = Days since Dec. 31, 1900 (i.e., Jan. 1, 1901 = 1)
#		    Time in binary seconds since midnight
#		2 = Binary date:  Word:4:8:4  =  Year:Month(4):Day(8):DayOfWeek(4)  Year=2011, e.g.
#		    Binary time:  Byte:Byte:Byte:Byte = 0:Hour:Minute:Second (24-hr format)
#		3 = BCD date:  Byte:Byte:Byte:Byte = Century:Year:Month:Day
#		    BCD time:  Byte:Byte:Byte:Byte = 00:hh:mm:ss
#
#    Return with:
#	D0 = 	date, per format option
#	D1 =	time, per format option
#
#  There is no error return.
#
#--------------------------------------------------------------------------
*/
		.globl	bios_daytime
bios_daytime:
	tst.b	%d1
	bne.s	option1
	move.l	julian_day,%d0
	move.l	timer_ticks,%d1
	bra	bios_good_return

option1:
	move.l	%d1,-(%sp)
	jsr	daytime_c
	add.l	#4,%sp
	bra	bios_good_return




