/* coff.h -- M68k coff a.out format */
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
#ifndef _COFF_H
#define _COFF_H 1
#include "mytypes.h"

#define MAGIC_COFF 0x0150

typedef
struct COFF_SECT {
    char section_name[8];
    dword   win32_at;           /* redundant load location */
    dword   load_at;            /* load section here */
    dword   length;             /* length of section in bytes */
    dword   file_pos;           /* position in file of section data */
    dword   unknown[3];         /* MBZ */
    dword   type_info;          /* hex types: 20h, 40h, 80h for .text, .data, .bss */ 
} T_coff_sect;

typedef
struct AOUT_HEAD {
    word    magic;          /* 0x5001 */
    word    n_sects;        /* number of sections */
    dword   reserved[5];    /* unknown usage */
    dword   sect_len[3];    /* lengths of 3 sections:  .text, .data, .bss */
    dword   entry_point;    /* start execution here */
    dword   text_load_at;   /* load .text here */
    dword data_load_at;     /* load .data here -- WRS: does not always match section headers! */
    T_coff_sect section[3]; /* multiple section headers */
} T_aout_head;

#endif  // _COFF_H
