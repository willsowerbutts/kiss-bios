/* ds1302.s */
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

	.text

rtc_data        =     1               /* Data mask bit - DATA	*/
rtc_wren        =     2               /* Write enable bit - /WE	*/
rtc_clk         =     4               /* Clock signal - CLK	*/
rtc_rst         =     8               /* Reset bit - /RESET	*/

rtc_write_cmd	=	0x80		/* WRITE command */
rtc_read_cmd	=	0x81		/* READ	command */


#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#  rtc_get_loc          RTC get location as addressed
#	Enter with:
#			Address to get on Stack
#			RAM = (address) | 0x80
#			CLOCK = (address) | 0x00
#	Exit with 	data in D0
#               All other registers are preserved
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.globl  rtc_get_loc
rtc_get_loc:
	link	%a6,#0
	movm.l	%d1-%d3,-(%sp)

	bsr	rtc_reset
	bsr	rtc_reset_off

	move.l	8(%a6),%d1		/* get address to D1 bits (7..0) */
	add.l	%d1,%d1
	or.l	#rtc_read_cmd,%d1	/* make into a write command */
	bsr	rtc_write

	bsr	rtc_read		/* read the data value to D1 */

	bsr	rtc_reset_off
	bsr	rtc_reset

	clr.l	%d0			/* make for a clean return */
	move.b	%d1,%d0	

	movm.l	(-12,%a6),%d1-%d3
	unlk	%a6
	rts


#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#  rtc_set_loc          RTC set location as addressed
#	Enter with:
#			Address to get on Stack -- ARG1
#				RAM = (address) | 0x20
#				CLOCK = (address) | 0x00
#			Data to write on Stack -- ARG2
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.globl  rtc_set_loc
rtc_set_loc:
	link	%a6,#0
	movm.l	%d1-%d3,-(%sp)

	bsr	rtc_reset
	bsr	rtc_reset_off

	move.l	8(%a6),%d1		/* get address to D1 bits (7..0) */
	add.l	%d1,%d1
	or.l	#rtc_write_cmd,%d1	/* make into a write command */
	bsr	rtc_write

	move.l	12(%a6),%d1		/* ARG2 is data to write to address */
	bsr	rtc_write

	bsr	rtc_reset_off
	bsr	rtc_reset

	movm.l	(-12,%a6),%d1-%d3
	unlk	%a6
	rts






#	.globl  rtc_write
#  write byte in D1 to the DS1302 chip
rtc_write:
	move.l	#7,%d2
wr_loop:
	move.l	#rtc_wren/2,%d0		/* write enable, shifted right */
	lsr.l	#1,%d1 			/* bit 0 to X bit */
	roxl.l	#1,%d0			/* write enable + low data bit */
	bsr	rtc_out			/* put out the byte */

	or.l	#rtc_clk,%d0		/* set the clock bit */
	bsr	rtc_out
	
	dbra	%d2,wr_loop

	rts


#	.globl	rtc_read
#  read byte from the DS1302 chip to D1
rtc_read:
	move.l	#7,%d2
	clr.l	%d1
rd_loop:
	bsr	rtc_reset_off		/* WriteEnable off, Reset Off */

/* use a subroutine to introduce appropriate delays of 16 usec. or more */
	bsr	rtc_in			/* get byte to D1 */

	move.l	#rtc_clk,%d0		/* clock the chip */
	bsr	rtc_out

	ror.w	#1,%d1			/* accumulate data byte in bits 15..8 */
	dbra	%d2,rd_loop

	lsr.l	#8,%d1

	rts




/*	rtc_reset
	rtc_reset_off		3 functions using D0 internally
	rtc_out			D3 is used for the time delay

*/
rtc_reset:
	move.l	#rtc_rst,%d0		/* Reset, enable read */
	br.s	rtc_out

rtc_reset_off:
	clr.l	%d0
	/* fall into rtc_out */
/*
  rtc_out()    byte to put into latch is in D0
*/
rtc_out:
	move.b	%d0,mf_rtc		/* output D0 to the RTC latch */
	jsr	(usec09).l
	rts

/*
  rtc_in()	input byte to D1
*/
rtc_in:
	.rept	4
	nop
	.endr
	move.b	mf_rtc,%d1
	rts


	.end

