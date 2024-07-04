	title	'CompuPro overlay for Interfacer 3/4'
;
; MXO-GB11.ASM -- MEX Overlay file for the CompuPro I3/I4 & SS1.  06/16/84
;
; This overlay adapts the MEX modem program to the CompuPro Interfacer 3 or
; Interfacer 4 or System Support 1 serial cards using the 2651 USART chip.
;
;
; This overlay is capable of setting baud rate and setting port number
; (via the SET command), setting baud rate from the phone library, dis-
; connecting the  modem, and sending a break.
;
REV	EQU	11	;V 1.1
;
; NOTE TO INTERFACER 4 USERS:
; The 'MIDDLE' serial port and the Centronics port can have their addresses
; changed using a hardware option.  Godbout did this to maintain software
; compatibility with their bios.  In order to prevent problems, use the
; 'RIGHT' serial port (RELATIVE USER 5) instead of the center serial
; port (RELATIVE USER 6).  Also, read page 19 of the manual, the modem
; port will probably have to be set up in the 'MASTER MODE'.  While 
; you're reading the manual, read the section on 'WAIT STATE LOGIC'.
; I'm using a CPU-Z running at 6Mhz, with a 300 baud modem and two wait
; states (jumper at J7).  Without them, I get 'o's for 'n's and 'g's
; for 'f's, and the checksums are never right.	(AWW 12/20/83)
;
; Calling conventions for the various overlay entry points are detailed more
; fully in the PMMI overlay (MXO-PMxx.ASM, where xx=revision number)
;
; History as a MEX overlay
;
; 06/16/84 - Baud rate can now be automaticaly selected by MEX
;	     when making a call with CAL command. Also Baud rate
;	     is now correctly initialized.     - Alex Soya
;
; 05/12/84 - SET port (0-7, S -- S=SS1)	       - Ron Fowler
; 05/11/84 - MEXified the overlay	       - Ron Fowler
;
; History as an MDM7 overlay
;
; 11/20/83 - Interfacer 4 note added		- A.W. Warren
; 11/11/83 - Renamed to M7IN-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/11/83 - Modifed somewhat for MDM711	- Irv Hoff
; 07/08/83 - Adapted from MDM711GP.ASM		- Paul Traina
;
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
YES	EQU	0FFH
NO	EQU	0
;
; Interfacer 3/4 and SS1 port equates
; 
INBASE	EQU	010H		;base port of CompuPro I3 or I4 card(s)
SSBASE	EQU	05CH		;base of serial section of CompuPro SS1
;
UPORT	EQU	INBASE+7	;user (chip select) port
;
; Port offsets
;
DPORT:	EQU	0		;data port
SPORT:	EQU	1		;status port
MPORT:	EQU	2		;mode port
CPORT:	EQU	3		;control port
;
TBMT:	EQU	01H		;transmit buffer empty
DAV:	EQU	02H		;data available
;
; Baud rate parameters
;
BD300:	EQU	35H		;300 baud
BD600:	EQU	36H		;600 baud
BD1200: EQU	37H		;1200 baud
BD4800: EQU	3CH		;4800 baud
BD9600: EQU	3EH		;9600 baud
BD19200 EQU	3FH		;19200 baud
;
	ORG	100H
;
; Change the clock speed to suit your system
;
	DS	3		;(for  "JMP   START" instruction)

	DB	NO		;yes=PMMI S-100 Modem			103H
	DB	YES		;yes=HAYES Smartmodem, no=non-PMMI	104H
	DB	'T'		;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:	DB	60		;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED: DB	5		;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY: DB	5		;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:	DB	5		;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS: DB	5		;number of DIR columns shown		10AH
SETFLG: DB	YES		;yes=user-added Setup routine		10BH
SCRTST: DB	YES		;Cursor control routine			10CH
	DB	YES		;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKFLG: DB	YES		;yes=change any file same name to .BAK	10EH
CRCDFL: DB	NO		;yes=default to CRC checking		10FH
TOGCRC: DB	YES		;yes=allow toggling of CRC to Checksum	110H
CVTBS:	DB	NO		;yes=convert backspace to rub		111H
TOGLBK: DB	YES		;yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO		;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR	114H
	DB	YES		;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP: DB	YES		;yes=do not overwrite CCP		116H
	DB	NO		;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
	DB	YES		;yes=allow toggling of LOCONEXTCHR	118H
