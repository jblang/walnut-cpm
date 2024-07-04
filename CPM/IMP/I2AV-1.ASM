
; I2AV-1.ASM  -  Apple ][ overlay file for IMP  -  06/01/87
;
;	     PCPI Z80 adapter with VERSAcard MC6850 ACIA
;
;			     VERSAcard
;
; To use SET with the Prometheus VERSAcard a small hardware change must
; be made, since the VERSAcard only supports baud rate selection via DIP
; switches.  This change will allow the VERSAcard to be switched between
; 300 and 1200 baud via software.  A wire should be attached from Pin
; #12 on U16 (IC marked 8126) on the VERSAcard into Annunciator #3 (Pin
; #12) on the Apple game port.	This will allow switch #4 on s2 of the
; VERSAcard to be toggled by setting or clearing annunciator #3. The de-
; fault baud rate is set at MSPEED Below either (300 or 1200).
;
; Note: This method could be extended to all other VERSAcard baud rates
;	and by using Annunciators 0,1,2 but 300 and 1200 are really
;	needed for a modem program. The DIP switches on the VERSAcard
;	should be set as follows:
;
; On switch bank #2:
;			S2 - ON
;			S3 - OFF
;			S4 - OFF
;			S5 - OFF
;
;
;	 NOTE:	If you have trouble disonnecting from the
;		phone line, you may not have a normal DTR
;		setup to turn off the modem.  In that case,
;		set the NODTR: option at 011E to YES, to
;		provide ATH0 to disonnect.  (This assumes
;		you have a Hayes-compatible type modem with
;		"AT" command set.)
;
;
;	 _________________
;	|		  |
;	| 7 6 5 4 3 2 1 0 |   6850 ACIA for serial I/O
;	|_________________|
;
;	  CR1 CR0     Function
;	   0   0	 1
;	*  0   1	16	(for 1200 bps)
;	+  1   0	64	(changes to 300 baud)
;	   1   1    Master reset
;
;	CR4 CR3 CR2
;	 0   0	 0     7 bits, even parity, 2 stop bits
;	 0   0	 1     7 bits,	odd parity, 2 stop bits
;	 0   1	 0     7 bits, even parity, 1 stop bit
;	 0   1	 1     7 bits,	odd parity, 1 stop bit
;	 1   0	 0     8 bits,	 no parity, 2 stop bits
;      * 1   0	 1     8 bits,	 no parity, 1 stop bit
;	 1   1	 0     8 bits, even parity, 1 stop bit
;	 1   1	 1     8 bits,	odd parity, 1 stop bit
;
;	  CR6 CR5
;	   0   0     RTS low,  Xmit interrupt disabled
;	   0   1     RTS low,  Xmit interrupt enabled
;	*  1   0     RTS high, Xmit interrupt disabled
;	   1   1     RTS low,  Xmit interrupt disabled, break sent
;
;	    CR7
;	     0	     Interrupts disabled
;	*    1	     Enables recieve buffer full, overrun, low-to-high
;		       transition on the data carrier detect.
;
;					- Notes by Irv Hoff W6FFC
;
;-----------------------------------------------------------------------
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
;		MLOAD IMP.COM=IMP.COM,I2AP-x.HEX
;
;					- Notes by Irv Hoff W6FFC
;
; =   =  =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =
;
; 06/01/87  First version for IMP 	- Irv Hoff
;
; =   =  =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =
;
YES	EQU	0FFH
NO	EQU	0
;
;====================== CUSTOMIZATION EQUATES ==========================
;
SLOT	EQU	2		; Slot of serial interface
SLOTOFF	EQU	16*SLOT		; Serial card slot offset
;
;
; CP/M adapter cards for Apple ][
;
PCPI	   EQU	YES		; Yes if using PCPI Applicard CP/M card
;
;
; Serial I/O cards for Apple ][
;
VERSA	EQU	YES		; Yes for Prometheus VERSAcard
;
;
;-----------------------------------------------------------------------
;
MAPOFF	EQU	0		; No memory remapping for either
;
;-----------------------------------------------------------------------
;
MDRCV	EQU	1		; Bit to test for receive
MDSND	EQU	2		; Bit to test for send
MDTXE	EQU	2		; Modem send buffer empty
;
;-----------------------------------------------------------------------
;
MDCTL1	EQU	0C08EH+SLOTOFF+MAPOFF ; Status port of VERSAcard
MDDATP	EQU	0C08FH+SLOTOFF+MAPOFF ; Data port of VERSAcard
;
;-----------------------------------------------------------------------
;
AN3CLR	EQU	0C05EH+MAPOFF	; Clear annunciator #3
AN3SET	EQU	0C05FH+MAPOFF	; Set	    "	    #3
;
;-----------------------------------------------------------------------
;
; We have software control over the VERSAcard (if the hardware mod is
; made.)
;
;-----------------------------------------------------------------------
;
; General equates
;
ESC	EQU	'['-40H		; ^[ = Escape
BELL	EQU	'G'-40H		; ^G = Bell character
LF	EQU	'J'-40H		; ^J = Linefeed
NEXTRY	EQU	'K'-40H		; ^K = Try next phone number now
CR	EQU	'M'-40H		; ^M = Carriage return
CLEARSC	EQU	'Z'-40H		; ^Z = Clear screen, command mode only
EOFCHAR	EQU	'Z'-40H		; ^Z = End of file
;
;-----------------------------------------------------------------------
;
;
	ORG	0100H
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
CLEAR:	 DB	'*'	; Clear screen character (ESC not needed)	10AH
;
CLOCK:	 DB	6	; Clock speed in MHz, 25.5 MHz max.		10BH
			; NOTE:  DO NOT MULTIPLY BY 10 FOR APPLICARD
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	9	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	9	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
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
I$MDCTL1: JMP	RCVCTL1		; In modem control port 		11FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:  JMP	RCVCTL1		;					129H
	  DB	0,0,0,0,0,0,0	;					12CH
;
I$MDDATP: JMP	RCVDATP		;in modem data port			133H
	  DB	0,0,0,0,0,0,0	;					146H
;
O$MDDATP: JMP	SNDDATP		; Out modem data port			13DH
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
LOGPTR:	DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	CALL	J$ILPRT		; Display the following line		1A7H
	DB	'Apple ][ with '
	DB	'PCPI Applicard'
	DB	CR,LF,'  and '
	DB	'VERSAcard'
	DB	' in slot ',SLOT+30H,CR,LF,0
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
LOGON:	DB	'Hello from a happy computer user',CR,0
;
;-----------------------------------------------------------------------
;
; This routine sends a break tone for 300 ms
;
SENDBRK:
	CALL	RCVCTL1		; Get the current status and speed
	STA	SBTEMP		; Store it for now
	MVI	A,0F5H		; Set for a break
	JMP	GOODBYE1	; Go send it
;.....
;
;
SBTEMP:	DB	0		; Temporary storage to remember speed
;.....
;
;
; This routine sets DTR low for 300 ms to disconnect the phone
;
;
GOODBYE:
	CALL	RCVCTL1		; Get the current status and speed
	STA	SBTEMP		; Store it for now
	MVI	A,0D5H		; Turn off DTR
;
GOODBYE1:
	CALL	SNDCTL1		; Send to the Modem
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	LDA	SBTEMP		; Get original status and speed back
	CALL	SNDCTL1
	MVI	A,0B5H		; Turn everything back on
	CALL	SNDCTL1
	XTHL			; Short delay to complete command
	XTHL
	RET
;.....
;
;
;=========================== INITMOD ===================================
;
;
INITMOD	EQU	$
;
INITMOD1:
	LDA	MSPEED		; Set annunciators to known state
	CPI	1		; Is it 300 ?
	JZ	OK300
	CPI	5		; Is it 1200 ?
	JZ	OK1200
	RET
;.....
;
;
; The following routine initializes the VERSAcard to the default baud
; rate which is set at MSPEED above.  If MSPEED is set to something
; other than 300 or 1200 this routine does not alter the annunciator
; settings.
;
;
;========================== APPLE I/O ==================================
;
RDBYTE	 EQU	0FFE0H		; Read 1 byte from Apple (A = byte)
WRBYTE	 EQU	0FFE3H		; Write 1 byte to Apple (C = byte)
RDWORD	 EQU	0FFE6H		; Read 2 bytes from Apple (DE = word)
WRWORD	 EQU	0FFE9H		; Write 2 bytes to Apple (DE = word)
PEEK1	 EQU	6		; Command
POKE1	 EQU	7		; Command
;
SNDCTL1: PUSH	D
	 LXI	D,MDCTL1
	 JMP	POKE
;
SNDDATP: PUSH	D
	 LXI	D,MDDATP
;
POKE:	 PUSH	B
	 MOV	B,A
	 MVI	C,POKE1
	 CALL	WRBYTE
	 CALL	WRWORD
	 MOV	C,B
	 CALL	WRBYTE
	 POP	B
	 POP	D
	 RET
;...
;
;
RCVCTL1: PUSH	D
	 LXI	D,MDCTL1
	 JMP	PEEK
;
RCVDATP: PUSH	D
	 LXI	D,MDDATP
;
PEEK:	 PUSH	B
	 MVI	C,PEEK1
	 CALL	WRBYTE
	 CALL	WRWORD
	 CALL	RDBYTE
	 POP	B
	 POP	D
	 RET
;.....
;
;
RCVAN3C: PUSH	D
	 LXI	H,AN3CLR
	 JMP	PEEK
;
RCVAN3S: PUSH	D
	 LXI	H,AN3SET
	 JMP	PEEK
;.....
;
;
;-----------------------------------------------------------------------
;
; Use the 'SET' command to select a desired baud rate
;
STUPR	EQU	$
;
	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, 2400, 9600): ',0
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
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
OK300:	CALL	RCVAN3C		; Clear Annunciator #3 for 300 baud
	MVI	A,1		; Set MSPEED for 300 baud
	STA	MSPEED		; For 300 baud
	RET
;
OK1200:	CALL	RCVAN3S		; Set Annunciator #3 for 1200 baud
	MVI	A,5		; Set MSPEED for 1200 bps
	STA	MSPEED		; For 1200 baud
	RET
;
OK2400:	JMP	OK1200		; Does not support 2400 bps
;
OK9600:	JMP	OK1200		; Does not support 9600 bps
;.....
;
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
;.....
;
;
;-----------------------------------------------------------------------
; NOTE: Must terminate prior to 0400H
;
	END
