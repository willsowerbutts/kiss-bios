#ifndef _CTYPE_H
#define _CTYPE_H

#define isalpha(c) (islower(c)||isupper(c))     /* true if "c" a letter     */
#define isdigit(c) ('0' <= (c) && (c) <= '9')   /* Ascii only!!             */
#define isspace(c) ((c) == ' ' || ((c) >= 9 && (c) <= 13)) /* whitespace    */
#define iswild(c)  ((c) == '*' || (c) == '?')	/* true if a wildcard char  */

#define islower(c) ('a' <= (c) && (c) <= 'z')   /* Ascii only!!             */
#define isupper(c) ('A' <= (c) && (c) <= 'Z')   /* Ascii only!!             */

#define tolower(c) (isupper(c) ? ((c)+040):(c)) /* translate to lower case  */
#define toupper(c) (islower(c) ? ((c)-040):(c)) /* translate to upper case  */

#define abs(x)     ((x) < 0 ? -(x) : (x))       /* Absolute value function  */
#define max(x,y)   (((x) > (y)) ? (x) :  (y))   /* Max function             */
#define min(x,y)   (((x) < (y)) ? (x) :  (y))   /* Min function             */

#define iswhite(c) ((c) <= 040 || 0177<= (c))   /* Is control / funny char  */
#define isalnum(c) (isalpha(c) || isdigit(c))

#endif
