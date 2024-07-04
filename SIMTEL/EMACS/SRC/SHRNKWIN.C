#include	"stdio.h"
#include	"ed.h"

/*
 * Shrink the current window.
 * Find the window that gains space. Hack at
 * the window descriptions. Ask the redisplay to
 * do all the hard work. Bound to "C-X C-Z".
 */
ovmain(x, f, n)
{
	register WINDOW	*adjwp;
	register LINE	*lp;
	register int	i;

	if (n < 0) { ctrlg(); return (FALSE); }
/*		return (enlargewind(f, -n));*/

	if (wheadp->w_wndp == NULL) {
		mlwrite("Only one window");
		return (FALSE);
	}
	if ((adjwp=curwp->w_wndp) == NULL) {
		adjwp = wheadp;
		while (adjwp->w_wndp != curwp)
			adjwp = adjwp->w_wndp;
	}
	if (curwp->w_ntrows <= n) {
		mlwrite("Impossible change");
		return (FALSE);
	}
	if (curwp->w_wndp == adjwp) {		/* Grow below.		*/
		lp = adjwp->w_linep;
		for (i=0; i<n && lback(lp)!=adjwp->w_bufp->b_linep; ++i)
			lp = lback(lp);
		adjwp->w_linep  = lp;
		adjwp->w_toprow -= n;
	} else {				/* Grow above.		*/
		lp = curwp->w_linep;
		for (i=0; i<n && lp!=curbp->b_linep; ++i)
			lp = lforw(lp);
		curwp->w_linep  = lp;
		curwp->w_toprow += n;
	}
	curwp->w_ntrows -= n;
	adjwp->w_ntrows += n;
	curwp->w_flag |= WFMODE|WFHARD;
	adjwp->w_flag |= WFMODE|WFHARD;
	return (TRUE);
}
