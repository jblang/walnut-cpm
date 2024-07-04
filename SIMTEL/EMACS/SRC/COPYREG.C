#include	"stdio.h"
#include	"ed.h"

/*
 * Copy all of the characters in the
 * region to the kill buffer. Don't move dot
 * at all. This is a bit like a kill region followed
 * by a yank. Bound to "M-W".
 */
ovmain(x, f, n)
{
	register LINE	*linep;
	register int	loffs;
	register int	s;
	REGION		region;

	if ((s=getregion(&region)) != TRUE)
		return (s);
	if ((lastflag&CFKILL) == 0)		/* Kill type command.	*/
		kdelete();
	thisflag |= CFKILL;
	linep = region.r_linep;			/* Current line.	*/
	loffs = region.r_offset;		/* Current offset.	*/
	while (region.r_size--) {
		if (loffs == llength(linep)) {	/* End of line.		*/
			if ((s=kinsert('\n')) != TRUE)
				return (s);
			linep = lforw(linep);
			loffs = 0;
		} else {			/* Middle of line.	*/
			if ((s=kinsert(lgetc(linep, loffs))) != TRUE)
				return (s);
			++loffs;
		}
	}
	return (TRUE);
}
#include "getreg.c"
