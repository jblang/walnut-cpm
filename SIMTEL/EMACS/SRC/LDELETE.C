#include	"stdio.h"
#include	"ed.h"

/*
 * This function deletes "n" bytes,
 * starting at dot. It understands how do deal
 * with end of lines, etc. It returns TRUE if all
 * of the characters were deleted, and FALSE if
 * they were not (because dot ran into the end of
 * the buffer. The "kflag" is TRUE if the text
 * should be put in the kill buffer.
 */
ldelete(n, kflag)
{
	register WINDOW	*wp;
#define dotp (*(LINE **)0x90)
	register char	*cp1;
#define cp3 (*(char **)0x9a)
#define cp2 (*(char**)0x92)
#define doto (*(int *)0x94)
#define chunk (*(int *)0x96)
#define left (*(int *)0x98)
#define localn (*(int *)0xa2)

	localn = n;
	while ( localn > 0 )
	{	if ( curbp->b_linep == ( dotp = curwp->w_dotp ) )
			return ( 0 );	/* Hit end of buffer.	*/
		doto = curwp->w_doto;

		if ( localn < ( chunk = left = dotp->l_used - doto ) )
			chunk = localn;
		if ( chunk == 0 )	/* End of line, merge. */
		{	lchange(WFHARD);
			if ( ldelnewline() == FALSE
			|| ( kflag != FALSE && kinsert('\n') == FALSE ))
				return (FALSE);
			--localn;
			continue;
		}
		lchange(WFEDIT);
		cp2 = ( cp3 = cp1 = &dotp->l_text[doto] ) + chunk;

		if (kflag != FALSE)	/* Kill? */
		{	while ( cp1 != cp2 )
			{	if (kinsert( *cp1++ ) == FALSE)
					return (FALSE);
			}
		}
 		blockmv( cp3, cp2, left - chunk );

		dotp->l_used -= chunk;
		wp = wheadp;	/* Fix windows	*/
		while (wp != NULL)
		{	if ( wp->w_dotp == dotp && wp->w_doto >= doto )
			{	wp->w_doto -= chunk;
				if (wp->w_doto < doto)
					wp->w_doto = doto;
			}	
			if ( wp->w_markp == dotp && wp->w_marko >= doto )
			{	wp->w_marko -= chunk;
				if (wp->w_marko < doto)
					wp->w_marko = doto;
			}
			wp = wp->w_wndp;
		}
		localn -= chunk;
	}
	return (TRUE);
}
