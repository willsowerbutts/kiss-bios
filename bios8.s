#  bios8.s
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
#	Handle BIOS traps (vector 8) and dispatch
#	to the proper Handler (BIOS call implementation)
#
#
# start with some bit definitions:
#
ccr_carry	=	0x01		/* carry bit mask */
ccr_overflow	=	0x02		/* overflow */
ccr_zero	=	0x04		/* zero bit mask */
ccr_sign	=	0x08		/* sign bit mask */
ccr_extend	=	0x10		/* extend bit mask */

sr_super	=	0x2000		/* supervisor mode bit mask */
sr_trace	=	0x8000		/* trace mode bit mask */


#	BIOS dispatch

# 3 entry points:
	.globl	bios_trap_entry
	.globl	bios_good_return
	.globl	bios_error_return


Flags	=	ccr_sign + ccr_overflow + ccr_carry

bios_good_return:
	move.l	(%sp)+,%a6	/* restore A6 */
	and.w	#~Flags,(%sp)	/* clear the Sign, Carry and Overflow */
	rte			/* return from exception */



# dispatch to here on any undefine BIOS call numbers
#
undefined:
#   print error message
	movm.l	%d0-%d2/%a0,-(%sp)
	pea	ufmt
	jsr	cprintf
	add.l	#4,%sp
	movm.l	(%sp),%d0-%d2/%a0
	add.l	#16,%sp
	jmp	_exit
	
#   print error message

# undefined:	/* former */
#	move.l	#-1,%d0		/* error code to D0 */
bios_error_return:
	move.l	(%sp)+,%a6	/* restore A6 */
	or.w	#Flags,(%sp)	/* set the N, V & C flags */
	rte			/* return from exception */

ufmt:
	.ascii	"\nUndefined BIOS call\n"
	.asciz	"  D0=%08x  D1=%08x  D2=%08x   A0=%08x\n"


	.even
bios_trap_entry:
	move.l	%a6,-(%sp)		/* save A6 */
	ext.w	%d0			/* extend byte to word < 128 */
	cmp.w	#bios_vector_lth/4,%d0	/* in range? */
	jbcc	undefined
	lsl.l	#2,%d0			/* multiply by 4 */
	move.l	bios_vector_00(%d0.w,%pc),%a6
	jmp	(%a6)			/* vector to service routine */

	.align	2		/* long word boundary */
bios_vector_00:
	.long	undefined
	.long	undefined
	.long	bios_sioput	/*  2  */
	.long	bios_siostr
	.long	bios_sioget
	.long	bios_siotst	/*  5  */
	.long	bios_cpuhma	/*  6  */
	.long	bios_cpustop	/*  7  */
#  8 - 15
	.long	bios_hma_alloc  /*  8  allocate HighestMA memory */
	.long	undefined
	.long	bios_disk	/* 10  Disk Reset */	
	.long	bios_disk	/* 11  Disk Status */
	.long	bios_disk	/* 12  Disk Read */
	.long	bios_disk	/* 13  Disk Write */
	.long	bios_disk	/* 14  Disk Verify */
	.long	bios_disk	/* 15  Disk Format */
# 16 - 23
	.long	undefined
	.long	undefined
	.long	undefined
	.long	undefined
	.long	bios_daytime	/* 20  Date & Time */
	.long	undefined
	.long	undefined
	.long	undefined
# 24 - 31
	.long	undefined
	.long	undefined
	.long	undefined
	.long	undefined
	.long	undefined
	.long	undefined
	.long	undefined
	.long	undefined

bios_vector_lth		=	. - bios_vector_00




bios_cpustop:
	move.l	%d1,%d0		/* push return code */
	jmp	_exit

bios_cpuhma:
	move.l	h_m_a,%d0		/* get HMA+1 address */
	jbra	bios_good_return	/* good return */

bios_hma_alloc:
	move.l	h_m_a,%d0
	and.l	#-4,%d0			/* keep it aligned */
	sub.l	%d1,%d0
	jbmi	bios_error_return	/* negative indicates error */
	and.l	#-4,%d0			/* keep it aligned */
	move.l	%d0,h_m_a		/* update Highest Memory Address */
	jbra	bios_good_return	/* good return */


	.end
