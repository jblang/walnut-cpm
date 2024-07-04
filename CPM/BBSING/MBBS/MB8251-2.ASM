;***********************************************************************
;
;			  MBYE  (Modular BYE)
;			 8251A USART routines
;		Version 2.0 - by Kim Levitt - 02/20/84
;
;	This version is for a 8251A I/O with CTC timer to set speed,
; or for a Morrow Micro Decision using the 8251A baud rate multiplier
; to change baud rates. (Set your printer port baud rate switches to
; 1200 baud and connect your modem to this port.)
;
;	These routines will allow the easy patching of MBYE for any 
; type of modem/serial port combination.  Certain routines must return
; status flags, so please be careful to set the flags as directed.
;
; This version is for the Intel 8251A chip that is hooked up to an ex-
; ternal modem. Since the 8251A cannot detect rings (RI), set NORING EQU
; YES in the main program. Also, since the 8251A cannot detect carrier,
; you should wire pin 8 (DCD) from your modem to pin 6 (DSR) on your
; port, which the 8251 reads to determine if carrier is present.
;
;=======================================================================
;
; 02/20/84  Added equates and code for MicroDecisions   - Kim Levitt
; 02/07/84  Fixed and renamed to work with MBYE		- Kim Levitt
; 11/27/83  Altered and renamed to work with BYE3	- Irv Hoff
; 10/04/83  Modified for use with 8251A I/O with
;	    CTC timer to set speed.			- Irv Hoff
; 10/04/82  Routines added, no fuss, mess, or frills.	- Paul Traina
;
;=======================================================================
;
; Set this equate to YES if you are running on a Morrow MicroDecision
;
MICROD:	EQU	YES		;Yes, if Morrow MicroDecision
;
	 IF	MICROD
BASEP:	EQU	0FEH		;MicroDecision base port address
	 ENDIF
;
	 IF	NOT MICROD
BASEP:	EQU	28H		;Set to your modem's UART base port
RCVPORT:EQU	20H		;Set to recv speed CTC port
XMTPORT:EQU	1AH		;Set to xmit speed CTC port
	 ENDIF
;
; The following define the port address to use.
;
DATPORT:EQU	BASEP		;Data port
STPORT:	EQU	BASEP+1		;Status/Control port
;
; The following are STPORT commands (output these to STPORT)
;
MODINS:	EQU	01001110B	;8 bits, no parity, 1 stop bit, 16x
OFFINS:	EQU	00010000B	;drop DTR and disable RCV/XMT
ONINS:	EQU	00010111B	;reset flags, send DTR, enable rx & tx
RSTINS:	EQU	01000010B	;reset USART and send DTR
;
; The following are STPORT status masks
;
DAV:	EQU	00000010B	;data available
TBMT:	EQU	00000001B	;transmit buffer empty
DSR:	EQU	10000000B	;data set ready (no DCD avail)
FE:	EQU	00100000B	;framing error
OE:	EQU	00010000B	;overrun error
ERR:	EQU	OE+FE		;overrun and framing error
;
	 IF	NOT MICROD
;
; The following are CTC timer baud rates divisors.
;
BD300:	EQU	32		;9600/300  =  300 bps
BD450:	EQU	21		;9600/450  =  450 bps
BD1200:	EQU	8		;9600/1200 = 1200 bps
;
	 ENDIF
;
;=======================================================================
;
; If any of your routines zaps anything other than the Accumulator, then
; you must preserve all other registers.
;
;=======================================================================
;
; This routine should turn off everything on the modem, and get it ready
; to wait for a ring.  (Also hang it up) (lowers DTR)
;
MDINIT:
	MVI	A,RSTINS	;reset UART
	OUT	STPORT
	CALL	UDELAY
;
	 IF	NOT MICROD
	MVI	A,MODINS	;x16 clk, 1 stop bit, etc.
	 ENDIF
;
	 IF	MICROD AND SPDBYTE
	LDA	MSPEED		;if multi speed, check speed byte
	CPI	5		;if not 1200 baud now, set to 300
	JNZ	INIT300
	MVI	A,MODINS	;else set to 1200
	JMP	INITSET
	 ENDIF
;
	 IF	MICROD
INIT300:
	MVI	A,MODINS+1	;x64 clk for 300 initially
	 ENDIF
