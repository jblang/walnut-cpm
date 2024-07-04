/*
 * Window management.
 * Some of the functions are internal,
 * and some are attached to keys that the
 * user actually types.
 */
#include	"stdio.h"
#include	"ed.h"

/*
 * Pick a window for a pop-up.
 * Split the screen if there is only
 * one window. Pick the uppermost window that
 * isn't the current window. An LRU algorithm
 * might be better. Return a pointer, or
 * NULL on error.
 */
WINDOW	*
wpopup()
{
	register WINDOW	*wp;

	if (wheadp->w_wndp == NULL)		/* Only 1 window	*/
	/* && splitwind(FALSE, 0) == FALSE) 	/* and it won't split	*/
		return (NULL);
	wp = wheadp;				/* Find window to use	*/
	while (wp!=NULL && wp==curwp)
		wp = wp->w_wndp;
	return (wp);
}
