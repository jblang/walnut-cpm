
	TITLE	'CompuPro overlay for Interfacer 3/4'
;
;  MXO-GB10.ASM -- MEX overlay file for the CompuPro I3/I4 & SS1.  05/12/84
;
;  This overlay adapts the mex modem program to the CompuPro Interfacer 3 or
;  Interfacer 4 or System Support 1 serial cards using the 2651 usart chip.
;
;
;  This overlay is capable of setting baud rate and setting port number
;  (via the SET command), setting baud rate from the phone library, dis-
;  connecting the  modem, and sending a break.
;
REV	EQU	12	; version 1.2
;
;  Note to Interfacer 4 users:
;  The 'middle' serial port and the Centronics port can have their addresses
;  changed using a hardware option.  Godbout did this to maintain software
;  compatibility with their BIOS.  In order to prevent problems, use the
;  'right' serial port (relative user 5) instead of the center serial
;  port (relative user 6).  Also, read page 19 of the manual, the modem
;  port will probably have to be set up in the 'master mode'.  While
;  you're reading the manual, read the section on 'wait state logic'.
;  I'm using a CPU-Z running at 6mhz, with a 300 baud modem and two wait
;  states (jumper at j7).  Without them, I get 'o's for 'n's and 'g's
;  for 'f's, and the checksums are never right.  (aww 12/20/83)
;
;  Calling conventions for the various overlay entry points are detailed more
;  fully in the PMMI overlay (MXO-PMxx.ASM, where xx=revision number)
;
;  History as a MEX overlay:
;
;  12/04/87 - Added routines to change number of
;	      stop bits, data bits, and partiy. - Dave Chapman
;  27/03/87 - Added GOODBY routine to drop DTR
;	      when exiting to CP/M.		- Dave Chapman
;  27/12/86 - Changed a bit for SS1, added
;	      110 and 2400 baud and instruction
;	      equates, changed set error.	- Dave Chapman
;  05/12/84 - set port (0-7, S -- S=SS1)	- Ron Fowler
;  05/11/84 - MEXified the overlay		- Ron Fowler
;
;  History as an MDM7 overlay:
;
;  11/20/83 - Interfacer 4 note added		- A.W. Warren
;  11/11/83 - Renamed to M7IN-1.ASM, no changes - Irv Hoff
;  07/27/83 - Renamed to work with MDM712	- Irv Hoff
;  07/11/83 - Modifed somewhat for MDM711	- Irv Hoff
;  07/08/83 - Adapted from MDM711GP.ASM 	- Paul Traina
;
;
;  MEX service processor stuff:
;
MEX	EQU	0D00H		; Address of the service processor
INMDM	EQU	255		; Get char from port to A, CY=no more in 100 MS
TIMER	EQU	254		; Delay 100MS * reg B
TMDINP	EQU	253		; B=# secs to wait for char, CY=no char
CHEKCC	EQU	252		; Check for ^C from kbd, Z=present
SNDRDY	EQU	251		; Test for modem-send ready
RCVRDY	EQU	250		; Test for modem-receive ready
SNDCHR	EQU	249		; Send a character to the modem (after SNDRDY)
RCVCHR	EQU	248		; Recv a char from modem (after RCVRDY)
LOOKUP	EQU	247		; Table search: see CMDTBL comments for info
PARSFN	EQU	246		; Parse filename from input stream
BDPARS	EQU	245		; Parse baud-rate from input stream
SBLANK	EQU	244		; Scan input stream to next non-blank
EVALA	EQU	243		; Evaluate numeric from input stream
LKAHED	EQU	242		; Get nxt char w/o removing from input
GNC	EQU	241		; Get char from input, CY=1 if none
ILP	EQU	240		; Inline print
DECOUT	EQU	239		; Decimal output
PRBAUD	EQU	238		; Print baud rate
;
CONOUT	EQU	2		; Simulated BDOS function 2: console char out
PRINT	EQU	9		; Simulated BDOS function 9: print string
INBUF	EQU	10		; Input buffer, same structure as BDOS 10
;
BELL	EQU	7		; Bell
TAB	EQU	9
CR	EQU	13		; Carriage return
LF	EQU	10		; Linefeed
ESC	EQU	1BH		; Escape
YES	EQU	0FFH
NO	EQU	0
;
; Interfacer 3/4 and SS1 port equates:
;
INBASE	EQU	010H		; Base port of CompuPro I3 or I4 card(s)
SSBASE	EQU	05CH		; Base of serial section of CompuPro SS1
;
UPORT	EQU	INBASE+7	; User (chip select) port
;
; Port offsets:
;
DPORT:	EQU	0		; Data port
SPORT:	EQU	1		; Status port
MPORT:	EQU	2		; Mode port
CPORT:	EQU	3		; Control port
;
TBMT:	EQU	01H		; Transmit buffer empty
DAV:	EQU	02H		; Data available
;
BIT5	EQU	02H		; 5 bits
BIT6	EQU	06H		; 6 bits
BIT7	EQU	0AH		; 7 bits
BIT8	EQU	0EH		; 8 bits
BITMSK	EQU	0EH		; Mask to get character length
PARE	EQU	30H		; Even parity
PARO	EQU	10H		; Odd parity
PARN1	EQU	00H		; No parity
PARN2	EQU	20H		; Another code for no parity
PARMSK	EQU	30H		; Mask to get parity bits
STP1	EQU	40H		; 1 stop bit
STP15	EQU	80H		; 1.5 stop bits
STP2	EQU	0C0H		; 2 stop bits
STPMSK	EQU	0C0H		; Mask to get stop bits
;
;
; Command register instruction:
;
MCMD	EQU	27H		; TxEn, DTR, RxEn, RTS
;
; Break command instruction:
;
BKCMD	EQU	2FH		; Send break
;
;  Baud rate parameters:
;
BD110:	EQU	32H		; 110 baud
BD300:	EQU	35H		; 300 baud
BD450:	EQU	00H		; 450 baud (not supported here)
BD600:	EQU	36H		; 600 baud
BD710:	EQU	00H		; 710 baud (not supported here)
BD1200:	EQU	37H		; 1200 baud
BD2400:	EQU	3AH		; 2400 baud
BD4800:	EQU	3CH		; 4800 baud
BD9600:	EQU	3EH		; 9600 baud
BD19200	EQU	3FH		; 19200 baud
;
	ORG	100H
