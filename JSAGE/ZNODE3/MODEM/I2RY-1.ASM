; I2RY-1.ASM - Royal Alphatronic PC IMP overlay (low speed) - 07/10/87
;
;		USES 8251A I/O and no baudrate generator
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Royal computer to the IMP modem program.  This
; model has no baudrate generator and changes the 8251 from "x16" for
; 1200 bps to "x64" for 300 bps.  The Royal must be jumpered for 1200
; bps for this method to work. (J101 4th from left)
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
;		MLOAD IMP.COM=IMP.COM,I2RY-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 07/11/87  Adapted from I2SY-2.ASM for Royal Alphatronic PC
;						- Paul Carmichael
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.			- Irv Hoff
;
; 10/27/85  Initial IMP version 		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
; ROYAL EQUATES
;
EOICMD	EQU	20H	; Non-spec EIO for PIC
RXINTV	EQU	0EF04H	; Receive ready interruptvector
LSTSTV	EQU	0D92DH	; Lstst vector (bug in monitor)
PICPRT0	EQU	70H	; PIC base port
PICPRT1	EQU	71H
PICMSK0	EQU	0FDH	; Enable receive ready interrupt
PICMSK1	EQU	0FFH	; Mask all interrupts
RXBFSIZ	EQU	32	; Receive buffer size
XOFF	EQU	'S'-40H
XON	EQU	'Q'-40H
;
;
NO	EQU	0
YES	EQU	NOT NO	; (Some assemblers cannot use 0FFh)
;
;
; Valeus shown are for an 8251A
;
PORT	EQU	40H	; Your base port (data or status)
MDCTL1	EQU	PORT+1	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MDRCV	EQU	02H	; Modem receive ready
MDSND	EQU	01H	; Modem send ready bit
MDTXE	EQU	05H	; Modem send buffer empty, holding buffer empty
;
MDMODE	EQU	82H	; Insures 8251 is out of mode with DTR high
MDRSET	EQU	42H	; Resets USERT for additional commands
MDSET0	EQU	4FH	; 1 stop bit, no parity, 8 bits, x64
MDSET1	EQU	4EH	; 1 stop bit, no parity, 8 bits, x16
MDSET2	EQU	4CH	; 2 stop bits, no parity, 8 bits, x16
RDCOM	EQU	37H	; Reset RTS, error flags, RCV, DRT, TX ready
;
;
;-----------------------------------------------------------------------
;
ESC	EQU	'['-40H	; ^[ = escape
BELL	EQU	'G'-40H	; ^G = bell character
LF	EQU	'J'-40H	; ^J = linefeed
NEXTRY	EQU	'K'-40H	; ^K = try next phone number, abort this try
CR	EQU	'M'-40H	; ^M = carriage return
CLEARSC	EQU	'Z'-40H	; ^Z = clears screen, command mode only
EOFCHAR	EQU	'Z'-40H	; ^Z = end of file
;
;
;-----------------------------------------------------------------------
;
;
	ORG	103H
;
MSPEED:	 DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200		103h
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	 DB	NO	; Yes=2400 bps highest speed			104h
HS1200:	 DB	YES	; Yes=1200 bps highest speed			105h
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200v or 2400v or 2400pa	106h
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107h
RESVD1:	 DB	NO	; Reserved for special modems			108h
RESVD2:	 DB	NO	; Reserved for special modems			109h
;
;
CLEAR:	 DB	'E'	; Clear screen character (ESC not needed)	10Ah
CLOCK:	 DB	40	; Clock speed in mhz x10, 25.5 MHz max. 	10Bh
			; 20=2 MHz, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	2	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10Ch
			; Default time to send character in ter-
			; Minal mode file transfer for slow bbs
CRDLY:	 DB	2	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10Dh
			; Default time for extra wait after crlf
			; In terminal mode file transfer
NOFCOL:	 DB	5	; Number of directory columns shown		10Fh
TCHPUL:	 DB	'T'	; T=tone, P=pulse (Hayes 2400 modems)		10Fh
;.....
;
ADDLFD:	 DB	NO	; Yes=add LF after cr to send file in terminal	110h
			; Mode (normally added by remote echo)
CONVRUB: DB	YES	; Yes=convert RUB to backspace			111h
CRCDFLT: DB	YES	; Yes=default to CRC checking			112h
IGNRCTL: DB	YES	; Yes=CTL-characters above ^M not displayed	113h
;.....
;
EXTCHR:	 DB	'['-40H	; ESC = preceeds local control character	114h
EXITCHR: DB	'E'	; Exit character				115h
FILESND: DB	'F'	; Send file when in terminal mode		116h
NOCONCT: DB	'N'	; Disconnect from phone line			117h
LOGCHR:	 DB	'L'	; Send logon					118h
LSTCHR:	 DB	'P'	; Toggle printer				119h
UNSAVCH: DB	'R'	; Close input text buffer			11Ah
SAVECHR: DB	'Y'	; Open input text buffer			11Bh
CLEARS:	 DB	'Z'	; Clears screen, terminal mode			11Ch
BRKCHR:	 DB	'Q'	; Send a break tone				11Dh
NODTR:	 DB	NO	; Yes if no DTR and need ATH0 to disconnect	11Eh
;.....
;
; Handles in/out ports for data and status
;
	  ORG	11FH
I$MDCTL1: IN	MDCTL1
	  RET
;
	  ORG	129H
I$MDTXE:  IN	MDCTL1
	  RET
;
	  ORG	133H
I$MDDATP: JMP	GETRX
;
	  ORG	13DH
O$MDDATP: OUT	MDDATP
	  RET
;
	  ORG	147H
A$MDRCV:  RET
;
	  ORG	14AH
C$MDRCV:  JMP	RXRDY
;
	  ORG	14DH
A$MDSND:  ANI	MDSND
	  RET
;
C$MDSND:  CPI	MDSND
	  RET
;
A$MDTXE:  ANI	MDTXE
	  RET
;
C$MDTXE:  CPI	MDTXE
	  RET
;.....
;
	ORG	159H
;
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:JMP	REXIT		;					159h
;.....
;
; JUMP VECTORS NEEDED BY EACH OVERLAY
;
J$GOODBYE:JMP	GOODBYE		; Disconnects modem by dropping DTR	15Ch
J$INITMOD:JMP	INITMOD		; Initializes modem, autosets baudrate	15Fh
J$STUPR:  JMP	STUPR		; Set routine to change baudrate	162h
J$SYSVR:  JMP	SYSVR		; Signon message			165h
;.....
;
; "AT" command strings, can be replaced in individual overlay if needed
;
J$STRNGA: DS	3		; 1200 bps "AT" string			168h
J$STRNG1: DS	3		; 2400 bps "AT" string			16Bh
;
;
; Next fourteen lines should not be changed by user overlay as these go
; to specific locations in the main program, not in the overlay.
;
;
J$CMDSPL: DS	3		; Allows entry of baudrate on CMD line	16Eh
J$CRLF:	  DS	3		; Turns up one new line on display	171h
JR$DIAL:   DS	3		; Start of dialing routine		174h
J$DSCONT: DS	3		; Terminates modem use			177h
J$GOLST:  DS	3		; Printer routine, needed by APPLE //e	17Ah
J$ILPRT:  DS	3		; Prints an inline string, 0 to end	17Dh
J$INBUF:  DS	3		; Stores a keybd string for comparison	180h
J$INLNCP: DS	3		; Inline "compare strings" routine	183h
J$INMDM:  DS	3		; Max .1 sec wait for modem character	186h
J$RCVRSP: DS	3		; For 3801 I/O use (TV-803)		189h
J$SNDCHR: DS	3		; Sends a character to the modem	18Ch
J$SNDSTR: DS	3		; Sends a string to the modem, $ to end 18Fh
J$TIMER:  DS	3		; 1 second timer (amount in 'B' reg.)	192h
J$BREAK:  JMP	SENDBRK		; Break routine 			195h
J$NEW2:	  DB	0,0,0		; For future needs			198h
;.....
;
;
; For 2400 bps auto-stepdown units
;
MANUAL:	  DB	0		; For manual selection flag		19Bh
J$300:	  JMP	OK300		;					19Ch
J$1200:	  JMP	OK1200		;					19Fh
J$2400:	  JMP	OK2400		; Sets baudrate to 2400 bps		1A2h
;.....
;
;
LOGPTR:	  DW	LOGON		; Pointer to display logon message	1A5h
;
SYSVR:	  CALL	J$ILPRT		; Display the following line		1A7h
	  DB	'Version for Royal Alphatronic PC'
	  DB	CR,LF,0
	  RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400h (601 bytes
;	 available after start of SYSVER).
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; (special character-L).  You can put in several lines.  End with a 0.
;
LOGON:	DB	'Hello!',CR,LF,0
;
;-----------------------------------------------------------------------
;
; This routine sets a 300 ms break tone
;
SENDBRK:
	MVI	A,3FH		; DTR normal, send break tone
	JMP	GOODBYE+2
;.....
;
;
; This routine sets DTR low for 300 ms to disonnect the phone
;
GOODBYE:
	MVI	A,3DH		; Send break, turn off DTR
	DI
	OUT	MDCTL1		; Send to status port
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,37H		; Normal send/receive with DTR
	OUT	MDCTL1		; Send to status port
	LXI	H,RXBUF
;
R:	SHLD	RXPTR		; Reset pointer
	XRA	A
	STA	RXCNT		; Clear count
	EI
	RET
;.....
;
;
; Sets 8251 to 8 bits, DTR, RCV and TX ready
;
INITMOD:
	DI
	CALL	INIT0		; Go initialize the modem
	LHLD	LSTSTV+1
	SHLD	OLDVEC		; Save old LsTst vector
	LXI	H,LSTST
	SHLD	LSTSTV+1	; Insert new
	XRA	A
	STA	RXCNT		; Clear buffer counter
	LXI	H,RXBUF
	SHLD	RXPTR		; Preset pointer
	LXI	H,RXISR
	SHLD	RXINTV+1	; Rxrdy service vector into table
	MVI	B,8
	MVI	A,EOICMD
;
INITL1:	OUT	PICPRT0		; EOI to PIC
	DCR	B
	JNZ	INITL1		; 8 times
	MVI	A,0C3H
	STA	RXINTV
	MVI	A,PICMSK0
	OUT	PICPRT1		; Enable rxrdy interrupt
	EI
	RET
;.....
;
;
INIT0:	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 baud
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'INPUT BAUD RATE (300, 1200): ',0
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
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ INCORRECT ENTRY ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
OK300:	MVI	A,1		; MSPEED 300 baud value
	MVI	B,MDSET0	; Divide by 64 for 300 baud
	JMP	LOADBD		; Go set the baudrate
;
OK1200:	MVI	A,5
	MVI	B,MDSET1	; Divide by 16 for 1200 bps
	JMP	LOADBD		; Go set the baudrate
;
OK2400:	JMP	OK1200
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	MVI	A,MDMODE	; Insure 8251 is out of mode
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDRSET	; Reset the 8251a for new command
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MOV	A,B		; Set speed
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDCOM		; Error reset, RCV, DTR, TX ready
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	RET
;.....
;
;
REXIT:	DI
	MVI	A,0C9H		; Put return code into vector
	STA	RXINTV
	MVI	A,PICMSK1
	OUT	PICPRT1		; Mask all interrupts
	LHLD	OLDVEC
	SHLD	LSTSTV+1
	XRA	A
	STA	RXCNT
	LXI	H,RXBUF
	SHLD	RXPTR
	EI
	RET
;.....
;
;
; Receive ready service routine
;
RXISR:	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H		; Save registers
	IN	MDDATP
	LHLD	RXPTR		; Get buffer pointer
	MOV	M,A		; Put RX data to buffer
	INX	H
	SHLD	RXPTR
	LDA	RXCNT
	INR	A
	CPI	RXBFSIZ		; ? buffer full
	STA	RXCNT
	JC	RXISX		; Skip next if not
	MVI	A,0FFH
	STA	XOFFL
	MVI	A,XOFF
	CALL	J$SNDCHR
;
RXISX:	MVI	A,EOICMD
	OUT	PICPRT0		; EOI to PIC
	POP	H
	POP	D
	POP	B
	POP	PSW		; Restore registers
	EI
	RET
;.....
;
;
; Get a character from RX buffer
;
GETRX:	PUSH	B
	PUSH	D
	PUSH	H
;
GETRX0:	DI
	LDA	RXCNT
	DCR	A		; Decrement counter
	STA	RXCNT		; Store new value
	LXI	H,RXBUF
	MOV	C,A
	MOV	A,M
	STA	CHAR		; Save character
	JZ	GETRX1		; Skip next if last character
	MVI	B,0
	XCHG
	LXI	H,RXBUF+1
	DB	0EDH
	DB	0B0H		; Move buffer down a byte
;
GETRX1:	LDA	XOFFL
	ORA	A
	JZ	GETRXX		; If XOFF flag not set leave
	MVI	A,XON
	CALL	J$SNDCHR
	XRA	A
	STA	XOFFL		; Turn XON and clear flag
;
GETRXX:	LHLD	RXPTR
	DCX	H
	SHLD	RXPTR		; Adjust buffer pointer
	LDA	CHAR		; Recover character
	POP	H
	POP	D
	POP	B
	EI
	RET
;.....
;
;
RXRDY:	LDA	RXCNT		; Get RX buffer counter
	ORA	A		; Anything there?
	JZ	RXNRDY		; Go not ready if not
	XRA	A		; Indicate ready
	RET
;
RXNRDY:	MVI	A,0FFH
	ORA	A		; Indicate not ready
	RET
;.....
;
;
LSTST:
	IN	30H
	IN	30H		; For hardware
	ANI	40H		; ? busy
	JZ	LSTRDY		;
	XRA	A
	RET			; Lister busy
;
LSTRDY:	DCR	A
	ORA	A
	RET			; Lister not busy
;.....
;
;
XOFFL:	DB	0		; Xoff flag
CHAR:	DB	0		; Temp character register
RXPTR:	DW	0		; Buffer pointer
OLDVEC:	DW	0		; Old LsTst vector
BAUDBUF:DB	10,0,0,0,0,0	; CONINP buffer
	DB	0,0,0,0,0,0
RXCNT:	DB	0		; RX buffer counter
RXBUF:	DS	RXBFSIZ		; RX input buffer
;
;			       end
;-----------------------------------------------------------------------
	END
