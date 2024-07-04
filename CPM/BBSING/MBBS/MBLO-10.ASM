;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;			 MBYE (Modular 'BYE')
;		   Lobo Max-80 serial I/O routines
;	    version 1.0 (06/16/84) by Peter N. Glaskowsky
;	  adapted from MBZSIO v2.1 (02/21/84) by Kim Levitt
;
; This overlay adapts MBYE v3.3 to the Lobo Max-80 computer, using
; serial port A for the modem.
;
; NOTE: set NORING EQU YES in the main MBYE program.
;
;-----------------------------------------------------------------------
;
; 06/16/84  Adapted for use with the Lobo Max-80;
;	    extraneous routines deleted			- Peter N. Glaskowsky
; 02/21/84  Removed exclaimation mark from comment      - Kim Levitt oops!
; 02/20/84  Added comments for XEROX 820-II & BigBoards,
;	    code for DARTs and modified SIOs to read RI - Kim Levitt
; 02/02/84  Fixed and renamed to work with MBYE 3.0	- Kim Levitt
;	    (Also added conditional equates 8116, CTC and KAYPRO.)
; 11/27/83  Altered and renamed to work with BYE3	- Irv Hoff
; 08/04/83  Updated for use with ByeII version 1.6	- Paul Traina
; 07/19/83  Improved operation of modem initialization.	- Paul Traina
; 04/18/83  Added option to use 300/1200 Smartmodem.	- Don Brown
; 04/14/83  Added option for alt. CTC baud set format.	- Paul Traina
; 02/21/83  Initial version.				- Steve Fox
;
;-----------------------------------------------------------------------
;
; Set memory-mapped addresses for SIO and 8116 baud-rate chip
;
BASEP:	EQU	0F7E4H		;Base port for SIO (0F7E6H for port B)
BASEC:	EQU	0F7D0H		;Base port for 8116 (0F7D4H for port B)
;
; The following define the memory-mapped addresses to use.
;
DPORT:	EQU	BASEP		;Data port
SPORT:	EQU	BASEP+1		;Status/Control port
BPORT:	EQU	BASEC		;Baud rate port
;
;
; The following are SPORT commands (output these to SPORT)
;
; WR0:
RESCHN:	EQU	00011000B	;Reset channel
RESSTA:	EQU	00010000B	;Reset ext/status
RESERR:	EQU	00110000B	;Error reset
;
WRREG1:	EQU	00000000B	;WR1 - No interrupts
WRREG3:	EQU	11000001B	;WR3 - Rx 8 bits/char, Rx enable
WRREG4:	EQU	01000100B	;WR4 - 16x, 1 stop bit, no parity
;
; WR5:
DTROFF:	EQU	01101000B	;DTR off, Tx 8 bits, Tx enable, RTS off
DTRON:	EQU	11101010B	;DTR on, Tx 8 bits, Tx enable, RTS on
;
;
; The following are SPORT status masks
;
; RR0:
DAV:	EQU	00000001B	;Data available
TBMT:	EQU	00000100B	;Transmit buffer empty
DCD:	EQU	00001000B	;Data carrier detect
RI:	EQU	00010000B	;Ring Indicator (DARTs only)
;
;(Normally, only DARTs can detect Ring Indicator...... HOWEVER,
; with special wiring to SYNC pin, SIOs can detect RI on this bit
; in asynchronous receive mode, wheras it is normally used only
; in synchronous mode. If you have this hardware mod done, your
; SIO will in effect function as a DART and this "SYNC/HUNT" bit
; in read reg. 0 will function as a RI status bit.) (Connect
; SYNCA pin 11 of SIO to pin 22 of RS-232C connector, not sure if
; any intermediate circut is necessary, though, so DON'T TRY IT
; UNLESS YOU KNOW WHAT YOU'RE DOING and really NEED ring detect,
; also realize you will lose synchronous capabilities...)
;
; RR1:
OE:	EQU	00100000B	;Overrun error
FE:	EQU	01000000B	;Framing error
ERR:	EQU	OE+FE		;Overrun and framing errors
;
;
; 8116 is initialized by system on cold boot, so you only
; need to set baud rate as single command to baud rate port.
;
BD110:	EQU	02H
BD300:	EQU	05H
BD600:	EQU	06H
BD1200:	EQU	07H
BD2400:	EQU	0AH	;2400 - 19.2 K baud values
BD4800:	EQU	0CH	;not currently supported, but could be
BD9600:	EQU	0EH	;used on a high speed link so are
BD19K:	EQU	0FH	;included for informational purposes
;
;
;***********************************************************************
;
; If any of your routines zap anything other than the Accumulator, then
; you must preserve all other registers.
;
;***********************************************************************
;
; This routine should turn off everything on the modem, hang it up, and
; get it ready to wait for a ring. (DTR off)
;
MDINIT:
	MVI	A,RESCHN	;Reset channel (DTR, RTS off)
	STA	SPORT
	MVI	A,4		;Setup to write register 4
	STA	SPORT
	MVI	A,WRREG4	;set 16x clock, 1 stop bit, no parity
	STA	SPORT
	MVI	A,1		;Setup to write register 1
	STA	SPORT
	MVI	A,WRREG1	;set no interrupts
	STA	SPORT
	MVI	A,3		;Setup to write register 3
	STA	SPORT
	MVI	A,WRREG3	;set Rx 8 bits, enable recv
	STA	SPORT
	MVI	A,5		;Setup to write register 5
	STA	SPORT
	MVI	A,DTROFF	;leave DTR OFF initially
	STA	SPORT
	RET			;Return
