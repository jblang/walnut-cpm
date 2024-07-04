
#include	"metab.h"
extern FILE * kbdmf;
extern FILE * ffp;
extern int kbdmstate;
extern int ovreq, ovreq2, ovsub, ovsub2;
extern char Argbuf[128];

ovmain( x, f, n )
{
	switch ( x )
	{	case 0:
		{	/* start keyboard macro */
			if ( kbdmf != NULL || ffptest() || kbdmstate != 0 )
			{
notnow:				mlwrite("Not Now");
				return (FALSE);
			}
			strcpy( Argbuf, "KY+BD+MC.KBM" );
/***********************kbdmf = fopen( "KY+BD+MC.KBM", "w" ); */
			ovreq  = 33;
			ovsub2 = 3;
ret29:			ovreq2 = 29;
rettrue:		return ( 1 );
		}	/* end case 1 */
		case 3:
		{	/* continue from case 1 */
			kbdmf = ffp;
			ffp = NULL;
			if ( kbdmf == NULL )
			{
retbeep:			return ( ctrlg());
			}
			mlwrite("[StartMac]");
			kbdmstate = 1;
			goto rettrue;
		}	/* end case 3 */
		case 1:
		{	/* end macro */
			if ( kbdmf == NULL || ffptest() ||
				( kbdmstate != 1  && kbdmstate != 2 ))
			{	goto notnow;
			}
			fclose( kbdmf );
			kbdmstate = 0;
			mlwrite( ( kbdmstate == 1 )
				? "[EndMac]" : "[MacDone]" );
			kbdmf = NULL;
			goto rettrue;
		}	/* end case 1 */
		case 2:
		{	/* execute macro */
			if ( kbdmf != NULL || ffptest() || kbdmstate != 0 )
			{	goto notnow;
			}
			strcpy( Argbuf, "KY+BD+MC.KBM" );
			ovreq  = 32;
			ovsub2 = 4;
			goto ret29;
		}
		case 4:
		{	/* continue case 2 */
			kbdmf = ffp;
			ffp = NULL;
			if ( kbdmf == NULL )
			{	goto retbeep;
			}
			kbdmstate = 2;
			goto rettrue;
		}
	}
}
ffptest()
{	if ( ffp == NULL ) return ( 0 );
	return ( ffp->_flags );
}
