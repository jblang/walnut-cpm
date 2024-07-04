#include "ed.h"
#include "cclass.h"

char cclass[128] =
{	/* character classes. */
	0,	/* ^@ */
	0,	/* ^A */
	0,	/* ^B */
	0,	/* ^C */
	0,	/* ^D */
	0,	/* ^E */
	0,	/* ^F */
	0,	/* ^G */
	0,	/* ^H */
	(c_TAB|c_WHITE),	/* ^I */
	0,	/* ^J */
	0,	/* ^K */
	0,	/* ^L */
	0,	/* ^M */
	0,	/* ^N */
	0,	/* ^O */
	0,	/* ^P */
	0,	/* ^Q */
	0,	/* ^R */
	0,	/* ^S */
	0,	/* ^T */
	0,	/* ^U */
	0,	/* ^V */
	0,	/* ^W */
	0,	/* ^X */
	0,	/* ^Y */
	0,	/* ^Z */
	0,	/* ^[ */
	0,	/* ^\ */
	0,	/* ^] */
	0,	/* ^^ */
	0,	/* ^_ */
	(c_SIMPLE|c_WHITE),	/* blank */
	c_SIMPLE,	/* ! */
	c_SIMPLE,	/* " */
	c_SIMPLE,	/* # */
	c_SIMPLE,	/* $ */
	c_SIMPLE,	/* % */
	c_SIMPLE,	/* & */
	c_SIMPLE,	/* ' */
	(c_FENCE|c_SIMPLE),	/* ( */
	(c_FENCE|c_SIMPLE),	/* ) */
	c_SIMPLE,	/* * */
	c_SIMPLE,	/* + */
	c_SIMPLE,	/* , */
	c_SIMPLE,	/* - */
	c_SIMPLE,	/* . */
	c_SIMPLE,	/* / */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 0 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 1 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 2 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 3 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 4 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 5 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 6 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 7 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 8 */
	(c_CWORD|c_DIGIT|c_SIMPLE),	/* 9 */
	c_SIMPLE,	/* : */
	c_SIMPLE,	/* ; */
	c_SIMPLE,	/* < */
	c_SIMPLE,	/* = */
	c_SIMPLE,	/* > */
	c_SIMPLE,	/* ? */
	c_SIMPLE,	/* @ */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* A */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* B */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* C */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* D */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* E */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* F */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* G */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* H */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* I */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* J */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* K */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* L */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* M */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* N */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* O */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* P */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* Q */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* R */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* S */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* T */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* U */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* V */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* W */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* X */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* Y */
	(c_CWORD|c_ALPHA|c_SIMPLE),	/* Z */
	(c_FENCE|c_SIMPLE),	/* [ */
	c_SIMPLE,	/* \ */
	(c_FENCE|c_SIMPLE),	/* ] */
	c_SIMPLE,	/* ^ */
	(c_CWORD|c_SIMPLE),	/* _ */
	c_SIMPLE,	/* ` */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* a */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* b */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* c */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* d */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* e */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* f */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* g */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* h */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* i */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* j */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* k */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* l */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* m */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* n */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* o */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* p */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* q */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* r */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* s */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* t */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* u */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* v */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* w */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* x */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* y */
	(c_CWORD|c_ALPHA|c_LOWC|c_SIMPLE),	/* z */
	(c_FENCE|c_SIMPLE),	/* { */
	c_SIMPLE,	/* | */
	(c_FENCE|c_SIMPLE),	/* } */
	c_SIMPLE,	/* ~ */
	0	/* ^? */
};

isinsert( CcharC )
{	if ( CcharC > 0x80 ) return( 0 );
	return( cclass[ CcharC ] & c_SIMPLE );
}
#ifdef NEVER
isupper( c )
int c;
{	/* if ( c > 0x80 ) return( 0 ); */
	return ( ( cclass[c] & ( c_ALPHA | c_LOWC )) == c_ALPHA );
}
#endif
islower( c )
int c;
{	if ( c > 0x80 ) return ( 0 );
	return ( ( cclass[c] &c_LOWC ));
}

int wstyle;

inword()
{	register int c;
	if (curwp->w_doto == llength(curwp->w_dotp))
		return (FALSE);
	c = cclass[ lgetc( curwp->w_dotp, curwp->w_doto )];
	if ( wstyle &1 ) return ( ( c & ( c_SIMPLE | c_WHITE )) == c_SIMPLE );
	return ( c & c_CWORD );
}

