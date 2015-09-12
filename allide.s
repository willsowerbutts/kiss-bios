#  allide.s
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
.ifndef _allide_s
_allide_s 	=	1



max_disk	=  8
max_floppy	=  2

	.comm	disk_table,max_disk*4

/* DISK structure offsets */
disk_ops_o	=	0		/* operations dispatch ptr */
disk_lba_o	=	4		/* LBA number of cylinders */
disk_type_o	=	8		/* byte: disk type */
disk_port_o	=	9		/* byte: I/O port */
disk_slave_o	=	10		/* byte: MASTER=0, SLAVE=0x10 (IDE)
						SLAVE=0x01 (SD) */
disk_status_o	=	11		/* byte: last h/w status */
disk_geom_o	=	12		/* geometry longword */






#ide control lines for use with ide_8255_ctl.  Change these 8
#constants to reflect where each signal of the 8255 each of the
#ide control signals is connected.  All the control signals must
#be on the same port, but these 8 lines let you connect them to
#whichever pins on that port.

ide_a0_line	=	0x01		/* direct from 8255 to ide interface */
ide_a1_line	=	0x02		/* direct from 8255 to ide interface */
ide_a2_line	=	0x04		/* direct from 8255 to ide interface */
.ifdef	rd_ide_8255
/* for the PPIDE driver */
ide_cs0_line	=	0x08		/* inverter between 8255 and ide interface */
ide_cs1_line	=	0x10		/* inverter between 8255 and ide interface */
ide_wr_line	=	0x20		/* inverter between 8255 and ide interface */
ide_rd_line	=	0x40		/* inverter between 8255 and ide interface */
ide_rst_line	=	0x80		/* inverter between 8255 and ide interface */
.else
/* for the DUALIDE driver */
ide_cs0_line	=	0x00		/* at the base address */
ide_cs1_line	=	0x08		/* at the base address + 8 */
.endif

#------------------------------------------------------------------
# More symbolic constants... these should not be changed, unless of
# course the IDE drive interface changes, perhaps when drives get
# to 128G and the PC industry will do yet another kludge.

#some symbolic constants for the ide registers, which makes the
#code more readable than always specifying the address pins

ide_data       	=	ide_cs0_line
ide_err		=	ide_cs0_line + ide_a0_line
ide_sec_cnt	=	ide_cs0_line + ide_a1_line
ide_sector     	=	ide_cs0_line + ide_a1_line + ide_a0_line
ide_cyl_lsb	=	ide_cs0_line + ide_a2_line
ide_cyl_msb	=	ide_cs0_line + ide_a2_line + ide_a0_line
ide_head       	=	ide_cs0_line + ide_a2_line + ide_a1_line
ide_command	=	ide_cs0_line + ide_a2_line + ide_a1_line + ide_a0_line
ide_status     	=	ide_cs0_line + ide_a2_line + ide_a1_line + ide_a0_line

ide_control	=	ide_cs1_line + ide_a2_line + ide_a1_line
ide_astatus	=	ide_cs1_line + ide_a2_line + ide_a1_line
ide_address	=	ide_cs1_line + ide_a2_line + ide_a1_line + ide_a0_line
.ifndef	rd_ide_8255
ide_data_16	=	ide_cs1_line
ide_dma_16	=	ide_cs1_line + ide_a0_line
.endif

#IDE Command Constants.  These should never change.
ide_cmd_recal		=	0x10
ide_cmd_read		=	0x20
ide_cmd_write		=	0x30
ide_cmd_init		=	0x91
ide_cmd_id     		=	0xEC
ide_cmd_set_feature	=	0xEF
ide_cmd_spindown	=	0xE0
ide_cmd_spinup		=	0xE1

#Feature requests
ide_fea_8bit		=	0x01
ide_fea_16bit		=	0x81

  /* end  allide.s */
.endif
#------------------------------------------------------------------

