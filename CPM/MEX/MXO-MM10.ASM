	title	'Overlay for the Morrow Multi I/O Board and/or 8250 ACE'
;
; MXO-MM10.ASM -- MEX Overlay file for the Morrow Multi I/O Board.  05/28/84
;
REV	EQU	10	;V 1.0
;
; This overlay adapts the MEX modem program to the Morrow Multi I/O board
; which uses the 8250 ACE.  It also can be used with an 8250 ACE alone by
; setting MORMIO to FALSE.
;
; This overlay is capable of setting baud rate and setting port number
; (via the SET command), setting baud rate from the phone library, dis-
; connecting the  modem, and sending a break.
;
; *NOTE* This overlay contains two conditionals and uses DTR to disconnect
; the modem.  SET THE DISC EQU TO FALSE in MXO-SMxx.ASM if using that overlay.
; DISC is handled here with DTR.
;
NO	EQU	0
YES	EQU	NOT NO
FALSE	EQU	NO
TRUE	EQU	YES
;
; Set the following two equates as needed:
;
MORMIO	EQU 	TRUE	;true if using Morrow Multi I/O card, false for
;			 stand alone 8250 ACE.
SMDM	EQU	TRUE	;True if using Smartmodem 1200, false and/or change
;			 code for other modems with Morrow Multi I/O
;
; Also, be sure to set your port address and desired baud rates below
;
; NOTE:  I have tested this overlay to the extent possible with MORMIO, SMDM,
; or both FALSE.  However, I could not conduct a full operational test since
; I do not have a properly configured machine.  Please report any bugs,
; suggestions to: Phil Cary, Mesilla Valley RCP/M, (505) 524-6920.
;
; Calling conventions for the various overlay entry points are detailed more
; fully in the PMMI overlay (MXO-PMxx.ASM, where xx=revision number)
;
; History as a MEX overlay
;
; 05/28/84 - 1st version      - Phil Cary, Mesilla Valley RCP/M
;
; Derived from:	MXO-PM10.ASM, Ron Fowler
;     		MXO-SM11.ASM, Ron Fowler
;	        MXO-GB10.ASM, Ron Fowler
;	        SMDMM.ASM, Phil Cary (overlay for MDMxxx)
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
PRINT	EQU	9		;BDOS/MEX print-string function call
;
BELL	EQU	7		;bell
TAB	EQU	9
CR	EQU	13		;carriage return
LF	EQU	10		;linefeed
ESC	EQU	1BH		;escape
;
;
 	IF MORMIO
;
;These are the equates for the Morrow Multi I/O base port and group selection.
;Change as needed to match your configuration.
;
; Morrow Multi I/O port equates
; 
BPORT	EQU	0F8H		;base port for Morrow Multi I/O
GPORT	EQU	BPORT+7		;group select port
MPORT	EQU	2		;default group in use for modem
;				 (2nd serial port)
	ENDIF
;
;
	IF NOT MORMIO
;
; 8250 port equates
;
BPORT	EQU	00H	;If using stand alone 8250, put base port address here.
;
	ENDIF
;
MODDAT:	EQU	BPORT		;data port(dlab=0)
MODIER: EQU	BPORT+1		;interrupt enable register(dlab=0)
MODLCR:	EQU	BPORT+3		;line control register
MODMCR:	EQU	BPORT+4		;modem control register
MODLSR:	EQU	BPORT+5		;line status register
LBAUDP:	EQU	BPORT		;LSB baud rate divisor latch(dlab=1)
MBAUDP:	EQU	BPORT+1		;MSB baud rate divisor latch(dlab=1)
;
;These are equates for the 8250 register masks or control words.
;
;line control register
;
wls0	equ	00000001b	;for eight bit word
wls1	equ	00000010b	;for eight bit word
sbrk	equ	01000000b	;set break
dlab	equ	10000000b	;baud rate divisor latch active
;
;modem control register
;
dtr	equ	00000001b	;DTR on
;
;line status register
;
dr	equ	00000001b	;data ready
thre	equ	00100000b	;transmitter holding register empty
;
;
; Baud rate parameters - change EQU to 0000h if you do not wish to support
; a particular baud rate.
;
BD110:	EQU	0417H	;110 baud
BD300:	EQU	0180H	;300 baud
BD450:	EQU	0120H	;450 baud
BD600:	EQU	00C0H	;600 baud
BD710:	EQU	0000H	;710 baud (not supported)
BD1200:	EQU	0060H	;1200 baud
BD2400:	EQU	0030H	;2400 baud
BD4800:	EQU	0018H	;4800 baud
BD9600:	EQU	000CH	;9600 baud
BD19200	EQU	0006H	;19200 baud
;
	ORG	100H
