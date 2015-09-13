/*  dualsd.s		*/
/*
	Copyright (C) 2015 John R. Coffman.
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
.include "hardware.s"
#-----------------------------------------------------------------------------
.include "allide.s"
.include "error.s"
#-----------------------------------------------------------------------------

USE_CRCs	=	1		/* CRC16's or not	*/

Dual_SD_port	=	0x08		/* Z80 port $08		*/

arg1	=	4
arg2	=	arg1+4
arg3	=	arg2+4
arg4	=	arg3+4

buffer	= 	arg2

SD_operation	=	0	/* kept in A5 */
SD_select	=	1
dual_SD_op	=	BOARD_BASE_IO + Dual_SD_port	/* Operation Reg */
dual_SD_sel	=	dual_ide_A + SD_select		/* Selection Reg */


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
#  dsd_reset
# -----------------------------------------------------------------------------	
#	arg1	disk number  (D1)
#	A1	disk table pointer
#	A5	principal M68k I/O address of device
#
#   Returns D1 (in stack) mask of devices present (D0 == 0)
#   Error return if no devices on unit.
# -----------------------------------------------------------------------------	
	.even
	.globl	dsd_reset
dsd_reset:
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
#  dsd_read_id
#  dsd_info		; equivalent
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
dsd_read_id:
		.globl	dsd_info
dsd_info:
	move.l	(buffer,%sp),%a0		/* get buffer address */

	move	%a0,%d0				/* test for NULL */
	tst.l	%d0
.if 0
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
.endif

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
#  dsd_read
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
	.globl	dsd_read
dsd_read:
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
#  dsd_verify
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
	.globl	dsd_verify
dsd_verify:
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
#  dsd_write
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
	.globl	dsd_write
dsd_write:
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




/******************************************************************
;------------------------------------------------------------------------
;  internal functions below this point
;------------------------------------------------------------------------
*******************************************************************/
SDtypeUnknown	=	0
SDtypeMMC	=	1	/* unused, probably		*/
SDtypeSDSC	=	2	/* standard, odd addressing		*/
SDtypeSDHC	=	3	/* large, lba addressing		*/
SDtypeSDXC	=	4	/* super large capacity		*/


/* Operation Register (0x08) bits:		*/
SD_DATA		=	1	/* data I/O bit		*/
SD_CLK		=	1<<1	/* clock bit				*/
SD_CS		=	1<<2	/* chip select bit op. reg.		*/
SD_WP		=	1<<4	/* Write Protect status of selected unit		*/
SD_CD		=	1<<5	/* Card Detect status of selected unit		*/
bit_SD_CD	=	5


/* Status Register (0x09) bits:	 (flag byte)		*/
ST_UNIT		=	1	/* r/w unit select		*/
ST_WP0		=	1<<2	/* ro write protect status of slot 0		*/
ST_WP1		=	1<<3	/* ro write protect status of slot 1		*/
ST_CD0		=	1<<4	/* r/w card detect status of slot 0		*/
ST_CD1		=	1<<5	/* r/w card detect status of slot 1		*/
ST_IEN		=	1<<6	/* wo Interrupt Enable		*/
ST_CHANGE	=	1<<7	/* wo Change Enable (bits 4, 5, 6)		*/
ST_IPEND0	=	1<<6	/* ro Interrupt Pending on slot 0		*/
ST_IPEND1	=	1<<7	/* ro Interrupt Pending on slot 1		*/


/* ResetCommand:		*/
CMD0:		.byte	0x40 | 0
		.byte	0
		.byte	0
		.byte	0
		.byte	0
		.byte	0x95
CMD8:		.byte	0x40 | 8
		.byte	0
		.byte	0
		.byte	0x01
		.byte	0xAA
		.byte	0x87
CMD9:		.byte	0x40 | 9
		.byte	0
		.byte	0
		.byte	0
		.byte	0
		.byte	0xAF
CMD10:		.byte	0x40 | 10
		.byte	0
		.byte	0
		.byte	0
		.byte	0
		.byte	0x1B
CMD16:		.byte	0x40 | 16
		.byte	0
		.byte	0
		.byte	512>>8
		.byte	512&0xFF
		.byte	0x15
