#include "medisp.h"

extern int wstyle;
extern int ovreq, ovsub, ovreq2, ovsub2;

ovmain( x, f, n )
{	switch ( x )
	{	case 0: return ( quit( f, n ));
		case 1: return ( ctrlg());
		case 4:
		case 2: wstyle = ( x > 3 ) + (( n < 0 ) ? 2 : 0 );
			if ( wstyle & 1 )
			{	if ( wstyle & 2 )
					mlwrite( "[vi WORD mode]" );
				else
					mlwrite( "[emacs WORD mode]" );
			}
			else
			{	if ( wstyle & 2 )
					mlwrite( "[vi word mode]" );
				else
					mlwrite( "[emacs word mode]" );
			}
			return( TRUE );
		case 3: return ( quit( FALSE, n ));
	}
}
#ifdef NEVER
/*
 * Fancy quit command, as implemented
 * by Norm. If the current buffer has changed
 * do a write current buffer and exit emacs,
 * otherwise simply exit.
 */
quickexit(f, n)
register int f, n;
{
	if ( ( curbp->b_flag & ( BFCHG | BFTEMP )) == BFTEMP )
	{	/* changed buffer, not [List] */
		ovreq = 9;	/* save */
		ovsub = 0;
		ovreq2 = 30;	/* conditionally quit	*/
		ovsub2 = 3;
	}
	return( TRUE );
}
#endif
/*
 * Quit command. If an argument, always
 * quit. Otherwise confirm if a buffer has been
 * changed and not written out. Normally bound
 * to "C-X C-C".
 */
quit(f, n)
{
	register int	s;

	if (f != FALSE				/* Argument forces it.	*/
	|| anycb() == FALSE			/* All buffers clean.	*/
	|| (s=mlyesno("Quit")) == TRUE)
	{	/* User says it's OK.	*/
		vttidy();
		exit(0);
	}
	return (s);
}

/*
 * Look through the list of
 * buffers. Return TRUE if there
 * are any changed buffers. Buffers
 * that hold magic internal stuff are
 * not considered; who cares if the
 * list of buffer names is hacked.
 * Return FALSE if no buffers
 * have been changed.
 */
anycb()
{
	register BUFFER	*bp;

	bp = bheadp;
	while (bp != NULL)
	{	if ( ( bp->b_flag & ( BFTEMP | BFCHG )) == BFCHG )
			return (TRUE);
		bp = bp->b_bufp;
	}
	return (FALSE);
}

/*
 * Clean up the virtual terminal
 * system, in anticipation for a return to the
 * operating system. Move down to the last line and
 * clear it out (the next system prompt will be
 * written in the line). Shut down the channel
 * to the terminal.
 */
vttidy()
{
	movecursor( 23, 0 );
	ansieeol();
}
