;
; I2AP-7.ASM - Apple ][ overlay file for IMP - 02/27/86
;
;		APR = 6850 (uses divide by 16 or by 64)
;		CCS = 6850 (uses divide by 16 or by 64)
;		CPS = 2651 (built-in divisor)
;		SSC = 6551 (built-in divisor)
;
; This overlay file adapts Apple II computers with various serial cards
; and external 2400 bps modems to IMP.COM.  It supports the following
; configurations:
;
; CP/M adapter cards:
; ------------------
;	ALS CP/M 3.0 adapter card
;	Applied Engineering Z80+ or Z80C
;	Microsoft Softcard Z80 equivalent
;	PCPI Applicard
;	BASIS 108 System (German Apple)
;
; Serial cards
; ------------
;	a) ALS Dispatcher card
;     * b) Apricorn serial card (see note below about baudrate)
;	c) CCS 7710 serial interface *see note below about baudrate
;	d) Apple Comcard
;	e) Mountain Hardware CPS Multifunction card  -	2651
;	f) Apple SSC communications interface  -  6551
;	g) SSM serial interface
;	h) Prometheus Versacard with software baud select
;
;     * The 6850 has no baudrate generator.  It relies on the user
;	setting a dip switch to the maximum speed he wants to use.
;	The program then uses the 6850 in the "divide by 16" mode
;	to get that speed.  It can then change to "divide by 64"
;	to get the only other speed available.	This type system
;	normally limits the user to 1200 and 300 baud.	If you
;	set the dip switches for 2400, then you could only get
;	2400 and 600, eliminating both 1200 and 300 baud.  Using
;	either the Apricorn or CCS 7710 board just about precludes
;	the user from wanting to obtain a new modem with 2400 bps.
;	The 6850 uses the last two bits to select the divisor.	01
;	gives "divide by 16" and 10 gives "divide by 64".
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
;-----------------------------------------------------------------------
;
; The CCS 7710 serial card is set up as DCE rather than the more usual
; DTE, and requires a special cable.....the following cable configura-
; ion is necessary to work with this overlay -----
;
;	      MODEM pin       CCS pin
;
;		2		3
;		3		2
;		5		4
;		8		20
;		7		7
;		20		5
;
; Hayes 1200 switch 6 must be down...(DCD true)
;							<nlb>
;----------------------------------------------------------------------
;
; To use SET with the Prometheus Versacard a small hardware change  must
; be made, since the Versacard only supports baud rate selection via DIP
; switches.  This change will allow the Versacard to be switched between
; 300 and 1200 baud via software.  A wire should be attached from Pin
; #12 on U16 (IC marked 8126) on the Versacard into Annunciator #3 (Pin
; #12) on the Apple game port.	This will allow switch #4 on s2 of the
; Versacard to be toggled by setting or clearing annunciator #3. The de-
; fault baud rate is set at MSPEED Below either (300 or 1200).
;
; Note: This method could be extended to all other Versacard baud rates
;	and by using Annunciators 0,1,2 but 300 and 1200 are really
;	needed for a modem program. The DIP switches on the Versacard
;	should be set as follows:
;
; On switch bank #2:
;			S2 - ON
;			S3 - OFF
;			S4 - OFF
;			S5 - OFF
;
; =   =  =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =
;
; 02/27/86  Fixed several sections so the BASIS 108 option would work
;    v7     correctly.			- Irv Hoff
;
; 01/17/85  Added the Applied Engineering Z80 card.  Added the Apricorn
;    v6     serial card, fixed a problem with the CCS serial card so the
;	    program would assemble correctly.  Note added to tell about
;	    the CCS and Apricorn being limited to 300/1200 bps, if 2400
;	    bps is needed, likely will want a different serial card.
;					- Irv Hoff
;
; 09/27/85  Fixed compile errors for CCS serial option, added DTR sup-
;    v5     port, modem cable description (for CCS board, only).
;					- Norman Beeler
;
; 09/22/85  Corrected SSC INITMOD1 routine - changed JMP to CALL.
;    v4 				- Douglas Thom
;
; 09/15/85  Added SET300 in CPS INITMOD to fix cold boot problem.
;    v3 				- Norman Beeler
;
; 08/27/85  Added to support the BASIS 108
;    v2 				- Clay Walker
;
; 07/17/85  Written to work with IMP	- Irv Hoff
;    v1
;
; =   =  =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =	 =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
;====================== CUSTOMIZATION EQUATES ==========================
;
SLOT	EQU	2		; Slot of serial interface
SLOTOFF	EQU	16*SLOT		; Serial card slot offset
;
;
; CP/M adapter cards for Apple ][
;
ALSCARD	   EQU	NO		; Yes if using ALS CP/M card
APPLIED	   EQU	NO		; Yes if using Applied Engineering Z80
APPLICARD  EQU	NO		; Yes if using PCPI Applicard CP/M card
BASIS	   EQU	NO		; Yes if BASIS 108
MICROSOFT  EQU	YES		; Yes if Microsoft Sofcard CP/M card
;
;
; Serial I/O cards for Apple ][
;
ALSDSP	EQU	NO		; Yes for ALS Dispatcher
APR	EQU	NO		; Yes for Apricorn serial card
CCS	EQU	NO		; Yes for CCS 7710
COMCARD	EQU	NO		; Yes for Apple Comcard
CPS	EQU	NO		; Yes for CPS card
SSC	EQU	YES		; Yes for Super Serial Card
SSM	EQU	NO		; Yes for SSM serial card
VERSA	EQU	NO		; Yes for Prometheus Versacard
;
CPSPRT	EQU	NO		; Yes if using CPS parallel printer port
;
;
;-----------------------------------------------------------------------
;
	 IF	ALSCARD	OR APPLICARD
MAPOFF	EQU	0		; No memory remapping for either
	 ENDIF			; ALSCARD OR APPLICARD
;
	 IF	APPLIED	OR MICROSOFT
MAPOFF	EQU	2000H		; Microsoft strikes again
	 ENDIF			; APPLIED OR MICROSOFT
;
;
;-----------------------------------------------------------------------
;
	 IF	BASIS
MDDATP	EQU	0E098H		; Data Port
MDCTL1	EQU	0E099H		; Status Port
MDCTL2	EQU	0E09AH		; Command Port
MDCTL3	EQU	0E09BH		; Control Port
MDRCV	EQU	08H		; Same as SSC (6551 ACIA)
MDSND	EQU	10H		;  "
MDTXE	EQU	10H		;  "
	 ENDIF			; BASIS
;
;
;-----------------------------------------------------------------------
;
	 IF	APR
MDCTL1	EQU	0C08EH+SLOTOFF+MAPOFF ; Status port of Apricorn
MDDATP	EQU	0C08FH+SLOTOFF+MAPOFF ; Data port of Apricorn
	 ENDIF			; APR
;
;
;-----------------------------------------------------------------------
;
	 IF	CCS
MDCTL1	EQU	0C080H+SLOTOFF+MAPOFF ; Status port of CCS 7710
MDDATP	EQU	0C081H+SLOTOFF+MAPOFF ; Data port of CCS 7710
	 ENDIF			; CCS
;
;
;-----------------------------------------------------------------------
;
	 IF	COMCARD	OR VERSA OR ALSDSP
MDCTL1	EQU	0C08EH+SLOTOFF+MAPOFF ; Status port of Comcard
MDDATP	EQU	0C08FH+SLOTOFF+MAPOFF ; Data port of Comcard
	 ENDIF			; COMCARD OR VERSA OR ALSDSP
;
;
;-----------------------------------------------------------------------
;
	 IF	CPS
MDCPST	EQU	0C0F9H+SLOT*100H+MAPOFF	; Printer status port
MDDATP	EQU	0C0FAH+SLOT*100H+MAPOFF	; Data port of CPS card
MDCTL1	EQU	0C0FBH+SLOT*100H+MAPOFF	; Status port of CPS card
MDCTL2	EQU	0C0FCH+SLOT*100H+MAPOFF	; Second CPS status port
MDCPRT	EQU	0C0FDH+SLOT*100H+MAPOFF	; Printer data port
MDCR	EQU	0C0FEH+SLOT*100H+MAPOFF	; Control port of CPS card
MDRCV	EQU	2		; Bit to test for receive
MDSND	EQU	1		; Bit to test for send
MDTXE	EQU	5		; Modem send buffer empty
	 ENDIF			; CPS
;
;
;-----------------------------------------------------------------------
;
	 IF	SSC
MDDATP	EQU	0C088H+SLOTOFF+MAPOFF ; SSC data port
MDCTL1	EQU	0C089H+SLOTOFF+MAPOFF ; SSC status port
MDCTL2	EQU	0C08AH+SLOTOFF+MAPOFF ; SSC mode port
MDCTL3	EQU	0C08BH+SLOTOFF+MAPOFF ; SSC control port
MDRCV	EQU	08H		; Bit to test for received data
MDSND	EQU	10H		; Bit to test for ready to send
MDTXE	EQU	10H		; Modem send buffer empty
	 ENDIF			; SSC
;
;
;-----------------------------------------------------------------------
;
	 IF	SSM
MDCTL1	EQU	0C084H+SLOTOFF+MAPOFF ; Status port of SSM
MDDATP	EQU	0C085H+SLOTOFF+MAPOFF ; Data port of SSM
	 ENDIF			; SSM
;
;
;-----------------------------------------------------------------------
;
	 IF	NOT SSC	AND NOT	CPS AND	NOT BASIS
MDRCV	EQU	1		; Bit to test for receive
MDSND	EQU	2		; Bit to test for send
MDTXE	EQU	2		; Modem send buffer empty
	 ENDIF			; NOT SSC AND NOT CPS
;
;
;-----------------------------------------------------------------------
;
	 IF	VERSA
AN3CLR	EQU	0C05EH+MAPOFF	; Clear annunciator #3
AN3SET	EQU	0C05FH+MAPOFF	; Set	    "	    #3
	 ENDIF			; VERSA
;
;
;-----------------------------------------------------------------------
;
; We have software control over the APR, CCS, CPS, SSC and Versacard (if
; the hardware mod is made.)
;
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
	  IF	APPLICARD
CLOCK:	 DB	6	; Clock speed in MHz, 25.5 MHz max.		10BH
			; NOTE:  DO NOT MULTIPLY BY 10 FOR APPLICARD
	  ENDIF		; APPLICARD
;
	  IF	NOT APPLICARD
CLOCK:	 DB	20	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
	  ENDIF		; NOT APPLICARD
;
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
NODTR:	 DB	YES	; Yes if no DTR and need +++ to disconnect	11EH
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
LOGPTR:	DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	CALL	J$ILPRT		; Display the following line		1A7H
	 IF	BASIS
	DB	'Basis 108 with built in serial port ',CR,LF	;	1AAH
	DB	0
	RET
	 ENDIF			; BASIS
;
	 IF	NOT BASIS
	DB	'Apple ][ and '	;
	 ENDIF			; NOT BASIS
;
	 IF	ALSCARD
	DB	'ALS CP/M Card'
	 ENDIF			; ALSCARD
;
	 IF	APPLICARD
	DB	'Applicard'
	 ENDIF			; APPLICARD
;
	 IF	APPLIED
	DB	'Applied Engineering'
	 ENDIF			; APPLIED
;
	 IF	MICROSOFT
	DB	'CP/M 2.2 Card'
	 ENDIF			; MICROSOFT
;
	 IF	VERSA
	DB	'Versacard'
	 ENDIF			; VERSA
;
	DB	CR,LF
;
	 IF	ALSDSP
	DB	'ALS Dispatcher'
	 ENDIF			; ALSDSP
;
	 IF	APR
	DB	'Apricorn serial card'
	 ENDIF			; APR
;
	 IF	CCS
	DB	'CCS 7710 Card'
	 ENDIF			; CCS
;
	 IF	COMCARD
	DB	'Comcard'
	 ENDIF			; COMCARD
;
	 IF	CPS
	DB	'CPS card - serial function'
	 ENDIF			; CPS
;
	 IF	SSC
	DB	'Super Serial Card'
	 ENDIF			; SSC
;
	 IF	SSM
	DB	'SSM Serial Interface'
	 ENDIF			; SSM
;
	 IF	NOT	BASIS
	DB	' in slot ',SLOT+30H,CR,LF
	DB	0
	RET
	 ENDIF			; NOT BASIS
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
LOGON:	DB	'Hello there from a happy computer user',CR,0
;
;-----------------------------------------------------------------------
;
;
; This routine sets DTR low for 300 ms to disconnect the phone
;
GOODBYE	EQU	$
;
	 IF	NOT APR	AND NOT	BASIS AND NOT CCS AND NOT CPS AND NOT SSC
	CALL	J$ILPRT
	DB	CR,LF,'++ DOES NOT DROP DTR, USE "BYE" ++',BELL,CR,LF,0
	RET
	 ENDIF			; NOT APR AND NOT BASIS (etc)
;
	MVI	A,'S'-40H	; X-off to stop host if needed
	CALL	J$SNDCHR
	MVI	B,1		; Wait a moment to let it react
	CALL	J$TIMER
;
	 IF	APR OR CCS
	MVI	A,0D5H		; Turn off DTR
	CALL	SNDCTL1
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,0B5H		; Turn everything back on
	CALL	SNDCTL1
	XTHL			; Short delay to complete command
	XTHL
	RET
	  ENDIF			; APR OR CCS
;
	 IF	SSC OR BASIS
	MVI	A,0AH		; Turn off DTR
	CALL	SNDCTL2
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,0BH		; Set DTR, Rx, Irq
	CALL	SNDCTL2
	XTHL			; Short delay to complete command
	XTHL
	RET
	 ENDIF			; SSC or BASIS
;
	 IF	CPS
	MVI	A,80H		; Open command
	CALL	SNDMDCR
	MVI	A,1DH		; RTS, DTR off, send break
	CALL	SNDCTL1
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,37H		; RTS, ERR reset errors, Rx, DTR, Tx
	CALL	SNDCTL1
	MVI	A,0		; Close command
	CALL	SNDMDCR
	MVI	B,5		; Short delay to complete command
	CALL	J$TIMER
	RET
	 ENDIF			; CPS
;.....
;
;
;=========================== INITMOD ===================================
;
;
INITMOD	EQU	$
;
	 IF	ALSCARD
	LHLD	1		; Initialize our local jumps to the BIOS
	LXI	D,60H
	DAD	D
	SHLD	APREAD+1
	INX	H
	INX	H
	INX	H
	SHLD	APWRITE+1
	RET
	 ENDIF			; ALSCARD
;.....
;
;
	 IF	APR OR CCS
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	CPI	6		; 2400 bps
	JZ	OK2400
	CPI	8		; 9600 bps
	JZ	OK9600
	JMP	STUPR1		; Else ask what is wanted
;
INITMOD1:
	MOV	A,B		; Get the baudrate back, 8 bits 1 stop
	CALL	SNDCTL1		; ACIA control register
	XTHL			; Short delay to complete command
	XTHL
	RET
	 ENDIF			; APR OR CCS
;.....
;
;
; The following may be used to initialize the Mountain Hardware CPS
; Multifunction Card.
;
	 IF	CPS
	CALL	OK300		; Necessary for cold boot
	CALL	CPSPRINT	; Install special CPS printer routine
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	CPI	6		; 2400 bps
	JZ	OK2400
	CPI	8		; 9600 bps
	JZ	OK9600
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
INITMOD1:
	MVI	A,80H		; Open command
	CALL	SNDMDCR
	MVI	A,4EH		; 1 stop, 8 bits, 16x
	CALL	SNDDATP
	MOV	A,B		; Get the baudrate back
	CALL	SNDDATP
	MVI	A,37H		; RTS, ERR reset errors, Rx, DTR, Tx
	CALL	SNDCTL1
	XRA	A		; Close command
	CALL	SNDMDCR
	MVI	B,5		; 1/2 second delay for CPS board
	CALL	J$TIMER
	RET
	 ENDIF			; CPS
;.....
;
;
	 IF	BASIS OR SSC
	MVI	A,0BH		; Set DTR, Rx, Irq
	CALL	SNDCTL2
	XTHL			; Short delay to complete command
	XTHL
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
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
INITMOD1:
	MOV	A,B		; Get the baudrate back
	CALL	SNDCTL3		; Store default baudrate
	XTHL			; Short delay to complete command
	XTHL
	RET
	 ENDIF			; BASIS OR SSC
;.....
;
;
; The following routine initializes the Versacard to the default baud
; rate which is set at MSPEED above.  If MSPEED is set to something
; other than 300 or 1200 this routine does not alter the annunciator
; settings.
;
	 IF	VERSA
INITMOD1:
	LDA	MSPEED		; Set annunciators to known state
	CPI	1		; Is it 300 ?
	JZ	OK300
	CPI	5		; Is it 1200 ?
	JZ	OK1200
	RET
	 ENDIF			; VERSA
;.....
;
;
; If none of the above cards
;
	RET			; From 'CALL INITMOD'
;.....
;
;
; The routine that checks to see if the printer is ready does not work
; with the CPS card.  This routine changes it.	It overwrites the area
; in the main program that normally checks printer status from a BDOS
; call with our own status checks.
;
CPSPRINT:
	 IF	CPS AND	CPSPRT	; If printer uses CPS printer port
	CALL	J$GOLST		; Get GOLIST+1 in 'HL'
	LXI	B,PRCHECK	; Put routine at GOLIST+1
	MOV	M,C
	INX	H
	MOV	M,D
	XCHG			; Now get GOLIST+15 into 'HL' from 'DE'
	LXI	B,PRINTCHAR	; Put routine at GOLIST+15
	MOV	M,C
	INX	H
	MOV	M,D
	RET
;.....
;
;
; Substitute routines for status checks and printing:
;
PRCHECK:CALL	RCVCPST		; Read the status port
	ANI	40H		; Mask off unused bits
	RET
;.....
;
;
PRINTCHAR:
	MOV	A,C		; Move character to 'A' register
	JMP	SNDCPRT		; Send it to the printer
	 ENDIF			; CPS AND CPSPRT
;
	RET			; In case CPSPRT was set to 'NO'
;.....
;
;
;========================== APPLE I/O ==================================
;
	 IF	APPLIED	OR BASIS OR MICROSOFT
SNDCTL1:STA	MDCTL1
	RET
;
SNDDATP:STA	MDDATP
	RET
;
RCVCTL1:LDA	MDCTL1
	RET
;
RCVDATP:LDA	MDDATP
	RET
	 ENDIF			; APPLIED OR BASIS OR MICROSOFT
;.....
;
;
	  IF	CPS AND	(APPLIED OR MICROSOFT)
SNDCPRT: STA	MDCPRT
	 RET
;
SNDMDCR: STA	MDCR
	 RET
;
RCVCPST: LDA	MDCPST
	 RET
	  ENDIF			; CPS AND (APPLIED OR MICROSOFT)
;.....
;
;
	  IF	BASIS OR SSC AND (APPLIED OR MICROSOFT)
RCVCTL2: LDA	MDCTL2
	 RET
;
RCVCTL3: LDA	MDCTL3
	 RET
;
SNDCTL2: STA	MDCTL2
	 RET
;
SNDCTL3: STA	MDCTL3
	 RET
	  ENDIF			; BASIS OR SSC AND (APPLIED OR MICROSOFT)
;.....
;
;
	  IF	VERSA AND (APPLIED OR MICROSOFT)
RCVAN3C: LDA	AN3CLR
	 RET
;
RCVAN3S: LDA	AN3SET
	 RET
	 ENDIF			; VERSA AND (APPLIED OR MICROSOFT)
;.....
;
	  IF	ALSCARD	AND SSC
SNDCTL2: PUSH	H
	 LXI	H,MDCTL2
	 JMP	POKE
;
SNDCTL3: PUSH	H
	 LXI	H,MDCTL3
	 JMP	POKE
	  ENDIF			; ALSCARD AND SSC
;.....
;
;
	  IF	ALSCARD
SNDCTL1: PUSH	H
	 LXI	H,MDCTL1
	 JMP	POKE
;
SNDDATP: PUSH	H
	 LXI	H,MDDATP
;
POKE:	 PUSH	D
	 PUSH	B
	 CALL	APWRITE
	 POP	B
	 POP	D
	 POP	H
	 RET
	  ENDIF			; ALSCARD
;.....
;
;
	  IF	ALSCARD	AND SSC
RCVCTL3:  PUSH	H
	 LXI	H,MDCTL3
	 JMP	PEEK
	  ENDIF			; ALSCARD AND SSC
;.....
;
;
	  IF	ALSCARD
RCVCTL1: PUSH	H
	 LXI	H,MDCTL1
	 JMP	PEEK
;
RCVDATP: PUSH	H
	 LXI	H,MDDATP
;
PEEK:	 PUSH	D
	 PUSH	B
	 CALL	APREAD
	 POP	B
	 POP	D
	 POP	H
	 RET
;.....
;
;
; These are the jump locations to the ALS BIOS
;
APREAD:	 JMP	$-$
APWRITE: JMP	$-$
	  ENDIF			; ALSCARD
;.....
;
;
	  IF	ALSCARD	AND CPS
SNDCPRT: PUSH	H
	 LXI	H,MDCPRT
	 JMP	POKE
;
SNDMDCR: PUSH	H
	 LXI	H,MDCR
	 JMP	POKE
;
RCVCPST: PUSH	H
	 LXI	H,MDCPST
	 JMP	PEEK
	  ENDIF			; ALSCARD AND CPS
;.....
;
;
	  IF	ALSCARD	AND SSC
RCVCTL3: PUSH	H
	 LXI	H,MDCTL3
	 JMP	PEEK
;
SNDCTL2: PUSH	H
	 LXI	H,MDCTL2
	 JMP	POKE
;
SNDCTL3: PUSH	H
	 LXI	H,MDCTL3
	 JMP	POKE
	  ENDIF			; ALSCARD AND SSC
;.....
;
;
	  IF	ALSCARD	AND VERSA
RCVAN3C: PUSH	H
	 LXI	H,AN3CLR
	 JMP	PEEK
;
RCVAN3S: PUSH	H
	 LXI	H,AN3SET
	 JMP	PEEK
	  ENDIF			; ALSCARD AND VERSA
;.....
;
;
	  IF	APPLICARD	;
RDBYTE	 EQU	0FFE0H		; Read 1 byte frin Aooke (A = byte)
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
	  ENDIF			; APPLICARD
;.....
;
;
	  IF	APPLICARD AND CPS
SNDCPRT: PUSH	D
	 LXI	D,MDCPRT
	 JMP	POKE
;
SNDMDCR: PUSH	D
	 LXI	D,MDCR
	 JMP	POKE
;
RCVCPST: PUSH	D
	 LXI	D,MDCPST
	 JMP	PEEK
	  ENDIF			; APPLICARD AND CPS
;.....
;
;
	  IF	APPLICARD AND SSC
RCVCTL3: PUSH	D
	 LXI	D,MDCTL3
	 JMP	PEEK
;
SNDCTL2: PUSH	D
	 LXI	D,MDCTL2
	 JMP	POKE
;
SNDCTL3: PUSH	D
	 LXI	D,MDCTL3
	 JMP	POKE
	  ENDIF			; APPLICARD AND SSC
;.....
;
;
	  IF	APPLICARD AND VERSA
RCVAN3C: PUSH	D
	 LXI	H,AN3CLR
	 JMP	PEEK
;
RCVAN3S: PUSH	D
	 LXI	H,AN3SET
	 JMP	PEEK
	  ENDIF			; APPLICARD AND VERSA
;.....
;
;
;-----------------------------------------------------------------------
;
; Use the 'SET' command to select a desired baud rate
;
STUPR	EQU	$
;
	 IF	ALSDSP OR COMCARD OR SSM
	RET
	 ENDIF			; ALSDSP OR COMCARD OR SSM
;
	 IF	NOT ALSDSP OR NOT COMCARD OR NOT SSM
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
	 IF	NOT VERSA
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
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	JMP	INITMOD1	; Reset to new baudrate
	 ENDIF			; NOT VERSA
;.....
;
;
	 IF	VERSA
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
	 ENDIF			; VERSACARD
;.....
;
;
; Table of baud rate parameters
;
	 IF	APR OR CCS
BD300	EQU	16H		; Divide by 64 (set by last 2 bits 10)
BD1200	EQU	15H		; Divide by 16 (set by last 2 bits 01)
BD2400	EQU	00H		; See note at the top for other speeds
BD9600	EQU	00H
	 ENDIF			; APR OR CCS
;
	 IF	CPS
BD300	EQU	35H
BD1200	EQU	37H
BD2400	EQU	3AH
BD9600	EQU	3EH
	 ENDIF			; CPS
;
	 IF	SSC OR BASIS
BD300	EQU	16H
BD1200	EQU	18H
BD2400	EQU	1AH
BD9600	EQU	1EH
	 ENDIF			; SSC
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
	 ENDIF			; NOT ALSDSP OR NOT COMCARD OR NOT SSM
;.....
;
;
;-----------------------------------------------------------------------
; NOTE: Must terminate prior to 0400H
;
	END
