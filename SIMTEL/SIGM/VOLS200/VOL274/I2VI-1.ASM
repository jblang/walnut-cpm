
; I2VI-1.ASM  -  Visual 1050 overlay for IMP  -  02/07/86
;
;	    USES 8251A I/O and 8253 ?? baudrate generator
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Visual 1050 computer to IMP.COM.
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
;		MLOAD IMP.COM=IMP.COM,I2VI-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 10/27/85 - Written to work with IMP, adapted portions of M7VI-2.ASM.
;					- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
BDOS	EQU	0005H
RDRIN	EQU	3		; Reader input function
PNCHOUT	EQU	4		; Punch output function
GETIO	EQU	7		; Get I/O byte
SETIO	EQU	8		; Set I/O byte
DIRBIOS	EQU	50		; Direct BIOS call
;
;
; Values shown are for a 8251A
;
PORT	EQU	8CH	; Your base port (data or status)
MDCTL1	EQU	PORT+1	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MDRCV	EQU	02H	; Modem receive ready
MDSND	EQU	01H	; Modem send ready bit
MDTXE	EQU	05H	; Modem send buffer empty, holding buffer empty
;
BDPORT	EQU	92H	; Port for setting baudrate
;
MDMODE	EQU	82H	; Insures 8251 is out of mode with DTR high
MDRSET	EQU	42H	; Resets USART for additional commands
MDSET1	EQU	4EH	; 1 stop bit, no parity, 8 bits, x16
MDSET2	EQU	0CEH	; 2 stop bits, no parity, 8 bits, x16
MDCOM	EQU	17H	; Reset error flags, RCV, DTR, TX ready
;
;
; Table of baudrate parameters
;
BD300	EQU	4F00H
BD1200	EQU	4E00H
BD2400	EQU	4E04H
BD9600	EQU	4E08H
BD19200	EQU	4E0CH
;.....
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
	ORG	0100H
;
;
	DS	3		; Skip the data area below
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
;
CLEAR:	 DB	1AH	; Clear screen character (ESC not needed)	10AH
CLOCK:	 DB	37	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
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
IGNRCTL: DB	NO	; Yes=CTL-chars above ^M not displayed		113H
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
SPARE1:	 DB	0	; For future development			11DH
NODTR:	 DB	NO	; Yes if no DTR and need +++ to disconnect	11EH
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: RET			; Status port not used			11FH
	  DB	0,0,0,0,0	; Spares if needed			120H
	  DB	0,0,0,0		; Spares if needed			125H
