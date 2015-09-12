/*****************************************************************************
*
*	    C P / M   C   R U N   T I M E   L I B   H E A D E R   F I L E
*	    -------------------------------------------------------------
*	Copyright 1982 by Digital Research Inc.  All rights reserved.
*
*	This is an include file for assisting the user to write portable
*	programs for C.
*
*****************************************************************************/
#ifndef _PORTAB_H
#define _PORTAB_H

#define ALCYON 0				/* NOT using Alcyon compiler   */
#define GCC		1

/*
 *	Standard type definitions
 */
						/***************************/
#define	BYTE	signed char				/* Signed byte		   */
#define  BOOLEAN	char				/* 2 valued (true/false)   */
#define	WORD	short	int			/* Signed word (16 bits)   */
#define	UWORD	unsigned short int	/*** unsigned word	   */
#define	LONG	long				/* signed long (32 bits)   */
#define	ULONG	unsigned long			/* Unsigned long	   */
#define	REG	register			/* register variable	   */
#define	LOCAL	auto				/* Local var on 68000	   */
#define	EXTERN	extern				/* External variable	   */
#define	MLOCAL	static				/* Local to module	   */
#define	GLOBAL	/**/				/* Global variable	   */
#define	DEFAULT	int				/* Default size		   */
#define  CONST		const			/* constant */
						/***************************/
#if ALCYON
#define UBYTE	char
#define	VOID	/**/				/* Void function return	   */
#else
#define	UBYTE	unsigned char			/* Unsigned byte	   */
#define VOID	void
#endif



/****************************************************************************/
/*	Miscellaneous Definitions:					    */
/****************************************************************************/
#define	FAILURE	(-1)			/*	Function failure return val */
#define  SUCCESS	0  			/*	Function success return val */
#define	YES	1			/*	"TRUE"			    */
#define	NO	0			/*	"FALSE"			    */
#define	FOREVER	for(;;)			/*	Infinite loop declaration   */
#ifndef NULL
#define	NULL	0			/*	Null pointer value	    */
#endif
#define	ZERO	0			/ *	Zero value		    */
#define	EOF	(-1)			/*	EOF Value		    */
#define	TRUE	 1			/*	Function TRUE  value	    */
#define	FALSE	 0			/*	Function FALSE value	    */

/*************************** end of portab.h ********************************/

#if ALCYON
/**** included from  DDT/STDIO.H ***********/
#define isalpha(c) (islower(c)||isupper(c))     /* true if "c" a letter     */
#define isdigit(c) ('0' <= (c) && (c) <= '9')   /* Ascii only!!             */
#define iswhite(c) ((c) <= 040 || 0177<= (c))   /* Is control / funny char  */
#define iswild(c)  ((c) == '*' || (c) == '?')	/* true if a wildcard char  */
/**/
#define islower(c) ('a' <= (c) && (c) <= 'z')   /* Ascii only!!             */
#define isupper(c) ('A' <= (c) && (c) <= 'Z')   /* Ascii only!!             */
/**/
#define tolower(c) (isupper(c) ? ((c)+040):(c)) /* translate to lower case  */
#define toupper(c) (islower(c) ? ((c)-040):(c)) /* translate to upper case  */
/**/
#define abs(x)     ((x) < 0 ? -(x) : (x))       /* Absolute value function  */
#define max(x,y)   (((x) > (y)) ? (x) :  (y))   /* Max function             */
#define min(x,y)   (((x) < (y)) ? (x) :  (y))   /* Min function             */
/**/
/**** above are included from  DDT/STDIO.H ***********/
#else		// !ALCYON
#include "ctype.h"
#endif	// ALCYON
#endif  // _PORTAB_H
