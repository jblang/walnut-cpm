;**********************************************************************
;
;			MBYE (Modular 'BYE')
;	    	 Novation Apple-Cat modem routines
;		   v1.0 (02/07/84) by Kim Levitt
;
; These routines will allow the easy patching of MBYE for any type of
; modem/serial port combination.  Certain routines must return status
; flags, so please be careful to set the flags as directed.
;
; This version is for the Apple ][ running with an Apple-Cat modem card.
; (much thanks to Dave Roznar for the original ACAT code)
;
; For the Apple, you should set BYELOW to YES.
;
;-----------------------------------------------------------------------
;
; 02/07/84  Altered and renamed to work with MBYE	- Kim Levitt
; 11/27/83  Altered and renamed to work with BYE3.	- Irv Hoff
; 08/04/83  Updated for ByeII version 1.6		- Paul Traina
; 10/04/82  Routines added, no fuss, mess, or frills.	- Paul Traina
;
;-----------------------------------------------------------------------
;
; The following define the slot address to use.
;
SLOT:	EQU	2		;Apple-Cat residing in Slot #2
;
;***********************************************************************
;
;
; Apple-Cat modem address equates
;
SLOTVAL:EQU	SLOT*16		;number to add for proper slot
;
MCSTATP:EQU	0E080H+SLOTVAL	;Carrier status
LNCTL:	EQU	0E081H+SLOTVAL	;Line control
PHCTL:	EQU	0E082H+SLOTVAL	;Phone control
BSRINT:	EQU	0E083H+SLOTVAL	;BSR and interrupts
RCVCTL:EQU	0E089H+SLOTVAL	;Receiver control
MDPORT:	EQU	0E08AH+SLOTVAL	;Mode (parity/stop bits) port
BAUDPT:	EQU	0E08BH+SLOTVAL	;Baud rate port
XRINT:	EQU	0E08CH+SLOTVAL	;Transmitt/Receive interrupts
TRXCTL:	EQU	0E08DH+SLOTVAL	;Transmitter control
MODSEL:	EQU	0E08FH+SLOTVAL	;Modem select port
;
RSPORT:	EQU	0E08FH+SLOTVAL	;Receive status port
RDPORT:	EQU	0E08BH+SLOTVAL	;Receive data port
TSPORT;	EQU	0E08FH+SLOTVAL	;Transmit status port
TDPORT:	EQU	0E08EH+SLOTVAL	;Transmit data port
;
; Values to poke into ports
;
MAINM:	EQU	0		;Select main modem
HANG:	EQU	0		;Hang up phone
RDET:	EQU	1		;Ring detect
SQLT:	EQU	1		;Squeltch cat
ANSW:	EQU	2		;Answer phone
NOXRINT:EQU	5		;No transmitt/recv interrupts
NOINT:	EQU	6		;No BSR interrupts
DAV:	EQU	8		;Data available
TBMT:	EQU	10H		;Transmit buffer empty
XMT103:	EQU	10H		;Transmitter 103 mode (also clears RX)
XMITOFF:EQU	1FH		;Turn of transmitter
CTS:	EQU	20H		;Carrier detect
ANS103:	EQU	64H		;Receiver 103 mode
CATERR:	EQU	0C0H		;Framing/Overrun errors
B110:	EQU     55H		;Select 110 bps
B300:	EQU     22H		;Select 300 bps
B8NO1:	EQU     03H		;8 data bits, no parity, 1 stop bit
B8NO2:	EQU     0BH		;8 data bits, no parity, 2 stop bits
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
MDINIT:	MVI	A,XMITOFF	;Turn off transmitter
	STA	TRXCTL
	MVI	A,HANG		;Hang up phone
	STA	PHCTL
	RET
;
; The following is a routine to determine if there is a character wait-
; ing to be received.  If none are there, the Zero flag will be set,
; otherwise, 255 will be returned in register A.  Remember that the sys-
; tem will like you a little more if you also mask out framing, parity,
; and overrun errors.
;
MDINST:	LDA	RSPORT		;Get modem status
	ANI	DAV		;Data available?
	RZ			;nope
	ORI	0FFH		;return true
	RET
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is empty, it will return with the Zero flag clear.  If
; the transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST:LDA	TSPORT		;Get modem status
	ANI	TBMT		;mask out junk
	RET
;
; The following is a routine that will check to make sure we still have
; carrier.  If there is no carrier, it will return with the Zero flag
; set.
;
MDCARCK:LDA	MCSTATP		;Get carrier status
	ANI	CTS		;got a carrier?
	RET
;
; The following routine will check to see if the phone is ringing, if it
; isn't, it will return with Zero set, otherwise Zero will be cleared.
;
MDRING:	LDA	TRXCTL		;get ring status
	ANI	RDET		;ringing?
	RET
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage... so
; use the MDINST routine first.
;
MDINP:	MVI	A,XMT103	;Clear receiver
	STA	TRXCTL
	LDA	RDPORT		;Read character
	ANI	7FH		;strip parity and other garbage
	RET
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;
; **** Use MDOUTST first to see if buffer is empty ****
;
MDOUTP:	STA	TDPORT		;send character
	RET
;
; The following routine will make the modem answer the phone.
;
MDANSW:	MVI	A,ANSW		;Answer phone
	STA	PHCTL
	MVI	A,SQLT		;Squelch Cat
	STA	LNCTL
	MVI	A,NOINT		;Disable BSR and interupts
	STA	BSRINT
	MVI	A,ANS103	;Set receiver to 103, answer mode
	STA	RCVCTL
;
	CALL	SET300		;300 baud
	MVI	A,NOXRINT	;No XMIT/RCV interrupts
	STA	XRINT
	MVI	A,XMT103	;Transmitter 103, answer mode
	STA	TRXCTL
	MVI	A,MAINM		;Select main modem
	STA	MODSEL
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
SET110: 			;110 bps too slow to support
SET450:				;450 bps not supported
SET600:				;600 bps not supported
SET710:				;710 bps not supported
SET1200:	
;
SETINV:	ORI	0FFH		;make sure the Zero flag isn't set
	RET
;
; Set speed to 110 baud
;
SET110:	CALL	MDINP		;Clear out garbage since the modem was
	CALL	MDINP		;Set to 300 baud upon answer
	MVI	A,B110		;Set 110 baud
	STA	BAUDPT
	MVI	A,B8NO2		;Set 8 data bits, no parity, 2 stop bits
	STA	MDPORT
	XRA	A		;Force zero flag
	RET
;
; Set up for 300 bps
;
SET300:	CALL	MDINP
	CALL	MDINP
	MVI	A,B300		;Set 300 baud
	STA	BAUDPT
	MVI	A,B8NO1		;Set 8 data bits, no parity, 1 stop bit
	STA	MDPORT
	XRA	A
	RET
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you patch this file into your copy of MBYE, then it should work out
; well.
;
;***********************************************************************
;
