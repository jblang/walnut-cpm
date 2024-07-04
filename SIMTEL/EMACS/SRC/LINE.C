/*
 * The functions in this file
 * are a general set of line management
 * utilities. They are the only routines that
 * touch the text. They also touch the buffer
 * and window structures, to make sure that the
 * necessary updating gets done. There are routines
 * in this file that handle the kill buffer too.
 * It isn't here for any good reason.
 *
 * Note that this code only updates the dot and
 * mark values in the window list. Since all the code
 * acts on the current window, the buffer that we
 * are editing must be being displayed, which means
 * that "b_nwnd" is non zero, which means that the
 * dot and mark values in the buffer headers are
 * nonsense.
 */
#include	"stdio.h"
#include	"ed.h"

#define	NBLOCK	4			/* Line block chunk size	*/
/* changed from 16 to 8 in an attempt to save space. */

/*
 * This routine allocates a block
 * of memory large enough to hold a LINE
 * containing "used" characters. The block is
 * always rounded up a bit. Return a pointer
 * to the new block, or NULL if there isn't
 * any memory left. Print a message in the
 * message line if no space.
 */
LINE	*
lalloc(used)
int	used;
{
	register LINE	*lp;
	register int	size;

	size = (used+NBLOCK-1) & ~(NBLOCK-1);
	if (size == 0)				/* Assume that an empty	*/
		size = NBLOCK;			/* line is for type-in.	*/
	if ((lp = (LINE *) malloc(sizeof(LINE)+size)) == NULL) {
		mlwrite("No Memory");
		return (NULL);
	}
	lp->l_size = size;
	lp->l_used = used;
	return (lp);
}

/*
 * This routine gets called when
 * a character is changed in place in the
 * current buffer. It updates all of the required
 * flags in the buffer and window system. The flag
 * used is passed as an argument; if the buffer is being
 * displayed in more than 1 window we change EDIT to
 * HARD. Set MODE if the mode line needs to be
 * updated (the "*" has to be set).
 */
lchange(flag)
{
	register WINDOW	*wp;

	if (curbp->b_nwnd != 1)			/* Ensure hard.		*/
		flag = WFHARD;
	if ((curbp->b_flag&BFCHG) == 0) {	/* First change, so 	*/
		flag |= WFMODE;			/* update mode lines.	*/
		curbp->b_flag |= BFCHG;
	}
	wp = wheadp;
	while (wp != NULL) {
		if (wp->w_bufp == curbp)
			wp->w_flag |= flag;
		wp = wp->w_wndp;
	}
}
