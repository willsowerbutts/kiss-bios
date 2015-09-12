/* disasm.c
        	Derived from DRI's SID05.C, part of the SID debugger, formerly
        	know as DDT.
 */

/************************************************************************/
/*									*/
/*  Usual filename:  SID05.C						*/
/*  Remarks:  Fourth C module for SID68K				*/
/*  Adapted by:  Timothy M. Benson					*/
/*  Control:  11 MAY 83  11:31  (TMB)					*/
/*									*/
/************************************************************************/
#include "portab.h"
//#include "ddt/lgcdef.h"
//#include "ddt/cputype.h"
//#include "ddt/siddef.h"
//#include "ddt/ddtinc.h"
#include "optab.h"
//#include "ddt/stdio.h"
//#include "ddt/bdosfunc.h"
//#include "ddt/disas.h"

/*******
        Interface to mini-M68k debugger
*******/
#include "main68.h"
#include "disasm.h"

#define NEW_STUFF	0
#define putchar(ch) _con_out((char)ch)
int _con_out(char);
#define stout(s) cprintf("%s",s)
#define puthex(n,f,u) cprintf((f)<=8?"%02lx":(f)<=16?"%04lx":"%08lx",(n))
extern const char nstring[];
#define hexchar(r) nstring[r]
/************************************************************************/


MLOCAL char *dot, *sdot;
MLOCAL int dotinc;


int pinstr(long ip)
/************************************************************************/
/*									*/
/*	print an instruction in assembler format			*/
/*									*/
/************************************************************************/
{
   REG struct optbl *p;

        dot = (char*)ip;


#if NEW_STUFF
        				/**temp** Next several lines added recently */
   REG WORD reg;
   EXTERN struct lmhedr *caput;
   EXTERN WORD scope; 
   EXTERN BYTE ref;
   EXTERN LONG inhalt;
        				/**temp** End of added stuff	*/
        				/**temp** Next several lines added recently */
   ref = '\0';				/* Mark "not in use"		*/
        						/**temp** End of added stuff	*/
#endif

        sdot = dot + 2;			/* next word address		*/
        dotinc = 2;

        instr = *(short*) dot;			/* instruction in binary	*/

        p = (void*)&optab;				/* sequential search = (n+1)/2	*/
        while(TRUE) {			/* last table entry matches anything */
        		if( (instr & (p->inmsk)) == p->invalu)
        			break;			/* found it			*/
        		p++;
        }

        stout(p->innam);			/* print mnemonic		*/
        stout("  ");

        if( (p->infmt >= 0) && (p->infmt <= MAXFMT) ) {

        		if(p->infmt) {

            		switch ( p->infmt) {	/* call proper funct		*/
            			case  0 : noin();  break;	    case  1 : inf1();  break;
            			case  2 : inf2();  break;	    case  3 : inf3();  break;
            			case  4 : inf4();  break;	    case  5 : inf5();  break;
            			case  6 : inf6();  break;	    case  7 : inf7();  break;
            			case  8 : inf8();  break;	    case  9 : inf9();  break;
            			case 10 : inf10(); break;	    case 11 : inf11(); break;
            			case 12 : inf12(); break;	    case 13 : inf13(); break;
            			case 14 : inf14(); break;	    case 15 : inf15(); break;
            			case 16 : inf16(); break;	    case 17 : inf17(); break;
            			case 18 : inf18(); break;	    case 19 : inf19(); break;
            			case 20 : inf20(); break;	    case 21 : inf21(); break;
            			case 22 : inf22(); break;	    case 23 : inf23(); break;
            			case 24 : inf24(); break;	    case 25 : inf25(); break;
            		}
        		}

        				/**temp** Next line added recently */
#if NEW_STUFF
        		if ( ref ) {
            		putchar(' ');
            		spell((U32)inhalt,caput->sump,scope,ref,'H');
        		}
#endif

   }
   else
        	putchar('?');


        return dotinc;
}


VOID noin(void)
{
    stout("illegal instruction format #\n");
    return;
}


