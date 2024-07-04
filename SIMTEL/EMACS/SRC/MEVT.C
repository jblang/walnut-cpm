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
#include "medisp.h"

/*
 * Set the virtual cursor to
 * the specified row and column on the
 * virtual screen. There is no checking for
 * nonsense values; this might be a good
 * idea during the early stages.
 */
vtmove(row, col)
int row, col;
{
	vtrow = row;
	vtcol = col;
}

/*
 * Write a character to the
 * virtual screen. The virtual row and
 * column are updated. If the line is too
 * long put a "$" in the last column.
 * This routine only puts printing characters
 * into the virtual terminal buffers.
 * Only column overflow is checked.
 */
vtputc(c)
int	c;
{
	register char *vp;

	if (vtcol >= 80)
	{	vscreen[vtrow]->v_text[79] = '$';
		return 0;
	}
	if ( isinsert( c ))
	{	vscreen[vtrow]->v_text[vtcol++] = c;
		return 1;
	}
	vp = &vscreen[vtrow]->v_text[vtcol];
	if (c == '\t') 
	{	do
		{	*(vp++) = ' ';
		} while (( ++vtcol & 7 ) && vtcol < 80);
	} else
	{	*(vp++) = '^';
		*vp = (c ^ 0x40);
		vtcol += 2;
	}
	return 1;
}

/*
 * Erase from the end of the
 * software cursor to the end of the
 * line on which the software cursor is
 * located.
 */
vteeol()
{	clear( &vscreen[vtrow]->v_text[vtcol], 
		80 - vtcol, ' ' );
}
