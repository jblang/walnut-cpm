
; I2CP-2.ASM - Overlay file for the CompuPro Interfacer 3/4 - 06/01/87
;
;	    2651 I/O with built-in baudrage generator
;
; The Interfacer board uses the 2651 I/O.  This has a peculiarity that
; prevents its proper use if you hook pin 8 (DCD) of the modem to pin 8
; (DCD) of the Interfacer board.  You should instead hook pin 8 of the
; modem (DCD) to (DSR) on the Interfacer board.  To further complicate
; the picture, CompuPro uses an unique wiring they refer to as "master"
; or "slave setting".  Normally the board is delivered with the serial
; ports hooked as "slave", which makes (DSR) pin 20 instead of the con-
; ventional pin 6 as on most RS-232 DB-25 connectors.	It then makes
; (DTR) pin 6 instead of conventional pin 20.  (See page 14 of the In-
; terfacer 3 manual or page 20 of the Interfacer 4 manual for additional
; information on this subject.	The schematic below is shown for both
; configurations.
;
; (For interest, the newer version of the 2561 is called the 2661.  It
; came out in 1981, but has this same bug the 2651 has.  That chip is
; used in the Heath/Zenith-100 series computers.  The 2651 has another
; serious bug, if selecting other than 1 stop pulse, it must receive an
; incoming signal with the same (or more) stop pulses.	Fortunately few
; people need 1-1/2 or 2 stop pulses so this bug is rarely a problem.)
;
; NOTE FOR HAYES SMARTMODEM USERS:
; -------------------------------
;	In the past people using the Hayes Smartmodem 1200 and the
;	Interfacer board have complained they had to put SW6 up to
;	use with BYE5 but then had to put it down to use with IMP,
;	MDM7,MES or other autodial modem programs.  With the con-
;	figuration below, SW6 can be left in whatever position the
;	user prefers (up, for BYE5) and this will have no effect on
;	the normal use of IMP, MEX or MDM7.
;
;
; If using "slave" mode:
; ---------------------
;	MODEM=DCE	INTERFACER	(Slave mode)
;
;	TXD	2  -->	3	RXD	received data
;	RXD	3  <--	2	TXD	tranmitted data
;	SG	7  ---	7	SG	signal ground
;	DCD	8  -->	20 *	DSR	data set ready (carrier)
;	DTR	20 <--	6  *	DTR	data terminal ready
;
;
; If using "master" mode
; ----------------------
;	MODEM=DCE	INTERFACER	(as Master)
;
;	TXD	2  -->	2	RXD	received data
;	RXD	3  <--	3	TXD	tranmitted data
;	SG	7  ---	7	SG	signal ground
;	DCD	8  -->	6	DSR	data set ready (carrier)
;	DTR	20 <--	20	DTR	data terminal ready
;
;					- Notes by Irv Hoff
;
;-----------------------------------------------------------------------
;
; This overlay adapts IMP.COM to the CompuPro Interfacer 3/4 serial
; card using the 2651 USART.  If using a 6 MHz clock 1-2 wait states may
; be needed to keep from dropping characters.  Note: This overlay can be
; modified to work with the Apple CPS Multifunction card which uses the
; same 2651 USART.
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
;		MLOAD IMP.COM=IMP.COM,I2CP-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.  Added information on wiring the modem
;	    cable			- Irv Hoff
;
; 05/07/87  Improved the GOODBYE routine, added information on wiring
;	    the modem cable.		- Irv Hoff
; 10/27/85  Written to work with IMP	- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
PORT	EQU	010H	; Modem data port for Interfacer 3 or 4 cards
MDCTL1	EQU	PORT+1	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MDRCV	EQU	02H	; Modem receive ready
MDSND	EQU	01H	; Modem send ready bit
MDTXE	EQU	05H	; Modem send buffer empty, holding buffer empty
CHIP	EQU	6	; Selects slave mode (users 6 or 7)
UPORT	EQU	PORT+7	; User select port (6 and 7 are slave mode)
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
I$MDCTL1: MVI	A,CHIP		; Select correct user port		11FH
	  OUT	UPORT		;					121H
	  IN	MDCTL1		;					123H
	  RET			;					125H
	  DB	0,0,0		;					126H
;
I$MDTXE:  MVI	A,CHIP		; Select correct user port		129H
	  OUT	UPORT		;					12BH
	  IN	MDCTL1		;					12DH
	  RET			;					12FH
	  DB	0,0,0		;					130H
;
I$MDDATP: MVI	A,CHIP		; Select the correct port		133H
	  OUT	UPORT		;					135H
	  IN	MDDATP		;					137H
	  RET			;					139H
	  DB	0,0,0		;					13AH
;
O$MDDATP: PUSH	PSW		;					13DH
	  MVI	A,CHIP		;					13EH
	  OUT	UPORT		;					140H
	  POP	PSW		;					142H
	  OUT	MDDATP		; Out modem data port			143H
	  RET			;					145H
	  DB	0		;					146H
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
	  DB	'Version for CompuPro Interfacer-3 or 4 ' ;		1AAH
	  DB	'(port ',CHIP+'0',')',CR,LF,0
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
LOGON:	  DB	'Nice chatting with you, bye for now.',CR,LF,0
;
;-----------------------------------------------------------------------
;
; This routine sets a 300 ms break tone
;
SENDBRK:
	MVI	A,3FH		; DTR normal, send break tone
	JMP	GOODBYE1
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the phone
;
GOODBYE:
	MVI	A,CHIP		;select chip
	OUT	UPORT
	MVI	A,1DH		; Set RTS, flags, DTR, break
;
GOODBYE1:
	OUT	PORT+3		; Put command register out of mode
	IN	PORT+3		; Make sure it is now clear
	IN	PORT+3		; Try once more
	MVI	B,3		; Turn off DTR for 300 ms
	CALL	J$TIMER
	MVI	A,37H		; Turn DTR back on
	OUT	PORT+3		; Send to command register
	IN	PORT+3		; Clear any incoming characters
	IN	PORT+3		; Try once more
	XRA	A		; Clear the 'A' register
	RET
;.....
;
;
; Initializes the 2561 I/O for selected baudrate
;
INITMOD:
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	CPI	6		; 2400 bps
	JZ	OK2400
	CPI	8		; 9600
	JZ	OK9600
	CPI	9
	JZ	OK19200		; 19200 BPS
	JMP	STUPR1		; Else ask what is wanted
;
INITMOD1:
	MVI	A,CHIP		; Select correct user port
	OUT	UPORT
	XRA	A		; Set RTS, flags, DTR, disable R/T
	OUT	PORT+3		; Put command register out of mode
	IN	PORT+3		; Makes sure it is now clear
	IN	PORT+3		; Try once more
	MVI	A,4EH		; Select 8 data bits no parity 1 stop
	OUT	PORT+2		; Send to mode register 1
	MOV	A,B		; Get the baudrate back
	OUT	PORT+2		; Send to mode register 2
	MVI	A,37H		; Turn on DTR etc, reset any error flags
	OUT	PORT+3		; Send to command register
	IN	PORT+3		; Clear any incoming characters
	IN	PORT+3		; Try once more
	RET
;.....
;
;
; Use the 'SET' command to select a desired baud rate
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, '
	DB	'2400, 9600, 19200): ',0
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
	JMP	LOADBD
;
OK19200:MVI	A,9
	MVI	B,BD19200
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	JMP	INITMOD1	; Reinitialize to new baudrate, done
;.....
;
;
; Table of baudrate parameters
;
BD300	EQU	35H		; 300 baud
BD1200	EQU	37H		; 1200 bps
BD2400	EQU	3AH		; 2400 bps
BD9600	EQU	3EH		; 9600 bps
BD19200	EQU	3FH		; 19200 bps
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE: Must terminate prior to 0400H
;
	END