VOID
inf1(void)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |  REG  Rx  | x |  SIZE | x | x |R/M|  REG  Ry  |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		ABCD, ADDX, SBCD, SUBX					*/
/*									*/
/************************************************************************/
{
    REG WORD i;
 

    i = (instr & 0x0E00) >> 9;

    if (instr & 8) {			/* R/M field == 1 so...		*/
        		paripd(instr & 7);		/* this is memory to memory op	*/
        		putchar(',');			/* use Address registers with	*/
        		paripd(i);			/* predecrement.		*/
    }
    else {
        		pdr(instr & 7);			/* R/M field == 0 so....	*/
        		putchar(',');			/* this is data reg to data reg	*/
        		pdr(i);				/* operands in data register.	*/
    }
}


VOID
inf2(VOID)
/************************************************************************/
/*									*/
/*					     |   EFFECTIVE ADDRESS   |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | REGISTER  |  OP-MODE  |   MODE    |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		ADD, ADDA, AND, CMP, CMPA, EOR, LEA, OR, SUB, SUBA	*/
/*									*/
/************************************************************************/
{
    REG WORD reg;
    REG WORD mode;


    reg = ( (instr & 0x0E00) >> 9);

        				/* Special case the ADDA/SUBA	*/
        				/* instructions.  These have	*/
        				/* OP-MODEs = 3,7.  Then add 8	*/
        				/* to denote address register	*/
    if( (instr & 0x00C0) == 0x00C0) {	
        mode = WORDSZ;
        if((instr & 0x01C0) == 0x01C0) {
            mode = LONGSZ;
        }
        reg += AREG0;
    }
    else {
        mode = (instr & 0x00C0) >> 6;
    }


    if( (reg > 7) || ( (instr & 0x0100) == 0) ) {
        prtop(instr & 077,mode);
        putchar(',');			/* Operation <ea>,(Dn or An)	*/
        prtreg(reg);
    }
    else {
        prtreg(reg);
        putchar(',');			/* Operation Dn,<ea>		*/
        prtop(instr & 077,mode);
    }
}


VOID
inf3(VOID)
/************************************************************************/
/*									*/
/*					       EFFECTIVE    ADDRESS	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x |  SIZE |    MODE   | REGISTER  |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |      WORD DATA (16 bits)      |      BYTE DATA (8 bits)       |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |   LONG DATA (32 bits, including previous word)		     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		ADDI, ANDI, CMPI, EORI, ORI, SUBI			*/
/*									*/
/************************************************************************/
{
    REG WORD size;
 

    size = (instr & 0x00C0) >> 6;		/* Print out the size of the	*/
    					/* operation.  Then seperate	*/
    					/* with blank.  Display the 	*/
    primm(size);			/* immediate size of the value.	*/
    putchar(',');

    switch (instr) {			/* Then print the effective	*/
    case 0x027C:			/* address.  Special case ANDI,	*/
    case 0x0A7C:			/* EORI, and ORI to SR.		*/
    case 0x007C:
        stout("SR");
 	break;

    case 0x023C:			/* Also special case ANDI, EORI	*/
    case 0x0A3C:			/* and ORI to CCR.		*/
    case 0x003C:
        stout("CCR");
        break;

    default :
        prtop( (instr & 077),size);
    }
}


VOID
inf4(VOID)
/************************************************************************/
/*									*/
/*					     |   EFFECTIVE ADDRESS   |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |   DATA    | x |  SIZE |   MODE    |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		ADDQ, SUBQ						*/
/************************************************************************/
{
    REG WORD i;
 

    i = (instr & 0x0E00) >> 9;
    if(i == 0)
        i = 8;

    stout("#$");
    hexbzs( (BYTE)i);
    putchar(',');

    prtop((instr & 077),WORDSZ);
}



