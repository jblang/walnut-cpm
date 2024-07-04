#include	"stdio.h"
#include	"ed.h"

#define	NBLOCK	16			/* Line block chunk size	*/
#define	KBLOCK	256			/* Kill buffer block size	*/

char	*kbufp	= NULL;			/* Kill buffer data		*/
int	kused	= 0;			/* # of bytes used in KB	*/
int	ksize	= 0;			/* # of bytes allocated in KB	*/

/*
 * Delete all of the text
 * saved in the kill buffer. Called by commands
 * when a new kill context is being created. The kill
 * buffer array is released, just in case the buffer has
 * grown to immense size. No errors.
 */
kdelete()
{
	if (kbufp != NULL) {
		free((char *) kbufp);
		kbufp = 
		kused = 
		ksize = 0;
	}
}

/*
 * Insert a character to the kill buffer,
 * enlarging the buffer if there isn't any room. Always
 * grow the buffer in chunks, on the assumption that if you
 * put something in the kill buffer you are going to put
 * more stuff there too later. Return TRUE if all is
 * well, and FALSE on errors.
 */
kinsert(c)
{
	register char	*nbufp;
	register int	i;

	if (kused == ksize) {
		if ((nbufp=malloc(ksize+KBLOCK)) == NULL)
			return (FALSE);
		blockmv( nbufp, kbufp, ksize );
		/* for (i=0; i<ksize; ++i) */
			/* nbufp[i] = kbufp[i]; */
		if (kbufp != NULL)
			free((char *) kbufp);
		kbufp  = nbufp;
		ksize += KBLOCK;
	}
	kbufp[kused++] = c;
	return (TRUE);
}
