#  siodef.s
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
.ifndef	_siodef_s
_siodef_s	=	1
.include  "mfpic.s"
############################################################


/* Define the 8250, 16450, 16550, 16C550, 16C750 registers  */

sio_thr         = 0+mf_sio	/* transmitter holding register  */
sio_rbr		= 0+mf_sio	/* receiver buffer register  */
sio_ier		= 1+mf_sio	/* interrupt enable register  */
sio_iir		= 2+mf_sio	/* interrupt ident register (r/only)  */
sio_lcr		= 3+mf_sio	/* line control register  */
sio_mcr		= 4+mf_sio	/* modem control register  */
sio_lsr		= 5+mf_sio	/* line status register  */
sio_msr		= 6+mf_sio	/* modem status register  */
sio_scr		= 7+mf_sio	/* scratch register  */

sio_dll		=	sio_rbr	/* divisor latch lsbyte  */
sio_dlm		=	sio_ier	/* divisor latch msbyte  */

/*  define the ier (interrupt enable bits)  */

sio_ier_erbfi	=	0x01	/* enable received data available interrupt  */
sio_ier_ethei	=	0x02	/* enable transm holding reg empty interrupt  */
sio_ier_elsi	=	0x04	/* enable receiver line status interrupt  */
sio_ier_edssi	=	0x08	/* enable modem (data set) status interrupt  */


/*  define the iir (interrupt ident) bit settings  */

sio_iir_none	=	0x01	/* no interrupt is pending  */
sio_iir_rls 	=	0x06	/* receiver line status int. (highest priority)  */
sio_iir_rda    	=	0x04	/* received data available  */
sio_iir_thre	=	0x02	/* transmitter holding register empty  */
sio_iir_dss	=	0x00	/* modem (data set) status  */

sio_iir_none_bn	=	0x00	/* bit zero is no-int-pending bit  */


/*  define the lcr (line control register) bit settings  */

sio_lcr_5bits	=	0x00	/* select 5 data bits  */
sio_lcr_6bits	=	0x01	/* select 6 data bits  */
sio_lcr_7bits	=	0x02	/* select 7 data bits  */
sio_lcr_8bits	=	0x03	/* select 8 data bits  */
sio_lcr_bit_msk	=	0x03	/* mask for data word length select  */
sio_lcr_stb2	=	0x04	/* select 2 stop bits  */
sio_lcr_pen	=	0x08	/* parity enable  */
sio_lcr_eps	=	0x10	/* even parity select  */
sio_lcr_stick	=	0x20	/* stick parity  */
sio_lcr_break	=	0x40	/* set break condition on line  */
sio_lcr_dlab	=	0x80	/* divisor latch access bit  */


/*  define the mcr (modem control register) bits  */

sio_mcr_dtr	=	0x01	/* data terminal ready  */
sio_mcr_rts	=	0x02	/* request to send  */
sio_mcr_out1	=	0x04	/* user defined output 1  */
sio_mcr_out2	=	0x08	/* user defined output 2  */
sio_mcr_loop	=	0x10	/* diagnostic loopback mode  */


/*  define the lsr (line status register) bit settings  */

sio_lsr_dr	=	0x01	/* data ready  */
sio_lsr_dr_bit	=	0
sio_lsr_oe	=	0x02	/* overrun error  */
sio_lsr_oe_bit	=	1
sio_lsr_pe	=	0x04	/* parity error  */
sio_lsr_pe_bit	=	2
sio_lsr_fe	=	0x08	/* framing error  */
sio_lsr_fe_bit	=	3
sio_lsr_bi	=	0x10	/* break interrupt  */
sio_lsr_bi_bit	=	4
sio_lsr_thre	=	0x20	/* transmitter holding register empty  */
sio_lsr_thre_bit	=	5
sio_lsr_temt	=	0x40	/* transmitter empty  */
sio_lsr_temt_bit	=	6


/*  define the msr (modem status register) bit settings  */

sio_msr_dcts	=	0x01	/* delta clear to send  */
sio_msr_ddsr	=	0x02	/* delta data set ready  */
sio_msr_teri	=	0x04	/* trailing edge ring indicator  */
sio_msr_ddcd	=	0x08	/* delta data carrier detect  */
sio_msr_cts	=	0x10	/* clear to send  */
sio_msr_dsr	=	0x20	/* data set ready  */
sio_msr_ri	=	0x40	/* ring indicator  */
sio_msr_dcd	=	0x80	/* data carrier detect  */


.endif

