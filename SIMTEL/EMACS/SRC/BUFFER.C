 /*
 * Buffer management.
 * Some of the functions are internal,
 * and some are actually attached to user
 * keys. Like everyone else, they set hints
 * for the display system.
 */
#include	"stdio.h"
#include	"ed.h"

/*
 * Find a buffer, by name. Return a pointer
 * to the BUFFER structure associated with it. If
 * the named buffer is found, but is a TEMP buffer (like
 * the buffer list) conplain. If the buffer is not found
 * and the "cflag" is TRUE, create it. The "bflag" is
 * the settings for the flags in in buffer.
 */
BUFFER	*
bfind(bname, cflag, bflag)
char	*bname;
{
	register BUFFER	*bp;
	register LINE	*lp;

	bp = bheadp;
	while (bp != NULL)
	{	if ( ! strcmp( bname, bp->b_bname ))
		{	/* if ((bp->b_flag&BFTEMP) != 0) */
			/* {	mlwrite("Cannot select builtin buffer"); */
			/*	return (NULL); */
			/* } */
			return (bp);
		}
		bp = bp->b_bufp;
	}
	if (cflag != FALSE)
	{	if ((bp=(BUFFER *)malloc(sizeof(BUFFER))) == NULL)
			return (NULL);
		if ((lp=lalloc(0)) == NULL)
		{	free((char *) bp);
			return (NULL);
		}
		bp->b_bufp = bheadp;
		bheadp = bp;
		lp->l_fp =
		lp->l_bp =
		bp->b_dotp  =
		bp->b_linep = lp;
/****		bp->b_doto  = ** malloc() already did this. */
/****		bp->b_markp = */
/****		bp->b_marko = */
/****		bp->b_nwnd  = 0; */
		bp->b_flag  = bflag;

/****		strcpy(bp->b_fname, ""); ** malloc() did it. */
		strcpy(bp->b_bname, bname);
	}
	return (bp);
}

/*
 * This routine blows away all of the text
 * in a buffer. If the buffer is marked as changed
 * then we ask if it is ok to blow it away; this is
 * to save the user the grief of losing text. The
 * window chain is nearly always wrong if this gets
 * called; the caller must arrange for the updates
 * that are required. Return TRUE if everything
 * looks good.
 */
bclear(bp)
BUFFER	*bp;
{
	register LINE	*lp;
	
	if (( bp->b_flag & ( BFTEMP | BFCHG )) == BFCHG
	&& mlyesno("Junk changes") != TRUE) return (0);
	bp->b_flag  &= ~BFCHG;			/* Not changed		*/
	while ((lp=lforw(bp->b_linep)) != bp->b_linep)
		lfree(lp);
	bp->b_dotp  = bp->b_linep;		/* Fix "."		*/
	bp->b_doto  =
	bp->b_markp =
	bp->b_marko = 0;
	return (TRUE);
}
