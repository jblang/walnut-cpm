
; I2MDA-3.ASM - Morrow Micro-Decision overlay file for IMP - 06/01/87
;
;		MD-3 8281, MD-5 or MD-121 Z80 SIO
;
; Version for ALL Micro-Decisions, including hard disk models, ROM v1.x
; machines (no parallel port), and ROM revision 2.x and 3.x machines
; with (with parallel port).
;
; If you are using this overlay for the MD-HD computer (MD-5, -11, etc.)
; you have two additional options in the SET command: AUX and P/M.  When
; using SET AUX, it selects the Auxilliary port as your modem port.  The
; SET P/M selects the Printer/Modem port.  Select either the MDHDA or
; the MDHDP equate below as the DEFAULT modem port.  You can always use
; the SET command later to swap ports.
;					      - Paul Bartholomew
;-----------------------------------------------------------------------
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts all of the MD series computers. Be sure and select
; which model you have below.
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
;		MLOAD IMP.COM=IMP.COM,I2MDA-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;    v3	    IMP245 to use it.			- Irv Hoff
;
; 09/24/85  Fixed bug with MD-HD overlay trashing the BC registers in
;    v2     the I/O routines.	There are now only 3 or 4 bytes left
;	    in the MD-HD overlay before it goes past the 0400h limit.
;						- Paul Bartholomew
; 09/23/85 - Written to work with IMP		- Paul Bartholomew
;    v1
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
; Set ONE AND ONLY ONE of the following to YES, all the rest to NO:
;
MD3R1	EQU	NO	; Set to YES for MD-2/3 with Revision 1.x ROM
MD3R2	EQU	NO	; Set to YES for MD-2/3 with Revision 2.x or 3.x ROM
MDHDA	EQU	NO	; Set to YES for MD-HD using Auxilliary port
MDHDP	EQU	YES	; Set to YES for MD-HD using Printer/Modem port
;
;
; EQUates for MD-2/3 all ROM's
;
	 IF	(MD3R1 OR MD3R2)
MDDATP	EQU	0FEH	; Printer/Modem DATA port
MDCTL1	EQU	0FFH	; Printer/Modem STATUS port
MDRCV	EQU	02H	; Modem receive ready
MDSND	EQU	01H	; Modem send ready bit
MDTXE	EQU	05H	; Modem send buffer empty, holding buffer empty
	 ENDIF
;
;
; CTC EQUates for MD-2/3 ROM 2.x and 3.x
;
	 IF	MD3R2
BPORT	EQU	0F2H
CPORT	EQU	0F3H
CTCSEL	EQU	0BEH
	 ENDIF
;
;
; EQUates for MD-HD using Auxilliary port
;
	 IF	MDHDA
PORT	EQU	70H	; Auxilliary BASE port
BRPORT	EQU	50H	; Baud rate port
BMODE	EQU	3EH	; Mode
	 ENDIF
;
;
; EQUates for MD-HD using Printer/Modem port
;
	 IF	MDHDP
PORT	EQU	62H	; Printer/Modem BASE port
BRPORT	EQU	51H	; Baud rate port
BMODE	EQU	7EH	; Mode
	 ENDIF
;
;
;EQUates for MD-HD
;
	 IF	(MDHDA OR MDHDP)
MDCTL1	EQU	PORT+1	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MOPORT	EQU	53H	; Mode port
MDRCV	EQU	01H	; Modem receive ready
MDSND	EQU	04H	; Modem send ready bit
MDTXE	EQU	01H	; Modem send buffer empty, holding buffer empty
	 ENDIF
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
	ORG	0100H
;
;
	DS	3	; Skip the data area below
;
;
; These routines and equates are at the beginning of the program so
; they can be patched by a monitor or overlay file without re-assembling
; the program.
;
MSPEED:	 DB	5	; 1=300 5=1200 6=2400 7=4800 8=9600 9=19200	103H
HS2400:	 DB	NO	; Yes=2400 bps highest speed			104H
HS1200:	 DB	YES	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
;
CLEAR:	 DB	'*'	; Clear screen character (ESC not needed)	10AH
CLOCK:	 DB	40	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	2	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	2	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
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
I$MDCTL1:
	  JMP	IMDC		;					11FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:
	  JMP	IMDT		;					129H
	  DB	0,0,0,0,0,0,0	;					12CH
;
I$MDDATP:
	  JMP	IMDD		;					133H
	  DB	0,0,0,0,0,0,0	;					136H
