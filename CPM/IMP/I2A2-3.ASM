
; I2A2-3.ASM - Apple //c overlay file for IMP - 06/01/87
;
;		6551 with built-in baudrate generator
;
; This overlay file adapts Apple //c computers with various CP/M cards
; and external 300/1200 or 300/1200/2400 bps modems to IMP.COM.  It sup-
; ports the following configurations:
;
; CP/M adapter cards:
; ------------------
;	ALS CP/M 3.0 adapter card
;	Applied Engineering Z80+ or Z80C
;	Microsoft Softcard Z80 equivalent
;	PCPI Applicard
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
;		MLOAD IMP.COM=IMP.COM,I2A2-x.HEX
;
;					- Notes by Irv Hoff W6FFC
;
; =   =  =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.		- Irv Hoff
;
; 06/06/86  Added SNDCTL2 and SNDCLT3 routines for the Applicard.
;					- Irv Hoff
;
; 03/22/86  Written for the Apple //c	- Irv Hoff
;
; =   =  =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =
;
YES	EQU	0FFH
NO	EQU	0
;
;
;====================== CUSTOMIZATION EQUATES ==========================
;
; CP/M adapter cards for Apple //c
;
ALSCARD	   EQU	NO	       ; Yes if using ALS CP/M card
APPLIED	   EQU	NO	       ; Yes if using Applied Engineering Z80
APPLICARD  EQU	YES	       ; Yes if using PCPI Applicard CP/M card
MICROSOFT  EQU	NO	       ; Yes if Microsoft Softcard CP/M card
;
;-----------------------------------------------------------------------
;
PORT	EQU	0E0A8H
MDDATP	EQU	PORT		; Data port
MDCTL1	EQU	PORT+1		; Status port
MDCTL2	EQU	PORT+2		; Command port
MDCTL3	EQU	PORT+3		; Control port
MDRCV	EQU	08H		; Modem receive bit
MDSND	EQU	10H		; Modem send bit
MDTXE	EQU	10H		; Modem send buffer empty bit
;
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
;
;-----------------------------------------------------------------------
;
;
	ORG	0100H
;
	DS	3	; Skip the data area below
;
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
CLEAR:	 DB	'*'	; Clear screen character (ESC not needed)	10AH
;
	  IF	APPLICARD
CLOCK:	 DB	6	; Clock speed in MHz, 25.5 MHz max.		10BH
			; NOTE:  DO NOT MULTIPLY BY 10 FOR APPLICARD
	  ENDIF		; APPLICARD
;
	  IF	NOT APPLICARD
CLOCK:	 DB	40	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
	  ENDIF		; NOT APPLICARD
;
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	9	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	9	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
			;   default time for extra wait after CRLF
			;   in terminal mode file transfer
NOFCOL:	 DB	5	; Number of directory columns shown		10EH
TCHPUL:	 DB	'T'	; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;.....
;
;
ADDLFD:	 DB	NO	; Yes=add LF after CR to send file in terminal	110H
			;   mode (normally added by remote echo)
CONVRUB: DB	YES	; Yes=convert rub to backspace			111H
CRCDFLT: DB	YES	; Yes=default to CRC checking			112H
IGNRCTL: DB	YES	; Yes=CTL-chars above ^M not displayed		113H
;.....
;
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
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: JMP	RCVCTL1		; In modem control port 		11FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:  JMP	RCVCTL1		;					129H
	  DB	0,0,0,0,0,0,0	;					12CH
;
I$MDDATP: JMP	RCVDATP		;in modem data port			133H
	  DB	0,0,0,0,0,0,0	;					146H
;
O$MDDATP: JMP	SNDDATP		; Out modem data port			13DH
	  DB	0,0,0,0,0,0,0	; Spares if needed			140H
;.....
;
;
A$MDRCV:  ANI	MDRCV		;					147H
	  RET			;					149H
;
C$MDRCV:  CPI	MDRCV		;					14AH
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
;.....
;
;
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:RET			;					159H
	  DB	0,0		;					15AH
;.....
;
;
; Jump vectors needed by each overlay
;
J$GOODBYE:JMP	GOODBYE		; Disconnects modem by dropping DTR	15CH
J$INITMOD:JMP	INITMOD		; Initializes modem, autosets baudrate	15FH
J$STUPR:  JMP	STUPR		; SET routine to change baudrate	162H
J$SYSVR:  JMP	SYSVR		; Signon message			165H
;.....
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
J$BREAK:  JMP	SENDBRK		; Break routine 			195H
J$NEW2:	  DB	0,0,0		; For future needs			198H
;.....
;
;
; For 2400 bps auto-stepdown units
;
MANUAL:	  DB	0		; For manual selection flag		19BH
J$300:	  JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:	  JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:	  JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;.....
;
;
LOGPTR:	DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	CALL	J$ILPRT		; Display the following line		1A7H
;
	DB	'Apple ][ and '	;
;
	 IF	ALSCARD
	DB	'ALS CP/M Card'
	 ENDIF			; ALSCARD
;
	 IF	APPLICARD
	DB	'Applicard'
	 ENDIF			; APPLICARD
;
	 IF	APPLIED
	DB	'Applied Engineering'
	 ENDIF			; APPLIED
;
	 IF	MICROSOFT
	DB	'CP/M 2.2 Card'
	 ENDIF			; MICROSOFT
;
	DB	CR,LF
;
	DB	' Z80C ',CR,LF
	DB	0
	RET