;
; Change the clock speed to suit your system:
;
	DS	3		; (for	"JMP   START" instruction)

	DB	NO		; Yes=PMMI S-100 modem			103h
	DB	YES		; Yes=Hayes Smartmodem, no=non-PMMI	104h
	DB	'P'		; T=touch, p=pulse (Smartmodem-only)	105h
CLOCK:	DB	60		; Clock speed in mhz x10, 25.5 mhz max. 106h
				; 20=2 mhz, 37=3.68 mhz, 40=4 mhz, etc.
MSPEED:	DB	5		; 0=110 1=300 2=450 3=600 4=710 5=1200	107h
				;   6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	5		; 0=0 delay  1=10ms  5=50 ms - 9=90 ms	108h
				;   default time to send character in ter-
				;   minal mode file transfer for slow bbs.
CRDLY:	DB	5		; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109h
				;   default time for extra wait after crlf
				;   in terminal mode file transfer
COLUMS:	DB	5		; Number of dir columns shown		10ah
SETFLG:	DB	YES		; Yes=user-added setup routine		10bh
SCRTST:	DB	YES		; Cursor control routine		10ch
	DB	YES		; Yes=resend a record after any non-ack 10dh
				;   no=resend a record after a valid-nak
BAKFLG:	DB	NO		; Yes=change any file same name to .bak 10eh
CRCDFL:	DB	YES		; Yes=default to crc checking		10fh
TOGCRC:	DB	YES		; Yes=allow toggling of crc to checksum 110h
CVTBS:	DB	NO		; Yes=convert backspace to rub		111h
TOGLBK:	DB	YES		; Yes=allow toggling of bksp to rub	112h
ADDLF:	DB	NO		; No=no lf after cr to send file in	113h
				;   terminal mode (added by remote echo)
TOGLF:	DB	YES		; Yes=allow toggling of lf after cr	114h
	DB	YES		; Yes=allow transmission of logon	115h
				;   write logon sequence at location logon
SAVCCP:	DB	YES		; Yes=do not overwrite ccp		116h
	DB	NO		; Yes=local command if extchr precedes	117h
				;   no=external command if extchr precedes
	DB	YES		; Yes=allow toggling of loconextchr	118h
LSTTST:	DB	YES		; Yes=printer available on printer port 119h
XOFTST:	DB	YES		; Yes=checks for xoff from remote while 11ah
				;   sending a file in terminal mode
XONWT:	DB	NO		; Yes=wait for xon after cr while	11bh
				;   sending a file in terminal mode
