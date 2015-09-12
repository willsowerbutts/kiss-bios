#  ppi.s
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
#
.ifndef	_ppi_s
_ppi_s		=	1
.include  "mfpic.s"
############################################################

# offsets from the base port address
portA_o		=	0
portB_o		=	1
portC_o		=	2
portCTRL_o	=	3

# absolute port addresses
portA		=	mf_ppi + portA_o
portB		=	mf_ppi + portB_o
portC		=	mf_ppi + portC_o
portCTRL	=	mf_ppi + portCTRL_o

.endif
