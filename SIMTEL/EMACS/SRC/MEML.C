#include "medisp.h"
/*
 * Erase the message line.
 * This is a special routine because
 * the message line is not considered to be
 * part of the virtual screen. It always works
 * immediately; the terminal buffer is flushed
 * via a call to the flusher.
 */
mlerase()
{
	movecursor(23, 0);
	ansieeol();
	mpresf = FALSE;
}

/*
 * Ask a yes or no question in
 * the message line. Return either TRUE,
 * FALSE, or ABORT. The ABORT status is returned
 * if the user bumps out of the question with
 * a ^G. Used any time a confirmation is
 * required.
 */
mlyesno(prompt)
char	*prompt;
{
	register int	s;
	char	buf[64];

	strcpy(buf, prompt);
	strcat(buf, " [y/n]? ");
	s = mlreply(buf, buf, sizeof(buf));
	if ( s == ABORT ) return (ABORT);
	if ( s != FALSE && ( buf[0] == 'y' || buf[0] == 'Y' ))
		return ( 1 );
	return ( 0 );
}

/*
 * Write a prompt into the message
 * line, then read back a response. Keep
 * track of the physical position of the cursor.
 * If we are in a keyboard macro throw the prompt
 * away, and return the remembered response. This
 * lets macros run at full speed. The reply is
 * always terminated by a carriage return. Handle
 * erase, kill, and abort keys.
 */
mlreply(prompt, buf, nbuf)
char	*prompt;
char	*buf;
{
	register int	cpos;
	register int	c;

	cpos = 0;
	mlwrite(prompt);
	for (;;)
	{	switch ( c = getstroke())
		{
		case 0x0D:			/* Return, end of line	*/
			buf[cpos++] = 0;
			conout( '\r' );
			ttcol = 0;
			if (buf[0] == 0)
				return (FALSE);
			return (TRUE);

		case 0x07:			/* Bell, abort		*/
			conout( '^' );
			conout( 'G' );
			ttcol += 2;
			ctrlg();
			return (ABORT);

		case 0x7F:			/* Rubout, erase	*/
		case 0x08:			/* Backspace, erase	*/
			if (cpos != 0)
			{	crtbs();
				if (buf[--cpos] < 0x20)
				{	crtbs();
				}
			}
			break;
#ifdef NEVER
		case 0x15:			/* C-U, kill		*/
			while (cpos != 0)
			{	crtbs();
				if (buf[--cpos] < 0x20)
				{	crtbs();
				}
			}
			break;
#endif
		default:
			if (cpos < nbuf-1)
			{	buf[cpos++] = c;
				if (c < ' ')
				{	conout( '^' );
					++ttcol;
					c ^= 0x40;
				}
				conout( c );
				++ttcol;
			}
		}
	}
}
crtbs()
{	conout( '\b' );
	conout( ' '  );
	conout( '\b' );
	--ttcol;
}
conout( c )
{	bios( 4, c );
}
/*
 * Write a message into the message
 * line. Keep track of the physical cursor
 * position. A small class of printf like format
 * items is handled. Assumes the stack grows
 * down; this assumption is made by the "++"
 * in the argument scan loop. Set the "message
 * line" flag TRUE.
 */
mlwrite(fmt, arg)
char	*fmt;
{
	register int	c;
	register char	*ap;

	movecursor(23, 0);
	ap = (char *) &arg;
	while ((c = *fmt++) != 0)
	{	if (c != '%') goto out_it;
		c = *fmt++;
		switch (c)
		{	case 'd':
				mlputi(*(int *)ap, 10);
				ap += sizeof(int);
				break;

#ifdef NEVER
			case 'o':
				mlputi(*(int *)ap,  8);
				ap += sizeof(int);
				break;

			case 'x':
				mlputi(*(int *)ap, 16);
				ap += sizeof(int);
				break;

			case 'D':
				mlputli(*(long *)ap, 10);
				ap += sizeof(long);
				break;
#endif
			case 's':
				mlputs(*(char **)ap);
				ap += sizeof(char *);
				break;

			default:
out_it:				conout( c );
				++ttcol;
		}
	}
	ansieeol();
	mpresf = TRUE;
}

/*
 * Write out a string.
 * Update the physical cursor position.
 * This assumes that the characters in the
 * string all have width "1"; if this is
 * not the case things will get screwed up
 * a little.
 */
mlputs(s)
char	*s;
{
	register int	c;

	while ((c = *s++) != 0)
	{	conout( c );
		++ttcol;
	}
}

/*
 * Write out an integer, in
 * the specified radix. Update the physical
 * cursor position. This will not handle any
 * negative numbers; maybe it should.
 */
mlputi(i, r)
{
	register int	q;
	static char hexdigits[] = "0123456789ABCDEF";

	if (i < 0)
	{	i = -i;
		conout( '-');
	}
	q = i/r;
	if (q != 0) mlputi(q, r);
	conout( hexdigits[i%r]);
	++ttcol;
}
#ifdef NEVER
/*
 * do the same except as a long integer.
 */
mlputli(l, r)
long l;
{
	register long q;

	if (l < 0)
	{	l = -l;
		conout( '-');
	}
	q = l/r;
	if (q != 0) mlputli(q, r);
	conout( (int)(l%r)+'0');
	++ttcol;
}
#endif
