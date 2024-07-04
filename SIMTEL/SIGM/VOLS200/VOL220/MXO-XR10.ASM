
; MXO-XR10.ASM -- XOR S-100-4 (Rev B CPU) overlay file for MEX112  10/21/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
;		critical customizations:
;			PORT		- Modem status port for your system
;			INITMOD1:	- optional patch for Modem-7 term-mode
;					  command compatability - MEX112 depend
;			INITMOD2:	- modem port initialization
;			NEWBAUD:	- reads MSPEED: & inits baudrate
;			SETUPR:		- custom SET command to change baud 
;					  rate as well as start, stop & data
;					  bit transmission parameters
;			CLREOS: &
;			CLRSCR:		- terminal command for clearing screen
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 10/21/84 - XOR S-100-4 (rev.B CPU) customized	- Howard Vigorita
; 05/24/84 - MEXified overlay			- Biff Bueffel
; 11/11/83 - Renamed to M7XE-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
; MEX service processor stuff
;
MEX	EQU	0D00H		;address of the service processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
;
PRINT	EQU	9		;MEX/BDOS print-string function call

;
;
;	XOR S-100-4 via serial (printer) port
;		note that on the port's "A" paddle card you must:
;			1) replace two pull-up resistors w/jumpers
;			2) connect RTS & CTS w/jumpers
;
PORT		EQU	01h
MODDATP		EQU	PORT-1		;data port for XOR
MODCTL1		EQU	PORT		;modem status port for XOR
MODCTL2		EQU	PORT		;modem status port for XOR
MODSNDB		EQU	01h		;bit to test for ready to send
MODSNDR		EQU	MODSNDB		;change to 0 if bit is 0 when
					;ready to send
MODRCVB		EQU	2		;bit to test for received data
MODRCVR		EQU	MODRCVB		;change to 0 if bit is 0 when
					;data received
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	NO	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	YES	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=check for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'	; @ = Send a 300 ms. break tone		120H
NOCONNCT:	DB	'D'	; D = Disconnect from the phone line	121H
LOGCHR:		DB	'L'	; L = Send logon			122H
LSTCHR:		DB	'P'	; P = Toggle printer			123H
UNSAVE:		DB	'R'	; R = Close input text buffer		124H
TRANCHR:	DB	'T'	; T = Transmit file to remote		125H
SAVECHR:	DB	'Y'	; Y = Open input text buffer		126H
EXTCHR:		DB	'^'	; ^ = Send next character		127H
;
;
		DS	2		;				128H
IN$MODCTL1:	IN	MODCTL1 ! RET	;				12AH
		DS	7
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				154H
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port 	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem status port		15DH
;
;
		DS	2		;Not used by MEX		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	JMP	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  
;
CLREOS:
		LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLRSCRN:
		LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
;
SYSVER:		MVI	C,ILP		;				1A7H
		CALL	MEX
		DB	'for XOR via serial printer port & Hazeltine w/esc'
		DB	CR,LF,0
		RET
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SENDBRK:
	  RET
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBYE:
GOODBYE1:
	  RET
;.....
;
;	
INITMOD:
INITMOD1: 
;	patch to change term-mode commands for modem7 compatability:

TermTable:	EQU	40B8h		; address of Mex112 term-mode command
					; table. To use with a different Mex
					; version hunt down the location of the
					; command table that looks like this:
					; "+E?@N.PSTU"
	LDA	NOCONNCT
	STA	TermTable+4	; disconnect

	LDA	SAVECHR
	STA	TermTable+7	; open text buffer

	LDA	UNSAVE
	STA	TermTable+9	; close text buffer
INITMOD2: 
; XOR S-100-4 (REV-B) initialization -- resets 8251 to 1200 baud
;
	PUSH	H
	PUSH	B
	JMP	OK1200
;
;.....
;
;
; Setup routine to allow changing modem speed with the SET command.
;
;
SETUPR:
	PUSH	H
	PUSH	B
