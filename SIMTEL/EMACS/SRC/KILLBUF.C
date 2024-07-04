/*
 * Buffer management.
 * Some of the functions are internal,
 * and some are actually attached to user
 * keys. Like everyone else, they set hints
 * for the display system.
 */
#include	"stdio.h"
#include	"ed.h"

/*
 * Dispose of a buffer, by name.
 * Ask for the name. Look it up (don't get too
 * upset if it isn't there at all!). Get quite upset
 * if the buffer is being displayed. Clear the buffer (ask
 * if the buffer has been changed). Then free the header
 * line and the buffer header. Bound to "C-X K".
 */
ovmain( x, f, n)
{
	register BUFFER	*bp;
	register BUFFER	*bp1;
	register BUFFER	*bp2;
	register int	s;
	char		bufn[NBUFN];

	if ((s=mlreply("Kill buffer: ", bufn, NBUFN)) != TRUE)
		return (s);
	if ((bp=bfind(bufn, FALSE, 0)) == NULL)	/* Easy if unknown.	*/
		return (TRUE);
	if (bp->b_nwnd != 0) {			/* Error if on screen.	*/
		mlwrite("Buffer is being displayed");
		return (FALSE);
	}
	if ((s=bclear(bp)) != TRUE)		/* Blow text away.	*/
		return (s);
	free((char *) bp->b_linep);		/* Release header line.	*/
	bp1 = NULL;				/* Find the header.	*/
	bp2 = bheadp;
	while (bp2 != bp) {
		bp1 = bp2;
		bp2 = bp2->b_bufp;
	}
	bp2 = bp2->b_bufp;			/* Next one in chain.	*/
	if (bp1 == NULL)			/* Unlink it.		*/
		bheadp = bp2;
	else
		bp1->b_bufp = bp2;
	free((char *) bp);			/* Release buffer block	*/
	return (TRUE);
}