TOGXOF:	DB	YES		; Yes=allow toggling of xoff checking	11ch
IGNCTL:	DB	YES		; Yes=ctl-chars above ^m not displayed	11dh
EXTRA1:	DB	0		; For future expansion			11eh
EXITCHR	DB	'E'-40H		; ^E = exit to main menu		11fh
BRKCHR:	DB	'@'-40H		; ^@ = send 300 ms. break tone		120h
NOCONN:	DB	'N'-40H		; ^N = disconnect from the phone line	121h
LOGCHR:	DB	'L'-40H		; ^L = send logon			122h
LSTCHR:	DB	'P'-40H		; ^P = toggle printer			123h
UNSAVE:	DB	'R'-40H		; ^R = close input text buffer		124h
TRNCHR:	DB	'T'-40H		; ^T = transmit file to remote		125h
SAVCHR:	DB	'Y'-40H		; ^Y = open input text buffer		126h
EXTCHR:	DB	'^'-40H		; ^^ = send next character		127h
	DS	2		; Unused by MEX 			128h
;
INCTL1:	JMP	INSP		; Go input status port			12ah
	DS	7
;
OTDATA:	JMP	OUTDP		; Go output data port			134h
	DS	7
;
INPORT:	JMP	INDP		; Go input data port			13eh
	DS	7
;
MASKR:	ANI	DAV	! RET	; Bit to test for receive ready 	148h
TESTR:	CPI	DAV	! RET	; Value of rcv. bit when ready		14bh
MASKS:	ANI	TBMT	! RET	; Bit to test for send ready		14eh
TESTS:	CPI	TBMT	! RET	; Value of send bit when ready		151h
	DS	14		;					156h
;
;
	DS	3		; DIALV: not done here (maybe MXO-SM)	162h
DISCV:	JMP	DISCON		; Disconnect
GOODBV:	JMP	GOODBY		;					168h
INMODV:	JMP	NITMOD		; Go to user written routine		16bh
	RET ! NOP ! NOP		; Newbdv					16eh
	RET ! NOP ! NOP		; Noparv					171h
	RET ! NOP ! NOP		; Paritv					174h
SETUPV:	JMP	SETCMD		;					177h
	DS	3		; Not used by MEX			17ah
VERSNV:	JMP	SYSVER		;					17dh
BREAKV:	JMP	SBREAK		;					180h
;
;  Do not change the following six lines (they provide access to routines
;  in MEX that are present to support MDM7 overlays -- they will likely
;  be gone by mex v2.0).
;
ILPRTV:	DS	3		;					183h
INBUFV	DS	3		;					186h
ILCMPV:	DS	3		;					189h
INMDMV:	DS	3		;					18ch
	DS	3		;					18fh
TIMERV	DS	3		;					192h
;
;  Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
;  SCRTEST to YES at 010AH (above).
;
CLREOS:	LXI	D,EOSMSG	;					195h
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLS:	LXI	D,CLSMSG	;					19eh
	MVI	C,PRINT
	CALL	MEX
	RET
;									1a7h
;
;			End of fixed area.
;
;------------------------------------------------------------------------------
;
SYSVER:	MVI	C,ILP		; In-line print
	CALL	MEX
	DB	CR,LF
	DB	'Version '
	DB	REV/10+'0'
	DB	'.'
	DB	REV MOD	10+'0'
	DB	' for CompuPro'
	DB	CR,LF
	DB	'Interfacer 3/4 and System Support 1.'
	DB	CR,LF
	DB	0
	CALL	SHOALL		; Show initial values for everything
	RET
;
; Routine to exit just prior to exit-to-CP/M:
;
GOODBY:	XRA	A		; Turn off DTR
	PUSH	PSW
	CALL	STPORT		; Select port
	POP	PSW
	CALL	OUTCP		; Send passed byte to cport
	RET			; Exit to cp/m
;
;  Send break to remote:
;
SBREAK:	MVI	A,BKCMD		; Send break for 300ms
	JMP	DISC1
;
;  Disconnect the modem:
;
DISCON:	XRA	A		; Turn off DTR
DISC1:	PUSH	PSW
	CALL	STPORT		; Select port
	POP	PSW
	CALL	OUTCP		; Send passed byte to cport
	MVI	B,3		; Turn off DTR for 300 ms.
	MVI	C,TIMER
	CALL	MEX
	MVI	A,MCMD		; Turn DTR back on
	CALL	OUTCP
	RET
