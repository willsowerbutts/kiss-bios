/*  dualide.s		*/
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
.include "allide.s"
#-----------------------------------------------------------------------------

Dual_IDE_port	=	0x80

arg1	=	4
arg2	=	arg1+4
arg3	=	arg2+4
arg4	=	arg3+4

buffer	= 	arg2


dual_ide_A	=	BOARD_BASE_IO + Dual_IDE_port
dual_ide_B	=	dual_ide_A + 16

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

RECAL	=  1

	.text
# -----------------------------------------------------------------------------	
#  dide_reset
# -----------------------------------------------------------------------------	
#	arg1	disk number  (D1)
#	A1	disk table pointer
#	A5	principal M68k I/O address of device
#
#   Returns D1 (in stack) mask of devices present (D0 == 0)
#   Error return if no devices on unit.
# -----------------------------------------------------------------------------	
	.even
	.globl	dide_reset
dide_reset:
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






# -----------------------------------------------------------------------------	
#  dide_read_id
#  dide_info		; equivalent
# -----------------------------------------------------------------------------	
# Read the 512 byte ID information from the attached drive
#
#	arg1	disk number  (D1)
#	arg2	buffer or NULL	(A0)
#	A1	disk table pointer
#	A5	principal M68k I/O address of device
#
#-----------------------------------------------------------------------------
	.even
dide_read_id:
		.globl	dide_info
dide_info:
	move.l	(buffer,%sp),%a0		/* get buffer address */

	move	%a0,%d0				/* test for NULL */
	tst.l	%d0
	beq.s	short_info			/* LBA & GEOM info only */

	bsr	ide_wait_not_busy		/* uses D0, D1 */
	bne.s	read_id_error			/* %D0 == -1 */

	move.b	(disk_slave_o,%a1),%d0		/* get slave byte */
	or.b	#0xE0,%d0
	move.b	%d0,ide_head(%a5)		/* set M/S */

	move.b	#ide_cmd_id,ide_command(%a5)	/* send ID command */

	bsr	ide_wait_drq			/* uses D0, D1 */
	bne.s	read_id_error			/* %D0 == -1 */

	move.w	#511,%d1
	add.l	#ide_data_16,%a5		/* change A5 */
read_id_loop:
	move.b	(%a5),(%a0)+
	dbra.w	%d1,read_id_loop
	sub.l	#ide_data_16,%a5		/* restore A5 */

short_info:
	move.l	disk_lba_o(%a1),%d2		/* LBA info return */
	move.l	%d2,arg1(%sp)
	move.l	disk_geom_o(%a1),%d2		/* geometry return */

get_error_status:
	bsr	ide_wait_not_busy		/* uses D0, D1 */
	bne.s	read_id_error			/* %D0 == -1 */

	clr.l	%d0
	move.b	ide_status(%a5),%d0
	and.l	#1,%d0				/* test error flag */
	beq.s	read_id_error			/* D0 = 0 if not set */
	move.b	ide_err(%a5),%d0		/* return error */
	or.w	#0x800,%d0			/* show error code */
read_id_error:
	rts

	
# -----------------------------------------------------------------------------	
#  dide_read
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
	.globl	dide_read
dide_read:
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


# -----------------------------------------------------------------------------	
#  dide_verify
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
	.globl	dide_verify
dide_verify:
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



#-----------------------------------------------------------------------------
#  dide_write
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
	.globl	dide_write
dide_write:
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







# Wait for IDE not busy and Drive Ready
#
ide_wait_not_busy:			/* make sure drive is ready */
	move.l	#-1,%d0
wait_not_busy:
	jsr	usec16			/* wait 16 usec */
	move.b	ide_status(%a5),%d1
	eor.b	#0x40,%d1		/* invert DRDY bit */
	and.b	#0xC0,%d1		/* check Busy bit */
	dbeq.w	%d0,wait_not_busy
# wait until Busy bit(7) is clear

  /* EQ if okay, NE if not okay */

	rts


# Wait for Data Request
ide_wait_drq:
	move.l	#-1,%d0
wait_drq:
	jsr	usec16			/* wait 16 usec */
	move.b	ide_status(%a5),%d1
	eor.b	#0x08,%d1
	and.b	#0x88,%d1
	dbeq.w	%d0,wait_drq
/* EQ if okay, NE if not okay */
	rts


/* write out the LBA in D2, pick up Slave bit from D1 pointer */
/* sector count is in D3.b */

wr_lba:
	move.b	(disk_slave_o,%a1),%d0	/* get slave byte */
	and.b	#0x10,%d0		/* for safety */
	rol.l	#8,%d2			/* hi byte of LBA to low 8 bits */
	and.b	#0x0F,%d2		/* 28 bit limit */
	or.b	%d2,%d0
	or.b	#0xE0,%d0		/* select LBA mode */
	add.l	#ide_head,%a5
	move.b	%d0,(%a5)
	rol.l	#8,%d2
	move.b	%d2,-(%a5)		/* cylinder high */
	rol.l	#8,%d2
	move.b	%d2,-(%a5)		/* cylinder low */
	rol.l	#8,%d2
	move.b	%d2,-(%a5)		/* sector */
	and.b	#0x7F,%d3		/* limit sector count to 127 */
	move.b	%d3,-(%a5)		/* sector count */
	sub.l	#ide_sec_cnt-ide_data,%a5	/* restore A5 */
	rts



/*==========================================================================*/
/*
	BIOS calls dispatch to here

	D0.w = bios entry # << 2	(based at 10)
	D1 = disk number
	A0 = buffer address, if any

*/
/*==========================================================================*/


	.globl	bios_disk
bios_disk:
	movm.l	%d1/%a0-%a1/%a5,-(%sp)
	cmp.w	#max_disk,%d1
	bcs.s	bd_ok1
      	move.l	#1,%d0
	br.s	bd_out
bd_ok1:
	sub.l	#4*10,%d0		/* base call # at 0 (still *4) */
	lsl.l	#2,%d1			/* disk # *4 */
	lea.l	disk_table,%a1
	
	move.l	(%a1,%d1.w),%d1		/* struct DISK pointer or NULL */
	bne.s	bd_ok2
      	move.l	#2,%d0
	br.s	bd_out
bd_ok2:
	move.l	%d1,%a1

#	move.l	(disk_ops_o,%a1),%a0	/* disk_ops_o == 0 */
	move.l	(%a1),%a0		/* A1 = struct DISK, A0 = struct OPER. */

	move.l	(%a0,%d0.w),%d1		/* routine to call */
	bne.s	bd_ok3
	move.l	#3,%d0			/* function is NULL */
	br.s	bd_out
bd_ok3:
	move.l	%d1,%a0	

	move.l	#BOARD_BASE_IO,%d1
	or.b	(disk_port_o,%a1),%d1
	move.l	%d1,%a5			/* port pointer in A5 */

    /* A1 passes the Disk Table Pointer */
	jsr	(%a0)			/* dispatch to routine */

bd_out:
	movm.l	(%sp)+,%d1/%a0-%a1/%a5	/* restore */
bd_floppy_out:
	tst.l	%d0
	bne.s	bd_nok
	br	bios_good_return
bd_nok:
	br	bios_error_return



	.end

