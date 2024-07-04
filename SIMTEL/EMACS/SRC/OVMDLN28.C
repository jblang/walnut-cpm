#include "medisp.h"

/*
 * Redisplay the mode line for
 * the window pointed to by the "wp".
 * This is the only routine that has any idea
 * of how the modeline is formatted. You can
 * change the modeline format by hacking at
 * this routine. Called by "update" any time
 * there is a dirty window.
 */
extern char * Argv[];
ovmain()
{
	register WINDOW	*wp;
	register char	*cp;
	register int	c;
	register int	n;
	register BUFFER	*bp;

	wp = (WINDOW *) Argv[3];
	n = wp->w_toprow+wp->w_ntrows;		/* Location.		*/
	vscreen[n]->v_flag |= VFCHG;		/* Redraw next time.	*/
	vtmove(n, 0);				/* Seek to right line.	*/
	vtputc('=');
	bp = wp->w_bufp;
	if ((bp->b_flag&BFCHG) != 0)		/* "*" if changed.	*/
		vtputc('*');
	else
		vtputc('=');
	n  = 2;
	cp = " BetzaEMACS == ";			/* Buffer name.		*/
	while ((c = *cp++) != 0) {
		vtputc(c);
		++n;
	}
	cp = &bp->b_bname[0];
	while ((c = *cp++) != 0) {
		vtputc(c);
		++n;
	}
	vtputc(' ');
	++n;
	if (bp->b_fname[0] != 0) {		/* File name.		*/
		cp = "== File: ";
		while ((c = *cp++) != 0) {
			vtputc(c);
			++n;
		}
		cp = &bp->b_fname[0];
		while ((c = *cp++) != 0) {
			vtputc(c);
			++n;
		}
		vtputc(' ');
		++n;
	}
#ifdef	WFDEBUG
	vtputc('=');
	vtputc((wp->w_flag&WFMODE)!=0  ? 'M' : '-');
	vtputc((wp->w_flag&WFHARD)!=0  ? 'H' : '-');
	vtputc((wp->w_flag&WFEDIT)!=0  ? 'E' : '-');
	vtputc((wp->w_flag&WFMOVE)!=0  ? 'V' : '-');
	vtputc((wp->w_flag&WFFORCE)!=0 ? 'F' : '-');
	n += 6;
#endif
	while (n < 80) {		/* Pad to full width.	*/
		vtputc('=');
		++n;
	}
}
