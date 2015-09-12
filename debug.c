/* debug.c -- main control program for mini-M68k debugger */
/*
	Copyright (C) 2011,2012 John R. Coffman.
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
#include "main68.h"
#include "debug.h"
#include "disasm.h"
#include "io.h"

byte	break_taken;			/* 0=trace trap, 1=breakpoint trap */
int errno;
int radix;
byte charsave;
#define PRIVATE	MLOCAL	/* not global */
/*#define unblank(p) while(*p==' '||*p==011)++p*/
#define unblank(p) while(isspace((int)(*p)))++p

T_break  breakpoint[MAXBREAKS+1];

#define xSP	0xFF
static const T_symbol builtin[] = {
	{  0, "D0", 2 },
	{  1, "D1", 2 },
	{  2, "D2", 2 },
	{  3, "D3", 2 },
	{  4, "D4", 2 },
	{  5, "D5", 2 },
	{  6, "D6", 2 },
	{  7, "D7", 2 },
	{  8, "A0", 2 },
	{  9, "A1", 2 },
	{ 10, "A2", 2 },
	{ 11, "A3", 2 },
	{ 12, "A4", 2 },
	{ 13, "A5", 2 },
	{ 14, "A6", 2 },
	{ xSP, "A7", 2 },		/* special */
	{ 15, "SSP", 3 },
	{ 16, "USP", 3 },
	{ 17, "PC", 2 },
	{ 18, "SR", 2 },
	{ xSP, "SP", 2 },		/* special */
	{  0, NULL, 0 }
									 };

/*  Linear lookup, case sensitive if nocase = 0, case insensitive if nocase = 1 */
long lookup(const T_symbol *table, char *name, byte nocase)
{
	word lth;
	const T_symbol *p = table;

	errno = 0;
	lth = strlen(name);
	while (p->length) {
		if (p->length == lth  &&  (nocase ? !stricmp(p->name, name) : !strcmp(p->name, name)) ) {
			return p->value;
		}
		++p;
	}
	
	errno = 1;
	return 0;
}


PRIVATE
void cmd_error(void)
{
	cprintf(" ?\n");
}


PRIVATE
char *token(char *lp, char **llp)
{
	char *tp;
	int16 ch;

	unblank(lp);
	tp = lp;
	ch = *lp;
	while (isalnum(ch)) {
		ch = *++lp;
	}
	if (lp == tp) tp = NULL;
	if (*lp) {
		charsave = *lp;
		*lp = 0;
	}
	*llp = lp;
	return tp;
}

PRIVATE
int size_imm(void)
{
	word bd, is;
	int size;
	word imm = *(word*)(state.pc+2);

	size = 2;		/* the IMM word */
	if (imm & 0x100) {
		 bd = (imm>>4) & 3;
		 is = (imm & 3);
		 if (bd==2) size += 2;
		 else if (bd==3) size += 4;
		 if (is==2) size += 2;
		 else if (is==3) size += 4;
	}
	return size;
}


PRIVATE
int size_ea(word ins)
{
	word mode, reg;

	mode = (ins >> 3) & 7;
	if (mode <= 4) return 0;
#if 0
	if (mode <= 6) return 2;
	/* mode is 7 */
	reg = ins & 7;
	if (reg == 1) return 4;
	if (reg <= 3) return 2;
	/* immediate */
	size = (ins >> 6) & 3;
	if (size == 2) return 4;
	return 2;
#else
	if (mode==5) return 2;
	reg = ins & 7;
	if (mode==7) {
		if (reg==0 || reg==2) return 2;
		if (reg==1) return 4;
		if (reg==3) return size_imm();
		return 0;
	}
/*	if (mode==6) */ return size_imm();
#endif
}

