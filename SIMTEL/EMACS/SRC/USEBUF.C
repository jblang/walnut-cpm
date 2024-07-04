#include	"stdio.h"
#include	"ed.h"

/*
 * Attach a buffer to a window. The
 * values of dot and mark come from the buffer
 * if the use count is 0. Otherwise, they come
 * from some other window.
 */
ovmain( x, f, n)
{
	register BUFFER	*bp;
	register WINDOW	*wp;
	register int	s;
	char		bufn[NBUFN];

	if ( x )
	{	/* "next buffer" */
		bp = curbp->b_bufp;
		if ( bp == NULL ) bp = bheadp;
	}
	else
	{	/* normal usebuffer() routine. */
		if ((s=mlreply("Use buffer: ", bufn, NBUFN)) != TRUE)
			return (s);
		if ((bp=bfind(bufn, TRUE, 0)) == NULL)
			return (FALSE);
	}
	if (--curbp->b_nwnd == 0) {		/* Last use.		*/
		curbp->b_dotp  = curwp->w_dotp;
		curbp->b_doto  = curwp->w_doto;
		curbp->b_markp = curwp->w_markp;
		curbp->b_marko = curwp->w_marko;
	}
	curbp = bp;				/* Switch.		*/
	curwp->w_bufp  = bp;
	curwp->w_linep = bp->b_linep;		/* For macros, ignored.	*/
	curwp->w_flag |= WFMODE|WFFORCE|WFHARD;	/* Quite nasty.		*/
	if (bp->b_nwnd++ == 0) {		/* First use.		*/
		curwp->w_dotp  = bp->b_dotp;
		curwp->w_doto  = bp->b_doto;
		curwp->w_markp = bp->b_markp;
		curwp->w_marko = bp->b_marko;
		return (TRUE);
	}
	wp = wheadp;				/* Look for old.	*/
	while (wp != NULL) {
		if (wp!=curwp && wp->w_bufp==bp) {
			curwp->w_dotp  = wp->w_dotp;
			curwp->w_doto  = wp->w_doto;
			curwp->w_markp = wp->w_markp;
			curwp->w_marko = wp->w_marko;
			break;
		}
		wp = wp->w_wndp;
	}
	return (TRUE);
}
