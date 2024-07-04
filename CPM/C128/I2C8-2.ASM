
; I2C8-2.ASM - Commodore C128 overlay for IMP - 06/01/87
;
; This Commodore C128 overlay for IMP supports the Commodore 1670 modem,
; the Hayes Smartmodem 1200 or any similar modem using the Hayes "AT"
; command set, the Prometheus 1200 modem or any Racal-Vadic autodial
; modem.
;
; NOTE: Modems for the Commodore C128 plug into the "user's port".  The
;	Commodore 1670 modem plugs in directly.  Other brands of modems
;	can be used, but an adapter interface is needed to convert that
;	port to a RS232 type connector.  This is called a 1011A adapter
;	by Commodore.  The Omni-Tronics firm makes such an adapter which
;	comes with a RS-232 cable to plug into the modem.
;
;		The Commodore 1670 does not support DTR
;		so if using that modem, be sure to use:
;
;			NODTR  EQU  YES
;
;		in the equates below.  This substitutes
;		the "pause +++ pause ATH0" command for
;		dropping DTR.  If using a modem that
;		does support DTR, you can instead use:
;
;			NODTR  EQU  NO
;
;		since dropping DTR for 1/2 second is far
;		faster than the "pause +++ pause ATH0".
;		Also not all external modems support the
;		Hayes AT commands, etc.  The DTR/+++ is
;		used to remotely disconnect the modem
;		from the telephone line.
;
; NOTE: The times quoted for file transfer will likely be less than what
;	will be observed when using the C128 computer.	This is mostly
;	due to the way the information is sent to the disk and then ver-
;	ified.	As a result, it takes around 7-8 seconds to dump only 4k
;	to the Commodore 1571 disk system.  (Most disk systems take only
;	5-6 seconds to dump 16k.)  Consequently, this Commodore overlay
;	has a line at the very end which sets byte 0BFFH to dump every
;	4k (32 record intervals), so it will finish prior to a 10-second
;	time-out error.  (The 1541 disks are slower yet and that byte
;	may need to be changed to dump at 2k intervals if using the 1541
;	disk drive, to prevent timeout errors.)
;
;	The printer command has been disabled - due to the way the 1200
;	bps modem "bit-banging" has been implemented into the Commodore
;	C128, the printer can not be used at the same time the modem is
;	being used.
;
;	IMPORTANT:  IF YOU GOT THE "I2NM-n.ASM" FILE FOR CHANG-
;		    ING THE PHONE NUMBER LIBRARY, AT THIS TIME
;		    GO CHANGE THE LABEL "XFRSIZE" FROM 16 TO 4
;		    SO IF/WHEN YOU USE THAT PROGRAM, IT WILL SET
;		    THE 0BFF BYTE CORRECTLY FOR THE COMMODORE
;		    TO DUMP TO DISK EACH 4K.  (IF YOU DO THAT
;		    WHILE READING THIS, YOU WON'T FORGET IT.)
;
;					- Notes by Irv Hoff W6FFC
;
;-----------------------------------------------------------------------
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Commodore C128 (with external modem) to IMP.COM.
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
;    NOTE:  The Commodore C128 does not have an authentic serial
;	    port and thus can only run 1200 bps maximum speed.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to merge into the main file:
;
;		MLOAD IMP.COM=IMP.COM,I2C8-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Improved the GOODBYE routine, added BREAK routine, needs
;	    IMP245 to use it.  (Not fully implemented for this computer
;	    as yet.)				- Irv Hoff
;
; 12/12/85  Written to work with IMP, based on work done for MDM740 for
;	    the C128 by Von Ertwine.  		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH		; Some assemblers cannot use NOT NO or
NO	EQU	0		;   0FFFFH for "YES", notably ASM.COM.
;
;
; C128 data
;
PORT	EQU	6
MEMRY	EQU	0FD4EH
MDCTL1	EQU	MEMRY+1
SNDDAT	EQU	MEMRY+2
RCVDAT	EQU	MEMRY+3
MDRCV	EQU	01H		; Modem receive ready
MDSNDB	EQU	80H		; bit to test for send
MDSNDR	EQU	00H		; value when send ready
MDTXE	EQU	00H
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
CLOCK:	 DB	12	; Special clock speed, set for C128 at 1200 bps 10BH
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
LSTCHR:	 DB	NO	; Toggle printer (unavailable to C128 users)	119H
UNSAVCH: DB	'R'	; Close input text buffer			11AH
SAVECHR: DB	'Y'	; Open input text buffer			11BH
CLEARS:	 DB	'Z'	; Clears screen, terminal mode			11CH
BRKCHR:	 DB	'Q'	; Send a break tone				11DH
NODTR:	 DB	YES	; Yes if no DTR and need ATH0 to disconnect	11EH
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: LDA	MDCTL1		; Get status byte to A-reg.		11FH
	  RET			;					121H
	  DB	0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:  LDA	MDCTL1		; (Needed for SIO or DART register 1	129H
	  RET			;					12BH
	  DB	0,0,0,0,0,0	;					12CH
;
I$MDDATP: LDA	RCVDAT		; Get the character			133H
	  JMP	GETDAT		;					136H
	  DB	0,0,0,0		;					139H
;
O$MDDATP: STA	SNDDAT		; Output the character			13DH
	  JMP	OUTDAT		;					140H
	  DB	0,0,0,0		; Spares if needed			143H
;.....
;
;
A$MDRCV:  ANI	MDRCV		;					147H
	  RET			;					149H
;
C$MDRCV:  CPI	MDRCV		;					14AH
	  RET			;					14CH
;
A$MDSND:  ANI	MDSNDB		;					14DH
	  RET			;					14FH
;
C$MDSND:  CPI	MDSNDR		;					150H
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
J$EXITVEC:JMP	SET300		; Put C128 back to 300 baud clock	159H
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
J$STRNGA: JMP	SPLSTR		; 1200 bps "AT" string			168H
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
	  DB	'Commodore C128 Version' ;				1AAH
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
LOGON:	DB	'C128 running CP/M 3.0',CR,LF,0
;
;-----------------------------------------------------------------------
;
;
; This routine allows a 300 ms break tone to be sent.
;
SENDBRK:
	RET
;.....
;
;
; This routine sets DTR low for 300 ms to disonnect the phone
;
GOODBYE:
	LXI	B,0DD01H	; Dataport B
	DB	0EDH,78H	; Input A (Z80 instruction)
	ANI	0F9H
	DB	0EDH,79H	; Output the new value, to disconnect
	MVI	B,3		; For 300 ms.
	CALL	J$TIMER
	LXI	B,0DD01H	; Reset back to normal
	DB	0EDH,78H
	ORI	6
	DB	0EDH,79H
	RET
;.....
;
;
; Sets 8251 to 8 bits, DTR, RCV and TX ready
;
INITMOD:MVI	A,1		; Set to 8 bits, no parity
	STA	MEMRY		; Configure byte in BIOS
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
; Initialize the port, baudrate is now in the B-reg. find where it goes
; and put it there.
;
INIT1:	PUSH	B		; Temporarily store the baudrate value
	LHLD	0000H+1		; Get BIOS address
	LXI	D,57		; CP/M JMP device table
	DAD	D		; Index into BIOS
	CALL	INIT2		; Jumps to address now in HL
				; returns with HL=char device tbl start
	LXI	D,PORT*8+7	; Offset to RS232 baud rate
	DAD	D		; Point to RS232 baud rate byte
				;   Byte now in HL
	POP	B		; Get the baudrate value back
	MOV	M,B		; Store the requested baud rate
;
;
; Have now stored desired baudrate, find the address in BIOS where the
; port will be initialized, put the correct port into the 'C' register
; and then initialize that port to baud rate just set, finished.
;
	LHLD	0000H+1		; Get BIOS address
	LXI	D,60		; CP/M init address
	DAD	D		; Index into BIOS
	MVI	C,PORT		; Tell it what port to initialize
;
;
; Jumps to HL address, performs that routine, then returns to original
; area that called this area.
;
INIT2:	PCHL			; Jump to that routine then return
;.....
;
;
; We found there was a character, got it, but have to manually reset the
; flag to zero saying we did get the character.
;
GETDAT:	PUSH	H		; Save the current address just in case
	LXI	H,MDCTL1	; Address of status byte
	DB	0CBH,86H	; Reset the 0 bit of the HL status byte
	POP	H		; Restore the original address
	RET			; Return with the character
;.....
;
;
; Output character has been stored in the BIOS memory location, now set
; the flag showing there is a charcter ready.
;
OUTDAT:	PUSH	H		; Save any current address, if needed
	LXI	H,MDCTL1	; Address of the status byte
	DB	0CBH,0FEH	; Set bit 7 of the HL status byte
	POP	H		; Get the original address back
	RET			; All done
;.....
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, or 1200): ',0
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
OK2400:	JMP	OK1200		; C128 does not support 2400 bps
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	JMP	INIT1
;.....
;
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300	EQU	6		; Divisor for 300 baud
BD1200	EQU	8		; Divisor for 1200 bps
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;.....
;
;
SET300:	MVI	B,BD300
	JMP	INIT1
;.....
;
;
; Initialization string - the '#' character is a 100 ms. delay, at least
; four should be used after a CR following a commnd.
;
SPLSTR:	DB	'ATV0',CR,'####','ATE1Q0X1',CR,'####','$'
;
;
; This sets the size of the disk dump.	Most Commodore systems write to
; disk so slowly that 4k is a good figure to use to insure finishing
; prior to a 10-second timeout at the other end (which causes them to
; resend the last transmission again, etc.)
;
	ORG	0BFFH
;
	DB	20H		; 20h=4k, 40h=8k, 80h=16k disk dumps
;.....
;
;
; NOTE: Must terminate by 0400H
;
	END
