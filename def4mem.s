#  def4mem.s
/*
    Copyright (C) 2015 John R. Coffman.
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
.ifndef _def4mem_s
_def4mem_s  =   1

.include "hardware.s"

# Z80 port address of first 4MEM board
dev_4mem_IO     =   0x00
dev_4mem_inc    =   2

# board base address:
dev_4mem0   =   BOARD_BASE_IO + dev_4mem_IO

.endif

