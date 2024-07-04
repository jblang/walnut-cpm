#include "metab.h"

/* This is the general command execution
 * routine. It handles the fake binding of all the
 * keys to "self-insert". It also clears out the "thisflag"
 * word, and arranges to move it to the "lastflag", so that
 * the next command can look at it. Return the status of
 * command.
 */
execute()
#define cmdchar (*(int *)0x100)
#define cmdflag (*(int *)0x102)
#define cmdparm (*(int *)0x104)
{
	register char * gp;
#define ktp ((KEYTAB *)gp)
#define otp ((OVERTAB *)gp)
	register int status;
	extern int currow;

	thisflag = 0;
	if ( isinsert( cmdchar ))
	{	/* Self inserting. */
#ifdef NEVER
		/* If space typed, fill column defined, argument non-
	 	* negative, and past fill column, word wrap.
		*/
		if (cmdchar == ' ' && fillcol > 0 
		&& cmdparm >= 0 && currow >= fillcol )
			ovloader( 21, 4 ); /* wrapword(); */
This doesn't work anyway, so... out with it!
#endif
		if (cmdparm <= 0)	/* Fenceposts. */
		{	lastflag = 0;
			return ( cmdparm < 0 ? FALSE : TRUE);
		}
		status   = linsert( cmdparm, cmdchar );
byebye:		lastflag = thisflag;
		return (status);
	}

	ktp = &keytab[0];	/* Look in key table.	*/
	while (ktp < &keytab[NKEYTAB])
	{	if (ktp->k_code == cmdchar)
		{	status   = (*ktp->k_fp)( cmdflag, cmdparm);
			goto byebye;
		}
		++ktp;
	}
	otp = &overtab[0];
	while ( otp < &overtab[NOVERTAB])
	{	if (otp->k_code == cmdchar)
		{	status = ovloader( otp->ovcode,
				otp->ovparm, cmdflag, cmdparm );
			goto byebye;
		}
		++otp;
	}
	lastflag = 0;				/* Fake last flags.	*/
	return (ctrlg());
}