ParmL:	LXI	D,ParmBUF	;point to input buffer for InLnComp
	CALL	JMP$ILPRT
	DB	'Input CR for no change, or',CR,LF
	DB	'       1 for 1 stop bit,  8 data bits, no parity,   or ',CR,LF
	DB	'       2 for 1 stop bit,  7 data bits, even parity, or ',CR,LF
	DB	'       3 for 2 stop bits, 8 data bits, no parity,   or ',CR,LF
	DB	'       4 for 2 stop bits, 7 data bits, even parity, or ',0
	CALL	JMP$INBUF
	LXI	D,ParmBUF+2
	CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	DB	CR,0
	JNC	BaudL		;go to baudrate if got match
	CALL	JMP$InLnComp
	DB	'1',0
	JNC	OKParm1
	CALL	JMP$InLnComp
	DB	'2',0
	JNC	OKParm2
	CALL	JMP$InLnComp
	DB	'3',0
	JNC	OKParm3
	CALL	JMP$InLnComp
	DB	'4',0
	JNC	OKParm4
	CALL	JMP$ILPRT	;all matches failed - tell operator
	DB	'++ Incorrect entry ++',CR,LF,0
	JMP	ParmL		;try again
;
OKParm1:	LXI	h,Parm1
		JMP	LoadParm
;
OKParm2:	LXI	h,Parm2
		JMP	LoadParm

;
OKParm3:	LXI	h,Parm3
		JMP	LoadParm

;
OKParm4:	LXI	h,Parm4
		JMP	LoadParm

LoadParm:	MOV	b,m
		INX	h
		MOV	c,m
		INX	h
		DCR	b
		INR	b
		JZ	BaudL
		DB	0EDh,0B3h	;OUTIR
		JMP	LoadParm

Parm1:	DB	4,Port,0AAh,40h,0100$1110b,0011$0111b,0	;1S, 8D, NP
Parm2:	DB	4,Port,0AAh,40h,0111$1010b,0011$0111b,0 ;1S, 7D, EP
Parm3:	DB	4,Port,0AAh,40h,1100$1110b,0011$0111b,0 ;2S, 8D, NP
Parm4:	DB	4,Port,0AAh,40h,1111$1010b,0011$0111b,0 ;2S, 7D, EP
ParmBuf:
	DB	10,0
	DS	10


BaudL:	LXI	D,BAUDBUF	;point to input buffer for InLnComp
	CALL	JMP$ILPRT
	DB	'Input Baud Rate (CR=nc, 300,  600, 1200, 9600): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	DB	'300',0
	JNC	OK300		;go if got match
	CALL	JMP$InLnComp
	DB	'1200',0
	JNC	OK1200
	CALL	JMP$InLnComp
	DB	'9600',0
	JNC	OK9600
	CALL	JMP$InLnComp
	DB	'600',0
	JNC	OK600
	CALL	JMP$InLnComp
	DB	CR,0
	JNC	NoChg

NoneOK:	CALL	JMP$ILPRT	;all matches failed - tell operator
	DB	'++ Incorrect entry ++',CR,LF,0
	JMP	BaudL		;try again
;
OK600:	MVI	A,3
	MVI	b,06h
	JMP	LOADBD
;
OK9600:	MVI	A,8
	MVI	b,0Eh
	JMP	LOADBD
;

OK1200:	MVI	A,5
	MVI	b,07h
	JMP	LOADBD
;

OK300:	MVI	A,1		;MSPEED 300 baud value
	MVI	b,05h
;

LOADBD:	STA	MSPEED
	IN	0Ah
	IN	0Bh		;read baud switches
	ANI	1111$0000b	;force low nibble off
	MOV	c,a
	MOV	a,b
	ORA	c		;mask c onto upper nibble
	OUT	0Bh		;write the baud rate

NoChg:	POP	B
	POP	H
	RET
;
NEWBAUD:
	PUSH	H
	PUSH	B
	CPI	1
	JZ	OK300
	CPI	5
	JZ	OK1200
	JMP	NoChg
;
BAUDBUF:
	DB	10,0
	DS	10
;
;
EOSMSG:
	  DB	1Bh,17h,0,0,'$'		  	
CLSMSG:
	  DB	1Bh,12h,1Bh,17h,'$'
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
	  END
