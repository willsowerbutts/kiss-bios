/* setup.c  */
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
#include <stdlib.h>
#include <string.h>
#include "mytypes.h"
#include "packer.h"
#include "ns202.h"
#include "main68.h"
#include "myide.h"
#include "crc32.h"
#include "bioscall.h"
#include "ide.h"
#include "rtc.h"
#include "fdc8272.h"

#define	baud	9600
#define	divisor	((counter_clock/16)/baud)
#define	CHECK		(0xF1u)

const byte nvram0[31] = {
	divisor%256, divisor/256, 0x20, 0x00, 1, MF_PIC+4, 1, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0
};


union UN_NVRAM {
	byte	b[31];
	T_nv_struct sn;
} nvram;	 				/* communicate NVRAM contents to others */
byte nvram_valid;		/* flag nvram Valid */


int errno;				/* error number on integer conversion */
int32 timer_ticks;
int32 julian_day;

const
struct OPERATION floppy_ops = {
	floppy_reset,		/* reset */
	floppy_info,		/* info; read_id */
	floppy_read,
	floppy_write,
	floppy_verify,
	floppy_format
};

const
struct OPERATION ppide_ops = {
	ppide_reset,		/* reset */
	ppide_info,		/* info; read_id */
	ppide_read,
	ppide_write,
	NULL,
	NULL
};

const
struct OPERATION dide_ops = {
	dide_reset,		/* reset */
	dide_info,		/* info; read_id */
	dide_read,
	dide_write,
	dide_verify,
	NULL
};

struct OPERATION dualsd_ops = {
	dsd_reset,		/* reset */
	dsd_info,		/* info; read_id */
	dsd_read,
	dsd_write,
	dsd_verify,
	NULL
};

#if 0
const struct DISK dide_2 = {
	&dide_ops,			/* operations pointer */
	0x1ec0UL,			/* number of LBA sectors */
	D_DIDE,				/* disk type */
	0x80,					/* port 0x80 */
	MASTER,				/* MASTER/SLAVE */
	0,						/* last status */
	{0,0,0}				/* geometry info */
};

const struct DISK ppide_3 = {
	&ppide_ops,			/* operations pointer */
	128000UL,			/* number of LBA sectors */
	D_PPIDE,				/* disk type */
	0x44,					/* port 0x44 */
	MASTER,				/* MASTER/SLAVE */
	0,						/* last status */
	{0,0,0}				/* geometry info */
};

int setup_dide_disk(void)
{
	int i;

	for (i=0; i<MAX_DISK; i++) disk_table[i] = NULL;

	disk_table[2] = &dide_2;
	disk_table[3] = &ppide_3;

	return 0;
}
#endif


#define int_to_disk(x) ('A'+(x))
#define disk_to_int(c) (toupper(c)-'A')

static
int set_boot(char *first, int nnn)
{
	char line[6];
	int k;

#if !RETAIL
	if (debug>=2) cprintf("set_boot: nnn=%d\n", nnn);
#endif

	do {
		cprintf("Set %s boot device [%c]: ", first, int_to_disk(nnn));
		GETLINE(line);
		if (*line == 0) return nnn;
		k = *line;
		k = disk_to_int(k);
		if (k < 0 || k >= MAX_DISK || line[1]) k = -1;
	} while (k < 0);
	
#if !RETAIL
	if (debug>=2) cprintf("set_boot: k=%d\n", k);
#endif
	return k;
}

void set_boot_order(void)
{
	nvram.sn.boot_disk_1 = set_boot("first", (int)nvram.sn.boot_disk_1);
	nvram.sn.boot_disk_2 = set_boot("second", (int)nvram.sn.boot_disk_2);
}



static const int mods[5] = { 1, 4, 32, 32, 2 };

