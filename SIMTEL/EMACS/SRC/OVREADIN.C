#include "stdio.h"
#include "ed.h"

/*
 * Read file "fname" into the current
 * buffer, blowing away any text found there. Called
 * by both the read and visit commands. Return the final
 * status of the read. Also called by the mainline,
 * to read in a file specified on the command line as
 * an argument.
 */
extern FILE * ffp;
#define fname ((char *)0x80)

ovmain( flag )
{
	register LINE	*lp1;
	register LINE	*lp2;
	register int	i;
	register WINDOW	*wp;
	register BUFFER	*bp;
	register int	s;
	register int	nbytes;
	register int	nline;
	char		line[NLINE+1];

	if (flag && ((s=bclear(bp=curbp)) != TRUE))/* Might be old.	*/
		return (s);
	bp->b_flag &= ~(BFTEMP|BFCHG);
	if (flag) strcpy(bp->b_fname, fname);
	if (( ffp = fopen(fname, "r" )) == NULL)
	{	mlwrite( "[New file]" );
		goto out;
	}
	mlwrite("[Reading]");
	nline = 0;
	while ( fgets( line, NLINE, ffp) != NULL )
	{	nbytes = strlen(line);
		while ( ( s = line[ nbytes - 1 ] ) == '\n' || s == '\r' )
			if ( --nbytes <= 0 ) break;
		if ( nbytes == strlen( line ))
			mlwrite( "Long Line" );
		
		if ((lp1=xlalloc(nbytes)) == NULL)
		{	s = FIOERR;		/* Keep message on the	*/
			break;			/* display.		*/
		}
		lp2 = (flag) ? lback(curbp->b_linep) :
			(( curwp->w_doto == 0 )
			? curwp->w_dotp->l_fp 
			: curwp->w_dotp );
		lp1->l_fp = lp2->l_fp;
		lp2->l_fp = lp1;
		lp1->l_bp = lp2;
		lp1->l_fp->l_bp = lp1;
		curwp->w_dotp = lp1;
		curwp->w_doto = 0;

		/* for (i=0; i<nbytes; ++i)
		**	lputc(lp1, i, line[i]);
		*/
		blockmv( &lp1->l_text[0], &line[0], nbytes );

		++nline;
	}
	fclose(ffp);		/* Ignore errors.	*/
	if (s == FIOEOF)	/* Don't zap message!	*/
	{	mlwrite("[Read %d lines]", nline);
	}
out:
	for (wp=wheadp; wp!=NULL; wp=wp->w_wndp)
	{	if (wp->w_bufp == curbp)
		{	wp->w_linep = lforw(curbp->b_linep);
			wp->w_dotp  = ( flag )
				? lforw(curbp->b_linep)
				: curwp->w_dotp;
			wp->w_doto  = 
			wp->w_markp = 
			wp->w_marko = 0;
			wp->w_flag |= WFMODE|WFHARD;
		}
	}
	if (s == FIOERR)			/* False if error.	*/
		return (FALSE);
	return (TRUE);
}

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
xlalloc(size)
int	size;
{
	register LINE	*lp;

	if ((lp = (LINE *) malloc(( sizeof(LINE)-1 ) +size)) == NULL)
	{	mlwrite("No memory");
		return (NULL);
	}
	lp->l_size = lp->l_used = size;
	return (lp);
}