;
; Change the clock speed to suit your system
;
	DS	3		;(for  "JMP   START" instruction)

	DB	NO		;yes=PMMI S-100 Modem			103H
	DB	YES		;yes=HAYES Smartmodem, no=non-PMMI	104H
	DB	'T'		;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:	DB	40		;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	5		;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	5		;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:	DB	5		;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:	DB	5		;number of DIR columns shown		10AH
SETFLG:	DB	YES		;yes=user-added Setup routine		10BH
SCRTST:	DB	YES		;Cursor control routine 		10CH
	DB	YES		;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKFLG:	DB	NO		;yes=change any file same name to .BAK	10EH
CRCDFL:	DB	YES		;yes=default to CRC checking		10FH
TOGCRC:	DB	YES		;yes=allow toggling of CRC to Checksum	110H
CVTBS:	DB	NO		;yes=convert backspace to rub		111H
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO		;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR	114H
	DB	YES		;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP		116H
	DB	NO		;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
	DB	YES		;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:	DB	YES		;yes=printer available on printer port	119H
XOFTST:	DB	NO		;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:	DB	YES		;yes=allow toggling of XOFF checking	11CH
IGNCTL:	DB	YES		;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:	DB	0		;for future expansion			11EH
EXITCHR	DB	'E'-40H		;^E = Exit to main menu			11FH
BRKCHR:	DB	'@'-40H		;^@ = Send 300 ms. break tone		120H
NOCONN:	DB	'N'-40H		;^N = Disconnect from the phone line	121H
LOGCHR:	DB	'L'-40H		;^L = Send logon			122H
LSTCHR:	DB	'P'-40H		;^P = Toggle printer			123H
UNSAVE:	DB	'R'-40H		;^R = Close input text buffer		124H
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote		125H
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer		126H
EXTCHR:	DB	'^'-40H		;^^ = Send next character		127H
	DS	2		;unused by MEX				128H
;
INCTL1:	JMP	INSP		;go input status port			12AH
	DS	7
;
OTDATA:	JMP	OUTDP		;go output data port			134H
	DS	7
;
INPORT:	JMP	INDP		;go input data port			13EH
	DS	7
;
MASKR:	ANI	dr	! RET	;bit to test for receive ready		148H
TESTR:	CPI	dr	! RET	;value of rcv. bit when ready		14BH
MASKS:	ANI	thre	! RET	;bit to test for send ready		14EH
TESTS:	CPI	thre	! RET	;value of send bit when ready		151H
	DS	12		;					156H
;
;
	DS	2		;for log on msg pointer
	DS	3		;DIALV: not done here (maybe MXO-SM)	162H
DISCV:	JMP	DISCON		;disconnect
GOODBV:	JMP	GOODBY		;					168H
INMODV:	JMP	NITMOD		;go to user written routine		16BH
NEWBDV: JMP     PBAUD		;					16EH 
	RET ! NOP ! NOP		;NOPARV					171H
	RET ! NOP ! NOP		;PARITV					174H
SETUPV:	JMP	SETCMD		;					177H
	DS	3		;not used by MEX			17AH
VERSNV:	JMP	SYSVER		;					17DH
BREAKV:	JMP	SBREAK		;					180H
;
; Do not change the following six lines (they provide access to routines
; in MEX that are present to support MDM7 overlays -- they will likely
; be gone by MEX v2.0).
;
ILPRTV:	DS	3		;					183H
INBUFV	DS	3		;					186H
ILCMPV:	DS	3		;					189H
INMDMV:	DS	3		;					18CH
	DS	3		;					18FH
TIMERV	DS	3		;					192H
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRTEST to YES at 010AH (above).
;
CLREOS:	LXI	D,EOSMSG	;					195H
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLS:	LXI	D,CLSMSG	;					19EH
	MVI	C,PRINT
	CALL	MEX
	RET
;									1A7H
;
; end of fixed area
;
SYSVER:	MVI	C,ILP		;in-line print
	CALL	MEX
;
	IF MORMIO
;
	DB	'Morrow Multi I/O at 0F8H  V.' 
;
	ENDIF
;
	IF NOT MORMIO
;
	DB	'Version for 8250 ACE  V.'
;
	ENDIF
;
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	CR,LF
;
	IF SMDM
;
	DB	'with Hayes Smartmodem 1200',CR,LF,LF
;
	ENDIF

	DB	0
