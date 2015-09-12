#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
# PPIDE.S -- Parallel Port IDE driver
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#** Updated 1-Jul-2010 Max Scane - Added PPIDE driver and conditionals
#
#   Copyright (C) 2010 John R. Coffman.  All rights reserved.
#   Provided for hobbyist use on the N8VEM SBC-188 board.
#
#   (modified from Max Scane's driver for the Z80)
#   (modified from the SBC-188 source for the MC68000)
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.include	"mfpic.s"
#-----------------------------------------------------------------------------
.include	"ppi.s"
#-----------------------------------------------------------------------------

# PPI control bytes for read and write to IDE drive

rd_ide_8255	=	0b10010010	/* ide_8255_ctl out, ide_8255_lsb/msb input */
#rd_ide_8255	=	0x92
wr_ide_8255	=	0b10000000	/* all three ports output */
#wr_ide_8255	=	0x80


.include "allide.s"
#-----------------------------------------------------------------------------


arg1	=	4
arg2	=	arg1+4
arg3	=	arg2+4
arg4	=	arg3+4


buffer	= 	arg2


		.text
#	
#------------------------------------------------------------------------------------		
# Parallel port IDE driver
#	
#
#	

	.even
# -----------------------------------------------------------------------------	
#  ppide_read_id
#  ppide_info		; equivalent
# -----------------------------------------------------------------------------	
# Read the 512 byte ID information from the attached drive
#
#	arg1	disk number  (D1)
#	arg2	buffer or NULL	(A0)
#	A1	disk table pointer
#	A5	principal M68k I/O address of device
#
#-----------------------------------------------------------------------------
		.globl	ppide_info
ppide_read_id:
ppide_info:

	move.l	(buffer,%sp),%a0		/* get buffer address */

	move	%a0,%d0				/* test for NULL */
	tst.l	%d0
	beq.s	short_info			/* LBA & GEOM info only */

	bsr	ide_wait_not_busy	/* make sure drive is ready */
	bne	error_return

	move.b	(disk_slave_o,%a1),%d1	/* get slave byte */
	and.b	#0x10,%d1		/* for safety */
	or.b	#0xE0,%d1		/* select LBA mode */
	move.b	#ide_head,%d0		/* write to head register */
	bsr	ide_write

	move.b	#ide_command,%d0
	move.w	#ide_cmd_id,%d1
	bsr	ide_write		/* ask the drive to read the ID */

	bsr	ide_wait_drq		/* wait until it's got the data */
	bne	error_return

	bsr	read_data		/* get the data */

short_info:
	move.l	disk_lba_o(%a1),%d2		/* LBA info return */
	move.l	%d2,arg1(%sp)
	move.l	disk_geom_o(%a1),%d2		/* geometry return */

	bra	get_error_status



# -----------------------------------------------------------------------------	
#  ppide_read
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
		.globl	ppide_read
ppide_read:
	move.l	(buffer,%sp),%a0		/* get buffer address */
	move.l	#5,%d0				/* error code */
	cmp.l	(disk_lba_o,%a1),%d2		/* check lba address */
	bcc.s	read_error

	move.l	#4,%d0				/* error code */
	cmp.l	#1,%d3
	bne.s	read_error			/* for now */

	bsr	ide_wait_not_busy	/* make sure drive is ready */
	bne.s	read_error			/* %D0 == -1 */

	bsr	wr_lba			/* select device */

	move.b	#ide_command,%d0
	move.w	#ide_cmd_read,%d1
	bsr	ide_write
	
	bsr	ide_wait_drq		/* wait until it's got the data */
	bne.s	read_error			/* %D0 == -1 */

	bsr	read_data		/* get the data */

get_error_status:
	bsr	ide_wait_not_busy	/* make sure drive is ready */
	bne.s	read_error			/* %D0 == -1 */

	move.b	#ide_status,%d0
	bsr	ide_read

	and.l	#1,%d1			/* check error bit */
	beq.s	exg_return
	
	move.b	#ide_err,%d0
	bsr	ide_read

	and.l	#0xFF,%d1		/* mask to byte */
	or.w	#0x800,%d1

exg_return:
	exg	%d1,%d0
error_return:
read_error:
	rts

good_return:
	clr.l	%d0
	rts


