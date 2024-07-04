#include	"stdio.h"
#include	"ed.h"

/*
 * Ask for a file name, and write the
 * contents of the current buffer to that file.
 * Update the remembered file name and clear the
 * buffer changed flag. This handling of file names
 * is different from the earlier versions, and
 * is more compatable with Gosling EMACS than
 * with ITS EMACS. Bound to "C-X C-W".
 */
ovmain(x, f, n)
{
	register int	s;
	char		fname[NFILEN];

	if (( s = mlreply( "Write file: ", fname, NFILEN )) != TRUE )
		return (s);
	return ( writeout( fname ));
}
#include "writeout.c"