;.....
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
LOGON:	DB	'Hello there from a happy computer user',CR,0
;
;-----------------------------------------------------------------------
;
; This routine sets a 300 ms break tone
;
SENDBRK:
	MVI	A,0FH		; DTR normal, send break tone
	JMP	GOODBYE+2	; Send the break tone
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the modem.
;
GOODBYE:
	MVI	A,0EH		; Turn off DTR and send break
	CALL	SNDCTL2
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,0BH		; Set DTR, Rx, Irq
	CALL	SNDCTL2
	XTHL			; Short delay to complete command
	XTHL
	RET
;.....
;
;
;=========================== INITMOD ===================================
;
;
INITMOD: IF	ALSCARD
	LHLD	1		; Initialize our local jumps to the BIOS
	LXI	D,60H
	DAD	D
	SHLD	APREAD+1
	INX	H
	INX	H
	INX	H
	SHLD	APWRITE+1
	RET
	 ENDIF			; ALSCARD
;.....
;
;
	MVI	A,0BH		; Set DTR, Rx, Irq
	CALL	SNDCTL2
	XTHL			; Short delay to complete command
	XTHL
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
INITMOD1:
	MOV	A,B		; Get the baudrate back
	CALL	SNDCTL3		; Store default baudrate
	XTHL			; Short delay to complete command
	XTHL
	RET
;.....
;
;
; If none of the above cards
;
	RET			; From 'CALL INITMOD'
	RET
;.....
;
;
;========================== APPLE I/O ==================================
;
	 IF	APPLIED	OR MICROSOFT
SNDCTL1:STA	MDCTL1
	RET
;
SNDDATP:STA	MDDATP
	RET
;
RCVCTL1:LDA	MDCTL1
	RET
;
RCVDATP:LDA	MDDATP
	RET
;.....
;
;
RCVCTL3: LDA	MDCTL3
	 RET
;
SNDCTL2: STA	MDCTL2
	 RET
;
SNDCTL3: STA	MDCTL3
	 RET
	  ENDIF			; APPLIED OR MICROSOFT
;.....
;
;
	  IF	ALSCARD
SNDCTL1: PUSH	H
	 LXI	H,MDCTL1
	 JMP	POKE
;
SNDDATP: PUSH	H
	 LXI	H,MDDATP
;
POKE:	 PUSH	D
	 PUSH	B
	 CALL	APWRITE
	 POP	B
	 POP	D
	 POP	H
	 RET
	  ENDIF			; ALSCARD
;.....
;
;
	  IF	ALSCARD
RCVCTL1: PUSH	H
	 LXI	H,MDCTL1
	 JMP	PEEK
;
RCVDATP: PUSH	H
	 LXI	H,MDDATP
;
PEEK:	 PUSH	D
	 PUSH	B
	 CALL	APREAD
	 POP	B
	 POP	D
	 POP	H
	 RET
;.....
;
;
; These are the jump locations to the ALS BIOS
;
APREAD:	 JMP	$-$
APWRITE: JMP	$-$
	  ENDIF			; ALSCARD
;.....
;
;
	  IF	APPLICARD	;
RDBYTE	 EQU	0FFE0H		; Read 1 byte frin Aooke (A = byte)
WRBYTE	 EQU	0FFE3H		; Write 1 byte to Apple (C = byte)
RDWORD	 EQU	0FFE6H		; Read 2 bytes from Apple (DE = word)
WRWORD	 EQU	0FFE9H		; Write 2 bytes to Apple (DE = word)
PEEK1	 EQU	6		; Command
POKE1	 EQU	7		; Command
;
SNDCTL1: PUSH	D
	 LXI	D,MDCTL1
	 JMP	POKE
;
SNDDATP: PUSH	D
	 LXI	D,MDDATP
;
POKE:	 PUSH	B
	 MOV	B,A
	 MVI	C,POKE1
	 CALL	WRBYTE
	 CALL	WRWORD
	 MOV	C,B
	 CALL	WRBYTE
	 POP	B
	 POP	D
	 RET
;...
;
;
RCVCTL1: PUSH	D
	 LXI	D,MDCTL1
	 JMP	PEEK
;
RCVDATP: PUSH	D
	 LXI	D,MDDATP
;
PEEK:	 PUSH	B
	 MVI	C,PEEK1
	 CALL	WRBYTE
	 CALL	WRWORD
	 CALL	RDBYTE
	 POP	B
	 POP	D
	 RET
;.....
;
;
SNDCTL2:PUSH	D
	LXI	D,MDCTL2
	JMP	POKE
;
SNDCTL3:PUSH	D
	LXI	D,MDCTL3
	JMP	POKE
	  ENDIF			; APPLICARD
;.....
;
;
;-----------------------------------------------------------------------
;
; Use the 'SET' command to select a desired baud rate
;
STUPR	EQU	$
	CALL	J$CMDSPL	; Gives us CMDBUF+6
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
	MVI	B,BD300		; Get 300 baud value for 2651 in 'B'
	JMP	LOADBD		; Go load everything
;
OK1200:	MVI	A,5
	MVI	B,BD1200
	JMP	LOADBD
;
OK2400:	XRA	A
	STA	MANUAL
	MVI	A,6
	MVI	B,BD2400
	JMP	LOADBD
;
OK9600:	MVI	A,8
	MVI	B,BD9600
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	JMP	INITMOD1	; Reset to new baudrate
;.....
;
;
; Table of baud rate parameters
;
BD300	EQU	22
BD1200	EQU	24
BD2400	EQU	26
BD9600	EQU	30
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;.....
;
;
;-----------------------------------------------------------------------
; NOTE: Must terminate prior to 0400H
