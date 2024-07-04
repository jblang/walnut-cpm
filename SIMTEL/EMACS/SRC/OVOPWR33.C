#include "stdio.h"
#include "ed.h"

extern FILE * ffp;
extern char Argbuf[128];
int ovreq;
int ovsub;
int ovreq2;
int ovsub2;

ovmain()
{
	ffp = fopen( Argbuf, "w" );
	ovreq = ovreq2;
	ovsub = ovsub2;
	return ( 1 );
}
