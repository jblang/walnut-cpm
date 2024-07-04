#include "stdio.h"
#include "ed.h"

/* readin.c, continued in another overlay. */

extern FILE * ffp;
extern char Argbuf[128];

ovmain( flag )
{
	register LINE	*lp1;
	register LINE	*lp2;
	register int	i;
	register WINDOW	*wp;
	register int	s;
	register int	nbytes;
	register int	nline = 0;
	char		line[NLINE+1];

#ifdef NEVER
	if (flag < 0) { flag += 2; goto out; }
#else
	if ( ffp == NULL )
	{	mlwrite( "[New file]" );
		goto out;
	}
	mlwrite("[Reading]");
#endif
	if ( ! flag )
	{	if ( curwp->w_doto )
		{	lnewline();
			curwp->w_doto = 0;
		}
		curwp->w_dotp = curwp->w_dotp->l_bp;
		curbp->b_flag |= BFCHG;
	}
	while ( fgets( line, NLINE, ffp) != NULL )
	{	nbytes = strlen(line);
		if ( line[ --nbytes ] != '\n' )
		{	mlwrite( "Long Line" );
			nbytes++;
		}
		
		if ((lp1=xlalloc(nbytes)) == NULL)
		{	goto closer;
		}
		lp2 = (flag) ? lback(curbp->b_linep) :
			curwp->w_dotp;
		(lp1->l_fp = lp2->l_fp)->l_bp = lp1;
		curwp->w_dotp = (lp1->l_bp = lp2)->l_fp = lp1;

		blockmv( &lp1->l_text[0], &line[0], nbytes );

		++nline;
	}
	mlwrite("[Read %d lines]", nline);
	if ( ! flag ) curwp->w_dotp = curwp->w_dotp->l_fp;
closer:
	fclose(ffp);		/* Ignore errors.	*/
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
