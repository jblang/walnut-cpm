#include	"stdio.h"
#include	"ed.h"

/*
 * Select a file for editing.
 * Look around to see if you can find the
 * fine in another buffer; if you can find it
 * just switch to the buffer. If you cannot find
 * the file, create a new buffer, read in the
 * text, and switch to the new buffer.
 * Bound to C-X C-V.
 */
ovmain( x, f, n )
{
	register BUFFER	*bp;
	register WINDOW	*wp;
	register LINE	*lp;
	register int	i;
	register int	s;
	char		bname[NBUFN];
	char		fname[NFILEN];

	if ((s=mlreply("Find file: ", fname, NFILEN)) != TRUE)
		return (s);
	for ( bp = bheadp; bp != NULL; bp = bp->b_bufp )
	{	if ((bp->b_flag&BFTEMP)==0 && strcmp(bp->b_fname, fname)==0)
		{	if (--curbp->b_nwnd == 0)
			{	blockmv( curbp, curwp, 8 );
			}
			curbp =
			curwp->w_bufp  = bp;
			if (bp->b_nwnd++ == 0)
			{	blockmv( curwp, bp, 8 );
			} else
			{	wp = wheadp;
				while ( wp != NULL )
				{	if ( wp != curwp && wp->w_bufp==bp)
					{	blockmv( curwp, wp, 8 );
						break;
					}
					wp = wp->w_wndp;
				}
			}
			lp = curwp->w_dotp;
			/* i = curwp->w_ntrows >> 1; */
			/* while ( i-- && lback(lp) != curbp->b_linep ) */
				/* lp = lback(lp); */
			curwp->w_linep = lp;
			curwp->w_flag |= WFMODE|WFHARD;
			mlwrite("[Old buffer]");
			return (TRUE);
		}
	}
	makename(bname, fname);			/* New buffer name.	*/
	while (( bp = bfind( bname, FALSE, 0 )) != NULL )
	{	if ( ( s = mlreply( "Buffer name: ", bname, NBUFN )) == ABORT)
			return (s);	/* ^G to just quit	*/
		if (s == FALSE)		/* CR to clobber it	*/
		{	makename( bname, fname );
			break;
		}
	}
	if ( bp == NULL && ( bp = bfind( bname, TRUE, 0 )) == NULL )
	{	mlwrite("No buffer");
		return (FALSE);
	}
	if (--curbp->b_nwnd == 0)		/* Undisplay.	*/
	{	blockmv( curbp, curwp, 8 );
	}
	( curbp =				/* Switch to it.	*/
		curwp->w_bufp = bp)->
			b_nwnd++;
	return ( readin( fname, 1 ));		/* Read it in.		*/
}

makename(bname, fname)
char	*bname;
char	*fname;
{
	register char * cp1;

	cp1 = fname;
	while ( *cp1 != ':' )
	{	if ( ! *cp1 )
		{	cp1 = fname;
			break;
		}
		cp1++;
	}
	if ( *cp1 == ':' ) cp1++;
	strcpy( bname, cp1 );
}

#include "readin.c"