;
;  Initialize the port;  either set an initial baud rate, or (if
;  your system is capable of it) query the current rate and set
;  mspeed value.  We can do neither here, so we assume a value
;  for mspeed -- if it's not the current value, the user must
;  execute a set command to bring mspeed into agreement with the
;  current baud rate.
;
NITMOD:	LDA	MSPEED
	JMP	PBAUD		; Added here to init uart when mex
				;   initially loaded. - dlc
				; Return from pbaud
;
;  Set command: select baud rate, port number. port number may be any of
;  0,1,2,3,4,5,6,7,s  (s=ss1), baud rate any of 300, 600, 1200, 4800
;  9600, 19200.  Special set-port syntax allows baud rate after port
;  number.  Examples:
;
;	set port 3		set par o    - odd parity
;	set port 5 1200 	set stop 1.5 - 1.5 stop bits
;	set port s 300		set data 7   - 7 data bits
;	set baud 9600
;
SETCMD:	MVI	C,SBLANK	; Any arguments?
	CALL	MEX
	JC	SHOALL		; If not, go display port/baud etc.
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		; Parse argument
	PUSH	H		; Save any parsed argument adrs on stack
	RNC			; If we have one, return to it
	POP	H		; Oops, input not found in table
SETERR:	CALL	ILPRT
	DB	BELL
	DB	CR,LF,'SET command error!',CR,LF,0
	CALL	STHELP
	RET
;
;  Argument table:
;
CMDTBL:	DB	'?'+80H		; Help
	DW	STHELP
	DB	'BAU','D'+80H	; "set baud"
	DW	STBAUD
	DB	'POR','T'+80H	; "set port"
	DW	SETPOR
	DB	'DAT','A'+80H	; "set bits"
	DW	STDATA
	DB	'PA','R'+80H	; "set par"
	DW	STPAR
	DB	'STO','P'+80H	; "set stop"
	DW	STSTOP
	DB	0		; <<=== table terminator
;.....
;
;
; Set ? processor:
;
STHELP:	CALL	CLS
	CALL	ILPRT
	DB	LF
	DB	'The SET command is invoked as follows:'
	DB	LF
	DB	CR,LF,'     SET BAUD <baud rate>               SET PORT <port-number>'
	DB	CR,LF,'     SET DATA <no. of data bits>        SET PARity <parity>'
	DB	CR,LF,'     SET STOP bits <no. of stop bits>'
	DB	CR,LF
	DB	CR,LF,'     BAUD rate is one of:'
	DB	CR,LF,'        110 300 600 1200 2400 4800 9600 19200'
	DB	CR,LF
	DB	CR,LF,'     PORT number is one of:'
	DB	CR,LF,'        0-7 : Interfacer 3 or 4 port number.'
	DB	CR,LF,'        S   : System Support 1 serial port.'
	DB	CR,LF
	DB	CR,LF,'     DATA bits is one of:   STOP bits is one of:'
	DB	CR,LF,'        5, 6, 7, or 8          1, 1.5, or 2.'
	DB	CR,LF
	DB	CR,LF,'     PARity is one of:'
	DB	CR,LF,'        E)ven, O)dd, or N)one.'
	DB	CR,LF,LF,LF,0
	RET
;.....
;
;
; Set port processor:
;
SETPOR:	MVI	C,SBLANK	; Scan to argument
	CALL	MEX
	JC	SETERR		; If no arg, bomb out
	MVI	C,GNC		; Else consume it
	CALL	MEX
	CPI	'S'		; SS1?
	JZ	SETSS1		; Jump if so
	CPI	's'
	JZ	SETSS1
	SUI	'0'		; Convert
	JC	SETERR
	CPI	7+1
	JNC	SETERR
	JMP	SETX		; Go put away port #
SETSS1:	MVI	A,0FFH		; SS1 token
SETX:	STA	PORT
TELL:	CALL	ILPRT
	DB	'Port is now: ',0
	LDA	PORT
	CPI	0FFH		; SS1?
	JNZ	TELL1		; Jump if not
	MVI	A,'S'-'0'	; Set SS1, and avoid a jmp
TELL1:	ADI	'0'		; Get port # in ascii
	STA	PORTAS
	CALL	ILPRT
PORTAS:	DB	'    ',CR,LF,0
	RET
;.....
;
;
; Set baud processor:
;
STBAUD:	MVI	C,BDPARS	; Function code: parse a baudrate
	CALL	MEX		; Let MEX look up code
	JC	SETERR		; Jump if invalid code
	CALL	PBAUD		; No, try to set it
	JC	SETERR		; If not one of ours, bomb out