PRIVATE
void create_break(char *lp)
{
	uint16 n;
	long addr;

	addr = strtoul(lp, NULL, radix);
	addr &= BREAK_LIMIT_MASK;
	if (errno || (addr & 1) || 
				addr < BREAK_LIMIT_LOW || addr >= BREAK_LIMIT_HIGH) {
		cmd_error();
		return;
	}
/*  Check that a breakpoint is not already set at this location */
	for (n=0; n<MAXBREAKS; n++)
		if ( (breakpoint[n].status & BR_USED) &&
				breakpoint[n].where == addr )  {
			cmd_error();
			return;
		}
/*  Find an empty slot for the breakpoint definition */
	for (n=0; n<MAXBREAKS; n++)
		if ( !(breakpoint[n].status & BR_USED) ) break;
	if (n < MAXBREAKS) {
		if (!errno && !(addr & 1) && addr>= 0x1000 && (addr & 0x3FFFFF) < 0x3F8000) {
			breakpoint[n].where = addr;
			breakpoint[n].instr = *(word*)addr;
			breakpoint[n].status = BR_USED | BR_ENBL;
		}
		else cmd_error();
	}
	else cmd_error();
}

PRIVATE
void enable_break(char *lp)
{
	uint16 n = strtoul(lp, NULL, 10);

	if (!errno  &&  n < MAXBREAKS  &&  (breakpoint[n].status & BR_USED) ) {
		breakpoint[n].status |= BR_ENBL;
	}
	else cmd_error();
}

PRIVATE
void disable_break(char *lp)
{
	uint16 n = strtoul(lp, NULL, 10);

	if (!errno  &&  n < MAXBREAKS  &&  (breakpoint[n].status & BR_USED) ) {
		breakpoint[n].status &= ~BR_ENBL;
	}
	else cmd_error();
}

PRIVATE
void list_breaks(char *lp)
{
	uint16 n;

	for (n=0; n<MAXBREAKS; n++) {
		if (breakpoint[n].status & BR_USED) {
			cprintf("%2hd %c %06lx\n",
				n,
				breakpoint[n].status & BR_ENBL ? 'e' : 'd',
				breakpoint[n].where );
		}
	}
}

PRIVATE
void clear_breaks(char *lp)
{
	uint16 n, a, b;

	unblank(lp);
	if (*lp == '*') {
		a = 0;
		b = MAXBREAKS-1;
		errno = 0;
	}
	else {
		a = b = strtoul(lp, NULL, 10);
	}
	if (errno) cmd_error();
	else for (n = a; n <= b; n++) {
		breakpoint[n].where = 0;
		breakpoint[n].instr = 0;
		breakpoint[n].status = 0;
	}
}

/* install all the enabled breakpoints before Go or Trace execution begins */
void install_breaks(void)
{
	uint16 i;
	T_break	*bp = breakpoint;
	word *insp;

	for (i=0; i<=MAXBREAKS; i++, bp++) {
		if (bp->status & BR_ENBL) {
			insp = (word*) bp->where;
/*			bp->instr = *insp;		  */
			*insp = INSBREAK;
		}
	}

}

/* remove all the enabled breakpoints after a Trace or Break trap */
void remove_breaks(void)
{
	uint16 i;
	T_break	*bp = breakpoint;
	word *insp;

	for (i=0; i<=MAXBREAKS; i++, bp++) {
		if (bp->status & BR_ENBL) {
			insp = (word*) bp->where;
			*insp = bp->instr;
		}
	}
	breakpoint[MAXBREAKS].status = 0;	/* stepping breakpoint */
	breakpoint[MAXBREAKS].where  = 0;	/* not really necessary to do this */

}



/* check for an enabled breakpoint at the resume PC
	Return
		-1		if all clear
		n		number of the breakpoint  0...
*/
PRIVATE
int check_pc(void)
{
	int n;

	for (n=0; n<MAXBREAKS; n++) {
		if ( (breakpoint[n].status & BR_ENBL) &&
			   breakpoint[n].where == state.pc )  return n;
	}

	return -1;
}

PRIVATE
void execute_trace(long count)
{
	int flag;
	
	if ( (flag=check_pc()) >= 0 ) {
		breakpoint[flag].status &= ~BR_ENBL;
		Trace(1);
		breakpoint[flag].status |= BR_ENBL;
		count--;
	}
	if (count > 0) Trace(count);
}

PRIVATE
void execute_go(void)
{
	int flag;
	
	if ( (flag=check_pc()) >= 0 ) {
		breakpoint[flag].status &= ~BR_ENBL;	/* disable the break */
		Trace(1);
		breakpoint[flag].status |= BR_ENBL;		/* enable it again */
	}
	Go(1);
}


