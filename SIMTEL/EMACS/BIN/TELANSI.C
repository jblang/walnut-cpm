#include "stdio.h"
#include "ed.h"

#define	NROW	24			/* Screen size.			*/
#define	NCOL	80			/* Edit if you want to.		*/
#define	BEL	0x07			/* BEL character.		*/
#define	ESC	0x1B			/* ESC character.		*/
int ansiterm;
char termctrl[3][10] =
{	4, ESC, '=', ' ', ' ', 0,0,0,0,0,
	2, ESC, 'T', 0,0, 0,0,0,0,0,
	1, 26,     0,0,0, 0,0,0,0,0
};
	
ansimove(row, col)
{	register char * cp;
	register int i;

	cp = &termctrl[0][0];
	i = *cp++;
	conout( *cp++ ); --i;
	conout( *cp++ ); --i;
	if ( ! ansiterm )
	{	conout( row + *cp++ ); ++i;
		conout( col + *cp++ ); ++i;
	}
	else
	{	conout( ( row / 10 ) + *cp++ ); ++i;
		conout( ( row % 10 ) + *cp++ ); ++i;
		conout( *cp++ ); --i;
		conout( ( row / 10 ) + *cp++ ); ++i;
		conout( ( row % 10 ) + *cp++ ); ++i;
	}
	while ( --i >= 0 ) conout( *cp++ );
}
ansiclear()
{	ctlout( 2 );
}
ansieeol()
{	ctlout( 1 );
}
ctlout( x )
{	register char * cp;
	register int i;

	cp = &termctrl[x][0];
	i = *cp++;
	while ( --i >= 0 ) conout( *cp++ );
}

ansibeep()
{
	conout( BEL );
}
