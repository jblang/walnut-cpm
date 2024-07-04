;*************************************************************************
;
;			     MB7201-1.ASM
;			 MBYE (Modular 'BYE')
;		      7201 MPSC UART I/O routines
;		        with 4618  RTC as timer	
;		     ****** for EPSON QX-10 ******
;			      Version 1.0
;
; Renamed and fixed to work with MBYE    02/15/84   Kim Levitt
; Adapted from BY3-KPSM.ASM	         12/15/83   Albert Doolittle	
; Adapted for use with BYE3-12           12/07/83   Steve Sanders
; Original Z80-SIO routine	         Ver. 1.3   by Steve Fox 
;
=========================================================================
;
;	Set base port for SIO & CTC chips
;
BASEP:	EQU	11h		;Base port for SIO
BASEC:	EQU	06h		;Base port for CTC baud rate generator
;
;The following define the port addresses to use.
;
DPORT:	EQU	BASEP		;Data port
SPORT:	EQU	BASEP+2		;Status/Control port
BPORT:	EQU	BASEC		;Baud rate port
VPORT:	EQU	BASEC+1		;Vector port
;
;The following are SPORT commands (output these to SPORT)
;
RESCHN:	EQU	00011000b	;Reset channel
RESSTA:	EQU	00010000b	;Reset ext/status
WRREG1:	EQU	00000000b	;Value to write to register 1
WRREG3:	EQU	11000001b	;8 bits/char, Rx enable
WRREG4:	EQU	01000100b	;16x, 1 stop bit, no parity
DTROFF:	EQU	00000000b	;DTR off, RTS off
DTRON:	EQU	11101010b	;DTR on, 8 bits/char, Tx enable, RTS on
ONINS:	EQU	00110000b	;Error reset
;
;The following are SPORT status masks
;
DAV:	EQU	00000001b	;Data available
TBMT:	EQU	00000100b	;Transmit buffer empty
DCD:	EQU	00001000b	;Data carrier detect
PE:	EQU	00010000b	;Parity error
OE:	EQU	00100000b	;Overrun error
FE:	EQU	01000000b	;Framing error
ERR:	EQU	PE+OE+FE	;Parity, overrun and framing error
;
;Now comes the time to decide how we set the baud rate.  Set it properly
;for your particular CTC configuration
;
BDVECT:	EQU	0B6H		;QX-10 Vector word
;
; Set Speed values for CTC Command:
;
BD300:	EQU	0A001H		;300 Baud
BD1200:	EQU	06800H		;1200 Baud
;
MDINIT:
	MVI	A,0		;select WR0 (to be sure)
	OUT	SPORT
	MVI	A,RESCHN	;Reset channel
	OUT	SPORT
	MVI	A,4		;Setup to write register 4
	OUT	SPORT
	MVI	A,WRREG4
	OUT	SPORT
	MVI	A,1		;Setup to write register 1
	OUT	SPORT
	MVI	A,WRREG1
	OUT	SPORT
	MVI	A,5		;Setup to write register 5
	OUT	SPORT
	MVI	A,DTROFF	;Clear DTR
	OUT	SPORT		;..Causing Hang-Up
	MVI	A,3		;Setup to write register 3
	OUT	SPORT
	MVI	A,WRREG3	;Initialize receive register
	OUT	SPORT
	RET			;Return
;
; This routine will raise DTR to answer the phone
;
MDANSW:
	MVI	A,5		;WR5
	OUT	SPORT
	MVI	A,DTRON		;turn on DTR
	OUT	SPORT
	RET			;Return
;
;The following routine checks to make sure we still have carrier.
;If there is no carrier, it will return with the Zero flag set.
;
MDCARCK:
	MVI	A,RESSTA	;Reset status, select WR0:
	OUT	SPORT
	IN	SPORT		;Get status
	ANI	DCD		;Check for data carrier
	RET			;Return
;
;The following routine determines if there is a character waiting
;to be received.  If no character is waiting, the Zero flag will be set,
;otherwise, 255 will be returned in register A.
;
MDINST:
	IN	SPORT		;Get status
	ANI	DAV		;Got a character?
	RZ			;Return if none
	ORI	0FFh		;..Otherwise, set the proper flag
	RET			;...and return
;
;The following is a routine that will input one character from the modem
;port.  If there is nothing there, it will return garbage... so use the
;MDINST routine first.
;
MDINP:
	IN	DPORT		;Get character
	ANI	7FH		;Strip parity
	RET			;Return
;
;The following is a routine to determine if the transmit buffer is empty.
;If it is empty, it will return with the Zero flag clear.  If the transmitter
;is busy, then it will return with the Zero flag set.
;
MDOUTST:
	IN	SPORT
	ANI	TBMT		;Mask it
	RET			;Return
;
;The following is a routine that will output one character in register A
;to the modem.  REMEMBER, that is register A, not register C.
; ** Use MDOUTST first to see if buffer is empty **
;
MDOUTP:
	OUT	DPORT		;Send it
	RET			;Return
;
;These next routines set the proper baud rates for the modem.  If you do
;not support the particular rate, then simply put the lable in front of
;the SETINV routine.  If the baud rate change was successful, make SURE
;the Zero flag is set.
;
;Set up for 300 baud
;
SET300:
	PUSH	H
	LXI	H,BD300		;Load rate
	JMP	SETBAUD
;
;Set up for 1200 baud
;
SET1200:
	PUSH	H
	LXI	H,BD1200	;Load rate
;
SETBAUD:
	MVI	A,BDVECT	;Get Vector addr
	OUT	VPORT		;Send to CTC
	MOV	A,H
	OUT	BPORT
	MOV	A,L
	OUT	BPORT		;Send rate
	POP	H
	XRA	A		;Say rate is OK
	RET			;Return
;
;The following routine returns a 255 because we were not able to set to
;the proper baud rate because either the serial port or the modem can't
;handle it.
;
SET110:			;110 baud not supported
SET450:			;450 baud not supported
SET600:			;600 baud not supported
SET710:			;710 baud not supported
;
	ORI	0FFH	;Make sure zero flag is not set
	RET		;and return...
;
;***********************************************************************
;
; That's it for the modem dependent I/O routines. Patch these into MBYE
; where it says INSERT YOUR MODEM DEPENDENT ROUTINES and it should work.
;
;************************************************************************
;
