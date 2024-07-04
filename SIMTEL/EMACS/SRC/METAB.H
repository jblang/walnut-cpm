#include	"stdio.h"
#include	"ed.h"

#ifndef	GOOD
#define	GOOD	0
#endif

#ifdef OWNER
#define Extern
#else
#define Extern extern
#endif

Extern int	currow;			/* Working cursor row		*/
Extern int	curcol;			/* Working cursor column	*/
Extern int	fillcol;		/* Current fill column		*/
Extern int	thisflag;		/* Flags, this command		*/
Extern int	lastflag;		/* Flags, last command		*/
Extern int	curgoal;		/* Goal column			*/
Extern BUFFER *curbp;			/* Current buffer		*/
Extern WINDOW *curwp;			/* Current window		*/
Extern BUFFER *bheadp;			/* BUFFER listhead		*/
Extern WINDOW *wheadp;			/* WINDOW listhead		*/
Extern BUFFER *blistp;			/* Buffer list BUFFER		*/
/* Extern short kbdm[NKBDM] 
/* #ifdef OWNER
/* = { CTLX|')', 0 }
/* #endif
/* ;		/* Macro */
/* Extern short *kbdmip;		/* Input  for above		*/
/* Extern short *kbdmop;		/* Output for above		*/
Extern char	pat[NPAT];		/* Pattern			*/

typedef	struct
{	short	k_code;			/* Key code			*/
	int	(*k_fp)();		/* Routine to handle it		*/
}	KEYTAB;

typedef struct
{	short k_code;		/* same as KEYTAB */
	char  ovcode;		/* which overlay. */
	char ovparm;		/* which routine in overlay. */
}	OVERTAB;

extern	int	ctrlg();		/* Abort out of things		*/
extern	int	quit();			/* Quit				*/
extern	int	getccol();		/* Get current column		*/
extern	int	gotobol();		/* Move to start of line	*/
extern	int	forwchar();		/* Move forward by characters	*/
extern	int	gotoeol();		/* Move to end of line		*/
extern	int	backchar();		/* Move backward by characters	*/
extern	int	setfillcol();		/* Set fill column.		*/
extern	int	tab();			/* Insert tab			*/
extern	int	newline();		/* Insert CR-LF			*/
extern	int	backword();		/* Backup by words		*/
extern	int	forwword();		/* Advance by words		*/
extern	int	forwdel();		/* Forward delete		*/
extern	int	backdel();		/* Backward delete		*/
extern	int	delfword();		/* Delete forward word.		*/
extern	int	delbword();		/* Delete backward word.	*/
extern	int	quickexit();		/* low keystroke style exit.	*/
extern	char	*strcpy();		/* copy string			*/

extern KEYTAB	keytab[];
extern int NKEYTAB;

extern OVERTAB overtab[];
extern int NOVERTAB;
