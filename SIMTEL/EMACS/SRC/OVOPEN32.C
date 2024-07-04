#include "stdio.h"
#include "ed.h"

extern FILE * ffp;
extern char Argbuf[128];
extern int ovreq;
extern int ovsub;
extern int ovreq2;
extern int ovsub2;

ovmain()
{
	ffp = fopen( Argbuf, "r" );
	ovreq = ovreq2;
	ovsub = ovsub2;
	return ( 1 );
}
