/* error.s				*/
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

/* error codes follow			*/
NO_ERROR	=	0
/*			*/
/*	Mild errors 1..63			*/
/*			*/
ERR_NOT_YET	=	1	/* Method still being implemented			*/

/*	Definite errors	64..127			*/
/*			*/
ERR_UNKNOWN	=	65	/* Unknown call			*/
ERR_UNIT_NO	=	66	/* unit no. bad			*/
ERR_METHOD	=	67	/* method number is bad			*/
ERR_ADDRESS	=	68	/* address out of range (must be >=0x8000)			*/
ERR_DECODE	=	69	/* not an encoded value (decode.s)			*/
ERR_CAPACITY	=	70	/* LBA address beyond disk capacity			*/
ERR_NO_MEDIA	=	71	/* no Media in drive socket			*/
ERR_WRONG_MEDIA =	72	/* not SDSC or SDHC			*/
ERR_WRITE_PROT	=	73	/* media is write-protected			*/

ERR_NO_PROTO	=	129	/* no Instance prototype found			*/
ERR_NO_MEMORY	=	130	/* ran out of Heap memory			*/
ERR_NO_UNIT	=	131	/* no new unit available			*/
ERR_SIO_BAUD	=	132	/* serial baud rate setup not possible			*/
ERR_DISK_IO	=	133	/* disk I/O error			*/
ERR_TIMEOUT	=	134	/* timeout			*/
ERR_CRC16	=	135	/* CRC16 error on data read			*/

CATASTROPHE_HEAP	=	241	/* HEAP catastrophe			*/
DRIVE_TRANSFER_NOT_SET	=	242	/* DRIVE NOT 8 & NOT 16 BIT			*/


/* end error.s			*/