;
O$MDDATP:
	  JMP	OMDD		;					13DH
	  DB	0,0,0,0,0,0,0	;					140H
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
J$STRNG1: DS	3		; 2400 bps "AT" string			16B:IMP
;
;
; Next fourteen lines should not be changed by user overlay as these go
; to specific locations in the main program, not in the overlay.
;
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
LOGPTR:	  DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	  CALL	J$ILPRT		; Display the following line		1A7H
	  DB	'Version for '	;					1AAH

	   IF	MD3R1
	  DB	'Morrow MD-2/3 with Revision 1.x ROM'
	   ENDIF

	   IF	MD3R2
	  DB	'Morrow MD-2/3 with Revision 2.x or 3.x ROM'
	   ENDIF

	   IF	MDHDA
	  DB	'Morrow MD-HD using Auxilliary Port'
	   ENDIF

	   IF	MDHDP
	  DB	'Morrow MD-HD using Printer/Modem Port'
	   ENDIF

	  DB	CR,LF,0
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
LOGON:	DB	'This is a Morrow Micro Decision computer',CR,LF,0
;
;-----------------------------------------------------------------------
;
; Modem I/O for MD-2/3 all ROM's:
;
; Input STATUS to A
;
	 IF	MD3R1 OR MD3R2
IMDC:	IN	MDCTL1
	RET
;.....
;
;
; Check for transmit ready
;
IMDT:
	IN	MDCTL1
	RET
;.....
;
;
; Input byte from DATA port to A
;
IMDD:
	MVI	A,37H
	OUT	MDCTL1
	IN	MDDATP
	RET
;.....
;
;
; Output byte in A to DATA port
;
OMDD:
	OUT	MDDATP
	RET
	 ENDIF			; MD3R1 OR MD3R2
;
;-----------------------------------------------------------------------
;
; Modem I/O for MD-HD using either port:
;
; BASE PORT - Changed by SET
;
; DON'T CHANGE THE ORDER OF THE FOLLOWING 3 BYTES!
; ------------------------------------------------
;
	 IF	MDHDA OR MDHDP
BSPRT:	DB	PORT
BRPRT:	DB	BRPORT
BMD:	DB	BMODE
;.....
;
;
; Input STATUS to 'A' register
;
IMDC:	PUSH	B
	LDA	BSPRT
	MOV	C,A
	INR	C
	MVI	A,10H		; Register 0, reset interrupts
	DW	79EDH		; Z80 opcodes for  OUT	(C),A
	DW	78EDH		; Z80 opcodes for  IN	A,(C)
	POP	B
	RET			; IN modem control port
;.....
;
;
; Check for transmit ready
;
IMDT:	PUSH	B
	LDA	BSPRT
	MOV	C,A
	INR	C
	MVI	A,11H		; Read register 1, for "all sent"
	DW	79EDH		; Z80 opcodes for  OUT	(C),A
	DW	78EDH		; Z80 opcodes for  IN	A,(C)
	POP	B
	RET
;.....
;
;
; Input byte from DATA port to A
;
IMDD:	PUSH	B
	LDA	BSPRT
	MOV	C,A
	DW	78EDH		; Z80 opcodes for  IN	A,(C)
	POP	B
	RET
;....
;
;
; Output byte in A to DATA port
;
OMDD:
	PUSH	B
	PUSH	PSW
	LDA	BSPRT
	MOV	C,A
	POP	PSW
	DW	79EDH		; Z80 opcodes for  OUT	(C),A
	POP	B
	RET
	 ENDIF			; MDHDA OR MDHDP
;
;-----------------------------------------------------------------------
;
;
; This routine sets a 300 ms break tone for the 8251 I/O
;
	 IF	MD3R1 OR MD3R2	; 8251A
SENDBRK:
	MVI	A,3FH		; DTR normal, send break tone
	JMP	GOODBYE+2	; Send the break tone
	 ENDIF			; MD3R1 OR MD3R2
;
;
; This routine sets a 300 ms break tone for the Z80 SIO
;
	 IF	MDHDA OR MDHDP	; Z80 SIO
SENDBRK:
	MVI	A,0F8H		; DTR normal, send break tone
	STA	GOODBYE1+1	; Reset value temporarily
	CALL	GOODBYE		; Send the break tone
	MVI	A,78H		; Restore original value
	STA	GOODBYE1+1
	RET
	 ENDIF			; MDHDA OR MDHDP
;.....
;
;
; This routine sets DTR low for 300 ms to disonnect the phone
;
	 IF	MD3R1 OR MD3R2	; 8251A
GOODBYE:
	MVI	A,3DH		; Send break, turn off DTR
	OUT	MDCTL1		; Send to status port
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,37H		; Normal send/receive with DTR
	OUT	MDCTL1		; Send to status port
	RET
	 ENDIF			; MD3R1 OR MD3R2
;
	 IF	MDHDA OR MDHDP	; Z80 SIO
