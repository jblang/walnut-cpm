/*
 * The functions in this file
 * handle redisplay. There are two halves,
 * the ones that update the virtual display
 * screen, and the ones that make the physical
 * display screen the same as the virtual
 * display screen. These functions use hints
 * that are left in the windows by the
 * commands.
 */
#define OWNER
#include "medisp.h"

/*
 * Make sure that the display is
 * right. This is a three part process. First,
 * scan through all of the windows looking for dirty
 * ones. Check the framing, and refresh the screen.
 * Second, make sure that "currow" and "curcol" are
 * correct for the current window. Third, make the
 * virtual and physical screens the same.
 */
extern char * Argv[];
update()
{
	register LINE	*lp;
	register WINDOW	*wp;
#define vp1 (*(VIDEO **)0x108)
#define i   (*(int *)0x10c)
#define c   (*(int *)0x10e)
#define lp2 (*(LINE **)0x110)
#define wrows (*(int *)0x112)
/* lp2 and wrows will be wiped out when meupdate is called. */

	wp = wheadp;
	while (wp != NULL)
	{	/* Look at any window with update flags set on.		*/
		wrows = wp->w_ntrows;
		lp2 = wp->w_bufp->b_linep;

		if (wp->w_flag != 0)
		{	/* If not force reframe, check the framing.	*/
			if ( ( wp->w_flag & WFFORCE ) == 0 )
			{	lp = wp->w_linep;
				for ( i = 0 ; ++i <= wrows; )
				{	if ( lp == wp->w_dotp )
						goto out;
					if ( lp == lp2 )
						break;
					lp = lforw(lp);
				}
			}
			/* Not acceptable, better compute a new value	*/
			/* for the line at the top of the window. Then	*/
			/* set the "WFHARD" flag to force full redraw.	*/
			if ( ( i = wp->w_force ) > 0)
			{	if ( --i >= wrows )
					i = wrows - 1;
			} else if ( i < 0 )
			{	i += wrows;
				if ( i < 0 ) i = 0;
			} else 	i = wrows >> 1;
			lp = wp->w_dotp;
			while ( --i >= 0 && lback(lp) != lp2 )
			{	lp = lback(lp);
			}
			wp->w_linep = lp;
			wp->w_flag |= WFHARD;	/* Force full.		*/
out:
/* Try to use reduced update. Mode line update	*/
/* has its own special flag. The fast update is	*/
/* used if the only thing to do is within the	*/
/* line editing.				*/
			lp = wp->w_linep;
			i  = wp->w_toprow;
			if ( wp->w_flag & WFMODE )
			{	Argv[3] = (char *)wp;
				ovloader( 28, 0 );
			}	/* modeline(wp); */
			if ( wp->w_flag & WFHARD )
			{	while ( i < wp->w_toprow + wrows )
				{	if ( ! cramline( lp, wp ))
						lp = lforw(lp);
					++i;/* cramline uses i... */
				}
			}
			else if (wp->w_flag & WFEDIT)
			{	while (lp != wp->w_dotp)
				{	++i;
					lp = lforw(lp);
				}
				cramline( lp, wp );
			}
			wp->w_flag  = 0;
			wp->w_force = 0;
		}
/*#if	WFDEBUG
/*		modeline(wp);
/*		wp->w_flag =  0;
/*		wp->w_force = 0;
/*#endif*/
		wp = wp->w_wndp;
	}
	/* Always recompute the row and column number of the hardware	*/
	/* cursor. This is the only update for simple moves.		*/
	lp = curwp->w_linep;
	currow = curwp->w_toprow;
	while (lp != curwp->w_dotp)
	{	++currow;
		lp = lforw(lp);
	}
	curcol = 0;
	i = 0;
	while (i < curwp->w_doto)
	{	c = lgetc(lp, i++);
		if (c == '\t') curcol |= 0x07;
		else if ( ! isinsert( c )) ++curcol;
		++curcol;
	}
	if (curcol >= 80)		/* Long line.		*/
		curcol = 79;
	/* Special hacking if the screen is garbage. Clear the hardware	*/
	/* screen, and update your copy to agree with it. Set all the	*/
	/* virtual screen change bits, to force a full update.		*/
	if (sgarbf != FALSE)
	{	for ( i=0; i < 23; ++i )
		{	vscreen[i]->v_flag |= VFCHG;
			clear( &( pscreen[ i ]->v_text[ 0 ]), 80, ' ' );
		}
		ansiclear();	/*clear */
		ttrow = ttcol = 
		sgarbf =	/* Erase-page clears	*/
		mpresf = 0;	/* the message area.	*/
	}
	/* Make sure that the physical and virtual displays agree.	*/
	/* Unlike before, the "updateline" code is only called with a	*/
	/* line that has been updated for sure.				*/
	for (i=0; i<23; ++i)
	{	vp1 = vscreen[i];
		if (( vp1->v_flag & VFCHG ) != 0 )
		{	vp1->v_flag &= ~VFCHG;
			updateline( i, &vp1->v_text[0], 
				&pscreen[i]->v_text[0]);
		}
	}
	/* Finally, update the hardware cursor and flush out buffers.	*/
	movecursor( currow, curcol );
}

cramline( lp, wp )
LINE * lp;
WINDOW * wp;
{	register int j, k, retval;

	retval = 1;
	vscreen[i]->v_flag |= VFCHG;
	vtmove( i, 0 );
	if (lp != wp->w_bufp->b_linep)
	{	k = llength(lp);
		for ( retval = j = 0; j < k; ++j )
			vtputc(lgetc(lp, j));
	}
	vteeol();
	return ( retval );
}
