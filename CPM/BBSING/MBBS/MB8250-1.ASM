;***********************************************************************
;
;		       MBYE (Modular 'BYE')
;			8250 UART routines
;		   v1.0 (02/07/84) by Kim Levitt
;
;	This is adapted from the WD8250 routines in BYE3.
;
;	These routines will allow the easy patching of MBYE for any 
; type of modem/serial port combination.  Certain routines must return
; status flags, so please be careful to set the flags as directed.
;
; This version is for the Western Digital 8250 chip that is hooked up to
; an external modem.  If your modem cannot detect a ring, then set
; NORING true.
;
;=======================================================================
;
; 02/07/84  Altered and renamed to work with MBYE	- Kim Levitt
; 11/27/83  Altered and renamed to work with BYE3	- Irv Hoff
; 08/04/83  Added MDQUIT routine			- Paul Traina
; 07/18/83  Fixed several bugs that I put in 		- Paul Traina
; 10/04/82  Initial re-write of old 8250 routines	- Paul Traina
;
;=======================================================================
;
; The following define the port address to use.
;
BASEP:	EQU	0D8H		;Base port modem port
DATPORT:EQU	BASEP		;Data port
LPORT:	EQU	BASEP+3		;Line control
CPORT:	EQU	BASEP+4		;Modem control
SPORT:	EQU	BASEP+5		;Line status port
MSPORT:	EQU	BASEP+6		;Modem status port
RPORT:	EQU	BASEP+6		;Ring indicator port
;
; Line status bits
;
DAV:	EQU	00000001B	;Data available
ORUN:	EQU	00000010B	;Overrun error
PERR:	EQU	00000100B	;Parity error
FERR:	EQU	00001000B	;Framing error
ERR:	EQU	ORUN+PERR+FERR	;Error bits
TBMT:	EQU	00100000B	;Transmitt buffer empty
;
; Modem status bits
;
DSR:	EQU	00100000B	;Data set ready
RDET:	EQU	01000000B	;Ring detect
DCD:	EQU	10000000B	;Carrier detect
;
; Baud rate divisors
;
BR300LS: EQU	080H		;300 baud
BR300MS: EQU	001H
BR450LS: EQU	000H		;450 baud
BR450MS: EQU	001H
BR600LS: EQU	0C0H		;600 baud
BR600MS: EQU	000H
BR120LS: EQU	060H		;1200 baud
BR120MS: EQU	000H
;
;	Modem control bits
;
DTR:	EQU	00000001B	;Data terminal ready
RTS:	EQU	00000010B	;Request to send
OUT1:	EQU	00000100B	;Aux output #1
OUT2:	EQU	00001000B	;Aux output #2
;
;	Line control bits
;
WLS0:	EQU	00000001B	;Word length select 0
WLS1:	EQU	00000010B	;Word length select 1
STB:	EQU	00000100B	;Stop bit select
PEN:	EQU	00001000B	;Parity enable
PES:	EQU	00010000B	;Even parity select
SPS:	EQU	00100000B
BRKS:	EQU	01000000B	;Break
DLAB:	EQU	10000000B
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
; to wait for a ring.  (Also hang it up)
;
MDINIT:
	XRA	A		;Shut off DTR & RTS
	OUT	CPORT		;..which turns off modem.
	RET
;
; The following routine will make the modem answer the phone.
;
MDANSW:
	MVI	A,DTR+RTS	;Turn on DTR and let modem answer phone
	OUT	CPORT
	CALL	SET300		;Set 300 baud (for init only)
	MVI	A,WLS0+WLS1	;8 data bits, 1 stop bit, no parity
	OUT	LPORT
	RET
;
; The following is a routine to determine if there is a character wait-
; ing to be received, if none, Zero flag will be set, otherwise, 0FFH
; will be returned in register A.  Remember that the system will like
; you a little more if you also mask out framing, parity, and overrun
; errors.
;
MDINST:
	PUSH	B		;Save BC
	IN	SPORT		;Get status
	MOV	B,A		;Save it in B (status cleared by read)
	ANI	DAV		;Data available?
	JZ	NDAV		;Return if not ready
	MOV	A,B		;else, check error bits
	ANI	ERR		;for parity/overrun/framing errors
	JZ	DAVA		;if none, ok...
	IN	DPORT		;else clear garbage
;
NDAV:
	XRA	A		;say no data
	POP	B		;restore BC
	RET			;and return
;
DAVA:
	ORI	0FFH		;We have a character
	POP	B		;restore BC
	RET			;and return
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is empty, it will return with the Zero flag clear.  If
; the transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST:
	IN	SPORT
	ANI	TBMT
	RET
;
; The following is a routine that will check to make sure we still have
; carrier.  If there is no carrier, it will return with the Zero flag
; set.
;
MDCARCK:
	IN	MSPORT			;Get modem status
	ANI	DCD			;Got a carrier?
	RET
;
; The following routine will check to see if the phone is ringing, if it
; isn't, it will return with Zero set, otherwise Zero will be cleared.
;
MDRING:
	IN	RPORT		;Ringing?
	ANI	RDET		;1=yes, 0=no
	RET
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
; do not support the particular rate, then simply remove that routine
; and put the pointer in front of SETINV.
;
; If the baud rate change was successful, make SURE the Zero flag is set.
;
; The following routine returns a 255 because we were not able to set to
; the proper baud rate because either the serial port or the modem can't
; handle it.
;
SET110:				;110 baud is seldom used
SET600:				;600 bause is only for PMMI
SET710:				;710 baud is only for PMMI
;
SETINV:
	ORI	0FFH
	RET
;
; Set up for 300 baud
;
SET300:
	PUSH	D		;Set 300
	MVI	D,BR300MS
 	MVI	E,BR300LS
	JMP	SETALL
;
; Set up for 450 baud
;
SET450:
	PUSH	D		;Set 450
	MVI	D,BR450MS
	MVI	E,BR450LS
	JMP	SETALL
;
; Set up for 1200 baud
;
SET1200:
	PUSH	D		;Set 1200
	MVI	D,BR120MS
	MVI	E,BR120LS
;
SETALL:
	CALL	SETBAUD
	POP	D
	XRA	A
	RET
;
; This routine takes the baud rate divisors passed in the DE register
; and sets the modem port accordingly.
;
SETBAUD:
	MVI	A,83H		;Set DLAB
	OUT	LPORT
	MOV	A,E		;Get LSB
	OUT	DATPORT
	MOV	A,D		;Get MSB
	OUT	DATPORT+1
	MVI	A,WLS0+WLS1	;8 data bits, no parity, 1 stop bit
	OUT 	LPORT
	PUSH	B
	MVI	B,2		;wait about .2 seconds
	CALL	DELAY
	POP	B
	IN	DATPORT		;Clear out any inpuyt chars.
	IN	DATPORT
	RET
;
; Ok, that's all of the modem dependant routines that MBYE uses, so if
; you patch this file into your copy of MBYE, then it should work out
; well.
;
;**********************************************************************
;
