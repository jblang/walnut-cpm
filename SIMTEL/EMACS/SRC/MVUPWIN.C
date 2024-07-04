#include	"stdio.h"
#include	"ed.h"

/*
 * Move the current window up by "arg"
 * lines. Recompute the new top line of the window.
 * Look to see if "." is still on the screen. If it is,
 * you win. If it isn't, then move "." to center it
 * in the new framing of the window (this command does
 * not really move "."; it moves the frame). Bound
 * to "C-X C-P".
 */
ovmain(x, f, n)
register int	n;
{
	register LINE	*lp;
	register int	i;
	if (x == 1) { n = -n; x = 0; }
	if (x == 3) return ( prevwind( f, n ));
	if (x == 2) return ( nextwind( f, n ));
	lp = curwp->w_linep;
	if (n < 0)
	{	while (n++ && lp!=curbp->b_linep)
			lp = lforw(lp);
	}
	else
	{	while (n-- && lback(lp)!=curbp->b_linep)
			lp = lback(lp);
	}
	curwp->w_linep = lp;
	curwp->w_flag |= WFHARD;		/* Mode line is OK.	*/
	for (i=0; i<curwp->w_ntrows; ++i)
	{	if (lp == curwp->w_dotp)
			return (TRUE);
		if (lp == curbp->b_linep)
			break;
		lp = lforw(lp);
	}
	lp = curwp->w_linep;
	i  = curwp->w_ntrows/2;
	while (i-- && lp!=curbp->b_linep)
		lp = lforw(lp);
	curwp->w_dotp  = lp;
	curwp->w_doto  = 0;
	return (TRUE);
}

/*
 * The command make the next
 * window (next => down the screen)
 * the current window. There are no real
 * errors, although the command does
 * nothing if there is only 1 window on
 * the screen. Bound to "C-X C-N".
 */
nextwind(f, n)
{
	register WINDOW	*wp;

	if ((wp=curwp->w_wndp) == NULL)
		wp = wheadp;
	curwp = wp;
	curbp = wp->w_bufp;
	return (TRUE);
}

/*
 * This command makes the previous
 * window (previous => up the screen) the
 * current window. There arn't any errors,
 * although the command does not do a lot
 * if there is 1 window.
 */
prevwind(f, n)
{
	register WINDOW	*wp1;
	register WINDOW	*wp2;

	wp1 = wheadp;
	wp2 = curwp;
	if (wp1 == wp2)
		wp2 = NULL;
	while (wp1->w_wndp != wp2)
		wp1 = wp1->w_wndp;
	curwp = wp1;
	curbp = wp1->w_bufp;
	return (TRUE);
}
