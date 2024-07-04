
; I2OV-3.ASM - Osborne Vixen/OCC4 overlay file for IMP - 06/01/87
;
;		8251A IO and 8155 baudrate generator
;
; The Osborne Vixen/OCC4 requires that pin 5 on its serial port be con-
; nected to an RS-232 pin which has a "SPACE" signal present.  This sig-
; nal can be found on most RS-232 modems as pin 5 (CLEAR TO SEND - CTS).
; The Vixen is already wired as "DCE" not "DTE", so no cross-wiring from
; 2 and 3 is needed as in most computers.  The cable between the Vixen
; OCC4 and your modem should contain the following.  The optional wire
; is not needed for use with IMP, but would be needed if used with BYE3
; for RCPM use:
;
;	       VIXEN	      MODEM
;		 2 ------------ 2	TXD data out
;		 3 ------------ 3	RXD data in
;		 5 ------------ 5	CTS, required
;		 6 ------------ 8	(*)
;		 7 ------------ 7	ground
;		20 ------------ 20	DTR
;
;	(*) Required for BYE3 or BYE5, unnecessary otherwise
;
;-----------------------------------------------------------------------
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
; 08/07/85  Diagram clarified, no other change	- Roy Robinson
; 07/17/85  Adapted for use with IMP		- Irv Hoff
; 02/10/85  Modified for Osborne Vixen/OCC-4	- Roy Robinson
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
; Values shown are for a 8251A
;
PORT	EQU	30H	; Your base port (data or status)
MDCTL1	EQU	PORT+1	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MDRCV	EQU	02H	; Modem receive ready
MDSND	EQU	01H	; Modem send ready bit
MDTXE	EQU	05H	; Modem send buffer empty, holding buffer empty
;
MDMODE	EQU	82H	; Insures 8251 is out of mode with DTR high
MDRSET	EQU	42H	; Resets USART for additional commands
MDSET1	EQU	4EH	; 1 stop bit, no parity, 8 bits, x16
MDSET2	EQU	0CEH	; 2 stop bits, no parity, 8 bits, x16
MDCOM	EQU	37H	; Reset error flags, RTS, Rxd, DTR, Txd on
;
AJUMP	EQU	0C3H	; JUMP instruction opcode
BDOS	EQU	0005H	; Address of BDOS entry point in 1st page of RAM
BIOS	EQU	0001H	; Pntr address of CP/M warm boot jump in BIOS
EXITCPM	EQU	2C80H	; Address of CP/M warm boot jump in EXIT routine
INTVEC	EQU	0EFFEH	; Address of interrupt vector to first interrupt
			;   service routine
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
MSPEED:	 DB	6	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	 DB	YES	; Yes=2400 bps highest speed			104H
HS1200:	 DB	NO	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
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
I$MDCTL1: DI			;					11FH
	  IN	MDCTL1		;					120H
	  EI			;					122H
	  RET			; IN modem control port 		123H
	  DB	0,0,0,0,0	; Spares if needed			124H