GOODBYE:
	LDA	BSPRT
	MOV	C,A
	INR	C
	MVI	A,5
	DW	79EDH		; Z80 opcode for  OUT  (C),A
;
GOODBYE1:
	MVI	A,78H		; Turn off DTR
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	B,3		; Wait for 300 ms
	PUSH	B
	CALL	J$TIMER
	POP	B
	MVI	A,5
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	A,0E8H		; Restore normal, 8 bits, DTR on, etc.
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	POP	B		; Restore the stack
	RET
	 ENDIF			; MDHDA OR MDHDP
;
;-----------------------------------------------------------------------
;
; MD-2/3 ROM 1.x initialization
;
	 IF	MD3R1		; 8251A
INITMOD:
	MVI	A,087H		; Insure out of mode
	OUT	MDCTL1		; Modem status port
	OUT	MDCTL1		; Slight extra delay
	MVI	A,40H		; Initialize USART
	OUT	MDCTL1		; Modem status port
;
INITMOD1:
	MVI	A,17H		; DTR, RCV, XMT, error reset
	OUT	MDCTL1		; Modem status port
	IN	MDDATP		; Clear data port
	LDA	MSPEED		; Get the selected value
	CPI	9+1
	JNC	STUPR1		; If invalid, ask for baud, else default
	JMP	GETBAUD
	 ENDIF			; MD3R1
;
;-----------------------------------------------------------------------
;
; MD-2/3 ROM 2.x and 3.x initialization
;
; Makes sure we are ok on the 2nd serial port
;
	 IF	MD3R2
INITMOD:
	MVI	A,087H
	OUT	MDCTL1
	MVI	A,40H
	OUT	MDCTL1
	MVI	A,4EH
	OUT	MDCTL1
	MVI	A,17H
	OUT	MDCTL1
;
;
; Sets default baudrate to MSPEED selection on CTC
;
INITMOD1:
	LDA	MSPEED		; Get the selected value
	CPI	9+1
	JNC	STUPR1		; If invalid, ask for baud, else
	JMP	GETBAUD		; set to default
	 ENDIF			; MD3R2
;
;-----------------------------------------------------------------------
;
; Morrow MD-HD initialization
;
	 IF	MDHDA OR MDHDP	; Z80 SIO
INITMOD:
	PUSH	B
	LDA	BSPRT
	MOV	C,A
	INR	C
	MVI	A,0		; Select register 0
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	A,18H		; Throw out of mode
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	A,4		; Select register 4
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	A,44H		; 16x, 1 stop, parity off (44=1, 4C=2)
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	A,3		; Select register 3
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	A,0C1H		; Enable receive
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	A,5		; Select register 5
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MVI	A,0E8H		; Enable send, 'DTR', 'RTS'
	DW	79EDH		; Z80 opcode for  OUT  (C),A
;
	POP	B
	LDA	MSPEED		; Get the selected value
	CPI	9+1
	JNC	STUPR1		; If invalid, ask for baud, else
	JMP	GETBAUD		; set to default
	 ENDIF			; MDHDA OR MDHDP
;.....
;
;
; Setup routine to allow changing modem speed with the SET command.
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate '
;
	 IF	MD3R1
	DB	'(300,1200): ',0
	 ENDIF			; MD3R1
;
	 IF	MD3R2
	DB	'(300,1200,2400,4800,9600): ',0
	 ENDIF			; MD3R2
;
	 IF	MDHDA OR MDHDP
	DB	'(300,1200,2400,4800,9600,19200,P/M,AUX): ',0
	 ENDIF			; MDHDA OR MDHDP
;
	LXI	D,BAUDBUF	; Point to new input buffer
	CALL	J$INBUF
	CALL	J$CRLF
	LXI	D,BAUDBUF+2
;...
;
;
STUPR2:	CALL	J$INLNCP
	DB	'300',0
	JNC	OK300
;
	CALL	J$INLNCP
	DB	'1200',0
	JNC	OK1200
;
	 IF	NOT MD3R1
	CALL	J$INLNCP
	DB	'2400',0
	JNC	OK2400
;
	CALL	J$INLNCP
	DB	'4800',0
	JNC	OK4800
;
	CALL	J$INLNCP
	DB	'9600',0
	JNC	OK9600
	 ENDIF			; NOT MD3R1
;
	 IF	MDHDA OR MDHDP
	CALL	J$INLNCP
	DB	'19200',0
	JNC	OK19200
;
	CALL	J$INLNCP
	DB	'P/M',0
	JNC	OKPM
;
	CALL	J$INLNCP
	DB	'AUX',0
	JNC	OKAUX
	 ENDIF			; MDHDA OR MDHDP