;
I$MDTXE:  RET			; (Needed for SIO or DART register 1	129H
	  DB	0,0,0,0,0	;					12AH
	  DB	0,0,0,0		;					12FH
;
I$MDDATP: JMP	BDOS3		;					133H
	  DB	0,0,0,0,0,0,0	; Spares if needed			136H
;
O$MDDATP: JMP	BDOS4		;					13DH
	  DB	0,0,0,0,0,0,0	; Spares if needed			140H
;.....
;
;
A$MDRCV:  RET			; BDOS7 tests receive ready		147H
	  DB	0,0		; Spares if needed			148H
;
C$MDRCV:  JMP	BDOS7		;					14AH
;
A$MDSND:  RET			; BDOS8 tests send ready		14DH
	  DB	0,0
;
C$MDSND:  JMP	BDOS8		; BDOS8 checks for send ready		150H
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
	  DB	'Version for Visual 1050 modem port 8CH' ;		1AAH
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
LOGON:	DB	'This is a Visual 1050 Computer....  ',0
;
;-----------------------------------------------------------------------
;
; This routine sets DTR low for 300 ms to disonnect the phone
;
GOODBYE:MVI	B,'S'-40H	; X-off to stop host if needed
	CALL	J$SNDCHR
	MVI	B,1		; Wait a moment to let it react
	CALL	J$TIMER
	MVI	A,3DH		; Send break, turn off DTR
	CALL	SETMCTL		; Send to status port
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,37H		; Normal send/receive with DTR
	JMP	SETMCTL		; Send to status port, finished
;.....
;
;
INITMOD:LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	CPI	6		; 2400 bps
	JZ	OK2400
	CPI	8		; 9600 bps
	JZ	OK9600
	CPI	9		; 19200
	JZ	OK19200
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
; The following routines replace direct modem port I/O with BDOS calls.
; The Visual 1050 BIOS uses interrupt-driven I/O with ring buffers.
; This solves the problem of losing modem input while the console dis-
; play does a carriage return.
;
; Check for input character (receive ready)
;
BDOS7:	PUSH	B		; Save the registers
	MVI	C,GETIO		; BDOS function number
	JMP	BDOS78		; Common routine for BDOS 7 & 8
;
;
; Check for output character (send ready)
;
BDOS8:	PUSH	B		; Save the registers
	MVI	C,SETIO		; BDOS function number
;
BDOS78:	PUSH	D
	PUSH	H
	CALL	BDOS
	POP	H		; Restore the registers
	POP	D
	POP	B
	ORA	A		; Bdos returns A=0 if not ready
	JZ	CLRZ		; Return Z flag off if not ready
	XRA	A		; Set Z flag if ready
	RET
;
CLRZ:	INR	A		; Clear Z flag (make a non-zero)
	RET
;.....
;
;
; Input a character from modem via BIOS ring buffer
;
BDOS3:	PUSH	B		; Save the registers
	PUSH	D
	PUSH	H
	MVI	C,RDRIN		; BDOS function number
	CALL	BDOS
	POP	H		; Restore the registers
	POP	D
	POP	B
	RET			; Input character is in 'A' register
;.....
;
;
; Ouput a character to modem via BIOS ring buffer
;
BDOS4:	PUSH	B		; Save the registers
	PUSH	D
	PUSH	H
	MVI	C,PNCHOUT	; BDOS function number
	MOV	E,A		; Character to output must be in 'E'
	CALL	BDOS
	POP	H		; Restore the registers
	POP	D
	POP	B
	RET
;.....
;
;
; The Visual 1050 BIOS keeps the current value of the modem control
; register in a special byte.  We must modify this byte whenever we
; change the value of this register, or the BIOS will clobber it when-
; ever it gets an interrupt from the modem port.
;
SETMCTL:PUSH	H
	LHLD	RSPAR		; Address of BIOS byte
	MOV	M,A		; Save new value there
	OUT	MDCTL1		; Output to modem control register
	POP	H
	RET
;.....
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, 2400, 9600, 19200): ',0
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
	CALL	J$INLNCP
	DB	'19200',0
	JNC	OK19200
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
OK300:	MVI	A,1
	LXI	H,BD300
	JMP	LOADBD
;
OK1200:	MVI	A,5
	LXI	H,BD1200
	JMP	LOADBD
;
OK2400:	XRA	A
	STA	MANUAL		; Reset to maximum auto-speed
	MVI	A,6
	LXI	H,BD2400
	JMP	LOADBD
;
OK9600:	MVI	A,8
	LXI	H,BD9600
	JMP	LOADBD
;
OK19200:MVI	A,9
	LXI	H,BD19200
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	SHLD	STASPD
	MVI	A,3FH		; Get byte to enable interrupts
	OUT	9DH		; Enable them...
;
;
; The Visual 1050 provides a special function which returns the address
; of the byte where the BIOS keeps the current value of the modem con-
; trol register.  We must modify this byte whenever we change the value
; of this register, or the BIOS will clobber it whenever it gets an in-
; terrupt from the modem port.
;
	LXI	D,BIOSPB	; Parameter block for BIOS call
	MVI	C,DIRBIOS	; BDIS function for direct BIOS call
	CALL	BDOS
	SHLD	RSPAR		; Save the returned address
;
;
; Sets 8251 to 8 bits, DTR, RCV and TX ready
;
	MVI	A,MDMODE	; Insure 8251 is out of mode
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDRSET	; Reset the 8251A for new command
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
;
;
; Set the 8251A to x16 or x64
;
	LDA	STASPD		; Get the x16 or x64 value
	OUT	MDCTL1		; Modem status port (mode word)
	MVI	A,MDCOM		; DTR, RCV, XMT, error reset
	CALL	SETMCTL		; Modem status port
;
;
; Now set the baud rate
;
	LDA	STASPD+1	; Get the timer speed
	STA	BAUD+1
	IN	BDPORT		; Get what was there
	ANI	0F3H		; Clear out the old baud rates
;
BAUD:	ORI	0		; Set new default to 1200
	OUT	BDPORT		; New baud rate now set
	RET
;.....
;
;
; Data area
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
BIOSPB:	DB	30,3
RSPAR:	DB	0,0		; Address of BIOS
STASPD:	DB	0,0		; Store the requested baud rate temp.
;.....
;
;			       end
;-----------------------------------------------------------------------
;
;NOTE:	Must terminate by 0400H
;
	END
