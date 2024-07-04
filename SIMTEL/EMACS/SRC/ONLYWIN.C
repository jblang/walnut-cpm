#include	"stdio.h"
#include	"ed.h"

/*
 * This command makes the current
 * window the only window on the screen.
 * Bound to "C-X 1". Try to set the framing
 * so that "." does not have to move on
 * the display. Some care has to be taken
 * to keep the values of dot and mark
 * in the buffer structures right if the
 * distruction of a window makes a buffer
 * become undisplayed.
 */
ovmain(x, f, n)
{
	register WINDOW	*wp;
	register LINE	*lp;
	register int	i;

	if ( x == 1 ) return ( reposition( f, n ));
	if ( x == 2 ) return ( refresh( f, n ));

	while (wheadp != curwp) {
		wp = wheadp;
		wheadp = wp->w_wndp;
		if (--wp->w_bufp->b_nwnd == 0) {
			wp->w_bufp->b_dotp  = wp->w_dotp;
			wp->w_bufp->b_doto  = wp->w_doto;
			wp->w_bufp->b_markp = wp->w_markp;
			wp->w_bufp->b_marko = wp->w_marko;
		}
		free((char *) wp);
	}
	while (curwp->w_wndp != NULL) {
		wp = curwp->w_wndp;
		curwp->w_wndp = wp->w_wndp;
		if (--wp->w_bufp->b_nwnd == 0) {
			wp->w_bufp->b_dotp  = wp->w_dotp;
			wp->w_bufp->b_doto  = wp->w_doto;
			wp->w_bufp->b_markp = wp->w_markp;
			wp->w_bufp->b_marko = wp->w_marko;
		}
		free((char *) wp);
	}
	lp = curwp->w_linep;
	i  = curwp->w_toprow;
	while (i!=0 && lback(lp)!=curbp->b_linep) {
		--i;
		lp = lback(lp);
	}
	curwp->w_toprow = 0;
	curwp->w_ntrows = 22 /* term.t_nrow-1 */;
	curwp->w_linep  = lp;
	curwp->w_flag  |= WFMODE|WFHARD;
	return (TRUE);
}

/*
 * Reposition dot in the current
 * window to line "n". If the argument is
 * positive, it is that line. If it is negative it
 * is that line from the bottom. If it is 0 the window
 * is centered (this is what the standard redisplay code
 * does). With no argument it defaults to 1. Bound to
 * M-!. Because of the default, it works like in
 * Gosling.
 */
reposition(f, n)
{
	curwp->w_force = n;
	curwp->w_flag |= WFFORCE;
	return (TRUE);
}

/*
 * Refresh the screen. With no
 * argument, it just does the refresh. With an
 * argument it recenters "." in the current
 * window. Bound to "C-L".
 */
refresh(f, n)
{
	if (f == FALSE)
	{	curwp->w_flag |= WFHARD | WFFORCE;
		sgarbf = TRUE;
	}
	else
	{	curwp->w_force = 0;		/* Center dot.		*/
		curwp->w_flag |= WFFORCE;
	}
	return (TRUE);
}
