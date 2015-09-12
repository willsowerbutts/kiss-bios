/* ns202def.s	*/
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
/*	*/
/*   Register definitions for the NS32202 interrupt controller	*/
/*	*/
/*	*/
.ifndef _ns202def_
_ns202def_ 	=	1
.include  "mfpic.s"
############################################################


hvct	        =  0	     /*b	  hardware vector - read by INTA only	*/
svct	        =  1	     /*b	  software vector - pending	*/
svcti           =  svct+32   /*b   software vector - in service	*/
eltg	        =  2	     /*w	  edge/level triggering	*/
tpl	        =  4	     /*w	  triggering polarity	*/
ipnd	        =  6	     /*w	  interrupts pending	*/
isrv	        =  8	     /*w	  interrupts in service	*/
imsk	        = 10	     /*w	  interrupt mask	*/
csrc	        = 12	     /*w	  cascaded source	*/
fprt	        = 14	     /*w	  first priority	*/
mctl	        = 16	     /*b	  mode control	*/
ocasn	        = 17	     /*b	  output clock assignment	*/
ciptr	        = 18	     /*b	  counter interrupt pointer	*/
pdat	        = 19	     /*b	  port data	*/
ips	        = 20	     /*b	  interrupt/port select	*/
pdir	        = 21	     /*b	  port direction	*/
cctl	        = 22	     /*b	  counter control	*/
cictl	        = 23	     /*b	  counter interrupt control	*/
lcsv	        = 24	     /*w	  l-counter starting value	*/
hcsv	        = 26	     /*w	  h-counter starting value	*/
lccv	        = 28	     /*w	  l-counter current value	*/
hccv	        = 30	     /*w	  h-counter current value	*/

eoi             = hvct+32    /*b   read for End Of Interrupt signal	*/


counter_clock	=	1843200    /* input counter (no prescaling yet) */
hi_byte	=	25			/* special values needed here */


/*    xwxwxwxwbbbbbbbbxwxwxwxwxwxwxwbb	*/
/*    01010101000000000101010101010100	*/

/*    0101 0101 0000 0000 0101 0101 0101 0100	*/
/*    0x55005554	*/
/*    0xFFFC,0xFF00	*/

.endif