;
	MVI	C,ILP
	CALL	MEX
	DB	'Defaults-  ',0
	JMP	TELL
;
; Routine to exit just prior to exit-to-cpm
;
GOODBY:	RET			;not done here
;
; Send break to remote
;
SBREAK:	MVI	A,sbrk		;send break for 300ms
	CALL	OUTCP
	PUSH	B
	MVI	B,3
	MVI	C,TIMER
	CALL	MEX
	POP	B
	MVI	A,wls0+wls1	;reset to normal 8 bits, 1 stop, dlab off
	CALL	OUTCP
	RET
;
; Disconnect the modem
;
DISCON:	XRA	A		;turn off DTR
	CALL	OUTMP
	PUSH	B
	MVI	B,10		;turn off DTR for 1000 ms.(my smartmodem
	MVI	C,TIMER		;seems to require more than 300ms to hang up)
	CALL	MEX
	POP	B
	MVI	A,dtr		;turn DTR back on
	CALL	OUTMP
	RET
;
; Initialize the port with default baud rate(1200)
;
NITMOD:	PUSH	H
	PUSH	D
	PUSH	B
NITMO1:	MVI	A,5		;default to 1200 baud
	STA	MSPEED
	CALL	SELGRP		;select morrow group
	XRA	A		;disable 8250 interrupts
	OUT	MODIER		;interrupt enable register
	MVI	A,wls0+wls1+dlab ;8 bit word, 1 stop, baud rate div on
	out	MODLCR

LSBSPD:	MVI	A,60H		;default 'LSB' for 1200 baud
	OUT	LBAUDP		;register for 'LSB' when dlab=1

MSBSPD:	MVI	A,00H		;default 'MSB' for 1200 baud
	OUT	MBAUDP		;register for 'MSB' when dlab=1
;
; finish up
;
	MVI	A,wls0+wls1	;8 bit, 1 stop, turn dlab off
	out	MODLCR
	MVI	A,dtr		;Be sure DTR is on
	out	MODMCR
;
	IF 	SMDM
;
; for smartmodem only, send AT to set modem baudrate.

	LXI	H,SMSET
	CALL	SMSEND
SMCLR	MVI	C,INMDM
	CALL	MEX
	JNC	SMCLR

	ENDIF

	ORA 	A		;no errors, clear carry for return to STBAUD
	POP	B
	POP	D
	POP	H
	RET
;
	IF SMDM
;
SMSEND:	MVI	C,SNDRDY	;WAIT FOR MODEM READY
	CALL	MEX
	JNZ	SMSEND
	MOV	A,M		;FETCH NEXT CHARACTER
	INX	H
	ORA	A		;END?
	RZ			;DONE IF SO
	MOV	B,A		;NO, POSITION FOR SENDING
	MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	CALL	MEX
	JMP	SMSEND
;
SMSET:	DB	'AT',CR,0	;kick the modem
;
	ENDIF
;
; SET command: select baud rate, port number. Port number may be any of
; 1,2,, or 3, baud rate any of 110, 300, 450, 600, 1200, 2400, 4800
; 9600, 19200.  Special set-port syntax allows baud rate after port
; number.  Examples:
;
;	SET PORT 1
;	SET PORT 2 1200
;	SET PORT 3 300
;	SET BAUD 9600
;
SETCMD:	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	TELL		;if not, go display port/baud
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		;parse argument
	PUSH	H		;save any parsed argument adrs on stack
	RNC			;if we have one, return to it
	POP	H		;oops, input not found in table
SETERR:	MVI	C,ILP		;inline print
	CALL	MEX
	DB	CR,LF,'SET command error',CR,LF,0
	RET
;
; Argument table
;
CMDTBL:	DB	'?'+80H		;help
	DW	STHELP
	DB	'BAU','D'+80H	;"set baud"
	DW	STBAUD
;
	IF	MORMIO
;
	DB	'POR','T'+80H	;"set port"
	DW	SETPOR
;
	ENDIF
;
	DB	0		;<<=== table terminator
;
; "SET ?" processor
;
STHELP:	MVI	C,ILP		;inline print
	CALL	MEX
	DB	CR,LF,'SET BAUD <rate>'
;
	IF MORMIO
;
	DB	CR,LF,'SET PORT <port-number>'
	DB	CR,LF,'SET PORT <port-number> <baud-rate>'
;
	ENDIF
;
	DB	CR,LF,'Baud rate is one of:'
	DB	CR,LF,'  110 300 450 600 1200 2400 4800 9600 19200'
;
	IF	MORMIO
