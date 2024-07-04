;	MEX OVERLAY FOR INTERCONTINENTAL MICROSYSTEMS CPZ-4800X
;
REV	EQU	10
;
; MXO-CZ10.ASM -- MEX Overlay for CPZ-48000	01/04/86
;
; This overlay will set baud rate from set command and from the phone
; library, disconnect the modem, and send break.  The overlay assumes
; the terminal is on channel 1 and the modem is on channel 0.
;
; Calling conventions for the various overlay entry points are detailed more
; fully in the PMMI overlay (MXO-PMxx.ASM, where xx=revision number)
;
; 01/04/86	INITIALLY WRITTEN [ESKAY]  (template used was MXO-SS10)
;
; MEX service processor functions:
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
;
; DEFINE WHICH PORT TO USE FOR MEX - DEFINE ONLY ONE!!!!
PORT0	EQU	YES
PORT1	EQU	NO
;
; port equates
;
CMNDA	EQU	81H		; COMMAND PORT CHANNEL 0
CMNDB	EQU	83H		; COMMAND PORT CHANNEL 1
;
	IF	PORT0
SPORT	EQU	CMNDA		; STATUS PORT
DPORT	EQU	CMNDA-1		; DATA PORT
	ENDIF
	IF	PORT1
SPORT	EQU	CMNDB		; STATUS PORT
DPORT	EQU	CMNDB-1		; DATA PORT
	ENDIF
;
RDA	EQU	1		; RECEIVE DATA AVAILABLE
TBE	EQU	4		; TRANSMIT BUFFER EMPTY
;
; Baud rate parameters
;
TCH0	EQU	0B0H		; TIMER CHANNEL 0
TCH1	EQU	0B1H		; TIMER CHANNEL 1
TCMND	EQU	0B3H		; TIMER COMMAND PORT
CHAMD	EQU	36H		; CHANNEL 0 MODE
CHBMD	EQU	76H		; CHANNEL 1 MODE
;
	IF	PORT0
CHMD	EQU	CHAMD
TCHN	EQU	TCH0
	ENDIF
	IF	PORT1
CHMD	EQU	CHBMD
TCHN	EQU	TCH1
	ENDIF
;
CLK	EQU	24576/16	; CRYSTAL FREQUENCY DIV 16
B38400	EQU	CLK/384		; 38K BAUD
B19200	EQU	CLK/192		; 19K BAUD
B9600	EQU	CLK/96		; 9600 BAUD
B4800	EQU	CLK/48		; 4800 BAUD
B2400	EQU	CLK/24		; 2400 BAUD
B1200	EQU	CLK/12		; 1200 BAUD
B600	EQU	CLK/6		; 600 BAUD
B300	EQU	CLK/3		; 300 BAUD
;
	ORG	100H
;
; Change the clock speed to suit your system
;
	DS	3		;(for  "JMP   START" instruction)

	DB	NO		;yes=PMMI S-100 Modem			103H
	DB	NO		;yes=HAYES Smartmodem, no=non-PMMI	104H
	DB	'T'		;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:	DB	60		;clock speed in MHz x10, 25.5 MHz max.	106H
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
SCRTST:	DB	NO		;Cursor control routine 		10CH
	DB	YES		;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKFLG:	DB	YES		;yes=change any file same name to .BAK	10EH
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
INCTL1:	IN	SPORT
	RET
	DS	7
;
OTDATA:	OUT	DPORT
	RET
	DS	7
;
INPORT:	IN	DPORT		;input data port			13EH
	RET
	DS	7
;
MASKR:	ANI	RDA	! RET	;bit to test for receive ready		148H
TESTR:	CPI	RDA	! RET	;value of rcv. bit when ready		14BH
MASKS:	ANI	TBE	! RET	;bit to test for send ready		14EH
TESTS:	CPI	TBE	! RET	;value of send bit when ready		151H
	DS	14		;					156H
;
;
	DS	3		;DIALV: not done here (maybe MXO-SM)	162H
DISCV:	JMP	DISCON		;disconnect
GOODBV:	JMP	GOODBY		;					168H
INMODV:	JMP	NITMOD		;go to user written routine		16BH
	JMP	PBAUD		;NEWBDV					16EH
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
	DB	'ICM CPZ-4800x [ESKAY]  V'
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD 10+'0'
	DB	CR,LF,0
	RET
;
; Routine to exit just prior to exit-to-cpm
;
GOODBY:	RET			;not done here
;
; Send break to remote
;
SBREAK:	RET			; NOT IMPLEMENTED
;
; INITIALIZE PORT
;
NITMOD:	LXI	H,NITTB0
	MVI	B,7		; 7 BYTES
	CALL	SETMOD
	LDA	MSPEED
	JMP	PBAUD
;
; Disconnect the modem
;
DISCON:	LXI	H,DTROFF
	MVI	B,2
	CALL	SETMOD
	MVI	B,3		;turn off DTR for 300 ms.
	MVI	C,TIMER
	CALL	MEX
	LXI	H,DTRON
	MVI	B,2
;
SETMOD:	MVI	C,SPORT
	DB	0EDH,0B3H	; OTIR
	RET
;
DTROFF:	DB	05H,06AH
DTRON:	DB	05H,0EAH
NITTB0:	DB	18H,04H,4CH,03H,0C1H,05H,0EAH
;
SETCMD:	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	BDSHOW		;if not, go display baud
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
	DB	0		;<<=== table terminator
;
; "SET ?" processor
;
STHELP:	MVI	C,ILP		;inline print
	CALL	MEX
	DB	CR,LF,'SET BAUD <rate>'
	DB	CR,LF
	DB	CR,LF,'Baud rate is one of:'
	DB	CR,LF,'   300 600 1200 2400 4800 9600 19200 38400'
	DB	CR,LF,0
	RET
;
; "SET BAUD" processor
;
STBAUD:	MVI	C,BDPARS	;function code: parse a baudrate
	CALL	MEX		;let MEX look up code
	JC	SETERR		;jump if invalid code
	CALL	PBAUD		;no, try to set it
	JC	SETERR		;if not one of ours, bomb out
BDSHOW:	MVI	C,ILP		;inline print
	CALL	MEX		;display baud
	DB	'Baud: ',0
	LDA	MSPEED		;get current baud rate
	MVI	C,PRBAUD	;let MEX print it
	JMP	MEX
;
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
	DAD	D
	MOV	A,M		;fetch code
	INX	H
	MOV	H,M
	MOV	L,A
	ORA	H		;0? (means unsupported code)
	STC			;prep carry in case unsupported
	JZ	PBEXIT		;exit if bad
	IF	PORT0
	MVI	A,CHMD
	OUT	TCMND
	MOV	A,L
	OUT	TCHN
	MOV	A,H
	OUT	TCHN
	MOV	A,E
	STA	MSPEED		;set it
	ORA	A		;return no-errors
PBEXIT:	POP	B
	POP	D
	POP	H
	RET
;
BAUDTB:	DW	0		;110 (not supported)
	DW	B300		;300
	DW	0		;450 (not supported)
	DW	B600		;600
	DW	0		;710 (not supported)
	DW	B1200		;1200
	DW	B2400		;2400
	DW	B4800		;4800
	DW	B9600		;9600
	DW	B19200		;19200
	DW	B38400		;38400
;
;
; Clear-to-end-of-screen and clear-screen sequences
;
EOSMSG:	DB	ESC,'Y','$'
CLSMSG:	DB	26,'$'
;
;
	END
int it
	JMP	MEX
;
;
; This routine sets baud rate passed as MSPEED code in A.
; Returns CY=1 if baud rate no