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
#include <stdlib.h>
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

const char *fatfs_errmsg[20] = 
{
    /* 0  */ "Succeeded",
    /* 1  */ "A hard error occurred in the low level disk I/O layer",
    /* 2  */ "Assertion failed",
    /* 3  */ "The physical drive cannot work",
    /* 4  */ "Could not find the file",
    /* 5  */ "Could not find the path",
    /* 6  */ "The path name format is invalid",
    /* 7  */ "Access denied due to prohibited access or directory full",
    /* 8  */ "Access denied due to prohibited access",
    /* 9  */ "The file/directory object is invalid",
    /* 10 */ "The physical drive is write protected",
    /* 11 */ "The logical drive number is invalid",
    /* 12 */ "The volume has no work area",
    /* 13 */ "There is no valid FAT volume",
    /* 14 */ "The f_mkfs() aborted due to any parameter error",
    /* 15 */ "Could not get a grant to access the volume within defined period",
    /* 16 */ "The operation is rejected according to the file sharing policy",
    /* 17 */ "LFN working buffer could not be allocated",
    /* 18 */ "Number of open files > _FS_LOCK",
    /* 19 */ "Given parameter is invalid"
};

void f_perror(int errno)
{
    if(errno <= 19)
        cprintf("Error: %s\n", fatfs_errmsg[errno]);
    else
        cprintf("Error: Unknown error %d. Hold tight.\n", errno);
}

void do_dump(char *argv[], int argc)
{
    unsigned long start, count;

    start = strtoul(argv[0], NULL, 16);
    count = strtoul(argv[1], NULL, 16);

    pretty_dump_memory((void*)start, count);
}

void do_cd(char *argv[], int argc)
{
    FRESULT r;

    r = f_chdir(argv[0]);
    if(r != FR_OK)
        f_perror(r);
}

void do_ls(char *argv[], int argc)
{
    FRESULT fr;
    const char *path;
    DIR fat_dir;
    FILINFO fat_file;
    bool left = true;
    int i;

    if(argc == 0)
        path = "";
    else
        path = argv[0];

    fr = f_opendir(&fat_dir, path);
    if(fr != FR_OK){
        cprintf("f_opendir(\"%s\"): ", path);
        f_perror(fr);
        return;
    }

    while(1){
        fr = f_readdir(&fat_dir, &fat_file);
        if(fr != FR_OK){
            cprintf("f_readdir(): ");
            f_perror(fr);
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
        cprintf("f_closedir(): ");
        f_perror(fr);
        return;
    }
}

#define LINELEN 128
#define MAXARG 10

FATFS fat_fs_workarea[_VOLUMES];

typedef struct
{
    const char *name;
    const int min_args;
    const int max_args;
    void (* function)(char *argv[], int argc);
} cmd_entry_t;

const cmd_entry_t cmd_table[] = {
    /* name     min max function */
    {"ls",      0,  1,  &do_ls},
    {"dir",     0,  1,  &do_ls},
    {"cd",      1,  1,  &do_cd},
    {"dump",    2,  2,  &do_dump},
    {0, 0, 0, 0} /* terminator */
};

bool handle_cmd_builtin(char *arg[], int numarg)
{
    FRESULT fr;
    const cmd_entry_t *cmd;

    if(numarg == 1 && arg[0][strlen(arg[0])-1] == ':'){
        /* change drive */
        fr = f_chdrive(arg[0]);
        if(fr)
            f_perror(fr);
        return true;
    } else {
        /* built-in command */
        for(cmd = cmd_table; cmd->name; cmd++){
            if(!strcasecmp(arg[0], cmd->name)){
                if((numarg-1) >= cmd->min_args && 
                        (cmd->max_args == 0 || (numarg-1) <= cmd->max_args)){
                    cmd->function(arg+1, numarg-1);
                }else{
                    if(cmd->min_args == cmd->max_args){
                        cprintf("%s: takes exactly %d argument%s\n", arg[0], cmd->min_args, cmd->min_args == 1 ? "" : "s");
                    }else{
                        cprintf("%s: takes %d to %d arguments\n", arg[0], cmd->min_args, cmd->max_args);
                    }
                }
                return true;
            }
        }
    }
    return false;
}

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
            if(!handle_cmd_builtin(arg, numarg))
                cprintf("%s: unknown command\n", arg[0]);
        }
    }

    return 0;
}
