/*
 * The routines in this file
 * handle the reading and writing of
 * disk files. All of details about the
 * reading and writing of the disk are
 * in "fileio.c".
 */
#include	"stdio.h"
#include	"ed.h"

/*
 * Read a file into the current
 * buffer. This is really easy; all you do it
 * find the name of the file, and call the standard
 * "read a file into the current buffer" code.
 * Bound to "C-X C-R".
 */
ovmain( x, f, n )
{
	register int	s;
	char		fname[NFILEN];

	if ((s=mlreply("Read file: ", fname, NFILEN)) != TRUE)
		return (s);
	return (readin(fname, ( n > 0)));
}
#include "readin.c"
