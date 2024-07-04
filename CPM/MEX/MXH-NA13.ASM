; MXH-NA13.ASM -- MEXPLUS overlay for North Star Advantage Ver 1.3 - 86/01/14

VER:		EQU	13		;Version number

; NOTE:  This overlay is designed for use with MEXPLUS (version 1.2 or
;        greater) but it is fully compatible with the public domain
;        versions of MEX (version 1.1x)

; Edit this file for your preferences then follow the "TO USE:" example
; shown below.

; Use the MEX "SET" command to change the baudrate when desired.  Use
; "SET" to see the current baud rate and "SET xxxx" to set to xxxx.  It
; starts out at the value specified for the MSPEED equate.  To change
; the default baud rate, use "SET" to set the desired rate, then "CLONE"
; MEX.


;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  

;	For MEX V 1.1x, use MLOAD (version 2.3 or greater)to
;		overlay the the results of this program to the
;		original .COM file:
;
;		A>MLOAD MEX.COM=MEXxxx.COM,[MXO-SMxx,]MXO-NAxx
;			where MXO-SMxx is an optional modem overlay.

;	For MEXPLUS V 1.2 or greater, use MLOAD to create an overlay
;		file (.OVR) and boot MEXPLUS and use its built in 
;		LOAD command to install the overlay:

;		A>MLOAD MXH-NA13.OVR=MXH.NA13.HEX

;		Load MEXPLUS and type:

;		[MEX] A0>>LOAD MXH-NA13.OVR

; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =

; 86/01/14 - Version 1.3 - upgraded to MEXPLUS
;            compatibility - MEXified labels    - Ian Cottrell
;						  Sysop
;						  Info Centre BBS
;						  Ottawa, Ontario
;						  Canada
;						  (613)-990-9774

; 85/09/30 - Version 1.2 - corrected minor bugs	- Ian Cottrell
; 85/03/27 - Version 1.1 - added ability to change
;            default baud rate through "CLONE"
;	     command           			- Ian Cottrell
; 84/11/26 - Version 1.0 -  MEXified overlay    - Ian Cottrell
; 84/07/26 - Added default baud rate and slot # - Ian Cottrell
; 83/11/11 - Renamed to M7NA-1.ASM, no changes	- Irv Hoff
; 83/09/14 - Changed M712HZ.ASM TO M712AF.ASM	- Robert Lehman
; 83/07/27 - Renamed to work with MDM712	- Irv Hoff
; 83/02/17 - 1st version of M712HZ.ASM		- Irv Hoff

; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =

YES:	EQU	0FFH
NO:	EQU	0

MEXP:	EQU	YES		; Set to NO for MEX version 1.1x

SLOT:	EQU	6		; Slot used for modem port
PORT:	EQU	(6-SLOT)*16	; Addr for selected slot
BPORT:	EQU	PORT+8          ; Baud rate port for Advantage
DPORT:	EQU	PORT		; Data port for Advantage
SPORT:	EQU	PORT+1		; Status port for Advantage
CPORT:	EQU	PORT+1		; Control port for Advantage
DAV:	EQU	2		; Data available
TBMT:	EQU	1		; Transmit buffer empty

; MEX Service Processor

MEX:	EQU	0D00H		; Address of the service processor
INMDM:	EQU	255		; Get char from port to A, CY=no more in 100 ms
TIMER:	EQU	254		; Delay 100ms * reg B
TMDINP:	EQU	253		; B=# secs to wait for char, cy=no char
CHEKCC:	EQU	252		; Check for ^C from KBD, Z=present
SNDRDY:	EQU	251		; Test for modem-send ready
RCVRDY:	EQU	250		; Test for modem-receive ready
SNDCHR:	EQU	249		; Send a character to the modem (after sndrdy)
RCVCHR:	EQU	248		; Recv a char from modem (after rcvrdy)
LOOKUP:	EQU	247		; Table search: see CMDTBL comments for info
PARSFN:	EQU	246		; Parse filename from input stream
BDPARS:	EQU	245		; Parse baud-rate from input stream
SBLANK:	EQU	244		; Scan input stream to next non-blank
EVALA:	EQU	243		; Evaluate numeric from input stream
LKAHED:	EQU	242		; Get nxt char w/o removing from input
GNC:	EQU	241		; Get char from input, cy=1 if none
ILP:	EQU	240		; Inline print
DECOUT:	EQU	239		; Decimal output
PRBAUD:	EQU	238		; Print baud rate

