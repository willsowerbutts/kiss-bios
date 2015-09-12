/* rtc.h */
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


typedef
struct TIME {
	byte 	unused, hour, minute, second;
	dword ticks;
} T_time;

typedef
struct DATE {
	byte century, year, month, day;
	dword julian;
} T_date;


#define NVOFFSET 0x20
enum {SECOND = 0, MINUTE, HOUR, DAY, MONTH, DOW, YEAR, PROTECT, BATTERY,
		SIO_DIV_L = NVOFFSET, SIO_DIV_H, CENTURY,
		CHECKSUM = NVOFFSET+30, NV_BURST };


#define BCD(x) (byte)((x)<100?(((x)/10)<<4)|((x)%10):0xFF)
#define BIN(x) (byte)((((x)&0xF0)>>4)*10+((x)&0xF))
#define rtc_WP(on) rtc_set_loc(PROTECT,(on)?0x80:0)

void rtc_set_loc(byte address, byte value);
byte rtc_get_loc(byte address);
void rtc_debug(void);

dword get_rtc_time (T_time *tod);
dword get_rtc_date(T_date *today);

/* time.h */
