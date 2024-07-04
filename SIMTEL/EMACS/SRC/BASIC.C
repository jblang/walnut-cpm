/*
 * The routines in this file
 * move the cursor around on the screen.
 * They compute a new value for the cursor, then
 * adjust ".". The display code always updates the
 * cursor location, so only moves between lines,
 * or functions that adjust the top line in the window
 * and invalidate the framing, are hard.
 */
#include	"stdio.h"
#include	"ed.h"
int tabsize;
#ifdef OLDMAP
/*
 * Move the cursor to the
 * beginning of the current line.
 * Trivial.
 */
gotobol(f, n)
{
	curwp->w_doto  = 0;
	return (TRUE);
}
#endif
/*
 * Move the cursor backwards by
 * "n" characters. If "n" is less than
 * zero call "forwchar" to actually do the
 * move. Otherwise compute the new cursor
 * location. Error if you try and move
 * out of the buffer. Set the flag if the
 * line pointer for dot changes.
 */
backchar(f, n)
register int	n;
{
	register LINE	*lp;

	if (n < 0)
		return (forwchar(f, -n));
	while (n--)
	{	if (curwp->w_doto == 0)
		{	if ((lp=lback(curwp->w_dotp)) == curbp->b_linep)
				return (FALSE);
			curwp->w_dotp  = lp;
			curwp->w_doto  = llength(lp);
			curwp->w_flag |= WFMOVE;
		} else 	curwp->w_doto--;
	}
	return (TRUE);
}
#ifdef OLDMAP
/*
 * Move the cursor to the end
 * of the current line. Trivial.
 * No errors.
 */
gotoeol(f, n)
{
	curwp->w_doto  = llength(curwp->w_dotp);
	return (TRUE);
}
#endif
/*
 * Move the cursor forwwards by
 * "n" characters. If "n" is less than
 * zero call "backchar" to actually do the
 * move. Otherwise compute the new cursor
 * location, and move ".". Error if you
 * try and move off the end of the
 * buffer. Set the flag if the line pointer
 * for dot changes.
 */
forwchar(f, n)
register int	n;
{
	if (n < 0)
		return (backchar(f, -n));
	while (n--)
	{	if (curwp->w_doto == llength(curwp->w_dotp))
		{	if (curwp->w_dotp == curbp->b_linep)
				return (FALSE);
			curwp->w_dotp  = lforw(curwp->w_dotp);
			curwp->w_doto  = 0;
			curwp->w_flag |= WFMOVE;
		} else
			curwp->w_doto++;
	}
	return (TRUE);
}
