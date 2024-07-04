
; I2EQ-4.ASM - INSIGHT EQ-4 overlay file for IMP - 06/01/87
;
;		Zilog DART and 8116 baudrate generator
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This overlay adapts the Insight Enterprises EQ-4 computer, using the
; Z80 DART and SMC 8116 baud rate generator to IMP.COM.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Many terminals will clear the screen with a CTL-Z.  If yours does, put
; a 1AH at CLEAR: (010AH).  Many terminals use two characters, the first
; normally an ESC.  For example, ESC *.  In this case put '*' at CLEAR:
; (The ESC will automatically be typed with no CTL-character present.)
; If you don't know what your terminal uses, put a 0 at CLEAR: and IMP
; will scroll up 24 blank lines to clear the CRT for things like MENU,
; looking at the function key table, typing CTL-Z in command mode, etc.
;
; Use the "SET" command to change the baudrate when desired.  The value
; at MSPEED controls the baudrate when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to merge into the main file:
;
;		MLOAD IMP.COM=IMP.COM,I2DP-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.			- Irv Hoff
;	
; 03/15/86  Converted to 8080 mnemonics, can now be use any normal 8080
;	    normal assembler.  Standardized routines to be compatible
;	    with other IMP overlays.		- Irv Hoff
;
; 02/09/86  Correction to 2400 baud select entry
;						- Chris Taylor
;
; 10/27/84  First version of this file, from I2KP-1.ASM
;						- Chris Taylor
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
; Change the following information to match your equipment
;
PORT	EQU	38H		; Port modem is on
DART	EQU	'A'		; Modem is on DART pair "A"
BRPORT	EQU	37H		; Baud rate generator port
MDCTL1	EQU	PORT+1		; Modem control port
MDDATP	EQU	PORT		; Modem data in port
MDRCV	EQU	1		; Bit to test for receive
MDSND	EQU	4		; Bit to test for send
MDTXE	EQU	1		; Value when ready
;
;
;-----------------------------------------------------------------------
;
ESC	EQU	'['-40H	; ^[ = Escape
BELL	EQU	'G'-40H	; ^G = Bell character
LF	EQU	'J'-40H	; ^J = Linefeed
NEXTRY	EQU	'K'-40H	; ^K = Try next phone number, abort this try
CR	EQU	'M'-40H	; ^M = Carriage return
CLEARSC	EQU	'Z'-40H	; ^Z = Clears screen, command mode only
EOFCHAR	EQU	'Z'-40H	; ^Z = End of file
;
;
;-----------------------------------------------------------------------
;
;
		ORG	100H
;
;
; Change the clock speed if needed, to match your system
;
	 DS	3	; (for	"JMP   START" instruction)
;
;
MSPEED:	 DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	 DB	NO	; Yes=2400 bps highest speed			104H
HS1200:	 DB	YES	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V 2400V or 2400PA 	106H
PROMODM: DB	NO	; Yes=Prometheus Promodem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
;
CLEAR:	 DB	1AH	; Clear screen char (ESC not needed)		10AH
CLOCK:	 DB	40	; Clock speed in mhz x10 25.5 MHz max		10BH
;

BYTDLY:	 DB	2	; 0=0 delay 1=10ms 5=50ms 9=90ms		10CH
			; Default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	2	; 0=0 delay 1=100ms 5=500ms 9=900ms		10DH
			; Default time for extra wait after CRLF
			;   in terminal mode file transfer
NOFCOL:	 DB	5	; Number of directory columns shown		10EH
TCHPUL:	 DB	'T'	; T=tone, p=pulse (Hayes 2400 modems		10FH
;......
;
;
ADDLFD:	 DB	NO	; Yes=add LF after CR to send file in terminal	110H
			;   mode (normally added by remote echo)
CONVRUB: DB	YES	; Yes=convert rub to backspace			111H
CRCDFLT: DB	YES	; Default to CRC checking			112H
IGNRCTL: DB	YES	; Yes=control chars above ^M not shown		113H
;.....
;
;
EXTCHR:	 DB	'['-40H	; Esc =  preceeds local CTL chars		114H
EXITCHR: DB	'E'	; Exit character
FILESND: DB	'F'	; Send file in terminal mode			116H
NOCONCT: DB	'N'	; Disconnect from phone line			117H
LOGCHR:	 DB	'L'	; Send logon					118H
LSTCHR:	 DB	'P'	; Toggle printer				119H
UNSAVCH: DB	'R'	; Close input text buffer			11AH
SAVECH:	 DB	'Y'	; Open input text buffer			11BH
CLEARS:	 DB	'Z'	; Clear screen in terminal mode 		11CH
BRKCHR:	 DB	'Q'	; Send a break tone				11DH
NODTR:	 DB	NO	; YES if no DTR and need ATH0 to disconnect	11EH
;.....
;
;
I$MDCTL1:	IN	MDCTL1		; In modem control port 	11FH
		RET
		DB	0,0,0,0,0,0,0
;
I$MDTXE:	IN	MDCTL1		; In modem data port		129H
		RET
		DB	0,0,0,0,0,0,0
;
IN$MDDATP:	IN	MDDATP		; In modem data port		133H
		RET
		DB	0,0,0,0,0,0,0
;
O$MDDATP:	OUT	MDDATP		; Out modem data port		13DH
		RET
		DB	0,0,0,0,0,0,0
;.....
;
;
A$MDRCV:	ANI	MDRCV		; Bit to test for receive ready 147H
		RET
;
C$MDRCV:	CPI	MDRCV		; Value of rcv. bit when ready	14AH
		RET
;
A$MDSND:	ANI	MDSND		; Bit to test for send ready	14DH
		RET
;
C$MDSND:	CPI	MDSND		; Value of send bit when ready	150H
		RET
;
A$MDTXE:	ANI	MDTXE		;				153H
		RET
;
C$MDTXE:	CPI	MDTXE		;				156H
		RET
;.....
;
;
; Special exit vector to reset interrupt vectors
;
J$EXITVEC:	RET			;				159H
		DS	2
;
;
J$GOODBYE:	JMP	GOODBYE		;				15CH
J$INITMOD	JMP	INITMOD		; Go to user written routine	15FH
J$STUPR:	JMP	STUPR		;				162H
J$SYSVER:	JMP	SYSVER		;				165H
;.....
;
;
; "AT" command strings, can be replaced by indificual overlay
;
J$STRNGA:	DS	3		; 1200 bps "AT" string		168H
J$STRNG1:	DS	3		; 2400 bps "AT" string		16BH
;
;
; Do not change the following FOURTEEN lines.  They are to specific lo-
; cations in the main program, not the overlay
;
J$CMDSPL:	DS	3		; Allows entry of baudrate	16EH
J$CRLF:		DS	3		;				171H
J$DIAL:		DS	3		;				174H
J$DSCONT:	DS	3		;				177H
J$GOLST:	DS	3		; Apple //e printer routine	17AH
;
J$ILPRT:	DS	3		;				17DH
J$INBUF:	DS	3		;				180H
J$INLNCP:	DS	3		;				183H
J$INMDM:	DS	3		;				186H
;
J$RCVRSP:	DS	3		;				189H
J$SNDCHR:	DS	3		; Send character to modem	18CH
J$SNDSTR:	DS	3		; Send string ($ at end) to mdm 18FH
J$TIMER:	DS	3		;				192H
J$BREAK:  	JMP	SENDBRK		; Break routine			195H
J$NEW2:		DB	0,0,0		; Future needs			198H
;.......
;
;
; For 2400 bps auto-stepdown modems
;
MANUAL:		DB	0		; Manual selection flag 	19BH
J$300:		JMP	OK300		; Set 300 baud			19CH
J$1200:		JMP	OK1200		; Set 1200 baud 		19FH
J$2400:		JMP	OK2400		; Set 2400 baud 		1A2H
;.....
;
;
LOGPTR:		DW	LOGON		; Pointer to display logon msg	1A5H
;
SYSVER:	CALL	J$ILPRT			;				1A7H
	DB	'Insight Enterprises EQ-4',CR,LF,0 ;			1AAH
	RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can use several lines if
; desired.  End with a 0.
;
LOGON:	DB	CR,LF,'Insight Enterprises EQ-4', CR,LF,0
;
;-----------------------------------------------------------------------
;
; This routine sets a 300 ms break tone
;
SENDBRK:
	MVI	A,5
	OUT	MDCTL1		; Send to the status port
	MVI	A,0F8H		; DTR normal, send break tone
	JMP	GOODBYE1	; Go send the break tone
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the modem.
;
GOODBYE:
	MVI	A,5
	OUT	MDCTL1		; Send to the status port
	MVI	A,78H		; Turn off DTR and send break tone
;
GOODBYE1:
	OUT	MDCTL1
	MVI	B,3		; Delay 300 ms
	CALL	J$TIMER
	MVI	A,5
	OUT	MDCTL1
	MVI	A,0E8H		; Restore normal, 8 bits, DTR on, etc.
	OUT	MDCTL1
	RET
;.....
;
;
; The following is used to initialize the EQ-4 Z80 DART-2 port.  Baud
; rate is initially set to 'SPEED'.
;
INITMOD:MVI	A,DART
	CPI	'A'		; If DART pair "A" selected
	MVI	A,MASK$A
	JZ	DO$A
	MVI	A,MASK$B	; Else, do "B" dart pair
;
DO$A:	STA	PORT$MASK	; Set port mask for future baud changes
	MVI	A,00H		; Select register
	OUT	MDCTL1
	MVI	A,18H		; Throw out of mode
	OUT	MDCTL1
	MVI	A,04H		; Select register
	OUT	MDCTL1
	MVI	A,44H		; Set ASCII parameters (44=1, 4C=2)
	OUT	MDCTL1
	MVI	A,03H		; Select register
	OUT	MDCTL1
	MVI	A,0C1H		; Enable receive
	OUT	MDCTL1
	MVI	A,05H		; Select register
	OUT	MDCTL1
	MVI	A,0EAH		; Enable send, DTR, RTS
	OUT	MDCTL1
;
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	CPI	6		; 2400 bps
	JZ	OK2400
	CPI	8		; 9600 bps
	JZ	OK9600
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
; Sets the modem speed via the SET command.
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, 2400, 9600): ',0
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
	DB	'9600',0
	JNC	OK9600
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
OK300:	MVI	A,1		; MSPEED 300 baud value
	MVI	B,BD300
	JMP	LOADBD
;
OK1200:	MVI	A,5
	MVI	B,BD1200
	JMP	LOADBD
;
OK2400:	XRA	A
	STA	MANUAL		; Reset to maximum auto-speed
	MVI	A,6
	MVI	B,BD2400
	JMP	LOADBD
;
OK9600:	MVI	A,8
	MVI	B,BD9600
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	MOV	A,B		; Get baudrate byte
	CALL	DO$CHANGE
	RET
;.....
;
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300	EQU	5
BD1200	EQU	7
BD2400	EQU	10
BD9600	EQU	14
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;.....
;
;
; HL points to block to output
; DB data,data,data,data....
;
BLOCK$OUTPUT:
	MVI	B,6		; Get count

BLOCK1:	OUT	MDCTL1
	INX	H
	DCR	B
	JNZ	BLOCK1
	RET			; Return
;.....
;
;
DBC	EQU	50		; Direct BIOS call
MASK$A	EQU	0F0H		; Baud rate mask for port A
MASK$B	EQU	00FH		; Baud rate mask for port B
BDOS	EQU	0005H		; BDOS entry
;
;
;-----------------------------------------------------------------------
;
; Locate the character I/O table then search for the DART ports.  When
; correct DART found, change the speed to the new value.  This allows
; 'device' command to report the actual speed.
;
;-----------------------------------------------------------------------
;
DO$CHANGE:
	CPI	10
	JNC	STO$SPD
	DCR	A
;
STO$SPD:MOV	L,A		; Convert speed to a pointer
	MVI	H,0
	DAD	H		; *2 for table entry size
	LXI	D,SPEED$T	; Base of table
	DAD	D
	SHLD	TABLE$IDX	; Save true pointer
	MOV	A,M
	STA	BAUD
	LXI	D,DBCT		; Point to BIOS call table
	MVI	C,DBC		; Direct BIOS call
	CALL	BDOS
;
;
; Begin search for DARTS
;
	LXI	B,8		; Size of character I/O table entry
;
LOOP:	MOV	A,M		; Get link indicator
	ANA	A
	JZ	SET$BAUD$RATE	; End of link if null
	PUSH	H
	INX	H
	INX	H
	INX	H
	INX	H
	INX	H
	MOV	A,M		; Get which port
	MOV	D,A		; Save for later
	INX	H
	INX	H
	MOV	E,M		; Remember old rate
	CPI	'A'
	JNZ	STO$B
	MOV	A,E		; Save old rate for later
	STA	A$SPD
	JMP	NEXT
;
STO$B:	CPI	'B'		; Is it 'B' port
	JNZ	NEXT		; No, don't update
	MOV	A,E
	STA	B$SPD
;
NEXT:	DCX	H
	MVI	A,DART		; Get selectd port
	CMP	D		; Is this a match?
	JNZ	BUMP
	DB	0CBH,4EH	; Z80 code
	JZ	BUMP
	INX	H
	LDA	BAUD		; Get true baud rate
	CPI	10		; Check if adjustment needed
	JNC	STO$RT
	INR	A		; Yes, so correct for display
;
STO$RT:	MOV	M,A		; And put into table entry
;
BUMP:	POP	H		; Recover HL
	DAD	B		; Bump pointer
	JMP	LOOP		; Go do another
;.....
;
;
; End of chain found, set new baud rate
;
SET$BAUD$RATE:
	LDA	B$SPD		; Get the old speeds
	CPI	10
	JNC	SKIP1		; Adjust rate value
	DCR	A
;
SKIP1:	RLC
	RLC
	RLC
	RLC
	MOV	B,A
	LDA	A$SPD
	CPI	10
	JNC	SKIP2		; Adjust rate value
	DCR	A
;
SKIP2:	ORA	B
	LXI	H,PORT$MASK	; Get correct mask
	ANA	M		; Erase for new value
	MOV	B,A		; Save value for later
	LHLD	TABLE$IDX	; Get table entry pointer
	LDA	PORT$MASK
	CPI	MASK$A
	JZ	GET$RATE	; If B port then point to B port speed
	INX	H
;
GET$RATE:
	MOV	C,M		; Get new value
	MOV	A,B		; Get old value
	ORA	C		; Form new value
	OUT	BRPORT		; Change the speed
	RET
;.....
;
;
;****************************************
;					*
;	STORAGE 			*
;					*
;****************************************
;
;
TABLE$IDX:
	DW	SPEED$T		; Pointer to table entry
;
;
; Port speed A/B
;
SPEED$T:DB	0,0*16		; 50 baud
	DB	1,1*16		; 75 baud
	DB	2,2*16		; 110 baud
	DB	3,3*16		; 134 baud
	DB	4,4*16		; 150 baud
	DB	5,5*16		; 300 baud
	DB	6,6*16		; 600 baud
	DB	7,7*16		; 1200 bps
	DB	8,8*16		; 1800 bps
	DB	9,9*16		; 2000 bps ( not supported )
	DB	10,10*16	; 2400 bps
	DB	11,11*16	; 3600 bps
	DB	12,12*16	; 4800 bps
	DB	13,13*16	; 7200 bps
	DB	14,14*16	; 9600 bps
	DB	15,15*16	; 19200 bps
;
BAUD:	DB	0		; Selected baud rate value
A$SPD:	DB	0		; Old baud rate
B$SPD:	DB	0		; Old baud rate
;
PORT$MASK:
	DB	0,0		; Port mask
;
DBCT:	DB	20		; BIOS call 20 - character I/O tables
	DB	0		; A reg
	DW	0		; BC regs
	DW	0		; DE regs
	DW	0		; HL regs
;.....
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE:  Must terminate prior to 0400H
;
	END
