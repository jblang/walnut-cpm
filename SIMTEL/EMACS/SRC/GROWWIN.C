#include	"stdio.h"
#include	"ed.h"

/*
 * Enlarge the current window.
 * Find the window that loses space. Make
 * sure it is big enough. If so, hack the window
 * descriptions, and ask redisplay to do all the
 * hard work. You don't just set "force reframe"
 * because dot would move. Bound to "C-X Z".
 */
ovmain(x, f, n)
{
	register WINDOW	*adjwp;
	register LINE	*lp;
	register int	i;

	if (n < 0) { ctrlg(); return (FALSE); }
		/* return (shrinkwind(f, -n)); */
	if (wheadp->w_wndp == NULL) {
		mlwrite("Only one window");
		return (FALSE);
	}
	if ((adjwp=curwp->w_wndp) == NULL) {
		adjwp = wheadp;
		while (adjwp->w_wndp != curwp)
			adjwp = adjwp->w_wndp;
	}
	if (adjwp->w_ntrows <= n) {
		mlwrite("Impossible change");
		return (FALSE);
	}
	if (curwp->w_wndp == adjwp) {		/* Shrink below.	*/
		lp = adjwp->w_linep;
		for (i=0; i<n && lp!=adjwp->w_bufp->b_linep; ++i)
			lp = lforw(lp);
		adjwp->w_linep  = lp;
		adjwp->w_toprow += n;
	} else {				/* Shrink above.	*/
		lp = curwp->w_linep;
		for (i=0; i<n && lback(lp)!=curbp->b_linep; ++i)
			lp = lback(lp);
		curwp->w_linep  = lp;
		curwp->w_toprow -= n;
	}
	curwp->w_ntrows += n;
	adjwp->w_ntrows -= n;
	curwp->w_flag |= WFMODE|WFHARD;
	adjwp->w_flag |= WFMODE|WFHARD;
	return (TRUE);
}
