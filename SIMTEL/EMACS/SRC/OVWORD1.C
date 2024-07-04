/*
 * The routines in this file
 * implement commands that work word at
 * a time. There are all sorts of word mode
 * commands. If I do any sentence and/or paragraph
 * mode commands, they are likely to be put in
 * this file.
 */
#include	"stdio.h"
#include	"ed.h"

ovmain( x, f, n )
{	switch ( x )
	{	case 0: return ( upperword( f, n ));
		case 1: return ( lowerword( f, n ));
		case 2: return ( capword( f, n ));
/*		case 3: return ( setfillcol( f, n )); */
/*		case 4: return ( wrapword( )); */
	}
}
#ifdef NEVER
/* Word wrap on n-spaces.
 * Back-over whatever precedes the point on the current line and
 * stop on the first word-break or the beginning of the line.
 * If we reach the beginning of the line, jump back to the end of the
 * word and start a new line.  Otherwise, break the line at the
 * word-break, eat it, and jump back to the end of the word.
 *	NOTE:  This function may leaving trailing blanks.
 * Returns TRUE on success, FALSE on errors.
 */
wrapword()
{
	register int cnt;
	register LINE *oldp;

	oldp = curwp->w_dotp;
	cnt = -1;
	do {				
		cnt++;
		if (! backchar(NULL, 1))
			return(FALSE);
	}
	while (! inword());
	if (! backword(NULL, 1))
		return(FALSE);
	if (oldp == curwp->w_dotp && curwp->w_doto ) {
		if (! backdel(NULL, 1))
			return(FALSE);
		if (! newline(NULL, 1))
			return(FALSE);
	}
	return(forwword(NULL, 1) && forwchar(NULL, cnt));
}

/*
 * Set fill column to n. 
 */
setfillcol(f, n)
{
	fillcol = n;
	return(TRUE);
}
#endif
/*
 * Move the cursor forward by
 * the specified number of words. As you move,
 * convert any characters to upper case. Error
 * if you try and move beyond the end of the
 * buffer. Bound to "M-U".
 */
upperword(f, n)
{
	register int	c;

	if (n < 0)
		return (FALSE);
	while (n--) {
		while (inword() == FALSE) {
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
		while (inword() != FALSE) {
			c = lgetc(curwp->w_dotp, curwp->w_doto);
			if (c>='a' && c<='z') {
				c -= 'a'-'A';
				lputc(curwp->w_dotp, curwp->w_doto, c);
				lchange(WFHARD);
			}
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
	}
	return (TRUE);
}

/*
 * Move the cursor forward by
 * the specified number of words. As you move
 * convert characters to lower case. Error if you
 * try and move over the end of the buffer.
 * Bound to "M-L".
 */
lowerword(f, n)
{
	register int	c;

	if (n < 0)
		return (FALSE);
	while (n--) {
		while (inword() == FALSE) {
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
		while (inword() != FALSE) {
			c = lgetc(curwp->w_dotp, curwp->w_doto);
			if (c>='A' && c<='Z') {
				c += 'a'-'A';
				lputc(curwp->w_dotp, curwp->w_doto, c);
				lchange(WFHARD);
			}
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
	}
	return (TRUE);
}

/*
 * Move the cursor forward by
 * the specified number of words. As you move
 * convert the first character of the word to upper
 * case, and subsequent characters to lower case. Error
 * if you try and move past the end of the buffer.
 * Bound to "M-C".
 */
capword(f, n)
{
	register int	c;

	if (n < 0)
		return (FALSE);
	while (n--) {
		while (inword() == FALSE) {
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
		}
		if (inword() != FALSE) {
			c = lgetc(curwp->w_dotp, curwp->w_doto);
			if (c>='a' && c<='z') {
				c -= 'a'-'A';
				lputc(curwp->w_dotp, curwp->w_doto, c);
				lchange(WFHARD);
			}
			if (forwchar(FALSE, 1) == FALSE)
				return (FALSE);
			while (inword() != FALSE) {
				c = lgetc(curwp->w_dotp, curwp->w_doto);
				if (c>='A' && c<='Z') {
					c += 'a'-'A';
					lputc(curwp->w_dotp, curwp->w_doto, c);
					lchange(WFHARD);
				}
				if (forwchar(FALSE, 1) == FALSE)
					return (FALSE);
			}
		}
	}
	return (TRUE);
}