#define is_jXX(ins) (((ins) & 0xFF80) == 0x4E80)
#define is_bXX(ins) (((ins) & 0xF000) == 0x6000)
#define is_dbXX(ins) (((ins) & 0xF0F8) == 0x50C8)
#define is_trap(ins) (((ins) & 0xFFF0) == 0x4E40)
#define is_trapv(ins) ((ins) == 0x4E76)
#define is_trapcc(ins) (((ins) & 0xF0F8) == 0x50F8)

PRIVATE
void execute_skipover(void)
{
	word ins;
	int incr = 2;
	long addr;

	ins = *(word*)state.pc;
	if (is_jXX(ins)) {
		incr += size_ea(ins);
	}
	else if (is_bXX(ins)) {
		incr += 2 * ((ins & 0xFF) == 0);
#if (M68000 >= 68020)
		incr += 4 * ((ins & 0xFF) == 0xFF);
#endif
	}
	else if (is_dbXX(ins)) {
		incr += 2;
	}
	else if (is_trap(ins) || is_trapv(ins)) {
		/* single word instruction */ ;;;
	}
	else if (is_trapcc(ins)) {
		if ((ins&7) == 2) incr += 2;
		else if ((ins&7) == 3) incr += 4;
	}
	else {	/* none of the above */
		execute_trace(1);
		return;
	}
/* set the Step Over breakpoint and resume execution */
	breakpoint[MAXBREAKS].where = addr = state.pc + incr;
	breakpoint[MAXBREAKS].instr = *(word*)addr;
	breakpoint[MAXBREAKS].status = BR_USED | BR_ENBL;
	execute_go();
}

PRIVATE
void print_regs(char name, long *v, word last)
{
	word i;
	for (i=0; i<last; ) {
		cprintf("  %c%hd %08lx", name, i, v[i]);
		if (!(++i & 3)) cprintf("\n");
	}
}

PRIVATE
void print_state(struct STATUS *statep)
{
	print_regs('D', statep->d, 8);
	print_regs('A', statep->a, 7);
	cprintf("  A7 %08lx\n", (statep->sr & 0x2000u) ? statep->ssp : statep->usp);
	cprintf("PC %06lx  SR %04hx  USP %06lx  SSP %06lx\n",
		statep->pc, statep->sr,
		statep->usp, statep->ssp  );
}

PRIVATE
void dump_memory(int format, uint32 start, int count)
{
/*	static const char * const spacer = "        "; */
	static const char * const fmt[4] = {
		" %02hx",
		" %04hx",
		"%c",
		" %08lx"
		};
	word m, n, i;
	long k;
	char *p;

	/* format: 'C', 'B', 'W', 'L' encoded as 3,1,2,4 */

	if (format<1 || format>4) format=1;
	if ( (format & 1)==0 ) {
		start &= 0xFFFFFFFE;	/* align address */
	}
	m = 0;
	if (format == 3) n = 64;
	else {
		n = 16/format;		/* number of entries per line */
	}

	while (count > 0) {
		cprintf("%06lx:", start);
		p = (void*)start;
		for (i=0; i<n && count>0; i++, count--) {
			if (i==0 || i==m) cprintf(" ");
			k = 0;
			switch (format) {
				case 1:
					m = 8;
					(word)k = *(byte*)p++;
					break;
				case 2:
					m = 4;
					(word)k = *((word*)p)++;
					break;
				case 3:
					(byte)k = *p++;
					break;
				case 4:
					k = *((long*)p)++;
					break;
			} /* switch */
			cprintf(fmt[format-1], k);
		} /* for */
		cprintf("\n");
		start = (uint32)p;
	} /* while */

}

PRIVATE
void help(void)
{
	cprintf("%s",
"B <addr>  set break                    G  go from current PC\n"
"BC <n>  clear break                    N [<radix>]  set/ask radix\n"
"BD <n>  disable break                  Q  quit\n"
"BE <n>  enable break                   R [<reg>]  register(s) display\n"
"BL   list breaks                       S  step over branch or call\n"
"D [<addr> [<lth>]]  dump               T [<n>]  trace N instructions\n"
" DB, DW, DL, DC  format                U [<addr> [<lth>]]  unassemble\n"
"I <port>  input byte port\n"
"O <port> <byte>  out to byte port\n"
"                      ? or H  print help\n"
	);
}



