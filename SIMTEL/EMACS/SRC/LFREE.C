#include	"stdio.h"
#include	"ed.h"

/*
 * Delete line "lp". Fix all of the
 * links that might point at it (they are
 * moved to offset 0 of the next line.
 * Unlink the line from whatever buffer it
 * might be in. Release the memory. The
 * buffers are updated too; the magic conditions
 * described in the above comments don't hold
 * here.
 */
lfree(lp)
LINE	*lp;
{
	register BUFFER	*bp;
	register WINDOW	*wp;
#define wp ((WINDOW *)bp)
#define llfp (*(LINE **)0xac)
	register LINE * lp1;

	bp = wheadp;
	llfp = ( lp1 = lp )->l_fp;
	while (wp != NULL)
	{	if ( wp->w_linep == lp1 )
			wp->w_linep = llfp;
		if ( wp->w_dotp  == lp1 )
		{	wp->w_dotp  = llfp;
			wp->w_doto  = 0;
		}
		if ( wp->w_markp == lp1 )
		{	wp->w_markp = llfp;
			wp->w_marko = 0;
		}
		wp = wp->w_wndp;
	}
	bp = bheadp;
	while (bp != NULL)
	{	/* if ( bp->b_nwnd == 0 ) */
		/* { */	if ( bp->b_dotp  == lp1 )
			{	bp->b_dotp = llfp;
				bp->b_doto = 0;
			}
			if ( bp->b_markp == lp1 )
			{	bp->b_markp = llfp;
				bp->b_marko = 0;
			}
		/* } */
		bp = bp->b_bufp;
	}
	lp1->l_bp->l_fp = llfp;
	llfp->l_bp = lp->l_bp;
	free((char *) lp1);
}