int set_disk_boards(void)
{
	unsigned int nbd, ty, port;
	char line[20];

	nbd = 0;
	cprintf("IDE board types are:\n"
			  "   %d  not present\n"
			  "   %d  Parallel Port\n"
			  "   %d  Dual IDE\n"
			  "   %d  DiskIO v2\n"
			  "   %d  Dual SD\n",
			  B_NONE, B_PPIDE, B_DIDE, B_DISKIO, B_DUALSD
			  );
	while (nbd < nelem(nvram.sn.board)) {
		errno = 0;
		do {
			ty = (int)nvram.sn.board[nbd].type;
			cprintf("Board #%d type [%d]: ", nbd+1, ty);
			GETLINE(line);
			if (*line != 0) ty = atoi(line);
		} while (errno || ty >= B_noBoard );
		nvram.sn.board[nbd].type = ty;
		port = 0;
		if (ty == B_NONE) {
			nvram.sn.board[nbd].port = port;
			break;
		}
		if (ty) do {
			port = (int)nvram.sn.board[nbd].port;
			cprintf("Base port address (hex) [%02x]: ", port);
			GETLINE(line);
			if (*line != 0) port = strtoul(line, NULL, 16);
		} while (errno || port%mods[ty] != 0);

		nvram.sn.board[nbd].port = port;
		nbd++;
	}
	
	return nvram.sn.nboards = nbd;
}

#define FL_OK (1<<D_NONE|1<<D_FLOPPY_1200|1<<D_FLOPPY_720|1<<D_FLOPPY_1440)
#define fl_ok(x) (FL_OK&(1<<(x)))
int set_dide_floppy(void)
{
	word nbd, nflp=0;
	word k, ty;
	char line[20];

	for (nbd=0; nbd < nelem(nvram.sn.board); nbd++) {
		if (nvram.sn.board[nbd].type == B_DIDE) {
			cprintf("Floppy disk types are:\n"
			  		"   %d  not present\n"
			  		"   %d  1.2M 5.25\"\n"
			  		"   %d  720K 3.5\"\n"
			  		"   %d  1.44M 3.5\"\n",
			  		D_NONE, D_FLOPPY_1200, D_FLOPPY_720, D_FLOPPY_1440
			  		);
			for (k=0; k<nelem(nvram.sn.floppy); k++) {
				ty = nvram.sn.floppy[k].type;
				do {
					errno = 0;
					cprintf("Floppy disk %c type [%d]: ", 'A'+k, ty);
					GETLINE(line);
					if (*line != 0) ty = atoi(line);
				} while (errno || !fl_ok(ty));
				nvram.sn.floppy[k].type = ty;
				nvram.sn.floppy[k].port = ty ? nvram.sn.board[nbd].port + 0x0A : 0 ;
				if (ty) nflp++;
			}
		} /* if */
	} /* for nbd */

	if (nflp == 0) {
		for (k=0; k<nelem(nvram.sn.floppy); k++) {
			nvram.sn.floppy[k].type = D_NONE;
			nvram.sn.floppy[k].port = 0 ;
		}
	}

	return nflp;
}


byte set_battery(void)
{
   byte state, diode, resistor;
   int en, rvalid, dvalid;
   char line[80], *cp;

   state = rtc_get_loc(BATTERY);
   en =  state>>4 == 0x0A;
   diode = (state>>2) & 3;
   resistor = state & 3;
   en &= (diode==1 || diode==2);
   en &= (resistor!=0);
   if (en) resistor = 1<<resistor;

   cprintf("Trickle charge backup is %sabled.\n", en ? "En" : "Dis");
   if (en) cprintf("   %d diode%s used.  A%s %dK resistor is selected.\n",
                   (int)diode, diode==1 ? " is" : "s are",
                   resistor == 8 ? "n" : "",
                   resistor);
   else state = 0;

   do {
       cprintf("Diode (0,1,2) & Resistor (2,4,8) [d[+r]]: ");
       GETLINE(line);
       if (*line == 0) return 0;   /* state == 0 */
       cp = strchr(line,'+');
       if (cp) *cp++ = 0;
       diode = atoi(line);
       if (cp) resistor = atoi(cp);
       rvalid = resistor==2 || resistor==4 || resistor==8;
       dvalid = diode==1 || diode==2;
       if (rvalid && dvalid) {
           en = 1;
           resistor>>=1;
           if (resistor==4) resistor--;
           state = (diode<<2) | resistor | 0xA0;
       }
       else if (resistor==0 || diode==0) {
           state = resistor = en = diode = 0;
       }
       else en = -1;
   } while (en < 0);
    
   rtc_set_loc(BATTERY, state);

   return state;
}

static const byte dpm0[12] = {31,30,31,30,31, 31,30,31,30,31, 31,28};
static const char * const dow[8] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "???"};
/*static const char * const month[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
*/

/* Day of the Week calculation:  dow is [0..6] for  [Su..Sa] */

