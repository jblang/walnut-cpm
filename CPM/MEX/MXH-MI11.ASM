	TITLE	'MEXPLUS overlay for PMC Micromate 101, Version 1.1'

; MXH-MI10.ASM - MEXPLUS OVERLAY FOR PMC MICROMATE 101
;   Version 1.1  January 04/87
;	(Delete above TITLE if not assembling with MAC)

VER:	EQU	11		; Version number


; History:

; 87/01/04 Fixed bug in NEWBD routine.  This routine destroyed HL, which
;          some modem overlays (like MXM-2416.ASM) required be preserved.
;          Also deleted some superfluous code.
;                               Ian Cottrell

; 85/12/28 Created from MXO-MI13.ASM
;				Ian Cottrell,
;				Dept Energy, Mines and Resources,
;				Ottawa, Canada

; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;	/////////////////////////////////////////
;	/					/
;	/	- - W A R N I N G - -		/
;	/					/
;	/    This code uses CP/M 3 dependent	/
;	/    stuff.				/
;	/					/
;	/////////////////////////////////////////

; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Use the MEX "SET" command to change the baud rate when desired.  Use
; "SET" to see the current baud rate and "SET xxxx" to set to xxxx.  It
; starts out at the value specified for the MSPEED equate.  To change
; the default baud rate, use "SET" to set the desired rate, then "CLONE"
; MEX.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =


BELL:	EQU	07H		; Bell
CR:	EQU	0DH		; Carriage return
ESC:	EQU	1BH		; Escape
LF:	EQU	0AH		; Linefeed

BDOS:	EQU	05H		; BDOS entry point

YES:	EQU	0FFH
NO:	EQU	0

RVIDEO:	EQU	YES		; Yes if terminal supports reverse video
				; Be sure to set RON and ROFF to correct
				; values

; PMC Micromate Model 101 dependant stuff

PORT:	EQU	89H		; PMC serial modem port
DPORT:	EQU	PORT		; Modem data port
CPORT:	EQU	PORT+2		; Modem control port
SPORT:	EQU	PORT+2		; Modem status port
DAV:	EQU	01H		; Data available
TBMT:	EQU	04H		; Tranmit buffer empty
DCD:	EQU	08H		; check for data carrier detect
RI:	EQU	10H		; check for ring indicator

; Terminal definitions (currently set for Qume QVT-103)
; If your terminal uses less characters for these functions, set the
; extra ones to space (20H), starting from the 1st character.

ATT1:	EQU	20H		; 1st character of reverse video sequence
ATT2:	EQU	0EH		; 2nd character of reverse video sequence
RON:	EQU	'D'		; 3rd character (rev vid on)
ROFF:	EQU	'E'		; 3rd character (rev vid off)

CLR1:	EQU	20H		; 1st character of clear screen functions
CLR:	EQU	18H		; 2nd character (clear screen)
CLEOS:	EQU	17H		; 2nd character (clear end of screen)

; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; MEX Service Processor

MEX	EQU	0D00H		; Address of the service processor
INMDM	EQU	255		; Get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		; Delay 100ms * reg B
TMDINP	EQU	253		; B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		; Check for ^C from KBD, Z=present
SNDRDY	EQU	251		; Test for modem-send ready
RCVRDY	EQU	250		; Test for modem-receive ready
SNDCHR	EQU	249		; Send a character to the modem (after sndrdy)
RCVCHR	EQU	248		; Recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		; Table search: see CMDTBL comments for info
PARSFN	EQU	246		; Parse filename from input stream
BDPARS	EQU	245		; Parse baud-rate from input stream
SBLANK	EQU	244		; Scan input stream to next non-blank
EVALA	EQU	243		; Evaluate numeric from input stream
LKAHED	EQU	242		; Get nxt char w/o removing from input
GNC	EQU	241		; Get char from input, cy=1 if none
ILP	EQU	240		; Inline print
DECOUT	EQU	239		; Decimal output
PRBAUD	EQU	238		; Print baud rate

CONOUT	EQU	2		; Simulated BDOS function 2: console char out
PRINT	EQU	9		; Simulated BDOS function 9: print string
INBUF	EQU	10		; Input buffer, same structure as BDOS 10

	ORG	100H

	DB	0C3H		; Show that we're an 8080/Z-80 overlay
	DS	2		; rest of the jump instruction

	DS	2		; unused by MEX

	DB	'P'		; T=touch, P=pulse (Smartmodem-only)	 105H
