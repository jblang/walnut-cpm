;***********************************************************************
;
;			MBYE (Modular 'BYE')
;	     National Semiconductor 2651 UART I/O routines
;		    v1.0 (02/07/84) by Kim Levitt
;     (For CompuPro Interfacer 3, Interfacer 4 & System Support 1)
;
; These routines will allow the easy patching of BYE3 for any type of
; modem/serial port combination.  Certain routines must return status
; flags, so please be careful to set the flags as directed.
;
; This version is for the CompuPro Interfacer 3 or 4 that is connected
; to an external modem.  Note:  I use DSR to tell me if the phone is
; ringing and DCD tells me when I have carrier.
;
; This means, a null-modem cable should be set up as follows:
;
;     Modem Interfacer 3/4	     Function
;	2	3		TXD	->	RXD
;	3	2		RXD	<-	TXD
;	4-\			RTS	-\	(jumpered)
;	5-/			CTS	-/
;	8	8		DCD	->	DCD
;	7	7		Ground	--	Ground
;	22	20		RI	->	DSR
;	20	6		DTR	<-	DSR
;
;-----------------------------------------------------------------------
;
; 02/07/84  Altered and renamed to work with MBYE	- Kim Levitt
; 11/27/83  Altered and renamed to work with BYE3	- Irv Hoff 
; 08/04/83  Added MDQUIT routine which will de-
;	    initalize modem port.			- Paul Traina
; 07/14/83  Added support for Rixon/US Robotics/Hayes
;	    Smartmodem.  Added support for CompuPro
;	    System Support-1.				- Paul Traina
; 10/04/82 Routines added, no fuss, mess, or frills.	- Paul Traina
;
;***********************************************************************
;
; Define which I/O card you are using here
;
GBCINT3:EQU	YES		;yes= CompuPro Interfacer 3 or 4
GBCSS1:	EQU	NO		;yes= CompuPro System Support 1
;
;
; The following define the port address and USART number to use.
;
	 IF	GBCINT3
BASEP:	EQU	010H		;Base port for I3/4 boards
USART:	EQU	6		;USART number to use
	 ENDIF
;
	 IF	GBCSS1
BASEP:	EQU	05CH		;Base port for System Support 1
	 ENDIF
;
;***********************************************************************
;
; Modem port equates
;
DPORT:	EQU	BASEP		;Modem data port
SPORT:	EQU	BASEP+1		;Modem status port
MPORT	EQU	BASEP+2		;Modem mode select port
CPORT:	EQU	BASEP+3		;Modem control port
;
	 IF	GBCINT3
UPORT:	EQU	BASEP+7		;Modem USART select port
	 ENDIF			;GBCINT3
;
;
; Modem status port equates
;
TBMT:	EQU	00000001B		;Transmit buffer empty
DAV:	EQU	00000010B		;Data available
PE:	EQU	00001000B		;Parity error
OE:	EQU	00010000B		;Overrun error
FE:	EQU	00100000B		;Framing error
DCD:	EQU	01000000B		;Carrier detect
RDET:	EQU	10000000B		;Ring detect (tied to I3 DSR line)
;
;
;Mode port equates
;
E8NO1:	EQU	01001110B		;8 data bits, no parity, 1 stop bit
EBASE:	EQU	01110000B		;Mode register 2 base
B110:	EQU	EBASE+2			;110 bps
B300:	EQU	EBASE+5			;300 bps
B600:	EQU	EBASE+6			;600 bps (not implemented)
B1200:	EQU	EBASE+7			;1200 bps
;
;
; Command port equates
;
CBASE:	EQU	00000101B		;Command base
RESET:	EQU	00010000B		;Reset errors
DTR:	EQU	00000010B		;Turn on DTR
RTS:	EQU	00100000B		;Turn on RTS
;
;***********************************************************************
;
; If any of your routines zaps anything other than the Accumulator, then
; you must preserve all other registers.
;
;***********************************************************************
;
; This routine should turn off everything on the modem,  but set baud-
; rate to 300 bps, and get it ready to wait for a ring.  (Also hang it
; up)
;
MDINIT:
	 IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
	CALL	SET300		;Set 300 bps
	MVI	A,CBASE		;Xmit on, Recv on, DTR off, RTS off  
	OUT	CPORT
	RET