int idow(int da, int mo, int yr)
{
    int leap = 0;
    int ce = yr/100;
    int y = yr%100;
    int i;
    byte dpm[12];

    for (i=0; i<12; i++) dpm[i]=dpm0[i];
/* return 99 on error */
    if (yr < 1583  ||  yr > 9999  ||  mo < 1  ||  mo > 12  ||  
           da < 1  ) return 99;
/* 1582 was the year of the change to the Gregorian calendar */

    leap = ( (y%4 == 0 && y != 0) || yr%400 == 0 );
    dpm[11] += leap;
    mo = mo - 3;
    if (mo < 0) {
        mo += 12;
        yr--;
    }
    if (da > dpm[mo]) return 98;
    ce = yr/100;
    yr = yr%100;
    for (leap=0; leap<mo; ++leap) da += dpm[leap];
    da += 5*ce + yr + yr/4 + ce/4 + 2;
    
    return (da % 7);
}


/*int Date(byte *ram)*/
int Date(void)
{
    byte da, mo, dw, yr, ce;
    int day, mon, year, tem;
    char line[80];
    char *cp, *tp;
    
	 if (!nvram_valid) {
	 		da = 1;
			mo = 1;
			dw = 3;
			yr = 01;
			ce = 0x19;
	 } else {
			da = rtc_get_loc(DAY);
			mo = rtc_get_loc(MONTH);
			dw = rtc_get_loc(DOW);
			yr = rtc_get_loc(YEAR);
			ce = rtc_get_loc(CENTURY);
	 }
    if (dw<1 || dw >7) dw = 8;
    cprintf("Date read:  %s %02x/%02x/%02x%02x\n", dow[dw-1],
                    (int)mo, (int)da, (int)ce, (int)yr );

    cprintf("Date [mm/dd/yyyy]: ");
    GETLINE(line);
    if (*line==0)  return 0;
    
    cp = strchr(line,'/');
    if (!cp) return 0;
    *cp++ = 0;
    mon = atoi(line);
    
    tp = strchr(cp,'/');
    if (!tp) return 0;
    *tp++ = 0;
    day = atoi(cp);
    year = atoi(tp);
    cprintf("Binary date:  %d/%d/%d\n", mon, day, year);
    mo = BCD(mon);
    da = BCD(day);
    tem = year/100;
    ce = BCD(tem);
    tem = year%100;
    yr = BCD(tem);
    dw = idow(day, mon, year);
    if (dw > 7) {
        cprintf("Invalid date entered.  (code %d)\n", (int)dw);
        return 0;
    }
    ++dw;    
    cprintf("BCD date to be set to DS1302:  %02x/%02x/%02x%02x  dow(%x)\n", 
                    (int)mo, (int)da, (int)ce, (int)yr, (int)dw );
    rtc_WP(0);
    rtc_set_loc(DAY, da);
    rtc_set_loc(MONTH, mo);
    rtc_set_loc(DOW, dw);
    rtc_set_loc(YEAR, yr);
    nvram.b[CENTURY&31] = ce;
        
    return (int)ce;
}



void Time(void)
{
    char line[80];
    char *cp, *tp;
    word hr, min, sec;
    
    sec = rtc_get_loc(SECOND);
    min = rtc_get_loc(MINUTE);
    hr  = rtc_get_loc(HOUR);
    
    if (sec & 0x80) cprintf("The clock is stopped.\n");
    else cprintf("Time read:  %02x:%02x:%02x\n", hr, min, sec);
    
        do {
            cprintf("Time [hh:mm[:ss]]: ");
            GETLINE(line);
            if (*line == 0) return;
            
            cp = strchr(line,':');
            if (!cp) continue;
            *cp++ = 0;
            hr = atoi(line);
            tp = strchr(cp,':');
            if (!tp) sec = 0;
            else *tp++ = 0;
            min = atoi(cp);
            if (tp) sec = atoi(tp);
        } while (hr>23 || min>59 || sec>59);
        cprintf("Read in %d:%02d:%02d\n", hr, min, sec);
        sec = BCD(sec);
        rtc_set_loc(SECOND, (byte)(sec | 0x80));  	/* stop the clock */
        rtc_set_loc(MINUTE, BCD(min));
        rtc_set_loc(HOUR, BCD(hr));
        rtc_set_loc(SECOND, (byte)sec);		/* start the clock */
        
    return;
}

#define JAN_1_1901 2415386
#define JAN_1_2001 2451911

