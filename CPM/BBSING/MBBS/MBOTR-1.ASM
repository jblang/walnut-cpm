;***********************************************************************
;
;
;
;                     MBYE (Modular 'BYE')
;              Otrona Attache Specialized Routines
;               v1.1 (04/08/84) by Donald Larson
;                      Modified from.....
;
;			 MBYE (Modular 'BYE')
;		Zilog Z80-SIO/DART USART/UART routines
;		    v2.1 (02/21/84) by Kim Levitt
;
;
;
;----------------------------------------------------------------------
;
; This particular version was skeletonized and reworked for the Otrona
; Attache.  The program will utilize escape codes to the display driver
; instead of direct hardware sets to prevent difficulties with Valet.
; Also note that this will require a rework on the Otrona standard modem
; ("Communications") cable.  The pin for CTS must be moved to pin 8
; from pin 5 on the DB-25 (25 pin) connector.  This will allow the
; BYE to monitor the DSR (data set ready) lead (which tracks with
; carrier detect).  Therefore the correct cable would be:
;
;         Attache'                                   Modem
;          15 pin                                    25 pin
;
;            1 --------- Protective Ground ----------- 1
;            2 --------- Transmitted Data ------------ 2
;            4 --------- Received Data --------------- 3
; NOTE ===>  5 --------- Clear to Send --------------- 8
;            8 --------- Signal Ground --------------- 7 <---+-+
;            9 --------- Data Terminal Ready --------- 20    | |
;           10 --------- Request to Send ------------- 4     | |
;           11 --------- Received Data Return ---------------+ |
;           12 --------- Clear to Send Return -----------------+
;
; NOTE: this is where you change the standard lead from pin 5 in the
; standard cable to pin 8 as shown.
;
; This version was tested with a Hayes Smartmodem 1200 and an 8:16
; using CP/M 2.2.5.  If there are any bugs, please call by voice
; days at (312) 867-6400 X 451.
;
; I have still been unable to use the Attache's (R)eal (T)ime
; (C)lock for forced logoff, etc.  I'd like to talk to anyone 
; coming up with a method of doing so.  Please give me a call.
;
;                                 - Donald Larson
;
;-----------------------------------------------------------------------
;
; 04/08/84  Editted, skeletonized  and reformatted for
;           specific use with the Otrona Attache. Used
;           with MBYE v 3.2.                            - Donald Larson
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
BASEP:	EQU	0F0H		;Set Base port for SIO (data port)
;
; The following define the port addresses to use.
;
DPORT:	EQU	BASEP		;Data port
SPORT:	EQU	BASEP+1		;Status/Control port
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
DAV:	EQU	00000001B	;Data available
TBMT:	EQU	00000100B	;Transmit buffer empty
DCD:	EQU	00100000B	;Data carrier detect (using modifed cts)
OE:	EQU	00100000B	;Overrun error
FE:	EQU	01000000B	;Framing error
ERR:	EQU	OE+FE		;Overrun and framing errors
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
;
SET110:
	MVI	A,01		;Send code for 110 baud
	JMP	SETBAUD
;
SET300:
	MVI	A,04		;Send code for 300 baud
	JMP	SETBAUD
;
SET600:
	MVI	A,05		;Send code for 600 baud
	JMP	SETBAUD
;
SET1200:
	MVI	A,06		;Send code for 1200 baud
	JMP	SETBAUD
;
SET2400:
	MVI	A,07		;Send code for 2400 baud
	JMP	SETBAUD
;
SET4800:
	MVI	A,08		;Send code for 4800 baud
	JMP	SETBAUD
;
SET9600:
	MVI	A,09		;Send code for 9600 baud
	JMP	SETBAUD
;
SET19200:
	MVI	A,0AH		;Send code for 19,200 baud
;	
SETBAUD:
	PUSH	PSW		;Preserve baud code (just in case)
	MVI	E,ESC		;First, send escape
	CALL 	SCONOUT
	MVI	E,'@'		;Next set for write to CMOS ram
	CALL	SCONOUT
	MVI	E,8		;Communications address
	CALL 	SCONOUT
	POP	PSW		;Get back baud code
	PUSH	PSW		;Again, just in case
	MOV	E,A
	CALL	SCONOUT		;Write it
	MVI	E,ESC		;Send escape (again)
	CALL 	SCONOUT
	MVI	E,'<'		;Tell machine to reset to CMOS speed
	CALL	SCONOUT
	POP	PSW
	XRA	A	
	RET			;Return
;
;.....
;
; This routine uses a BDOS call for direct console I/O.
;
SCONOUT:
	MVI	C,6		;BDOS direct console i/o function
	CALL	BDOS
	RET
;
;....
;
; The following routine returns a 255 because we were not able to set to
; the proper baud rate because the serial port can't handle it.
;
SET450:
SET710:
	ORI	0FFH		;Make sure zero flag is not set
	RET			;Return
;
;.....
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you patch this file into your copy of MBYE, (using Wordstar's ^KR
; function) then it should work out well. (Be sure to set the SMODEM and 
; SM1200 equates in the main program section to indicate if you are 
; using a Hayes Smartmodem or compatible or not.)
;
;***********************************************************************
