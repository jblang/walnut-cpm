;***********************************************************************
;
;			 MBYE (Modular 'BYE')
;		  TRS-80 Model III UART I/O routines
;		    v2.0 (02/19/84) by Kim Levitt
;
;	These routines will allow the easy patching of MBYE for any 
; type of modem/serial port combination.  Certain routines must return
; status flags, so please be careful to set the flags as directed.
;
; NOTE: The TRS-80 Model III uses the Western Digital TR1602 UART along
; with some additional circuts and latches used to interface it to the
; RS-232C port. The modem status port addresses a set of latches which
; are apparently reset when any data is output to this port, at which
; point a master reset also occurs on the UART, causing DTR to go off,
; the recv/xmit holding registers to be cleared, etc. There is no way
; I know of to reset the modem status latches WITHOUT ALSO resetting the
; UART, and the latches do not reset automatically when the line they
; are monitoring goes off. This means the carrier can be detected going
; ON after a disconnect, (during which a UART reset is done), but it
; CANNOT DETECT CARRIER LOSS DURING MODEM I/O (because the UART cannot
; be repeatedly reset during I/O to reset those blasted modem status
; latches...) WHAT THIS MEANS IS: You MUST set TIMEOUT EQU YES, other-
; wise, if someone hangs up without saying BYE, the system will never
; reset for a new caller... (With the timeout set, it will recover after
; the timeout, which could be several minutes, so set the timeout for
; 2 or 3 minutes maximum...)
;
;-----------------------------------------------------------------------
;
; 02/17/84  Fixed some glaring bugs/deficiencies, added
;	    important note re: TRS modem status latches - Kim Levitt
; 02/07/84  Altered and renamed to work with MBYE	- Kim Levitt
; 11/27/83  Altered and renamed to work with BYE3.	- Irv Hoff
; 08/08/83  Routines added, no fuss, mess, or frills.	- Paul Traina
;
;-----------------------------------------------------------------------
;
; Port addresses:
;
MSPORT:	EQU	0E8H		;modem status/uart reset port	
BPORT:	EQU	0E9H		;baud rate port
SPORT:	EQU	0EAH		;uart status port
CPORT:	EQU	0EAH		;uart control port
DPORT:	EQU	0EBH		;data I/O port
;
; MSPORT modem status port masks:
;
RI:	EQU	00010000b	;ring indicator
DCD:	EQU	00100000b	;data carrier detect
DSR:	EQU	01000000b	;data set ready
CTS:	EQU	10000000b	;clear to send
;
; MSPORT command:
;
RESET:	EQU	00000010b	;UART/modem status reset cmd
;
; SPORT status port masks:
;
TBMT:	EQU	01000000b	;xmit buffer empty
DAV:	EQU	10000000b	;data available
;
PE:	EQU	00001000b	;parity error
FE:	EQU	00010000b	;framing error
OE:	EQU	00100000b	;overrun error
ERR:	EQU	PE+FE+OE	;error bits
;
; CPORT control port commands:
;
CBASE:	EQU	01101100b	;everything on, 8 no 1, no dtr or rts
DTR:	EQU	00000010b	;data terminal ready
RTS:	EQU	00000001b	;request to send
;
; BPORT Baud rate values:
;
BD110:	EQU	22H		;110 baud
BD300:	EQU	55H		;300 baud
BD600:	EQU	66H		;600 baud
BD1200:	EQU	77H		;1200 baud
;
;***********************************************************************
;
; If any of your routines zaps anything other than the Accumulator,
; then you must preserve all other registers.
;
;***********************************************************************
;
; This routine should turn off everything on the modem,  but set baud-
; rate to 300 bps, and get it ready to wait for a ring.  (Also hang it
; up)
;
MDINIT:
	MVI	A,RESET		;reset uart, enable modem control
	OUT	MSPORT
	MVI	A,CBASE		;Xmit on, Recv on, DTR off, RTS off  
	OUT	CPORT
	RET
;
; The following is a routine to determine if there is a character wait-
; ing to be received.  If there are none, the Zero flag will be set,
; otherwise, 0FFH will be returned in register 'A'.  Remember that the
; system will like you a little more if you also mask out framing, par-
; ity, and overrun errors.
;
MDINST:
	IN	SPORT		;Get status
	ANI	DAV		;Got a character?
	RZ			;return now if none
	ORI	0FFH		;else say we got one
	RET			;...and return
;
; The following is a routine to determine if the transmit buffer is em-
; pty.  If empty, it will return with the Zero flag clear.  If not, it
; will return with the Zero flag set.
;
MDOUTST:
	IN	SPORT		;read port
	ANI	TBMT		;mask crap
	RET
;
; The following is a routine that will check to make sure we still have
; carrier.  If no carrier, it will return with the Zero flag set.
; (Actually, on the TRS-80 Model III, it will only detect carrier coming
; on in the initial wait for carrier routine, thereafter it will always
; return NZ until MDINIT or MDRING is called to reset the modem status
; latches.) (See lengthy note at beginning of program.)
;
MDCARCK:
	IN	MSPORT		;read modem status port
	ANI	DCD		;mask carrier detect
	RET
;
; The following routine will check to see if the phone is ringing, if it
; isn't, it will return with Zero set, otherwise Zero will be cleared.
;
MDRING:
	MVI	A,RESET		;reset modem status latches
	OUT	MSPORT		;to get current status
	NOP ! NOP ! NOP ! NOP	;pause (allow latch to set)
	IN	MSPORT		;read modem status port
	ANI	RI		;check if RI on..
	RET
;
; The following is a routine that will input one character from the mo-
; dem port.  If there is nothing there, it will return garbage... so use
; the MDINST routine first.
;
MDINP:
	IN	DPORT		;get character
	ANI	7FH		;strip parity and other garbage
	RET
;
; The following is a routine that will output one character in reg. 'A'
; to the modem.  REMEMBER, that is reg. 'A', not reg. 'C'.
;
; ** Use MDOUTST first to see if buffer is empty **
;
MDOUTP:
	OUT	DPORT		;send it
	RET
;
; The following routine will make the modem answer the phone.
; (Raises DTR and RTS.)
;
MDANSW:
	MVI	A,CBASE+DTR+RTS	;turn on DTR and RTS which will allow
	OUT	CPORT		;..the modem to answer on next ring
	RET
;
;
;***********************************************************************
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply set the appropriate
; equates in the main program.
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
; The following rates, (450 & 710), are not supported for the Model III
;
SET450:
SET710:
	ORI	0FFH		;say rate ng
	RET			;and return
;
;**********************************************************************
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you patch this file into your copy of MBYE, then it should work out
; well.
;
;**********************************************************************
;