CMD55:		.byte	0x40 | 55
		.byte	0
		.byte	0
		.byte	0
		.byte	0
		.byte	0x65
ACMD41:		.byte	0x40 | 41
		.byte	0x40
		.byte	0
		.byte	0
		.byte	0
		.byte	0x77
CMD58:		.byte	0x40 | 58
		.byte	0
		.byte	0
		.byte	0
		.byte	0
		.byte	0xFD
.if USE_CRCs
CMD59:		.byte	0x40 | 59
		.byte	0
		.byte	0
		.byte	0
		.byte	1
		.byte	0x83
.endif

CMD17_read	=	0x40 | 17
CMD24_write	=	0x40 | 24


/*------------------------------------------------------------------------
; SDunit
;	Selects the unit (0, or 1)
;
;  Enter with:
;	nothing
;
;  Exit with:
;	Side effect, unit 0/1 is selected
;
;	D0 is trashed
;------------------------------------------------------------------------*/
	.even
SDunit:
	move.b	disk_slave_o(%a1),%d0	/* unit 0 or 1 */
	move.b	%d0,SD_select(%a5)	/* select unit based on bit 0 */
	rts



/*------------------------------------------------------------------------
; SDselect 	Select the correct unit, and assert ChipSelect
;
;  Enter with:
;	nothing
;
;  Exit with:
;	CS is asserted (to align 8-bit command/data bytes)
;	Z-flag is clear on success
;
;  Errors:
;	ERR_NO_MEDIA if no card is present
;
;------------------------------------------------------------------------*/
	.even
SDselect:
	bsr.s	SDunit		/* select unit */
/* Check for card present			*/
	move.l	#ERR_NO_MEDIA,%d0	/* possible error code
	btst	#bit_SD_CD,(%a5)	/* check Card Detect */
	beq.s	select9			/* error if Zero */

	move.b	#SD_CS+SD_DATA,(%a5)	/* set ChipSelect & DataOut, no Clock */
/*	move.l	#NO_ERROR,%d0			/* signal No Error */
	clr.l	%d0			/* signal No Error	*/
select9:
	or.b	%d0,%d0			/* set Z bit */
	rts

/*------------------------------------------------------------------------
; SDget	Get a byte from DATOUT on the SD card
;
;  Assume:
;	Chip Select is already asserted
;	Clock is low
;
;  Return with:
;	D0.B	= the byte read
;	Clock is low, Chip Select is still asserted
;
;------------------------------------------------------------------------*/
	.even
SDget:
	move.l	%d2,-(%sp)		/* save D2		*/

	move.l	#8,%d1			/* count 8 bits		*/
	bra.s	SDget2
SDget1:
	move.b	(%a5),%d2		/* get data_in on bit 0 */
	lsr.b	#1,%d2			/* shift into C & X bits */
	move.b	#SD_CS+SD_CLK+SD_DATA,(%a5) /* raise the clock */
	roxl	#1,%d0			/* shift into D0 */
SDget2:
	move.b #SD_CS+SD_DATA,(%a5)	/* clock low, chip_sel, data_out */
	dbra	%d1,SDget1

	move.l	(%sp)+,%d2		/* restore D2		*/
	rts


/*------------------------------------------------------------------------
; SDput		Put a byte to DATIN on the SD card
;
;  Enter with:
;	D0.B	byte to put out
;
;  Assume:
;	Chip Select is already asserted (except for SDsendclks)
;	Clock may be high or low
;
;  Return with:
;	Chip Select is unchanged (still asserted)
;	Clock is active (high)
;
;	D0 and D1 are trashed
;
;------------------------------------------------------------------------*/
	.even
SDput:
	move.l	%d2,-(%sp)		/* save D2		*/

	move.l	#7,%d1			/* count 7..0 */
SDput1:
	move.l	#SD_CS/2,%d2		/* Chip Select will be asserted */
	lsl.b	#1,%d0			/* hi-bit to X */
	roxl	#1,%d2			/* Chip Select, Clock Low, Data Out */
	move.b	%d2,(%a5)		/* put out the data bit */
	or.b	#SD_CLK,%d2		/* assert the clock */
	move.b	%d2,(%a5)		/* put out the data bit & clock */
	dbra	%d1,SDput1		/* loop back */

	move.l	(%sp)+,%d2		/* restore D2		*/
	rts



