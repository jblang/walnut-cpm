
; I2TD-1.ASM  -  TurboDos 1.4x overlay file for IMP -  06/01/87
;
;		    Uses the 8116 Baudrate generator
;
; This overlay file adapts TurboDos 1.4x to IMP244 and an external modem.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  The value
; at MSPEED controls the baudrate when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to merge into the main file:
;
;		MLOAD IMP.COM=IMP.COM,I2TD-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Added 19200 bps, added BREAK routine, needs IMP245 to use
;    v2     it. (It uses the 19200 bps.)	- Irv Hoff
;
; 05/20/87  Initial version			- Greg Davis, Sysop
;    v1 					  Lewisville, TX RCP/M
;						  (214) 221-1956
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
; TurboDos /// equates
;
TDOS	EQU	050H	; T-function entry
CHNL	EQU	0	; Modem channel ( 0 or 1 )
;		^-------; Change this to your channel number
;
;-----------------------------------------------------------------------
;
ESC	EQU	1BH	; Escape
BELL	EQU	'G'-40H	; ^G = Bell character
LF	EQU	'J'-40H	; ^J = Linefeed
NEXTRY	EQU	'K'-40H	; ^K = Try next phone number, abort this try
CR	EQU	'M'-40H	; ^M = Carriage return
CLEARSC	EQU	'Z'-40H	; ^Z = Clear screen, command mode only
EOFCHAR	EQU	'Z'-40H	; ^Z = End of file
;
MDRCV	EQU	1	; Bit to test for receive
MDSND	EQU	0	; Bit to test for send
MDTXE	EQU	0	; Modem send buffer empty
;
;-----------------------------------------------------------------------
;
;
	ORG	0100H
;
	DS	3	; Skip the data area below
;
; These routines and equates are at the beginning of the program so
; they can be patched by a monitor or overlay file without re-assembling
; the program.
;
MSPEED:	 DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	 DB	NO	; Yes=2400 bps highest speed			104H
HS1200:	 DB	YES	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
CLEAR:	 DB	1AH	; Clear screen character (ESC not needed)	10AH
;
CLOCK:	 DB	40	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
			; 4 for Apple ///
BYTDLY:	 DB	2	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	2	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
			;   default time for extra wait after CRLF
			;   in terminal mode file transfer
NOFCOL:	 DB	5	; Number of directory columns shown		10EH
TCHPUL:	 DB	'T'	; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;
ADDLFD:	 DB	NO	; Yes=add LF after CR to send file in terminal	110H
			;   mode (normally added by remote echo)
CONVRUB: DB	YES	; Yes=convert rub to backspace			111H
CRCDFLT: DB	YES	; Yes=default to CRC checking			112H
IGNRCTL: DB	YES	; Yes=CTL-chars above ^M not displayed		113H
;
EXTCHR:	 DB	'['-40H	; ESC = preceeds local control character	114H
EXITCHR: DB	'E'	; Exit character				115H
FILESND: DB	'F'	; Send file when in terminal mode		116H
NOCONCT: DB	'N'	; Disconnect from phone line			117H
LOGCHR:	 DB	'L'	; Send logon					118H
LSTCHR:	 DB	'P'	; Toggle printer				119H
UNSAVCH: DB	'R'	; Close input text buffer			11AH
SAVECHR: DB	'Y'	; Open input text buffer			11BH
CLEARS:	 DB	'Z'	; Clears screen, terminal mode			11CH
SPARE1:	 DB	0	; For future development			11DH
NODTR:	 DB	NO	; Yes if no DTR and need ATH0 to disconnect	11EH
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: JMP	RCVCTL1		; In modem control port 		11FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:  JMP	RCVCTL2		;					129H
	  DB	0,0,0,0,0,0,0	;					12CH
;
I$MDDATP: JMP	RCVDATP		;in modem data port			133H
	  DB	0,0,0,0,0,0,0	;					146H
;
O$MDDATP: JMP	SNDDATP		; Out modem data port			13DH
	  DB	0,0,0,0,0,0,0	; Spares if needed			140H
;
A$MDRCV:  RET			;					147H
	  DB	0,0		;					148H
;
C$MDRCV:  CPI	0FFH		; TurboDos returns 0ffh 		14AH
	  RET			; if char available			14CH
