#include	"stdio.h"
#include	"ed.h"

/*
 * List all of the active
 * buffers. First update the special
 * buffer that holds the list. Next make
 * sure at least 1 window is displaying the
 * buffer list, splitting the screen if this
 * is what it takes. Lastly, repaint all of
 * the windows that are displaying the
 * list. Bound to "C-X C-B".
 */
ovmain(x, f, n)
{
/*	register WINDOW	*wp; */
	register BUFFER	*bp;
	register int	s;

	if ( x ) return ( usebuf( x, f, n ));
	if ( ! usebuf( 2, 0, 0 )) return ( 0 );
	if ((s=makelist()) != TRUE)
		return (s);
#ifdef NEVER
	if (blistp->b_nwnd == 0) {		/* Not on screen yet.	*/
		if ((wp=wpopup()) == NULL)
			return (FALSE);
		bp = wp->w_bufp;
		if (--bp->b_nwnd == 0) {
			bp->b_dotp  = wp->w_dotp;
			bp->b_doto  = wp->w_doto;
			bp->b_markp = wp->w_markp;
			bp->b_marko = wp->w_marko;
		}
		wp->w_bufp  = blistp;
		++blistp->b_nwnd;
	}
#endif
#ifdef NEVER
	while (wp != NULL)
	{	if (wp->w_bufp == blistp)
		{
			wp->w_linep =
			wp->w_dotp  = lforw(blistp->b_linep);
			wp->w_markp =
			wp->w_doto  =
			wp->w_marko = 0;
			wp->w_flag |= WFMODE|WFHARD;
		}
		wp = wp->w_wndp;
	}
#endif
	return (TRUE);
}

/*
 * This routine rebuilds the
 * text in the special secret buffer
 * that holds the buffer list. It is called
 * by the list buffers command. Return TRUE
 * if everything works. Return FALSE if there
 * is an error (if there is no memory).
 */
makelist()
{
	register char	*cp1;
	register char	*cp2;
	register int	c;
	register BUFFER	*bp;
	register LINE	*lp;
	register int	nbytes;
	register int	s;
	register int	type;
	char		b[6+1];
	char		line[128];
	int nbuff;

	nbuff = 0;
	blistp->b_flag &= ~BFCHG;		/* Don't complain!	*/
	if ((s=bclear(blistp)) != TRUE)		/* Blow old text away	*/
		return (s);
	blistp->b_fname[0] = 0;
	if (addline("    C   Size Buffer           File") == FALSE
	||  addline("    -   ---- ------           ----") == FALSE)
		return (FALSE);
	bp = bheadp;				/* For all buffers	*/
	while (bp != NULL)
	{	if ( bp->b_flag & BFTEMP )
		{	bp = bp->b_bufp;	/* Skip magic ones.	*/
			continue;
		}
		cp1 = &line[-1];		/* Start at left edge	*/
		cp2 = &b[0];
		itoa( cp2, 3, ++nbuff );	/* 6 digit buffer size.	*/
		while (*++cp1 = *cp2++);
		*cp1 = ' ';			/* Gap.			*/
		*++cp1 = ( bp->b_flag & BFCHG ) ? '*' : ' ';
			/* "*" if changed	*/
		*++cp1 = ' ';			/* Gap.			*/
		nbytes = 0;			/* Count bytes in buf.	*/
		lp = lforw(bp->b_linep);
		while (lp != bp->b_linep)
		{	nbytes += llength(lp)+1;
			lp = lforw(lp);
		}
		cp2 = &b[0];
		itoa( cp2, 6, nbytes );		/* 6 digit buffer size.	*/
		while (*++cp1 = *cp2++);
		*cp1 = ' ';			/* Gap.			*/
		cp2 = &bp->b_bname[0];		/* Buffer name		*/
		while (*++cp1 = *cp2++);
		cp2 = &bp->b_fname[0];		/* File name		*/
		if (*cp2 != 0) {
			while (cp1 < &line[4+1+1+6+1+NBUFN+1])
				*cp1++ = ' ';		
			while ( *cp1++ = *cp2++ );
		}
		*cp1 = 0;
		if (addline(line) == FALSE)
			return (FALSE);
		bp = bp->b_bufp;
	}
	return (TRUE);				/* All done		*/
}