;
	DB	CR,LF,'Port number is one of:'
	DB	CR,LF,'  1, 2, or 3 for Morrow Multi I/O'
;
	ENDIF
;
	DB	CR,LF,0		;end of message
	RET
;
; "SET BAUD" processor
;
STBAUD:	MVI	C,BDPARS	;function code: parse a baudrate
	CALL	MEX		;let MEX look up code
	JC	BDERR		;jump if invalid code
	CALL	PBAUD		;no, try to set it
	JC	BDERR		;if not one of ours, bomb out
	JMP	TELL		;show the settings
;
BDERR:	MVI	C,ILP
	CALL	MEX
	DB	'Invalid baud rate selected',cr,lf,0
	RET
;
	IF	MORMIO
;
; SET PORT processor
;
SETPOR:	MVI	C,SBLANK	;scan to argument
	CALL	MEX
	JC	SETERR		;if no arg, bomb out
	MVI	C,GNC		;else consume it
	CALL	MEX
	SUI	'0'		;convert
	CPI	0
	JZ	PRTERR		;less than 1
	CPI	3+1
	JNC	PRTERR		;more than 3
	STA	PORTS
	MVI	C,SBLANK	;any thing more?
	CALL	MEX
	JNC	STBAUD		;if so, go parse as baud rate
;
	ENDIF
;
TELL:	
;
	IF	MORMIO
;
	MVI	C,ILP
	CALL	MEX
	DB	'Port: ',0
	LDA	PORTS
	ADI	'0'		;get port # in ASCII
	STA	PORTAS
	MVI	C,ILP
	CALL	MEX
PORTAS:	DB	' ,  ',0
;
	ENDIF
;
	MVI	C,ILP		;inline print
	CALL	MEX		;display baud
	DB	'Baud: ',0
	LDA	MSPEED		;get current baud rate
	MVI	C,PRBAUD	;let MEX print it
	CALL	MEX
	RET
;
PRTERR: MVI	C,ILP
	CALL	MEX
	DB	'Invalid port selected',CR,LF,0
	RET



; This routine sets baud rate passed as MSPEED code in A.
; Returns CY=1 if baud rate not supported (if supported,
; this routine must set the new MSPEED code).
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	MOV	E,A		;MSPEED code to DE
	MVI	D,0
	LXI	H,BAUDTB	;offset into table
	DAD	D
	DAD	D		;each entry two bytes
	MOV	A,M		;get LSB
	ORA	A		;0? (means unsupported code)
	STC			;prep carry in case unsupported
	JZ	PBEXIT		;exit if bad
	MOV 	A,E		;get MSPEED back
	STA	NITMO1+1	;store in NITMOD for execution
	MOV	A,M		;get LSB of baud rate divisor
	STA	LSBSPD+1	;store in NITMOD for execution
	INX	H		;bump to MSB
	MOV	A,M		;get it
	STA	MSBSPD+1	;store it
	JMP	NITMO1		;go initialize the port/modem,
;				 carry reset there
;
PBEXIT:	POP	B
	POP	D
	POP	H
	RET
;
BAUDTB:	DW	BD110,BD300,BD450,BD600,BD710
	DW	BD1200,BD2400,BD4800,BD9600,BD19200
;
;	Port access routines
;
; Input
;
INSP:	CALL	SELGRP		;select morrow group
	IN	MODLSR		;get the status
	RET

INDP:	CALL	SELGRP		;select morrow group
	IN	MODDAT		;get the char
	RET
;
; Output
;
OUTDP:	PUSH	PSW		;save the character
	CALL	SELGRP		;select group
	POP	PSW		;get char back
	OUT	MODDAT		;and send it
	RET

OUTMP:	PUSH	PSW		;save A
	CALL	SELGRP		;select group
	POP	PSW		;get A back
	OUT	MODMCR		;send it to modem control register
	RET

OUTCP:	PUSH	PSW		;save A
	CALL	SELGRP		;select group
	POP	PSW		;get A back
	OUT	MODLCR		;send it to line control reg
	RET

; Select Morrow Multi I/O group(port)
;
SELGRP:	
;
	IF MORMIO
;
	LDA	PORTS
	OUT	GPORT		;select Morrow group #
;
	ENDIF
;
	RET
;
	IF	MORMIO
;
PORTS:	DB	MPORT		;default modem group(port)
;
	ENDIF
;
; Clear-to-end-of-screen and clear-screen sequences(H/Z 19)
;
EOSMSG:	DB	ESC,'J','$'
CLSMSG:	DB	ESC,'E','$'
;
;
	END