/*------------------------------------------------------------------------
; cmd_R1	issue command and get R1 response
;
;  Enter with:
;	A0	pointer to the command (5 of 6 bytes)
;
;  Uses:
;	B & C registers
;
;  Exit with:
;	Z flag set (EQ):
;		D0.b is the response to the command
;	Z flag clear (NE):
;		D0 is the error code
;	A0 is incremented by 5
;
;  Errors:
;	ERR_TIMEOUT	if no response within 8 byte times (NE condition)
;	ERR_NO_MEDIA
;
;------------------------------------------------------------------------
cmd_R1:
	call	SDselect
	ret	nz

	ld	b,#6		; all commands are 6 bytes
cmr1:
	ld	c,(hl)		; get a byte of the command
	inc	hl		; increment the pointer
	call	SDput		; put out the byte
	djnz	cmr1		; loop back

	ld	b,#9			; response must come within 8 chars
cmr2:	call	SDget
	ld	a,c			; response in A & C (no error)
	ld	hw_status-instance(IY),c  ; save response in Status byte
	bit	7,c			; test high bit
	ret	z			; return with Z set
	djnz	cmr2			; does not touch the Flags
			; NZ condition is guaranteed here
	ld	a,c			; error byte in A
	ld	c,#ERR_TIMEOUT		; return error code
	ret				; return NZ if no response
*/
	.even
cmd_R1:
	movem	%d2-%d3,-(%sp)		/* save registers */
	bsr.s	SDselect
	 bne.s	cmdr19
	move.l	#6-1,%d3
cmdr11:
	move.b	(%a0)+,%d0		/* get byte to put out	*/
	bsr.s	SDput			/* put out the command byte */
	dbra	%d3,cmdr11		/* put out 5 bytes	*/

/* the command has been sent */
		
	move.l	#8,%d3			/* response must come within 8 chars */
cmdr13:
	bsr.s	SDget			/* get a character */
	move.b	%d0,disk_status_o(%a1)	/* save disk status byte */
	btst	#7,%d0			/* test hi-bit (7) */
	beq.s	cmdr19			/* return with Z flag set */
	dbra	%d3,cmdr13		/* loop back */

	move.w	#ERR_TIMEOUT,%d0	/* clear Zero flag, return error */
cmdr19:
	movem	(%sp)+,%d2-%d3		/* restore registers */
	rts


/*------------------------------------------------------------------------
; SDsendclks	send clock transitions to the card
;
;  Enter with:
;	D0 =	initial byte to send
;	D1.W =	count of clock transitions - 1 (must be odd;  15 / 255)
;
;  Return with:
;	D1.W =	-1
;
;	The Operation register is left in the D0 state.
;
;------------------------------------------------------------------------*/
	.even
SDsendclks:
	move.b	%d0,(%a5)		/* set initial clock */
	eori.b	#SD_CLK,%d0		/* invert clock */
/*  count 15..0 or 255..0  		*/
	dbra	%d1,SDsendclks		/* loop D1.w+1 times */

	move.b	%d0,(%a5)		/* set initial clock value */
	rts



/*------------------------------------------------------------------------
; SDdone	complete a transaction
;
;  Enter with:
;	Nothing
;
;  Return with:
;	All registers are preserved
;	Flags are preserved, too
;
;	The card is deselected!!!  (Chip_Select is cleared)
;
;------------------------------------------------------------------------*/
	.even
SDdone:
	movem	%d0-%d2,-(%sp)		/* save 3 registers */
	move	%sr,%d2			/* save CCR+SR */

	move.l	#SD_DATA,%d0 		/* Chip Select OFF, Clock Low, Data Idle (high) */
	move.l	#15,%d1
	bsr.s	SDsendclks

	move	%d2,%sr			/* restore CCR */
	movem	(%sp)+,%d0-%d2		/* restore registers */
	rts				/* return */