# -----------------------------------------------------------------------------	
#  ppide_verify
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

	bsr	ide_wait_not_busy	/* make sure drive is ready */
	bne	error_return

	move.l	8(%a6),%d3		/* logical block number */
	move.l	12(%a6),%d2		/* master/slave */
	bsr	wr_lba			/* select device */

	move.b	#ide_command,%d0
	move.w	#ide_cmd_read,%d1
	bsr	ide_write
	
	bsr	ide_wait_drq		/* wait until it's got the data */
	bne	error_return

	bsr	verify_data		/* get the data */

	bra	get_error_status




#-----------------------------------------------------------------------------
#  ppide_write
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
		.globl	ppide_write
ppide_write:
	move.l	(buffer,%sp),%a0		/* get buffer address */
	move.l	#5,%d0				/* error code */
	cmp.l	(disk_lba_o,%a1),%d2		/* check lba address */
	bcc.s	read_error

	move.l	#4,%d0				/* error code */
	cmp.l	#1,%d3
	bne.s	read_error			/* for now */

	bsr	ide_wait_not_busy	/* make sure drive is ready */
	bne.s	read_error			/* %D0 == -1 */

	bsr	wr_lba			/* select device */

	move.b	#ide_command,%d0
	move.w	#ide_cmd_write,%d1
	bsr	ide_write

	bsr	ide_wait_drq		/* wait until it's got the data */
	bne	error_return

	bsr	write_data		/* put the data */

	bra	get_error_status


RECAL	=  1

#-----------------------------------------------------------------------------
#--------ppide_reset-------------------------------------------------------
#
#	arg1	disk number  (D1)
#	A1	disk table pointer
#	A5	principal M68k I/O address of device
#
#   Returns D1 (in stack) mask of devices present (D0 == 0)
#   Error return if no devices on unit.
# -----------------------------------------------------------------------------	
	.globl	ppide_reset
ppide_reset:
	move.l	#0,%a0			/* accumulate D1 mask here */

	move.b	#rd_ide_8255,portCTRL_o(%a5)	/* bsr set_ppi_rd */
##	bsr.s	set_ppi_rd		/* setup for a read cycle */

	nop
	nop
	move.b	#ide_rst_line,portC_o(%a5)	/* assert the RST line on the interface */

	move.l	#50000,%d0		/* half a second */
	jsr	usec_delay		/* wait 500ms */

	clr.b	portC_o(%a5)

	move.l	#200000,%d0		/* half a second */
	jsr	usec_delay		/* wait 500ms */

	move.b	#ide_status,%d0
	bsr	ide_read		/* read status of drive 0 */
	cmp.b	#0x50,%d1		/* check exact status bits */
	bne.s	reset1

.if RECAL
	btst	#4,(disk_slave_o,%a1)		/* test SLAVE bit */
	bne.s	reset10				/* branch if SLAVE */
	move.b	#ide_command,%d0	/* do a recalibrate of drive 0 */
	move.b	#ide_cmd_recal,%d1	/* do a recalibrate of the drive */
	bsr	ide_write
	
	bsr	ide_wait_not_busy
	bne.s	reset1
reset10:
.endif
	add.l	#1,%a0				/* mark drive 0 present */
reset1:
       	move.b	#0b11110000,%d1
	move.b	#ide_head,%d0		/* select drive 1 */
	bsr	ide_write

	move.l	#1000,%d0			/* delay 10 ms = 10,000 usec */
	jsr	usec_delay

	move.b	#ide_status,%d0
	bsr	ide_read		/* read status of drive 0 */
	cmp.b	#0x50,%d1		/* check exact status bits */
	bne.s	reset2
.if RECAL
	btst	#4,(disk_slave_o,%a1)		/* test SLAVE bit */
	beq.s	reset20				/* branch if SLAVE */
	move.b	#ide_command,%d0	/* do a recalibrate of drive 0 */
	move.b	#ide_cmd_recal,%d1	/* do a recalibrate of the drive */
	bsr	ide_write
	
	bsr	ide_wait_not_busy
	bne.s	reset2
reset20:
.endif
	add.l	#2,%a0				/* mark drive 0 present */
reset2:
       	move.b	#0b11100000,%d1
	move.b	#ide_head,%d0		/* select drive 0 */
	bsr	ide_write

	move.l	%a0,%d1				/* move to D1 */
	move.l	%d1,arg1(%sp)			/* save in stack */
	clr.l	%d0
	tst.b	%d1
	bne.s	reset3
	move.l	#1,%d0				/* error return */
reset3:
	rts




#------------------------------------------------------------------------------
# IDE INTERNAL SUBROUTINES 
#------------------------------------------------------------------------------