;
INITSET:
	OUT	STPORT
	CALL	UDELAY
	MVI	A,OFFINS	;Clear DTR
	OUT	STPORT		;causing hangup
	RET			;return
;
; The following routine will make the modem answer the phone. (raise DTR)
;
MDANSW:
	MVI	A,ONINS		;turn on DTR, etc.
	OUT	STPORT
	RET			;return
;
; The following is a routine to determine if there is a character wait-
; ing to be received,  if none, the Zero flag will be set, otherwise it
; returns with FF in register A.  Remember that the system will like you
; a little more if you also mask out framing, parity, and overrun errors.
;
MDINST:
	IN	STPORT		;get status
	ANI	DAV		;got a character?
	RZ			;return if none
	IN	STPORT		;get status again
	ANI	ERR		;check for framing and overrun
	JZ	MDINST1		;no errors
	MVI	A,ONINS		;reset error flags
	OUT	STPORT
	XRA	A		;return false
	RET
;
MDINST1:
	ORI	0FFH		;We have a character
	RET
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is, it will return with the Zero flag clear.  If the
; transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST:
	IN	STPORT
	ANI	TBMT
	RET
;
; The following is a routine that will check to make sure we still have
; carrier.  If there is no carrier, it will return with the Zero flag
; set.
;
MDCARCK:
	IN	STPORT	;get status
	ANI	DSR	;check if Data Set Ready is on (no DCD)
	RET		;(wire modem pin 8 to port pin 6 for carrier read)
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage...
; so use the MDINST routine first.
;
MDINP:
	IN	DATPORT		;get character
	ANI	7FH		;strip parity and other garbage
	RET
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;  
; ** Use MDOUTST first to see if buffer is empty **
;
MDOUTP:
	OUT	DATPORT		;send it
	RET
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply set the appropriate
; S110 - S1200 equates in the main program. If the baud rate change
; is successful, make SURE the Zero flag is set.
;
	 IF	NOT MICROD	;if non-MicroDecision (CTC)
;
; Set up for 300 bps
;
SET300:
	MVI	B,BD300		;load 300 bps
	JMP	SETSPD
;
; Set up for 450 bps
;
SET450:
	MVI	B,BD450		;load 450 bps
	JMP	SETSPD
;
; Set up for 1200 bps
;
SET1200:
	MVI	B,BD1200	;poke in 1200 bps
;
SETSPD:
	MVI	A,47H
	OUT	RCVPORT
	OUT	XMTPORT
	MOV	A,B		;get the speed value back
	OUT	RCVPORT
	OUT	XMTPORT
	XRA	A		;say it is ok
	RET
;
	 ENDIF	;NOT MICROD
;
	 IF	MICROD
;
; On MicroDecisions, there is no software controllable baud rate chip,
; (at least not on the MD1 and MD2, anyway), so only two baud rates
; can be selected, either 300 or 1200 baud, by using the baud rate
; factor variable of the 8251A to change baud rates instead of an
; external baud rate chip. Be sure to set up your dip switches so that
; 1200 is the baud rate for your printer port and attach your modem
; there. Set the switches to 1200 even if it is a 300 only modem, as
; the software will switch to 300 only if switches are set up right.
;
;
SET300:
	MVI	B,MODINS+1	;x64 clk for 300 baud
	JMP	SETBAUD		;change baud rate
;
SET1200:
	MVI	B,MODINS	;x16 clk for 1200 baud
SETBAUD:
	MVI	A,RSTINS	;return to mode instruction reg
	OUT	STPORT
	CALL	UDELAY
	MOV	A,B		;get clk multiplier
	OUT	STPORT
	JMP	UDELAY		;pause and return
;
SET450:
;
	 ENDIF	;MICROD
;
; The following routines returns a 255 because we were not able to set to
; the proper baud rate because the serial port can't handle it.
; (Use S110-S1200 equates and SINGLE equate to select from valid baud
; rates you wish to support. (in main pgm))
;
SET110:
SET600:
SET710:
;
SETINV:
	MVI	A,0FFH
	ORA	A		;make sure the Zero flag isn't set
	RET
;
; 8251 specific USART delay
;
UDELAY:
	NOP
	NOP
	NOP
	RET
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you patch this file into your copy of MBYE, it should work out well.
;
;***********************************************************************
;