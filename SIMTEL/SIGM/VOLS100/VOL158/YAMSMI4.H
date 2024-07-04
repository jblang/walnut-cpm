/*
>>:yamsys.h 10-30-83
 *
 * computer innovations c86 version
 *
 * global equates for specific installation and modem ports
 * Other modem specific stuff is in yam5.c
 *
 * This header file supports a hayes smartmodem using
 * a Godbout Interfacer 3 or 4 i/o board.
 */

#define ANSWERBACK "\r\n999-999-9999 J. Doe  N.Y. New York\r\n"
/* files have single letter ext so pip yam?????.? gets all source but no crl */
#define HELPFILE "YAMHELP.T"
#define PHONES "PHONES.T"
#define MYSYSTEM "#CPMPMMI,CC,HC,PA,PL\015"
#define FLAVOR "Smartmodem / IF3 / Heath Z-29 YAM"
#define C86
#define USQ
#define BRKKEY 0x00
#define LOOPBACKNONO "\020\003\021\023\033"
#define BIGYAM
#define CPM
#define CLKMHZ 8
#define LOOPS 1370	/* timing value in sleep; compiler & cpu dependent */
			/* chosen so that sleep(n) will pause n 1/10ths for */
			/* a 2Mhz processor */
#define MOMCAL 400*CLKMHZ
#define SECPBLK 16	/* 2k blocks on CDR DD controller 5/8" disk */
/* ********* following string must be in UPPER case ********* */
#define DISKS "ABCDEM"	/* legal disks for default selection */
#define MAXUSER 15	/* maximum user number */

/* defines for Heath/Zenith Z/H19 (or 29) terminal */
#define STATLINE	/* do special status line information */
#define Z19			/* terminal type */
	/* 25th line off, wrap at end of line*/
#define TERMRESET	"\033y1\033x9\033v"
#define TERMINIT	"\033z"
	/* mode for replot -clear screen, no 25th, no wrap. Added Home'n'Clear. */
#define TERMREPLOT	"\033E\033y1\033w"

/* Modem I/O ports for Serial i/o */
#define INT3		/* Interfacer 3/4 code tied to this define */
#define DPORT MDATA
#define SPORT MSTAT

#define GBI4 0x10	/* Interfacer 4 base port (also data) */
#define GBI4U GBI4 + 7	/* Interfacer 4 user select port */
#define GBI4M GBI4 + 2	/* Interfacer 4 mode port (also parallel data) */
#define GBI4C GBI4 + 3	/* Interfacer 4 command port */


EXTERN int MDMU;			/* modem user variable */
#define MUSER 1			/* initial value assigned to MDMU */
#define USERINIT		/* so that user externals get initialized */

#define MIREADY (i4rs(MDMU)&MIMASK) /* value != 0 if char available */
#define MICHAR (i4rd(MDMU))	    /* get char assuming miready */
#define MOREADY (i4rs(MDMU)&MOMASK) /* != 0 if modem ready to load next char */
#define MODOUT(x) i4sd(MDMU,x)
#define MODATA Dport 		/* modem data output port */

#define OVRRNMASK 0x20		/* overrun error */
#define FRMMASK 0x10		/* framing error */

#define MIREADYERROR

/* #define CDO i4cd()		value = 0 if carrier there */

#define MIREADYMASK MIMASK	/* rx character available */
#define MIERRORMASK (OVRRNMASK & FRMMASK) /* error condition framing and overrun only */

#define SMODEM
/* Switches on Smartmodem 1200 should be set for Not Verbose (S2 down),
** Send Result Codes to Screen (S3 down), No Echo of Commands (S4 down)
** and Don't Auto-Answer (S5 down). All other switches as from the
** factory. Sorry, not for XYAM usage as it stands. If your system allows
** communication even if DSR is low you can also set switch 6 to allow you
** to detect loss of carrier.
**/
#define SMCMD	"ATX1"	/* specify use of extended result code set */
#define SMATTN	"+++"	/* get to command mode if not already there */
#define SMHUP	"ATH\r"	/* onhook command - loss of DTR or long break works too */
#define SMDIAL	"ATDT "	/* prefix to sending the number - touchtone mode */
/* #define FLIP */
#define SMTOORG "ATD\r" /* offhook and wait for carrier in originate mode */
#define SMTOANS "ATA\r"	/* offhook and turn on carrier in answer mode */
#define NRING	3	/* Number of rings before offhook in auto-ans mode */


#define POREADY bios(15,0,0)
#define LPOUT(x) bdos(5,x)

#define CIREADY bdos(6,0xFE)
#define CICHAR bdos(6,0xFF)

/* using SS1 serial port for console */

#define COREADY (inportb(CSTAT)&COMASK)
#define TTYOUT(x) bios(4,x,0)


/* if using IF3/4 for console-
 * #define IF3CON
 * unsigned CONU;
 * #define CUSER 7
 * #define COREADY (i4rs(CONU)&COMASK)
 * #define TTYOUT(x) i4sd(CONU, x)
 */

/* STDIO file included here to simplify cross-compiles of cyams */

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

#define	MSTAT	0x11	/* status port				*/
#define MDATA	0x10	/* data port				*/
#define MIMASK	0x02	/* input data ready mask		*/
#define MOMASK	0x01	/* ready to send a character mask	*/