CONOUT:	EQU	2		; Simulated BDOS function 2: console char out
PRINT:	EQU	9		; Simulated BDOS function 9: print string
INBUF:	EQU	10		; Input buffer, same structure as BDOS 10

BELL:	EQU	07H		; Bell
CR:	EQU	0DH		; Carriage return
ESC:	EQU	1BH		; Escape
LF:	EQU	0AH		; Linefeed
RON:	EQU	01H		; Reverse video on
ROFF:	EQU	02H		; Reverse video off

; The Advantage uses the 8251


		ORG	100H

	DB	0C3H		; Show that we're an 8080/Z-80 overlay
	DS	2		; For rest of the "JMP   START" instruction

	DS	2		; Unused by MEX

	DB	'P'		; T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:	DB	40		; Clock speed in MHz x10, 25.5 MHz max.	106H
				;   20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	5		; 0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;   6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	5		; 0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;   default time to send char in terinal
				;     mode file transfer for slow BBS.
CRDLY:	DB	5		; 0=0 delay 1=100 ms 5=500 ms-9=900 ms  109H
				;   default time for extra wait after CRLF
				;     in terminal mode file transfer
COLUMS:	DB	5		; Number of DIR columns shown		10AH
SETFLG:	DB	YES		; Yes=user-added Setup routine		10BH
SCRTST:	DB	YES		; Cursor control routine 		10CH
	DS	1		; Unused by MEX				10DH
BAKFLG:	DB	YES		; Yes=change any file same name to .BAK	10EH
CRCDFL:	DB	YES		; Yes=default to CRC checking		10FH
TOGCRC:	DB	YES		; Yes=allow toggling of CRC to Checksum	110H
CVTBS:	DB	NO		; Yes=convert backspace to rub		111H
TOGLBK:	DB	YES		; Yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO		; No=no LF after CR to send file in	113H
				;   terminal mode (added by remote echo)
TOGLF:	DB	YES		; Yes=allow toggling of LF after CR	114H
	DB	YES		; Yes=allow transmission of logon	115H
				;   write logon sequence at location LOGON
SAVCCP:	DB	YES		; Yes=do not overwrite CCP		116H
	DB	NO		; Yes=local command if EXTCHR precedes	117H
				;   no=external command if EXTCHR precedes
	DB	YES		; Yes=allow toggling of LOCONEXTCHR	118H
LSTST:	DB	YES		; Yes=printer available on printer port	119H
XOFTST:	DB	YES		; Yes=checks for XOFF from remote while	11AH
				;   sending a file in terminal mode
XONWT:	DB	NO		; Yes=wait for XON after CR while	11BH
				;   sending a file in terminal mode
TOGF:	DB	YES		; Yes=allow toggling of XOFF checking	11CH
IGNCTL:	DB	YES		; Tes=CTL-chars above ^M not displayed	11DH
EXTRA1:	DB	0		; For future expansion			11EH
EXITCHR:DB	'E'		; E = Exit to main menu			11FH
BRKCHR:	DB	'@'		; @ = Send a 300 ms. break tone		120H
NOCONN:	DB	'N'		; N = Disconnect from the phone line	121H
LOGCHR:	DB	'L'		; L = Send logon			122H
LSTCHR:	DB	'P'		; P = Toggle printer			123H
UNSAVE:	DB	'R'		; R = Close input text buffer		124H
TRANCHR:DB	'T'		; T = Transmit file to remote		125H
SAVECHR:DB	'Y'		; Y = Open input text buffer		125H
EXTCHR:	DB	'^'		; ^ = Send next character		126H


	DS	2		;					128H

INCTL1:	IN	CPORT		; In modem control port			12AH
	RET

	DS	7

