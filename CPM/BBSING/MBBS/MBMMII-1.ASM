;*****************************************************************
;
;			MBYE (Modular 'BYE')
;	      D. C. Hayes MicroModem ][ modem I/O routines
;		    v1.0 (02/07/84) by Kim Levitt
;
; These routines will allow the easy patching of MBYE for any type of
; modem/serial port combination.  Certain routines must return status
; flags, so please be careful to set the flags as directed.
;
; This version is for the Apple ][ running with a MicroModem ][ card.
; It seems to work on those Apples that even APBYE barfed on.  The prob-
; lem was in the Carrier Detect routine, because the Microsoft Z80 card
; screws up on a double strobe type of I/O that they tried to use.  Any-
; way, that means the Answer Phone routine is a crock,  but the thing
; works...
;
; For the Apple, you should set BYELOW to YES. (??)
;
;-----------------------------------------------------------------------
;
; 02/07/84  Altered and renamed to work with MBYE	- Kim Levitt
; 11/27/83  Altered and renamed to work with BYE3	- Irv Hoff
; 08/04/83  Updated for use with ByeII version 1.6	- Paul Traina
; 04/16/83  General code cleanup and optimization.	- Paul Traina
; 03/09/83  Fixed a missing '$+OFFSET' in MDANSW
;	    routine, also improved the "flip" logic
;	    needed for checking carrier and ring.	- Paul Traina
; 10/04/82  Routines added, no fuss, mess, or frills.	- Paul Traina
;
;-----------------------------------------------------------------------
;
; The following define the slot address to use.
;
BASE:	EQU	0E0A6H		;This is the status port location
;				;for slot #2
;
;***********************************************************************
;
; MMII Modem address equates
;
SPORT:	EQU	BASE		;Control/status port
DPORT:	EQU	BASE+1		;Data port
RPORT:	EQU	BASE-1		;Baud rate/modem status port
CPORT:	EQU	BASE-1		;Modem control port
;
; Switch hook and modem commands, output to SPORT
;
BYE:	EQU	0		;on hook or dial-break
ORIG:	EQU	8EH		;off hook originate
ANSW:	EQU	8AH		;off hook answer
TSB:	EQU	8		;2 stop bits
NORM:	EQU	15H		;8 bits, no parity, 1 stop bit
F110:	EQU	11H		;same w/2 stop bits
;
; Modem status input
;
RDET:	EQU	80H		;ring detect
CTS:	EQU	4		;carrier detect
TBMT:	EQU	2		;xmit buffer empty
DAV:	EQU	1		;data available
; 
; Baud rate divisors
;
B110:	EQU	0		;110 bps
B300:	EQU	1		;300 bps
;
;
;***********************************************************************
;
; If any of your routines zaps anything other than the Accumulator, then
; you must preserve all other registers.
;
;***********************************************************************
;
; This routine should turn off everything on the modem, hang up the
; phone, and get it ready to wait for a ring.
;
MDINIT:	XRA	A
	STA	CPORT		;Hang up phone
	STA	SPORT		;Turn of Xmit/Recv
	RET
;
; The following is a routine to determine if there is a character wait-
; ing to be received.  If none are there, the Zero flag will be set,
; otherwise, 255 will be returned in register A.  Remember that the
; system will like you a little more if you also mask out framing,
; parity, and overrun errors.
;
MDINST:	LDA	SPORT		;Get modem status
	ANI	DAV		;Data available?
	RZ			;nope
	ORI	0FFH		;return true
	RET
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is empty, it will return with the Zero flag clear.  If
; the transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST:LDA	SPORT		;Get modem status
	ANI	TBMT		;mask out junk
	RET
;
; The following is a routine that will check to make sure we still have
; carrier.  If there is no carrier it will return with the Zero flag set.
;
MDCARCK:LDA	RPORT		;The Z80 interface likes this dummy load...
	LDA	SPORT		;Get modem status
	CMA			;flip/flop the Zero flag
	ANI	CTS		;got a carrier?
	RET
;
; The following routine will check to see if the phone is ringing, if it
; isn't, it will return with Zero set, otherwise Zero will be cleared.
;
MDRING:	LDA	RPORT		;get ring port status
	CMA			;flip/flop the proper bit
	ANI	RDET		;ringing?
	RET
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage... so
; use the MDINST routine first.
;
MDINP:	LDA	DPORT		;get character
	ANI	7FH		;strip parity and other garbage
	RET
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;
; **** Use MDOUTST first to see if buffer is empty ****
;
MDOUTP:	STA	DPORT		;send character
	RET
;
; The following routine will make the modem answer the phone.  It should
; set baudrate to 300 baud.
;
MDANSW:	MVI	A,ANSW		;Answer phone
	STA	CPORT
	PUSH	D		;save register pair DE
	MVI	E,20		;Wait for modem to turn on
;
ALOP1:	CALL	DELAY
	DCR	E
	JNZ	ALOP1
	POP	D		;restore registers
	CALL	SET300
	PUSH	B		;here is the crock I was telling you
	MVI	B,30		;  about,  I was beating my head for two
;
ALOOP:	CALL	DELAY		;  days trying to figure out why the
	LDA	RPORT		;  carrier detect routine was not work-
	LDA	SPORT		;  ing - it turns out this corck here
	LDA	DPORT		;  will get the modem to work properly.
	LDA	DPORT
	DCR	B
	JNZ	ALOOP
	POP	B
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
SET110:				;110 bps too slow to support
SET450:				;450 bps not supported
SET600:				;600 bps not supported
SET710:				;710 bps not supported
SET1200				;1200 bps not supported
;
SETINV:	ORI	0FFH		;make sure the Zero flag isn't set
	RET
;
; Set speed to 110 baud.
;
SET110:	MVI	A,B110+ANSW
	STA	CPORT		;Set 110 bps
	MVI	A,F110
	STA	SPORT		;Set 8 bits, no parity, 2 stop bits
	RET
;
; Set up for 300 bps
;
SET300:	MVI	A,B300+ANSW
	STA	CPORT		;Set 300 bps
	MVI	A,NORM
	STA	SPORT		;Set 8 bits, no parity, 1 stop bit
	RET
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you patch this file into your copy of MBYE, then it should work out
; well.
;
;**********************************************************************
;