void debug68(int option)
{
	char line[80];
	char ch, *lp, *tp;
	long n, v;
	long dumpbegin = 0;
	long udot = 0;
	byte skip = 0;
	int dumpcount = 0x40;
	int dumpformat = 2;
	int ucount = 4;

	radix = 16;
	for (;;) {
		if (!skip) {
			print_state(&state);
			dump_memory(2, state.pc, 6);
			cprintf("         ");
			udot = state.pc;
				pinstr(udot);	/* print instruction */
			cprintf("\n");
		}
		skip = 1;

		cprintf(">>");
		if ( GETLINE(line) ) {
			lp = line;
			unblank(lp);
			ch = *lp++;
			switch (toupper(ch)) {
				case 'B':	/* Breakpoints */
					ch = *lp++;
					switch (toupper(ch)) {
						case 'C':	clear_breaks(lp); break;
						case 'D':	disable_break(lp); break;
						case 'E':	enable_break(lp); break;
						case 'L':	list_breaks(lp); break;
						case ' ':	create_break(lp); break;
						default:		cmd_error();
					}
					break;
				case 'D':	/* Dump memory */
					ch = *lp++;
					switch (toupper(ch)) {
						case 'B':	dumpformat = 1; break;
						case 'W':	dumpformat = 2; break;
						case 'L':	dumpformat = 4; break;
						case 'C':	dumpformat = 3; break;
						default:		--lp;
					}
					n = strtoul(lp, &lp, radix);
					if (!errno) dumpbegin = n;
					n = strtoul(lp, &lp, radix);
					if (!errno && n>0) dumpcount = n;
					if (dumpformat != 3) {
						n = (dumpcount + dumpformat - 1) / dumpformat;
						dumpcount = n * dumpformat;
					}
					dump_memory(dumpformat, dumpbegin, n);

					if (dumpformat == 3)
						dumpbegin += strlen((char*)dumpbegin) + 1;
					else  dumpbegin += dumpcount;

					skip = 1;
					break;
				case 'G':	/* Go from here */
					execute_go();
					skip = 0;
					break;
				case 'I':
					n = strtoul(lp, NULL, radix);
					if (errno) break;
					n &= 0x3FFF;
					v = inp(n);
					cprintf("%02lx\n", v);
					skip = 1;
					break;
				case 'N':	/* set the numeric radix */
					n = strtoul(lp, NULL, 10);
					if (n < 2 || n > 16) {
						cprintf(" %d\n", radix);
					} else radix = n;
					skip = 1;
					break;
				case 'O':	/* output to a byte port */
					n = strtoul(lp, &lp, radix);
					if (errno) break;
					n &= 0x3FFF;
					v = strtoul(lp, &lp, radix);
					if (errno) break;
					outp(n,v);
					skip = 1;
					break;
				case 'Q':	/* quit debugger */
					return;
				case 'R':	/* display registers */
					skip = 0;
					tp = token(lp, &lp);
					if (tp) {
						skip = 1;
						n = lookup(builtin, tp, 1);
						if (errno) {
							cmd_error();
							break;
						}
						if (n == xSP) n = 15 + !(state.sr & 0x2000);
						cprintf(n==18 ? "%04lx : " : n<15 ? "%08lx : " : "%06lx : ",
									state.d[n]);
						v = GETLINE(line);
						if (v) {
							v = strtoul(line, NULL, radix);
							if (!errno) state.d[n] = v;
						}
					}
					break;
				case 'S':	/* step over a call or jump */
					execute_skipover();
					skip = 0;
					break;
				case 'T':	/* trace into */
					n = strtoul(lp, &lp, radix);
					if (n < 1)  n = 1;
					execute_trace(n);
					skip = 0;
					break;
				case 'U':	/* unassemble */
					n = strtoul(lp, &lp, radix);
#if M68000<68020
					if (!errno) udot = n & 0x00FFFFFEu;
#else
					if (!errno) udot = n & 0xFFFFFFFEu;
#endif
					n = strtoul(lp, &lp, radix);
					if (!errno && n>0) ucount = n;
					n = ucount;
					while (n--) {
						cprintf("%06lx:  ", udot);
						udot += pinstr(udot);
						cprintf("\n");
					}
					break;
				default: /* case 'H': case '?': */
					help();
			} /* switch */
		} /* if */
	} /* for(ever) */
}

