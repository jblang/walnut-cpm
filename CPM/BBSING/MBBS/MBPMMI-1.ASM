;***********************************************************************
;
;			MBYE (Modular 'BYE')
;	   Potomic Micro Magic Incorporated modem routines
;		   v1.0 (02/07/84) by Kim Levitt
;
; These routines will allow the easy patching of MBYE for any type of
; modem/serial port combination.  Certain routines must return status
; flags, so please be careful to set the flags as directed.
;
; This version is for the PMMI S100 modem card.
;
; Current revision history: (in reverse order to minimize reading time)
;
; 02/07/84  Altered and renamed to work with MBYE	- Kim Levitt
; 11/27/83  Altered and renamed to work with BYE3	- Irv Hoff
; 08/04/83  Updated for use with ByeII version 1.6	- Paul Traina
; 04/16/83  General code optimization & housecleaning	- Paul Traina
; 01/29/82  Removed check for framing and overrun errors
;	    which get screwed when TSTBAUD'ing...	- Paul Traina
; 11/28/82  Fixed some conventions in file format,
;	    cleaned up for distribution.		- Paul Traina
; 11/27/82  Fixed MDCARCK and MDRING routines to work 
;	    with PMMI convention.  Corrected syntax
;	    errors with 8bit.				- Frank Gaude
; 11/25/82  Routines added, no fuss, mess, or frills.	- Paul Traina
;
;***********************************************************************
;
; The following define the port address for the PMMI card.
;
BASEP:	EQU	0C0H		;Base port for PMMI modem
;
; Modem port equates
;
TPORT:	EQU	BASEP		;control port #1
DPORT:	EQU	BASEP+1 	;data port
RPORT:	EQU	BASEP+2 	;baud rate generator/modem status
CPORT:	EQU	BASEP+3 	;modem control port
;
; Switch hook and modem commands, output to TPORT (port 0)
;
BYE:	EQU	0		;hang up
ANSW:	EQU	2		;off hook, answer mode
BIT8:	EQU	0CH		;8 data bits
NOPY:	EQU	10H		;no parity
TSB:	EQU	40H		;2 stop bits
NORM:	EQU	BIT8+NOPY	;normal, 8 bits, no parity
P110:	EQU	BIT8+NOPY+TSB	;same w/2 stop bits
;
; Modem status, input on RPORT (port 3)
;
DTD:	EQU	1		;dial tone detect
RDET:	EQU	2		;ring detect
CTS:	EQU	4		;CTS (carrier detect)
CONN:	EQU	10H		;connected? (0=yes, 1=modem hung up)
;
; Control port values for filter mask
;
LE300:	EQU	7FH		;less than or equal to 300 bps
GT300:	EQU	5FH		;greater than 300 bps
;
; PMMI modem status masks
;
TBMT:	EQU	1		;xmit buffer empty
DAV:	EQU	2		;data available
OE:	EQU	10H		;overrun error	
FE;	EQU	20H		;framing error
;
; Baud rate divisors
;
B110:	EQU	142		;110 bps
B300:	EQU	52		;300 bps
B450:	EQU	35		;450 bps
B600:	EQU	26		;600 bps
B710:	EQU	22		;710 bps
;
;
;***********************************************************************
;
; If any of your routines zaps anything other than the Accumulator, then
; you must preserve all other registers.
;
;***********************************************************************
;
; This routine should turn off everything on the modem, and get it ready
; to wait for a ring.  (Also hang it up.)
;
MDINIT:
	XRA	A		;get disconnect value
	OUT	TPORT		;reset orig/answer
	OUT	CPORT		;turn off DTR, do break
	RET
;
; The following is a routine to determine if there is a character wait-
; ing to be received,  if none are there,  the Zero flag will be set,
; otherwise, 255 will be returned in register A.  Remember that the
; system may like you a little more if you also mask out framing,
; parity, and overrun errors.  (On some modems, you can't because of
; problems with the baud rate selection.)
;
MDINST:
	IN	TPORT		;get status
	ANI	DAV		;data available?
	RZ			;return if not ready
	ORI	0FFH		;we got something...
	RET
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it isn't, then it will return with the Zero flag set.  If
; the transmitter is not empty, it will return with Zero clear.
;
MDOUTST:
	IN	TPORT	;get modem status
	ANI	TBMT	;transmit buffer empty
	RET