#	
#----------------------------------------------------------------------------
#  Get Error code
#
#	;when an error occurs, we get bit 0 of A set from a call to ide_drq
#	;or ide_wait_not_busy (which read the drive's status register).  If
#	;that error bit is set, we should jump here to read the drive's
#	;explaination of the error, to be returned to the user.  If for
#	;some reason the error code is zero (shouldn't happen), we'll
#	;return 255, so that the main program can always depend on a
#	;return of zero to indicate success.
#
#  Exit with:
#	D0 contains exact status byte as read
#	D1 destroyed
#----------------------------------------------------------------------------
.if 0
get_err:
	move.b	#ide_err,%d0
	bsr	ide_read

	clr.l	%d0
	or.b	%d1,%d0
	bne.s	gerr2
	sub.b	#1,%d0
gerr2:
	rts
.endif


#-----------------------------------------------------------------------------
#  Wait for BUSY to be reset
#
#  Exit with:
#	D0 contains exact status byte as read
#	D1 destroyed
#
#------------------------------------------------------------------------------
ide_wait_not_busy:
	move.l	%d4,-(%sp)

	move.l	#-1,%d4
wnb1:
	move.b	#ide_status,%d0
	bsr	ide_read

	move.b	%d1,%d0
	eor.b	#0x40,%d0		/* want busy==0, rdy==1 */
	and.b	#0xC0,%d0		/* mask off Busy(7) & Drdy(6) */
	dbeq.w	%d4,wnb1		/* loop */
	bne.s	wnb2

	clr.l	%d0			/* zero extend D0, set EQ (Z-bit) */
wnb2:
   /* return EQ if no timeout, NE if timeout */
	move.l	(%sp)+,%d4
	tst.l	%d0
	rts


	.even
#------------------------------------------------------------------------------
#	;Wait for the drive to be ready to transfer data (DRQ = data request)
#	;Returns the drive's status in Acc
#
#  Exit with:
#	D0 contains exact status byte as read
#	D1 destroyed
#
#------------------------------------------------------------------------------
ide_wait_drq:
	move.l	%d4,-(%sp)

	move.l	#-1,%d4
wdrq1:
	move.b	#ide_status,%d0
	bsr	ide_read

	move.b	%d1,%d0
	eor.b	#0x08,%d0		/* want busy==0, drq==1 */
	and.b	#0x88,%d0		/* mask off Busy(7) and DRQ(3) */
	dbeq.w	%d4,wdrq1
	bne.s	wdrq2

	clr.l	%d0			/* zero extend D0 */
wdrq2:
	move.l	(%sp)+,%d4
	tst.l	%d0
	rts

.if 0
wdrq2a:
	move.l	%d1,-(%sp)
	pea	fmt2
	jsr	cprintf
	lea.l	8(%sp),%sp
	br	wdrq2

fmt2:
	.asciz	"WDRQBusy: %hx\n"
.endif
	.even


#------------------------------------------------------------------------------
# Read a sector of 512 bytes into memory at (A1)
#
#  Call with:
#	A0 -- pointer to the data block
#
#  Exit with:
#	A0 is updated
#	D0,D1 are destroyed
#
#-----------------------------------------------------------------------------
read_data:
	move.l	%d2,-(%sp)		/* save D2 */

	move.b	#ide_data,%d0
	move.w	#256-1,%d2		/* read 512 bytes */
rdblk2: 
	bsr.s	ide_read
	ror.w	#8,%d1			/* swap bytes */
	move.w	%d1,(%a0)+
	dbra.w	%d2,rdblk2

	move.l	(%sp)+,%d2		/* restore D2 */
	rts



#------------------------------------------------------------------------------
#  Verify a block of 512 bytes (one sector) from the drive
#
#  Call with:
#	Nothing
#
#  Exit with:
#	D0..D2 are destroyed
#
#-----------------------------------------------------------------------------
verify_data:
	move.b	#ide_data,%d0
	move.w	#256-1,%d2
verblk2: 
	bsr.s	ide_read
	dbra.w	%d2,verblk2

	rts


#-----------------------------------------------------------------------------
# Write a block of 512 bytes (at ES:BX to the drive)
#
#  Call with:
#	A0 -- pointer to the data block
#
#  Exit with:
#	A1 is preserved
#	D0,D1 are destroyed
#
#-----------------------------------------------------------------------------
write_data:
	move.l	%d2,-(%sp)		/* save D2 */

	move.b	#ide_data,%d0
	move.w	#256-1,%d2
