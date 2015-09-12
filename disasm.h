/* disasm.h -- ANSI-C definitions of procedures */
#ifndef _DISASM_H
#define _DISASM_H 1

/* beginning of original DISAS.H */
/*
        Copyright 1981
        Alcyon Corporation
        8474 Commerce Av.
        San Diego, Ca.  92121
*/
#define NUMSS 1 /*number of special symbols*/
//#define SSRG    0       /*max symbol offset to display symbolically*/
 
//#define LSTENT 12
//struct symtab {
//        char syname[8];
//        char *syval;
//};
 
 
//char *symbuf;   /*start of symbol table*/
//char *esymbuf;  /*end of symbol table*/
//int  *symptr;
//int     errflg;
/*  the following definitions must not be changed -- esp. the order */
//int     symlen;
//int     symct;
//char    ssymbol[8];
//int     ssymflg;
//char  *ssymval;
/* end of order dependant declarations */

/****  make the next 3 'static' to disasm.c ****/
//char *dot;
//int     dotinc;
//char    *sdot;          /* symbolic operand temporary dot */


//char *tdot;
//int textsym;
 
 
//#define TEXTS 01000
//#define DATAS 02000
//#define BSSS  0400
//#define ABSS  03400
 
//char tsym[10];
//char fsymbol[10];
//int seffadr, sefaflg;   /* effective address search variables */
 
 
//int ssval[NUMSS];               /* special symbol values */
WORD instr;              /* holds instruction first word */
 
#define BYTESZ 0
#define WORDSZ 1
#define LONGSZ 2
 

/* flags for symbols */
//# define SYDF   0100000         /* defined */
//# define SYEQ   0040000         /* equated */
//# define SYGL   0020000         /* global - entry or external */
//# define SYER   0010000         /* equated register */
//# define SYXR   0004000         /* external reference */
//# define SYDA   0002000         /* DATA based relocatable */
//# define SYTX   0001000         /* TEXT based relocatable */
//# define SYBS   0000400         /* BSS based relocatable */
 
 
#define AREG0   8
#define PC              16
 
//char lbuf[40];
/* end of original DISAS.H */


// VOID pinstr(VOID);
int pinstr(long ip);

VOID noin(VOID);
VOID inf1(VOID);
VOID inf2(VOID);
VOID inf3(VOID);
VOID inf4(VOID);
VOID inf5(VOID);
VOID inf6(VOID);
VOID inf7(VOID);
VOID inf8(VOID);
VOID inf9(VOID);
VOID inf10(VOID);
VOID inf11(VOID);
VOID inf12(VOID);
VOID inf13(VOID);
VOID inf14(VOID);
VOID inf15(VOID);
VOID inf16(VOID);
VOID inf17(VOID);
VOID inf18(VOID);
VOID inf19(VOID);
VOID inf20(VOID);
VOID inf21(VOID);
VOID inf22(VOID);
VOID inf23(VOID);
VOID inf24(VOID);
VOID inf25(VOID);
VOID putrlist(CONST WORD *ap, WORD mask);
VOID pdr(WORD r);
VOID par(WORD r);
VOID pdri(WORD r);
VOID pari(WORD r);
VOID paripd(WORD r);
VOID paripi(WORD r);
VOID hexlzs(LONG n);
VOID hexwzs(WORD n);
VOID hexbzs(BYTE n);
VOID badsize(VOID);
VOID prtreg(WORD areg);
VOID prdisp(VOID);
VOID prindex(WORD areg);
VOID primm(WORD asize);
VOID prtop(WORD adrtype, WORD asize);

#endif // _DISASM_H