void calendar_date (long jdate, int *day, int *month, int *year)
/* calculate the day, month, and year corresponding to a Julian day number */
/* the year will be negative if it is B.C. */
{
	long a, b, c, d, e, z, alpha;
	z = jdate;
	/* cope with the Gregorian calendar reform */
	if (z < 2299161L) a = z;
	else {
#define c1 186721625L
#define c2 3652425L
		alpha = (z*100 - 186721625L) / 3652425L;
		a = z + 1 + alpha - alpha/4;
		}
	b = a+1524;
	c = ((b*100 - 12210L) / 36525L);
	d = (36525*c)/100;
	e = ((b-d)*10000)/306001;
	*day = (int) b - d - (306001 * e)/10000;
	*month = (int) (e <= 13) ? e - 1 : e - 13;
	*year = (int) (*month > 2) ? (c - 4716) : c - 4715;
}


void long_time (long time, int *hour, int *min, int *sec)
{
	long temp = time;

	*hour = (int) (temp / 3600);
	temp = temp - *hour * 3600;
	*min = (int) (temp / 60);
	*sec = (int) (temp - *min * 60);
}

qword daytime_c(byte option)
{
	uint32 seconds = timer_ticks * (675/high_byte) >> 9;
	uint32 jyear = julian_day;
	int day, month, year, century;
	int hour, min, sec;
	int dow;

	if (option==1 || option>3) {
		jyear -= JAN_1_2001;
	}
	else if (option>=2) {
		calendar_date(julian_day, &day, &month, &year);
		long_time(seconds, &hour, &min, &sec);
		if (option==2) {
			dow = (julian_day+1) % 7;
			jyear = (((((year << 4) + month) << 8) + day) << 4) + dow;
			seconds = (((hour << 8) + min) << 8) + sec;
		}
		else {
			century = year / 100;
			year = year - century * 100;
			jyear = BCD(century);
			jyear <<= 8;
			jyear |= BCD(year);
			jyear <<= 8;
			jyear |= BCD(month);
			jyear <<= 8;
			jyear |= BCD(day);
			seconds = BCD(hour);
			seconds <<= 8;
			seconds |= BCD(min);
			seconds <<= 8;
			seconds |= BCD(sec);
		}
	}

	return ((qword)jyear << 32) | seconds;
}


int set_serial (void)
{
	byte line[16];
	int i, rate, bitrate;
/*	const char *rates[8] = {"1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"}; */
	const int rates[] = { 300, 600, 1200, 1800, 2400, 3600, 4800, 7200,
						9600, 14400, 19200, 28800, 38400, 57600, 115200};
	int div = nvram.b[SIO_DIV_L & 31] + 256*nvram.b[SIO_DIV_H & 31];

	bitrate = (counter_clock/16)/div;
	while (1) {
		cprintf ("Serial port baud rate (Kbit/sec) [%d]: ", bitrate);
		GETLINE(line);
		if (line[0] == '\0') break;

		rate = atoi(line);
		for (i = 0; i < nelem(rates); i++) {
			if (rate == rates[i]) break;
		}
		if (i != nelem(rates)) {
			bitrate = rate;
			break;
		} else {
			cprintf ("Invalid selection; allowable bit rates are:");
			for (i = 0; i < nelem(rates); i++) {
				cprintf (" %d", rates[i]);
				if (i==6) cprintf("\n");
			}
			cprintf ("\n");
		}
	}
	div = (counter_clock/16) / bitrate;
	nvram.b[SIO_DIV_L & 31] = div % 256;
	nvram.b[SIO_DIV_H & 31] = div / 256;
#if !RETAIL
	if (debug>=2)
		cprintf("  divisor set to %d for %d baud\n", div, bitrate);
#endif
	return bitrate;
}


void get_nvram(void)
{
	byte cksum;
	uint16 i;
	byte temp;

#if !RETAIL
	if (debug>=1)
		cprintf("get_nvram entered\n");
#endif
	cksum = 0;
	for (i=SIO_DIV_L; i<=CHECKSUM; i++) {
		temp = rtc_get_loc(i);
		cksum += temp;
		nvram.b[i&31] = temp;
	}
#if !RETAIL
	if (debug>=2)
		prbuf(SIO_DIV_L, nvram.b, nelem(nvram.b));
#endif
	if (cksum != CHECK || (rtc_get_loc(SECOND) & 0x80)) {
		nvram_valid = 0;
		/* NVRAM is bad */
		memmove(nvram.b, nvram0, sizeof(nvram.b));
	}
	else nvram_valid = 1;

#if !RETAIL
	if (debug<0) {
		nvram.b[SIO_DIV_L&31] = 12;
		nvram.b[SIO_DIV_H&31] = 0;
	}
	if (debug>=1)
		cprintf("get_nvram done\n");
#endif
#if 0
	setup_dide_disk();
#endif
}


