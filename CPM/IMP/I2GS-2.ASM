
;	I2GS-2.ASM - Apple IIGS overlay file for IMP - 07/17/88
;
;	Internal Zilog 8530 SCC Serial Communications Controller
;
; This overlay file adapts Apple IIGS computers with a PCPI Applicard
; and external 300/1200 or 300/1200/2400 bps modems to IMP.COM.
;
;-----------------------------------------------------------------------
;
; You will want to look this file over carefully.  There are a number of
; options that you can use to configure the program to suit your taste.
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
;		MLOAD IMP.COM=IMP.COM,I2GS-2.HEX
;
;					- Notes by Irv Hoff W6FFC
;
; =   =  =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =
;
; 07/17/88  Written for the Apple IIGS	- John Wolf
;	    Heavily modified from Irv Hoff's //c overlay
;
; =   =  =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =
;
YES	EQU	0FFH
NO	EQU	0
;
;====================== CUSTOMIZATION EQUATES ==========================
;
PEEKCMD	EQU	06H
POKECMD	EQU	07H
RDBYTE	EQU	0FFE0H
WRBYTE	EQU	0FFE3H
WRWORD	EQU	0FFE9H
;
SLOT1	EQU	NO		; Yes for slot 1
SLOT2	EQU	YES		; Yes for slot 2
;
	 IF	SLOT1
MDCMD	EQU	0C039H		; Address of command port A
	 ENDIF
;
	 IF	SLOT2
MDCMD	EQU	0C038H		; Address of command port B
	 ENDIF
;
MDDATP	EQU	MDCMD+2		; Address of data port
MDRXF	EQU	01H		; Receive register full bit
MDTXE	EQU	04H		; Transmit register empty bit
MDSND	EQU	04H		; Same as TXE
;
;-----------------------------------------------------------------------
;
; General equates
;
ESC	EQU	'['-40H		; ^[ = Escape
BELL	EQU	'G'-40H		; ^G = Bell character
LF	EQU	'J'-40H		; ^J = Linefeed
NEXTRY	EQU	'K'-40H		; ^K = Try next phone number now
CR	EQU	'M'-40H		; ^M = Carriage return
CLEARSC	EQU	'Z'-40H		; ^Z = Clear screen, command mode only
EOFCHAR	EQU	'Z'-40H		; ^Z = End of file
;
;-----------------------------------------------------------------------
;
	ORG	0100H
;
	DS	3	; Skip the data area below
;
; These routines and equates are at the beginning of the program so
; they can be patched by a monitor or overlay file without re-assembling
; the program.
;
MSPEED:	 DB	6	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
;
HS2400:	 DB	YES	; Yes=2400 bps highest speed			104H
HS1200:	 DB	NO	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
CLEAR:	 DB	'*'	; Clear screen character (ESC not needed)	10AH
CLOCK:	 DB	6	; Clock speed in MHz, 25.5 MHz max.		10BH
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	0	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	5	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
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
BRKCHR:	 DB	'Q'	; Send a break tone				11DH
NODTR:	 DB	NO	; YES if no DTR and need ATH0 to disconnect	11EH
;
; Handles in/out ports for data and status
;
I$MDRXF:  JMP	RCVCMD		; Test for receive reg full		11FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			123H
;
I$MDTXE:  JMP	RCVCMD		; Test for transmit reg empty		129H
	  DB	0,0,0,0,0,0,0	;					12DH
;
I$MDDATP: JMP	RCVDATP		; In modem data port			133H
	  DB	0,0,0,0,0,0,0	;					147H
;
O$MDDATP: JMP	SNDDATP		; Out modem data port			13DH
	  DB	0,0,0,0,0,0,0	;					140H
;
A$MDRXF:  ANI	MDRXF		;					147H
	  RET			;					149H
;
C$MDRXF:  CPI	MDRXF		;					14AH
	  RET			;					14CH
;
A$MDSND:  ANI	MDSND		;					14DH
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
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:RET			;					159H
	  DB	0,0		;					15AH
;
; Jump vectors needed by each overlay
;
J$GOODBYE:JMP	GOODBYE		; Disconnects modem by dropping DTR	15CH
J$INITMOD:JMP	INITMOD		; Initializes modem, autosets baudrate	15FH
J$STUPR:  JMP	STUPR		; SET routine to change baudrate	162H
J$SYSVR:  JMP	SYSVR		; Signon message			165H
;
; "AT" command strings, can be replaced in individual overlay if needed
;
J$STRNGA: DS	3		; 1200 bps "AT" string			168H
J$STRNG1: DS	3		; 2400 bps "AT" string			16BH
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
J$BREAK:  JMP	SENDBRK		; Break routine 			195H
J$NEW2:	  DB	0,0,0		; For future needs			198H
;
; For 2400 bps auto-stepdown units
;
MANUAL:	  DB	NO		; YES if manual stepdown			19BH
J$300:	  JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:	  JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:	  JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;
LOGPTR:	DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	CALL	J$ILPRT		; Display the following line		1A7H
;
	DB	'Apple IIGS and PCPI Applicard'
	DB	CR,LF,0
	RET
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
LOGON:	DB	'Basselopes eat Poptarts (with butter!)',CR,0
;
;======================== BREAK/GOODBYE ===============================
;
SENDBRK:MVI	A,5
	CALL	SNDCMD
	MVI	A,01111010B	; DTR on, BRK on
	JMP	GOBRK
;
GOODBYE:MVI	A,5
	CALL	SNDCMD
	MVI	A,11111010B	; DTR off, BRK on
GOBRK:	CALL	SNDCMD		; Set register 5
	MVI	B,3
	CALL	J$TIMER
	MVI	A,5
	CALL	SNDCMD
	MVI	A,01101010B	; DTR on, BRK off
	JMP	SNDCMD		; Set register 5
;
;=========================== INITMOD ===================================
;
INITMOD:PUSH	H
	LXI	H,BITS		; Get table address
LOOP:	MOV	A,M		; Get reg number
	ORA	A
	JZ	DONE		; Zero is end
	CALL	SNDCMD
	INX	H
	MOV	A,M		; Get reg value
	CALL	SNDCMD
	INX	H
	JMP	LOOP
DONE:	POP	H
	LDA	MSPEED		; Autoset baudrate
	CPI	1
	JZ	OK300
	CPI	5
	JZ	OK1200
	CPI	6
	JZ	OK2400
	CPI	7
	JZ	OK4800
	CPI	8
	JZ	OK9600
	JMP	STUPR1		; Bad value in overlay, ask
;
BITS:	 IF	SLOT1
	DB	09,10000000B	; Reset channel A
	 ENDIF
	 IF	SLOT2
	DB	09,01000000B	; Reset channel B
	 ENDIF
	DB	11,11010000B	; Set xtal on RTxC and Rx-Tx to BR gen
	DB	12,2EH		; Low byte of BR generator
	DB	13,00H		; High byte of baud
	DB	14,00000001B	; Enable BR generator
	DB	15,00000000B	; Kill interrupts
	DB	01,00000000B	; Kill Rx-Tx interrupts
	DB	03,11000001B	; Rx-8bit, Rx on
	DB	04,01000100B	; X16 clock, 1 stop, no parity
	DB	05,01101010B	; Tx-8bit, Tx on, DTR on, BRK off
	DB	0
;
;========================== APPLE I/O ==================================
;
SNDCMD:	PUSH	D
	LXI	D,MDCMD
	JMP	POKE
;
SNDDATP:PUSH	D
	LXI	D,MDDATP
POKE:	PUSH	B
	MOV	B,A
	MVI	C,POKECMD
	CALL	WRBYTE
	CALL	WRWORD
	MOV	C,B
	CALL	WRBYTE
	POP	B
	POP	D
	RET
;
RCVCMD:	PUSH	D
	LXI	D,MDCMD
	JMP	PEEK
;
RCVDATP:PUSH	D
	LXI	D,MDDATP
PEEK:	PUSH	B
	MVI	C,PEEKCMD
	CALL	WRBYTE
	CALL	WRWORD
	CALL	RDBYTE
	POP	B
	POP	D
	RET
;
;============================ STUPR ====================================
;
; Use the 'SET' command to select a desired baud rate
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, 2400, 4800, 9600): ',0
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
OK300:	MVI	A,1
	MVI	B,7EH		; Baud value for 300 is actually 17EH
	JMP	LOADBD		; Taken care of in LOADBD
