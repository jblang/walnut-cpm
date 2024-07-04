#include	"stdio.h"
#include	"ed.h"

ovmain( x, f, n )
{	switch (x)
	{	case 0:
			return (showcpos( f, n ));
		case 1:
			return ( twiddle( f, n ));
		case 2:
			return ( deblank( f, n ));
	}
}

/*
 * Display the current position of the cursor,
 * in origin 1 X-Y coordinates, the character that is
 * under the cursor (in octal), and the fraction of the
 * text that is before the cursor. The displayed column
 * is not the current column, but the column that would
 * be used on an infinite width display. Normally this
 * is bound to "C-X =".
 */
showcpos(f, n)
{
	register LINE	*clp;
	register int	nch;
	register int	cbo;
	register int	nbc;
	register int	cac;
	register int	ratio;
	register int	col;
	register int	i;
	register int	c;
	int curln, lines;
	extern int currow;

	clp = lforw(curbp->b_linep);		/* Grovel the data.	*/
	cbo = nch = lines = 0;
	for (;;)
	{	lines++;
		if ( clp == curwp->w_dotp )
		{	nbc = nch + ( cbo = curwp->w_doto );
			curln = lines;
			if (cbo == llength(clp))
				cac = '\n';
			else
				cac = lgetc(clp, cbo);
		}
		nch += llength( clp ) + 1;	/* 1 allows for newline. */
		if (clp == curbp->b_linep) break;
		clp = lforw(clp);
	}
	col = currow + 1;			/* Get real column.	*/
	ratio = 0;				/* Ratio before dot.	*/
	if (nch != 0)
		ratio = nbc / ( nch / 100 );
	mlwrite("X=%d Y=%d CH=0x%d .=%d (%d%% of %d) line %d of %d",
		col+1, currow+1, cac, nbc, ratio, nch, curln, lines);
	return (TRUE);
}

/*
 * Twiddle the two characters on either side of
 * dot. If dot is at the end of the line twiddle the
 * two characters before it. Return with an error if dot
 * is at the beginning of line; it seems to be a bit
 * pointless to make this work. This fixes up a very
 * common typo with a single stroke. Normally bound
 * to "C-T". This always works within a line, so
 * "WFEDIT" is good enough.
 */
twiddle(f, n)
{
	register LINE	*dotp;
	register int	doto;
	register int	cl;
	register int	cr;

	dotp = curwp->w_dotp;
	doto = curwp->w_doto;
	if (doto==llength(dotp) && --doto<0)
		return (FALSE);
	cr = lgetc(dotp, doto);
	if (--doto < 0)
		return (FALSE);
	cl = lgetc(dotp, doto);
	lputc(dotp, doto+0, cr);
	lputc(dotp, doto+1, cl);
	lchange(WFEDIT);
	return (TRUE);
}

/*
 * Delete blank lines around dot.
 * What this command does depends if dot is
 * sitting on a blank line. If dot is sitting on a
 * blank line, this command deletes all the blank lines
 * above and below the current line. If it is sitting
 * on a non blank line then it deletes all of the
 * blank lines after the line. Normally this command
 * is bound to "C-X C-O". Any argument is ignored.
 */
deblank(f, n)
{
	register LINE	*lp1;
	register LINE	*lp2;
	register int	nld;

	lp1 = curwp->w_dotp;
	while (llength(lp1)==0 && (lp2=lback(lp1))!=curbp->b_linep)
		lp1 = lp2;
	lp2 = lp1;
	nld = 0;
	while ((lp2=lforw(lp2))!=curbp->b_linep && llength(lp2)==0)
		++nld;
	if (nld == 0)
		return (TRUE);
	curwp->w_dotp = lforw(lp1);
	curwp->w_doto = 0;
	return (ldelete(nld));
}