BDSHOW:	CALL	ILPRT		; Display baud
	DB	'Baud rate now: ',0
	LDA	MSPEED		; Get current baud rate
	MVI	C,PRBAUD	; Let MEX print it
	CALL	MEX
	CALL	CRLF
	RET
;
;  This routine sets baud rate passed as MSPEED code in A.
;  returns CY=1 if baud rate not supported (if supported,
;  this routine must set the new MSPEED code).
;
PBAUD:	PUSH	H		; Don't alter anybody
	PUSH	D
	PUSH	B
	MOV	E,A		; MSPEED code to DE
	MVI	D,0
	LXI	H,BAUDTB	; Offset into table
	DAD	D
	MOV	A,M		; Fetch code
	ORA	A		; 0? (means unsupported code)
	STC			; Prep carry in case unsupported
	JZ	PBEXIT		; Exit if bad
	PUSH	PSW		; No, set the rate
	LDA	MODCTB		; Mode register 1
	CALL	OUTMP
	POP	PSW		; Get baud code back
	CALL	OUTMP
	MVI	A,MCMD		; Command insruction
	CALL	OUTCP
	MOV	A,E		; Get mspeed code back
	STA	MSPEED		; Set it
	ORA	A		; Return no-errors
PBEXIT:	POP	B
	POP	D
	POP	H
	RET
;
BAUDTB:	DB	BD110		; 110
	DB	BD300		; 300
	DB	0		; 450 (not supported)
	DB	BD600		; 600
	DB	0		; 710 (not supported)
	DB	BD1200		; 1200
	DB	BD2400		; 2400
	DB	BD4800		; 4800
	DB	BD9600		; 9600
	DB	BD19200		; 19200
;......
;
;
; Set data character length:
;
STDATA:	LXI	D,BITTBL	; Point to table
	CALL	TSRCH		;   and search for command
	JC	SETERR
	LDA	MODCTB		; Get the last 2651 mode byte
	ANI	0FFH AND NOT BITMSK	; Zero the character length
	ORA	L			;   and put in the new value
	CALL	PMODE		; Re-init the 2651
BTSHOW:	LDA	MODCTB		; 2651 mode register image
	ANI	BITMSK		; Keep only the character length
	RAR
	RAR			; Shift bits down to bit 0
	ADI	'5'		; 0 is 5 bits, 1 is 6...
	CALL	TYPE
	CALL	ILPRT
	DB	' Data bits. ',CR,LF,0
	RET
;
; Data bits table:
;
BITTBL:	DB	'8'+80H
	DW	BIT8
	DB	'7'+80H
	DW	BIT7
	DB	'6'+80H
	DW	BIT6
	DB	'5'+80H
	DW	BIT5
	DB	0		; <== table terminator
;.....
;
;
; Set the parity:
;
STPAR:	LXI	D,PARTBL	; Point to the table of commands
	CALL	TSRCH		;   and search it
	JC	SETERR
	LDA	MODCTB
	ANI	0FFH AND NOT PARMSK	; Zero the parity bits
	ORA	L			;   and put in the new parity
	CALL	PMODE		; Set everythng up again
BYSHOW:	LDA	MODCTB
	ANI	PARMSK		; Get the parity bits
	LXI	D,EVNMSG
	MVI	C,PRINT
	CPI	PARE
	CZ	MEX		; For even parity
	LXI	D,ODDMSG
	CPI	PARO
	CZ	MEX		; For odd parity
	LXI	D,NOMSG
	CPI	PARN1
	CZ	MEX		; For no parity-first code
	CPI	PARN2
	CZ	MEX		; For no parity-second code
	CALL	ILPRT
	DB	' Parity. ',CR,LF,0
	RET
;
; Table for parity:
;
PARTBL:	DB	'E'+80H
	DW	PARE
	DB	'O'+80H
	DW	PARO
	DB	'N'+80H
	DW	PARN1
	DB	0		; <== table terminator
;
EVNMSG:	DB	'EVEN$'
ODDMSG:	DB	'ODD$'
NOMSG:	DB	'NO$'
;.....
;
;
; Set the stop bits:
;
STSTOP:	LXI	D,STPTBL	; Point to the command table
	CALL	TSRCH		;   and search it
	JC	SETERR
	LDA	MODCTB
	ANI	0FFH AND NOT STPMSK	; Zero the stop bits
	ORA	L			;   and put in the new ones
	CALL	PMODE		; And set it all up again
