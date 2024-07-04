#include	"stdio.h"
#include	"ed.h"

/*
 * Kill the region. Ask "getregion"
 * to figure out the bounds of the region.
 * Move "." to the start, and kill the characters.
 * Bound to "C-W".
 */
ovmain(x, f, n)
{
	register int	s;
	REGION		region;

	if ((s=getregion(&region)) != TRUE)
		return (s);
	if ((lastflag&CFKILL) == 0)		/* This is a kill type	*/
		kdelete();			/* command, so do magic	*/
	thisflag |= CFKILL;			/* kill buffer stuff.	*/
	curwp->w_dotp = region.r_linep;
	curwp->w_doto = region.r_offset;
	return (ldelete(region.r_size, TRUE));
}
#include "getreg.c"