/*------------------------------------------------------------------------
; SDcmdset	Set up a command in the stack
;
;  Enter with:
;	D0	Command byte
;	D2	parameter word
;
;	C	Command byte
;	DE	high order parameter word
;	HL	low order parameter word
;
;  Return with:
;	A0	points to command in the stack
;	SP	decremented by 8 (stack alignment is maintained)
;
;	HL	points at stack top
;	SP	is decremented by 6 (size of the command)
;	BC & DE are trashed
;
;	The sixth byte of the command is the CRC7 value needed
;------------------------------------------------------------------------
SDcmdset:
	ld	b,h
	ex	(sp),hl		; stack has  L,X
				; HL = return address
	ld	a,c
	ld	c,e
	push	bc		; stack has  E,H,L,X
	ld	e,a
	push	de		; stack has  C,D,E,H,L,X
	push	hl		; save return address
	ld	hl,#2		; address of command
	add	hl,sp		; HL -> command
.if USE_CRCs
	push	hl		; save command pointer
	ld	b,#5		; CRC7 calculated over 5 bytes
	call	calcCRC7
	ld	(hl),e		; store CRC7 calculation
	pop	hl		; restore HL
.endif
	ret
*/
	.even
SDcmdset:
	move	%a0,-(%sp)	/* this loc. and return address will
					become the command area of 6 bytes */
	move	%sp,%a0		/* A0 is command pointer */
	move	4(%sp),-(%sp)	/* stack the return address */

	movem	%d2/%a2,-(%sp)	/* register save */

	move.w	%d0,(%a0)+	/* SP+1 is command byte */
.if USE_CRCs
	and.w	#0xFF,%d0
	lea	table7,%a2	/* address table from A2 */
	move.l	#4,%d1		/* 4 parameter bytes */
	bra.s	cms4
cms2:
	rol.l	#8,%d2
	move.b	%d2,(%a0)+	/* store command byte */
	eor.b	%d2,%d0
cms4:	move.b	(%a2,%d0.w),%d0	/* update the CRC7 */
	dbra	%d1,cms2

	or.b	#1,%d0
	move.b	%d0,(%a0)	/* store the CRC7 */
.else
	move.l	%d2,(%a0)+	/* store the command parameter */
	move.b	#0xFF,(%a0)	/* store the CRC7 */
.endif
	lea	-5(%a0),%a0

	movem	(%sp)+,%d2/%a2	/* register restore */
	rts

/*
;------------------------------------------------------------------------
; SDwaitrdy	wait for card to become ready
;
;  Enter with:
;	nothing
;
;  Uses:
;	B & C registers
;
;  Return with:
;	Z flag = 1	no error, character+1 in C
;	Z flag = 0	error, timeout; B reg == 1
;
;------------------------------------------------------------------------
SDwaitrdy:
	call	SDselect	; assert Chip Select
	ret	nz

	ld	b,#0x7F		; count 0x7F7F
	ld	timeout-instance(IY),b
waitrdy1:
	call	SDget
	inc	c		; 0xFF -> 0x00
	ret	z		; Z flag set -- no error
	djnz	waitrdy1
	dec	timeout-instance(IY)
	jr	nz,waitrdy1	; outer count loop
	
	or	a,c		; clear the Z flag (C != 0)
	ld	c,#ERR_TIMEOUT	; return error code with Z flag clear
	ret			; NZ is flagged
*/
	.even
SDwaitrdy:
	movem	%d3,-(%sp)	/* register save */

	bsr	SDselect
	bne	sdwr9
	move.w	#0x7FFF,%d3
sdwr1:
	bsr	SDget		/* get a byte from the card */
	cmp.b	#0xFF,%d0	/* 0xFF returned means ready */
	beq.s	sdwr9
	dbra	%d3,sdwr1
	move.l	#ERR_TIMEOUT,%d0	/* signal timeout error	*/
/* Z flag is clear (NE condition) */
sdwr9:
	movem	(%sp)+,%d3	/* register restore */
	rts	

/*------------------------------------------------------------------------
; SDgoidle	put card in the idle state
;
;  Enter with:
;	nothing
;
;  Uses:
;	B and C
;	HL
;
;  Return with:
;    Zero flag set:
;	D0	response to CMD0
;
;    Zero flag clear:
;	D0	error code
;
;------------------------------------------------------------------------
SDgoidle:
	ld	b,#200		; about 5 milliseconds or so
go1:	call	_delay32
	djnz	go1

	ld	hl,#CMD0
	call	cmd_R1		; execute command 0
	call	SDdone		; de-selects the card
	ld	a,c		; check the response
	ret	nz		; error return
	cp	#0x01		; check for '0000_0001' response
	ret	z
	ld	c,#ERR_DISK_IO
	ret
*/
  	.even
