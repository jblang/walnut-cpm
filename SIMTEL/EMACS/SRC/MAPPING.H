/* the OV macro is for overlays; the BI macro is for built-ins */

#ifdef OLDMAP
BI( 0x1f&'@',	&gotobol )	/* ZMAP */
	/* ^A == TVI magic prefix */
BI( 0x1f&'B',	&backword )	/* ZMAP */
OV( 0x1f&'C',	23, 2 )		/* forwpage ZMAP */
BI( 0x1f&'D',	&forwdel )	/* ZMAp */
BI( 0x1f&'E',	&gotoeol )
#else
OV( 0x1f&'@',	31, 12 )	/* gotobol ZMAP */
	/* ^A == TVI magic prefix */
OV( 0x1f&'B',	31, 3 )		/* wordback ZMAP */
OV( 0x1f&'C',	31, 10 )	/* forwpage ZMAP */
OV( 0x1f&'D',	31, 6  )	/* forwdel ZMAP */
OV( 0x1f&'E',	31, 13 )	/* gotoeol ZMAP */
#endif




#ifdef OLDMAP
BI( 0x1f&'F',	&forwword )	/* ZMAP */
#else
OV( 0x1f&'F',	31, 2 )	/* forwword ZMAP */
#endif

BI( 0x1f&'G',	&ctrlg )	/* ZMAP */
BI( 0x1f&'H',	&backchar )	/* ZMAP */

#ifdef OLDMAP
BI( 0x1f&'I',	&tab )		/* ZMAP */
OV( 0x1f&'J',	22, 0 )		/* forwline ZMAP */
OV( 0x1f&'K',	22, 1 )		/* backline, ZMAP */
#else
OV( 0x1f&'I',	31, 40 )		/* tab, ZMAP */
OV( 0x1f&'J',	31, 0 )		/* forwline ZMAP */
OV( 0x1f&'K',	31, 1 )		/* backline, ZMAP */
#endif

BI( 0x1f&'L',	&forwchar )	/* ZMAP */

#ifdef OLDMAP
OV( 0x1f&'M',	26, 0 )		/* indent ZMAP */
#else
OV( 0x1f&'M',	31, 42 )	/* indent ZMAP */
#endif

OV( 0x1f&'N',	2, 0 )		/* fsearch ZMAP */

#ifdef OLDMAP
OV( 0x1f&'O',	26, 1 )		/* openline */
#else
OV( 0x1f&'O',	31, 41 )	/* openline */
#endif

OV( 0x1f&'P',	1, 0 )		/* bsearch, ZMAP */
	/* ^Q available */

#ifdef OLDMAP
OV( 0x1f&'R',	23, 3 )		/* backpage ZMAP */
#else
OV( 0x1f&'R',	31, 11 )	/* backpage ZMAP */
#endif

	/* ^S available */
	/* ^T findchar ZMAP */
	/* ^U parameter introducer ZMAP */

#ifdef OLDMAP
OV( 0x1f&'V',	22, 0 )		/* forwline TVI arrow */
#else
OV( 0x1f&'V',	31, 0 )		/* forwline TVI arrow */
#endif

	/* ^W */
	/* ^X ZMAP prefix */

#ifdef OLDMAP
OV( 0x1f&'Y',	25, 1 )		/* ????yank */
#else
OV( 0x1f&'Y',	31, 44 )	/* ????yank */
#endif

#ifdef OLDMAP
OV( 0x1f&'Z',	24, 1 )		/* swapmark, TVI CLEAR key */
#else
OV( 0x1f&'Z',	31, 46 )		/* swapmark, TVI CLEAR key */
#endif

	/* ^[ META prefix ZMAP */
	/* ^\ negative parameter introducer ZMAP */
	/* ^] */
OV( 0x1f&'^',	16, 1 )	/* next buffer, TVI HOME key */
	/* ^_ */

	/* space to twiddle (0x20 to 0x7e) self-insert */

#ifdef OLDMAP
BI( 0x7F,	&backdel )	/* ZMAP */
#else
OV( 0x7F,	31, 7 )		/* backdel ZMAP */
#endif

/* META-control: mostly not used for now */

OV( META|(0x1f&'Z'), 30, 1 )		/* quick save and exit	*/


/* M-punctuation: mostly not used for now */