/*
 * The argument "text" points to
 * a string. Append this line to the
 * buffer list buffer. Handcraft the EOL
 * on the end. Return TRUE if it worked and
 * FALSE if you ran out of room.
 */
addline(text)
char	*text;
{
	register LINE	*lp;
	register int	ntext;

	ntext = strlen(text);
	if ((lp=lalloc(ntext)) == NULL)
		return (FALSE);
	blockmv( &lp->l_text[0], text, ntext );
/****	for (i=0; i<ntext; ++i) ****/
/****		lputc(lp, i, text[i]); ****/
	( lp->l_bp = blistp->b_linep->l_bp )->l_fp = lp;
	( lp->l_fp = blistp->b_linep )->l_bp = lp;
	if (blistp->b_dotp == blistp->b_linep)	/* If "." is at the end	*/
		blistp->b_dotp = lp;		/* move it to new line	*/
	return (TRUE);
}
itoa(buf, width, num)
register char	buf[];
register int	width;
register int	num;
{
	buf[width] = 0;				/* End of string.	*/
	clear( buf, width, ' ' );
	while (num >= 10) {			/* Conditional digits.	*/
		buf[--width] = (num%10) + '0';
		num /= 10;
	}
	buf[--width] = num + '0';		/* Always 1 digit.	*/
#ifdef NEVER
	while (width != 0)			/* Pad with blanks.	*/
		buf[--width] = ' ';
#endif
}

/*
 * Attach a buffer to a window. The
 * values of dot and mark come from the buffer
 * if the use count is 0. Otherwise, they come
 * from some other window.
 */
usebuf( x, f, n)
{
	register BUFFER	*bp;
	register WINDOW	*wp;
	register int	s;
	char		bufn[NBUFN];

	if ( x == 1 )
	{	/* "next buffer" */
		bp = curbp->b_bufp;
		if ( bp == NULL ) bp = bheadp;
	}
	else if ( x == 2 )
	{	if ( ( bp = bfind( "[List]", TRUE, BFTEMP )) == NULL )
			return ( 0 );
	}
	else
	{	/* normal usebuffer() routine. */
		if ((s=mlreply("Use buffer: ", bufn, NBUFN)) != TRUE)
			return (s);
		if ((bp=bfind(bufn, TRUE, 0)) == NULL)
			return (FALSE);
	}
	if (--curbp->b_nwnd == 0) {		/* Last use.		*/
/****		curbp->b_dotp  = curwp->w_dotp; ****/
/****		curbp->b_doto  = curwp->w_doto; ****/
/****		curbp->b_markp = curwp->w_markp; ****/
/****		curbp->b_marko = curwp->w_marko; ****/
		blockmv( curbp, curwp, 8 );
	}
	curbp = bp;				/* Switch.		*/
	curwp->w_bufp  = bp;
	curwp->w_linep = bp->b_linep;		/* For macros, ignored.	*/
	curwp->w_flag |= WFMODE|WFFORCE|WFHARD;	/* Quite nasty.		*/
	if (bp->b_nwnd++ == 0) {		/* First use.		*/
		blockmv( curwp, curbp, 8 );
#ifdef NEVER
		curwp->w_dotp  = bp->b_dotp;
		curwp->w_doto  = bp->b_doto;
		curwp->w_markp = bp->b_markp;
		curwp->w_marko = bp->b_marko;
#endif
		return (TRUE);
	}
	wp = wheadp;				/* Look for old.	*/
	while (wp != NULL) {
		if (wp!=curwp && wp->w_bufp==bp) {
			blockmv( curwp, curbp, 8 );
#ifdef NEVER
			curwp->w_dotp  = wp->w_dotp;
			curwp->w_doto  = wp->w_doto;
			curwp->w_markp = wp->w_markp;
			curwp->w_marko = wp->w_marko;
#endif
			break;
		}
		wp = wp->w_wndp;
	}
	return (TRUE);
}
