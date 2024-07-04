#include "medisp.h"

/*
 * Update a single line. This
 * does not know how to use insert
 * or delete character sequences; we are
 * using VT52 functionality. Update the physical
 * row and column variables. It does try an
 * exploit erase to end of line. The RAINBOW version
 * of this routine uses fast video.
 */
updateline(row, vline, pline)
char	*vline;
char	*pline;
{
	register char	*cp1;
	register char	*cp2;
#define cp3 (*(char **)0x110)
#define cp4 (*(char **)0x112)
#define cp5 (*(char **)0x114)
#define nbflag (*(int *)0x116)

	cp1 = vline;	/* Compute left match.	*/
	cp2 = pline;
	cp5 = &vline[80];
	while ( *cp1 == *cp2 )
	{	if (cp1 == cp5) return;/* All equal. */
		++cp1;
		++cp2;
	}
	/* This can still happen, even though we only call this routine	*/
	/* on changed lines. A hard update is always done when a line	*/
	/* splits, a massive change is done, or a buffer is displayed	*/
	/* twice. This optimizes out most of the excess updating. A lot	*/
	/* of computes are used, but these tend to be hard operations	*/
	/* that do a lot of update, so I don't really care.		*/
	nbflag = FALSE;
	cp3 = cp5;	/* Compute right match.	*/
	cp4 = &pline[80];
	while ( *(--cp3) == *(--cp4) )
	{	if ( *cp3 != ' ')		/* Note if any nonblank	*/
			nbflag = TRUE;		/* in right match.	*/
	}
	cp5 = ++cp3; ++cp4;
	if (nbflag == FALSE)	/* Erase to EOL ?	*/
	{	while ( cp5 != cp1 && cp5[ -1 ] == ' ' )
			--cp5;
#ifdef NEVER
		if ( cp3 - cp5 <= 3 )		/* Use only if erase is	*/
			cp5 = cp3;		/* fewer characters.	*/
#endif
	}
	movecursor(row, cp1 - &vline[0]);	/* Go to start of line.	*/
	while (cp1 != cp5)	/* Ordinary.		*/
	{	conout( *cp2++ = *cp1++ );
		++ttcol;
		/* *cp2++ = *cp1++; */
	}
	if (cp5 != cp3)		/* Erase.		*/
	{	ansieeol();
		while (cp1 != cp3)
			*cp2++ = *cp1++;
	}
}
/*
 * Send a command to the terminal
 * to move the hardware cursor to row "row"
 * and column "col". The row and column arguments
 * are origin 0. Optimize out random calls.
 * Update "ttrow" and "ttcol".
 */
movecursor(row, col)
int row, col;
{
	if ( row != ttrow || col != ttcol )
	{	ttrow = row;
		ttcol = col;
		ansimove( row, col );
	}
}
