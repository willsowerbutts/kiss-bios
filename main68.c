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
#include <stdbool.h>
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
#include "ff.h"

void *memset(void *s, int c, size_t n);
void pretty_dump_memory(void *start, int len);
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
    "Copyright (C) 2015 William R. Sowerbutts <will@sowerbutts.com>" "\r\n"
#if RETAIL
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
#endif
#if M68000==68030
    "Distributed for hobbyist use on the N8VEM KISS-68030 CPU board."
#else
    "Distributed for hobbyist use on the N8VEM Mini-M68k CPU board."
#endif
    "\r\n\r\n";

T_nv_struct nvram;

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

FATFS fat_fs;

void do_ls(const char *path)
{
    FRESULT fr;
    DIR fat_dir;
    FILINFO fat_file;
    bool left = true;
    int i;

    fr = f_opendir(&fat_dir, path);
    if(fr != FR_OK){
        cprintf("Failed f_opendir(\"%s\"): 0x%x\n", path, fr);
        return;
    }

    while(1){
        fr = f_readdir(&fat_dir, &fat_file);
        if(fr != FR_OK){
            cprintf("Failed f_readdir(): 0x%x\n", fr);
            break;
        }
        if(fat_file.fname[0] == 0) /* end of directory? */
            break;

        if(fat_file.fattrib & AM_DIR){
            /* directory */
            cprintf("          %04d-%02d-%02d %02d:%02d:%02d %s/", 
                    1980 + ((fat_file.fdate >> 9) & 0x7F),
                    (fat_file.fdate >> 5) & 0xF,
                    fat_file.fdate & 0x1F,
                    fat_file.ftime >> 11,
                    (fat_file.ftime >> 5) & 0x3F,
                    (fat_file.ftime & 0x1F) << 1,
                    fat_file.fname);
            for(i=strlen(fat_file.fname); i<12; i++)
                cprintf(" ");
        }else{
            /* regular file */
            cprintf("%9d %04d-%02d-%02d %02d:%02d:%02d %-12s ", fat_file.fsize, 
                    1980 + ((fat_file.fdate >> 9) & 0x7F),
                    (fat_file.fdate >> 5) & 0xF,
                    fat_file.fdate & 0x1F,
                    fat_file.ftime >> 11,
                    (fat_file.ftime >> 5) & 0x3F,
                    (fat_file.ftime & 0x1F) << 1,
                    fat_file.fname);
        }

        if(left)
            cprintf(" ");
        else
            cprintf("\n");
        left = !left;
    }

    if(!left)
        cprintf("\n");

    fr = f_closedir(&fat_dir);
    if(fr != FR_OK){
        cprintf("Failed f_closedir(): 0x%x\n", fr);
        return;
    }
}

#define MEMORY_INCREMENT  (512*1024)        /* test in chunks of 512KB */
#define MEMORY_TESTOFFSET 0x1100            /* avoid overwriting exception vectors */
#define MEMORY_MAXIMUM    (long*)0x10000000 /* 256MB */
#define MEMTEST_VAL1      0x55AA77CC
#define MEMTEST_VAL2      0xEC3C6D5D

void data_cache_flush(void);

long *memtop = (long*)0;

void probe_memory_size(void)
{
    volatile long *testptr;

    do{
        testptr = memtop + (MEMORY_TESTOFFSET / sizeof(long));

        *testptr = MEMTEST_VAL1;
        data_cache_flush();
        if(*testptr != MEMTEST_VAL1)
            break;

        *testptr = MEMTEST_VAL2;
        data_cache_flush();
        if(*testptr != MEMTEST_VAL2)
            break;

        memtop += (MEMORY_INCREMENT / sizeof(long));
    }while(memtop < MEMORY_MAXIMUM);

    cprintf("RAM found to address 0x%08x (%dMB)\n", memtop, (long)memtop >> 20);
}

int main68(void)
{
    FRESULT fr;
    cprintf("Hello, world!\n");

    probe_memory_size();

    fr = f_mount(&fat_fs, "0:", 1);
    if(fr != FR_OK){
        cprintf("Failed FAT mount: 0x%x\n", fr);
        exit(fr);
    }

    cprintf("\n");
    do_ls("");
    cprintf("\n");
    do_ls("0:/bios.src");

    return 0;
}