LSTTST: DB	YES		;yes=printer available on printer port	119H
XOFTST: DB	NO		;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF: DB	YES		;yes=allow toggling of XOFF checking	11CH
IGNCTL: DB	NO		;yes=CTL-chars above ^M not displayed	11DH
EXTRA1: DB	0		;for future expansion			11EH
EXITCHR DB	'E'-40H		;^E = Exit to main menu			11FH
BRKCHR: DB	'@'-40H		;^@ = Send 300 ms. break tone		120H
NOCONN: DB	'N'-40H		;^N = Disconnect from the phone line	121H
LOGCHR: DB	'L'-40H		;^L = Send logon			122H
LSTCHR: DB	'P'-40H		;^P = Toggle printer			123H
UNSAVE: DB	'R'-40H		;^R = Close input text buffer		124H
TRNCHR: DB	'T'-40H		;^T = Transmit file to remote		125H
SAVCHR: DB	'Y'-40H		;^Y = Open input text buffer		126H
EXTCHR: DB	'^'-40H		;^^ = Send next character		127H
	DS	2		;unused by MEX				128H
;
INCTL1: JMP	INSP		;go input status port			12AH
	DS	7
;
OTDATA: JMP	OUTDP		;go output data port			134H
	DS	7
;
INPORT: JMP	INDP		;go input data port			13EH
	DS	7
;
MASKR:	ANI	DAV	! RET	;bit to test for receive ready		148H
TESTR:	CPI	DAV	! RET	;value of rcv. bit when ready		14BH
MASKS:	ANI	TBMT	! RET	;bit to test for send ready		14EH
TESTS:	CPI	TBMT	! RET	;value of send bit when ready		151H
	DS	14		;					156H
;
;
	DS	3		;DIALV: not done here (maybe MXO-SM)	162H
DISCV:	JMP	DISCON		;disconnect
GOODBV: JMP	GOODBY		;					168H
INMODV: JMP	NITMOD		;go to user written routine		16BH
NEWDBV: JMP	PBAUD		;NEWBDV					16EH
	RET ! NOP ! NOP		;NOPARV					171H
	RET ! NOP ! NOP		;PARITV					174H
SETUPV: JMP	SETCMD		;					177H
	DS	3		;not used by MEX			17AH
VERSNV: JMP	SYSVER		;					17DH
BREAKV: JMP	SBREAK		;					180H
;
; Do not change the following six lines (they provide access to routines
; in MEX that are present to support MDM7 overlays -- they will likely
; be gone by MEX v2.0).
;
ILPRTV: DS	3		;					183H
INBUFV	DS	3		;					186H
ILCMPV: DS	3		;					189H
INMDMV: DS	3		;					18CH
	DS	3		;					18FH
TIMERV	DS	3		;					192H
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRTEST to YES at 010AH (above).
;
CLREOS: LXI	D,EOSMSG	;					195H
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
SYSVER: MVI	C,ILP		;in-line print
	CALL	MEX
	DB	'Interfacer/SS1 V.'
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	CR,LF,0
	RET
;
; Routine to exit just prior to exit-to-cpm
;
GOODBY: RET			;not done here
;
; Send break to remote
;
SBREAK: MVI	A,2FH		;send break for 300ms
	JMP	DISC1
;
; Disconnect the modem
;
DISCON: XRA	A		;turn off DTR
DISC1:	PUSH	PSW
	CALL	STPORT		;select port
	POP	PSW
	CALL	OUTCP		;send passed byte to CPORT
	MVI	B,3		;turn off DTR for 300 ms.
	MVI	C,TIMER
	CALL	MEX
	MVI	A,27H		;turn DTR back on
	CALL	OUTCP
	RET
;
; Initialize the port; either set an initial baud rate, or (if
; your system is capable of it) query the current rate and set
; MSPEED value.	 We can do neither here, so we assume a value
; for MSPEED -- if it's not the current value, the user must
; execute a SET command to bring MSPEED into agreement with the
; current baud rate.
;
NITMOD: MVI	A,5
	STA	MSPEED
	CALL	PBAUD
	RET
;
; SET command: select baud rate, port number. Port number may be any of
; 0,1,2,3,4,5,6,7,S  (S=SS1), baud rate any of 300, 600, 1200, 4800
; 9600, 19200.	Special set-port syntax allows baud rate after port
; number.  Examples:
;
;	SET PORT 3
;	SET PORT 5 1200
;	SET PORT S 300
;	SET BAUD 9600
;
SETCMD: MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	TELL		;if not, go display port/baud
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		;parse argument
	PUSH	H		;save any parsed argument adrs on stack
	RNC			;if we have one, return to it
	POP	H		;oops, input not found in table
SETERR: MVI	C,ILP		;inline print
	CALL	MEX
	DB	CR,LF,'SET command error',CR,LF,0
	RET
;
; Argument table
;
CMDTBL: DB	'?'+80H		;help
	DW	STHELP
	DB	'BAU','D'+80H	;"set baud"
	DW	STBAUD
	DB	'POR','T'+80H	;"set port"
	DW	SETPOR
	DB	0		;<<=== table terminator
