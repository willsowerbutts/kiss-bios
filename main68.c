/* main68.c  --  main program started by booting the 68000 system  */
/*
	Copyright (C) 2011-2015 John R. Coffman.
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
#include <string.h>
#include "mytypes.h"
#include "packer.h"
#include "mfpic.h"
#include "dosdisk.h"
#include "ide.h"
#include "coff.h"
#include "main68.h"
#include "bioscall.h"
#if !RETAIL
#include "debug.h"
#endif
#include "version.h"
#include "cout.h"

int sio_get(void);
int _con_out(char);
void _run_us_mode(word mode, void *pc);
#if 0
int _IDE_WRITE_SECTOR(byte *buffer, long lba_sector, byte slave);
#endif

extern byte location_zero;
const char msg_welcome[] =
		"\r\n\r\n"
#if M68000==68030
		"        Welcome to the KISS-68030 System" "\r\n\r\n"
#else
		"        Welcome to the MINI-M68000 System" "\r\n\r\n"
#endif
		"BIOS version " VERSION_STRING " of " VERSION_DATE	"\r\n"
		"Copyright (C) 2011-2015 John R. Coffman  <johninsd@gmail.com>" "\r\n"
#if 1
	 "\r\n"
    "This program is free software: you can redistribute it and/or modify\r\n"
    "it under the terms of the GNU General Public License as published by\r\n"
    "the Free Software Foundation, either version 3 of the License, or\r\n"
    "(at your option) any later version.\r\n"
	 "\r\n"
    "This program is distributed in the hope that it will be useful,\r\n"
    "but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n"
    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n"
    "GNU General Public License for more details.\r\n"
	 "\r\n"
    "You should have received a copy of the GNU General Public License\r\n"
    "in the file COPYING in the distribution directory along with this\r\n"
    "program.  If not, see <http://www.gnu.org/licenses/>.\r\n"
	 "\r\n"
#if M68000==68030
	 "Distributed for hobbyist use on the N8VEM KISS-68030 CPU board."
#else
	 "Distributed for hobbyist use on the N8VEM Mini-M68k CPU board."
#endif

#else
		"Licensed for hobbyist use on the N8VEM Mini-M68k CPU board."
#endif
		"\r\n\r\n"
;

char *cp;
byte buffer[512];
dword sec_in_buf;
int diskno;
T_nv_struct nvram;

byte slave;

/* #define P_TUTOR  (void*)0x384004 */
#define WAIT do ch = sio_get(); while (ch<0)
#define MAGIC_COFF 0x0150
#define LOADPOINT 0x1000


extern int32 timer_ticks;
void prbuf(dword addr, byte *buf, int n);

char * const sname[3] = {
			".text", ".data", ".bss"
			};
char * const exemode[2] = {
			"user", "supv"
			};

struct {
	dword	base;
	dword count;
	dword fat_base[2];
	dword dir_base;
	dword data_base;
	dword dir_sectors;
	word	fat_size;
	word	clusters;
	word	fateof;			/* 0xfff for fat12, 0xffff for fat16 */
	byte	nfats;
	byte	sec_p_clus;		/* sectors per cluster */
	byte	fatshift;		/* 1 for fat12, 0 for fat16 */
} dos_part;


int _IDE_READ_ID(byte *b, byte slave)
{
	struct REGS reg;

#define FOR 0
#if FOR
	word i;
	for (i=0; i<4; i++) {
#endif
		reg.D0 = 11;		/* info call */
		reg.A0 = b;			/* buffer address */
		reg.D1 = diskno;			/* disk # 2 */

		bios_call( &reg, &reg );
#if FOR
		if (reg.V) {
			reg.D0 = 10;	/* reset */
			reg.D1 = diskno;
			bios_call(&reg, &reg);
		}
	}
#endif
#undef FOR

	return reg.D0;
}
int _IDE_READ_SECTOR(byte *buffer, long lba_sector, byte slave)
{
	struct REGS reg;

	reg.D0 = 12;		/* read call */
	reg.A0 = buffer;
	reg.D1 = diskno;			/* disk # 2 */
	reg.D2 = lba_sector;
	reg.D3 = 1;

	bios_call( &reg, &reg );

	if (reg.V) exit(reg.D0);

	return reg.D0;
}
#if !RETAIL
int _IDE_WRITE_SECTOR(byte *buffer, long lba_sector, byte slave)
{
	struct REGS reg;

	reg.D0 = 13;		/* write call */
	reg.A0 = buffer;
	reg.D1 = diskno;			/* disk # 2 */
	reg.D2 = lba_sector;
	reg.D3 = 1;

	bios_call( &reg, &reg );

	if (reg.V) exit(reg.D0);

	return reg.D0;
}

