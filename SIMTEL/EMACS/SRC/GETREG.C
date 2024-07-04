/* getreg.c is included by overlaid region commands.
 * This routine figures out the
 * bounds of the region in the current window, and
 * fills in the fields of the "REGION" structure pointed
 * to by "rp". Because the dot and mark are usually very
 * close together, we scan outward from dot looking for
 * mark. This should save time. Return a standard code.
 * Callers of this routine should be prepared to get
 * an "ABORT" status; we might make this have the
 * conform thing later.
 */
getregion(rp)
register REGION	*rp;
{
	register LINE	*flp;
	register LINE	*blp;
	register int	fsize;
	register int	bsize;

	if (curwp->w_markp == NULL) {
		mlwrite("No mark set in this window");
		return (FALSE);
	}
	if (curwp->w_dotp == curwp->w_markp) {
		rp->r_linep = curwp->w_dotp;
		if (curwp->w_doto < curwp->w_marko) {
			rp->r_offset = curwp->w_doto;
			rp->r_size = curwp->w_marko-curwp->w_doto;
		} else {
			rp->r_offset = curwp->w_marko;
			rp->r_size = curwp->w_doto-curwp->w_marko;
		}
		return (TRUE);
	}
	blp = curwp->w_dotp;
	bsize = curwp->w_doto;
	flp = curwp->w_dotp;
	fsize = llength(flp)-curwp->w_doto+1;
	while (flp!=curbp->b_linep || lback(blp)!=curbp->b_linep) {
		if (flp != curbp->b_linep) {
			flp = lforw(flp);
			if (flp == curwp->w_markp) {
				rp->r_linep = curwp->w_dotp;
				rp->r_offset = curwp->w_doto;
				rp->r_size = fsize+curwp->w_marko;
				return (TRUE);
			}
			fsize += llength(flp)+1;
		}
		if (lback(blp) != curbp->b_linep) {
			blp = lback(blp);
			bsize += llength(blp)+1;
			if (blp == curwp->w_markp) {
				rp->r_linep = blp;
				rp->r_offset = curwp->w_marko;
				rp->r_size = bsize - curwp->w_marko;
				return (TRUE);
			}
		}
	}
	mlwrite("Bug: lost mark");
	return (FALSE);
}
