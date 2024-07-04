/* Screen editor:  non-user defined globals
 *
 * Source:  ed1.h
 * Version: May 15, 1980.
 */


/* Define global constants */

/* Define constants describing a text line */

#define MAXLEN	133	/* max chars per line */
#define MAXLEN1	134	/* MAXLEN + 1 */

/* Define operating system constants */

#define SYSFNMAX 15	/* CP/M file name length + 1 */

/* Define misc. constants */

#define EOS	0	/* code sometimes assumes \0 */
#define ERR	-1	/* must be same as ERROR */
#define YES	1	/* must be nonzero */
#define NO	0
#define CR	13	/* carriage return */
#define LF	10	/* line feed */
#define TAB	9	/* tab character */
#define HUGE	32000	/* practical infinity */

#define OK	1
#define EOF	-1

/*
Screen editor:  special key definitions
This file was created by the configuration program:
Version 2:  September 6, 1981.
*/

/*
Define which keys are used for special edit functions.
*/

#define UP1 21
#define DOWN1 13
#define UP2 11
#define DOWN2 10
#define LEFT1 8
#define RIGHT1 12
#define INS1 14
#define EDIT1 5
#define ESC1 27
#define DEL1 127
#define ZAP1 26
#define ABT1 24
#define SPLT1 19
#define JOIN1 16

/*
Define length and width of screen and printer.
*/

#define SCRNW 80
#define SCRNW1 79
#define SCRNL 24
#define SCRNL1 23
#define SCRNL2 22
#define LISTW 80
/*
 * Screen editor:  external definitions
 *
 * Version: August 8, 1982.
 *
 */

#ifndef EXTERN
#define EXTERN extern
#endif

/* define flag for startup of editor -- ed2.c */

EXTERN int	startup;	/* flag for editor startup */
EXTERN int	argcount;	/* global argc */
EXTERN char	sname[SYSFNMAX]; /* command line filename */

/* define statics for the command module -- ed3.c */

EXTERN char filename[SYSFNMAX];	/* file name for (re)save */

/* define statics for the window module -- ed4.c */

EXTERN char	editbuf[MAXLEN]; /* the edit buffer */
EXTERN int	editp;		/* cursor: buffer index */
EXTERN int	editpmax;	/* length of buffer */
EXTERN int	edcflag;	/* buffer change flag */

/* define statics for the format module -- ed5.c */

EXTERN int fmttab;		/* max length of tab character */
EXTERN int fmtdev;		/* device -- YES/NO = LIST/CONSOLE */
EXTERN int fmtwidth;		/* devide width.  LISTW/SCRNW1 */

/* fmtcol[i] is the first column at which buf[i] is printed.
 * fmtsub() and fmtlen() assume fmtcol[] is valid on entry.
 */

EXTERN int fmtcol[MAXLEN1];

/* define statics for the terminal module -- ed6.c */

EXTERN int outx, outy;		/* coordinates of the cursor */

/* define statics for the prompt line module -- ed7.c */

EXTERN char pmtln[MAXLEN];	/* mode */
EXTERN char pmtfn[SYSFNMAX];	/* file name */

/* define statics for the operating system module -- ed8.c */

EXTERN int  iormode;		/* 'r' if file is read mode */

/* define statics for the buffer module -- ed10.c */

/*
 * buffer[] must be the last external variable and it must
 * have a nonzero dimension.
 */

EXTERN int bufcflag;		/* main buffer changed flag */
EXTERN char *bufp;		/* start of current line */
EXTERN char *bufpmax;		/* end of last line */
EXTERN char *buffer;		/* start of buffer */
EXTERN char *bufend;		/* last byte of buffer */
EXTERN int bufline;		/* current line number */
EXTERN int bufmaxln;		/* number of lines in buffer */
