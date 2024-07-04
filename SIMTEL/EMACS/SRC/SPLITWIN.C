#include	"stdio.h"
#include	"ed.h"

/*
 * Split the current window. A window
 * smaller than 3 lines cannot be split.
 * The only other error that is possible is
 * a "malloc" failure allocating the structure
 * for the new window. Bound to "C-X 2".
 */
ovmain( x, f, n )
{
	register WINDOW	*wp;
	register LINE	*lp;
	register int	ntru;
	register int	ntrl;
	register int	ntrd;
	register WINDOW	*wp1;
	register WINDOW	*wp2;

	if (curwp->w_ntrows < 3) {
		mlwrite("Cannot split a %d line window", curwp->w_ntrows);
		return (FALSE);
	}
	if ((wp = (WINDOW *) malloc(sizeof(WINDOW))) == NULL) {
		mlwrite("Cannot allocate WINDOW block");
		return (FALSE);
	}
	++curbp->b_nwnd;			/* Displayed twice.	*/
	wp->w_bufp  = curbp;
	wp->w_dotp  = curwp->w_dotp;
	wp->w_doto  = curwp->w_doto;
	wp->w_markp = curwp->w_markp;
	wp->w_marko = curwp->w_marko;
	wp->w_flag  = 0;
	wp->w_force = 0;
	ntru = (curwp->w_ntrows-1) / 2;		/* Upper size		*/
	ntrl = (curwp->w_ntrows-1) - ntru;	/* Lower size		*/
	lp = curwp->w_linep;
	ntrd = 0;
	while (lp != curwp->w_dotp) {
		++ntrd;
		lp = lforw(lp);
	}
	lp = curwp->w_linep;
	if (ntrd <= ntru) {			/* Old is upper window.	*/
		if (ntrd == ntru)		/* Hit mode line.	*/
			lp = lforw(lp);
		curwp->w_ntrows = ntru;
		wp->w_wndp = curwp->w_wndp;
		curwp->w_wndp = wp;
		wp->w_toprow = curwp->w_toprow+ntru+1;
		wp->w_ntrows = ntrl;
	} else {				/* Old is lower window	*/
		wp1 = NULL;
		wp2 = wheadp;
		while (wp2 != curwp) {
			wp1 = wp2;
			wp2 = wp2->w_wndp;
		}
		if (wp1 == NULL)
			wheadp = wp;
		else
			wp1->w_wndp = wp;
		wp->w_wndp   = curwp;
		wp->w_toprow = curwp->w_toprow;
		wp->w_ntrows = ntru;
		++ntru;				/* Mode line.		*/
		curwp->w_toprow += ntru;
		curwp->w_ntrows  = ntrl;
		while (ntru--)
			lp = lforw(lp);
	}
	curwp->w_linep = lp;			/* Adjust the top lines	*/
	wp->w_linep = lp;			/* if necessary.	*/
	curwp->w_flag |= WFMODE|WFHARD;
	wp->w_flag |= WFMODE|WFHARD;
	return (TRUE);
}
