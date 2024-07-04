;
;***********************************************************************
;
;			 MBYE (Modular 'BYE')
;		Zilog Z80-SIO/DART USART/UART routines
;		    v2.1 (02/21/84) by Kim Levitt
;
; These routines will allow the easy patching of MBYE for any type of
; modem/serial port combination.  Certain routines must return status
; flags, so please be careful to set the flags as directed.
;
; NOTE: set NORING EQU YES in the main MBYE program if you have an SIO
; chip. Normally, the SIO doesn't allow monitoring of the RI status.
; The DART, however, does have RI has a standard function. If you have
; a DART, set NORING EQU NO (unless you are using a Smartmodem). (Also
; set DART EQU YES below.)
;
; This version is for the Zilog SIO chip that is hooked up to an extern-
; al modem.  A Z80-CTC or 8116 can be used as baud rate generator. If
; you have a KAYPRO, XEROX 820-II, or another "BigBoard"-based system,
; set the KAYPRO equate true and the rest is automatic.
;
;-----------------------------------------------------------------------
;
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
KAYPRO:	EQU	YES		;yes, if Kaypro, Xerox 820 or BigBoard
;
	 IF	KAYPRO
CTC:	EQU	NO
C8116:	EQU	YES		;BigBoards use the 8116 baud rate clock
	 ENDIF
;
	 IF	NOT KAYPRO
CTC:	EQU	YES
C8116:	EQU	NO		;most other systems use CTC
	 ENDIF
;
; Set base ports for SIO/DART & baud rate clock
;
	 IF	KAYPRO
DART:	EQU	NO		;BigBoards use a true SIO
BASEP:	EQU	04H		;Base port for SIO
BASEC:	EQU	00H		;Base port for 8116
	 ENDIF
;
	 IF	NOT KAYPRO
DART:	EQU	NO		;Yes, if DART used and not SIO
BASEP:	EQU	20H		;Set Base port for SIO (data port)
BASEC:	EQU	32H		;Set Base port for CTC
	 ENDIF
;
; The following define the port addresses to use.
;
DPORT:	EQU	BASEP		;Data port
SPORT:	EQU	BASEP+2		;Status/Control port
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
	 IF	CTC
;
; First Byte of CTC Command:
;
BDCMD1:	EQU	07H		;110 baud		(timer mode)
BDCMD2:	EQU	47H		;300, 600 & 1200 baud	(counter mode)
;
;
; The following are baud rates for BPORT -- they may have to be changed
; for your particular system's CTC.
;
BD300:	EQU	128		;300 bps
BD600:	EQU	64		;600 bps  (not supported by Smartmodem)
BD1200:	EQU	32		;1200 bps
;
	 ENDIF	;CTC
;
	 IF	KAYPRO
;
; 8116 (on Kaypros at least) is initialized by system on cold boot,
; only need to set baud rate as single command to baud rate port.
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
	 ENDIF	;KAYPRO
;
	 IF	C8116 AND NOT KAYPRO
;
BD110:	EQU	02H	
BD300:	EQU	05H	;you may have to change these if you're not
BD600:	EQU	06H	;on a Kaypro system
BD1200:	EQU	07H
;
	 ENDIF
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
	OUT	SPORT
	MVI	A,4		;Setup to write register 4
	OUT	SPORT
	MVI	A,WRREG4	;set 16x clock, 1 stop bit, no parity
	OUT	SPORT
	MVI	A,1		;Setup to write register 1
	OUT	SPORT
	MVI	A,WRREG1	;set no interrupts
	OUT	SPORT
	MVI	A,3		;Setup to write register 3
	OUT	SPORT
	MVI	A,WRREG3	;set Rx 8 bits, enable recv
	OUT	SPORT
	MVI	A,5		;Setup to write register 5
	OUT	SPORT
	MVI	A,DTROFF	;leave DTR OFF initially
	OUT	SPORT
	RET			;Return
;.....
;
; This routine will check the Ring Indicator status,
; returning a non-zero value if the RI line is active.
; (This routine is only valid for DARTs or modified SIOs,
; see notes above.)
;
	 IF	DART	;Only DARTs or modified SIOs can do this
;
MDRING:
	IN	SPORT
	ANI	RI
	RET
;
	 ENDIF	;DART
;.....
;
;
; The following routine will raise DTR. (and RTS)
;
MDANSW:
	MVI	A,5		;address WR5
	OUT	SPORT
	MVI	A,DTRON		;raise DTR, RTS
	OUT	SPORT
	RET			;Return
;
;
; The following routine checks to make sure we still have carrier.  If
; there is no carrier, it will return with the Zero flag set.
;
MDCARCK:
	MVI	A,RESSTA	;Reset status
	OUT	SPORT
	IN	SPORT		;Get status
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
	IN	SPORT		;Get status
	ANI	DAV		;Got a character?
	RZ			;Return if none
	MVI	A,1		;else, check error bits
	OUT	SPORT		;(address RR1)
	IN	SPORT		;read RR1
	ANI	ERR		;mask error bits
	JZ	MDINST1		;no error, ok
	MVI	A,RESERR	;else, reset error bits
	OUT	SPORT
	IN	DPORT		;clear out garbage
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
	IN	DPORT		;Get character
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
	IN	SPORT
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
	OUT	DPORT		;Send it
	RET			;Return
;.....
;
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply put the label in front
; of the ORI 0FFH / RET. If the baud rate change was successful, make
; SURE the Zero flag is set (XRA A).
;
	 IF	CTC
;
SET300:
	MVI	A,BDCMD1	;Get first byte of command
	OUT	BPORT		;send it
	MVI	A,BD300		;Load rate
	JMP	SETBAUD
;
SET1200:
	MVI	A,BDCMD2	;Get first byte of command
	OUT	BPORT		;send it
	MVI	A,BD1200	;Load rate
;
SETBAUD:
	OUT	BPORT		;Send 2nd byte of command (rate)
	XRA	A		;Say rate is OK
	RET			;Return
;
; The following routine returns a 255 because we were not able to set to
; the proper baud rate because either the serial port or the modem can't
; handle it.
;
SET110:
SET450:
SET600:
SET710:
	ORI	0FFH		;Make sure zero flag is not set
	RET			;Return
;
	 ENDIF	;CTC
;.....
;
;
	 IF	C8116
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
	OUT	BPORT		;set baud rate
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
	 ENDIF	;C8116
;.....
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you patch this file into your copy of MBYE, then it should work out
; well. (Be sure to set the SMODEM and SM1200 equates in the main program
; section to indicate if you are using a Hayes Smartmodem or compatible
; or not.)
;
;***********************************************************************
;
