#include	"stdio.h"
#include	"ed.h"

/*
 * Delete a newline. Join the current line
 * with the next line. If the next line is the magic
 * header line always return TRUE; merging the last line
 * with the header line can be thought of as always being a
 * successful operation, even if nothing is done, and this makes
 * the kill buffer work "right". Easy cases can be done by
 * shuffling data around. Hard cases require that lines be moved
 * about in memory. Return FALSE on error and TRUE if all
 * looks ok. Called by "ldelete" only.
 */
ldelnewline()
{
	register WINDOW	*wp;	/* appears 29 times. */
	register LINE	*myline;	/* appears 25 times. */
/*	register LINE	*nextline; */
/*	register LINE	*lp3; */
#define nextline (*(LINE **)0x9c)
#define lp3 (*(LINE **)0x9e)
#define mysize (*(int *)0xa0)

	mysize = ( myline = curwp->w_dotp )->l_used;

	if ( ( nextline = myline->l_fp ) == curbp->b_linep )
	{	/* At the buffer end.	*/
		if ( ! mysize )	/* Blank line. */
			lfree( myline );
rettrue:	return ( 1 );
	}
#ifdef NEVER
To save space, we will ALWAYS allocate a new line
which will contain both myline and nextline.
.	if ( nextline->l_used <= myline->l_size - mysize )
.	{	/* nextline fits in myline. */
.		blockmv( &myline->l_text[mysize],
.			&nextline->l_text[0], nextline->l_used );
.		wp = wheadp;
.		while (wp != NULL)
.		{	if (wp->w_linep == nextline)
.				wp->w_linep = myline;
.			if (wp->w_dotp == nextline)
.			{	wp->w_doto += 
.					( wp->w_dotp  = myline )->
.						l_used;
.			}
.			if (wp->w_markp == nextline)
.			{	wp->w_marko += ( wp->w_markp  = myline )->
.					l_used;
.			}
.			wp = wp->w_wndp;
.		}		
.		mysize += nextline->l_used;
.		(myline->l_fp = nextline->l_fp)->l_bp = myline;
.		free((char *) nextline);
.		return (TRUE);
.	}
#endif
	if ( ( lp3 = lalloc( mysize + nextline->l_used )) == NULL )
		return (FALSE);
	blockmv( &lp3->l_text[0], &myline->l_text[0], mysize );
	blockmv( &lp3->l_text[mysize], 
		&nextline->l_text[0], nextline->l_used );

	myline->l_bp->l_fp = nextline->l_fp->l_bp = lp3;
	lp3->l_fp = nextline->l_fp;
	lp3->l_bp = myline->l_bp;

	wp = wheadp;
	while (wp != NULL)
	{	if ( wp->w_linep == myline || wp->w_linep == nextline )
			wp->w_linep = lp3;

		if (wp->w_dotp == myline) goto xyz2;
		if ( wp->w_dotp == nextline )
		{	wp->w_doto += mysize;
xyz2:			wp->w_dotp  = lp3;
		}

		if (wp->w_markp == myline) goto xyz3;
		if (wp->w_markp == nextline)
		{	wp->w_marko += mysize;
xyz3:			wp->w_markp  = lp3;
		}

		wp = wp->w_wndp;
	}
	free((char *) myline);
	free((char *) nextline);
	return (TRUE);
}