;
OK1200:	MVI	A,5
	MVI	B,5EH		; Baud rate values same as Apple's
	JMP	LOADBD
;
OK2400:	MVI	A,6
	MVI	B,2EH
	JMP	LOADBD
;
OK4800:	MVI	A,7
	MVI	B,16H
	JMP	LOADBD
;
OK9600:	MVI	A,8
	MVI	B,0AH
;
LOADBD:	STA	MSPEED		; Save baud rate
	MVI	A,12
	CALL	SNDCMD
	MOV	A,B
	CALL	SNDCMD
	MVI	A,13
	CALL	SNDCMD
	LDA	MSPEED
	CPI	1
	JZ	ONE
	XRA	A
ONE:	JMP	SNDCMD
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
;-----------------------------------------------------------------------
;
; Pinout and cabling for GS serial port
;      _________
;    /	  \ /	 \	Apple IIgs Serial port as seen from rear of
;   / (8) (7) (6) \	computer. Note: these ports are RS422, to
;  /		   \	make them compatible with RS232 devices
; <  (5)   (4) (3)  >	pin 8 must connect to pin 4 (ground.)
;  \_		  _/	This converts RS422 to RS423, the same
;   \|	(2) (1)  |/	as RS232 except for voltage (+-5 versus +-12.)
;    \ _________ /
;
; Pin 1 - Output handshake (DTR) Set with reg 5, mask=80H (inverted)
; Pin 2 - Input handshake (DCD, DSR or RING) Test with mask=20H
; Pin 3 - Transmit data- Connect to modem receive
; Pin 4 - Ground
; Pin 5 - Receive data- Connect to modem transmit
; Pin 6 - Transmit data+ Leave unconnected
; Pin 7 - Not connected
; Pin 8 - Receive data+ Must be connected to ground
;
;-----------------------------------------------------------------------
;
; Overlay must terminate before 400H