void exerciser(int iter, long sector)
{
	int16 i;
	int plus = 17;
	byte k;

	while (iter--) {
		k = iter+1;
		for (i=0; i<nelem(buffer); i++) {
			buffer[i] = k;
			k += plus;
		}
		_IDE_WRITE_SECTOR(buffer, sector, slave);

		for (i=0; i<nelem(buffer); i++) buffer[i] = 0xFF;
		_IDE_READ_SECTOR(buffer, sector, slave);

		k = iter+1;
		for (i=0; i<nelem(buffer); i++) {
			if (buffer[i] != k) {
				cprintf("buf[%hd]	%02x %02x\n", i, (int)k, (int)buffer[i]);
			}
			k += plus;
		}
		cprintf("End iteration %d\n", iter+1);
	}
	cprintf("End R/W exerciser\n\n");
}
#endif

char *dosname(char *dos, char *str)
{
	int i;
	char ch;

	for (i=0; i<8; i++) {
		ch = toupper(*str);
		if ((ch>='A'&&ch<='Z')||(ch>='0'&&ch<='9')||ch=='_'||ch=='-') {
			dos[i] = ch;
			str++;
		}
		else {
			dos[i] = ' ';
		}
	}

	while ( (ch=*str) && (ch != '.') ) str++;
	if (ch=='.') str++;

	for (i=8; i<11; i++) {
		ch = toupper(*str);
		if ((ch>='A'&&ch<='Z')||(ch>='0'&&ch<='9')||ch=='_'||ch=='-') {
			dos[i] = ch;
			str++;
		}
		else {
			dos[i] = ' ';
		}
	}
	dos[11] = 0;
	return dos;
}

byte fat_byte(word nbyte)
{
	dword sector;

	sector = nbyte / 512UL + dos_part.fat_base[0] + dos_part.base;
	if (sec_in_buf != sector) {
		_IDE_READ_SECTOR(buffer, sector, slave);
		sec_in_buf = sector;

		sector -= dos_part.base;
#if !RETAIL
		if (debug>=2)
		cprintf("FAT sector %u  0x%x\n", sector, sector);
		if (debug>=3)
		prbuf(0, buffer, 512);
#endif
	}
	return buffer[nbyte % 512];
}

word next_cluster(word current)
{
	word nibble, nbyte, cluster;

	nibble = dos_part.fatshift ?
		/* FAT12 */	current * 3 :  /* FAT16 */ current * 4 ;
	nbyte = nibble >> 1;
	cluster = fat_byte(nbyte);
	cluster |= fat_byte(nbyte+1) << 8;
	if (current & dos_part.fatshift) cluster >>= 4;
	cluster &= dos_part.fateof;

	return cluster;
}


dword loadfile(byte *where, T_dirent *file)
{
	dword size, remain, lth;
	word cluster;
	word sc;
	dword sector;
	byte *core = where;

	sec_in_buf = 0;
	size = bswap(file->fsize);
	cluster = wswap(file->clust);
	remain = size;

	while (remain) {
#if !RETAIL
		if (debug>=2)
			cprintf("   %lu bytes at cluster %hu\n", remain, cluster);
#endif
		sector = (cluster-2) * dos_part.sec_p_clus + dos_part.data_base;
		for (sc = 0; sc < dos_part.sec_p_clus && remain; sc++) {
			_IDE_READ_SECTOR(core, dos_part.base + sector, slave);
			sector++;
			lth = remain > 512 ? 512 : remain;
			core += lth;
			remain -= lth;
		}
		cluster = next_cluster(cluster);
	}

	return size;
}


/* check the type of a loaded file, Flat Binary or COFF a.out 
	return the starting address  */
