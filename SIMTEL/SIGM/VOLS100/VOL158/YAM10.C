/*
>> yam10.c 12-20-82
 * File unsqueezer module from Richard Greenlaw's USQ
 *  and other vital functions
*/
#define EXTERN
#include "yamc86.h"

#ifdef XMODEM
#define CICHAR BCICHAR
#define CIREADY BCIREADY
#endif

/* *** Stuff for first translation module *** */
#define USDLE 0x90
/* *** Stuff for second translation module *** */
#define SPEOF 256	/* special endfile token */
#define LARGE 30000
int bpos;	/* last bit position read */
int curin;	/* last byte value read */
/* Variables associated with repetition decoding */
int repct;	/*Number of times to return value*/
int value;	/*current byte value or EOF */

unsqueeze()
{
	int i, c;
	int numnodes;		/* size of decoding tree */

	/* Initialization */
	init_cr();
	init_huff();

	/* Process rest of header (SQMAGIC already read) */
	getw(fin);	/* ignore checksum ... */

	/* List current and original file names */
	fprintf(stderr, "%s -> ", Tname);
	while(c = getc(fin))
		putc(c, stderr);
	putc('\n', stderr);

	numnodes = getw(fin);
	if(numnodes < 0 || numnodes >= NUMVALS) {
		printf(stderr, "%s has invalid decode tree size\n", Tname);
		return ERROR;
	}

	/* Initialize for possible empty tree (SPEOF only) */
	Utility.dnode[0].children[0] = -(SPEOF + 1);
	Utility.dnode[0].children[1] = -(SPEOF + 1);

	/* Get decoding tree from file */
	for(i = 0; i < numnodes; ++i) {
		Utility.dnode[i].children[0] = getw(fin);
		Utility.dnode[i].children[1] = getw(fin);
	}

	while((c = getcr()) != CPMEOF) {
		if( !(c=putcty(c)))
			continue;
		if(c==003 || c==CAN || c==013) {
			return c;
		}
	}
	return CPMEOF;
}


/* initialize decoding functions */

init_cr()
{
	repct = 0;
}

init_huff()
{
	bpos = 99;	/* force initial read */
}

/* Get bytes with decoding - this decodes repetition,
 * calls getuhuff to decode file stream into byte
 * level code with only repetition encoding.
 *
 * The code is simple passing through of bytes except
 * that USDLE is encoded as USDLE-zero and other values
 * repeated more than twice are encoded as value-USDLE-count.
 */

int
getcr()
{
	int c;

	if(repct > 0) {
		/* Expanding a repeated char */
		--repct;
		return value;
	} else {
		/* Nothing unusual */
		if((c = getuhuff()) != USDLE) {
			/* It's not the special delimiter */
			value = c;
			if(value == CPMEOF)
				repct = LARGE;
			return value;
		} else {
			/* Special token */
			if((repct = getuhuff()) == 0)
				/* USDLE, zero represents USDLE */
				return USDLE;
			else {
				/* Begin expanding repetition */
				repct -= 2;	/* 2nd time */
				return value;
			}
		}
	}
}

/* Decode file stream into a byte level code with only
 * repetition encoding remaining.
 */

int
getuhuff()
{
	int i;

	/* Follow bit stream in tree to a leaf*/
	i = 0;	/* Start at root of tree */
	do {
		if(++bpos > 7) {
			if((curin = getc(fin)) == ERROR)
				return ERROR;
			bpos = 0;
			/* move a level deeper in tree */
			i = Utility.dnode[i].children[1 & curin];
		} else
			i = Utility.dnode[i].children[1 & (curin >>= 1)];
	} while(i >= 0);

	/* Decode fake node index to original data value */
	i = -(i + 1);
	/* Decode special endfile token to normal EOF */
	i = (i == SPEOF) ? CPMEOF : i;
	return i;
}

char putcty(c)
char c;
{
#ifdef RXNONO
	if(index(c, RXNONO))
		return 0;
#endif
	if(UsePutchar)
		putchar(c);
	else {
#ifdef BTTYOUT
		BTTYOUT(c);
#else
#ifdef COREADY
		while (!COREADY)
			;
#endif
		TTYOUT(c);
#endif
	}
	if(CIREADY) {
		if((c=(CICHAR&KBMASK))==XOFF) {
			if((c=getcty())==003 || c==CAN || c==013)
				return c;
		} else
			return c;
	}
	return FALSE;
}

char getcty()
{
	while (!CIREADY)
		;
	return (CICHAR&KBMASK);
}

listfile(name)
char *name;
{
	int c;

	closetx(TRUE);
#ifndef XMODEM
	putcty('\f');		/* line printer form-feed if ^P */
#endif
	if(opentx(name)==ERROR)
		return ERROR;
#ifdef XMODEM
	sendline(022);		/* bracket with ^R and ^T for squelch */
#endif
#ifdef USQ
	if((c=getw(fin))==SQMAGIC)
		c=unsqueeze();
	else if(c != ERROR) {
		putcty(c); putcty(c>>8);	/* pdp-11 sequence */
#else
	else {
#endif
		while((c=getc(fin))!=EOF && c != CPMEOF) {
			if( !(c=putcty(c)))
				continue;
			if(c==003 || c==CAN || c==013) {
				break;
			}
		}
	}
	if(c != CPMEOF)
		putchar('\n');
	/* record complete xmsn iff terminated by (CPM)EOF */
	closetx(c != CPMEOF);
#ifdef XMODEM
	sendline(024);	/* squelch in case user downloading */
#endif		
	/* cancel rest of files if ^C or ^X */
	if(c==003 || c==CAN)
		return ERROR;
	else
		return OK;
}

/* fill buf with count chars padding with ^Z for CPM */
filbuf(buf, count)
char *buf;
{
	register c, m;
	m=count;
	while((c=getc(fin))!=EOF) {
		*buf++ =c;
		if(--m == 0)
			break;
	}
	if(m==count)
		return 0;
	else
		while(--m>=0)
			*buf++ = 032;
	return count;
}


cmdeq(s,p)
char *s, *p;
{
	while(*p)
		if(*s++ != *p++)
			return 0;
	return 1;
}

/* local tell-it-like-it-is string write function with no kbd check */
lputs(s)
char *s;
{
	while(*s) {
#ifdef COREADY
		while (!COREADY)
			;
#endif
		TTYOUT(*s++);
	}
}
