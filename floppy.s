/*  floppy.s		*/
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
.include "mfpic.s"
#-----------------------------------------------------------------------------
.include "ns202def.s"
#-----------------------------------------------------------------------------

		.globl fdc_parameters
	.text
	.even
fdc_parameters:
	.long 0
	.long 0
	.long HD1200
	.long DD720
	.long HD144
	.long 0
	.long 0
	.long 0


	.globl	enable
	.globl	disable
	.even
/* enable all interrupts by going to interrupt level 000 */
enable:
	and.w	#0xF8FF,%sr	/* allow all interrupts */
	rts

/* disable all interrupts by going to interrupt level 111 (7) */
disable:
	or.w	#0x0700,%sr	/* disallow all interrupts */
	rts

	.globl	floppy_interrupt_1
	.even
floppy_interrupt_1:
	movm.l	%d0/%d1/%a0/%a1,-(%sp)		/* save the C-call registers */

	jsr	fdcint		/* written in C */

	move.b	(mf_202 + eoi*256),%d0		/* signal End of Interrupt */
	movm.l	(%sp)+,%d0/%d1/%a0/%a1		/* restore the registers */
	rte





arg1	=	4
arg2	=	arg1+4
arg3	=	arg2+4
arg4	=	arg3+4

buffer	= 	arg2



/*
    Enter general dispatch routines with:
	A0 = buffer pointer, if applicable
	A1 = disk structure pointer
	D0 = garbage
	D1 = garbage
	D2 = LBA sector number
	D3 = number of sectors (only 1, for now)

    Stack:
	SP:	return address
		Saved D1 -- disk number (0..7)
		Saved A0 -- buffer pointer
		Saved A1 -- ???
		Saved A5 -- ???

    May Use:
	D0, D1, A0, A1
    Must Preserve:
	D2-D7, A2-A7

 */

# -----------------------------------------------------------------------------	
#  floppy_reset
# -----------------------------------------------------------------------------	
#	arg1	disk number  (D1)
#	A1	disk table pointer
#	A5	principal M68k I/O address of device
#
#   Returns D1 (in stack) mask of devices present (D0 == 0)
#   Error return if no devices on unit.
# -----------------------------------------------------------------------------	
	.even
	.globl	floppy_reset
floppy_reset:
	move.l	#-1,%d0		/* error return */
	rts
.if 0
	move.l	#0,%a0			/* accumulate D1 mask here */

	move.b	#0b00001110,ide_control(%a5)	/* assert SRST, deassert IEN */
	move.l	#1000,%d0			/* delay 10 ms = 10,000 usec */
	jsr	usec_delay
	move.b	#0b00001010,ide_control(%a5)	/* deassert SRST, deassert IEN */
	move.l	#50000,%d0
	jsr	usec_delay			/* delay 500 ms */
	
#	cmp.b	#0,ide_head(%a5)
#	bne.s	reset1
	cmp.b	#0x50,ide_status(%a5)		/* check for BUSY=0, RDY=1, SeekComplete=1 */
	bne.s	reset1
/* may wish to recalibrate the drive here */
.if RECAL
	btst	#4,(disk_slave_o,%a1)		/* test SLAVE bit */
	bne.s	reset10				/* branch if SLAVE */
	move.b	#ide_cmd_recal,ide_command(%a5)	/* do a recalibrate of the drive */
	bsr	ide_wait_not_busy
	bne.s	reset1
reset10:
.endif
	add.l	#1,%a0				/* mark drive 0 present */
reset1:
       	move.b	#0b11110000,ide_head(%a5)	/* select drive 1 */
	move.l	#1000,%d0			/* delay 10 ms = 10,000 usec */
	jsr	usec_delay
	cmp.b	#0x50,ide_status(%a5)		/* check for BUSY=0, RDY=1, SeekComplete=1 */
	bne.s	reset2
/* may wish to recalibrate the drive here */
.if RECAL
	btst	#4,(disk_slave_o,%a1)		/* test SLAVE bit */
	beq.s	reset20				/* branch if MASTER */
	move.b	#ide_cmd_recal,ide_command(%a5)	/* do a recalibrate of the drive */
	bsr	ide_wait_not_busy
	bne.s	reset2
reset20:
.endif
	add.l	#2,%a0				/* mark drive 1 present */
reset2:
       	move.b	#0b11100000,ide_head(%a5)	/* select drive 0 */

	move.l	%a0,%d1				/* move to D1 */
	move.l	%d1,arg1(%sp)			/* save in stack */
	clr.l	%d0
	tst.b	%d1
	bne.s	reset3
	move.l	#1,%d0				/* error return */
reset3:
	rts
.endif





# -----------------------------------------------------------------------------	
#  floppy_info		
# -----------------------------------------------------------------------------	
# Read the 512 byte ID information from the attached drive
#
#	arg1	disk number  (D1)
#	arg2	buffer or NULL	(A0)
#	A1	disk table pointer
#	A5	principal M68k I/O address of device
#
#	int fdc_info(int lba, int geom, byte disk_no);
#		set lba & geom for return
#-----------------------------------------------------------------------------
	.even
	.globl	floppy_info
