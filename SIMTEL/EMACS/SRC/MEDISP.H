
#ifndef OWNER
#define Extern extern
#else
#define Extern
#endif

#include	"stdio.h"
#include	"ed.h"

/*efine	WFDEBUG	0			/* Window flag debug.		*/

typedef	struct	VIDEO {
	short	v_flag;			/* Flags			*/
	char	v_text[1];		/* Screen data.			*/
}	VIDEO;

#define	VFCHG	0x0001			/* Changed.			*/

Extern int	sgarbf	
#ifdef OWNER
= TRUE
#endif
;			/* TRUE if screen is garbage	*/
Extern int	mpresf	
#ifdef OWNER
= FALSE
#endif
;		/* TRUE if message in last line	*/
Extern int	vtrow	
#ifdef OWNER
= 0
#endif
;			/* Row location of SW cursor	*/
Extern int	vtcol	
#ifdef OWNER
= 0
#endif
;			/* Column location of SW cursor	*/
Extern int	ttrow	
#ifdef OWNER
= HUGE
#endif
;			/* Row location of HW cursor	*/
Extern int	ttcol	
#ifdef OWNER
= HUGE
#endif
;			/* Column location of HW cursor	*/

Extern VIDEO	**vscreen;			/* Virtual screen.		*/
Extern VIDEO	**pscreen;			/* Physical screen.		*/
