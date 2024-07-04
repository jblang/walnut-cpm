extern FILE * ffp;
extern int ovreq, ovreq2, ovsub, ovsub2;
extern char Argbuf[128];
/* writeout.c: #included by filesave.c and filewrite.c
 * This function starts to write a file. It makes a
 * CP/M-style backup file, then sets up an overlay thread,
 * ovopwr33 and ovwrit34.
 */

writeout(fn)
char	*fn;
{
	register int	s;
/*	register LINE	*lp; */
/*	register int	nline; */
	char backname[NFILEN];

	strcpy( backname, fn );
	s = 0;
	while ( backname[s] && backname[s] != '.' ) s++;
	if ( backname[s] == '.') backname[++s] = 0;
	else { backname[++s] = '.'; backname[++s] = 0; }
	strcat( backname, "bak" );
	rename( fn, backname );
		/* CP/M style backup file has been created. */

	strcpy( Argbuf, fn );
	ovreq = 33;
	ovreq2 = 34;
	return ( 1 );
#ifdef NEVER
	s = TRUE;
	if ((ffp=fopen(fn, "w")) == NULL)	/* Open writes message.	*/
		return (ctrlg());
	lp = lforw(curbp->b_linep);		/* First line.		*/
	nline = 0;				/* Number of lines.	*/
	while (lp != curbp->b_linep)
	{	if ( fwrite( &lp->l_text[0], 1,
			llength(lp), ffp) != llength(lp)
		|| putc( '\r', ffp ) == EOF
		|| putc( '\n', ffp ) == EOF )
		{	s = FALSE;
			mlwrite("Write I/O error");
			break;
		}
		++nline;
		lp = lforw(lp);
	}
	putc( ('z'&0x1f), ffp );
	fclose( ffp );
	if (s == TRUE)
	{	/* No write error. */
		mlwrite("[Wrote %d lines]", nline);
	}
	return ( s );
#endif
}
