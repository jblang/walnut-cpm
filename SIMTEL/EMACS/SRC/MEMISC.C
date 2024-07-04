#define OWNER 1
#include	"metab.h"

FILE * kbdmf;
int kbdmstate;

getstroke()
{	/* get physical key from current source. */
	register int	c;

	if ( kbdmstate == 2 )
	{	/* execute "keyboard mac" or "exec file" */
		if (( c = getc( kbdmf )) == EOF || c == 26 )
		{	kbdmclose();
		}
	}
	if ( kbdmstate != 2 )
	{	c = conin();
		if ( kbdmstate == 1 )
		{	/* save keyboard mac */
			if ( putc( c, kbdmf ) == EOF )
			{	ctrlg();
			}
		}
	}
	return ( c );
}
/*
kbdmget()
{	return( getc( kbdmf ));
}
*/
kbdmclose()
{	if ( kbdmf ) fclose( kbdmf );
	kbdmf = kbdmstate = 0;
}
conin()
{	return( bios( 3 ));
}

getkey()
{
	register int c;
	
	if ( ( c = getstroke()) == METACH )	/* Apply M- prefix */
	{	return (META | getstroke());
	}
#ifdef NEVER
	if ( c == CMINUSCH ) return ( c );
		/* negative parameter introducer. */
	if ( c <= 0x1F )			/* C0 control -> C-	*/
		c |= ( CTRL | '@' );
#endif
	return (c);
}

#ifdef NEVER
/*
 * Get a key.
 * Apply control modifications
 * to the read key.
 */
getctl()
{
	register int	c;

	if ( ( c = getstroke()) <= 0x1f )
		c |= ( CTRL | '@' );
	if ( islower( c ))
		c -= 0x20;
	return (c);
}
#endif
/*
 * Abort.
 * Beep the beeper.
 * Kill off any keyboard macro,
 * etc., that is in progress.
 * Sometimes called as a routine,
 * to do general aborting of
 * stuff.
 */

ctrlg()
{
	conout( 7 );
	kbdmclose();
	return (ABORT);
}
