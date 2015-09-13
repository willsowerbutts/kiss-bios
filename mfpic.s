#  mfpic.s
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
.ifndef _mfpic_s
_mfpic_s 	=	1

.include "hardware.s"

# Z80 port address of MF/PIC board (required)
mf_pic		=	0x40

# board base address:
mfpic_base      =       BOARD_BASE_IO + mf_pic

mf_sio          =       mfpic_base + 8
mf_ppi          =       mfpic_base + 4
mf_rtc          =       mfpic_base + 3
mf_cfg          =       mfpic_base + 2
mf_202          =       mfpic_base + 0

.endif
