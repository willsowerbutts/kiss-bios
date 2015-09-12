/* beetle.s --	assembly language interface for the debugger  */
/*
	Copyright (C) 2011,2012 John R. Coffman.
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

	.globl	state
	.globl	breakpoint
	.globl	Trace
	.globl	Go

	.bss
/* array that holds the machine state; see 'debug.h' */
state:
s_d:	.ds.l	8	/* 8 data registers */
s_a:	.ds.l	7	/* 7 address registers */
s_ssp:	.ds.l	1	/* s_a[7] is the SSP */
s_usp:	.ds.l	1	/* the User Stack Pointer, USP */
s_pc:	.ds.l	1	/* program counter (next instruction) */
	.ds.w	1	/* high word (MBZ) */
s_sr:	.ds.w	1	/* SR -- status register (full) */

trace_count:		/* was popped to D0 */
trace_save:
	.ds.l	15	/* 8 data + 7 address registers */
t_ssp:	.ds.l	1	/* SSP for debugger */
	

TRACE_BIT	=	0x8000
SUPV_BIT	=	0x2000
IPL_BITS	=	0x0700

X_BIT		=	0b10000
N_BIT		=	0b01000
Z_BIT		=	0b00100
V_BIT		=	0b00010
C_BIT		=	0b00001

	.text
Trace:
	or.w	#TRACE_BIT,s_sr		/* set Trace bit */
	move.l	#trace_trap,4*9		/* set to receive trap */
Go:
	move.l	#breakpoint_trap,4*4	/* set to receive breakpoint trap */

	jsr	install_breaks		/* install all breakpoints */

	move.l	(%sp)+,%a0		/* save return in A0 */
	move.l	(%sp)+,%d0		/* get trace count in D0 */
 /* the trace_count is in D0, and will be the function return */
	movem.l	%d0-%d7/%a0-%a7,trace_save	/* save all regs */

dispatch_user:
	move.l	s_ssp,%sp		/* set User SSP */
	move.l	s_usp,%a1		/* set User USP */
	move.l	%a1,%usp		/* */
	move.l	s_pc,-(%sp)		/* push User resume PC */
	move.w	s_sr,-(%sp)
	movem.l	state,%d0-%d7/%a0-%a6	/* restore User register state */
	rte		  		/* resume User program */



trace_trap:
	sub.l	#1,trace_count		/* count the instruction */
	beq.s	trace_done
	rte				/* count not expired */

breakpoint_trap:
	move.b	#1,break_taken		/* flag breakpoint */
	bra.s	common_reentry

trace_done:
	clr.b	break_taken		/* flag no breakpoint */
common_reentry:
	movem.l	%d0-%d7/%a0-%a6,state	/* save all registers */
	move.w	(%sp)+,%d0		/* grab the SR */
	and.w	#~TRACE_BIT,%d0		/* clear the TRACE bit */
	move.w	%d0,s_sr		/* save the program status */
	move.l	(%sp)+,s_pc		/* save the User resume point */
	move.l	%sp,s_ssp		/* save user SSP */
	move.l	%usp,%a1		/* save USP */
	move.l	%a1,s_usp

	movem.l	trace_save,%d0-%d7/%a0-%a7	/* restore Trace call state */
	sub.l	#4,%sp			/* push the count argument */
	move.l	%a0,-(%sp)		/* push the return address */

	jsr	remove_breaks

	rts


	.end