void* checkexe(byte *ptr, dword length)
{
	T_aout_head *hdr = (void*)ptr;
	dword entry_point, load_here, len;
	dword start;
	int i;
	byte aout;

	aout = (hdr->magic == MAGIC_COFF) && (hdr->n_sects == nelem(sname));
	for (i=0; aout && i<nelem(sname); i++) {
		aout &= !strcmp(hdr->section[i].section_name, sname[i]);
	}
	if (!aout) {
		cprintf("Flat Binary\n");
	} else {
		cprintf("a.out COFF format\n");
		entry_point = hdr->entry_point;

			/* extract .TEXT section data */
		load_here = hdr->section[0].load_at;
		len = hdr->section[0].length;
		start = hdr->section[0].file_pos + (dword)hdr;
			/* check that .DATA section follows immediately */
		aout &= (hdr->section[1].load_at == load_here + len);
		len += hdr->section[1].length;
			/* check that .BSS section follows immediately */
		aout &= (hdr->section[2].load_at == load_here + len);

			/* check that .TEXT is loaded above the LOADPOINT,
				and that the entry is above the LOADPOINT */
		if (load_here < LOADPOINT) {
			cprintf("File loads below 0x%u\n", LOADPOINT);
			aout = 0;
		}
		if (entry_point < LOADPOINT) {
			cprintf("Entry point is below 0x%u\n", LOADPOINT);
			aout = 0;
		}
		if (!aout) {
			cprintf("  Illegal  A.OUT  m68k-coff binary\n");
			return (void*)0001UL;	/* odd start address */
		}
		memmove((void*)load_here, (void*)start, (size_t)len);
		ptr = (void*)entry_point;
	}
	return ptr;
}


int wr_dir_ent(struct DIRENT *dirent)
{
	int i;
	word a,b,c;
	char *cp = "rhsvdauw";

	if (dirent->filename[0] == 0) return 1;
	if (dirent->filename[0] < ' ' || dirent->filename[0] >= 0177) return 0;
	if (dirent->attrib & (ATTR_D | ATTR_H | ATTR_S | ATTR_V)) return 0;

	for (i=0; i<8; i++) cprintf("%c", dirent->filename[i]);
	cprintf(" ");
	for (i=0; i<3; i++) cprintf("%c", dirent->extension[i]);
	i = wswap(dirent->d_upd);
	a = i & 0x1F;	i >>= 5;
	b = i & 0x0F;	i >>= 4;
	c = i + 1980;
	cprintf("   %4d-%02u-%02u", c, b, a);
	i = wswap(dirent->t_upd);
	a = i & 0x1F;  i >>= 5;	 a *= 2;
	b = i & 0x3F;	i >>= 6;
	c = i;
#if 0
	cprintf("  %2d:%02d:%02d", c, b, a);
#else
	cprintf("  %2d:%02d", c, b);
#endif
	i = bswap(dirent->fsize);
	cprintf("%8u   ", i);
	for (i=1; i<=0x80; i<<=1, cp++)
		if (dirent->attrib & i) cprintf("%c", *cp);
	cprintf("\n");

	return 0;
}

void wr_dir(void)
{
	int i;
	byte done;
	dword dsect = dos_part.dir_base;

	done = 0;
	while (!done && dsect < dos_part.data_base) {
		i = 0;
		_IDE_READ_SECTOR(buffer, dsect+dos_part.base, slave);
		while (i < sizeof(buffer) && !done) {
			done = wr_dir_ent((void*)(buffer+i));
			i += sizeof(struct DIRENT);
		}
		dsect++;
	}
}


int fmatch(char *pattern, char *name)
{
	int len = strlen(pattern);
	int i;

	if (*name == 0) return 1;
	for (i=0; i<len; i++) {
		if (*pattern == '?' || *pattern == *name) pattern++, name++;
		else return 0;
	}
	return 2;	/* match found */
}


/* find a particular filename in the root directory */
T_dirent* find_in_dir(char *name)
{
	int i;
	byte done;
	dword dsect = dos_part.dir_base;

	done = 0;  	/* 0=searching, 1=not found, 2=found it */
	while (!done && dsect < dos_part.data_base) {
		i = 0;
		_IDE_READ_SECTOR(buffer, dsect+dos_part.base, slave);
		while (i < sizeof(buffer) && !done) {
			done = fmatch(name, (void*)(buffer+i));
			if (done>=2) return (void*)(buffer+i);
			i += sizeof(struct DIRENT);
		}
		dsect++;
	}
	return NULL;
}