CLOCK:	DB	40		; Clock speed in MHz x10, 25.5 MHz max.  106H
				;    20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	5		; 0=110 1=300 2=450 3=600 4=710 5=1200	 107H
				;    6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	2		; 0=0 delay  1=10ms  5=50 ms - 9=90 ms	 108H
				;    Default time to send char in terminal
				;    mode file transfer for slow BBS.
CRDLY:	DB	4		; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;    Default time for extra wait after CRLF
				;    in terminal mode file transfer
COLUMS:	DB	5		; Number of DIR columns shown		 10AH
SETFLG: DB	YES		; Yes=user-added Setup routine		 10BH
SCRTST: DB	YES		; Cursor control routine		 10CH
	DS	1		; unused by MEX
BAKFLG: DB	NO		; Yes=change any file same name to .BAK  10EH
CRCDFL:	DB	YES		; Yes=default to CRC checking		 10FH
TOGCRC: DB	YES		; Yes=allow toggling of CRC to Checksum  110H
CVTBS: 	DB	NO		; Yes=convert backspace to rub		 111H
TOGLBK: DB	YES		; Yes=allow toggling of bksp to rub	 112H
ADDLF:	DB	NO		; No=no LF after CR to send file in	 113H
				;    terminal mode (added by remote echo)
TOGLF: 	DB	YES		; Yes=allow toggling of LF after CR	 114H
	DB	YES		; Yes=allow transmission of logon	 115H
				;    write logon sequence at location LOGON
SAVCCP:	DB	YES		; Yes=do not overwrite CCP		 116H
	DB	NO		; Yes=local command if EXTCHR precedes	 117H
				; No=external command if EXTCHR precedes
	DB	YES		; Yes=allow toggling of LOCONEXTCHR	 118H
LSTST:	DB	NO		; Yes=printer available on printer port  119H
XOFTST:	DB	YES		; Yes=checks for XOFF from remote while  11AH 
				;    sending a file in terminal mode
XONWT:	DB	NO		; Yes=wait for XON after CR while	 11BH
				;    sending a file in terminal mode
TOGF	DB	YES		; Yes=allow toggling of XOFF checking	 11CH
IGNCTL:	DB	YES		; Yes=CTL-chars above ^M not displayed	 11DH 
EXTRA1:	DB	0		; For future expansion			 11EH
EXITCHR:DB	'E'		; E = Exit to main menu		 	 11FH
BRKCHR:	DB	'@'		; @ = Send 300 ms. break tone		 120H
NOCONN: DB	'D'		; D = Disconnect from the phone line	 121H
LOGCHR:	DB	'L'		; L = Send logon			 122H
LSTCHR:	DB	'P'		; P = Toggle printer			 123H
UNSAVE:	DB	'U'		; U = Close input text buffer		 124H
TRANCHR:DB	'T'		; T = Transmit file to remote		 125H
SAVECHR:DB	'S'		; S = Open input text buffer		 126H
EXTCHR:	DB	'^'		; ^ = Send next character		 127H

	DS	2		; 					 128H

INCTL1: XRA	A		; Output 00H to command port		 12AH 
	OUT	CPORT		; 					 12BH 
	MVI	A,10H		; Output 10H to command port		 12DH
	OUT	CPORT		; 					 12FH 
	IN	SPORT		; Get status bits.			 131H
	RET			; 					 133H
;
OTDATA: OUT 	DPORT		; Out modem data port			 134H
	RET

	DS	7		; 					 137H

INPORT: IN	DPORT		; In modem data port			 13EH
	RET

	DS	7		; 				 	 141H

MASKR: 	ANI DAV			; Bit to test for receive ready 	 148H
	RET

TESTR: 	CPI DAV			; Value of rcv. bit when ready		 14BH
	RET

MASKS: 	ANI TBMT		; Bit to test for send ready		 14EH
	RET

TESTS: 	CPI TBMT		; Value of send bit when ready		 151H
	RET

DCDTST:	JMP	DCDVEC		; Data carrier detect			 154H
RNGDET:	JMP	RNGVEC		; ring detect				 157H

	DB	0,0,0,0,0	; reserved space, assumed 0

