
#define	CPM80	1			/* CP/M			*/

#define TELEVIDEO 1

#define	CVMVAS	1			/* C-V, M-V arg. in screens.	*/

#define NFILEN 15
#define NBUFN 15
#define NLINE 128
#define NPAT 20

#define	HUGE	1000			/* Huge number			*/

#define	METACH	0x1B			/* M- prefix,   Control-[, ESC	*/
#define CMINUSCH 0x1c

#define	META	0x0200			/* Meta flag, or'ed in		*/
#define	CTLX	0x0400			/* ^X flag, or'ed in		*/
#define MAGIC   0x0100			/* MAIGIC flag */

#define	FALSE	0			/* False, no, bad, etc.		*/
#define	TRUE	1			/* True, yes, good, etc.	*/
#define	ABORT	2			/* Death, ^G, abort, etc.	*/

#define	FIOSUC	0			/* File I/O, success.		*/
#define	FIOFNF	1			/* File I/O, file not found.	*/
#define	FIOEOF	2			/* File I/O, end of file.	*/
#define	FIOERR	3			/* File I/O, error.		*/

#define	CFCPCN	0x0001			/* Last command was C-P, C-N	*/
#define	CFKILL	0x0002			/* Last command was a kill	*/

/*
 * There is a window structure allocated for
 * every active display window. The windows are kept in a
 * big list, in top to bottom screen order, with the listhead at
 * "wheadp". Each window contains its own values of dot and mark.
 * The flag field contains some bits that are set by commands
 * to guide redisplay; although this is a bit of a compromise in
 * terms of decoupling, the full blown redisplay is just too
 * expensive to run for every input character. 
 */
typedef	struct	WINDOW {
	struct	LINE *w_dotp;		/* Line containing "."		*/
	short	w_doto;			/* Byte offset for "."		*/
	struct	LINE *w_markp;		/* Line containing "mark"	*/
	short	w_marko;		/* Byte offset for "mark"	*/
	struct	WINDOW *w_wndp;		/* Next window			*/
	struct	BUFFER *w_bufp;		/* Buffer displayed in window	*/
	struct	LINE *w_linep;		/* Top line in the window	*/
	char	w_toprow;		/* Origin 0 top row of window	*/
	char	w_ntrows;		/* # of rows of text in window	*/
	char	w_force;		/* If NZ, forcing row.		*/
	char	w_flag;			/* Flags.			*/
}	WINDOW;

#define	WFFORCE	0x01			/* Window needs forced reframe	*/
#define	WFMOVE	0x02			/* Movement from line to line	*/
#define	WFEDIT	0x04			/* Editing within a line	*/
#define	WFHARD	0x08			/* Better to a full display	*/
#define	WFMODE	0x10			/* Update mode line.		*/

/*
 * Text is kept in buffers. A buffer header, described
 * below, exists for every buffer in the system. The buffers are
 * kept in a big list, so that commands that search for a buffer by
 * name can find the buffer header. There is a safe store for the
 * dot and mark in the header, but this is only valid if the buffer
 * is not being displayed (that is, if "b_nwnd" is 0). The text for
 * the buffer is kept in a circularly linked list of lines, with
 * a pointer to the header line in "b_linep".
 */
typedef	struct	BUFFER {
	struct	LINE *b_dotp;		/* Link to "." LINE structure	*/
	short	b_doto;			/* Offset of "." in above LINE	*/
	struct	LINE *b_markp;		/* The same as the above two,	*/
	short	b_marko;		/* but for the "mark"		*/
	struct	BUFFER *b_bufp;		/* Link to next BUFFER		*/
	struct	LINE *b_linep;		/* Link to the header LINE	*/
	char	b_nwnd;			/* Count of windows on buffer	*/
	char	b_flag;			/* Flags			*/
	char	b_fname[NFILEN];	/* File name			*/
	char	b_bname[NBUFN];		/* Buffer name			*/
}	BUFFER;

#define	BFTEMP	0x01			/* Internal temporary buffer	*/
#define	BFCHG	0x02			/* Changed since last write	*/

/*
 * The starting position of a
 * region, and the size of the region in
 * characters, is kept in a region structure.
 * Used by the region commands.
 */
typedef	struct	{
	struct	LINE *r_linep;		/* Origin LINE address.		*/
	short	r_offset;		/* Origin LINE offset.		*/
	short	r_size;			/* Length in characters.	*/
}	REGION;

/*
 * All text is kept in circularly linked
 * lists of "LINE" structures. These begin at the
 * header line (which is the blank line beyond the
 * end of the buffer). This line is pointed to by
 * the "BUFFER". Each line contains a the number of
 * bytes in the line (the "used" size), the size
 * of the text array, and the text. The end of line
 * is not stored as a byte; it's implied. Future
 * additions will include update hints, and a
 * list of marks into the line.
 */
typedef	struct LINE {
	struct	LINE *l_fp;		/* Link to the next line	*/
	struct	LINE *l_bp;		/* Link to the previous line	*/
	char	l_size;			/* Allocated size		*/
	char	l_used;			/* Used size			*/
	char	l_text[1];		/* A bunch of characters.	*/
}	LINE;

#define	lforw(lp)	((lp)->l_fp)
#define	lback(lp)	((lp)->l_bp)
#define	lgetc(lp, n)	((lp)->l_text[(n)])
#define	lputc(lp, n, c)	((lp)->l_text[(n)]=(c))
#define	llength(lp)	((lp)->l_used)

extern	int	fillcol;		/* Fill column			*/
extern	int	currow;			/* Cursor row			*/
extern	int	curcol;			/* Cursor column		*/
extern	int	thisflag;		/* Flags, this command		*/
extern	int	lastflag;		/* Flags, last command		*/
extern	int	curgoal;		/* Goal for C-P, C-N		*/
extern	int	mpresf;			/* Stuff in message line	*/
extern	int	sgarbf;			/* State of screen unknown	*/
extern	WINDOW	*curwp;			/* Current window		*/
extern	BUFFER	*curbp;			/* Current buffer		*/
extern	WINDOW	*wheadp;		/* Head of list of windows	*/
extern	BUFFER	*bheadp;		/* Head of list of buffers	*/
extern	BUFFER	*blistp;		/* Buffer for C-X C-B		*/
extern	char	pat[NPAT];			/* Search pattern		*/

extern	BUFFER	*bfind();		/* Lookup a buffer by name	*/
extern	WINDOW	*wpopup();		/* Pop up window creation	*/
extern	LINE	*lalloc();		/* Allocate a line		*/
extern char cclass[128];