OTDATA:	OUT	DPORT		; Out modem data port			134H
	RET

	DS	7

INPORT:	IN	DPORT		; In modem data port			13EH
	RET

	DS	7

MASKR:	ANI	DAV		; Bit to test for receive ready  	148H
	RET

TESTR:	CPI	DAV		; Value of rcv. bit when ready   	14BH
	RET

MASKS:	ANI	TBMT		; Bit to test for send ready     	14EH
	RET

TESTS:	CPI	TBMT		; Value of send bit when ready   	151H
	RET

DCDTST:	JMP	DCDVEC		; Data carrier detect			154H
RNGDET:	JMP	RNGVEC		; Ring detect				157H

	DB	0,0,0,0,0	; Reserved space, assumed 0		15AH

SMDISC:	DS	3		; Smart modem disconnect (not here)	15FH
DIALV:	DS	3		; DIALV:  not done here (maybe MXM-xx)	162H

DISCV:	JMP	DISCON		; Disconnect modem (with DTR)		165H
GOODBV:	JMP	GOODBY		; Call just before exit to CP/M		168H
INMODV:	JMP	NITMOD		; Initialize port			16BH
NEWBDV:	JMP	NEWBD		; Set new baud rate			16EH

	RET  			; NOPARV				171H
	NOP
	NOP

	RET  			; PARITV				174H
	NOP
	NOP

SETUPV:	JMP	SETCMD		;					177H

	DS	3		; Not used by MEX			17AH

VERSNV:	JMP	SYSVER		;					17DH
BREAKV:	JMP	SBREAK		;					180H

; Do not change the following line.

	DS	18		;					183H

; Routines to clear screen and clear to end of screen
; If using these routines, set SCRTST to YES at 10AH (above)

CLREOS:	LXI	D,EOSMSG	;					195H
	MVI     C,PRINT
	CALL	MEX
	RET

CLS:	LXI	D,CLSMSG	;					19EH
	JMP	CLREOS+3

; End of fixed area ... from here to 1FFH is reserved

	ORG	200H		; New boundary for MEXPLUS

SYSVER:	MVI	C,ILP
	CALL	MEX

	 IF	MEXP
	DB	'MEXPLUS '
	 ENDIF			;MEXP

	DB	'Version '
	DB	VER/10+'0'
	DB	'.'
	DB	VER MOD 10+'0'
	DB	' for North Star Advantage - Slot ',SLOT+30H
	DB	CR,LF
	DB	'Default Baud Rate:  ',RON,0
	LDA	MSPEED
	MVI	C,PRBAUD
	CALL	MEX
	MVI	C,ILP
	CALL	MEX
	DB	ROFF
	DB	CR,LF,0
	RET

; Routine called just prior to exit to CP/M

GOODBY:	RET

; Return data carrier detect (DCD) status
;	0   = no carrier
;	255 = carrier present
;	254 = we don't know (DCD not supported)

DCDVEC:	MVI	A,254		; Return 'we don't know'
	RET

; Return ring indicator status
;	0   = not ringing
;	255 = ring detected
;	254 = we don't know (RI not supported)

RNGVEC:	MVI	A,254		; Return 'we don't know'
	RET

; This routine allows a 300 ms. break tone to be send to reset some
; time-share computers.

SBREAK: MVI	A,08H		;send a break tone for 300 ms.
	JMP	DISCON1

; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212a, etc.

DISCON:	MVI	A,0AH		;set break, DTR low

DISCON1:OUT	CPORT		;put command register out of mode
	IN	SPORT		;make sure it is now clear
	IN	SPORT		;try once more
	MVI	B,3		;delay for 300 ms.
	MVI	C,TIMER
	CALL	MEX
	MVI	A,37H		;reset RTS, flags, DTR low, enable R/T
	OUT	CPORT		;send to command register
	IN	DPORT		;clear any incoming chars.
	IN	DPORT		;try once more
	XRA	A		;clear the 'A' reg.
	RET

; The following are used in setting up the modem port.
; Since N/S Bios only initializes the first 3 ports, the
; 8251 for the selected slot is initialized.

