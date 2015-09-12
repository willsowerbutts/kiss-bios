#  mfpic.s
/*
	Copyright (C) 2011,2015 John R. Coffman.
	Licensed for hobbyist use only.
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
.ifndef _mfpic_s
_mfpic_s 	=	1
KISS		=	1

# Z80 port address of MF/PIC board (required)
mf_pic		=	0x40

# KISS68030 I/O address base
KISS68030_IO	=	0xFFFF8000
babyM68k_IO	=	0xFFFF8000

# board base address:
mfpic_base      =       KISS68030_IO + mf_pic

mf_sio          =       mfpic_base + 8
mf_ppi          =       mfpic_base + 4
mf_rtc          =       mfpic_base + 3
mf_cfg          =       mfpic_base + 2
mf_202          =       mfpic_base + 0


.if KISS

#  Cache control bits in the CACR

CACR_EI		=	1	/* Enable Instruction Cache		*/
CACR_FI		=	1<<1	/* Freeze Instruction Cache		*/
CACR_CEI	=	1<<2	/* Clear Entry in Instr. Cache		*/
CACR_CI		=	1<<3	/* Clear Instruction Cache		*/
CACR_IBE	=	1<<4	/* Instr. Cache Burst Enable		*/

CACR_ED		=	1<<8	/* Enable Data Cache			*/
CACR_FD		=	1<<9	/* Freeze Data Cache			*/
CACR_CED	=	1<<10	/* Clear Entry in Data Cache		*/
CACR_CD		=	1<<11	/* Clear Data Cache			*/
CACR_DBE	=	1<<12	/* Data Cache Burst Enable		*/
CACR_WA		=	1<<13	/* Write Allocate the Data Cache	*/

CACR0	= 	CACR_CI + CACR_EI  +  CACR_CD + CACR_ED

.endif


.endif