;
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
;-----------------------------------------------------------------------
;
;Baud rate code for MD-2/3 ROM 1.x
;
	 IF	MD3R1
OK300:	MVI	A,1		; MSPEED 300 baud value
	JMP	GETBAUD		; Go load them
;
OK1200:	MVI	A,5		; MSPEED 1200 bps value
	JMP	GETBAUD		; Go load th;em
;
OK2400:	JMP	OK1200		; Doesn't support 2400 bps
;...
;
;
GETBAUD:STA	MSPEED
	MVI	B,4FH		; Divide by 64 for 300 baud
	CPI	1
	JZ	LOADBD
	MVI	B,04EH		; Divide by 16 for 1200 bps (default)
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	MOV	A,B		; Get baudrate byte
	OUT	MDCTL1		; Modem status port
	IN	MDDATP		; Read in any garbage
	RET
	 ENDIF			; MD3R1
;
;-----------------------------------------------------------------------
;
; Common baud rate code for MD-2/3 ROM's 2.x and 3.x and MD-HD
;
	 IF	NOT MD3R1
OK300:	MVI	A,1
	JMP	GETBAUD
;
OK1200:	MVI	A,5
	JMP	GETBAUD
;
OK2400:	XRA	A
	STA	MANUAL		; Reset to maximum auto-speed
	MVI	A,6
	JMP	GETBAUD
;
OK4800:	MVI	A,7
	JMP	GETBAUD
;
OK9600:	MVI	A,8
	JMP	GETBAUD
;
OK19200:MVI	A,9
	 ENDIF
;
;-----------------------------------------------------------------------
;
; Code to swap ports on the MD-HD
;
	 IF	MDHDA OR MDHDP
OKPM:	MVI	A,062H
	STA	BSPRT
	LXI	H,7E51H
	SHLD	BRPRT
	JMP	INITMOD
;
OKAUX:
	MVI	A,070H
	STA	BSPRT
	LXI	H,3E50H
	SHLD	BRPRT
	JMP	INITMOD
	 ENDIF
;
;-----------------------------------------------------------------------
;
; Common baud rate code for MD-2/3 ROM's 2.x and 3.x and MD-HD
;
	 IF	NOT MD3R1
GETBAUD:PUSH	PSW
	LXI	H,BDTAB
	ADD	A		; *2
	MOV	E,A
	MVI	D,0
	DAD	D
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A		; HL = baud rate divisor
	POP	PSW
	JMP	LOADBD
	 ENDIF			; NOT MD3R1
;
;-----------------------------------------------------------------------
;
; Baud rate code for MD-2/3 ROM's 2.x and 3.x
;
	 IF	MD3R2
LOADBD:	STA	MSPEED
	MVI	A,CTCSEL
	OUT	CPORT
	MOV	A,L
	OUT	BPORT
	MOV	A,H
	OUT	BPORT
	RET
	 ENDIF
;
;-----------------------------------------------------------------------
;
; Baud rate code for MD-HD
;
	 IF	(MDHDA OR MDHDP)
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	LDA	BMD
	OUT	MOPORT
	PUSH	B
	LDA	BRPRT
	MOV	C,A
	MOV	A,L
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	MOV	A,H
	DW	79EDH		; Z80 opcode for  OUT  (C),A
	POP	B
	RET
	 ENDIF			;(MDHDA OR MDHDP)
;
;-----------------------------------------------------------------------
;
; Table of baud rate values for MD-2/3 ROM's 2.x and 3.x
;
	 IF	MD3R2
BDTAB:	DW	0		; 110 baud (not supported)
	DW	417		; 300 baud
	DW	0		; 450 baud (not supported)
	DW	0		; 600 baud (not supported)
	DW	0		; 710 baud (not supported)
	DW	104		; 1200 bps
	DW	52		; 2400 bps
	DW	26		; 4800 bps
	DW	13		; 9600 bps
	DW	0		; 19200 bps (not supported)
	 ENDIF			; MD3R2
;
;-----------------------------------------------------------------------
;
; Table of baud rate values for MD-HD
;
	 IF	MDHDA OR MDHDP
BDTAB:	DW	0		; 110 baud (not supported)
	DW	417*2		; 300 baud
	DW	0		; 450 baud (Not supported)
	DW	0		; 600 baud (not supported)
	DW	0		; 710 baud (Not supported)
	DW	104*2		; 1200 bps
	DW	52*2		; 2400 bps
	DW	26*2		; 4800 bps
	DW	13*2		; 9600 bps
	DW	13		; 19200 bps
	 ENDIF			; MDHDA OR MDHDP
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE: Must terminate prior to 0400H
;
	END
