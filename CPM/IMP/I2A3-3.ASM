
; I2AP3-3.ASM - Apple /// overlay file for IMP - 06/01/87
;
;	    6551 I/O with built-in baudrate generator
;
;
; This overlay file adapts the Apple /// SoftCard /// CP/M 2.21 to IMP
; and external modems.	Note that only speeds up to 2400 baud are al-
; lowed since the CP/M-6502 overhead is too great for any faster commun-
; ications.  (I tried 4800 & 9600 but lost too many characters and file
; transfers just did'nt work.)
;
; For those that are interested, this overlay uses the Device Function
; and Status calls built into the BIOS of 2.21 for the express purpose
; of dealing with SOS Drivers directly.  For details, refer to the Soft-
; card /// CP/M 2.21 Technical Description and also the Standard Device
; Drivers Manual.
;
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
;		MLOAD IMP.COM=IMP.COM,I2A3-x.HEX
;
;
;	NOTE TO APPLE /// USERS:
;
;		This overlay assumes that you have configured
;		your DRIVER.SOS file to include the .RS232
;		driver (Version 1.30) to the RD1: and PU1:
;		devices.  You may also use the serial driver
;		for the Serial Card /// in any slot without
;		changes to this overlay.  Just assign the
;		driver to RD1: & PU1:  Also note that you may
;		NOT have an active printer assigned to the LIST
;		device if it uses the same port as the modem.
;
;-----------------------------------------------------------------------
;
; 06/01/87 - Added Break routine.  Exit and	- Douglas Thom
;	     disconnect now drop DTR.
; 10/27/85 - Modified to drop DTR.		- Steve Smith
; 09/13/85 - Written for IMP244.		- Douglas Thom
;
;-----------------------------------------------------------------------
;
YES	EQU	0FFH
NO	EQU	0
;
;-----------------------------------------------------------------------
;
ESC	EQU	'['-40H	; ^[ = Escape
BELL	EQU	'G'-40H	; ^G = Bell character
LF	EQU	'J'-40H	; ^J = Linefeed
NEXTRY	EQU	'K'-40H	; ^K = Try next phone number, abort this try
CR	EQU	'M'-40H	; ^M = Carriage return
CLEARSC	EQU	'Z'-40H	; ^Z = Clear screen, command mode only
EOFCHAR	EQU	'Z'-40H	; ^Z = End of file
;
;
;==================== CUSTOMIZATION EQUATES ============================
;
MDRCV	EQU	1		; Bit to test for receive
MDSND	EQU	0		; Bit to test for send
MDTXE	EQU	0		; Modem send buffer empty
;
;-----------------------------------------------------------------------
;
	ORG	0100H
;
	DS	3	; Skip the data area below
;
; These routines and equates are at the beginning of the program so they
; can be patched by a monitor or overlay file without re-assembling the
; program.
;
MSPEED:	 DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	 DB	YES	; Yes=2400 bps highest speed			104H
HS1200:	 DB	NO	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
CLEAR:	 DB	28	; Clear screen character (ESC not needed)	10AH
;
CLOCK:	 DB	4	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
			; 4 for Apple ///
BYTDLY:	 DB	2	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			; Default time to send character in ter-
			; minal mode file transfer for slow BBS
CRDLY:	 DB	2	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
			; Default time for extra wait after CRLF
			; in terminal mode file transfer
NOFCOL:	 DB	5	; Number of directory columns shown		10EH
TCHPUL:	 DB	'T'	; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;
ADDLFD:	 DB	NO	; Yes=add LF after CR to send file in terminal	110H
			; mode (normally added by remote echo)
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
;.....
;
; Handles in/out ports for data and status
;
I$MDCTL1: JMP	RCVCTL1		; In modem control port 		11FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:  JMP	RCVCTL2		;					129H
	  DB	0,0,0,0,0,0,0	;					12CH
;
I$MDDATP: JMP	RCVDATP		; in modem data port			133H
	  DB	0,0,0,0,0,0,0	;					146H
;
O$MDDATP: JMP	SNDDATP		; Out modem data port			13DH
	  DB	0,0,0,0,0,0,0	; Spares if needed			140H
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
;
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:JMP	EXITPRG
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
MANUAL:	  DB	0		; For manual selection flag		19BH
J$300:	  JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:	  JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:	  JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;
LOGPTR:	  DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	  CALL	J$ILPRT		; Display the following line		1A7H
	  DB	'Apple /// CP/M 2.21 (RS232 Port)  '	;		1AAH
;
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
LOGON:	DB	'Hello, from an Apple /// user',CR,0
;
;================== Apple /// Specific Routines ========================
;
PUNCH	EQU	0DA12H		; BIOS vector for Punch routine
READER	EQU	0DA15H		; BIOS vector for Reader routine
ZDVMGR	EQU	0DA36H		; BIOS vector for Device Manager Call
DVSTAT	EQU	0DA3FH		; BIOS vector for Device Status Call
DVFUNC	EQU	0DA42H		; BIOS vector for Device Function Call
DEVTAB	EQU	0DF00H		; Device table location
BUFFER	EQU	0E400H		; Control Buffer
DEVICE	EQU	00004H		; Logical Device number
IOBYTE	EQU	00003H		; IOBYTE location
;.....
;
;
; This routine sends a 466 ms break signal.  Refer to the Apple ///
; Standard Device Drivers Manual (page 127) for details on the
; command.
;
SENDBRK:
	DB	0D9H		; Use Z80 alt. registers to save...
	LXI	H,BUFFER	; Point to Buffer
	MVI	M,2		; Break time (233ms * 2)
	LDA	CONFIG		; Get Device Configuration Number
	MOV	C,A		; put it in 'C' register
	MVI	B,3		; Transmit Break
	CALL	DVFUNC		; Device Function call (6502)
	DB	0D9H		; Restore Registers
	RET			; Return to caller...
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the phone
;
GOODBYE:
	MVI	A,7		; SOS Device close command
	CALL	DVMGR		; To set DTR low
	MVI	B,3		; Wait for 300 ms
	CALL	J$TIMER
	MVI	A,6		; SOS Device open command
	CALL	DVMGR		; To open the .RS232 driver again
	CALL	ZRESET		; Reset driver to bring DTR back up
	JMP	SPDCHK		; Restore modem speed
;.....
;
;
INITMOD:
	LDA	DEVTAB+DEVICE	; Get CP/M Configuration Number
	STA	CONFIG		; Save it for future use
	MOV	C,A
	MVI	B,1		; Get .RS232 Parmeters
	CALL	DVSTAT		; Do it....
	LXI	H,BUFFER+1	; Point to Baud Rate
	MOV	A,M		; Save it way for future use
	STA	OLDBAUD
	LDA	IOBYTE		; Get current IO Byte
	STA	IOSAVE		; Save it away for lager
	ORI	3		; Force Console to CO4:
	STA	IOBYTE
	MVI	A,6		; Open .RS232 driver
	CALL	DVMGR
;
SPDCHK:	LDA	MSPEED		; Get Baud Rate value
	CPI	1		; Is it 300 baud
	JZ	OK300
	CPI	5		; Is it 1200 baud
	JZ	OK1200
	CPI	6		; Is it 2400 baud
	JZ	OK2400
	JMP	STUPR1		; Else ask for Speed
;.....
;
;
DVMGR:	DB	0D9H		; Save Registers in Alt Z80 Registers
	STA	0E8C0H		; SOS Command location
	LDA	CONFIG		; Get CP/M Configuration
	STA	0E8C1H		; Pass to SOS Device Manager
	CALL	ZDVMGR		; Do SOS command
	DB	0D9H		; Restore Registers
	RET
;.....
;
;
EXITPRG:
	LDA	IOSAVE		; Return to CO1:
	STA	IOBYTE
	LDA	OLDBAUD		; Restore original Baudrate
	MOV	B,A		; Stuff it in 'B'
	CALL	LOADBD		; Do it...
	MVI	A,7		; Close up RS232 driver
	CALL	DVMGR		; do it....
	RET
;.....
;
;
RCVCTL1:
	PUSH	B		; Test Modem Input Status
	PUSH	D
	PUSH	H
	MVI	B,3		; Status code 3 (Retrieve Driver Buffer)
	LDA	CONFIG		; Get Driver Number
	MOV	C,A
	CALL	DVSTAT		; Do Device Status Call
	LHLD	BUFFER+6	; Look at Buffer Size
	MOV	A,L
	ORA	H
	JZ	INRDY		; Buffer is not empty....
	MVI	A,01H		; Buffer is empty...
;
INRDY:	POP	H		; Restore Registers
	POP	D
	POP	B
	RET
;.....
;
;
RCVCTL2:
	MVI	A,0		; TBE always true....
	RET
;.....
;
;
RCVDATP:
	PUSH	B		; Read in a Character
	PUSH	D
	PUSH	H
	CALL	READER
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
SNDDATP:
	PUSH	B		; Send out a Character
	PUSH	D
	PUSH	H
	MOV	C,A
	CALL	PUNCH
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
ZRESET:	DB	0D9H		; Use Z80 alt. registers (Save Regs)
	LDA	CONFIG
	MOV	C,A
	MVI	B,0		; Device function reset
	CALL	DVFUNC
	DB	0D9H		; Restore Registers
	RET
;.....
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT		; Print following Message
	DB	'Input Baud Rate (300, 1200, 2400): ',0
	LXI	D,BAUDBUF	; Point to new input buffer
	CALL	J$INBUF
	CALL	J$CRLF
	LXI	D,BAUDBUF+2
;
STUPR2:	CALL	J$INLNCP	; Compare BAUDBUF+2 with Chars. below
	DB	'300',0
	JNC	OK300		; Go if Match
	CALL	J$INLNCP
	DB	'1200',0
	JNC	OK1200
	CALL	J$INLNCP
	DB	'2400',0
	JNC	OK2400
	CALL	J$ILPRT		; All matches failed, tell user
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1
;.....
;
;
OK300:	MVI	A,1		; Load MSPEED 300 baud value
	MVI	B,BD300		; Get Baudrate Value
	JMP	LOADBD
;
OK1200:	MVI	A,5		; Load MSPEED 1200 baud value
	MVI	B,BD1200	; Get Baudrate Value
	JMP	LOADBD
;
OK2400:	XRA	A
	STA	MANUAL		; Reset to maximum auto-speed
	MVI	A,6		; Load MSPEED 2400 baud value
	MVI	B,BD2400	; Get Baudrate Value
;.....
;
;
LOADBD:	STA	MSPEED		; Save Modem Speed
	MOV	A,B
	STA	A3BD		; Stuff Baud into Driver...
	LXI	B,14		; Move 14 bytes
	LXI	H,RS232		; Move Control Parameters into
	LXI	D,BUFFER	; Device Driver Buffer
	DB	0EDH,0B0H	; LDIR instruction
	LDA	CONFIG		; Get Configuration Number
	MOV	C,A
	MVI	B,1		; Set Control Parmeters
	CALL	DVFUNC		; do it....
	RET
;.....
;
;
IOSAVE:		DB	0	; Temp storage for IOBYTE
CONFIG:		DB	0	; Configuration Number
OLDBAUD:	DB	8	; Storage for Original Baudrate
;.....
;
;
RS232:	DB	0FH		; Buffer size
A3BD:	DB	8		; 2400 bps baud rate value
	DB	0,0,0,0,0
	DB	013H,011H
	DB	0DFH,084H
	DB	050H,0,080H
;.....
;
;
; Table of baudrate values
;
BD300	EQU	6		; 300 baud
BD1200	EQU	8		; 1200 bps
BD2400	EQU	10		; 2400 bps
;
BAUDBUF:
	DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;.....
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE: Must terminate by 0400H
;
	END