floppy_info:
	sub.l	#8,%sp		/* make space on stack */
	jsr	fdc_info	/* fdc_info(byte disk#) */
	movm.l	(%sp)+,%d1/%d2	/* return values */
			/* return D0 */
	rts



	
# -----------------------------------------------------------------------------	
#  floppy_read
# -----------------------------------------------------------------------------	
#	;read a sector, specified by the 4 bytes in "lba",
#	;Return, acc is zero on success, non-zero for an error
#
#	arg1	disk number  (D1)
#	arg2	buffer	(A0)
#	A1	disk table pointer
#	D2	LBA address
#	D3	sector count (assumed to be 1)
#	A5	principal M68k I/O address of device
#
#
#-----------------------------------------------------------------------------
	.even
	.globl	floppy_read
floppy_read:
	move.l	#-1,%d0		/* error return */
	rts
.if 0
	move.l	(buffer,%sp),%a0		/* get buffer address */
	move.l	#5,%d0				/* error code */
	cmp.l	(disk_lba_o,%a1),%d2		/* check lba address */
	bcc.s	read_error

	move.l	#4,%d0				/* error code */
	cmp.l	#1,%d3
	bne.s	read_error			/* for now */

	bsr	ide_wait_not_busy
	bne.s	read_error			/* %D0 == -1 */

	bsr	wr_lba

	move.b	#ide_cmd_read,ide_command(%a5)	/* send ID command */

	bsr	ide_wait_drq
	bne.s	read_error			/* %D0 == -1 */

	move.w	#511,%d1
	add.l	#ide_data_16,%a5
read_loop:
	move.b	(%a5),(%a0)+
	dbra.w	%d1,read_loop
	sub.l	#ide_data_16,%a5

	bra	get_error_status

#	clr.l	%d0			/* signal no error */
read_error:
	rts
.endif


# -----------------------------------------------------------------------------	
#  floppy_verify
# -----------------------------------------------------------------------------	
#	;read a sector, specified by the 4 bytes in "lba",
#	;Return, acc is zero on success, non-zero for an error
#
#	arg1	disk number  (D1)
#	A1	disk table pointer
#	D2	LBA address
#	D3	sector count (assumed to be 1)
#	A5	principal M68k I/O address of device
#
#
#-----------------------------------------------------------------------------
	.even
	.globl	floppy_verify
floppy_verify:
	move.l	#-1,%d0		/* error return */
	rts
.if 0
	move.l	#5,%d0				/* error code */
	cmp.l	(disk_lba_o,%a1),%d2		/* check lba address */
	bcc.s	verify_error

	move.l	#4,%d0				/* error code */
	cmp.l	#1,%d3
	bne.s	verify_error			/* for now */

	bsr	ide_wait_not_busy
	bne.s	verify_error			/* %D0 == -1 */

	bsr	wr_lba

	move.b	#ide_cmd_read,ide_command(%a5)	/* send READ command */

	bsr	ide_wait_drq
	bne.s	verify_error			/* %D0 == -1 */

	move.w	#511,%d1
	add.l	#ide_data_16,%a5
verify_loop:
	move.b	(%a5),%d0
	dbra.w	%d1,verify_loop
	sub.l	#ide_data_16,%a5
 	bra	get_error_status

	clr.l	%d0			/* signal no error */
verify_error:
	rts
.endif



#-----------------------------------------------------------------------------
#  floppy_write
# -----------------------------------------------------------------------------	
#	;write a sector, specified by the 4 bytes in "lba",
#	;Return, acc is zero on success, non-zero for an error
#
#	arg1	disk number  (D1)
#	arg2	buffer	(A0)
#	A1	disk table pointer
#	D2	LBA address
#	D3	sector count (assumed to be 1)
#	A5	principal M68k I/O address of device
#
#
#-----------------------------------------------------------------------------
	.even
	.globl	floppy_write
floppy_write:
	move.l	#-1,%d0		/* error return */
	rts
.if 0
	move.l	(buffer,%sp),%a0		/* get buffer address */
	move.l	#5,%d0				/* error code */
	cmp.l	(disk_lba_o,%a1),%d2		/* check lba address */
	bcc.s	write_error

	move.l	#4,%d0				/* error code */
	cmp.l	#1,%d3
	bne.s	write_error			/* for now */

	bsr	ide_wait_not_busy
	bne.s	write_error			/* %D0 == -1 */

	bsr	wr_lba

	move.b	#ide_cmd_write,ide_command(%a5)	/* send WRITE command */

	bsr	ide_wait_drq
	bne.s	write_error			/* %D0 == -1 */

	move.w	#511,%d1
	add.l	#ide_data_16,%a5
write_loop:
	move.b	(%a0)+,(%a5)
	dbra.w	%d1,write_loop
	sub.l	#ide_data_16,%a5
	bra	get_error_status

	clr.l	%d0			/* signal no error */
write_error:
	rts
.endif

	.even
	.globl	floppy_format
floppy_format:
	move.l	#-1,%d0		/* error return */
	rts