BSSHOW:	LDA	MODCTB
	ANI	STPMSK		; Get the stop bits
	PUSH	PSW
	LXI	D,S1MSG
	MVI	C,PRINT
	CPI	STP1
	CZ	MEX		; For 1 stop bit
	LXI	D,S15MSG
	CPI	STP15
	CZ	MEX		; For 1.5 stop bits
	LXI	D,S2MSG
	CPI	STP2
	CZ	MEX		; For 2 stop bits
	CALL	ILPRT
	DB	' Stop bit',0
	POP	PSW
	CPI	STP1
	MVI	A,'s'
	CNZ	TYPE
	MVI	A,'.'
	CALL	TYPE		; If 1 don't put out 's'
	CALL	CRLF
	RET
;
; Table for stop:
;
STPTBL:	DB	'1'+80H
	DW	STP1
	DB	'1.','5'+80H
	DW	STP15
	DB	'2'+80H
	DW	STP2
	DB	0		; <== table terminator
;
S1MSG:	DB	'1$'
S2MSG:	DB	'2$'
S15MSG:	DB	'1.5$'
;
;------------------------------------------------------------------------------
;
; Port access routines:
;
;  Input:
;
INSP:	MVI	A,SPORT		; In status-port
	JMP	INP1
INDP:	MVI	A,DPORT		; In data-port
INP1:	PUSH	B		; Can't alter BC
	MOV	C,A		; 2661-relative port number in C
	CALL	STPORT		; Set port #
	ADD	C		; A=absolute port #
	POP	B		; Restore BC
	STA	INP2+1		; Put port # in the code
INP2:	IN	0		; Do the input
	RET
;.....
;
;
;  Output:
;
OUTDP:	PUSH	B		; Out data-port
	MVI	C,DPORT
	JMP	OUT1
OUTMP:	PUSH	B		; Out mport
	MVI	C,MPORT
	JMP	OUT1
OUTCP:	PUSH	B		; Out control port
	MVI	C,CPORT
OUT1:	MOV	B,A		; B=char to send
	CALL	STPORT		; Set port #
	ADD	C		; A=absolute port #
	STA	OUT2+1		; Put port # in the code
	MOV	A,B		; A=char to send
OUT2:	OUT	0		; Send it
	POP	B
	RET
;.....
;
;
; Send mode byte:
;
PMODE:	STA	MODCTB		; Store it for later use
	JMP	NITMOD		; Returns from pbaud
;.....
;
;
;  Set port #, return base adrs:
;
STPORT:	LDA	PORT		; Get current port #
	CPI	0FFH		; 255 implies SS1
	JNZ	STIN		; Jump if not SS1
	MVI	A,SSBASE	; It's SS1, return base adrs
	RET
STIN:	OUT	UPORT		; Set in 3/4 user #
	MVI	A,INBASE	; Return base port
	RET
;
PORT:	DB	255		; Initial port #=SS1
;
MODCTB:	DB	BIT8 OR	PARN1 OR STP1	; Modem control byte
;					   default  8,N,1
;
;------------------------------------------------------------------------------
;
; Misc. subroutines:
;
; Show all values:
;
SHOALL:	CALL	CRLF
	CALL	BDSHOW		; Show baud
	CALL	TELL		;  and port
	CALL	BTSHOW		;  and no. of data bits
	CALL	BSSHOW		;  and no. of stop bits
	CALL	BYSHOW		;  and parity
	CALL	CRLF
;
TSRCH:	MVI	C,LOOKUP	; Lookup
	JMP	MEX		; Return from MEX lookup routine
;
ILPRT:	MVI	C,ILP		; Inline print
	JMP	MEX		; Return from MEX ilp routine
;
CRLF:	CALL	ILPRT
	DB	CR,LF,0
;
; Send a char in A to the console:
;
TYPE:	PUSH	H
	PUSH	D
	PUSH	B
	MOV	E,A
	MVI	C,CONOUT
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
;
; Clear-to-end-of-screen and clear-screen sequences:
;
EOSMSG:	DB	ESC,'Y','$'
CLSMSG:	DB	ESC,'*','$'
;
;
; The following two create assembly-time error messages if the overlay
; is too big:
;
IF ($ GE 0B00H)
	WARNING!! OVERLAY EXTENDS BEYOND 0B00H!!
;
IF ($ GE 0D00H)
	ERROR!!	OVERLAY	EXTENDS	BEYOND 0D00H!!
;
	END


