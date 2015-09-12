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
short instr;              /* holds instruction first short */
 
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


// void pinstr(void);
int pinstr(long ip);

void noin(void);
void inf1(void);
void inf2(void);
void inf3(void);
void inf4(void);
void inf5(void);
void inf6(void);
void inf7(void);
void inf8(void);
void inf9(void);
void inf10(void);
void inf11(void);
void inf12(void);
void inf13(void);
void inf14(void);
void inf15(void);
void inf16(void);
void inf17(void);
void inf18(void);
void inf19(void);
void inf20(void);
void inf21(void);
void inf22(void);
void inf23(void);
void inf24(void);
void inf25(void);
void putrlist(const short *ap, short mask);
void pdr(short r);
void par(short r);
void pdri(short r);
void pari(short r);
void paripd(short r);
void paripi(short r);
void hexlzs(long n);
void hexwzs(short n);
void hexbzs(char n);
void badsize(void);
void prtreg(short areg);
void prdisp(void);
void prindex(short areg);
void primm(short asize);
void prtop(short adrtype, short asize);

#endif // _DISASM_H