SDgoidle:
/* delay stuff */
	lea	CMD0,%a0	/* command 0 	*/
	bsr	cmd_R1
	bsr	SDdone		/* end command */
	bne.s	sdgi9
	cmp.b	#0x01,%d0	/* check for $01 response */
	beq.s	sdgi9
	move.l	#ERR_DISK_IO,%d0	/* error return */
/* NE condition is set in Flags */
sdgi9:
	rts
	


/*
;------------------------------------------------------------------------
; SDinitcard	initialize a newly inserted SD card
;
;  Enter with:
;	nothing
;
;  Return with:
;	Zero flag reflects status
;
;  Errors:
;	ERR_TIMEOUT
;
;------------------------------------------------------------------------
.if nRETAIL
_SDinitcard::
	push	iy
	ld	iy,#instance
	call	SDinitcard
	pop	iy

	ld	l,c
	ld	h,#0
.if DEBUG2
	ld	a,c
	or	a,a
	ret	z
	out	(port_B),a
.endif
	ret
.endif


SDinitcard:
; STRANGE SEQUENCE
	call	SDselect		; select the unit
	ret	nz
	call	SDdone			; seems to help some cards
;---------

	ld	b,#256			; 256 clock transitions (16 bytes)
	ld	a,#SD_CS+SD_DATA
	call	SDsendclks		; send 16*8 = 128 clock pulses

	call	SDwaitrdy		; wait for card to go ready
	ret	nz			; may time out

; send the Reset (CMD0) command:
	call	SDgoidle		; only 1 needed
	ret	nz

	ld	hl,#CMD8
	call	cmd_R1			; check card version
	ret	nz
	ld	a,c
	and	#~0x01			; any of the error bits set?
	jr	nz,inc8
.if DEBUG2
	call	SDget			; v.2 card returns 4 more bytes
	ld	h,c
	call	SDget			; the R7 response
	ld	l,c
	push	hl
	call	SDget			;   is R1 + 4 more bytes
	ld	h,c
	call	SDget			; **
	ld	l,c
	push	hl
	ld	hl,#cmd8fmt
	push	hl
	.globl	_cprintf
	call	_cprintf
	pop	af
	pop	af
	pop	af
	jr	cmd8end
cmd8fmt:	.asciz	"CMD8 v.2 response: 0x%04lx\n"
cmd8end:
.else
	call	SDget			; v.2 card returns 4 more bytes
	call	SDget			; v.2 card returns 4 more bytes
	call	SDget			; v.2 card returns 4 more bytes
	call	SDget			; v.2 card returns 4 more bytes
.endif
inc8:
	call	SDdone			; ignore any error

	ld	b,#0			; try 256 times to do the init
inc10:
	push	bc			; save outer count

	ld	b,#200
inc11:	call	_delay32		; wait awhile
	djnz	inc11
	ld	hl,#CMD55		; signal ACMD is next
	call	cmd_R1			; issue the command
	call	SDdone
	jr	z,inc12
one_pop:
	pop	af
	ret				; NZ is set
inc12:		; CMD55 is okay, so far
	and	a,#~01			; only 1 or 0 are okay
	ld	c,#ERR_DISK_IO
	jr	nz,one_pop		;exit with NZ ser

	ld	hl,#ACMD41		; set for App. command
	call	cmd_R1
	call	SDdone			; A is response to ACMD41

      	pop	bc			; restore counter
	ld	c,#ERR_DISK_IO
.if 0
	tst	a,#~01			; only 1 or 0 are okay
	ret	nz			; error

	tst	a,#01			; Idle, running init?
	jr	z,inc16			; Init is done	
.else
	or	a,a			; test for 0
	jr	z,inc16			; if so, jump out of loop

	dec	a			; test for 1
	ret	nz
.endif

	djnz	inc10			; doesn't touch any flags

; NZ is known to be set from the TST a,#01 above
	ld	c,#ERR_TIMEOUT
	ret
inc16:			; initialization is done

; now find out SDSC or SDHC card
 	ld	hl,#CMD58
	call	cmd_R1
	call	nz,SDdone
	ret	nz
	call	SDget		; get hi-byte of OCR
	ld	a,c    		; bit 6 is HC bit
	ld	OCR-instance(IY),c
	and	#1<<6		; test bit 6
	ld	SDtype-instance(IY),#SDtypeSDHC
	jr	nz,inc17
	ld	SDtype-instance(IY),#SDtypeSDSC
inc17:
	call	SDget			; byte 2
	ld	OCR+1-instance(IY),c
	call	SDget
	ld	OCR+2-instance(IY),c
	call	SDget
	ld	OCR+3-instance(IY),c
	call	SDdone

.if USE_CRCs
	ld	hl,#CMD59		; checking ON
	call	cmd_R1
	call	SDdone
	ret	nz
.endif

; set the desired block length -- CMD16(512)
	ld	hl,#CMD16
	call	cmd_R1
	call	SDdone
	ret	nz

;	mov	[SDstatus + di], al	; save SD card status
;
;; get the Card Specific Data (CSD) register contents
	ld	hl,#CMD9
	call	cmd_R1
	call	nz,SDdone
	ret	nz

	ld	hl,#CSD-instance
	push	iy
	pop	bc
	add	hl,bc

	ld	bc,#16		; get 16 bytes
	call	SDgetdata
	call	SDdone
	ret	nz

	ld	a,CSD-instance(IY)	; get CSD version no.
	and	#0xC0			; check hi-bits
	jr	z,csdv1
; CSD is version 2.0
csdv2:
	ld	de,#-9			; CSD+16 in HL
	add	hl,de			; CSD+7 in HL
	ld	d,(hl)			; C_SIZE << 8
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	h,(hl)
	inc	h
	jr	nz,csv2a
	inc	de
csv2a:	ld	l,#0			; have SIZE<<8
	ld	b,l
	jr	csdv1b			; go shift by 2 more
; CSD is version 1.0
csdv1:
	dec	hl			; point at CSD[15]
	ld	bc,#(49<<8)+47		; bits for MULT
	call	xbits
	push	de			; save MULT
	ld	bc,#(73<<8)+62		; C_SIZE bits
	call	xbits
	pop	hl
	ld	b,l			; shift factor to B
	ex	de,hl
	ld	de,#0			; DE:HL to be shifted
	inc	hl			; add 1 to the C_SIZE
csdv1b:
	inc	b
	inc	b			; add 2 to the shift
csdv1a:
	sla	l
	rl	h			; DWORD shift
	rl	e
	rl	d			; **
	djnz	csdv1a
gotlbamax:
	ld	capacity+0-instance(IY),l
	ld	capacity+1-instance(IY),h
	ld	capacity+2-instance(IY),e
	ld	capacity+3-instance(IY),d

;; get the Card ID Data (CID) register contents
	ld	hl,#CMD10
	call	cmd_R1
	call	nz,SDdone
	ret	nz

	ld	hl,#CID-instance
	push	iy
	pop	bc
	add	hl,bc

	ld	bc,#16		; get 16 bytes
	call	SDgetdata
	call	SDdone
	ret	nz

	ld	c,#NO_ERROR
	ret
*/
	.even
.if !RETAIL
	.globl	SD_initcard
SD_initcard:
	rts
.endif
SDinitcard:
	bsr	SDselect
	bne	sdi99		/* return on non-zero */
	bsr	SDdone
#------------
	move.w	#255,%d1
	move.l	#SD_CS+SD_DATA,%d0
	bsr	SDsendclks	/* put out 128 clock transistions */

	bsr	SDwaitrdy
	 bne	sdi99

/* send the Reset (CMD0) command */
	bsr	SDgoidle
	 bne	sdi99

	lea	CMD8,%a0
	bsr	cmd_R1
	 bne	sdi99
	and.b	#~01,%d0
	 bne	inc8
	bsr	SDget
	bsr	SDget
	bsr	SDget
	bsr	SDget
inc8:
	bsr	SDdone

inc10:

inc11:


sdi98:
	bsr	SDdone	
sdi99:
	rts




	.end

