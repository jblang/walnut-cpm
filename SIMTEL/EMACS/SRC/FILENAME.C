#include	"stdio.h"
#include	"ed.h"

/*
 * The command allows the user
 * to modify the file name associated with
 * the current buffer. It is like the "f" command
 * in UNIX "ed". The operation is simple; just zap
 * the name in the BUFFER structure, and mark the windows
 * as needing an update. You can type a blank line at the
 * prompt if you wish.
 */
ovmain(x, f, n)
{
	register WINDOW	*wp;
	register int	s;
	char	 	fname[NFILEN];
	char		bname[NBUFN];

	if ( x == 1 ) return ( quote( f, n ));
	if ( n > 0 ) goto dobufname;
	if ((s=mlreply("File Name: ", fname, NFILEN)) == ABORT)
		return (s);
	if (s == FALSE)
		strcpy(curbp->b_fname, "");
	else
		strcpy(curbp->b_fname, fname);
	wp = wheadp;				/* Update mode lines.	*/
	while (wp != NULL) {
		if (wp->w_bufp == curbp)
			wp->w_flag |= WFMODE;
		wp = wp->w_wndp;
	}
	return (TRUE);
dobufname:
	if ((s=mlreply("Buffer Name: ", bname, NBUFN)) == ABORT)
		return (s);
	if (s == FALSE)
		return (s);
	else
		strcpy(curbp->b_bname, bname);
	wp = wheadp;				/* Update mode lines.	*/
	while (wp != NULL) {
		if (wp->w_bufp == curbp)
			wp->w_flag |= WFMODE;
		wp = wp->w_wndp;
	}
	return (TRUE);
}

/*
 * Quote the next character, and
 * insert it into the buffer. All the characters
 * are taken literally, with the exception of the newline,
 * which always has its line splitting meaning. The character
 * is always read, even if it is inserted 0 times, for
 * regularity. Bound to "M-Q" (for me) and "C-Q" (for Rich,
 * and only on terminals that don't need XON-XOFF).
 */
quote(f, n)
{
	register int	s;
	register int	c;

	c = getstroke();
	if (n < 0)
		return (FALSE);
	if (n == 0)
		return (TRUE);
	if (c == '\n') {
		do {
			s = lnewline();
		} while (s==TRUE && --n);
		return (s);
	}
	return (linsert(n, c));
}
