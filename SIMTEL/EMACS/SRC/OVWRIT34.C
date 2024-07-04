#include "stdio.h"
#include "ed.h"

extern FILE * ffp;
extern int ovreq, ovreq2, ovsub, ovsub2;
extern char Argbuf[128];

/*
 * This function performs the details of file
 * writing. Sadly, it looks inside a LINE; Most of the grief is error
 * checking of some sort.
 * fopen() is in overlay 33! Too big!
 */
ovmain()
{
	register WINDOW * wp;
	register int	s;
	register LINE	*lp;
	register int	nline;
	char backname[NFILEN];

	s = TRUE;
	if ( ffp == NULL) return (ctrlg());

	lp = lforw(curbp->b_linep);		/* First line.		*/
	nline = 0;				/* Number of lines.	*/
	while (lp != curbp->b_linep)
	{	if ( fwrite( &lp->l_text[0], 1,
			llength(lp), ffp) != llength(lp)
		|| putc( '\r', ffp ) == EOF
		|| putc( '\n', ffp ) == EOF )
		{	s = FALSE;
			mlwrite("Write I/O error");
			break;
		}
		++nline;
		lp = lforw(lp);
	}
	putc( ('z'&0x1f), ffp );
	fclose( ffp );
	if (s == TRUE)
	{	/* No write error. */
		mlwrite("[Wrote %d lines]", nline);
		curbp->b_flag &= ~BFCHG;
		wp = wheadp;			/* Update mode lines.	*/
		while (wp != NULL)
		{	if (wp->w_bufp == curbp)
				wp->w_flag |= WFMODE;
			wp = wp->w_wndp;
		}
	}
	return ( s );
}