SMDISC:	DS	3		; smartmodem disconnect (not here)
DIALV:	DS	3		; DIALV:  not done here (maybe MXO-SM)

DISCV:  JMP 	DISCON		; Disconnect modem			 165H
GOODBV: JMP 	GOODBY		; Reset port				 168H
INMODV: JMP 	NITMOD		; Initialize port			 16BH
NEWBDV: JMP 	NEWBD		; Set new baud rate			 16EH

	RET			; NOPARV				 171H
	NOP
	NOP

	RET			; PARITV				 174H
	NOP
	NOP

SETUPV: JMP	SETCMD		; 					 177H

	DS	3		; Not used by MEX			 17AH

VERSNV: JMP	SYSVER		; 					 17DH
BREAKV: JMP	SBREAK		; 					 180H

; Do not change the following line

	DS	18

; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).

CLREOS:	LXI	D,EOSMSG	;					 195H
	MVI	C,PRINT
	CALL	MEX
	RET

CLS:	LXI	D,CLSMSG	;					 19EH
	MVI	C,PRINT
	CALL	MEX
	RET

; End of fixed area ... from here to 1FFH is reserved

	ORG	200H		; new boundary for MEXPLUS

SYSVER:	MVI	C,ILP
	CALL	MEX
	DB	'MEXPLUS version '
	DB	VER/10+'0'
	DB	'.'
	DB	VER MOD	10+'0'
	DB	' for PMC Micromate Model 101 - '
	DB	CR,LF
	DB	'Default Baud Rate: '

	 IF	RVIDEO
	DB	ATT1,ATT2,RON
	 ENDIF
	DB	0
	LDA	MSPEED
	MVI	C,PRBAUD
	CALL	MEX

	 IF	RVIDEO
	MVI	C,ILP
	CALL	MEX
	DB	ATT1,ATT2,ROFF,0
	 ENDIF
	RET

; Routine called just prior to exit to CP/M

GOODBY:	RET

; Return data carrier detect (DCD) status
;        0   = no carrier
;        255 = carrier present
;        254 = we don't know (DCD not supported)

DCDVEC:	MVI	A,254		; Return 'we don't know'
;	CALL	INCTL1		; Get status
;	ANI	DCD		; Test for DCD
;	MVI	A,255		; Assume it's there
;	RNZ			; It was!
;	XRA	A		; No it wasn't
	RET

; Return ring indicator status
;        0   = not ringing
;        255 = ring detected
;        254 = we don't know (RI not supported)

RNGVEC:	MVI	A,254		; Return 'we don't know'
	RET

; Routine to send a 300 ms break tone to reset some time-sharing
; computers.

SBREAK:	MVI	A,5		; Select register 5
	OUT	CPORT
	MVI	A,0F8H		; Send break
SBRK1:	OUT	CPORT
	MVI	B,3		; Delay 300 ms
	MVI	C,TIMER
	CALL	MEX
	MVI	A,5		; Register 5 again
	OUT	CPORT
	MVI	A,0E8H		; Reset to normal (8 bits, DTR on, etc.)
	OUT	CPORT
	RET

; Routine to set DTR low for 300 ms to hang-up modem

DISCON:	MVI	A,5		; Select register 5
	OUT	CPORT
	MVI	A,068H		; Drop DTR (and send break)
	JMP	SBRK1		; Save a litte code here


; You can use this area for any special initialization or setup you may
; wish to include.  Each must end with a RET. You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.

NITMOD:	LDA	MSPEED		; Get MSPEED value
        PUSH	H               ; Save HL (needed by some modem overlays)
	LXI	H,BRTBL		; Calculate required value
	MVI	D,0		;   to send to baud
	MOV	E,A		;      rate register
	DAD	D
	MOV	A,M		; Reg A now contains correct value
	ORA	A		; Was value zero?
	JNZ	NITMOD1		; If not zero, continue
	LDA	BD1200		; Else, default to 1200 baud
NITMOD1:PUSH	PSW		; Save baud rate value
	MVI	C,32H		; Function: direct bios call.
	LXI	D,BIOSPB	; BIOS parameter block
	CALL	BDOS
	LXI	D,8+7		; Index to BAUD rate in 2nd
	DAD	D		; Entry. (i.e. MODEM)
	POP	D		; Get new code back (in D)
	MOV	A,M		; Best not to change high
	ANI	0F0H		;    nibble, whatever it is.
	ORA	D		; Put new code in table.
	MOV	M,A
	MVI	C,32H		; Function: direct bios call.
	LXI	D,BIOSPB1	; Initialize device means to
	CALL	BDOS		; Set BAUD rate to PMC.
	IN	DPORT		; Clear any incoming chars
	IN	DPORT		; Try once more
	XRA	A		; Clear the 'A' reg
        POP	H		; Now restore HL
	RET

