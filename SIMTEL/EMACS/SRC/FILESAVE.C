#include	"stdio.h"
#include	"ed.h"
extern int ovreq, ovreq2, ovsub, ovsub2;
/*
 * Save the contents of the current
 * buffer in its associated file. No nothing
 * if nothing has changed (this may be a bug, not a
 * feature). Error if there is no remembered file
 * name for the buffer. Bound to "C-X C-S". May
 * get called by "C-Z".
 */
ovmain( x, f, n )
{
	register int	s;

	if ((curbp->b_flag&BFCHG) == 0)		/* Return, no changes.	*/
		return (TRUE);
	if (curbp->b_fname[0] == 0)
	{	/* Must have a name.	*/
		mlwrite("No file name");
		return (FALSE);
	}
	return ( writeout( curbp->b_fname ));
}
#include "writeout.c"
