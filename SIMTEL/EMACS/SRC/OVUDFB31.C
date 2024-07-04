#include	"stdio.h"
#include	"ed.h"
/* ovudfb31.c: (read "up down forward back" for "udfb")
** overlay 31 source code.
** this large overlay is a portmanteau of frequently-used
** commands. One can hardly justify having some of them in
** overlays UNLESS the overlay in question is one which is
** likely to be in memory at all times -- so, this overlay 
** includes gobs of the most useful commands.
*/

extern int   wstyle;	/* Which kind of Word operations? */
extern int   currow;	/* set by update() */
extern int   tabsize;	/* if tabs are expanded to spaces. */
extern char *kbufp;	/* Kill buffer data */
extern int   kused;	/* # of bytes used in KB */
extern int   ksize;	/* # of bytes allocated in KB */

#define TABCASE 40	/* case TABCASE and above are special. */
	/* cases < TABCASE are numbered so that we can handle a negative
	** parameter with "casenumber ^= 1"
	*/

ovmain( x )
#define cmdflag (*(int *)0x102)
#define cmdparm (*(int *)0x104)
{
	register LINE	* mylp;
	register WINDOW * mywp;

#define temp_int (*(int *)0xc0)
#define mydoto   (*(int *)0xc2)
#define xbufchar (*(int *)0xc4)
#define limitp   (*(LINE **)0xc6)
#define localx   (*(int *)0xc8)
#define xinsct   (*(int *)0xca)
#define mylen    (*(int *)0xcc)
#define Wdoto    (*(int *)0xce)
	/* the above #defines are temporary variables, in effect:
	** the compiler generates much smaller code for specific addresses
	** than it does for stack variables.
	*/

	xinsct = 1;
	mywp = curwp;
	mylp = mywp->w_dotp;
	limitp = curbp->b_linep;
	temp_int = mydoto =  0;
	mylen = llength( mylp );
	Wdoto = mywp->w_doto;

	if ( ( localx = x ) < TABCASE )
	{	/* most commands here have negative-parameter counterparts. */

		if ( cmdparm < 0 )
		{	localx ^= 1;
			cmdparm = -cmdparm;
		}
	}

	switch ( localx )
	{
		case 13:	/* goto end of line. */
			mydoto = mylen;
			goto dotpset;
		case 12:	/* goto start of line. */
			if ( cmdflag && ( mydoto = cmdparm -1 ) > mylen )
				mydoto = mylen;
			goto dotpset;
		case 10:	/* page forwards */
		case 11:	/* page back. */
			cmdparm *= ( mywp->w_ntrows - 1 );
			goto linemotion;
		case 1:	/* up arrow.  */
			++cmdparm;
			goto linemo2;	/* backward goes n+1 lines! */
		case 9:	/* gotoeob */
			if ( cmdparm ) --cmdparm;
		case 8:	/* gotobob */
			mylp = curbp->b_linep;
linemotion:
			/* if ( localx & 1 ) */
			/* {	mylp = lforw( mylp ); */
			/* } */
			curgoal = curcol = 0;
			/* mywp->w_flag |= WFHARD; */
linemo2:		/* fall through. */
		case 0:	/* down arrow */
		{	/* up or down */
			if ( ! ( lastflag & CFCPCN ))
			{	/* Reset goal if last not up/down */
				curgoal = curcol;
			}
			thisflag |= CFCPCN;

			if ( localx & 1 )	/* backward */
			{	while ( decparm()
					&& ( mylp = lback( mylp )) != limitp
				);
			}
			else
			{	while ( decparm()
					&& ( mylp = lforw( mylp )) != limitp
				);
			}	/* "--n >= 0" for n+1 lines. */

			while ( mydoto != llength( mylp ))/* NOT mylen! */
			{	if ( ( xbufchar = lgetc( mylp, mydoto ))
					== '\t' )
						temp_int |= 0x07;
				else if ( ! isinsert( xbufchar ))
					plustemp();
				if ( ++temp_int > curgoal ) break;
				++mydoto;
			}
dotpmove:		wfmove();
dotpset:		mywp->w_dotp  = mylp;
			mywp->w_doto  = mydoto;
			goto rettrue;	/* return ( 1 ); */
		}	/* end case 0 or 1 */
		case 2:	/* word forward */
		case 4:	/* del word forward */
		{	/* mylp = curwp->w_dotp; at top (mylp) */
			mydoto = Wdoto;
			while ( decparm())
			{	if ( ! ( wstyle & 2 ) && ! fwx())
				{	goto retfalse;
				}
				while ( inword( ))
				{	fc1();
					/* assert the above cannot fail. */
					plustemp();
				}
				if ( wstyle & 2 && ! fwx())
				{	goto retfalse;
				}
			}
			if ( localx == 2 ) goto rettrue;
			mywp->w_dotp = mylp;
			mywp->w_doto = mydoto;
			goto retldel;	/* return ( ldelete( temp_int, 1 )); */
		}	/* end case 2 or 4 */
		case 3:	/* word backward */
		case 5:	/* del word backward */
		{
			if ( ! bc1( )) goto retfalse; /* TOF */
			/* temp_int++; */
			while ( decparm())
			{
				while ( ! inword( ))
				{	if ( ! bc1()) goto retfalse;
					plustemp();
				}
				while ( inword( ))
				{	if ( ! bc1())
					{	/* top of file. */
retfalse:					return ( 0 );
					}
					plustemp();
				}
			}
			/* temp_int--; */
			fc1();	/* can't fail. */
			if ( localx == 5 )
			{	/* delword. */
retldel:			cmdflag = 1;
ret2ldel:			return ( ldelete( temp_int, cmdflag ));
			}
rettrue:		return ( 1 );
		}	/* end case 3 or 5. */
		case 6:	/* forwdel() */
		case 7:	/* backdel() */
		{
			if ( cmdflag )
			{	/* Really a kill.	*/
				kdcheck();
			}
			if ( ( localx & 1 ) && ! backchar( cmdflag, cmdparm ))
				goto retfalse;
			temp_int = cmdparm;
			goto ret2ldel; /*return(ldelete(cmdparm,cmdflag));*/
		}	/* end cases 6 and 7 */
		case TABCASE:
		{	/* with no parameter, perform tab function;
			** with one, set tabsize.
			*/
			if ( cmdparm < 0 ) return ( 0 );
			if ( cmdparm != 1 )
			{	tabsize = cmdparm;
				return( 1 );
			}
			xbufchar = '\t';
			if ( tabsize )
			{	xinsct = tabsize - 
					( ( curcol + 1 ) % tabsize );
				xbufchar = ' ';
			}
			return( xlinsc( ));
		}	/* end case TABCASE */
		case TABCASE+1:	/* openline() */
		case TABCASE+2:	/* indent() */
		{	/* openline() keeps cursor in same place,
			** inserts arg newlines.
			** indent() moves forward with its newlines,
			** adds whitespace to match the current line.
			*/
			mylp = lback( mylp );
			mydoto = Wdoto;
			while ( decparm()) if ( ! lnewline()) goto retfalse;
			mylp = lforw( mylp );
				/* lnewline() may delete the original
				** target of mylp.
				*/
			if ( localx == ( TABCASE + 1 ))
			{	/* openline(), done. */
				goto dotpset;
			}
			while ( ( xbufchar = lgetc( mylp, ++cmdparm )) == ' '
				|| xbufchar == '\t' )
			{	xlinsc( );
			}
			if ( xbufchar == '{' )
			{	/* C indent */
				xbufchar = '\t';
				xlinsc();
			}
			goto rettrue;
		}	/* end case indent() and openline() */
		case TABCASE+7:	/* vi-style kill. */
			cmdflag = 1;
			mywp->w_doto = Wdoto = 0;	/* fall through. */
		case TABCASE+3:	/* kill() */
		{	kdcheck();
			mydoto = Wdoto;
			if ( ! cmdflag )
			{	temp_int = mylen - mydoto;
				if ( temp_int == 0 ) temp_int = 1;
			} else if ( ! cmdparm )
			{	temp_int = mydoto;
				mywp->w_doto = 0;
			} else if ( decparm())	/* "if n > 0" */
			{	temp_int = mylen - mydoto + 1;
				mylp = lforw( mylp );
				while (decparm()) /* while --n */
				{	if ( mylp == limitp )
					goto retfalse;
					temp_int += llength( mylp ) + 1;
					mylp = lforw( mylp );
				}
			} else
			{	/* mlwrite("neg kill"); */
				ctrlg();
				goto retfalse;
			}
			goto retldel; /*return(ldelete(temp_int,TRUE));*/
		}	/* end case "kill()" */
		case TABCASE+4:	/* yank() */
		{	if ( ! decparm()) goto retfalse;
			do	/* make cmdparm copies. */
			{	temp_int = 0;
				while ( temp_int < kused )
				{	if ( ( xbufchar = kbufp[ temp_int ])
						== '\n' )
					{	lnewline( );
					} else
					{	if ( ! xlinsc())
							goto retfalse;
					}
					plustemp();
				}
			} while ( decparm( ));
			goto rettrue;
		}	/* end case yank() */
		case TABCASE+5:	/* set mark */
		{	mlwrite("[Mark]");
markset:		mywp->w_markp = mylp;
			mywp->w_marko = Wdoto;
			goto rettrue;
		}	/* end case set mark */
		case TABCASE+6: /* exchange mark and cursor. */
		{	if ( mywp->w_markp == NULL )
			{	mlwrite("No mark");
				return ( 0 );
			}
			mywp->w_dotp  = mywp->w_markp;
			mywp->w_doto  = mywp->w_marko;
			wfmove();
			goto markset;
		}	/* end case ^X^X */
	}
}

fc1()	/* saves 10 bytes per call to it. */
{	return( forwchar( 0, 1 ));
}
bc1()	/* saves 10 bytes per call to it. */
{	return( backchar( 0, 1 ));
}
fwx()	/* loop used twice in forwword. */
{	while ( ! inword( ))
	{	if ( ! fc1( )) return ( 0 );
		plustemp();
	}
	return ( 1 );
}
plustemp()	/* temp_int++ : saves 2 bytes per call. */
{	++temp_int;
}
decparm()	/* --cmdparm >= 0 */
{	return ( --cmdparm >= 0 );
}
xlinsc()
{	return( linsert( xinsct, xbufchar ));
}
kdcheck()
{	if ( ! ( lastflag & CFKILL )) kdelete();
	thisflag |= CFKILL;
}
wfmove()
{	curwp->w_flag |= WFMOVE;
}