;Allow baud rate change w SET cmd

SETCMD:	MVI	C,SBLANK	; Any arguments
	CALL	MEX
	JC	TELL		; If not, go display baud
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		; Parse argument
	PUSH	H		; Save any arg addrs on stack
	RNC			; If we have one, return to it
	POP	H		; Oops, input not found in table
	MVI	C,ILP
	CALL	MEX		; Tell user input not valid
	DB	'++ Incorrect Entry ++',CR,LF,BELL,0
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
	DW	OK1920
	DB	0		; End of table

TELL:	MVI	C,ILP
	CALL	MEX		; Print current baud rate
	DB	CR,LF,'Baud rate is now: '

	 IF	RVIDEO
	DB	ATT1,ATT2,RON
	 ENDIF

	DB	0
	LDA	MSPEED
	MVI	C,PRBAUD
	CALL	MEX

	 IF	RVIDEO
	MVI	C,ILP
	CALL	MEX
	DB	ATT1,ATT2,ROFF,0
	 ENDIF

	RET

OK300:	MVI	A,1		; MSPEED 300 baud value
	JMP	BDSET		; Go do it

OK600:	MVI	A,3
	JMP	BDSET

OK1200:	MVI	A,5
	JMP	BDSET

OK2400:	MVI	A,6
	JMP	BDSET

OK4800:	MVI	A,7
	JMP	BDSET

OK9600:	MVI	A,8
	JMP	BDSET

OK1920:	MVI	A,9

BDSET:	STA	MSPEED		; Update MSPEED
	JMP	NITMOD

BAUDMCH:PUSH	PSW		; Save MSPEED value
	PUSH	H		; Save baud code
	MVI	C,32H		; Function: direct bios call.
	LXI	D,BIOSPB	; BIOS parameter block
	CALL	5
	LXI	D,8+7		; Index to BAUD rate in 2nd
	DAD	D		; Entry. (i.e. MODEM)
	POP	D		; Get new code back.
	MOV	A,M		; Best not to change high
	ANI	0F0H		; Nibble, whatever it is.
	ORA	E		; Put new code in table.
	MOV	M,A

	MVI	C,32H		; Function: direct bios call.
	LXI	D,BIOSPB1	; Initialize device means to
	CALL	5		; Set BAUD rate to PMC.
	POP	PSW		; Restore MSPEED value
	STA	MSPEED		; Set it
	RET

NEWBD:	CPI	1
	JZ	BDSET
	CPI	3
	JZ	BDSET
	CPI	5
	JZ	BDSET
	CPI	6
	JZ	BDSET
	CPI	7
	JZ	BDSET
	CPI	8
	JZ	BDSET
	CPI	9
	JZ	BDSET
	RET

; Table of Baud Rate Parameters

BRTBL:	EQU	$

BD110:	DB	00H		; 110 baud not supported
BD300:	DB	06H
BD450:	DB	00H		; 450 baud not supported
BD600:	DB	07H
BD710:	DB	00H		; 710 baud not supported
BD1200:	DB	08H
BD2400:	DB	0AH
BD4800:	DB	0CH
BD9600:	DB	0EH
BD1920:	DB	0FH

BIOSPB	DB	20		; BIOS fcn: return devtbl address
	DB	0		; A-reg contents
	DW	0		; BC-reg contents
	DW	0		; DE-reg contents
	DW	0		; HL-reg contents

BIOSPB1	DB	21		; BIOS fcn: initialize device in C-reg
	DB	0		; A-reg contents
	DB	1		; C-reg (= 1 for MODEM)
	DB	0		; B-reg
	DW	0		; DE-reg
	DW	0		; HL-reg


BAUDBUF:DB	10,0
	DS	10

EOSMSG:	DB	CLR1,CLEOS,0,0,0,'$'	; Clear to end of screen
CLSMSG:	DB	CLR1,CLR,0,0,0,'$'	; Clear screen

	END
