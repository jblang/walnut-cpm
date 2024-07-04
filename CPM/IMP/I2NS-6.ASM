
; I2NS-6.ASM - North Star Horizon w/HSIO-4 & Advantage IMP24x 06/01/87
;
;			 For 8251 USART
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the North Star Horizon w/HSIO-4 and Advantage to
; IMP.COM.
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
;		MLOAD IMP.COM=IMP.COM,I2NS-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.			- Irv Hoff
;
; 06/26/86  Changed GOODBYE so it uses MDRSET to lower carrier detect
;	    then resets baud at 300.  For some reason, on the Advantage
;	    it would not previously disconnect, although on the Horizon
;	    with the HSIO-4 it worked okay.
;						- Don Appleby
; 11/05/85  Added modem command to Advantage init routine.  Added the
;	    19200 bps flag to MSPEED.		- Mark Engelbrecht
;
; 10/19/85  Added equates to permit selection of Advantage configuration
;	    for various SIO boards and baud rates.  Easier to configure
;	    both systems.			- Don Appleby
;
; 10/05/85 - Changed SPARE2 to NODTR and set it to 00.
;						- Don Appleby
;
; 08/31/85 - Added equates to permit selection of any of 4 ports on
;	     HSIO-4. Seems to have problem with taking modem off hook
;	     at 300 baud.			- Don Appleby
;
; 08/23/85 - I2NA-1 written to work with North Star Advantage
;						- R. Gaspari
;
; 08/17/85 - Adapted from I2DP-1 for North Star Horizon
;						- Don Appleby
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
YES	EQU	0FFH
NO	EQU	0
;
HORZ	EQU	NO
ADV	EQU	YES
;
;
; Values shown are for an 8251
;
	 IF	HORZ
PORTA	EQU	12H		; HSIO-4 Port A data port
PORTB	EQU	PORTA+4		; Port B data port
PORTC	EQU	PORTB+4		; Port C data port
PORTD	EQU	PORTC+4		; Port D data port
;
PORT	EQU	PORTA		; <== Select which port to use here
MDCTL1	EQU	PORT+1		; Modem control port
MDDATP	EQU	PORT		; Modem data port
BDPORT	EQU	PORT-2		; HSIO-4 baud rate port
;
MDMODE	EQU	82H		; Insures 8251 is out of mode, DTR high
MDRSET	EQU	42H		; Resets USART for additional commands
MDSET1	EQU	4EH		; 1 stop bit, no parity, 8 bits, x16
MDSET2	EQU	0CEH		; 2 stop bits, no parity, 8 bits, x16
MDCOM	EQU	17H		; Reset error flags, RCV, DTR, TX ready
	 ENDIF			; HORZ
;
	 IF	ADV
PORT	EQU	3		; Set to your SIO slot 1,2,3,4,5 or 6
MDDATP	EQU	60H-(10H*PORT)	; Modem data port
MDCTL1	EQU	MDDATP+1	; Modem control port
BDPORT	EQU	MDDATP+8	; Modem baud rate port
;
MDMODE	EQU	80H		; Insures 8251 is out of mode, DTR high
MDRSET	EQU	40H		; Resets USART for additional commands
MDSET1	EQU	4EH		; 1 stop bit, no parity, 8 bits, x16
MDSET2	EQU	0CEH		; 2 stop bits, no parity, 8 bits, x16
MDCOM	EQU	37H		; Reset RTS, error flags, RCV, TX, DTR
	 ENDIF			; ADV
