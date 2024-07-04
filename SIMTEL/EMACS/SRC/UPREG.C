#include	"stdio.h"
#include	"ed.h"
/*
 * Upper case region. Zap all of the lower
 * case characters in the region to upper case. Use
 * the region code to set the limits. Scan the buffer,
 * doing the changes. Call "lchange" to ensure that
 * redisplay is done in all buffers. Bound to 
 * "C-X C-L".
 */
ovmain(x, f, n)
{
	register LINE	*linep;
	register int	loffs;
	register int	c;
	register int	s;
	REGION		region;

	if ((s=getregion(&region)) != TRUE)
		return (s);
	lchange(WFHARD);
	linep = region.r_linep;
	loffs = region.r_offset;
	while (region.r_size--) {
		if (loffs == llength(linep)) {
			linep = lforw(linep);
			loffs = 0;
		} else {
			c = lgetc(linep, loffs);
			if (c>='a' && c<='z')
				lputc(linep, loffs, c-'a'+'A');
			++loffs;
		}
	}
	return (TRUE);
}
#include "getreg.c"
