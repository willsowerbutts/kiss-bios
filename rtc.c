/* rtc.c */
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
#include "stdlib.h"
#include "string.h"
#include "mytypes.h"
#include "mfpic.h"
#include "ns202.h"
#include "main68.h"
#include "rtc.h"


#define NOFLOAT 1
#define deblank while(*lp==' ') ++lp

#if 0
#define rtc_WP(on) rtc_set_loc(PROTECT,(on)?0x80:0)

void rtc_set_loc(byte address, byte value);
byte rtc_get_loc(byte address);

#define NVOFFSET 0x20
enum {SECOND = 0, MINUTE, HOUR, DAY, MONTH, DOW, YEAR, PROTECT, BATTERY,
		SIO_DIV_L = NVOFFSET, SIO_DIV_H, CENTURY,
		CHECKSUM = NVOFFSET+30, NV_BURST };
#endif

dword hex(char **lp)
{
	return strtoul(*lp, lp, 16);
}

void rtc_debug(void)
{
	char line[40], *lp;
	int i, ch;
	byte port, data;

	cprintf("RTC debug    ('Q' to quit)\n");
	ch = 0;	/* quiet GCC */
	while (1) {
		GETLINE(line);
		for (i=0; i<nelem(line); i++) line[i] = toupper(line[i]);
		lp = line;
		deblank;
		ch = *lp++;
		switch (ch) {
		case 'I':
		case 'G':
			port = hex(&lp);
			if (ch == 'I')
				data = *(babyM68k_IO + port);
			else
				data = rtc_get_loc(port);
			cprintf("%02x\n", (int)data);
			break;
		case 'O':
		case 'S':
			port = hex(&lp);
			deblank;
			data = hex(&lp);
			if (ch == 'O')
				*(babyM68k_IO + port) = data;
			else
				rtc_set_loc(port, data);

			cprintf("(%02x) <- %02x\n", (int)port, (int)data);
			break;
		case 'Q':
			return;
		default:
			cprintf("?\n  I)nput pp, G)et pp, O)utput pp nn, S)et pp nn, Q)uit\n");
		}
	}
}


dword julian_date (word day, word month, int16 year)
/* Calculate the Julian day number for the specified day, month, year. */
/* if the year is B.C. it must be negative */
{
	int16 a, b;
   int16 year_corr;

	/* correct for negative year */
	year_corr = (year > 0 ? 0 : 75);

	if (month <= 2) {
		year--;
		month += 12;
		}
	b = 1;
	/* cope with the Gregorian calendar reform */
	if ((year*100L + month)*100L + day >= 15821015L) {
		a = year / 100;
		b = 3 - a + a/4;
		}
	return (36525UL*year - year_corr)/100 +
		(306001UL*(month+1))/10000UL + day + 1720994UL + b;
}





dword get_rtc_time (T_time *tod)
{
	byte temp, sec;
	dword seconds;

	temp = rtc_get_loc(SECOND);
	do {
		sec = temp;
		tod->unused = 0;
		temp = rtc_get_loc(HOUR);
		seconds = tod->hour	= BIN(temp);
		seconds *= 60;
		temp = rtc_get_loc(MINUTE);
		seconds += tod->minute	= BIN(temp);
		seconds *= 60;
		temp = rtc_get_loc(SECOND);
	} while (sec != temp);
	seconds += tod->second	= BIN(temp);

/* the day-long maximum timer tick count is (high_byte << 16) */
/* high_byte is defined in "ns202.h" */
/*	ticks = ((seconds / 86400) * high_byte) << 16; */

	return (tod->ticks = ((seconds * high_byte) << 9) / 675);
}


dword get_rtc_date(T_date *today)
{
	int16 Year;
	byte temp;

	temp = rtc_get_loc(CENTURY);
	today->century	= Year = BIN(temp);
	Year *= 100;
	temp = rtc_get_loc(YEAR);
	Year += today->year	 = BIN(temp);
	temp = rtc_get_loc(MONTH);
	today->month	= BIN(temp);
	temp = rtc_get_loc(DAY);
	today->day		= BIN(temp);

	today->julian	= julian_date(today->day, today->month, Year);

	return today->julian;
}

