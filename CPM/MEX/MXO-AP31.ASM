;	TITLE  'MEX Overlay for Apple ][ / Applicard / Smartmodem'
;
;  MXO-AP30.ASM created 01/28/85   by   Henry Middlebrook
;
REV	EQU	31		; 03 Feb 1985
;
; This overlay file enables Apple ][ computers to use the following
; Apple hardware configuration with MEX112:
;
;	> Mountain CPS Multi-Function and 6 MHz PCPI AppliCard <
; 
;			- Henry Middlebrook [70766,766]
;				January 28, 1985
;
; This overlay is written in three distinct parts as a "MIXED" type of
; overlay for MEX.  The parts follow the guidelines available in the
; MEX OVERLAY LIST #2 (01/06/85 -- Ron Fowler, NightOwl Sofware) with
; reference to the PORT, MODEM, and PATCH overlay types.  Thus, you
; should be able to remove or add any one of the three parts without
; severely affecting the overlay operation.  Naturally, removing the
; first section (PORT) will completely disable MEX; however, removing
; or changing the the MODEM (derived from MXO-SM13.ASM) section or
; the PATCH (MEXPAT11.ASM) will minimally affect operation (see LSTST
; and SSET).
;
; The three part in order are:
;
;	1. PORT -- Supports Apple ][+/e with PCPI Applicard and
;		   Mountain Computer cards.  Contains all vectors
;		   and equates from MDM7xx series as updated for MEX.
;
;	2. MODEM - This is basically the "officially sanctioned" version
;		   of the Hayes Smartmodem 1200 overlay, MXO-SM13.ASM.
;		   Several redundant EQUs and Conditionals have been
;		   removed or commented out of the source code.
;
;	3. PATCH - The MEXPAT11.ASM file was pulled into this overlay
;		   and modified to suit the author's needs and whims.
;		   Using the patch file as listed adds vector for a
;		   precise LSTST vector.
;
; >>>>  NOTE:  	Previous versions of MXO-APxx do NOT properly support
;		the PCPI Applicard.  You may not like this overlay;
;		however, you can use it as a reliable guide.
;
; This overlay includes many comments and instructional lines from
; the `full' overlays.  These may be commented out or passed along
; as you see fit.
;				HM	02/04/85
;
;----------------------------------------------------------------------
;			Overlay Update History
;
; 02/03/85 - Added TIME and SET functions -AP31	- Henry Middlebrook
; 01/28/85 - Created MXO original overlay -AP30	- Henry Middlebrook
;
;======================================================================

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;			PORT OVERLAY SECTION
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;
BELL		EQU	07H	;bell
CR		EQU	0DH	;carriage return
ESC		EQU	1BH	;escape
LF		EQU	0AH	;linefeed
TAB		EQU	09H	;tab
YES		EQU	0FFH
NO		EQU	0
;
;
;----------------------------------------------------------------------
;
;		Equates for BIOS LISTST correction
;		----------------------------------
;
; MEX support LST and LSTST vectors to custom routines in this
; overlay.  The EQUs must be properly set in MEXPAT section at
; end of this code and the routines equates below are for printer
; I/O specific routines at the end of the modem overlay (WR$PRT).
;
; Equates for optional printer routine (for SUPER-MX parallel Epson)
;
USERPRINTER	EQU	YES
;
PSLOT		EQU	1	;Printer slot
PTRSTATP	EQU	0C081H + (PSLOT * 10H)	;Printer stat address
PTRDATP		EQU	0C081H + (PSLOT * 10H)	;Printer data out addr
PTRSTBP1	EQU	0C082H + (PSLOT * 10H)	;Strobe address #1
PTRSTBP2	EQU	0C080H + (PSLOT * 10H)	;Strobe address #2
PTR$RDY		EQU	01H			;Printer ready mask
;
;----------------------------------------------------------------------
;
;	Mountain CPS Serial I/O and Clock equates and routines
;	------------------------------------------------------
;
CPSLOT		EQU	2
;
MODDATP		EQU	0C0FAH + (CPSLOT*100H)	;serial port of CPS card
MODCTLP		EQU	0C0FBH + (CPSLOT*100H)	;status port of CPS card
MODCTLP2	EQU	0C0FEH + (CPSLOT*100H)	;control port of CPS card
;
CLKPORT		EQU	0C0FEH + (CPSLOT*100H)	;control port for Clock
CLKDATA		EQU	0C0F9H + (CPSLOT*100H)	;data port for Clock
CLKHOLD		EQU	040H			;stop clock for read
CLKREAD		EQU	050H			;set clock read mode
;
RDBYTE		EQU	0FFE0H	;Read a Byte from Apple (A = BYTE)
WRBYTE		EQU	0FFE3H	;Write a Byte to Apple (C = BYTE)
RDWORD		EQU	0FFE6H	;Read 2 Bytes from Apple (DE = BYTES)
WRWORD		EQU	0FFE9H	;Write 2 Bytes to Apple (DE = BYTES)
RDNBYTS		EQU	0FFECH	;Read N Bytes (DE = COUNT, HL = BUFFER)
WRNBYTS		EQU	0FFEFH	;Write N Bytes (DE = COUNT, HL = BUFFER)
;
PEEK1BYTE	EQU	6	;Command to Peek 1 Byte in the Apple
POKE1BYTE	EQU	7	;Command to Poke 1 Byte to the Apple
;
; Status bit equates for CPS serial port
;
MDSNDB		EQU	01H
MDSNDR		EQU	01H
MDRCVB		EQU	02H
MDRCVR		EQU	02H
;
; Equates for PSW (Parity, Stop Bit, Word Length) used by CPS UART
;
P8N1		EQU	04EH	;8 NONE 1
P7E1		EQU	0EAH	;7 EVEN 1
P7O1		EQU	055H	;7 ODD 1
P7N1		EQU	045H	;7 NONE 1
;
;----------------------------------------------------------------------
;
;			MEX OVERLAY INFORMATION
;
; This is a general purpose MEX modem overlay file. You can use it as
; a model for designing your own modem overlay (or you can use any
; existing MDM7 overlay, if available).
;
; If you use this as a template for writing your own overlay, and
; distribute it to others, please pare down these comments as much
; as possible (to keep the overlays small). I'll maintain this file
; with as many notes and references as possible, but this will hope-
; fully be the only "big" overlay.
;
; There are advantages to recoding your overlay to conform to the
; techniques presented here: MEX 2.0 will likely have a much simpler
; overlay structure; if you stick to the label names and coding
; suggestions used here, you'll easily be able to follow the overlay
; upgrade instructions when MEX 2.0 hits the streets. Also, you can
; make use of the MEX service processor to write a very versatile
; SET command (as done here).
;
; Note that all overlays may freely use memory up to 0CFFH.  If your
; overlay must work with the MEX Smartmodem overlay (MXO-SMxx.ASM),
; the physical modem overlay should terminate by 0AFFH.
;
; For purposes of example, this is a "full-featured" MEX overlay.  In
; practice, your overlay may be much simpler (all that is really re-
; quired is the modem I/O code; fancy stuff like the SET command, and
; even the disconnect routine, may be left open.  You will need DIAL
; code, though, unless your modem doesn't support autodialing).
;
;
;	MEX Service Processor Calls  (User's Guide - Appendix #4)
;	---------------------------------------------------------
;
; MEX service processor stuff ... MEX supports an overlay service
; processor, located at 0D00H (and maintained at this address from
; version to version).  If your overlay needs to call BDOS for any
; reason, it should call MEX instead; function calls below about
; 240 are simply passed on to the BDOS (console and list I/O calls
; are specially handled to allow modem port queueing, which is why
; you should call MEX instead of BDOS).  MEX uses function calls
; above about 244 for special overlay services (described below).
;
; Some sophisticated overlays may need to do file I/O; if so, use
; the PARSFN MEX call with a pointer to the FCB in DE to parse out
; the name.  This FCB should support a spare byte immediately pre-
; ceeding the actual FCB (to contain user # information).  If you've
; used MEX-10 for input instead of BDOS-10 (or you're parsing part
; of a SET command line that's already been input), then MEX will
; take care of DU specs, and set up the FCB accordingly.  There-
; after all file I/O calls done through the MEX service processor
; will handle drive and user with no further effort necessary on
; the part of the programmer.
;
MEX	EQU	0D00H	;address of the service processor
INMDM	EQU	255	;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254	;delay 100ms * reg B
TMDINP	EQU	253	;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252	;check for ^C from KBD, Z=present
SNDRDY	EQU	251	;test for modem-send ready
RCVRDY	EQU	250	;test for modem-receive ready
SNDCHR	EQU	249	;send a character to the modem (after sndrdy)
RCVCHR	EQU	248	;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247	;table search: see CMDTBL comments for info
PARSFN	EQU	246	;parse filename from input stream
BDPARS	EQU	245	;parse baud-rate from input stream
SBLANK	EQU	244	;scan input stream to next non-blank
EVALA	EQU	243	;evaluate numeric from input stream
LKAHED	EQU	242	;get nxt char w/o removing from input
GNC	EQU	241	;get char from input, cy=1 if none
ILP	EQU	240	;inline print
DECOUT	EQU	239	;decimal output
PRBAUD	EQU	238	;print baud rate
PRNTBL	EQU	237	;print command table in columns (HL=addr)
PRID	EQU	236	;print MEX ID string on console
;
CONOUT	EQU	2	;simulated BDOS function 2: console char out
PRINT	EQU	9	;simulated BDOS function 9: print string
INBUF	EQU	10	;input buffer, same structure as BDOS 10
;
;
;======================================================================
;
	ORG	100H	;we begin
;
	DS	3	;MEX has a JMP START here			100H
;
; The following variables are located at the beginning of the program
; to facilitate modification without the need of re-assembly. They will
; be moved in MEX 2.0.
;
PMODEM:	DB	YES	;\ / These two locations are			103H
SMODEM:	DB	NO	;/ \ not referenced by MEX.			104H
TPULSE:	DB	'T'	;Tone/Pulse (used only in Smodem overlay)	105H
CLOCK:	DB	60	;clock speed x .1, up to 25.5 mhz.		106H
MSPEED:	DB	5	;sets display time for sending a file		107H
			;0=110	1=300  2=450  3=600  4=710
			;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	1	;default time to send character in		108H
			;terminal mode file transfer (0-9)
			;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	1	;end-of-line delay in terminal			109H
			;mode file transfer for slow BBS systems
			;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5	;number of directory columns			10AH
SETFL:	DB	YES	;yes=user-defined SET command			10BH
SCRTST:	DB	YES	;yes=if home cursor and clear screen		10CH
			;routine at CLRSCRN
	DB	0	;was once ACKNAK, now spare			10DH
BAKFLG:	DB	NO	;yes=make .BAK file				10EH
CRCDFL:	DB	YES	;yes=default to CRC checking			10FH
			;no=default to Checksum checking
TOGCRC:	DB	YES	;yes=allow toggling of Checksum to CRC		110H
CVTBS:	DB	NO	;yes=convert backspace to rub			111H
TOGLBK:	DB	YES	;yes=allow toggling of bksp to rub		112H
ADDLF:	DB	NO	;no=no LF after CR to send file in		113H
			;terminal mode (added by remote echo)
TOGLF:	DB	YES	;yes=allow toggling of LF after CR		114H
TRNLOG:	DB	NO	;yes=allow transmission of logon		115H
			;write logon sequence at location LOGON
SAVCCP:	DB	YES	;yes=do not overwrite CCP			116H
LOCNXT:	DB	NO	;yes=local cmd if EXTCHR precedes		117H
			;no=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES	;yes=allow toggling of LOCNXTCHR		118H
LSTTST:	DB	YES	;yes=allow toggling of printer on/off		119H
			;in terminal mode. Set to no if using
			;the printer port for the modem
XOFTST:	DB	YES	;yes=allow testing of XOFF from remote		11AH
			;while sending a file in terminal mode
XONWT:	DB	NO	;yes=wait for XON after sending CR while	11BH
			;transmitting a file in terminal mode	
TOGXOF:	DB	YES	;yes=allow toggling of XOFF testing		11CH
IGNCTL:	DB	NO	;yes=do not send control characters		11DH
			;above CTL-M to CRT in terminal mode
			;no=send any incoming CTL-char to CRT
EXTRA1:	DB	0	;for future expansion				11EH
EXTRA2:	DB	0	;for future expansion				11FH
BRKCHR:	DB	'@'-40H	;^@ = Send a 300 ms. break tone			120H
NOCONN:	DB	'N'-40H	;^N = Disconnect from phone line		121H
LOGCHR:	DB	'L'-40H	;^L = Send logon				122H
LSTCHR:	DB	'P'-40H	;^P = Toggle printer				123H
UNSVCH:	DB	'R'-40H	;^R = Close input text buffer			124H
TRNCHR:	DB	'T'-40H	;^T = Transmit file to remote			125H
SAVCHR:	DB	'Y'-40H	;^Y = Open input text buffer			126H
EXTCHR:	DB	'^'-40H	;^^ = Send next character			127H
;
; Equates used only by PMMI routines grouped together here.
;
PRATE:	DB	125	;125=20pps dialing, 250=10pps			128H
	DB	0	;not used					129H
;
; Low-level modem I/O routines: this will be replaced with
; a jump table in MEX 2.0 (you can insert jumps here to longer
; routines if you'd like ... I'd recommend NOT putting part of
; a routine in this area, then jumping to the rest of the routine
; in the non-fixed area; that will complicate the 2.0 conversion)
;
IN$MODCTLP:	JMP	RD$MODCTLP 	;				12AH
		DS	7
OUT$MODDATP:	JMP	WR$MODDATP	;				134H
		DS	7
IN$MODDATP:	JMP	RD$MODDATP	;				13EH
		DS	7
;
; Bit-test routines.  These will be merged with the above
; routines in MEX 2.0 to provide a more reasonable format
;
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
;
; Unused area: was once used for special PMMI functions, now used only
; to retain compatibility with MDM overlays. You may use this area for
; any miscellaneous storage you'd like but the length of the area
; >> MUST << be 12 bytes.
;
		DS	12		;PMMI only calls		154H
;
; Special modem function jump table: if your overlay cannot handle
; some of these, change the jump to "DS 3", so the code present in
; MEX will be retained.  Thus, if your modem can't dial, change the
; JMP PDIAL at DIALV to DS 3, and MEX will print a "not-implemented"
; diagnostic for any commands that require dialing.
;
; DIALV  dials the digit in A. See the comments at PDIAL for specs.
;
; DISCV  disconnects the modem
;
; GOODBV is called just before MEX exits to CP/M.  If your overlay
;        requires some exit cleanup, do it here.
;
; INMODV is called when MEX starts up; use INMODV to initialize the modem.
;
; NEWBDV is used for phone-number baud rates and is called with a baud-rate
;        code in the A register, value as follows:
;
;	 A=0:   110 baud       A=1:   300 baud      A=2:   450 baud
;	 A=3:   600 baud       A=4:   710 baud      A=5:  1200 baud
;	 A=6:  2400 baud       A=7:  4800 baud      A=8: 19200 baud
;
;        If your overlay supports the passed baud rate, it should store the
;	 value passed in A at MSPEED (107H), and set the requested rate. If
;	 the value passed is not supported, you should simply return (with-
;	 out modifying MSPEED) -or- optionally request a baud-rate from the
;	 user interactively.
;
; NOPARV is called at the end of each file transfer; your overlay may simply
;	 return here, or you may want to restore parity if you set no-parity
;	 in the following vector (this is the case with the PMMI overlay).
;	 
; PARITV is called at the start of each file transfer; your overlay may 
;	 simply return here, or you may want to enable parity detection
;	 (this is the case with the PMMI overlay).
;
; SETUPV is the user-defined command ... to use this routine to build your
;	 own MEX command, set the variable SETFL (117H) non-zero, and add
;	 your SET code.  You can use the routine presented in the PMMI
;	 overlay as a guide for parsing, table lookup, etc.
;
; SPMENU is provided only for MDM compatibility, and is not used by
;	  MEX 1.0 for any purpose (it will be gone in MEX 2).
;
; VERSNV is called immediately after MEX prints its sign-on message at cold
;	 startup -- use this to identify your overlay in the sign-on message
;	 (include overlay version number in the line).
;
; BREAKV is provided for sending a BREAK (<ESC>-B in terminal mode).  If
;	 your modem doesn't support BREAK, or you don't care to code a
;	 BREAK routine, you may simply execute a RET instruction.
;
;
LOGON:		DS	2		;not used by MEX  		160H
DIALV:		JMP	DIAL		;dial a digit in A (ref SMOVL)	162H
DISCV:		JMP	DISCON		;drops DTR to hang-up fast!	165H
GOODBV:		JMP	GOODBYE		;called before exit to CPM	168H
INMODV:		JMP	INITMOD		;go to user written routine	16BH
NEWBDV:		JMP	PBAUD		;changes baud with phone #	16EH
NOPARV:		RET  !	NOP  !	NOP	;set modem for no-parity 	171H
PARITV:		RET  !	NOP  !	NOP	;set modem parity         	174H
SETUPV:		JMP	SETCMD		;				177H
SPMENV:		DS 	3		;not used by MEX		17AH
VERSNV:		JMP	SYSVER		;				17DH
BREAKV:		JMP	SENDBRK		;				180H
;
; The following jump vector provides the overlay with access to special
; routines in the main program (retained and supported in the main pro-
; gram for MDM overlay compatibility). These should not be modified by
; the overlay.
;
; Note that for MEX 2.0 compatibility, you should not try to use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).
;
ILPRTV:		DS	3	;replace with MEX function 9 		183H
INBUFV:		DS	3	;replace with MEX functin 10		186H
ILCMPV:		DS	3	;replace with table lookup funct 247	189H
INMDMV:		DS	3	;replace with MEX function 255		18CH
NXSCRV:		DS	3	;not supported by MEX			18FH
TIMERV:		DS	3	;replace with MEX function 254		192H
;
; Clear/screen and clear/end-of-screen. Each routine must use the
; full 9 bytes alloted (may be padded with nulls).
;
; These routines (and other screen routines that MEX 2.0 will sup-
; port) will be accessed through a jump table in 2.0, and will be
; located in an area that won't tie the screen functions to the
; modem overlay (as the MDM format does).
;
CLREOS:		LXI	D,EOSMSG	;				195H
		MVI	C,PRINT
		CALL	MEX
		RET			;				19DH
;
CLS:		LXI	D,CLSMSG	;				19EH
		MVI	C,PRINT
		CALL	MEX
		RET			;				1A6H
;
;
;
;		*** END OF FIXED FORMAT AREA ***
;
;**********************************************************************
;
; These routines a specific to the Apple ][+ with Applicard.  The
; routines read modem hardware (CPS Serial I/O and Clock) directly from
; the Applicard.
;
; Read the Serial Status Port of UART
;
RD$MODCTLP:	PUSH	D
		LXI	D,MODCTLP
		CALL	PEEK
		POP	D
		RET
;
;
; Write to the Serial Status Port of UART
;
WR$MODCTLP:	PUSH	D
		LXI	D,MODCTLP
		CALL	POKE
		POP	D
		RET
;
;
; Write to the CPS Card SCR to activate secondary UART functions
;
WR$MODCTLP2:	PUSH	D
		LXI	D,MODCTLP2
		CALL	POKE
		POP	D
		RET
;
;
; Read the Serial Data from the UART
;
RD$MODDATP:	PUSH	D
		LXI	D,MODDATP
		CALL	PEEK
		POP	D
		RET
;
;
; Write to the Serial Data Port of the UART
;
WR$MODDATP:	PUSH	D
		LXI	D,MODDATP
		CALL	POKE
		POP	D
		RET
;
;
; Write to CPS hardware to activate card for CLOCK functions
; (duplicates WR$MODCTLP2 routine above).
;
WR$CLKSTAT:	PUSH	D
		LXI	D,CLKPORT
		CALL	POKE
		POP	D
		RET
;
;
; Read a single byte from the CPS Card OKI 5832 clock chip
;
RD$CLKDATA:	PUSH	D
		LXI	D,CLKDATA
		CALL	PEEK
		POP	D
		RET
;
;
; Peek at 1 byte from Apple 6502 address space
; ENTRY: DE = Address in Apple
; EXIT:	A = Data
;
PEEK:	PUSH	B
	MVI	C,PEEK1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	CALL	RDBYTE
	POP	B
	RET
;
;
; Poke 1 byte to Apple 6502 address space
; ENTRY: DE = Address in Apple
; EXIT:	A = Data
;
POKE:	PUSH	B
	MOV	B,A
	MVI	C,POKE1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	MOV	C,B
	CALL	WRBYTE
	POP	B
	RET
;
;----------------------------------------------------------------------
;
; This routine sends a timed (1 second) Break to modem from CPS card.
;
SENDBRK:	CALL	OPENCMD		;open the command register
		MVI	A,3FH		;BREAK byte for CPS CR register	
		CALL	WR$MODCTLP	;send to CPS cmd reg
		MVI	B,10
		MVI	C,TIMER
		CALL	MEX		;send BREAK for 1 second
		MVI	A,37H
		CALL	WR$MODCTLP	;back to normal operation
		CALL	CLOSECMD	;close the command register
		RET
;
;.....
;
; You can add your own routine here to set DTR low and/or send a break
; tone to disconnect.
;
GOODBYE:	RET		;just return for MEX to allow return
				;to system w/o dropping line
;
;.....
;
; The following may be used to initialize the Mountain Hardware CPS
; Multifunction Card for eight bits, no parity, one stop bit, and
; 1200 baud.  This does not alter the CPS defaults outside of MEX
;
INITMOD: 
	MVI	A,5		;set default baud rate to 1200
	CALL 	PBAUD
	MVI	A,P8N1		;set PSW default to 8N1
	STA	PSWSET		;save for future reference
;
INITMOD1:
	CALL	OPENCMD		;Open CPS command register
	MVI	A,37H		;initialize the serial chip
	CALL	WR$MODCTLP	;by storing 37H in CPS Cmd Reg
	LDA	PSWSET		;get current PSW value (def = 04EH) 
	CALL	WR$MODDATP	;store in CPS Mode Reg 1
	LDA     BDSET           ;set baud rate at BDSET by storing
	CALL	WR$MODDATP	;in CPS Mode Reg 2 -- (the two
				;registers cycle with each write)
	CALL    CLOSECMD	;Close CPS command register
	LDA	BDSET		;also return with current Baud setting
	RET
;
;.....
;
; Routines used to open and close CPS command register.  If OPEN, then
; UART CR register (DTR, RTS, Break) and Mode 1 and 2 Registers (FSW
; and Baud) are selected for write. (Note that Mode 1/2 are accessed
; sequentially by writing to MODDATP -- modem data address in Apple).
; The CR register is accessed with WR$MODCTLP and the Mode 1/2 registers
; are accessed (for WRITE only) with WR$MODDATP.
;
; If CLOSED, then UART status register may be read (RxRDY, TxRDY, PE,
; FE, DCD, DSR) with RD$MODCTLP.  Also Serial Data can be sent to
; and from the CPS card with WR$MODDATP and RD$MODDATP.
;
OPENCMD:			;Open the CPS command register
	MVI	A,80H
	JMP	WR$MODCTLP2
;
;
CLOSECMD:			;Close the CPS command register
	MVI	A,0
	JMP	WR$MODCTLP2
;
;.....
;
; This routine drops DTR to force modem to disconnect.  Does NOT do
; any initialization.
;
DISCON:	CALL	OPENCMD		;Open the command register
	MVI	A,05H		;Turn off DTR
	CALL	WR$MODCTLP
	MVI	B,10		;Wait 1 second
	MVI     C,TIMER
	CALL	MEX
	MVI	A,37H		;Turn everything back on
	CALL	WR$MODCTLP
	CALL	CLOSECMD	;Close the cmd register
	MVI	B,10		;Wait 1 second air to clear
	MVI	C,TIMER
	CALL	MEX
	RET
;
;.....
;
; This routine changes the modem baud rate with phone list entry
;
; Set baud-rate code in A (if supported by your modem overlay).  PMMI
; supports only five rates, which are validated here. NOTE: this routine
; (ie, the one vectored through NEWBDV) should update MSPEED with the
; passed code, but ONLY if that rate is supported by the hardware.
;
PBAUD:	PUSH	H		;don't alter anybody
	PUSH	D
	PUSH	B
	MOV	E,A		;code to DE
	MVI	D,0
	LXI	H,BAUDTB	;offset into table
	DAD	D
	MOV	A,M		;fetch code
	ORA	A		;0? (means unsupported code)
	JZ	PBEXIT		;exit if so
	STA	BDSET 		;good rate, set it
	MVI	A,P8N1		;need to get default PSW
	STA	PSWSET		;and save it
	CALL	INITMOD1	;Baud set, returns w/ A = Baud byte
	STA	BAUDSV		;save it
	MOV	A,E		;get speed code back
	STA	MSPEED		;make it current
	JMP	PBEXIT + 1	;jump error flag set
PBEXIT:	STC			;set return error for STBAUD caller
	POP	B		;all done
	POP	D
	POP	H
	RET
;
; Table of baud rate parameters for supported rates
;
BAUDTB:	DB	032H,035H,0,036H,0		;110,300,450,610,710
	DB	037H,03AH,03CH,03EH,03FH	;1200,2400,4800,9600,19200
BAUDSV: DB	037H			;current baud byte
BDSET:	DB	037H			;current and default baud byte
;
;.....
;
; Sign-on message
;
SYSVER:	LXI	D,VERMSG
	MVI	C,PRINT
	CALL	MEX
	CALL	TIMMSG		;prints 'current time is .... '
	CALL	CRLF
	RET
;
;.....
;
; Newline on console
;
CRLF:	MVI	A,CR
	CALL	TYPE
	MVI	A,LF		;fall into TYPE
;
; type char in A on console
;
TYPE:	PUSH	H		;save 'em
	PUSH	D
	PUSH	B
	MOV	E,A		;align output character
	MVI	C,CONOUT	;print via MEX
	CALL	MEX
	POP	B
	POP	D
	POP	H
	RET
;
;----------------------------------------------------------------------
;
; The remainder of this overlay implements a very versatile SET command
; -- if you prefer not to write a SET for your modem, you may delete the
; code from here to the END statement. Control is passed here after
; MEX parses a SET command.
;
;
SETCMD:	MVI	C,SBLANK	;any arguments?
	CALL	MEX
	JC	SETSHO		;if not, go print out values
	LXI	D,CMDTBL	;parse command
	CALL	TSRCH		;from table
	PUSH	H		;any address on stack
	RNC			;if we have one, execute it
	POP	H		;nope, fix stack
SETERR:	LXI	D,SETEMS	;print error
	MVI	C,PRINT
	CALL	MEX
	RET
;
SETEMS:	DB	CR,LF,'SET command error',CR,LF,'$'
;
; SET command table ... note that tables are constructed of command-
; name (terminated by high bit=1) followed by word-data-value returned
; in HL by MEX service processor LOOKUP.  Table must be terminated by
; a binary zero.
;
; Note that LOOKUP attempts to find the next item in the input stream
; in the table passed to it in HL ... if found, the table data item is
; returned in HL; if not found, LOOKUP returns carry set.
;
CMDTBL:	DB	'?'+80H			;"set ?"
	DW	STHELP
	DB	'BAU','D'+80H		;"set baud"
	DW	STBAUD
	DB	'PS','W'+80H		;"set PSW"
	DW	STPSW
	DB	'TIM','E'+80H		;"set TIME" -- just displays time
	DW	TIMMSG
	DB	'TON','E'+80H		;'set TONE/PULSE byte to 'T'
	DW	STTONE
	DB	'PULS','E'+80H		;'set TONE/PULSE byte to 'P'
	DW	STPULSE
	DB	0			;<<=== table terminator
;
; SET <no-args>: print current statistics
;
SETSHO:	LXI	H,SHOTBL	;get table of SHOW subroutines
SETSLP:	MOV	E,M		;get table address
	INX	H
	MOV	D,M
	INX	H
	MOV	A,D		;end of table?
	ORA	E
	RZ			;exit if so
	PUSH	H		;save table pointer
	XCHG			;adrs to HL
	CALL	GOHL		;do it
	CALL	CRLF		;print newline
	MVI	C,CHEKCC	;check for console abort
	CALL	MEX
	POP	H		;it's done
	JNZ	SETSLP		;continue if no abort
	RET
;
GOHL:	PCHL
;
; Table of SHOW subroutines
;
SHOTBL:	DW	TIMMSG		;displays time
	DW	BDSHOW		;displays current baud
	DW	PSWSHOW		;displays current PSW
	DW	TPSHOW		;displays current TPULSE byte (0105H)
	DW	CRLF
	DW	0		;<<== table terminator
;
; SET ?  processor
;
STHELP:	CALL 	CLS			;clear screen
	CALL	TIMMSG
	LXI	D,HLPMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; The help message
;
HLPMSG:	DB	CR,LF,'SET Commands available are:',CR,LF,LF
	DB	'SET BAUD  <110, 300, 600, 1200, 2400, 4800,'
	DB	' 9600, or 19200>',CR,LF
	DB	'SET PSW   <8N1, 7E1, 7O1, or 7N1> -- Word Length,'
	DB	' Parity, Stop Bits',CR,LF
	DB	'SET TIME  (Displays current time of day)',CR,LF
	DB	'SET TONE  (Sets flag for TONE  dialing)',CR,LF
	DB	'SET PULSE (Sets flag for PULSE dialing)'
	DB	CR,LF,LF,'$'
;
; SET BAUD processor
;
STBAUD:	MVI	C,BDPARS	;function code
	CALL	MEX	
	JC	SETERR		;invalid code
	CALL	PBAUD		;try to set it
	JC	SETERR		;unsupported code
BDSHOW:	CALL	ILPRT		;display baud
	DB	'Baud rate:',TAB,' ',0
	LDA	MSPEED
	MVI	C,PRBAUD	;use MEX routine
	CALL	MEX
	RET
;
; SET PSW processor
;
STPSW:	MVI	C,SBLANK
	CALL	MEX
	JC	SETERR		;SET PSW should have had argument
	LXI	D,PSWTBL	;look for PSW match in table
	CALL	TSRCH
	JC	SETERR		;not there, so report error
	MOV	A,L		;get UART PSW byte from table in HL
	STA	PSWSET		;save it
	CALL	INITMOD1	;set CPS card w/ PSW and BAUD
;
PSWSHOW:
	CALL	ILPRT
	DB	'PSW setting:',TAB,' ',0
	LDA	PSWSET
	CPI	P8N1
	JNZ	PSW1
	CALL	ILPRT
	DB	'8N1',0
	RET
PSW1:	CPI	P7E1
	JNZ	PSW2
	CALL	ILPRT
	DB	'7E1',0
	RET
PSW2:	CPI	P7O1
	JNZ	PSW3
	CALL	ILPRT
	DB	'7O1',0
	RET
PSW3:	CPI	P7N1
	JNZ	PSW4
	CALL	ILPRT
	DB	'7N1',0
	RET
PSW4:	CALL	ILPRT
	DB	'<< ERROR >>',0
	RET
;
;
PSWSET:	DB	04EH			;storage and default (8N1)
;
;
PSWTBL:	DB	'8N','1'+80H
	DW	P8N1
	DB	'7E','1'+80H
	DW	P7E1
	DB	'7O','1'+80H
	DW	P7O1
	DB	'7N','1'+80H
	DW	P7N1
	DB	0
;
;.....
;
; These routines set TPULSE flag at 0105H to either 'T' or 'P' so that
; MODEM (specifically MXO-SM13.ASM) overlay will dial in TONE or PULSE
; mode.  The settings are mutually exclusive.
;
STTONE:	MVI	A,'T'		;get T flag
	STA	TPULSE		;put into proper place
	JMP	TPSHOW		;display dial mode
;
STPULSE:
	MVI	A,'P'		;get P flag
	STA	TPULSE
;
TPSHOW:	CALL	ILPRT
	DB	'Dial Mode:',TAB,' ',0
	LDA	TPULSE
	CPI	'T'
	JNZ	TP1
	CALL	ILPRT
	DB	'TONE',0
	RET
TP1:	CPI	'P'
	JNZ	TP2
	CALL	ILPRT
	DB	'PULSE',0
	RET
TP2:	CALL	ILPRT
	DB	'<< ERROR >>',0
	RET
;
;......
;
; Compare next input-stream item in table @DE; CY=1
; if not found, else HL=matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
;
;------------------------------------------------------------
;
;		MEX  Fixed  Messages  Area
;
;
EOSMSG:	DB	ESC,0D9H,0,0,'$'	;clear to end of screen message
					;for Videx Videoterm / SOROC
;
CLSMSG:	DB	ESC,0AAH,0,0,'$'	;clear screen message
					;for Videx Videoterm / SOROC
;
VERMSG:	DB	CR,LF,TAB,TAB,'Version for Apple ][ / Applicard'
	DB	CR,LF
	DB	TAB,TAB,' CPS card   '
	DB	'Overlay Version ',REV/10+'0','.'
	DB	REV MOD 10+'0'
	DB	CR,LF,TAB,TAB,'    ','$'
;
;
;----------------------------------------------------------------------
;
;	Clock reading routines taken from TIME13.ASM
;
;				7/10/84   (H. Middlebrook)
;
; The program is specific to the following hardware:
;
;		Apple ][+
;		PCPI Applicard
;		Mountain Computer CPS Multifunction Card
;
; Program created as Version 1.0	7/10/84	- Henry Middlebrook
;
;.....
;
TIMMSG:	CALL	ILPRT		;Use MEX Inline Print
	DB	'Current time is ',0
	CALL	GET$TIME	;routine to read CPS clock
	CALL	PRT$TIME	;print time of day
	CALL	CRLF		;final CR/LF
	RET			;...all done
;
;.....
;
; PCHAR -->	Prints as ASCII character BCD number in low nibble.
;		Routine falls through to CTYPE.
; CTYPE -->	Prints single character to CONSOLE through BDOS.
;
PCHAR:	ANI	0FH	;mask garbage in upper for bits
	ADI	'0'	;convert to ASCII
CTYPE:	JMP	TYPE	;use MEX routine
;
;.....
;
; GET$TIME -->	Reads CPS clock byte at a time and stores time in
;		CLKTBL.
;
GET$TIME:
	MVI	A,CLKHOLD	;get byte to stop clock
	CALL	WR$CLKSTAT	;send to CPS card
	MVI	A,100		;short little delay
DLOOP:	DCR	A		;allows clock to settle
	JNZ	DLOOP
	LXI	D,CLKTBL	;put CLKTBL address in DE
	MVI	B,0		;set clock index to 0
;
TIME$LOOP:
	MVI	A,CLKREAD	;get byte to read clock
	ORA	B		;add clock index to read (50H - 5CH)
	CALL	WR$CLKSTAT	;send to CPS card
	CALL	RD$CLKDATA	;read clock (SEC1 --> YEAR10)
	ANI	0FH		;mask garbage in high nibble
	STAX	D		;save value read in CLKTBL
	INX	D		;bump CLKTBL address value in DE
	INR	B		;bump clock index in BC
	MVI	A,0DH		;fetch table length + 1
	CMP	B		;are we beyond end of table...
	JNZ	TIME$LOOP	;no, then go back again
	XRA	A		;yes, then zero A reg to turn on clock
	CALL	WR$CLKSTAT
	RET
;
;......
;
; PRT$TIME -->  Reads CLKTBL byte by byte to print time.  This code
;		converts 24hr time to 12hr format.  This code is extract
;		from TIME13 and prints on HH:MM aM using MEX print
;		routines.
;
PRT$TIME:
	XRA	A		;set AMPM flag to AM
	STA	AMPM
	LDA	CLKTBL + 5	;get H10 -- start BCD to Binary convert
	ANI	03H		;mask AM/PM garbage
				;and mask off low nibble
	RLC			;A = A * 2
	MOV	C,A		;save A
	RLC			;A = A * 4
	RLC			;A = A * 8
	ADD	C		;A = (A * 2) + (A * 8) = A * 10
				;A = H10 * 10
	LXI	H,CLKTBL+4	;get address of H1
	ADD	M		;Now we have binary hour in A
	JZ	TIME5		;if 00:00 -- 00:59 AM jmp to fix
	CPI	0CH		;is it afternoon (PM)
	JC	TIME0		;no, then enter at std entry point
	STA	AMPM		;yes, then make AMPM non-zero (=PM)
	CPI	0DH		;is it 13:00:00 (1:00 PM) yet?
	JC	TIME0		;no, then normal print entry
	SUI	0CH		;yes, then subtract 12hrs
	MVI	B,0FFH
TIME3:	INR	B		;divide hr by 10
	SUI	0AH
	JNC	TIME3
	ADI	0AH
	MOV	M,A		;and put H1 back
	INX	H
	MOV	M,B		;put H10 back
	JMP	TIME0
TIME5:	MVI	M,2		;kludge to print 12:xx AM
	INX	H
	MVI	M,1
TIME0:	LDA	CLKTBL + 5	;get H10
	ANI	03H		;mask garbage
	ORA	A
	JZ	TIME1		;skip print if H10 = 0
	CALL	PCHAR
TIME1:	LDA	CLKTBL + 4	;get H1
	CALL	PCHAR
	MVI	A,':'		;delimiter
	CALL	CTYPE
	LDA	CLKTBL + 3	;get M10
	CALL	PCHAR
	LDA	CLKTBL + 2	;get M1
	CALL	PCHAR
	LDA	AMPM		;AM=00H,  PM=anything else
	ORA	A		;set flags
	JNZ	TIME2		;print AM
	CALL	ILPRT
	DB	' AM',0
	RET
TIME2:	CALL	ILPRT
	DB	' PM',0		;print PM message
	RET
;
;.........
;
;	FIXED DATA AREA FOR CLOCK FUNCTION
;
; The CLKTBL is fixed, initialized area used to store time as
; read from CPS clock hardware.
;
CLKTBL:	DB	0		;S1
	DB	0		;S10
	DB	0		;MIN1
	DB	0		;MIN10
	DB	0		;H1
	DB	0		;H10
	DB	0		;Day of Week
	DB	0		;D1
	DB	0		;D10
	DB	0		;MON1
	DB	0		;MON10
	DB	0		;Y1
	DB	0		;Y10
;
AMPM:	DB	0		;flag --> 00H = AM,  else = PM
;
;----------------------------------------------------------------------
;
; >>>> 	Note that the following routines can only be used if the
; >>>>	appropriate patches are made in MEX using the MEXPATxx file.
;
	IF	USERPRINTER
;
; The BIOS implementation in the AppliCard and the BDOS print
; routines interfere with data reception if the printer function is
; enabled. The following routine for a Super-MX parallel printer card
; can  be used as a guide for the writing of an appropriate printer
; driver called as a vector from the program.
;
;
; This routine replaces the MEX PRTSTS routine in the main program.
; It returns with A = 0 if NOT ready.  If printer is ready return
; with A = 0FFH.  These vectors are EQU'd in MEXPAT section of code.
;
PRTSTS:	PUSH	D
	LXI	D,PTRSTATP
	CALL	PEEK		;get byte from printer status address
	POP	D
	ANI	PTR$RDY		;mask for printer status byte
	SUI	PTR$RDY		;return A = 0 if NOT ready
	RET			;else return A = 0FFH IF ready
;
; The following routine is called via the MEX LVEC in MEXPAT.
;
; This routine is entered with byte to print in 'A' register. All
; characters (printable or not) will be sent to printer data port.
; Parallel printer strobe line is then toggled by writing to the
; the two strobe addresses.
;
WR$PRT:	ANI	07FH		;clear Hi-bit
	PUSH	D
	LXI	D,PTRDATP
	CALL	POKE		;put data on printer o/p lines
	LXI	D,PTRSTBP1
	CALL	POKE		;strobe hi...
	LXI	D,PTRSTBP2
	CALL	POKE		;...then low
	POP	D
	RET
;
	ENDIF			;USERPRINTER
;
;
;	>>>>   End of PORT specific overlay section   <<<<

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;		MODEM SPECIFIC OVERLAY SECTION
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;		MEX SMARTMODEM OVERLAY V1.3
;
; Smartmodem overlay for MEX: revision 1.3
;
; Adapted for MXO-AP31 Overlay by Henry Middlebrook (1/85)
;
; NOTE: Some redundant parts of the V1.3 overlay were removed when this
;	section was pulled into MXO-AP31.  See the original overlay for
;	additional information on the history and use of this MODEM
;	specific overlay.		-HM-	2/4/85
;
; Written 04/16/84 by Ronald G. Fowler (V1.0)
;
; 06/06/84: Fixed problem for Anchor users, where, when the modem
;	    returned "DIAL TONE", the "N" in "TONE" was being regarded
;	    as a NO-CONNECT code.  Now we flush the entire result line
;	    before reading another. Also added code for numeric version
;	    of "CONNECT 1200".  --RGF
;
; This modules adapts MEX for the DC Hayes Smartmodem (as well as many
; others -- including US Robotics -- that use a similar command language).
; The main function of this module is to provide dialing capability;
; the disconnect vector is ancillary. You may use this module as a model
; to develop dialing routines for non-standard modems. The only pertinent
; entry point is the DIAL routine; you'll find entry specs for that below.
;
;
; This overlay will work separately with any modem overlay that terminates
; prior to 0B00H or which combines this module with I/O routine overlay
; and together they terminate prior to 0D00H.
;
;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (we don't do this with
; the PMMI, however; we just dial the digits as they come in).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the dig-
; its, and will send each to the DIAL routine un-inspected (some modems,
; like the Smartmodem, allow special non-numeric characters in the
; phone number, and MEX may make no assumptions about these). This
; dialing routine validates digits, and ignores any except 0-9 and
; comma (uses comma to simulate Smartmodem delay).
;
; After receiving the end-dial sequence (255) the overlay must take
; whatever end-of-dial actions are necessary *including* waiting for
; carrier at the distant end.  The overlay should monitor the keyboard
; during this wait (using the MEX keystat service call), and return
; an exit code to MEX in the A register, as follows:
;
;	0 - Carrier detected, connection established
;	1 - Far end busy (only for modems that can detect this condition)
;	2 - No answer (or timed out waiting for modem response)
;	3 - Keyboard abort (^C only: all others should be ignored)
;	4 - Error reported by modem
;	5 - No ring
;	6 - No dialtone
;
; <No other codes should be returned after an end-dial sequence>
;
; The overlay should not loop forever in the carrier-wait routine, but
; instead use either the overlay timer vector, or the INMDMV (timed 100
; ms character wait) service call routine.
;
; The DIAL routine is free to use any of the registers, but must return
; the above code after an end-dial sequence
;
;
	ORG	0B00H		;maintain official MEX origin
;
DIAL:	LHLD	DIALPT		;FETCH POINTER
	CPI	254		;START DIAL?
	JZ	STDIAL		;JUMP IF SO
	CPI	255		;END DIAL?
	JZ	ENDIAL		;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
	MOV	M,A		;PUT CHAR IN BUFFER
	INX	H		;ADVANCE POINTER
	SHLD	DIALPT		;STUFF PNTR
	RET			;ALL DONE
;
; Here on a start-dial sequence
;
STDIAL:	LXI	H,DIALBF	;SET UP BUFFER POINTER
	SHLD	DIALPT
	RET
;
; Here on an end-dial sequence
;
ENDIAL:	MVI	M,CR		;STUFF END-OF-LINE INTO BUFFER
	INX	H		;FOLLOWED BY TERMINATOR
	MVI	M,0
	LDA	TPULSE		;GET OVERLAY'S TOUCH-TONE FLAG
	STA	SMDIAL+3	;PUT INTO STRING
	LXI	H,SMDIAL	;POINT TO DIALING STRING
	CALL	SMSEND		;SEND IT
WAITSM:	MVI	C,INMDM
	CALL	MEX		;CATCH ANY OUTPUT FROM THE MODEM
	JNC	WAITSM		;LOOP UNTIL NO MORE CHARACTERS
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 60 SECONDS: YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE).
; NOTE THAT THE SMARTMODEM HAS AN INTERNAL 30 SECOND TIMEOUT WHILE
; FOR A CARRIER ON THE OTHER END.  YOU CAN CHANGE BY PLAYING WITH THE
; S7 VARIABLE (I.E. SEND THE SMARTMODEM "AT S7=20" TO LOWER THE 30 SECOND
; WAIT TO 20 SECONDS).
;
RESULT:	MVI	C,60		;<<== MAXIMUM TIME TO WAIT FOR RESULT
SMWLP:	PUSH	B
	MVI	B,1		;CHECK FOR A CHAR, UP TO 1 SEC WAIT
	MVI	C,TMDINP	;DO TIMED INPUT
	CALL	MEX
	POP	B
	JNC	SMTEST		;JUMP IF MODEM HAD A CHAR
	PUSH	B		;NO, TEST FOR CONTROL-C FROM CONSOLE
	MVI	C,CHEKCC
	CALL	MEX
	POP	B
	JNZ	SMNEXT		;IF NOT, JUMP
	MVI	B,CR		;YES, SHUT DOWN THE MODEM
	MVI	C,SNDCHR
	CALL	MEX
	MVI	A,3		;RETURN ABORT CODE
	RET
SMNEXT:	DCR	C		;NO
	JNZ	SMWLP		;CONTINUE
;
; ONE MINUTE WITH NO MODEM RESPONSE (OR NO CONNECTION)
;
SMTIMO:	MVI	A,2		;RETURN TIMEOUT CODE
	RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
SMTEST:	ANI	7FH		;IGNORE ANY PARITY
	CALL	SMANAL		;TEST THE RESULT
	MOV	A,B		;A=RESULT (CY SIGNIFICANT HERE TOO)
	PUSH	PSW		;SAVE IT
SMTLP:	MVI	C,INMDM		;FLUSH ANY REMAINING COMMAND LINE
	CALL	MEX
	JC	SMCHEK		;JUMP IF NO INPUT
	CPI	LF		;GOT SOME ... WAITING FOR EOL
	JNZ	SMTLP		;EAT ANY IN-BETWEEN
SMCHEK:	POP	PSW		;A HAS MEX RETURN-CODE, CY=1 IF UNKNOWN
	JC	RESULT		;IF RESULT UNKNOWN, IGNORE IT
	RET
;
SMANAL:	MVI	B,0		;PREP CONNECT CODE
	CPI	'C'		;"CONNECT"?
	RZ
	CPI	'1'		;NUMERIC VERSION OF "CONNECT"
	RZ
	CPI	'5'		;NUMERIC VERSION OF "CONNECT 1200"
	RZ
	INR	B		;PREP BUSY CODE B=1
	CPI	'B'
	RZ
	INR	B		;PREP NO CONNECT MSG B=2
	CPI	'N'		;N=NO CONNECT
	RZ
	CPI	'3'		;NUMERIC VERSION OF "NO CONNECT"
	RZ
	MVI	B,4		;PREP MODEM ERROR
	CPI	'E'		;E=ERROR
	RZ
	CPI	'4'		;NUMERIC VERSION OF "ERROR"
	RZ
	STC			;UNKNOWN...
	RET
;
;.....
;
; SMARTMODEM UTILITY ROUTINE: SEND STRING TO MODEM
;
SMSEND:	MVI	C,SNDRDY	;WAIT FOR MODEM READY
	CALL	MEX
	JNZ	SMSEND
	MOV	A,M		;FETCH NEXT CHARACTER
	INX	H
	ORA	A		;END?
	RZ			;DONE IF SO
	MOV	B,A		;NO, POSITION FOR SENDING
	MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	CALL	MEX
	JMP	SMSEND
;
; DATA AREA
;
SMDIAL:	DB	'ATDT '
DIALBF:	DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	DS	2		;DIAL POSITION POINTER
;
;
;	>>>>    End of MODEM Specific Overlay

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;		MEXPAT11.ASM	--	Patch file
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; 02/04/85  --	Patches in this file were for the convenience of the
;		author as well as to support a new LSTVEC and LVEC
;		which is in PORT section of this overlay, MXO-AP3x.
;					-- H. Middlebrook
;
; This is the patch file for MEX 1.1 -- you may edit this file to change
; various initial variables. Assemble with ASM or MAC, then use MLOAD
; to patch the changes into MEX:
;
;	ASM MEXPAT11.AAZ			;assemble the edited file
;	MLOAD NEWMEX.COM=MEX.OBJ,MEXPAT10	;patch MEX
;
; You may also pull this file into your modem overlay (be sure you in-
; clude the ORG statement below).
;
; The order of the patch variables supported here will not change from
; version to version (i.e., new items will be added on to the end).
;
;
	ORG	0D00H		;location of patch variables
;
;
;
; The following line defines the MEX service call entry point, and
; is not meant to be changed by the user
;
MEXSTART:	DS	3		;MEX service call processor
		DS	3		;reserved
		DS	1		;reserved
;
; The following line contains the initial free-memory pointer for
; MEX.  Sophisticated modem overlays requiring additional space may change
; this pointer (ie, move it higher), and thus "protect" an area of RAM.
;
MEMRY:	DS	2		;first free memory pointer
;
; Following are the lowest-level vectors for console and list I/O used
; by MEX.  These normally point to routines that save the registers and
; vector to the appropriate BIOS routines.  Complex applications may
; need to intercept (or even replace) these routines.  If you do this,
; be sure to preserve DE, HL and BC.
;
STSVEC:	DS	2		;console status vector
INVEC:	DS	2		;console input vector
OUTVEC:	DS	2		;console output vector
;
; NOTE: The USERPRINTER Equate must be set TRUE or FALSE and the routines
;	must be provided.  The original MEXPAT11 overlay just uses DS 2.
;
	IF	USERPRINTER
LVEC:	DW	WR$PRT		;list output vector
LSTVEC:	DW	PRTSTS		;list status vector
	ENDIF			;USERPRINTER
;
	IF	NOT USERPRINTER
LVEC:	DS	2		;list output vector
LSTVEC:	DS	2		;list status vector
	ENDIF			;NOT USERPRINTER

;
; The following line defines the location of the default MEX prompt.
; If you'd like to provide your own initial prompt, add a DW statement
; pointing to a prompt buffer structured as follows:
;
;		DB <max size of buffer>
;		DB <length of actual prompt>
;		DB <prompt string>
;
; <maxsize> and <length> may be equal (especially if you disable the
; ID command by setting CHGPMT, below to 0); the ID command will, if
; left enabled, be limited to the <max size> value.
;
PROMPT:	DS	2		;prompt location
	DS	1		;reserved
TYPLIN:	DB	22		;for TYPE command: # lines/screen
PAUSFL:	DB	1		;for TYPE cmd: 1=pause 0=no pause
SEPCHR:	DB	';'		;multiple command-line separator
;
; following five for SENDOUT command
;
SOWAIT:	DB	4		;# seconds waiting for a sendout echo
SOREPL:	DB	8		;# seconds waiting for initial reply
SOTRIG:	DB	'>'		;sendout trigger char from remote
CANCHR:	DB	'U'-64		;sendout char to cancel line to remote
SORTRY:	DB	6		;sendout # retries
;
;
HEXFLG:	DB	0		;hex/decimal mode
ESCCHR:	DB	1BH		;terminal mode escape char (1BH = ESC)
NOBELL:	DB	0		;set to 1 to disable bell
;
; Buffer variables.  See BUFFERS.DOC for setup information
;
PSIZE:	DB	2		;default=2k
ASIZE:	DB	255		;"big" capture buffer
XSIZE:	DB	16		;16K transfer buffer
NSIZE:	DB	1		;1k for 85 batch files
PRELEN:	DB	40		;maximum length of PREFIX string
SUFLEN:	DB	40		;maximum length of SUFFIX string
;
; Misc. stuff
;
CDOSFL:	DB	0		;non-zero for CDOS
WTECHO:	DB	0		;non-zero sets "wait-for-echo"
KYSIZE:	DW	400		;size of keystring area, in bytes
CISFLG:	DB	1		;non-zero allows CIS file transfers
CISOK:	DB	1		;non zero allows STAT CIS ON or OFF
CHGPMT:	DB	1		;non-zero allows ID (prompt chg) command
ERRID:	DB	1		;non-zero prints ID msg in err msgs
;
; by setting the following DB to 0, you can disable the HELP
; command, freeing up space used by the help file index.
;
HELPOK:	DB	1		;non-zero allows HELP command
MEXDU:	DB	0		;user \/  alt. area for READ,LOAD,INI.MEX
	DB	0		;drive/\  & HELP.MEX (if SEARCH <>0)
DEBUG:	DB	0		;debugging in term-mode if non-zero
EXCLSY:	DB	1		;non-0 excludes $SYS from batchsend, dir
INIMEX:	DB	0		;non-zero runs INI.MEX at startup
RTIMER:	DB	1		;receiver wait: # seconds [Plouff patch]
PQSIZE:	DW	150		;size of the modem-port queue
PHSIZE:	DB	30		;phone library size (# entries)
SILENT:	DB	0FFH		;0=silence multi-line & READ cmd echo
ALERT:	DB	255		;alert-bell count on CALL complete
EXTEND:	DB	0		;non-zero: unk cmds goto READ processor
SPLIT:	DB	1		;non-zero: phonelib printout, shows baud
SEARCH:	DB	0		;search mode 0,1,2,3
;
; Following is the GLOBAL secondary options table.  To
; set an option to global, change its ASCII character to a 0.
;
RESTT:	DB	'ABDELQRSTVX'
	DS	8		;room for option expansion
;
;
; added on release 1.10:
;
queue:	db	1		;1=allow queueing, 0=no
timbas:	dw	208		;timing constant
mode:	db	0		;mode of modem I/O
sminit:	ds	2		;Smartmodem INIT routine adrs
ssetv:	ds	2		;SSET command: defaulted off
smexit:	ds	2		;Smartmodem EXIT routine adrs
	ds	4		;internal to MEX
sodflg:	db	0		;1=tie SENDOUT to time delay if no WTECHO
autosv:	db	1		;0=initial term mode, save off
tabflg:	db	0ffh		;non-zero=expand tabs within MEX
;
;
;		>>>> End of PATCH Overlay Section <<<<
;
	END
