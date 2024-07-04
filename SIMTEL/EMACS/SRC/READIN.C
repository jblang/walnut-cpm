/* included... */
extern FILE * ffp;
extern int ovsub, ovreq, ovsub2, ovreq2;
/*
 * Read file "fname" into the current
 * buffer, blowing away any text found there. Called
 * by both the read and visit commands. Return the final
 * status of the read. Also called by the mainline,
 * to read in a file specified on the command line as
 * an argument.
 */
extern char Argbuf[128];
readin( fname, flag )
char	*fname;
{
	register BUFFER	*bp;
	register int	s;

	bp = curbp;
	if ( flag )
	{	if (( s = bclear( bp )) != TRUE )	/* Might be old. */
			return (s);
		strcpy( bp->b_fname, fname );
	}
	bp->b_flag &= ~( BFTEMP | BFCHG );

/* set up overlay thread: */
	strcpy( Argbuf, fname );	/* parameter to fopen() */
	ovreq = 32;	/* first call fopen() overlay. */
	ovreq2 = 27;	/* then call ovread27 */
	ovsub2 = flag;	/* parameter for ovread27 */
	return ( TRUE );
}