VOID
inf5(VOID)
/************************************************************************/
/*									*/
/*					     |   EFFECTIVE ADDRESS   |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x | x | x |    MODE   |  REGISTER |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*									*/
/*	Covers the following instructions:				*/
/*		MOVE to CCR, MOVE from CCR, MOVE to SR, MOVE from SR	*/
/*									*/
/************************************************************************/
{
    REG WORD i;
 

    i = instr & 0x0600;
    if(i == 0) {
        stout("SR,");
    }
    else if (i == 0x0200) {
        stout("CCR,");
    }

    prtop( (instr &077),WORDSZ);

    if(i == 0x0400)
        stout(",CCR");
    else if (i == 0x0600)
        stout(",SR");
}



VOID
inf6(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | COUNT/REG | DR|  SIZE |I/R| x | x |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		ASL, ASR, LSL, LSR, ROL, ROR, ROXL, ROXR		*/
/*									*/
/************************************************************************/
{
    REG WORD i;
 

    i = (instr & 0x0E00) >> 9;		/* get register number and find	*/

    if(instr & 0x0020) {		/* if bit # is in a register.	*/
        pdr(i);				/* If so print the reg #	*/
    }
    else {				/* Otherwise....		*/
        if(i == 0)			/* A zero denotes 8 bits all	*/
            i = 8;			/* others the same		*/
        putchar('#');			/* print the immediate value	*/
        hexbzs((BYTE)i);
    }

    putchar(',');			/* Then....			*/
    prtreg(instr & 07);			/* display the reg to be shifted*/

}



VOID
inf7(VOID)
/************************************************************************/
/*									*/
/*					     | EFFECTIVE    ADDRESS  |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x | x | x |   MODE    |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers The following instructions:				*/
/*		ASL, ASR, CLR, JMP, JSR, LSL, LSR, NBCD, NEG, NEGX,	*/
/*		NOT, PEA, ROL, ROR, ROXL, ROXR,	Scc, TAS, TST, 		*/
/*									*/
/************************************************************************/
{

    prtop( (instr & 077),WORDSZ);	/* print the Effective Address	*/
        				/* size is a nop for imm	*/
}



VOID
inf8(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |   CONDITION   |  8-BIT  DISPLACEMENT	     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |		16-BIT DISPLACEMENT if 8-BIT == 0		     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |		32-BIT DISPLACEMENT if 8-BIT == $FF	(68020)              |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		Bcc, BRA, BSR						*/
/*									*/
/************************************************************************/
{
    REG WORD i;				/* temp for 8-bit displacement	*/
    REG BYTE *p;
 

    i = (BYTE)instr;
#if M68000 >= 68020
    if (i == -1) {			/* 68020 and higher long displacement */
	 		LONG disp = *(short*)sdot;
			disp <<= 16;
			disp |= *(UWORD*)(sdot+2);
        	p = sdot + disp;		/* displacement = current local	*/
        	sdot += 4;			   /* + the next word.  Bump the	*/
        	dotinc += 4;			/* counters accordingly		*/
    }
    else
#endif
        							   /* Determine if 8-bit displace-	*/
         if(i) {						/* ment is present.  If so get	*/
        	p = sdot + i;			/* current location and add disp*/
    }
    else {				/* Otherwise...			*/
        	p = sdot + *(short*)sdot;		/* displacement = current local	*/
        	sdot += 2;			/* + the next word.  Bump the	*/
        	dotinc += 2;			/* counters accordingly		*/
    }

    stout("$");				/* Print the hex value of the	*/
    hexlzs((LONG)p);				/* displacement.		*/
}


VOID
inf9(VOID)
/************************************************************************/
/*									*/
/*					     | EFFECTIVE    ADDRESS  |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |  REGISTER | x | x | x |    MODE   |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following Instructions:				*/
/*		CHK, DIVS, DIVU, MULS, MULU				*/
/*									*/
/************************************************************************/
{
    REG WORD i;
 

    prtop( (instr & 077),WORDSZ);		/* print the Effective Address	*/

    putchar(',');

    i = (instr & 0x0E00) >> 9;		/* Then the register and type	*/
        pdr(i);
}


VOID
inf10(VOID)
/************************************************************************/
/*									*/
/*					     |   EFFECTIVE ADDRESS   |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |  REGISTER | x | x | x |    MODE   |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*   |				BIT NUMBER (for static only)	     |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*									*/
/*	Covers the following instructions:				*/
/*		BCHG, BCLR, BSET, BTST					*/
/*									*/
/************************************************************************/
{

    if(instr & 0x0100) {			/* if bit #dynamic, then print	*/
        pdr( (instr & 0x0E00) >> 9);	/* Data reg number.		*/
    }
    else {				/* Otherwise...			*/
        primm(WORDSZ);			/* print the immediate value	*/
    }

    putchar(',');

    prtop( (instr & 077),WORDSZ);	/* then the Effective Address	*/
}



VOID
inf11(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |REGISTER Rx| x |  SIZE | x | x | x |REGISTER Ry|  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		CMPM							*/
/*									*/
/************************************************************************/
{
    REG WORD i;
 

    paripi(instr & 7);			/* Prints source address then	*/
    putchar(',');			/* the destination address in	*/
    i = (instr & 0x0E00) >> 9;		/* Address register post inc	*/
    paripi(i);
}



VOID
inf12(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |  CONDITION    | x | x | x | x | x |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |				DISPLACEMENT			     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		DBcc							*/
/*									*/
/************************************************************************/
{
    REG BYTE *p;
 

    					/* Get and print out the Data	*/
    pdr(instr & 07);			/* Register that contains the	*/
        				/* count.			*/

    putchar(',');

    p = sdot + *(short*)sdot;		/* Then get current loc and add	*/
    sdot += 2;				/* the diaplacement.  Bump all	*/
    dotinc += 2;			/* pointers then print disp.	*/

    hexlzs((LONG)p);
}



VOID
inf13(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |REGISTER Rx| x |       OP-MODE     |REGISTER Ry|  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		EXG							*/
/*									*/
/************************************************************************/
{
    REG WORD rx;
    REG WORD ry;
    REG WORD opmde;
 

    rx = (instr & 0x0E00) >> 9;
    ry = instr & 7;
    opmde = instr & 0x00F8;

    if(opmde == 0x0048) {		/* Specifies both as Address	*/
        rx += AREG0;			/* registers.  Bump by 8 to let	*/
        ry += AREG0;			/* routine know.		*/
    }
    else if(opmde == 0x0088) {		/* if true echange is between a	*/
        ry += AREG0;			/* data and address reg.  Ry is	*/
    }					/* always an Address register.	*/

    prtreg(rx);				/* prints source register	*/
    putchar(',');
    prtreg(ry);				/* print destination register	*/
}



VOID
inf14(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x |  OP-MODE  | x | x | x |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		EXT							*/
/*									*/
/************************************************************************/
{
    REG WORD i;


    i = instr & 07;			/* Print out Data Register	*/
    pdr(i);
}


VOID
inf15(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x | x | x | x | x | x |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |				DISPLACEMENT			     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		LINK							*/
/*									*/
/************************************************************************/
{
    par(instr & 7);

    stout(",#$");
    hexwzs(*(short*)sdot);

    sdot += 2;
    dotinc += 2;
}


VOID
inf16(VOID)
/************************************************************************/
/*									*/
/*		     |      DESTINATION	     |		SOURCE	     |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x |  SIZE | REGISTER  |   MODE    |   MODE    |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions.				*/
/*		MOVE, MOVEA						*/
/*									*/
/************************************************************************/
{
    REG WORD size;
    REG WORD i;
 

    i = instr & 0x3000;			/* determine the size		*/
         size = WORDSZ;			   /* silence GCC */
    if(i == 0x1000)
        	size = BYTESZ;
    else if (i == 0x3000)
        	size = WORDSZ;
    else if(i == 0x2000)
        	size = LONGSZ;
    else
        	badsize();

    prtop( (instr & 077),size);		/* Source Effective Address	*/

    putchar(',');

    i = ( (instr & 07000) >> 9) | ( (instr & 0700) >> 3);
    prtop(i,size);			/* Dest. Effective Address	*/
}



VOID
inf17(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x | x | x | x | x | DR|  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		MOVE USP,An,  MOVE An,USP				*/
/*									*/
/************************************************************************/
{
    REG WORD i;
 

    i = instr & 7;
    if(instr & 8) {			/* USP to An */
        stout("USP,");
        par(i);
    }
    else {
        par(i);
        stout(",USP");
    }
}



CONST WORD regmsk0[] = {0100000,040000,020000,010000,04000,02000,01000,0400,0200,
        			0100,040,020,010,4,2,1};
CONST WORD regmsk1[] = {1,2,4,010,020,040,0100,0200,0400,01000,02000,04000,010000,
        			020000,040000,0100000};
VOID
inf18(VOID)
/************************************************************************/
/*									*/
/*					     |   EFFECTIVE ADDRESS   |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x | x | x |   MODE    |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |			     REGISTER LIST MASK			     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		MOVEM							*/
/*									*/
/************************************************************************/
{
    REG WORD rlm; 


    rlm = *(short*)sdot;
    sdot += 2;
    dotinc += 2;

    if (instr & 0x0400) {		/* test for mem->reg xfer */
        prtop( (instr & 077), WORDSZ);
        putchar(',');
        putrlist(regmsk1,rlm);
    }
    else {				/* must be reg->mem */
        if ( (instr & 070) == 040 )
            putrlist(regmsk0,rlm);	/* predec */
        else
            putrlist(regmsk1,rlm);

        putchar(',');
        prtop( (instr & 077), WORDSZ);
    }
}


VOID
inf19(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | DATA REG  |  OP-MODE  | x | x | x | ADDR REG  |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |				DISPLACEMENT			     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		MOVEP							*/
/*									*/
/************************************************************************/
{
    REG WORD i;
    REG WORD j;
 

    i = instr & 0x0180;			/* Get transfer direction	*/

    if(i == 0x0180) {			/* This is register to memory	*/
        prtreg((instr & 0x0E00) >> 9);
        putchar(',');
    }

    j = *(short*)sdot;
    hexwzs(j);				/* print the displacement	*/
    pari(instr & 7);			/* and the Address register	*/

    if(i == 0x0100) {			/* This is memory to register	*/
        putchar(',');
        prtreg( (instr & 0x0E00) >> 9);
    }

    sdot += 2;
    dotinc += 2;
}


VOID
inf20(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x |  REGISTER | x |		DATA		     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		MOVEQ							*/
/*									*/
/************************************************************************/
{

    stout("#$");
    hexbzs((BYTE)(instr & 0x00FF));
    putchar(',');

    prtreg((instr & 0x0E00) >> 9);
}


VOID
inf21(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   |				IMMEDIATE DATA			     |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		STOP, RTD(68010)					*/
/*									*/
/************************************************************************/
{

    primm(WORDSZ);
}


VOID
inf22(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x | x | x | x | x | x |  REGISTER |  */
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*									*/
/*	Covers the following instructions:				*/
/*		SWAP, UNLK						*/
/*									*/
/************************************************************************/
{

    prtreg(instr & 0x000F);
}


VOID
inf23(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*   | x | x | x | x | x | x | x | x | x | x | x | x |   VECTOR	     |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*									*/
/*	Covers the following instructions:				*/
/*		TRAP							*/
/*									*/
/************************************************************************/
{
    stout("#$");
    hexbzs((BYTE)(instr & 0x000F));
}


VOID
inf24(VOID)
/************************************************************************/
/*									*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+  */
/*   | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | DR|	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*   |A/D|  REGISTER |		Control Register		     |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*									*/
/*	Covers the following instructions:				*/
/*		MOVEC (68010)						*/
/*									*/
/************************************************************************/
{
    REG WORD creg;
    REG WORD rreg;
    REG WORD i;


    i = *(short*)sdot;
    sdot += 2;
    dotinc += 2;

    creg = i & 0x0FFF;			/* get Control Register then	*/
    rreg = ( (i & 0xF000) >> 12) & 0x000F;	/* the A/D register	*/

    if (instr & 1) {			/* This is register to Creg	*/
        prtreg(rreg);
        putchar(',');
    }

    switch (creg) {			/* display Control Register	*/
    case 0:
        stout("SFC");
        break;
    case 1:
        stout("DFC");
        break;
    case 0x0800:
        stout("USP");
        break;
    case 0x0801:
        stout("VBR");
        break;
    default:
        stout("illegal Control Register");
        break;
    }

    if ( !(instr & 1)) {		/* this is Creg to register	*/
        putchar(',');
        prtreg(rreg);
    }
}


VOID
inf25(VOID)
/************************************************************************/
/*									*/
/*					     |   EFFECTIVE ADDRESS   |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*   | x | x | x | x | x | x | x | x |  SIZE |    MODE   |  REGISTER |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*   |A/D|  REGISTER | x | x | x | x | x | x | x | x | x | x | x | x |	*/
/*   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+	*/
/*									*/
/*	Covers the following instructions:				*/
/*		MOVES(68010)						*/
/*									*/
/************************************************************************/
{
    REG WORD rreg;
    REG WORD size;
    REG WORD i;


    size = instr & 0x00C0;		/* get the size			*/

    i = *(short*)sdot;
    sdot += 2;
    dotinc += 2;

    rreg = ((i & 0xF000) >> 12) & 0x000F; /* get the general register	*/

    if (i & 0x0800) {			/* This is register to <ea>	*/
        prtreg(rreg);
        putchar(',');
    }

    prtop( (instr & 077),size);		/* print the effecive address	*/

    if ( !(instr & 0x800)) {		/* this is <ea> to register	*/
        putchar(',');
        prtreg(rreg);
    }

}


VOID putrlist(CONST WORD *ap, WORD mask)
/************************************************************************/
/*									*/
/*			PUT Register LIST				*/
/*									*/
/************************************************************************/
{
    REG WORD i;
    REG CONST WORD *p;
    REG WORD lmsk;
    REG WORD j;
 

    lmsk = mask;
    p = ap;
    j = -1;

    for(i = 0; i < 16; i++) {

        if(lmsk & *p++) {


            if(j == 0)
        	putchar('/');

            if(j != 1) {
        	prtreg(i);
        	putchar('-');
            }

            j = 1;
        }
        else if(j == 1) {
            prtreg(i - 1);
            j = 0;
        }

    }

    if(j == 1)
        stout("A7");
}


VOID pdr(WORD r)
/************************************************************************/
/*									*/
/*		Print Data Register					*/
/*									*/
/************************************************************************/
{

    putchar('D');
    putchar(hexchar(r));

}


VOID par(WORD r)
/************************************************************************/
/*									*/
/*	Print Address Register						*/
/*									*/
/************************************************************************/
{
         if (r == 7)	stout("SP");
         else {
            putchar('A');
   	 putchar(hexchar(r));
         }
}


VOID pdri(WORD r)
/************************************************************************/
/*									*/
/*	Print Data Register Inderect					*/
/*									*/
/************************************************************************/
{
    putchar('(');
    pdr(r);
    putchar(')');
}


VOID pari(WORD r)
/************************************************************************/
/*									*/
/*	Print Address Register Indirect					*/
/*									*/
/************************************************************************/
{

    putchar('(');
    par(r);
    putchar(')');
}


VOID paripd(WORD r)
/************************************************************************/
/*									*/
/*	Print Address Register Indirect PreDecrement			*/
/*									*/
/************************************************************************/
{

    putchar('-');
    pari(r);
}


VOID paripi(WORD r)
/************************************************************************/
/*									*/
/*	Print Address Register Indirect Post Increment			*/
/*									*/
/************************************************************************/
{
    pari(r);
    putchar('+');
}


VOID hexlzs(LONG n)
/************************************************************************/
/*									*/
/*			write a long integer in hex			*/
/*									*/
/************************************************************************/
{
#if NEW_STUFF
    EXTERN LONG inhalt;
    EXTERN BYTE ref;


    inhalt = n;
    ref = 'm';				/* Let ref => possible symbol */
#endif

    puthex(n,32,1);
}



VOID hexwzs(WORD n)
/************************************************************************/
/*									*/
/*			write an integer in hex				*/
/*									*/
/************************************************************************/
{

    puthex((LONG)n, 16, 1);
}



VOID hexbzs(BYTE n)
/************************************************************************/
/*									*/
/*			write a byte as a hex integer			*/
/*									*/
/************************************************************************/
{
    puthex((LONG)n, 8, 1);
}


VOID badsize(VOID)
/************************************************************************/
/*									*/
/*			The SIZE field is wrong				*/
/*									*/
/************************************************************************/
{

    stout("\n** illegal size field **\n");
}


VOID prtreg(WORD areg)
/************************************************************************/
/*									*/
/*	Print the register specified in AREG				*/
/*									*/
/************************************************************************/
{
    REG WORD reg;
 

    reg = areg;
    if(reg > 7) {
        par(reg - 8);
    }
    else {
        pdr(reg);
    }
}



VOID prdisp(VOID)
/************************************************************************/
/*									*/
/*			PRint DISPlacement				*/
/*									*/
/************************************************************************/
{
    REG WORD i;


    i = *(short*)sdot;
    sdot += 2;
    dotinc += 2;
    putchar('$');
    hexwzs(i);
}


VOID prindex(WORD areg)
/************************************************************************/
/*									*/
/*		Address Register Indirect With Index			*/
/*									*/
/************************************************************************/
{
    REG WORD i;

#if M68000 < 68020 
/* DEBUG */
//			cprintf("prindex:  68000 code\n");

    i = *(short*)sdot;
    sdot += 2;
    dotinc += 2;

    putchar('$');
    hexbzs((BYTE)(i & 0x00FF));

    putchar('(');

    if(areg == PC)
        stout("PC,");
    else {
        par(areg);
        putchar(',');
    }

    prtreg( (i >> 12) & 0x000F);

    if( i & 0x0800)
        stout(".l");

    putchar(')');

#else
	 UWORD scale, bs, bd_size, is, iis, comma;
	 LONG bd, od;

/* all of the 68020 addressing is below here */
/* DEBUG */
//		cprintf("prindex:  %d code\n", M68000);

	 od = bd = 0; 

    i = *(short*)sdot;
    sdot += 2;
    dotinc += 2;

	 scale = (i >> 9) & 3;
	 if (i & 0x100) {			/* test bit 8 for 68020 Full Format */
		  bs = (i >> 7) & 1;
		  bd_size = (i >> 4) & 3;
		  is = (i >> 6) & 1;
		  iis = (i & 7);
		  if (bd_size > 1) {
		  		 bd = *(short*)sdot;
				 sdot += 2;
				 dotinc += 2;
		  }
		  if (bd_size > 2) {
		  		 bd <<= 16;
		  		 bd += *(UWORD*)sdot;
				 sdot += 2;
				 dotinc += 2;
		  }
		  if ((iis & 3) > 1) {
		  		 od = *(short*)sdot;
				 sdot += 2;
				 dotinc += 2;
		  }
		  if ((iis & 3) > 2) {
		  		 od <<= 16;
		  		 od += *(UWORD*)sdot;
				 sdot += 2;
				 dotinc += 2;
		  }
	 } else {
		  bs = bd_size = is = iis = 0;
		  bd = (BYTE)(i & 0xFF);
	 }

	 comma = 0;
	 putchar('(');
	 if (iis) putchar('[');
	 if (bd_size != 1) {
		  putchar('$');
		  switch(bd_size) {
		  case 0:  hexbzs((BYTE)bd); break;
		  case 2:  hexwzs((WORD)bd); break;
		  case 3:  hexlzs((LONG)bd); break;
		  }
		  comma = 1;
	 }
	 if (!bs) {
		  if (comma) putchar(',');
		  if (areg == PC)  stout("PC");
		  else par(areg);
		  comma = 1;
	 }
	 if (iis>4) {
		  putchar(']');
		  comma = 1;
	 }
	 if (!is) {
		  if (comma) putchar(',');
		  prtreg( (i>>12) & 0x0F );
		  if (i & 0x800) /* stout(".l") */ ;	/* omit the ".l" suffix */
		  else stout(".w");
		  if (scale) {
				putchar('*');
				putchar(hexchar(1<<scale));
		  }
		  comma = 1;
	 }
	 if (iis && iis<4) {
		  putchar(']');
		  comma = 1;
	 }
#if 0
	 if (iis>4) {
		  putchar(',');
		  prtreg( (i>>12) & 0x0F );
		  if (i & 0x800) stout(".l");
		  else stout(".w");
		  if (scale) {
				putchar('*');
				putchar(hexchar(1<<scale));
		  }
		  comma = 1;
	 }
#endif
	 if ( iis & 2 ) {
		  if (comma) putchar(',');
	     putchar('$');
	     if ( iis & 1 ) hexlzs((LONG)od);
		  else   hexwzs((WORD)od);
	 }
	 putchar(')');

#endif
}



VOID primm(WORD asize)
/************************************************************************/
/*									*/
/*			Print out Immediate value 			*/
/*									*/
/************************************************************************/
{
    LONG l1;
 

    l1 = 0;				/* initialize for safety	*/

    if (asize == LONGSZ) {		/* Determine whether it is a 	*/
        	l1 = *(short*) sdot;		/* LONG immediate value.  Get	*/
        	l1 <<= 16;
        	sdot += 2;			/* value and bump pointers if so*/
        	dotinc += 2;
    }

    l1 |= *(UWORD*)sdot;		/* get loword value if LONG else*/
    sdot += 2;				/* default to WORD or BYTE	*/
    dotinc += 2;

    stout("#$");			/* print out immediate value in	*/
         hexlzs(l1);				/* hex notation.		*/
}


VOID
prtop(WORD adrtype, WORD asize)
/************************************************************************/
/*									*/
/*		Print the Effective Address				*/
/*									*/
/************************************************************************/
{
    REG WORD reg;
    REG WORD mode;
//    REG WORD defer;
    LONG la;
    REG LONG p;
 

    mode = (adrtype & 070) >> 3;
    reg = adrtype & 7;

/* DEBUG */
//	cprintf("\nmode=%hd, reg=%hd\n", mode, reg);
/* DEBUG */

    switch (mode) {
    case 0:				/* D reg direct */
        pdr(reg);
        break;

    case 1:				/* A reg direct */
        par(reg);
        break;

    case 2:				/* A indirect */
        pari(reg);
        break;

    case 3:				/* A+ */
        paripi(reg);
        break;

    case 4:				/* -(An) */
        paripd(reg);
        break;


    case 5:				/* d(an) */
        prdisp();
        pari(reg);
        break;

    case 6:				/* d(An,Ri) */
        prindex(reg);
        break;

    case 7:
        la = 0;

        switch(reg) {
        case 0:				/* xxx.W */
            p = *(short*)sdot;

            if(p & 0x8000)
        	p |= 0xFFFF0000;	/* sign extend like hard */

            sdot += 2;
            dotinc += 2;

            hexlzs(p);

            break;

        case 1:				/* xxx.L */
            la = *(short*)sdot;
        	 la <<= 16;
            sdot += 2;
            dotinc += 2;

            la += *(UWORD*)sdot;
            sdot += 2;
            dotinc += 2;

            putchar('$');
            hexlzs(la);

            break;

        case 2:				/* d(PC) */
            prdisp();
            stout("(PC)");
            break;

        case 3:				/* d(PC,Ri) */
            prindex(PC);
            break;

        case 4:
            primm(asize);
            break;
        }
        break;

    }

}