wrblk2: 
	move.w	(%a0)+,%d1
	ror.w	#8,%d1
	bsr.s	ide_write
	dbra.w	%d2,wrblk2

	move.l	(%sp)+,%d2		/* restore D2 */
	rts



#-----------------------------------------------------------------------------
# write the logical block address to the drive's registers
#
#  Call with:
#	A1 = disk table pointer (use to get slave bit)
#	D2.l = logical block address
#	D3.b = sector count
#
#  Exit with:
#	D0, D1  are destroyed
#
#-----------------------------------------------------------------------------
wr_lba:
	move.l	%d2,%d1			/* LBA address to D1 */
	move.b	(disk_slave_o,%a1),%d0	/* get slave byte */
	and.b	#0x10,%d0		/* for safety */
	rol.l	#8,%d1			/* hi byte of LBA to low 8 bits */
	and.b	#0x0F,%d1		/* 28 bit limit */
	or.b	%d0,%d1			/* slave bit to D1 */
	or.b	#0xE0,%d1		/* select LBA mode */
	
	move.b	#ide_head,%d0		/* write to head register */
	bsr.s	ide_write

	rol.l	#8,%d1
	sub.l	#1,%d0			/* cyl msb reg */
	bsr.s	ide_write

	rol.l	#8,%d1
	sub.l	#1,%d0			/* cyl lsb reg */
	bsr.s	ide_write

	rol.l	#8,%d1
	sub.l	#1,%d0			/* sector reg */
	bsr.s	ide_write

	move.b	%d3,%d1			/* sector count from D3 */
	and.b	#0x7f,%d1		/* for safety */
	sub.l	#1,%d0			/* sector count reg */
	bsr.s	ide_write

	rts
#	
#-------------------------------------------------------------------------------

# Low Level I/O to the drive.  These are the routines that talk
# directly to the drive, via the 8255 chip.  Normally a main
# program would not call to these.

# Do a read bus cycle to the drive, using the 8255.
#
#  Call With:
#	D0.b = ide register address
#
#  Exit With:
#	D0.b preserved
#	D1.w = word read from IDE drive
#
#
ide_read:
	move.b	#rd_ide_8255,portCTRL_o(%a5)	/* bsr set_ppi_rd */
##	bsr.s	set_ppi_rd		/* setup for a read cycle */

	move.b	%d0,portC_o(%a5)	/* drive address onto control lines */
	or.b	#ide_rd_line,%d0	/* assert RD pin */
	move.b	%d0,portC_o(%a5)

	move.b	portB_o(%a5),%d1		/* read MSB */
	lsl.w	#8,%d1			/* make room for LSB */
	move.b	portA_o(%a5),%d1

	eor.b	#ide_rd_line,%d0	/* clear RD signal */
	move.b	%d0,portC_o(%a5)

#	move.b	#0,portC_o(%a5)		/* clear all control lines */
	clr.b	portC_o(%a5)		/* release bus signals */

	rts




# Do a write bus cycle to the drive, via the 8255
#
#  Call With:
#	D0.b = ide register address
#	D1.w = word to write out
#
#  Exit with:
#	Nothing changed
#
		.even
ide_write:
	move.b	#wr_ide_8255,portCTRL_o(%a5)	/* bsr	set_ppi_wr  */

	move.b	%d1,portA_o(%a5)	/* output LSB */
	ror.w	#8,%d1
	move.b	%d1,portB_o(%a5)	/* output MSB */
	ror.w	#8,%d1

	move.b	%d0,portC_o(%a5)		/* output the address */
	or.b	#ide_wr_line,%d0	/* assert the WR line */
	move.b	%d0,portC_o(%a5)

	eor.b	#ide_wr_line,%d0	/* clear the WR line */
	move.b	%d0,portC_o(%a5)

#	move.b	#0,portC_o(%a5)		/* release bus signals */
	clr.b	portC_o(%a5)		/* release bus signals */
	rts

.if 0
#-----------------------------------------------------------------------------------	
# ppi setup routine to configure the appropriate PPI mode
#
#------------------------------------------------------------------------------------

		.even
set_ppi_rd:
	move.b	#rd_ide_8255,portCTRL_o(%a5)
	rts

		.even
set_ppi_wr:
	move.b	#wr_ide_8255,portCTRL_o(%a5)
	rts
.endif

#-----------------------------------------------------------------------------
# End of PPIDE disk driver
#

	.end