#if !RETAIL
void prline(byte *buff)
{	/* print a line of 16 byte values */
	word i, j;
	byte *buf = buff;
	for (j=2; j--; ) {
		for (i=8; i--; ) {
			cprintf(" %02x", (int)(*buf++));
		}
		cprintf(" ");
	}
	cprintf(" ");
	buf = buff;
	for (i=16; i--; buf++) cprintf("%c", *buf>=' ' && *buf<0177 ? *buf : '.');
}

void prbuf(dword addr, byte *buf, int n)
{
	word i;
	int ch;
	while (n>0) {
		for (i=0; i<8 && n>0; i++) {
			cprintf("\n%04x: ", addr);
			prline(buf);
			buf+=16;
			addr+=16;
			n-=16;
		}
		cprintf("\n");
		if (n>0) {
			do ch = sio_get();
			while (ch<0);
		}
	}
}

void show_bpb(struct BPB *bp)
{
	cprintf("%6hd : bytes per sector\n", bp->bps);
	cprintf("%6hu : sectors per cluster\n", (short)(bp->spc));
	cprintf("%6hu : reserved sectors\n", bp->rsvd);
	cprintf("%6hd : number of FATs\n", bp->nfat);
	cprintf("%6hd : number of root directory entries\n", bp->nrde);
	cprintf("%6lu : total number of sectors\n",
		bp->tsec ? (long)(bp->tsec) : bp->tsec2);
	cprintf("%6hx : media descriptor\n", bp->md);
	cprintf("%6hu : sectors per FAT\n", bp->spf);
	cprintf("%6hd : sectors per track\n", bp->spt);
	cprintf("%6hd : number of heads\n", bp->nhd);
	cprintf("%6lu : number of hidden sectors\n", bp->hid);
	cprintf("%6hx : BPB version info\n", bp->vers);
	cprintf("   Volume ID : %08lx \n", bp->id);
}
#endif

int uc_string(char *str, int length)
{
	int i = length;
	while( i-- ) {
		*str = toupper(*str);
		++str;
	}
	return length;
}

void rubout(void)
{
	_con_out('\b');
	_con_out(' ');
	_con_out('\b');
}

int getline(char *line, int linesize)
{
	int k = 0;
	signed char ch;

	do {
		do ch = sio_get();
		while (ch < 0);

		if (ch >= ' ' && ch < 0177) {
			line[k++] = ch;
			_con_out(ch);
		}
		else if (ch == '\r' || ch == '\n') {
			ch = 0;
			_con_out('\r');
			_con_out('\n');
		}
		else if ( (ch == '\b' || ch == 0177) && k>0) {
			rubout();
			--k;
		}
		else if (ch == ('X' & 037) /* Ctrl-X */) {
			while (k) { rubout(); --k; }
		}
		else _con_out('G' & 037);	/* BEL */

	} while (ch && k < linesize-1);
	line[k] = 0;
#if !RETAIL
	if (debug>=5) cprintf("\ngetline: k=%d\n", k);
#endif
	return k;
}

long run_rom_cpm(void)
{
	long i;

	byte *addr = &location_zero  +  BIOSSIZE * 1024L;
	if ((i=!strncmp("CPM     SYS", (char*)addr+1, 11)) &&
					*(word*)(addr+2048) == MAGIC) {
		i = ((struct hdr*)(addr+2048))->ch_entry;
		memmove( (byte*)i, (byte*)(addr+2048+sizeof(struct hdr)), 64*1024);
		_run_us_mode(1, (void*)i);
	}
	cprintf("No CPM.SYS in ROM found. (%ld)\n", i);
	return (long)addr;
}



void help(void)
{
	cprintf("Commands are single letters; U or S sets boot mode.\n");
	cprintf("C)P/M-68, D)irectory, U)ser, S)upervisor, H)elp, <filename.ext>\n\n");
}