;
; "SET ?" processor
;
STHELP: MVI	C,ILP		;inline print
	CALL	MEX
	DB	CR,LF,'SET BAUD <rate>'
	DB	CR,LF,'SET PORT <port-number>'
	DB	CR,LF
	DB	CR,LF,'Baud rate is one of:'
	DB	CR,LF,'   300 600 1200 4800 9600 19200'
	DB	CR,LF,'Port number is one of:'
	DB	CR,LF,'   0-7 : interfacer 3 or 4 port number'
	DB	CR,LF,'   S   : System Support I serial port'
	DB	CR,LF,0
	RET
;
; "SET BAUD" processor
;
STBAUD: MVI	C,BDPARS	;function code: parse a baudrate
	CALL	MEX		;let MEX look up code
	JC	SETERR		;jump if invalid code
	CALL	PBAUD		;no, try to set it
	JC	SETERR		;if not one of ours, bomb out
BDSHOW: MVI	C,ILP		;inline print
	CALL	MEX		;display baud
	DB	'Baud: ',0
	LDA	MSPEED		;get current baud rate
	MVI	C,PRBAUD	;let MEX print it
	CALL	MEX
	RET
;
; SET PORT processor
;
SETPOR: MVI	C,SBLANK	;scan to argument
	CALL	MEX
	JC	SETERR		;if no arg, bomb out
	MVI	C,GNC		;else consume it
	CALL	MEX
	CPI	'S'		;SS1?
	JZ	SETSS1		;jump if so
	CPI	's'
	JZ	SETSS1
	SUI	'0'		;convert
	JC	SETERR
	CPI	7+1
	JNC	SETERR
	JMP	SETX		;go put away port #
SETSS1: MVI	A,0FFH		;SS1 token
SETX:	STA	PORT
	MVI	C,SBLANK	;any thing more?
	CALL	MEX
	JNC	STBAUD		;if so, go parse as baud rate
;
TELL:	MVI	C,ILP
	CALL	MEX
	DB	CR,LF,'Port: ',0
	LDA	PORT
	CPI	0FFH		;SS1?
	JNZ	TELL1		;jump if not
	MVI	A,'S'-'0'	;set SS1, and avoid a JMP
TELL1:	ADI	'0'		;get port # in ASCII
	STA	PORTAS
	MVI	C,ILP
	CALL	MEX
PORTAS: DB	'    ',0
	JMP	BDSHOW
;
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
	MOV	A,M		;fetch code
	ORA	A		;0? (means unsupported code)
	STC			;prep carry in case unsupported
	JZ	PBEXIT		;exit if bad
	PUSH	PSW		;no, set the rate
	MVI	A,04EH		;first, set 8 bits, no parity, 1 stop
	CALL	OUTMP
	POP	PSW		;get baud code back
	CALL	OUTMP
	MVI	A,27H		;turn on DTR, etc
	CALL	OUTCP
	MOV	A,E		;get MSPEED code back
	STA	MSPEED		;set it
	ORA	A		;return no-errors
PBEXIT: POP	B
	POP	D
	POP	H
	RET
;
BAUDTB: DB	0		;110 (not supported)
	DB	BD300		;300
	DB	0		;450 (not supported)
	DB	BD600		;600
	DB	0		;710 (not supported)
	DB	BD1200		;1200
	DB	0		;2400 (not supported)
	DB	BD4800		;4800
	DB	BD9600		;9600
	DB	BD19200		;19200
;
;	Port access routines
;
; Input
;
INSP:	MVI	A,SPORT		;in status-port
	JMP	INP1
INDP:	MVI	A,DPORT		;in data-port
INP1:	PUSH	B		;can't alter BC
	MOV	C,A		;2661-relative port number in C
	CALL	STPORT		;set port #
	ADD	C		;A=absolute port #
	POP	B		;restore BC
	STA	INP2+1		;put port # in the code
INP2:	IN	0		;do the input
	RET
;
; Output
;
OUTDP:	PUSH	B		;out data-port
	MVI	C,DPORT
	JMP	OUT1
OUTMP:	PUSH	B		;out mport
	MVI	C,MPORT
	JMP	OUT1
OUTCP:	PUSH	B		;out control port
	MVI	C,CPORT
OUT1:	MOV	B,A		;B=char to send
	CALL	STPORT		;set port #
	ADD	C		;A=absolute port #
	STA	OUT2+1		;put port # in the code
	MOV	A,B		;A=char to send
OUT2:	OUT	0		;send it
	POP	B
	RET
;
; Set port #, return base adrs
;
STPORT: LDA	PORT		;get current port #
	CPI	0FFH		;255 implies SS1
	JNZ	STIN		;jump if not SS1
	MVI	A,SSBASE	;it's SS1, return base adrs
	RET
STIN:	OUT	UPORT		;set IN 3/4 user #
	MVI	A,INBASE	;return base port
	RET
;
;
PORT:	DB	6		;initial port #=ss1
;
; Clear-to-end-of-screen and clear-screen sequences
;
EOSMSG: DB	ESC,'T','$'
CLSMSG: DB	26,'$'
;
;
	END
