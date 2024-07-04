
; I2AE-1.ASM - Action Computer Enterprises DPC-280 IMP overlay - 08/24/87
;
;	   2661A I/O, built-in baudrate generator at 4.9152 MHz
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places adapts the Action DPC-280/Televideo 925 to IMP.COM.
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
;		MLOAD IMP.COM=IMP.COM,I2AE-1.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 08/24/81   Modified I2HZ-6.ASM originally intended for the Heath
;	     Computer with a Zenith 100 terminal to work with an
;	     Action Computer Enterprises DPC-280 and a Televidio 925
;	     Terminal.	Changes included different HEX baud rate set
;	     values for the Signetics 2661A Communications Chip
;	     from the values used with the 2661B chip used by the
;	     Heath computer.  Also changed routines for writing
;	     line 25 of the Televideo 925.	- David Hogan
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.			- Irv Hoff
;
; 02/12/86  Added Function keys for the Z-100 as well as 25th line
;	    (status line) display.  These F-keys execute terminal mode
;	    commands and are separate from the ESC-<number> sequences
;	    already present in IMP.  25th line display is currently set
;	    for a green indication of key assignments.	This is a color
;	    which will illuminate monochrome and and color monitors
;	    alike.  (Uses: F0 thru F6 keys and the Home key.)
;						- Hampton Childress
;
; 09/07/85  Added 19200 Baud			- Fred Townsend
; 07/17/85  Written to work with IMP		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =	   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
; Values shown are for a 2661-1 I/O ON ACTION DPC-280 COMPUTER
;
PORT	EQU	084H	; Your base port (data or status)
MDCTL1	EQU	PORT+1	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MDRCV	EQU	02H	; Modem receive ready
MDSND	EQU	01H	; Modem send ready bit
MDTXE	EQU	05H	; Modem send buffer empty, holding buffer empty
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
; Change the clock speed if needed, to match your system.  The 2661-1
; normally runs 4.9152 MHz.
;
;
	 ORG	0100H
;
;
	 DS	3	; Skip the data area below
;
;
MSPEED:	 DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200
HS2400:	 DB	YES	; Yes=2400 bps highest speed			104H
HS1200:	 DB	NO	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
;
CLEAR:	 DB	'*'	; Clear screen character (ESC not needed)	10AH
CLOCK:	 DB	49	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	0	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	0	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
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
EXTCHR:	 DB	ESC	; ESC = preceeds local control character	114H
EXITCHR: DB	'@'	; Exit character			(F0)	115H
FILESND: DB	'E'	; Send file when in terminal mode	(F5)	116H
NOCONCT: DB	'F'	; Disconnect from phone line		(F6)	117H
LOGCHR:	 DB	'A'	; Send logon				(F1)	118H
LSTCHR:	 DB	'B'	; Toggle printer			(F2)	119H
UNSAVCH: DB	'D'	; Close input text buffer		(F4)	11AH
SAVECHR: DB	'C'	; Open input text buffer		(F3)	11BH
CLEARS:	 DB	'G'	; Clears screen, terminal mode		(Home)	11CH
BRKCHR:	 DB	'H'	; Send a break tone				11DH
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
I$MDDATP: IN	MDDATP		;					133H
	  RET			;					135H
	  DB	0,0,0,0,0,0,0	;					136H
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
; or in this case, to clear the 25th line and clear the screen.
;
J$EXITVEC:JMP	EXITRM		;					159H
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
LOGPTR:	  DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	  CALL	J$ILPRT		; Display the following line		1A7H
	  DB	'Version for Action DPC-280 & Televideo 925 terminal';	1AAH
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
LOGON:	DB	'Hello from an Action DPC-280 S-100 computer',CR,LF,0
;
;-----------------------------------------------------------------------
;
; This routine sets a 300 ms break tone
;
SENDBRK:
	MVI	A,1FH		; DTR normal, send break tone
	JMP	GOODBYE+2	; Send the break tone
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the phone
;
GOODBYE:
	MVI	A,1DH		; Set RTS, flags, DTR, break
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
; The following are used in setting up the 2661-1 I/O port and the 25th
; (status) line
;
INITMOD:
	CALL J$ILPRT		; Set up 25th line on the Televideo 925
	DB	ESC,'f'		; Begin writing to User Line (line 25)
	DB	'1 DIR<cr>|'	; F1 key
	DB	'2 DIR..|'	; F2 key
	DB	'3 KMD R|'	; F3 key
	DB	'4 KMD S|'	; F4 key
	DB	'5 XMD R|'	; F5 key
	DB	'6 XMD S|'	; F6 key
	DB	'7 BYE |'	; F7 key
	DB	'8 BBS |'	; F8 key
	DB	'9 TYPE|'	; F9 key
	DB	'0 bye'		; F0 key
	DB	CR		; End input to line 25
	DB	ESC,'g'		; Turn display of line 25 on
	DB	0		; All done
;
;	Make sure that no more than 79 characters are sent to line
;	25 in the above routine.  The ESC,'f' and ESC,'g' are not
;	included in this count.
;
; Now set up the modem
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
;...
;
;
; The following changes the baud rate with the set command.
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
	MVI	B,BD300
	JMP	LOADBD
;
OK1200:	MVI	A,5
	MVI	B,BD1200
	JMP	LOADBD
;
OK2400:	XRA	A
	STA	MANUAL		; Reset for automatic stepdown
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
	STA	SETSPD+1	; Store in INITMOD
	XRA	A		; Set RTS, flags, DTR, disable R/T
	OUT	PORT+3		; Put command register out of mode
	IN	PORT+3		; Make sure it is now clear
	IN	PORT+3		; Try once more  (CE, 2 stop, 4E 1 stop)
	MVI	A,04EH		; 1 stop, no parity, 8 bits, 16x asynch
	OUT	PORT+2		; Send to mode register 1
;
SETSPD:	MVI	A,BD1200	; Start with 1200 baud (4.9152 clock)
	OUT	PORT+2		; Send to mode register 2
	MVI	A,37H		; Reset RTS, flags, DTR low, enable R/T
	OUT	PORT+3		; Send to command register
	IN	PORT+3		; Clear any incoming chars.
	IN	PORT+3		; Try once more
	XRA	A		; Clear the 'A' register
	RET
;.....
;
;
EXITRM:	CALL J$ILPRT
	DB	ESC,'h'		; Turn off line 25 of the Televidio 925
	DB	ESC,'*'		; Clear the CRT
	DB	0		; Done with J$ILPRT string
	RET
;.....
;
;
; Table of baudrate parameters for 2661A I/O
;
BD300	EQU	0F6H
BD1200	EQU	0F9H
BD2400	EQU	0FCH
BD9600	EQU	0FEH
BD19200	EQU	0FFH
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
;			       end
;-----------------------------------------------------------------------
;
; Note: Must terminate prior to 0400H
;
	END
