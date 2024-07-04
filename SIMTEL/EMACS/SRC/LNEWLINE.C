#include	"stdio.h"
#include	"ed.h"

/*
 * Insert a newline into the buffer
 * at the current location of dot in the current
 * window. The funny ass-backwards way it does things
 * is not a botch; it just makes the last line in
 * the file not a special case. Return TRUE if everything
 * works out and FALSE on error (memory allocation
 * failure). The update of dot and mark is a bit
 * easier then in the above case, because the split
 * forces more updating.
 */
lnewline()
{
	register WINDOW	*wp;
	register LINE	*lp1;
#define lp2 (*(LINE **)0x90)
#define doto  (*(int *)0x92)
/*	register LINE	*lp2; */
/*	register int	doto; */

	lchange( WFHARD );
	wp = curwp;
	lp1  = wp->w_dotp;			/* Get the address and	*/
	doto = wp->w_doto;			/* offset of "."	*/
	if ( ( lp2 = lalloc( doto )) == NULL )	/* New first half line	*/
		return (FALSE);
	blockmv( &lp2->l_text[0], &lp1->l_text[0], doto );
	blockmv( &lp1->l_text[ 0 ], &lp1->l_text[ doto ],
		lp1->l_used - doto );
	lp1->l_used -= doto;
	lp2->l_bp = lp1->l_bp;
	lp1->l_bp = lp2->l_bp->l_fp = lp2;
	lp2->l_fp = lp1;
	wp = wheadp;				/* Windows		*/
	while (wp != NULL)
	{	if (wp->w_linep == lp1)
			wp->w_linep = lp2;
		if (wp->w_dotp == lp1)
		{	if (wp->w_doto < doto)
				wp->w_dotp = lp2;
			else
				wp->w_doto -= doto;
		}
		if (wp->w_markp == lp1)
		{	if (wp->w_marko < doto)
				wp->w_markp = lp2;
			else
				wp->w_marko -= doto;
		}
		wp = wp->w_wndp;
	}	
	return (TRUE);
}
