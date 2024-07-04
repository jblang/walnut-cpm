;***********************************************************************
;
;			 MBYE (Modular 'BYE')
;		Overlay for Kaypro 4'84 Internal Modem
;		    v1.0 (05/12/85) by Terry Carroll
;
; These routines will allow the easy patching of MBYE for the
; Kaypro 4'84 Internal Modem.  Certain routines must return status
; flags, so please be careful to set the flags as directed.
;
; NOTE: In the main MBYE program, be sure to set the following equates:
;
;          NORING:	EQU 	NO
;	   SINGLE: 	EQU 	YES
;	   S300:  	EQU 	YES
;
;       Set all other baud rate equates to NO.
;       Set all modem equates to NO.
;
;-----------------------------------------------------------------------
;
; 05/12/85  Initial version	-----	 Terry Carroll
;					 The Poor Man's RCP/M
;					 Bedford, Texas
;					 817-283-9167
;					 24 hours, 300/1200 Baud
;
;-----------------------------------------------------------------------
;
; Set base ports
;
SIOBASEP:	EQU	0DH		;Base port for SIO
PIOBASEP:	EQU	21H		;Base port for PIO
BAUDRATE:	EQU	00H		;Baud rate port
;
; The following define the port addresses to use.
;
DPORT:		EQU	SIOBASEP	;SIO Data port
SPORT:		EQU	SIOBASEP+2	;SIO Status/Control port
PDPORT:		EQU	PIOBASEP	;PIO Data port
PSPORT:		EQU	PIOBASEP+2	;PIO Status/Control port
BPORT:		EQU	BAUDRATE	;Baud rate port
;
;
; The following are SPORT commands (output these to SPORT)
;
; WR0:
RESCHN:		EQU	00011000B	;Reset channel
RESSTA:		EQU	00010000B	;Reset ext/status
RESERR:		EQU	00110000B	;Error reset
;
WRREG1:		EQU	00000000B	;WR1 - No interrupts
WRREG3:		EQU	11000001B	;WR3 - Rx 8 bits/char, Rx enable
WRREG4:		EQU	01000100B	;WR4 - 16x, 1 stop bit, no parity
;
; WR5:
DTROFF:		EQU	01101000B	;DTR off, Tx 8 bits, Tx enable, RTS off
DTRON:		EQU	11101010B	;DTR on, Tx 8 bits, Tx enable, RTS on
;
;
; The following are SPORT status masks
;
; RR0:
DAV:		EQU	00000001B	;Data available
TBMT:		EQU	00000100B	;Transmit buffer empty
DCD:		EQU	00001000B	;Data carrier detect
RI:		EQU	00100000B	;Ring Indicator
;
; RR1:
OE:		EQU	00100000B	;Overrun error
FE:		EQU	01000000B	;Framing error
ERR:		EQU	OE+FE		;Overrun and framing errors
;
; 8116 (on Kaypros at least) is initialized by system on cold boot,
; only need to set baud rate as single command to baud rate port.
; The Kaypro 4'84 only supports 300 baud; other values are included here
; for informational purposes.
;
BD110:		EQU	02H
BD300:		EQU	05H
BD600:		EQU	06H
BD1200:		EQU	07H
BD2400:		EQU	0AH
BD4800:		EQU	0CH
BD9600:		EQU	0EH
BD19K:		EQU	0FH
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
	MVI	A,00001111B	;PIO initialization
	OUT	PSPORT
	MVI	A,01011111B
	OUT	PDPORT
	MVI	B,10
	CALL	DELAY
	MVI	A,11011111B	
	OUT	PDPORT
	MVI	B,10
	CALL	DELAY
	MVI	A,01011111B
	OUT	PDPORT
	MVI	A,10000111B
	OUT	PSPORT
	MVI	A,10000110B
	OUT	PSPORT
	MVI	A,01000000B	;Set modem on-hook (hang-up)
	OUT	PDPORT
	MVI	A,0
	OUT	SPORT
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
;
; This routine will check the Ring Indicator status,
; returning a non-zero value if the RI line is active.
;
MDRING:
	MVI	A,RESSTA	;reset status latches
	OUT	SPORT		;to get CURRENT
	IN	SPORT		;status
	ANI	RI		;check RI status
	RET
;
; The following routine will raise DTR. (and RTS)
;
MDANSW:
	MVI	A,5		;address WR5
	OUT	SPORT
	MVI	A,DTRON		;raise DTR, RTS
	OUT	SPORT
	MVI	A,00010000B	;answer phone (off hook)
	OUT	PDPORT
	MVI	B,10
	CALL	DELAY
	RET			;Return
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
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage... so
; use the MDINST routine first.
;
MDINP:
	IN	DPORT		;Get character
	ANI	7FH		;Strip parity
	RET			;Return
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is empty, it will return with the Zero flag clear.  If
; the transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST:
	IN	SPORT
	ANI	TBMT		;Mask it
	RET			;Return
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;
; **** Use MDOUTST first to see if buffer is empty ****
;
MDOUTP:
	OUT	DPORT		;Send it
	RET			;Return
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply put the label in front
; of the ORI 0FFH / RET. If the baud rate change was successful, make
; SURE the Zero flag is set (XRA A).
;
SET300:
	MVI	A,BD300
;
SETBAUD:
	OUT	BPORT		;set baud rate
	XRA	A		;say rate ok
	RET			;and return
;
; The following baud rates are not supported on the Kaypro 4'84
;
SET110:
SET450:
SET600:
SET710:
SET1200:
SET2400:
	ORI	0FFH		;say rate ng
	RET
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you insert this file into your copy of MBYE, then it should work out
; well.
;
;***********************************************************************
