
; I2SY-3.ASM - Sayno MBC-1000/1100/1200/1250 overlay for IMP - 06/01/87
;
;		USES 8251A I/O (no baudrate generator)
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Sanyo MBC-1000/1100/1200/1250  (no baudrate gen-
; erator) to IMP.
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
;		MLOAD IMP.COM=IMP.COM,I2SY-x.HEX
;
;-----------------------------------------------------------------------
;			   MBC-1000 mod
;
; This modification adapts the Sanyo MBC-1000 computer to use various
; modem speeds, including 300-1200-2400 bps.  It requires the following
; hardware changes to use the spare 8253 timer on IC4.	This is on the
; serial I/O board.
;
; NOTE: The Sayno MBC-1000 can be used at 300/1200 bps without these
;	changes, if you leave the on-board jumper set to 1200 bps.  Then
;	(as with the other models) the unit will come up at 1200 bps and
;	the SET command may be used to select 300 if desired.
;
;		1. Cut etch from IC18 Pin 1 to JP2 Pin 8.
;		2. Install jumper from IC18 Pin 1 to IC4 Pin 18.
;		3. Install jumper from IC4 Pin 17 to JP2 Pin 8.
;		4. Install jumper from IC4 Pin 16 to IC4 Pin 14.
;		5. Move jumper strap to JP2 Pin 8 for programmable
;		     baud rate, other pins (1-7) can still be used
;		     for standard baud rate selections.
;		6. Hardware modification is now complete.
;
;					- Hardware mods by Bob Sandel
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.			- Irv Hoff
; 08/04/86  Added hardware change for MBC-1000	- Irv Hoff
; 02/04/86  Written to work with IMP		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
MOD1000	EQU	NO		; MBC-1000 with hardware mods, above
MBC1000	EQU	YES		; Normal MBC-1000, jumper set for 1200
MBC1100	EQU	NO		; MBC-1100, jumper set for 1200
MBC1200	EQU	NO		; MBD-1200, jumper set for 1200
;
;
	 IF	MBC1000	OR MOD1000
PORT	EQU	0A4H
	 ENDIF
;
	 IF	MBC1100
PORT	EQU	0DCH
	 ENDIF
;
	 IF	MBC1200
PORT	EQU	0ECH
	 ENDIF
;
;
; Values shown are for a 8251A
;
MDDATP	EQU	PORT	; Modem data port
MDCTL1	EQU	PORT+1	; Modem control port
MDRCV	EQU	02H	; Modem receive ready
MDSND	EQU	01H	; Modem send ready bit
MDTXE	EQU	05H	; Modem send buffer empty, holding buffer empty
;
;
MDMODE	EQU	82H	; Insures 8251 is out of mode with DTR high
MDRSET	EQU	42H	; Resets USART for additional commands
MDCOM	EQU	17H	; Reset error flags, RCV, DTR, TX ready
;
;
	 IF	MOD1000
BDPORT	EQU	0A2H	; 8253 baud rate port
BTPORT	EQU	0A3H	; 8253 timer port
	 ENDIF		; MOD1000
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
PROMODM: DB	NO	;*Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
;
CLEAR:	 DB	1AH	; Clear screen character (ESC not needed)	10AH
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
BRKCHR:	 DB	'Q'	; Send a break tone				11DH
NODTR:	 DB	NO	; YES if no DTR and need ATH0 to disconnect	11EH
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: IN	MDCTL1		;					11FH
	  RET			; IN modem control port 		121H
	  DB	0,0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:  IN	MDCTL1		; (Needed for SIO or DART register 1	129H
	  RET			;					12BH
	  DB	0,0,0,0,0,0,0	;					12CH
;
I$MDDATP: MVI	A,37H		;					133H
	  OUT	MDCTL1		;					135H
	  IN	MDDATP		;					137H
	  RET			;					139H
	  DB	0,0,0		; Spares if needed			13AH
;
O$MDDATP: OUT	MDDATP		;					13DH
	  RET			; OUT modem data port			13FH
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
	  DB	'Version for Sayno computer with external modem' ;	1AAH
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
LOGON:	DB	'This is a Sanyo computer...'
	DB	CR,LF,0
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
	OUT	MDCTL1		; Send to status port
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,37H		; Normal send/receive with DTR
	OUT	MDCTL1		; Send to status port
	RET
;.....
;
;
; Sets 8251A to 8 bits, DTR, RCV and TX ready
;
INITMOD:LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
;
	 IF	MOD1000
	CPI	6
	JZ	OK2400
	CPI	8
	JZ	OK9600
	CPI	9
	JZ	OK19200
	 ENDIF			; MOD1000
;
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200'
;
	 IF	NOT MOD1000
	DB	'): ',0
	 ENDIF			; NOT MOD1000
;
	 IF	MOD1000
	DB	', 2400, 9600, 19200): ',0
	 ENDIF			; MOD1000
;
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
;
	 IF	MOD1000
	CALL	J$INLNCP
	DB	'9600',0
	JNC	OK9600
	CALL	J$INLNCP
	DB	'19200',0
	JNC	OK19200
	 ENDIF			; MOD1000
;
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
;
	 IF	NOT MOD1000
OK300:	MVI	A,1		; MSPEED 300 baud value
	MVI	B,DV64		; Get 300 baud parameters in 'HL'
	JMP	LOADBD		; Go load them
;
OK1200:	MVI	A,5
	MVI	B,DV16
	JMP	LOADBD
;
OK2400:	JMP	OK1200		; Horizon does not support 2400 bps
	 ENDIF			; NOT MOD1000
;
;
	 IF	MOD1000
OK300:	MVI	A,1
	MVI	B,DV16
	MVI	C,BD300
	JMP	LOADBB

OK1200:	MVI	A,5
	MVI	B,DV16
	MVI	C,BD1200
	JMP	LOADBB

OK2400:	XRA	A
	STA	MANUAL
	MVI	A,6
	MVI	B,DV16
	MVI	C,BD2400
	JMP	LOADBB
;
OK9600:	MVI	A,8
	MVI	B,DV16
	MVI	C,BD9600
	JMP	LOADBB
;
OK19200:MVI	A,9
	MVI	B,DV16
	MVI	C,BD19200
;
LOADBB:	PUSH	PSW		; Save the MSPEED value
	MVI	A,96H		; Square wave output for 8253, Cntr 2
	OUT	BTPORT
	MOV	A,C
	OUT	BDPORT		; Set the baudrate
	POP	PSW		; Get the baudrate back
	 ENDIF			; MOD1000
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	MVI	A,MDMODE	; Insure 8251 is out of mode
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDRSET	; Reset the 8251A for new command
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MOV	A,B		; No parity, 8 bits, 1 stop x16 (or x64)
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDCOM		; Error reset, RCV, DTR, TX ready
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	IN	PORT		; Clear data port
	XRA	A		; Clear the input
	RET
;.....
;
;
; Table of baudrate parameters
;
DV64	EQU	4FH		; 300 baud, x64
DV16	EQU	4EH		; 1200 bps, x16
;
	 IF	MOD1000
BD300	EQU	64		; 19200/300
BD1200	EQU	16		; 19200/1200
BD2400	EQU	8		; 19200/2400
BD9600	EQU	2		; 19200/9600
BD19200	EQU	1		; 19200/19200
	 ENDIF			; MOD1000
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE: Must terminate by 0400H
;
	END
