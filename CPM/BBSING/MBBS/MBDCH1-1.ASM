;***********************************************************************
;
;			 MBYE (Modular BYE)
;	     D. C. Hayes MicroModem 100 Interface routines
;		      Version 1.6 by Paul Traina
;
; These routines will allow the easy patching of BYE3 for any type of
; modem/serial port combination.  Certain routines must return status
; flags, so please be careful to set the flags as directed.
;
; This version is for the D.C. Hayes MM100 and 80-103a modem cards.  It
; is an adaptation of the routines present in BYE version 8.0
;
;-----------------------------------------------------------------------
;
; 11/27/83  Altered and renamed to work with BYE3.	- Irv Hoff	
; 08/04/83  Updated to work with ByeII version 1.6	- Paul Traina
; 04/16/83  Housekeeping and some code optimization	- Paul Traina
; 11/04/82  Routines added, no fuss, mess, or frills.	- Paul Traina
;
;-----------------------------------------------------------------------
;
; The following define the port address and USART number to use.
;
BASEP	EQU	80H		;Base port for modem card
;
;***********************************************************************
;
; Port equates
;
DPORT:	EQU	BASEP	;Modem data port
SPORT:	EQU	BASEP+1	;Status port and control port #1
CPORT2:	EQU	BASEP+2	;Control port #2
;
;
; Bit functions
;
DAV:	EQU	1	;Receive register full/data available
TBMT:	EQU	2	;Transmitt buffer empty
PE:	EQU	4	;Parity error
FE:	EQU	8	;Framing error
OE:	EQU	10H	;Overrun error
CD:	EQU	40H	;Carrier detect
RI:	EQU	80H	;NOT ring indicator (low=true)
;
NORM8:	EQU	17H	;8 bits, no parity, 1 stop bit
NORM110:EQU	1FH	;8 bits, no parity, 2 stop bits (for 110 bps)
;
BD300:	EQU	83H	;answer mode, 300 bps, answer, turn on carrier
BD110:	EQU	82H	;same as above, but 110 bps
;
;
;***********************************************************************
;
; If any of your routines zaps anything other than the Accumulator, then
; you must preserve all other registers.
;
;***********************************************************************
;
; This routine should turn off everything on the modem, (no carrier,
; on-hook).
;
MDINIT:
	XRA	A		;hangup phone
	OUT	CPORT2		;clear off-hook flag, turn off carrier
	RET
;.....
;
;
; The following routine is used to completely shut-down the modem.  It
; is the same as MDINIT on the MM100.
;
MDQUIT:
	JMP	MDINIT		;same as init
;.....
;
;
; The following is a routine to determine if there is a character wait-
; ing to be received, if none are there, the Zero flag will be set,
; otherwise, 255 will be returned in register A.  Remember that the
; system will like you a little more if you also mask out framing,
; parity, and overrun errors.
;
MDINST:
	IN	SPORT		;get status
	ANI	DAV		;mask garbage out
	RZ			;no character found
	ORI	0FFH		;we got something...
	RET
;.....
;
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is empty, it will return with the Zero flag clear.  If
; the transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST:
	IN	SPORT		;get status
	ANI	TBMT		;transmitter ready?
	RET			;return with proper status
;.....
;
;
; The following is a routine that will check to make sure we still have
; carrier.  If there is no carrier, it will return with the Zero flag set.
;
MDCARCK:
	IN	SPORT		;read port
	ANI	CD		;carrier there?
	RET
;.....
;
;
; The following routine will check to see if the phone is ringing, if it
; isn't, it will return with Zero set, otherwise Zero will be cleared.
;
MDRING:
	IN	SPORT		;read status
	CMA			;invert flags - NOT-RING becomes ring
	ANI	RI		;not ringing?
	RET
;.....
;
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage... so
; use the MDINST routine first.
;
MDINP:
	IN	DPORT		;get character
	ANI	7FH		;strip parity and other garbage
	RET
;.....
;
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;
; **** Use MDOUTST first to see if buffer is empty ****
;
MDOUTP:
	OUT	DPORT		;send it
	RET
;.....
;
;
; The following routine will make the modem answer the phone.
;
MDANSW:
	CALL	SET300		;set modem for 300 baud & answer phone
	RET
;.....
;
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply put in a JMP to SETINV.
; If the baud rate change was successful, make SURE the Zero flag is set.
;
; The following routine returns a 255 because we were not able to set to
; the proper baud rate because either the serial port or the modem can't
; handle ;it.
;
SET450:				;450  bps not supported
SET600:				;600  bps not supported
SET710:				;710  bps not supported
SET1200:			;1200 bps not supported
;
SETINV:
	ORI	0FFH		;make sure the Zero flag isn't set
	RET
;.....
;
;
; The follwing sets us for 110 bps. You may wish to remove this and re-
; place it with a JMP to SETINV because you hate creeps that call in at
; 110 bps and want to download a 200k long files (arrrrgh)
;
SET110:
	MVI	A,NORM110	;set 8 bits, no parity, 2 stop bits
	OUT	SPORT
	MVI	A,BD110		;set 110 baud and answer phone
	OUT	CPORT2
	XRA	A		;make sure Z flag is set
	RET
;.....
;
;
; Set up for 300 bps
;
SET300:
	MVI	A,NORM8		;8 bits, no parity, 1 stop bit
	OUT	SPORT
	MVI	A,BD300		;300 baud and answer phone
	OUT	CPORT2
	XRA	A		;make sure Z is set
	RET
;.....
;
;
; Ok, that's all of the modem dependant routines that BYE3 uses, so if
; you patch this file into your copy of BYE3, then it should work out
; well.
;
;************************************************************************
;