;
MDRCV	EQU	02H		; Modem receive ready
MDSND	EQU	01H		; Modem send ready bit
MDTXE	EQU	05H		; Modem send and holding buffers empty
;
;
;
;-----------------------------------------------------------------------
;
ESC	EQU	'['-40H		; ^[ = Escape
BELL	EQU	'G'-40H		; ^G = Bell character
LF	EQU	'J'-40H		; ^J = Linefeed
NEXTRY	EQU	'K'-40H		; ^K = Try next phone number
CR	EQU	'M'-40H		; ^M = Carriage return
CLEARSC	EQU	'Z'-40H		; ^Z = Clears screen, command mode only
EOFCHAR	EQU	'Z'-40H		; ^Z = End of file
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
CLEAR:	 DB	04H	; Clear screen character (ESC not needed)	10AH
CLOCK:	 DB	40	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
			;   20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	2	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			; Default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	2	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
			; Default time for extra wait after CRLF
			;   in terminal mode file transfer
NOFCOL:	 DB	5	; Number of directory columns shown		10EH
TCHPUL:	 DB	'T'	; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;.....
;
;
ADDLFD:	 DB	NO	; Yes=add LF after CR to send file in terminal	110H
			; Mode (normally added by remote echo)
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
O$MDDATP: OUT	MDDATP		; 13DH
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
J$TIMER:  DS	3		; 1 second timer (amount in 'B' reg.)	192H
J$BREAK:  JMP	SENDBRK		; Break routine 			195H
J$NEW2:	  DB	0,0,0		; For future needs			198H
;.....
;
;
; For 2400 bps auto-stepdown units
;
MANUAL:	DB	0		; For manual selection flag		19BH
J$300:	JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:	JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:	JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;.....
;
;
LOGPTR:	DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	CALL	J$ILPRT		; Display the following line		1A7H
	DB	'Version for North Star ' ; 1AAH
;
	 IF	HORZ
	DB	'Horizon HSIO-4 Port ',((PORT-15)/4)+65,' '
	 ENDIF			; HORZ
;
	 IF	ADV
	DB	1,'Advantage - Slot ',PORT+30H,' ',2
	 ENDIF			; ADV
;
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
LOGON:	DB	'This is a North Star computer...',CR,LF
	DB	0
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
; Sets 8251 to 8 bits, DTR, RCV and TX ready
;
	 IF	HORZ
INITMOD:
	MVI	A,MDMODE	; Insure 8251 is out of mode
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDRSET	; Reset the 8251 for new command
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDSET1	; Set stop pulse, no parity 8 bits, x16
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDCOM		; Error reset, RCV, DTR, TX ready
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	 ENDIF			; HORZ
;
;
; Complete initialization of 8251 (from scratch).  Sets 8251 to 8 bits,
; DTR, RCV and TX ready.
;
	 IF	ADV
INITMOD:
	IN	MDCTL1		; Clear control port of any garbage
	NOP
	XRA	A		; Set A to zero
	OUT	MDCTL1		; STEP 1  -  RESET
	NOP			; Reset the 8251 SIO chip,
	OUT	MDCTL1		; Using the 0,0,0,40 technique
	NOP
	OUT	MDCTL1
	NOP
	MVI	A,MDRSET
	OUT	MDCTL1
	NOP			; STEP 2  -  MODE
	NOP
	NOP
	MVI	A,MDSET1	; Mode is asynch, 16X, 1 stop bit,
	OUT	MDCTL1		; 8 data bits, no parity
	NOP
	NOP
	NOP
	MVI	A,MDCOM		; Set the ports operating parameters.
	OUT	MDCTL1		; And do it.
	IN	MDCTL1		; Clear out the garbage.
	IN	MDCTL1
	IN	MDCTL1
	 ENDIF			; ADV
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
	MOV	A,B
	OUT	BDPORT		; Give to baudrate port
	RET
;.....
;
;
; Table of baudrate parameters
;
	 IF	HORZ
BD300	EQU	6		; 300  baud
BD1200	EQU	4		; 1200
BD2400	EQU	3		; 2400
BD9600	EQU	1		; 9600
BD19200	EQU	0		; 19200
	 ENDIF			; HORZ
;
	 IF	ADV
BD300	EQU	40H		; N* Advantage code for 300 baud
BD1200	EQU	70H		; 1200
BD2400	EQU	78H		; 2400
BD9600	EQU	7EH		; 9600
BD19200	EQU	7FH		; 19200
	 ENDIF			; ADV
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
;
; NOTE: Must terminate by 0400H
;
	END
;			       end
;___________________________________________________________________