NITMOD:	LXI	H,NITSTR	; Point to initialization string
	LXI	B,5*256+PORT+1	; B=count, C=UART cmd port
	DB	0EDH,0B3H	; Z-80 OTIR instruction
	LDA	MSPEED		; Get MSPEED value
	CALL	SBAUD		; Go set baud rate
	JZ	NITERR		; If zero, error
	RET			; No error, normal return

NITERR:	MVI	C,ILP
	CALL	MEX
	DB	'Default baud rate not supported',CR,LF
	DB	'Now set to:  '
	DB	RON,'1200 baud.',ROFF,0
	MVI	A,5		; Set baud rate
	STA	MSPEED		;   to 1200
	CALL	SBAUD		;     baud
	RET

NITSTR:	DB	80H,80H		; Fillers to ensure known state
	DB	040H		; Internal reset
	DB	04EH		; 1 stop bit, 8 data bits, no parity
				; 16x clock
	DB	037H		; TX on, RX on, DTR low, RTS low
				; Reset errors

; The following changes the baud rate with the set command.

SETCMD:	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	TELL		;if not, go display baud rate
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		;parse agrument
	PUSH	H		;save any arg addrs on stack
	RNC			;if we have one, return to it
	POP	H		;oops, input not found in table
	MVI	C,ILP
	CALL	MEX		;tell user input not valid
SETERR:	DB	'++ SET command error ++',CR,LF,BELL,0
	RET

CMDTBL:	DB	'30','0'+80H
	DW	OK300	
	DB	'60','0'+80H
	DW	OK600
	DB	'120','0'+80H
	DW	OK1200
	DB	'240','0'+80H
	DW	OK2400
	DB	'480','0'+80H
	DW	OK4800
	DB	'960','0'+80H
	DW	OK9600
	DB	'1920','0'+80H
	DW	OK19200
	DB	0

TELL:	MVI	C,ILP
	CALL	MEX
	DB	CR,LF,'Baud rate is now: '
	DB	RON,0
	LDA	MSPEED
	MVI	C,PRBAUD
	CALL	MEX
	MVI	C,ILP
	CALL	MEX
	DB	ROFF,0
	RET

OK300:	MVI	A,1
	JMP	LOADBD

OK600:	MVI	A,3
	JMP	LOADBD

OK1200:	MVI	A,5
	JMP	LOADBD

OK2400:	MVI	A,6
	JMP	LOADBD

OK4800:	MVI	A,7
	JMP	LOADBD

OK9600:	MVI	A,8
	JMP	LOADBD

OK19200:MVI	A,9

LOADBD:	STA	MSPEED		; Set xfer time
	CALL	SBAUD		; Go set baud rate
	JZ	SETERR		; If zero, error
	CALL	TELL		; No error, so tell us new rate
	RET
	
SBAUD:	LXI	H,BRTBL		; Calculate required value
	MVI	D,0		;   to send to baud
	MOV	E,A		;     rate register
	DAD	D
	MOV	A,M		; Reg A now contain correct value
	ORA	A		; Zero?
	RZ			; If so, error - return with Z set
	OUT	BPORT		; Else, send to baud rate port
	IN	DPORT		; Clear any incoming chars.
	IN	DPORT		; Try once more
	RET

NEWBD:	CALL	SBAUD		; Go set baud rate
	JZ	SETERR		; If Z, error
	RET			; No error, normal return

; Table of baudrate parameters for N/S SIO board 

BRTBL:	EQU	$

BD110:	DB	00H		;110 baud not supported
BD300:	DB	40H
BD450:	DB	00H		;450 baud not supported
BD600:	DB	60H
BD710:	DB	00H		;710 baud not supported
BD1200:	DB	70H
BD2400:	DB	78H
BD4800:	DB	7CH
BD9600:	DB	7EH
BD19200:DB	7FH

EOSMSG:	  DB	15,0,0,0,0,'$'	;clear to eos for N/S Advantage
CLSMSG:	  DB	30,15,0,0,0,'$'	;clear screen (home and clear eos)

	  END
