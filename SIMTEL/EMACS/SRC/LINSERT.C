#include	"stdio.h"
#include	"ed.h"

/*
 * Insert "n" copies of the character "c"
 * at the current location of dot. In the easy case
 * all that happens is the text is stored in the line.
 * In the hard case, the line has to be reallocated.
 * When the window list is updated, take special
 * care; I screwed it up once. You always update dot
 * in the current window. You update mark, and a
 * dot in another window, if it is greater than
 * the place where you did the insert. Return TRUE
 * if all is well, and FALSE on errors.
 */
linsert(n, c)
{
#define cp1 (*(char **)0xa0)
#define cp2 (*(char **)0xa2)
	register LINE	*lp1;	/* 23 times. */
#define lp2 (*(LINE **)0xa8)
#define lp3 (*(LINE **)0xa4)
#define doto (*(int *)0xa6)
	register WINDOW	*wp;	/* 15 times, but the best! */
#define localn (*(int *)0xaa)

	lchange( WFEDIT );
	wp = curwp;
	localn = n;

	if (( lp1 = wp->w_dotp ) == curbp->b_linep )
	{	/* At the end: special. Assert that w_doto == 0 */
		/* There is no line at all here, so we must
		** allocate a new line ( lp2 ) and link it in.
		*/
		if ( ( lp2 = lalloc( localn )) == NULL )
		{	/* must be out of memory. */
retfalse:		return ( 0 );
		}

		( lp3 = lp1->l_bp )->l_fp = lp2;
		lp2->l_fp = lp1;
		( wp->w_dotp = lp1->l_bp = lp2)->l_bp = lp3;

#ifdef SANITY
		if ( wp->w_doto = localn )
		{	/* not zero count. */
			clear( &lp2->l_text[0], localn, c );
		}
#else
		clear( &lp2->l_text[0], ( wp->w_doto = localn ), c );
#endif
rettrue:	return ( 1 );
	}
	doto = wp->w_doto;
	if ( ( lp1->l_used + localn ) > lp1->l_size )
	{	/* The lp1 line grows and must be reallocated. */
		if ( ( lp2 = lalloc( lp1->l_used + localn )) == NULL )
			goto retfalse;

		blockmv( lp2, lp1, 4 );
			/* lp2->l_fp = lp1->l_fp; */
			/* lp2->l_bp = lp1->l_bp; */
		blockmv( lp2->l_text, lp1->l_text, doto );
		blockmv( &lp2->l_text[ localn + doto ], 
			&lp1->l_text[ doto ],
			lp1->l_used - doto );
		lp1->l_fp->l_bp = lp1->l_bp->l_fp = lp2;
		free((char *) lp1);
	} else
	{	/* Easy: in place	*/
		(lp2 = lp1)->			/* Pretend new line	*/
			l_used += localn;
		cp2 = &lp1->l_text[lp1->l_used];
		cp1 = cp2-localn;
		while (cp1 != &lp1->l_text[doto])
			*--cp2 = *--cp1;
	}
	if ( localn ) clear( &lp2->l_text[doto], localn, c );
	wp = wheadp;				/* Update windows	*/
	while (wp != NULL)
	{	if (wp->w_linep == lp1)
			wp->w_linep = lp2;
		if (wp->w_dotp == lp1)
		{	wp->w_dotp = lp2;
			if ( wp == curwp || wp->w_doto > doto )
			{	wp->w_doto += localn;
			}
		}
		if ( wp->w_markp == lp1 )
		{	wp->w_markp = lp2;
			if ( wp->w_marko > doto ) wp->w_marko += localn;
		}
		wp = wp->w_wndp;
	}
	return (TRUE);
}