;.....
;
; The following routine will raise DTR. (and RTS)
;
MDANSW:
	MVI	A,5		;address WR5
	STA	SPORT
	MVI	A,DTRON		;raise DTR, RTS
	STA	SPORT
	RET			;Return
;
;
; The following routine checks to make sure we still have carrier.  If
; there is no carrier, it will return with the Zero flag set.
;
MDCARCK:
	MVI	A,RESSTA	;Reset status
	STA	SPORT
	LDA	SPORT		;Get status
	ANI	DCD		;Check for data carrier
	RET			;Return
;
;
; The following routine determines if there is a character waiting to
; be received.  If no character is waiting, the Zero flag will be set,
; otherwise, 255 will be returned in register A. (Error conditions are
; checked, and, if present, the character is ignored.)
;
MDINST:
	LDA	SPORT		;Get status
	ANI	DAV		;Got a character?
	RZ			;Return if none
	MVI	A,1		;else, check error bits
	STA	SPORT		;(address RR1)
	LDA	SPORT		;read RR1
	ANI	ERR		;mask error bits
	JZ	MDINST1		;no error, ok
	MVI	A,RESERR	;else, reset error bits
	STA	SPORT
	LDA	DPORT		;clear out garbage
	XRA	A		;say no data
	RET			;and return
MDINST1:
	ORI	0FFH		;say we got one
	RET			;...and return
;.....
;
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage... so
; use the MDINST routine first.
;
MDINP:
	LDA	DPORT		;Get character
	ANI	7FH		;Strip parity
	RET			;Return
;.....
;
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is empty, it will return with the Zero flag clear.  If
; the transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST:
	LDA	SPORT
	ANI	TBMT		;Mask it
	RET			;Return
;.....
;
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;
; **** Use MDOUTST first to see if buffer is empty ****
;
MDOUTP:
	STA	DPORT		;Send it
	RET			;Return
;.....
;
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply put the label in front
; of the ORI 0FFH / RET. If the baud rate change was successful, make
; SURE the Zero flag is set (XRA A).
;
;
SET110:
	MVI	A,BD110
	JMP	SETBAUD
;
SET300:
	MVI	A,BD300
	JMP	SETBAUD
;
SET600:
	MVI	A,BD600
	JMP	SETBAUD
;
SET1200:
	MVI	A,BD1200
;
SETBAUD:
	STA	BPORT		;set baud rate
	XRA	A		;say rate ok
	RET			;and return
;
; The following rates, (450 & 710), are not supported for the 8116/SIO
;
SET450:
SET710:
	ORI	0FFH		;say rate ng
	RET
;
;.....
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you patch this file into your copy of MBYE, then it should work out
; well. (Be sure to set the SMODEM and SM1200 equates in the main program
; section to indicate if you are using a Hayes Smartmodem or compatible
; or not.)
;