;
A$MDSND:  ANI	MDSND		; Always show ready to send		14DH
	  RET			;					14FH
;
C$MDSND:  CPI	MDSND		;					150H
	  RET			;					152H
;
A$MDTXE:  ANI	MDTXE		;					153H
	  RET			;					155H
;
C$MDTXE:  CPI	MDTXE		;					156H
	  RET			;					158H
;
;
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:RET
	  DB	0,0
;
;
; Jump vectors needed by each overlay
;
J$GOODBYE:JMP	GOODBYE		; Disconnects modem by dropping DTR	15CH
J$INITMOD:JMP	INITMOD		; Initializes modem, autosets baudrate	15FH
J$STUPR:  JMP	STUPR		; SET routine to change baudrate	162H
J$SYSVR:  JMP	SYSVR		; Signon message			165H
;
;
; "AT" command strings, can be replaced in individual overlay if needed
;
J$STRNGA: DS	3		; 1200 bps "AT" string			168H
J$STRNG1: DS	3		; 2400 bps "AT" string			16BH
;
;
; Next fourteen lines should not be changed by user overlay as these go
; to specific locations in the main program, not in the overlay.
;
J$CMDSPL: DS	3		; Allows entry of baudrate on CMD line	16EH
J$CRLF:	  DS	3		; Turns up one new line on display	171H
J$DIAL:	  DS	3		; Start of dialing routine		174H
J$DSCONT: DS	3		; Terminates modem use			177H
J$GOLST:  DS	3		; Printer routine, needed by Apple //e	17AH
J$ILPRT:  DS	3		; Prints an inline string, 0 to end	17DH
J$INBUF:  DS	3		; Stores a keybd string for comparison	180H
J$INLNCP: DS	3		; Inline "compare strings" routine	183H
J$INMDM:  DS	3		; Max .1 sec wait for modem character	186H
J$RCVRSP: DS	3		; For 3801 I/O use (TV-803)		189H
J$SNDCHR: DS	3		; Sends a character to the modem	18CH
J$SNDSTR: DS	3		; Sends a string to the modem, $ to end 18FH
J$TIMER:  DS	3		; .1 second timer (amount in 'B' reg.)	192H
J$NEW1:	  DB	0,0,0		; For future needs			195H
J$NEW2:	  DB	0,0,0		; For future needs			198H
;
;
; For 2400 bps auto-stepdown units
;
MANUAL:	  DB	0		; For manual selection flag		19BH
J$300:	  JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:	  JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:	  JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;
LOGPTR:	  DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	  CALL	J$ILPRT		; Display the following line		1A7H
	  DB	'TurboDos 1.41 Generic Version 1.0 '	;		1AAH
;
	  DB	CR,LF,0
	  RET
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER).
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; (special character-L).  You can put in several lines.  End with a 0.
;
LOGON:	DB	'Hello, from a TurboDos /// user',CR,0
;
;-----------------------------------------------------------------------

; This routine sets a 300 ms break tone.  It changes the baudrate to
; 19200 bps then sends enough ASCII null characters to consume 300 ms.
; (A null character is all spacing except for the stop bit.)  At high
; speed this effectively gives a steady break tone.  When finished it
; restores the baudrate to the original speed.
;
SENDBRK:
	LDA	MSPEED		; Get current speed
	STA	STRSPD		; Store for now
	CALL	OK19200		; Set output to 19200 bps
	LXI	D,575		; Will take 300 ms at 19,200 bps
;
SEND1:	XRA	A		; ASCII null character
	CALL	J$SNDCHR	; Sends a character to the modem
	DCX	D		; One less to go
	JNZ	SEND1		; If not zero, do another
;
	LDA	STRSPD		; Get original baudrate back
	JMP	SPDCHK		; Go set speed to normal
;
STRSPD:	DB	0		; Temporary 'store speed' byte
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the phone
;
GOODBYE:
	MVI	C,39		; T-FCN 39 set modem control
	MVI	D,CHNL		; Select current modem channel number
	MVI	E,0		; Turn off DTR
	CALL	TDOS
	MVI	B,2		; Wait for 300 ms
	CALL	J$TIMER
	MVI	C,39
	MVI	D,CHNL		; Select current modem channel number
	MVI	E,0C0H		; Reset DTR normal
	CALL	TDOS