#ifdef OLDMAP
OV( META|'*',	24, 0 )		/* setmark TVI SHIFT-CLEAR key */
#else
OV( META|'*',	31, 45 )	/* setmark TVI SHIFT-CLEAR key */
#endif

	/* M-6 is SHIFT SEND (programmable) */
	/* M-7 is SEND (programmable) */
OV( META|'!',	14, 1 )		/* ???reposition */

#ifdef OLDMAP
OV( META|'<',	23, 0 )		/* gotobob */
OV( META|'>',	23, 1 )		/* gotoeob */
BI( META|'b',	&delbword )	/* ??? */
#else
OV( META|'g',	31, 8 )		/* gotobob gotoline ZMAP */
OV( META|'G',	31, 9 )		/* gotoeob */
OV( META|'b',	31, 5 )		/* delbword ??? */
#endif

OV( META|'c',	21, 2 )		/* capword */
	/* M-E TVI "LINE INS" */

#ifdef OLDMAP
BI( META|'f',	&delfword )	/* ??? */
#else
OV( META|'f',	31, 4 )	/* delfword ??? */
#endif

OV( META|'I',	29, 2 )		/* exec kbmac, TVI BACKTAB key */
OV( META|'j',	10, 0 )		/* uppercase region, TVI "SHIFT uparrow" */
OV( META|'L',	3, 0 )		/* killregion, TVI "SHIFT PRINT" key */
	/* M-N TVI "SHIFT LINE INS" */
	/* M-O TVI "SHIFT LINE DEL " key */
OV( META|'P',	19, 0 )		/* copyregion, TVI "PRINT" key */
OV( META|'Q',	5, 1 )		/* quote, ZMAP and TVI "CHAR INS" */

#ifdef OLDMAP
OV( META|'T',	25, 0 )		/* kill, TVI "LINE ERA" key */
#else
OV( META|'R',	31, 47 )	/* kill lines vi-style, TVI "LINE DEL" */
OV( META|'T',	31, 43 )	/* kill, TVI "LINE ERA" key */
#endif

OV( META|'W',   30, 4 )		/* WORD/word mode */
OV( META|'w',   30, 2 )		/* WORD/word mode */
OV( META|'Y',	17, 0 )		/* killbuffer, TVI "PAGE ERA" key */
OV( META|'\\',	14, 2 )		/* refresh */
OV( META|'_',	21, 1 )		/* lowerword */
OV( META|'^',	21, 0 )		/* upperword */
OV( META|'~',	7, 1 )	/* twiddle */




OV( CTLX|(0x1f&'B'), 4, 0 )	/* listbuf */
OV( CTLX|(0x1f&'C'), 30, 0 )	/* Hard quit. */
OV( CTLX|(0x1f&'F'), 11, 0 )	/* visit file */
OV( CTLX|(0x1f&'J'), 8, 0 )	/* scroll down window */
OV( CTLX|(0x1f&'K'), 8, 1 )	/* scroll up window */
OV( CTLX|(0x1f&'L'), 6, 0 )	/* ??? lowercase region */
OV( CTLX|(0x1f&'N'), 5, 0 )	/* filename */
OV( CTLX|(0x1f&'O'), 7, 2 )	/* ???deblank */
OV( CTLX|(0x1f&'R'), 20, 0 )	/* fileread */
OV( CTLX|(0x1f&'S'), 9, 0 )	/* filesave */
OV( CTLX|(0x1f&'V'), 8, 0 )	/* scroll down window */
OV( CTLX|(0x1f&'W'), 12, 0 )	/* ???write file */
OV( CTLX|(0x1f&'Z'), 13, 0 )	/* ???shrink current window. */

#ifdef NEVER
OV( CTLX|'F', 21, 3 )		/* setfillcol??? */
#endif
	/*CTLX|'!',		&spawn,		/* Run 1 command.	*/
OV( CTLX|'=',	7, 0 )		/* show cursor stats */
OV( CTLX|'1',	14, 0 )		/* one window */
OV( CTLX|'2',	15, 0 )		/* split window */
OV( CTLX|'b',	16, 0 )		/* ??? use buffer. */
OV( CTLX|'(',	29, 0 )		/* startmacro */
OV( CTLX|')',	29, 1 )		/* endmacro */
OV( CTLX|'n',	8, 2 )		/* ???nextwind */
OV( CTLX|'p',	8, 3 )		/* ???prevwind */
OV( CTLX|'z',	18, 0 )		/* ???enlarge window */
