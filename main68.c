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

#define LINELEN 128
#define MAXARG 10

FATFS fat_fs_workarea[_VOLUMES];

int main68(void)
{
    char buffer[LINELEN];
    char *p, *arg[MAXARG+1];
    int numarg, i;

    /* set up work areas for each volume */
    for(i=0; i<_VOLUMES; i++){
        buffer[0] = '0' + i;
        buffer[1] = ':';
        buffer[2] = 0;
        f_mount(&fat_fs_workarea[i], buffer, 0); /* permit lazy mounting */
    }

    while(true){
        f_getcwd(buffer, LINELEN/sizeof(TCHAR));
        cprintf("%s> ", buffer);
        getline(buffer, LINELEN);

        /* parse buffer into list of args */
        numarg = 0;
        p = buffer;
        while(true){
            if(!*p){ /* end of string? */
                arg[numarg] = 0;
                break;
            }
            while(isspace(*p))
                p++;
            if(!isspace(*p)){
                arg[numarg++] = p;
                while(*p && !isspace(*p))
                    p++;
                if(!*p)
                    continue;
                while(isspace(*p)){
                    *p=0;
                    p++;
                }
            }
        }

        if(numarg > 0){
            if(!strcasecmp(arg[0], "dir") || !strcasecmp(arg[0], "ls")){
                if(numarg == 1)
                    do_ls("");
                else if(numarg == 2)
                    do_ls(arg[1]);
                else
                    cprintf("%s: too many arguments\n", arg[0]);
            }else if(!strcasecmp(arg[0], "cd")){
                if(numarg == 2)
                    f_chdir(arg[1]);
                else
                    cprintf("%s: provide exactly 1 argument\n", arg[0]);
            }else if(numarg == 1 && arg[0][strlen(arg[0])-1] == ':'){
                f_chdrive(arg[0]);
            }else{
                cprintf("%s: unrecognised command\n", arg[0]);
            }
        }
    }

    return 0;
}