;.....
;
;
INITMOD:
	MVI	C,39		; T-FCN 39 set modem control
	MVI	D,CHNL		; Select current modem channel number
	MVI	E,0C0H		; DTR normal
	CALL	TDOS
	LDA	MSPEED		; Get Baud Rate value
;
SPDCHK:	CPI	1		; Is it 300 baud
	JZ	OK300
	CPI	5		; Is it 1200 bps
	JZ	OK1200
	CPI	6		; Is it 2400 bps
	JZ	OK2400
	CPI	7		; Is it 4800 bps
	JZ	OK4800
	CPI	8		; Is it 9600 bps
	JZ	OK9600
	CPI	9		; Is it 19200 bps
	JZ	OK19200
	JMP	STUPR1		; If none of these, ask for new value
;
;
;-----------------------------------------------------------------------
;
; Use the 'SET' command to select a desired baud rate
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, 2400, '
	DB	'4800, 9600, 19200): ',0
	LXI	D,BAUDBUF	; Point to new input buffer
	CALL	J$INBUF
	CALL	J$CRLF
	LXI	D,BAUDBUF+2
;
STUPR2:	CALL	J$INLNCP	; Compare BAUDBUF+2 with chars. below
	DB	'300',0
	JNC	OK300		; Go if got match
	CALL	J$INLNCP
	DB	'1200',0
	JNC	OK1200
	CALL	J$INLNCP
	DB	'2400',0
	JNC	OK2400
	CALL	J$INLNCP
	DB	'4800',0
	JNC	OK4800
	CALL	J$INLNCP
	DB	'9600',0
	JNC	OK9600
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
OK300:	MVI	A,1		; Load MSPEED 300 baud value
	MVI	E,BD300
	JMP	LOADBD
;
OK1200:	MVI	A,5
	MVI	E,BD1200
	JMP	LOADBD
;
OK2400:	XRA	A		; Reset the automatic 2400 bps flag
	STA	MANUAL
	MVI	A,6
	MVI	E,BD2400
	JMP	LOADBD
;
OK4800:	MVI	A,7
	MVI	E,BD4800
	JMP	LOADBD
;
OK9600:	MVI	A,8
	MVI	E,BD9600
	JMP	LOADBD
;
OK19200:MVI	A,9
	MVI	E,BD19200
;
LOADBD:	STA	MSPEED		; Save Modem Speed
	MVI	C,37		; T-FCN 37 set Comm baud rate
	MVI	D,CHNL		; Select current modem channel number
	CALL	TDOS
	RET
;.....
;
;
; BAUD RATE TABLE
;
BD300	EQU	5		;  300 baud
BD1200	EQU	7		;  1200 bps
BD2400	EQU	10		;  2400 bps
BD4800	EQU	12		;  4800 bps
BD9600	EQU	14		;  9600 bps
BD19200	EQU	15		; 19200 bps
;.....
;
;
RCVCTL1:PUSH	B		; Test Modem Input Status
	PUSH	D
	PUSH	H
	MVI	C,34		; T-FCN 34 MODEM Status
	MVI	D,CHNL		; Select current modem channel number
	CALL	TDOS
	CPI	0FFH
	POP	H		; Restore Registers
	POP	D
	POP	B
	RET
;.....
;
;
RCVCTL2:MVI	A,0		; TBE always true....
	RET
;.....
;
;
RCVDATP:PUSH	B		; Read in a Character
	PUSH	D
	PUSH	H
	MVI	C,35		; T-FCN 35 Comm channel input
	MVI	D,CHNL		; Select current modem channel number
	CALL	TDOS
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
SNDDATP:PUSH	B		; Send out a Character
	PUSH	D
	PUSH	H
	MVI	C,36		; T-FCN 36 Comm channel output
	MVI	D,CHNL		; Select current modem channel number
	MOV	E,A		; Character in 'E' register
	CALL	TDOS
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
BAUDBUF:
	DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;.....
;
;			       end
;-----------------------------------------------------------------------
; NOTE: Must terminate by 0400H
;
	END
