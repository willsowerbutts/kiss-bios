/* ns202.c	*/
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
#include "mytypes.h"
#include "mfpic.h"
#include "ns202.h"

#define CALLS 0

#if CALLS
int32 icu_inp(byte *reg)
{
	return (int32)(*reg);
}
#else
# define		icu_inp(r)  ((int32)(*(r)))
#endif

int32 icu_inpw(byte *reg)
{
	int32 result;

	result = icu_inp(reg+256) << 8;
	result |= icu_inp(reg);

	return result;
}

#if CALLS
void icu_outp(byte *reg, int32 bval)
{
	*reg = (byte)bval;
}
#else
# define		icu_outp(r,b)	*(r)=(byte)(b)
#endif

void icu_outpw(byte *reg, int32 wval)
{
	icu_outp(reg, wval & 255);
	icu_outp(reg+256, wval>>8);
}




void ns202_init2(void)
{
	int count = (hertz/512) * (675/high_byte) - 1;

/*  cfrz COUTD coutm clkm . frz 0 NTAR t16n8  */
	icu_outp(mctl, 0x42);

/*  ccon cfnps cout1 cout0 . crunh crunl cdcrh cdcrl  */
	icu_outp(cctl, 0x00);

/*  initialize counters  prescaling in use  */
	icu_outpw(lcsv, count);
	icu_outpw(hcsv, count);
	icu_outp(ciptr, 0x37);

	icu_outpw(lccv, count);
	icu_outpw(hccv, count);
/*  cerh cirh CIEH WENH cerl cirl ciel WENL  */
	icu_outp(cictl, 0x31);

/*  I/O port select:  0 = I/O, 1 = interrupt  */
	icu_outp(ips, 0x0F);

/*  port direction:  0 = output, 1 = input  */
	icu_outp(pdir, 0xFF);

/*  output clock assignment:  0 = not used, 1 = assigned */
	icu_outp(ocasn, 0x00);

/*  port data (pdat) -- not touched  */

/*  in service interrupts  */
	icu_outpw(isrv, 0x0000);

/*  cascade source  */
	icu_outpw(csrc, 0x0000);

/*  software vector assignment  */
	icu_outp(svct, 16);			/* vector 16, not 24 !!!  */

#ifdef M68000
/***  value for the Motorola 68000 and 68008 */
	icu_outp(mf_cfg, 16);		/* overrides the above */
#else
/***  value for the Z80 in IM 0  */
	icu_outp(mf_cfg, 0xFB);

/***  value for the Z80 in IM 2  */
		addr = 0xFFE0; e.g.			vector table aligned on 16-byte boundary
		Z80_ireg = addr >> 8;		high byte for I-register
		IM2_cfg = addr & 0xF0;		mask low bits correctly
	icu_outp(mf_cfg, IM2_cfg + 1);
#endif

/*  first priority  xxxx  on read;  xf  on write  */
	icu_outp(fprt, 0);

/*  triggering polarity (high, or rising) */
	icu_outpw(tpl, 0xFFFF);

/*  LEVEL/edge triggering  */
	icu_outpw(eltg, 0xFFFF);

/*  reset COUTD to start internal sampling oscillator  */
	icu_outp(mctl, 0x02);

/*  ccon cfnps cout1 cout0 . CRUNH crunl cdcrh cdcrl  */
	icu_outp(cctl, 0x08);

/*  clear mask bits  */
	icu_outpw(imsk, 0xFF00);

}