;
I$MDTXE:  DI			;					129H

	  IN	MDCTL1		; (Needed for SIO or DART register 1	12AH
	  EI			;					12CH
	  RET			;					12DH
	  DB	0,0,0,0,0	;					12EH
;
I$MDDATP: DI			;					13DH
	  IN	MDDATP		;					13EH
	  EI			;					140H
	  RET			;					141H
	  DB	0,0,0,0,0	; Spares if needed			142H
;
O$MDDATP: EI
	  OUT	MDDATP		;					147H
	  DI
	  RET			; OUT modem data port			149H
	  DB	0,0,0,0,0	; Spares if needed			14AH
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
J$EXITVEC:JMP	RSTINT		;					159H
				;					15AH
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
	  DB	'Version for Osborne Vixen/OCC 4',CR,LF	;		1AAH
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
LOGON:	DB	'Greetings from an Osborne Vixen user',CR,LF,0
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
OUTMDCTL1:
	DI
	OUT	MDCTL1
	EI
	RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
INITMOD:
	MVI	C,7		; Use BDOS to obtain current IOBYTE
	CALL	BDOS		;
	STA	OLDIOB		; Save old IOBYTE
	ANI	3FH		;
	ORI	80H		; Make CEN: port new LST: device
	MOV	E,A
	MVI	C,8
	CALL	BDOS		; Use BDOS to place new IOBYTE in first
				;   page of memory
;
	 DI			; DISABLE interrupts
	LHLD	INTVEC		; Get serial port interrupt processor
				;   address
	SHLD	OLDVEC		; Save serial port interrupt processor
				;   address
	DCX	H
	DCX	H
	DCX	H		; HL = next interrupt processor address
	SHLD	INTVEC		; Now have first interrupt processor
				;   rather than second
;
;
; Initialize the interrupt vector system
;
	LHLD	BIOS		; Find start of BIOS
	MVI	L,3CH		; Displacement of baud rate byte from
				;   start of BIOS
	STA	OLDBAUD		; Save original baud rate byte
;
	MVI	L,3BH		; Displacement of 8251 mode byte from
				;   start of bios
	MOV	A,M		; Old mode byte set by ROM is 2sb, no
				;   parity, 8db, x16 clock
	STA	OLDMODE		; Save original 8251 mode byte
;
	MOV	B,L
	MVI	A,MDSET1	; 1 sb, np, 8 db, x16 clock mode byte
	CALL	IORESET		; Use extended bios jump to reset 8251
	MVI	A,MDCOM		; RTS, DTR, Txd, Rxd on
	OUT	31H		; Send it to 8251 control port
	MVI	A,3		; Select 8155 port C
	OUT	21H		;
	IN	28H		; Get miscellaneous information byte
	STA	OLDMSC		; Save miscellaneous information byte
;
;
; Disable ring detect interrupt, Rxd interrupt, Txd
;
	ORI	0FH
	MOV	E,A		; Interrupt, enable internal clock
	MVI	A,3
	OUT	21H		; Select 8155 port C
	MOV	A,E
	OUT	28H		; Send new control byte to 8155 port c
	 EI			; RESTORE interrupts
;
;
; Set requested baudrate then finished with initialization
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
	CPI	9		; 19200 bps
	JZ	OK19200
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
;-----------------------------------------------------------------------
;
; Reset original interrupt vectors upon EXIT from program
;
RSTINT:	LDA	OLDIOB		; Get original IOBYTE
	MVI	C,8
	MOV	E,A		; Use BDOS to restore original IOBYTE
	CALL	BDOS
;
	 DI			; DISABLE interrupts
	MVI	A,15H		; RTS, DTR off
	LHLD	OLDVEC		; Get original interrupt service address
	SHLD	INTVEC		; Restore orig interrupt service address
	MVI	A,3		; Select 8155 port C
	OUT	21H
	IN	28H		; Get miscellaneous information byte for
				;   controlling interrupt lines
	ANI	030H		; Zero the least significant four bits
	MOV	E,A
	LDA	OLDMSC		; Get original misc. 8155 control byte
	ANI	0FH		; Zero the most significant four bits
	ORA	E		; Combine everything
	MOV	E,A		; Store temporarily
;
	MVI	A,3
	OUT	21H		; Select 8155 port C, again
	MOV	A,E		; Store the value held in "E"
	OUT	28H		; Restore original 8155 control byte
	 EI			; RESTORE interrupts
;
	MVI	B,3CH
	LDA	OLDBAUD		; Restore original baud rate byte
	CALL	IORESET		; Do an 8251 reset
;
	MVI	B,3BH
	LDA	OLDMODE		; Restore original mode byte
	CALL	IORESET		; Do an 8251 reset
	RET
;.....
;
;
IORESET:
;  SUBROUTINE WHICH EXECUTES A MASTER RESET FOR 8251.
;  8251 RESET IS A BIOS FUNCTION IN VIXEN EXTENDED BIOS
;
;	ENTRY:
;	A	=	BYTE VALUE TO BE REPLACED IN BIOS
;			(MODE BYTE OR BAUD RATE BYTE)
;
;	B	=	HEX DISPLACEMENT FROM BASE OF BIOS
;			FOR MODE BYTE OR BAUD RATE BYTE
;			(MODE BYTE = 3BH)
;			(BAUD RATE BYTE = 3CH)
;
;	EXIT:
;	NONE
;
	LHLD	BIOS		; Find base of BIOS
	MOV	L,B
	MOV	M,A
	MVI	L,36H		; Displacement in BIOS for 8251 reset
				;   function
	SHLD	EXTFUN
	CALL	BIOSFUNC	; Subroutine call of BIOS 8251 reset
				;   function
	RET
;.....
;
OLDIOB:	  DB	0		; Orig	IOBYTE
OLDMSC:	  DB	0		; Orig misc. ctl byte for 8155 port C
OLDVEC:	  DB	0,0		; Orig interrupt service vector
OLDMODE:  DB	1		; Orig 8251 mode byte from BIOS
OLDBAUD:  DB	1		; Orig baud rate byte for 8251 from BIOS
BIOSFUNC: DB	AJUMP		; Absolute jump to following memory addr
EXTFUN:	  DB	0,0		; Bios extended function address
;
;-----------------------------------------------------------------------
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
OK300:	MVI	A,1		; MSPEED 300 baud value
	MVI	B,BD300		; Get 300 baud parameters in 'HL'
	JMP	LOADBD		; Go load them
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
	JMP	LOADBD
;
OK19200:MVI	A,9
	MVI	B,BD19200
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	MOV	A,B		; Get baudrate byte
	MVI	B,3CH
	JMP	IORESET		; Used extended BIOS function to reset
;.....				;   baud rate on 8251
;
;
; Table of baudrate parameters
;
; Baudrate table (16 different rates are available)
;
BD300	EQU	6		; 300 baud
BD1200	EQU	8		; 1200 bps
BD2400	EQU	11		; 2400 bps
BD4800	EQU	13		; 4800 bps
BD9600	EQU	15		; 9600 bps
BD19200	EQU	16		; 19200 bps
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