;
; The following is a routine to determine if there is a character wait-
; ing to be received.  If none are there, the Zero flag will be set,
; otherwise, 255 will be returned in register A.  Remember that the
; system will like you a little more if you also mask out framing,
; parity, and overrun errors.
;
MDINST:	 IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
;
	 IN	SPORT		;read port
	ANI	DAV		;mask crap
	RZ			;nope, nothing there
	ORI	0FFH		;we got something...
	RET
;
; The following is a routine to determine if the transmit buffer is
; empty.  If it is empty, it will return with the Zero flag clear.  If
; the transmitter is busy, then it will return with the Zero flag set.
;
MDOUTST: IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
;
	IN	SPORT		;read port
	ANI	TBMT		;mask crap
	RET
;
; The following is a routine that will check to make sure we still have
; carrier.  If there is no carrier, it will return with the Zero flag
; set.
;
MDCARCK: IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
;
	IN	SPORT		;read port
	ANI	DCD		;yes, that's right, DSR...
	RET
;
; The following routine will check to see if the phone is ringing, if
; it isn't, it will return with Zero set, otherwise Zero will be cleared.
;
MDRING:	 IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
;
	IN	SPORT		;read status
	ANI	RDET		;yes, use DSR, and nothing else...sigh
	RET
;
; The following is a routine that will input one character from the
; modem port.  If there is nothing there, it will return garbage... so
; use the MDINST routine first.
;
MDINP:	 IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
;
	IN	DPORT		;get character
	ANI	7FH		;strip parity and other garbage
	RET
;
; The following is a routine that will output one character in register
; A to the modem.  REMEMBER, that is register A, not register C.
;
; **** Use MDOUTST first to see if buffer is empty ****
;
MDOUTP:	 IF	GBCINT3
	PUSH	PSW
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	POP	PSW
	 ENDIF
;
	OUT	DPORT		;send it
	RET
;
; The following routine will make the modem answer the phone.
;
MDANSW:	CALL	SET300		;set modem for 300 baud, selects chip
	MVI	A,CBASE+DTR+RTS	;turn on DTR and RTS which will allow
	OUT	CPORT		;..the external modem to answer on the
	RET			;..next ring.
;
; These next routines set the proper baud rates for the modem.  If you
; do not support the particular rate, then simply put the pointer for
; that rate in front of the SETINV routine.  If the baud rate change
; was successful, make SURE the Zero flag is set.
;
; The following routine returns a 255 because we were not able to set to
; the proper baud rate because either the serial port or the modem can't
; handle it.
;
SET110:		
SET450:				;2651 cannot handle 450 baud
SET600:				;J1259 is not very reliable at 600bps
SET710:				;only PMMI's are crazy enough to do 710
;
SETINV:	ORI	0FFH		;make sure the Zero flag isn't set
	RET
;
; Set up for 110 bps
;
SET110:  IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF

	MVI	A,E8NO1+128	;set default formats EXCEPT 2 STOP BITS
	OUT	MPORT
	MVI	A,B110
	OUT	MPORT
	XRA	A
	RET
;
; Set up for 300 bps
;
SET300:	 IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
;
	MVI	A,E8NO1		;set default formats
	OUT	MPORT
	MVI	A,B300		;set baud rate
	OUT	MPORT
	XRA	A
	RET
;
; Set up for 600 bps (some modems can handle 600 bps, if yours can, then
; delete the previous pointer and un-comment this routine.
;
SET600:  IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
;
	MVI	A,E8NO1		;set default formats
	OUT	MPORT
	MVI	A,B600		;set baud rate
	OUT	MPORT
	XRA	A
	RET
;
; Set up for 1200 bps
;
SET1200: IF	GBCINT3
	MVI	A,USART		;Select proper chip
	OUT	UPORT
	 ENDIF
;
	MVI	A,E8NO1		;set default formats
	OUT	MPORT
	MVI	A,B1200		;set baud rate
	OUT	MPORT
	XRA	A
	RET
;
; Ok, that's all of the modem dependent routines that MBYE uses, so if
; you patch this file into your copy of MBYE, then it should work out
; well.
;
;**********************************************************************
;