void setup(int ch)
{
	uint16 i;
	byte cksum, temp;

	if (ch==0) {
		memmove(nvram.b, nvram0, sizeof(nvram.b));
		nvram_valid = 0;
		rtc_WP(0);		/* write protection off */
		goto RESET;
	}

	if (!(ch=='s' || ch=='S') && nvram_valid) return;
	debug = 0;
	
	cprintf("\nStart of Setup.\n");
#if !RETAIL
	if (debug>=1)
		cprintf("Size of NVRAM structure = %d\n", sizeof(struct NVRAM));

	if (debug>=4)
		rtc_debug();
#endif

	cprintf("The contents of NVRAM are %svalid.\n", nvram_valid ? "" : "In");

	temp = rtc_get_loc(SECOND);
	cprintf("The clock is %s.\n\n", temp&0x80 ? "stopped" : "running");


/* setup the serial line speed -- in memory copy of NVRAM only */
	set_serial();

	rtc_WP(0);		/* write protection off */
/* setup the battery backup */
	set_battery();
	Date();
	Time();

	set_disk_boards();

	set_dide_floppy();

	set_boot_order();

RESET:
	cksum = 0;
	for (i=SIO_DIV_L; i<CHECKSUM; i++) {
		temp = nvram.b[i&31];
		cksum += temp;
		rtc_set_loc(i, temp);
	}
	temp = CHECK - cksum;
	nvram.b[CHECKSUM&31] = temp;
	rtc_set_loc(CHECKSUM, temp);
	rtc_WP(1);

	nvram_valid = 2;		/* indicate that NVRAM memory copy is valid */

#if !RETAIL
	if (debug>=2)
		prbuf(SIO_DIV_L, nvram.b, nelem(nvram.b));
#endif

	cprintf("Non-volatile Setup RAM has been updated.\n");
}

void *probe_IDE_disk(T_disk *proto, char *name)
{
	struct REGS reg;
	struct _IDENTIFY_DEVICE_DATA buffer;
	int i, d = MAX_DISK-1;
	T_disk *new;

	disk_table[d] = proto;

		reg.D0 = 10;	/* RESET */
		reg.D1 = d;
		bios_call(&reg, &reg);
#if !RETAIL
		if (debug>=3) {
			cprintf("pre-Reset disk #%d (port=0x%02x):  %08x %08x\n",
				d, (int)(proto->port), reg.D0, reg.D1);
		}
#endif

	if (reg.D0 != 0 ||
			(  (proto->slave == MASTER) && !(reg.D1 & 1)  ) ||
			(  (proto->slave == SLAVE) && !(reg.D1 & 2)  )
		) {
		disk_table[d] = NULL;
		return NULL;
	}

	reg.D0 = 11;		/* get info */
	reg.D1 = d;			/* disk 'd' */
	reg.A0 = (void*)&buffer;
#if !RETAIL
	if (debug>=3) cprintf("Making get info call\n");
#endif
	bios_call(&reg, &reg);
	name[0] = 0;
#if !RETAIL
		if (debug>=3) {
			cprintf("Get disk ID #%d (port=0x%02x):  %08x %08x\n",
				d, (int)(proto->port), reg.D0, reg.D1);
		}
#endif
	if (reg.C) {
#if !RETAIL
		if (debug>=3) {
			cprintf("Error: Get disk ID #%d (port=0x%02x):  %08x %08x\n",
				d, (int)(proto->port), reg.D0, reg.D1);
		}
#endif
#if 0
		reg.D0 = 10;	/* RESET */
		reg.D1 = d;
		bios_call(&reg, &reg);
		if (debug>=3) {
			cprintf("postReset disk #%d:  %08x %08x\n",
				d, reg.D0, reg.D1);
		}
#endif
		disk_table[d] = NULL;
		return NULL;
	}
	disk_table[d] = NULL;

	if (buffer.Capabilities.LbaSupported)
		proto->lba_cyls = bswap(buffer.UserAddressableSectors);
	else proto->lba_cyls = 0;
	proto->geom.cylinders = wswap(buffer.NumCylinders);
	proto->geom.heads = wswap(buffer.NumHeads);
	proto->geom.sectors = wswap(buffer.NumSectorsPerTrack);

	new = memmove(malloc(sizeof(*new)), proto, sizeof(*new));

	for (d=0; d<sizeof(buffer.ModelNumber); d+=2) {
		byte tem = buffer.ModelNumber[d+1];
		buffer.ModelNumber[d+1] = buffer.ModelNumber[d];
		buffer.ModelNumber[d] = tem;
	}
	d = sizeof(buffer.ModelNumber) - 1;
	for (i=0x20; i && d; d--) {
		if (buffer.ModelNumber[d] == i) {
			buffer.ModelNumber[d] = 0;
		} else {
			i = 0;
		}
	}
	strncpy(name, buffer.ModelNumber, 40);
	name[40] = 0;

	return new;
}


