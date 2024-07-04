/*
>>:yampmmi.h 11-01-83
 *
 * global equates for specific installation and modem ports
 * Other modem specific stuff is in yam5.c
 *
 * This yamsys header for pmmi with error checking,
 * for use with CI C86 compiler- 11-09-83 paul homchick
 */

#define ANSWERBACK "\215\012C. SMITH NYC\215\012\021"

/* files have single letter ext so pip yam?????.? gets all source but no crl */

#define HELPFILE "YAMHELP.T"
#define PHONES "PHONES.T"
#define MYSYSTEM "#CPMPMMI,CC,HC,PA,PL\015"
#define C86		/* compiler */
#define USQ
#define BRKKEY 0x00
#define LOOPBACKNONO "\020\003\021\023\033"
#define BIGYAM
#define CPM
#define LOOPS 1370	/* timing value in sleep; compiler & cpu dependent, */
			/* chosen so that sleep(n) will pause n 1/10ths for */
			/* a 2Mhz processor */
#define MOMCAL 400*CLKMHZ
#define FLAVOR "Pmmi MM-103 / Heath Z-29 YAM"
#define CLKMHZ 8

/* ********* following string must be in UPPER case ********* */

#define DISKS "ABCDEFGHIJKLMN"	/* legal disks for default selection */
#define MAXUSER 15	/* maximum user number */

/* defines for Heath/Zenith Z/H19 terminal */

#define STATLINE	/* do special status line information */
#define Z19			/* terminal type */

	/* 25th line off, wrap at end of line*/

#define TERMRESET	"\033y1\033x9\033v"
#define TERMINIT	"\033z"

	/* mode for replot -clear screen, no 25th, no wrap. Added Home'n'Clear. */

#define TERMREPLOT	"\033E\033y1\033w"

#define DPORT MDATA
#define SPORT MSTAT
#define DEFBAUD 300


/* modem defines */

#define PMMI TRUE
#define FLIP TRUE
#define MIREADY (inportb(MSTAT)& MIMASK)	/* value != 0 if char available */
#define MICHAR inportb(Dport)			/* get char assuming miready */
#define MOREADY (inportb(MSTAT) & MOMASK)	/* modem ready to load next char */
#define MODOUT(x) outportb(Dport, x)
#define MODATA Dport 		/* modem data output port */
#define PPS 125			/* use 125 for 20pps or 250 for 10pps */
#define AUTODIAL TRUE

/* modem error handling */

#define OVRRNMASK 0x10		/* overrun error */
#define FRMMASK 0x20		/* framing error */
#define MIREADYERROR		/* rx data ready and error bits in same reg */
#define CDO FALSE		/* don't bother with carrier detect */
#define MIREADYMASK MIMASK	/* rx character available */
#define MIERRORMASK (OVRRNMASK & FRMMASK) /* error condition framing and overrun only */

/* console and printer */

#define POREADY bios(15,0,0)
#define LPOUT(x) bdos(5,x)

#define CIREADY bdos(6,0xFE)
#define CICHAR bdos(6,0xFF)
#define COREADY (inportb(CSTAT)&COMASK)
#define TTYOUT(x) bios(4,x,0)

#include "stdio.h"

#define TWIDTH	80	/* # of columns	*/
#define TLENGTH	24	/* # of lines	*/
#define CLEARS	"\033E"	/* String to clear screen on console	*/
#define INTOREV	"\033p"	/* String to switch console into reverse video	*/
#define OUTAREV "\033q"	/* String to switch console OUT of reverse video  */
#define CURSOROFF "\033x5"	/* String to turn cursor off	*/
#define CURSORON "\033y5"	/* String to turn cursor on	*/
#define ESC	'\033'	/* Standard ASCII 'escape' character	*/

/*
 *	Console serial port characteristics:
 */

#define CSTAT	0x5d	/* status port	*/
#define CDATA	0x5c	/* data port	*/
#define CIMASK	0x02	/* input data ready mask   */
#define COMASK	0x01	/* output data ready mask  */

/*
 *	 Modem characteristics:
 */

#define	MSTAT	0xe0	/* status port	*/
#define MDATA	0xe1	/* data port	*/
#define MIMASK	0x02	/* input data ready mask	*/
#define MOMASK	0x01	/* ready to send a character mask	*/
#define MAHI	1	/* True if status logic active high  */
#define MRESET	0	/* True if status port needs to be reset */
#define MRESETVAL 0	/* If MRESET true, this is the byte to send */