int main68(void)
{
#if !RETAIL
	int ch;
#endif
	int i, j, iter;
	dword sect;
	dword dtemp;
	char name[16];
	word mode;
	struct _IDENTIFY_DEVICE_DATA *idp;
	struct BPB *bpbp, bpb;
	struct BOOTSECTOR *bootp;
	struct PARTENT *pt;
	struct DIRENT *dir;
	struct BOOT_BLK *bblkp;

	debug = 0;
	slave = MASTER;
	iter = 23;
	sect = 4;
	diskno = nvram.boot_disk_1;

	for (i=0; i<512; i++) buffer[i] = i;

#if !RETAIL
	if (debug>=1) cprintf("Read CF ID\n");
#endif
	if ((i=_IDE_READ_ID(buffer, slave))) {
		cprintf("Read ID error on device %c:\n", diskno+'A');
#if RETAIL
		if (nvram.boot_disk_2 == diskno)  run_rom_cpm();
#endif
		exit(i);
	}
#if !RETAIL
	if (debug>=1) cprintf("Read done\n");

	if (debug>=2) prbuf(0, buffer, 257);
	if (debug>=3) cprintf("Done.\n\n");
#endif

	idp = (void*)buffer;
#if !RETAIL
	if (debug>=1)
	cprintf("Disk has %lu sectors.      (%08lxh)\n", 
		bswap(idp->UserAddressableSectors),
		bswap(idp->UserAddressableSectors));
#endif

	idp = unpack(FMT_IDD FMT_ID2, buffer, idp);
#if !RETAIL
	if (debug>=1)
	cprintf("Disk has %lu sectors.      (%08lxh)\n", 
		idp->UserAddressableSectors,
		idp->UserAddressableSectors);

	if (debug>=2)
	prbuf(0, buffer, 257);
	if (debug>=3)
	cprintf("Done.\n\n");
#endif

#if 0
	{
		byte buff2[512];
		prbuf(0, buffer, 512);
		cprintf("Done.\n\n");

		for (i=1; i<1000; i++) {
			word j;
			for (j=0; j<512; j++) buff2[j] = 0xA5;
			_IDE_READ_ID(buff2, slave);
			for (j=0; j<512; j++) {
				if (buffer[j] != buff2[j]) {
					cprintf("Buffer error at = %d\n", j);
					break;
				}
			}
		}
		cprintf("Multiple read test done.\n");
	}
#endif

#if !RETAIL
	if (debug>=1)
	cprintf("Read sector 0\n");
#endif
	if (_IDE_READ_SECTOR(buffer, 0L, slave)) {
		cprintf("Read boot sector error\n");
		exit(1);
	}
#if !RETAIL
	if (debug>=2)
	cprintf("Read done\n");
#endif

	i = 3*128;
#if !RETAIL
	if (debug>=3)
	prbuf(i, buffer+i, 512-i);
	if (debug>=3)
	cprintf("Done.\n\n");
#endif

	bootp = (void*)buffer;
	pt = bootp->partition;

	for (j=-1, i=0; i<4; i++) {
		if (pt[i].ptype == 4 ||
			 pt[i].ptype == 6 ||
			 pt[i].ptype == 0xE ||
			 pt[i].ptype == 1) {
					if (pt[i].active || j<0) j=i;
		}
	}

	if (j<0) return 5;

	dos_part.base = bswap(pt[j].sector_start);
	dos_part.count = bswap(pt[j].sector_count);

#if !RETAIL
	if (debug>=1)
	cprintf("Found partition %d:  start = %u   size = %u\n",
		j+1, dos_part.base, dos_part.count);

	if (debug>=1)
	cprintf("Read partition boot sector\n");
#endif

	_IDE_READ_SECTOR(buffer, dos_part.base, slave);

#if !RETAIL
	if (debug>=3)
	prbuf(0, buffer, 144);
#endif

	bblkp = (void*)buffer;

	bpb.bps = cvget(bblkp->bps);
	bpb.spc = cvget(bblkp->spc);
	bpb.rsvd = cvget(bblkp->rsvd);
	bpb.nfat = cvget(bblkp->nfat);
	bpb.nrde = cvget(bblkp->nrde);
	bpb.tsec = cvget(bblkp->tsec);
	bpb.md = cvget(bblkp->md);
	bpb.spf = cvget(bblkp->spf);
	bpb.spt = cvget(bblkp->spt);
	bpb.nhd = cvget(bblkp->nhd);
	bpb.hid = cvget(bblkp->hid);
	bpb.tsec2 = cvget(bblkp->tsec2);
	bpb.vers = cvget(bblkp->vers);
	bpb.id = cvget(bblkp->id);

	if (cvget(bblkp->bps) != 512) {
		cprintf("CF card bytes per sector is not 512!\n");
		return 4;
	}

	dos_part.fat_base[0] = cvget(bblkp->rsvd);
	dtemp = dos_part.fat_size = cvget(bblkp->spf);
	dos_part.nfats = cvget(bblkp->nfat);
	dos_part.fat_base[1] = 0;
	if (dos_part.nfats > 1) {
		dos_part.fat_base[1] = dos_part.fat_base[0] + dtemp;
		dos_part.nfats = 2;
	}
	dos_part.dir_base = dos_part.fat_base[dos_part.nfats - 1] + dtemp;
	dtemp = (cvget(bblkp->nrde) * sizeof(*dir) + 511) / 512;
	dos_part.data_base = dos_part.dir_base + dtemp;
	dos_part.sec_p_clus = cvget(bblkp->spc);
	dtemp = cvget(bblkp->tsec);
	if (!dtemp) dtemp = cvget(bblkp->tsec2);
	if (dos_part.count > dtemp) {
		cprintf("Sector count:  PT=%lu   BPB=%lu\n",
			dos_part.count, dtemp);
		return 1;
	}
	dos_part.clusters = (dtemp - dos_part.data_base) / dos_part.sec_p_clus;
	if (dos_part.clusters < 0xff5) {		/* 0xff5 == 4085, a magic number */
		dos_part.fatshift = 1;		/* FAT12 */
		dos_part.fateof = 0xfff;
#if !RETAIL
	if (debug>=2)
		cprintf("FAT12\n");
#endif
	}
	else {
		dos_part.fatshift = 0;
		dos_part.fateof = 0xffff;
#if !RETAIL
	if (debug>=2)
		cprintf("FAT16\n");
#endif
	}

#if !RETAIL
	if (debug>=3)
	show_bpb(&bpb);
	if (debug>=3)
	do ch = sio_get();
	while (ch<0);
#endif

	bpbp = (void*)buffer;
	unpack(FMT_BPB, buffer+11, bpbp);
#if !RETAIL
	if (debug>=3)
	prbuf(0, (byte*)bpbp, sizeof(*bpbp));
	if (debug>=2) {
		show_bpb(bpbp);
		WAIT;
	}
	if (debug>=1)
		exerciser(iter, sect);
	else
#endif
	cprintf("\n");

	cprintf("Use 'H' for help\n");
	wr_dir();
	cprintf("\n");
	help();

	mode = 0;		/* 0 = user mode,  !0 = supervisor mode */
	do {
		byte *ptr;

		do {
			cprintf("%s boot> ", exemode[!!mode]);
			i = GETLINE((char*)buffer);
			if (i==1) {
				switch(*buffer) {
#if P_TUTOR
					case 'T':  case 't':
						ptr = P_TUTOR;		/* TUTOR starting address */
						ptr = (void*)(*(dword*)ptr);
						if ((long)ptr == -1L) goto default0;
						cprintf("Tutor START=$%x\n", (dword)ptr);
						_run_us_mode( 0x2700, ptr);
						break;
#endif
					case 'C':  case 'c':
						run_rom_cpm();
						break;
					case 'U':  case 'u':
						mode = 0;
						break;
					case 'S':  case 's':
						mode = 1;
						break;
					case 'D':  case 'd':
						wr_dir();
						break;
					case 'H':  case 'h':  case '?':
#if P_TUTOR
					default0:
#endif
					default:
						help();
				}
				if (mode != 2) i = 0;
			}
		} while ( i==0 );

		cp = (char*)buffer;
		while (*cp==' ' || *cp=='\t') ++cp;

		dosname(name, cp);

		dir = find_in_dir(name);	/* 11 characters, exactly */
		cprintf("%s %s found\n", name, dir ? "is" : "not");

		if (dir) {
			ptr = (void*)LOADPOINT;

#if !RETAIL
			if (debug>=3)
				prbuf(0, (void*)dir, sizeof(*dir));
#endif

			dtemp = loadfile(ptr, dir);		/* returns number of bytes loaded */

			ptr = checkexe(ptr, dtemp);

			if (!((int)ptr & 1)) {
#if !RETAIL
				if (mode == 2) 
#endif
							_run_us_mode(mode, ptr);

#if !RETAIL
				state.usp = h_m_a - 0x1000;
				state.ssp = h_m_a;
				state.pc = (long)ptr;
				state.sr = mode ? 0x2000 : 0;
				debug68(0);
#endif
				return 0x68;
			}
	/*		prbuf((dword)ptr, ptr, dtemp<1024 ? dtemp : 1024);
	*/
		}
	} while (!dir);

	return 0;
}