;
; The following is a routine that will check to make sure we still have
; carrier.  If there is no carrier, it will return with the Zero flag
; set.
;
MDCARCK:
	IN	RPORT		;get status of modem
	CMA			;reverse for pmmi convention
	ANI	CTS		;clear to send?
	RET
;
; The following routine will check to see if the phone is ringing, if it
; isn't, ;it will return with Zero set, otherwise Zero will be cleared.
;
MDRING:
	IN	RPORT		;get ring status
	CMA			;reverse for pmmi convention
	ANI	RDET		;mask all but ring
	RET
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage... so
; use the MDINST routine first.
;
MDINP:
	IN	DPORT		;get character
	ANI	7FH		;strip parity and other garbage
	RET
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;
; **** Use MDOUTST first to see if buffer is empty ****
;
MDOUTP:
	OUT	DPORT		;send it
	RET
;
; The following routine will make the modem answer the phone.  It should
; also set baud rate to 300 bps.
;
MDANSW:
	MVI	A,LE300		;filter value for 300 bps (DTR)
	OUT	CPORT
	CALL	DELAY		;give time to turn on (.1 sec)
	MVI	A,P110+ANSW	;answer phone
	OUT	TPORT
	CALL	DELAY		;give time for answer
	IN	DPORT		;clear modem port
	IN	DPORT		;make sure it's clear
	CALL	SET300		;set modem for 300 bps
	RET
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply put in a JMP to SETINV.
; If the baud rate change was successful, make SURE the Zero flag is set.
;
; The following routine returns a 255 because we were not able to set to
; the proper baud rate because either the serial port or the modem can't
; handle it.
;
SET1200:			;PMMI does not support 1200 bps
;
SETINV:	ORI	0FFH		;make sure the Zero flag isn't set
	RET
;
; Set up for 110 bps
;
SET110:
	MVI	A,LE300		;set filter value to less than 300 bps
	OUT	CPORT
	MVI	A,P110		; 8 data bits, no parity, 2 stop bits
	OUT	TPORT
	MVI	A,B110		; 110 bps
	OUT	RPORT
	XRA	A		;return 110 as a valid rate
	RET
;
; Set up for 300 bps
;
SET300:
	MVI	A,LE300		;filter set to less than or = 300 bps
	OUT	CPORT
	MVI	A,NORM		;set for 8 bits, no parity, 1 stop bit
	OUT	TPORT
	MVI	A,B300		;set divisor to 300 bps
	OUT	RPORT
	XRA	A		;return with 300 bps as a valid rate
	RET
;
; Set up for 450 bps
;
SET450:
	MVI	A,GT300		;set filter value for >300 bps
	OUT	CPORT
	MVI	A,NORM		;set for 8 bits, no parity, 1 stop bit
	OUT	TPORT
	MVI	A,B450		;set for 450 bps
	OUT	RPORT
	XRA	A		;return saying 450 is ok
	RET
;
; Set up for 600 bps
;
SET600:
	MVI	A,GT300		;set filter value for >300 bps
	OUT	CPORT
	MVI	A,NORM		;set for 8 bits, no parity, 1 stop bit
	OUT	TPORT
	MVI	A,B600		;set for 600 bps
	OUT	RPORT
	XRA	A		;return saying 600 bps is valid
	RET
;
; Set up for 710 bps
;
SET710:
	MVI	A,GT300		;set filter value for >300 bps
	OUT	CPORT
	MVI	A,NORM		;set for 8 bits, no parity, 1 stop bit
	OUT	TPORT
	MVI	A,B710		;set for 710 bps
	OUT	RPORT
	XRA	A		;return saying 710 bps is valid
	RET
;
; Ok, that's all of the modem dependant routines that MBYE uses, so if
; you patch this file into your copy of MBYE, then it should work out
; well.
;
;************************************************************************
;
