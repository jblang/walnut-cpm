#include "metab.h"

int ovreq;
int ovsub;
int ovreq2;
int ovsub2;
FILE * ffp;

main()
{
/*	static int	c;*/
#define cmdchar (*(int *)0x100)
#define cmdflag (*(int *)0x102)
#define cmdparm (*(int *)0x104)
/*	static int	f; */
/*	static int	n; */
/*	static int	mflag; */
#define mflag (*(int *)0x106)

	settop( 0x700 );
	myovinit( "meov" );

	/*ovreq = 0;*/
	ovloader( 0 ); /* , argc, argv[1] ); * initialize. */
	while ( ovreq )
	{	cmdchar = ovreq;
		ovreq = 0;
		if ( ovloader( cmdchar, ovsub ) != TRUE ) break;
	}


loop:

	update();				/* Fix up the screen	*/

	cmdchar = getkey();

	if (mpresf != FALSE)
	{	mlerase();
		update();
		/*if (c == ' ') goto loop; ** ITS EMACS does this */
	}
	cmdflag = FALSE;
	cmdparm = 1;
	if ( cmdchar == CMINUSCH )
	{	cmdflag = TRUE;
		goto negparm;
#ifdef NEVER
		cmdparm = 0;
		mflag = -1;
		goto argloop;
#endif
	}
	if (cmdchar == (0x1f&'U')) 
	{	/* ^U, start argument	*/
		cmdflag = TRUE;
		cmdparm = 4;			/* with argument of 4 */
		mflag = 0;			/* that can be discarded. */
argloop:
		for ( ;; )
		{	mlwrite( "Arg: %d", ( mflag >= 0 ) 
			? cmdparm : ( cmdparm ? -cmdparm : -1));
			
			if ( ( cmdchar = getkey()) == (0x1f&'U'))
				cmdparm <<= 2;
			else if ( cmdchar == '-' )
			{	if ( mflag ) break; /* insert n dashes */
negparm:
				cmdparm = 0;
				mflag = -1;
			}
			else if ( cmdchar >= '0' && cmdchar <= '9' )
			{	if ( ! mflag )	/* 1st digit */
				{	cmdparm = 0;
					mflag = 1;
				}
				cmdparm = 10 * cmdparm + cmdchar - '0';
			}
			else break;
		}
		/*
		 * Make arguments preceded by a minus sign negative and change
		 * the special argument "^U -" to an effective "^U -1".
		 */
		if (mflag == -1)
		{	if ( ! cmdparm ) cmdparm++;
			cmdparm = -cmdparm;
		}
	}
	if (cmdchar == (0x1f&'X'))	/* ^X is a prefix	*/
		cmdchar = CTLX | getstroke();
	ovreq = ovreq2 = 0;
	execute( );			/* Do it.		*/
	while ( ovreq )
	{	cmdchar = ovreq;
		ovreq = 0;
		if ( ovloader( cmdchar, ovsub ) != TRUE ) break;
	}
	goto loop;
}