void configure_floppy(int k)
{
	T_floppy *floppy;
	word n;

#define flp nvram.sn.floppy[k]
#define g floppy->disk.geom
	if (flp.type == D_NONE) return;

	floppy = malloc(sizeof(T_floppy));
	floppy->docb = operation_docb_ptr[k];
	floppy->param = fdc_parameters[flp.type];

	g.cylinders = n = floppy->param->cylm1 + 1;	/* number of cylinders */
	n *= (g.heads = 2);									/* number of heads */
	n *= (g.sectors = floppy->param->eot);			/* number of sectors */

	floppy->disk.op = &floppy_ops;
	floppy->disk.disk_type = flp.type;
	floppy->disk.port = flp.port;
	floppy->disk.slave = k;
	floppy->disk.lba_cyls = n;

	disk_table[k] = (T_disk*)floppy;
#undef flp
}


void configure(void)
{
	struct DISK disk_proto, *dp;
	struct TIME time;
	struct DATE date;
	char line[42];
	int i, n, k, m;
	int ty;

	debug = 0;
	/* assume that the memory copy of the nvram is valid */
	if (!nvram_valid) get_nvram();

	for (i=0; i<MAX_DISK; i++) disk_table[i] = NULL;

	for (i=0; i<nelem(nvram.sn.floppy); i++) configure_floppy(i);

	i = 2;
	for (n=0; n<nvram.sn.nboards && i<MAX_DISK; n++) {
		memset(&disk_proto, 0, sizeof(disk_proto));

		disk_proto.port = nvram.sn.board[n].port;

		ty=(int)nvram.sn.board[n].type;
		switch (ty) {
			case B_PPIDE:
			case B_DISKIO:
				disk_proto.op = &ppide_ops;
				disk_proto.disk_type = D_PPIDE;
				k = 2;
				break;
			case B_DIDE:
				disk_proto.op = &dide_ops;
				disk_proto.disk_type = D_DIDE;
				k = 4;
				break;
			case B_DUALSD:
				disk_proto.op = &dualsd_ops;
				disk_proto.disk_type = D_DUALSD;
				k = 2;
				break;
			default:
				k = 0;
		}
		m = MASTER;
		while (k--) {
			disk_proto.slave = m;

			if (ty == B_DUALSD) dp = NULL;	// JRC:  for now
			else	dp = probe_IDE_disk(&disk_proto, line);

			if (dp) {
				disk_table[i++] = dp;
				cprintf(" %c:  %s\n", (char)('A'-1 + i), line);
#if !RETAIL
				if (debug>=1)
					cprintf("   LBA sectors:  0x%x = %d\n",
						disk_proto.lba_cyls, disk_proto.lba_cyls);
#endif
			}

			
			if (ty == B_DUALSD) m++;
			else  m ^= SLAVE;

			if (k == 2) disk_proto.port += 0x10;
		}
	}

	timer_ticks = get_rtc_time(&time);
	julian_day = get_rtc_date(&date);

	cprintf("Boot at %2u:%02u:%02u on %2u%02u/%u/%u   %8luJ %8luT\n",
		(int)time.hour, (int)time.minute, (int)time.second,
		(int)date.century, (int)date.year, (int)date.month, (int)date.day,
		(long)date.julian, (long)time.ticks);
}

