; MXO-TD30.ASM -- TurboDOS overlay for MEX -- Version 3.0 -- 10/04/84
;
;	This overlay is a rather full-featured one.  All of the
;	SET command changes made should remain valid through
;	CLONE operations.  If you are working with a version of
;	TurboDOS greater than 1.22, I make no guarantees about
;	the correctness of the TURBO calls, I have included them
;	simply because I have heard that the later versions are
;	available (I have no way of verifying them).  Just confirm
;	the Turbo Function Call Codes, and set the TURBO2 equate
;	appropriately, and have fun!
;
;    Just for fun (and for space restrictions, and time restrictions),
;    I am using Z80 instructions via MACROs, so use MAC, or
;    decode them your self, its not hard.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts MEX to run under TurboDOS using the Comm Channel
; (the example here is using channel 1).
;
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the SET command to change baud rate if needed.  Also SET-able
; is the parity.  This implements MEX changing the Baud rate.
; All of the values changed by the SET command, should remain
; valid through any CLONE operations.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD21.COM (or later) to combine
;		this overlay with the original MEX10.COM file.  You may
;               optionally combine files for Hayes Smartmodem (MXO-SM13.
;		HEX), Version 1.0C MEX update (MEXFIX.HEX), and buffer size
;		customization (MEXPAT10.HEX) on the same MLOAD command line
;		if you desire.  See MEX10.DOC or MEX-EASY.DOC for details.
;		For example, to prepare a working COM file for use with a
;		Hayes Smartmodem and to incorporate the version 1.0C from
;		MEXNEWS.003, enter the following:
;
;		A>MLOAD21 MEX-TURB.COM=MEX112.COM,MXO-TD30,MXO-SM13,MEXFIX
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 10/04/84 - (Ver 3.0) Fixed SENDOUT "hang"	- Matt Ward (Wacko)
;	     problem, and try to get better
;	     performance re: timing problems
;
; 09/28/84 - (Ver 2.0) Changed labels to 	- Matt Ward (Wacko)
;	     conform to MEX conventions
;
; 09/20/84 - (Ver 1.0) TurboDOS initial		- Matt Ward (Wacko)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0

TURBO2	EQU	YES	; Set to YES if TurboDOS 1.2, 1.22, et al
			; Set to NO if TurboDOS 1.3, 1.4, et al
;
;
BDOS	EQU	005H

	IF	TURBO2
TDOS	EQU	005H
CCS	EQU	87		; Return Comm Channel Status
CCI	EQU	88		; Comm Channel Input
CCO	EQU	89		; Comm Channel Output
CCBR	EQU	90		; Set Comm Channel Baud Rate
	ELSE
TDOS	EQU	050H
CCS	EQU	34		; Return Comm Channel Status
CCI	EQU	35		; Comm Channel Input
CCO	EQU	36		; Comm Channel Output
CCBR	EQU	37		; Set Comm Channel Baud Rate
	ENDIF

BELL	EQU	07H		;bell
CR	EQU	0DH		;carriage return
ESC	EQU	1BH		;escape
LF	EQU	0AH		;linefeed
	PAGE
;
; MEX service processor stuff
;

MEX	EQU	0D00H		; CALL MEX

INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
PRINT	EQU	9
;
;
;  some Turbo stuff:
;
PORT	EQU	002H		;Net/82 SIO channel B base port
MODCT1	EQU	PORT+1		;SIO channel B Command/Status
MODDAT	EQU	PORT		;SIO channel B Data
MODCT2	EQU	PORT+1		;Modem status port
;
CRTN	EQU	00H		; your Console comm channel number
CCN	EQU	01H		; your Modem comm channel number
;				 if using a comm slave, it might look	
;				 like this:
;CNN	EQU	81H
;
EXX	MACRO		
	DB	0D9H
	ENDM
EXAF	MACRO
	DB	008H
	ENDM
LDIR	MACRO		
	DB	0EDH,0B0H
	ENDM
OUTIR	MACRO		
	DB	0EDH,0B3H
	ENDM

	PAGE
;
$-MACRO

	ORG	100H
;
;
; Change the clock speed to suit your system
;
	DS	3	;(for  "JMP   START" instruction)
;
	DS	2
TCHPLS:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:	DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
			;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
			;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
			;default time to send character in ter-
			;minal mode file transfer for slow BBS.
CRDLY:	DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
			;default time for extra wait after CRLF
			;in terminal mode file transfer
COLUMS:	DB	5	;number of DIR columns shown		10AH
SETFL:	DB	YES	;yes=user-defined SET command		10BH
SCRTST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:	DB	YES	;yes=resend a record after any non-ACK	10DH
			;no=resend a record after a valid NAK
BAKFLG:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFL:	DB	YES	;yes=default to CRC checking		10FH
TOGCRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:	DB	NO	;yes=convert backspace to rub		111H
TOGLBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO	;no=no LF after CR to send file in	113H
			;terminal mode (added by remote echo)
TOGLF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRNLOG:	DB	YES	;yes=allow transmission of LOGON	115H
			;write logon sequence at location LOGON
SAVCCP:	DB	NO	;yes=do not overwrite CCP		116H
LOCNXT:	DB	NO	;yes=local command if EXTCHR precedes	117H
			;no=external command if EXTCHR precedes
TOGLOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:	DB	YES	;yes=allow toggling of printer on/off	119H
XOFTST:	DB	NO      ;yes=check for XOFF from remote	while	11AH
			;sending a file in terminal mode
XONWT:	DB	NO	;yes=wait for XON after CR while	11BH
			;sending a file in terminal mode
TOGXOF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:	DB	NO	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:	DB	0	;for future expansion			11EH
EXTRA2:	DB	0	;for future expansion			11FH
BRKCHR:	DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONN:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:	DB	'L'-40H	;^L = Send logon		(LF)	122H
LSTCHR:	DB	'P'-40H	;^P = Toggle printer			123H
UNSVCH:	DB	'R'-40H	;^R = Close input text buffer	(DC4)	124H
TRNCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:	DB	'Y'-40H	;^Y = Open input text buffer    (DC2)	126H
EXTCHR:	DB	'^'-40H	;^^ = Send next character		127H
;
;
	DS	2		;				128H

INCTL1:		; Get modem status byte				12AH
	EXX		; (for Turbo, first swap to alt. regs)	12AH
	MVI	C,CCS	; (use "Return Comm Channel Status")	12BH
	MVI	D,CCN	; (comm channel for Modem)		12DH
	CALL	TDOS	;					12FH
	EXX		; (swap back to default regs)		132H
	RET		; (and return, whew it fits)		133H
;
OTDATA:	JMP	TRBOMO	;out modem data port			134H
	DS	7
;
INPORT:	JMP	TRBOMI	; Get data from modem data port		13EH
	DS	7
;
MASKR:	ORA	A ! RET ! RET	;bit to test for receive ready	148H
TESTR:	CPI	0FFH	! RET	;value of receive bit when rdy	14BH
MASKS:	XRA	A ! RET ! RET	;bit to test for send ready	14EH
TESTS:	CPI	0	! RET	;value of send bit when ready	151H
;
; Unused area:  was once used for special PMMI functions,
; Now used only to retain compatibility with MDM overlays.
; You may use this area for any miscellaneous storage you'd
; like but the length of the area *MUST* be 12 bytes (decimal)
;
	DS	12		;				154H
;
LOGON:	DS	2		;not used			160H
DIALV:	DS	3		; (I'm using the mxo-sm13)	162H
DISCV:	DS	3		;				165H
GOODBV:	JMP	GOODBYE		;				168H
INMODV:	JMP	INITMOD		;go to user written routine	16BH
NEWBDV:	JMP	PBAUD		;set baud rate			16EH
NOPARV:	RET  !	NOP  !	NOP	;by-passes PMMI routine		171H
PARITV:	RET  !	NOP  !	NOP	;by-passes PMMI routine		174H
SETUPV:	JMP	SETCMD		;process SET comand		177H
SPMENV:	DS	3		;not used			17AH
VERSNV:	JMP	SYSVER		;				17DH
BREAKV:	JMP	SENDBRK		;				180H
;
;
; The following jump vector provides the overlay with access to special
; routines in the main program (retained and supported in the main pro-
; gram for MDM overlay compatability).  These should not be modified by
; the overlay.
;
; Note that for MEX 2.0 compatability, you should try to not use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).
;				suggest replace with:
ILPRTV:	DS	3		; MEX function 9		183H
INBUFV:	DS	3		; MEX function 10		186H
ILCMPV:	DS	3		; MEX function 247		189H
INMDMV:	DS	3		; MEX function 255		18CH
NXSCRV:	DS	3		; not supported			18FH
TIMERV:	DS	3		; MEX function 254		192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLS is clear
; entire screen.
;
CLREOS:	LXI	D,EOSMSG	; N.B.  MY clear clreos fit	195H
	JMP	MEXPRT		; in 3 bytes, YOURS may not	198H
				; so watch the addresses.
EOSMSG:	DB	ESC,'y$'	;				19BH
;
CLS:	LXI	D,CLSMSG	;				19EH
MEXPRT:	MVI	C,PRINT		; this entry saves a few bytes	1A1H
	CALL	MEX		;				1A3H
	RET
;
;-----------------------------------------------------------------------
;
;         *******    End of fixed format area    ********
;
;.....
;
;-----------------------------------------------------------------------
;
; NOTE:  The end of your last routine should terminate by 0B00H if
;	 using the Hayes Smartmodem or by address 0D00H otherwise.
;
;-----------------------------------------------------------------------
;
;
CLSMSG:	DB	01AH,'$'
;
SYSVER:	LXI	D,SYSVERMSG	; at sign-on, print the whole thing
SHOW0:	CALL	MEXPRT
	LXI	D,COMMAMSG
	CALL	MEXPRT		; for "SET ?", just the configuration
	LDA	MSPEED		; let MEX print the current Baud Rate
	MVI	C,PRBAUD
	CALL	MEX
	LXI	D,CRLF
	CALL	MEXPRT
	LXI	D,CRLF
	CALL	MEXPRT
	RET
;
SYSVERMSG:
	DB	LF,'For TurboDOS 1.2,  Comm Channel '
	DB	CCN+'0',CR,LF
SHOWMSG:DB	'('
SYSVR1:	DB	'8 data bits, 1 stop bit, '
SYSVR2:	DB	'no',0,0,' parity)$'

COMMAMSG:
	DB	', $'
;
nonmsg:	db	'no',0,0
evnmsg:	db	'even'
oddmsg:	db	'odd',0
;
;.....
;
; Here is the TurboDOS version for OTDATA, it doesn't fit
; in the ten (10 decimal) bytes allowed for I/O primitives above:
;
TRBOMO:	EXX		; (swap to alt. regs)
	MOV	E,A	; (move data byte to [E] for funct CCO)
	EXAF		; (swap to alt. AF reg)
	MVI	C,CCO	; (use "Output Character to Comm Channel")
	MVI	D,CCN	; (comm channel for Modem)
	CALL	TDOS
	EXAF		; (swap back to default AF)
	EXX		; (swap back to default regs)
	RET

;
;.....
;
;	(Version 3.0)
;
; Here is the TurboDOS version for INPORT, it normally would fit
; in the ten (10 decimal) bytes allowed for I/O primitives above,
; but I am trying to make sure that a char REALLY is waiting for
; us to read (it may affect SENDOUT and others):
;
TRBOMI:		; Get data from modem data port
	EXX		; (for Turbo, first swap to alt. regs)
	MVI	C,CCS	; (use "Return Comm Channel Status")
	MVI	D,CCN	; (comm channel for Modem)
	CALL	TDOS	;  to see if a char is REALLY there
	ORA	A	;  well, was there?
	JZ	MIOUT	;  nope, return a NUL
	MVI	C,CCI	; ("Input Character from Comm Channel")
	MVI	D,CCN	; (comm channel for Modem)
	CALL	TDOS
MIOUT:	EXX		; (swap back to default regs)
	RET		; (and return, whew it fits)


;
;-----------------------------------------------------------------------
;.....
;
;
; This routine interprets the SET command parameters.  Everything
; set here should be valid through CLONING.
;
SETCMD:	MVI	C,SBLANK	; check for any arguments
	CALL	MEX
	JC	HELPER		; if none, tell how to use SET
	LXI	D,CMDTBL	; look for an argument
LOOK:	MVI	C,LOOKUP	; (common lookup entry and go code)
	CALL	MEX
	PUSH	H		; push-down address to jmp to
	RNC			; 'RET' there if valid
	POP	H		; oops, pop to keep stack valid
HELPER:	LXI	D,HLPMSG	; and tell how to use
	CALL	MEXPRT
	RET

BAUDCMD:
	MVI	C,BDPARS	; let MEX decode which rate he wants
	CALL	MEX
	JC	SHOWBD		; if couldn't find it, show current Baud
	CALL	PBAUD		; if not oops, try to set
	JC	HELPER		; if wouldn't set, show how to use
	LXI	D,HEREBD	; say "Modem speed set to: "
	CALL	MEXPRT
	LDA	MSPEED
	MVI	C,PRBAUD	; and show how we set it
	CALL	MEX
	RET

SHOWBD:	LXI	D,CURRBD	; For no args on SET BAUD line,
	CALL	MEXPRT		; show current Baud Setting
	LDA	MSPEED
	MVI	C,PRBAUD
	CALL	MEX
	RET

PARITCMD:
	MVI	C,SBLANK	; Look for any args
	CALL	MEX
	JC	SHOWPR		; if none, show current settings
	LXI	D,PARITBL	; look for parity arguments
	JMP	LOOK

SHOWPR:	LXI	D,CURRPR	; For no args on SET PARITY line,
	CALL	MEXPRT		; show current parity setting
	LXI	D,SHOWMSG
	CALL	MEXPRT
	RET

NONE:	LXI	H,NONMSG	; set up to put "no",NUL,NUL in sign-on
	LXI	D,CONTROLN	; set up to tell SIO: 8 bits, no parity
	MVI	A,'8'		; set up to put "8" bits in sign-on
	JMP	PARITGO
ODD:	LXI	H,ODDMSG	; set up to put "odd",NUL in sign-on
	LXI	D,CONTROLO	; set up to tell SIO:  7 bits, odd
	JMP	EORO
EVEN:	LXI	H,EVNMSG	; set up to put "even" in sign-on
	LXI	D,CONTROLE	; set up to tell SIO:  7 bits, even
EORO:	MVI	A,'7'		; set up to put "7" bits in sign-on
PARITGO:STA	SYSVR1	; stash data bits message in sign-on message
	PUSH	D		; save SIO control stuff
	LXI	D,SYSVR2	; stash parity configuration in sign-on
	LXI	B,4
	LDIR
	POP	H		; get back SIO stuff
	LXI	D,SETMODCTL	; stash it where INITMOD can get to it
	LXI	B,8		; (i.e. after cloning)
	LDIR
	LXI	D,HEREPR	; say "Parity set to:"
	CALL	MEXPRT
	LXI	D,SHOWMSG	; and show them
	CALL	MEXPRT

INITALSO:			; INITMOD comes here, too
	LXI	H,SETMODCTL	; really tell the SIO how to do it
	LXI	B,0800H+MODCT1
	DI
	OUTIR
	EI
	RET

PBAUD:	PUSH	H
	PUSH	D
	PUSH	B
	MOV	E,A		; get MEX value
	MVI	D,0		; index into Turbo values
	LXI	H,TBAUDTBL
	DAD	D
	MOV	A,M		; take a peek
	ORA	A		; was it valid?
	STC			; set up to say "not valid"
	JZ	PBEXIT		; and return if it was not valid
	MOV	A,E		; get back MEX value
	STA	MSPEED		; record for MEX what we are doing
	MOV	E,M		; get back Turbo value
	MVI	D,CCN		; and set the Baud Rate
	MVI	C,CCBR		; (use "Set Comm Channel Baud Rate")
	CALL	TDOS
	XRA	A		; tell, "no errors"
PBEXIT:	POP	B
	POP	D
	POP	H
	RET

INITMOD:
	LDA	MSPEED		; get value from last clone
	CALL	PBAUD		; set the rate
	JMP	INITALSO	; and initialize SIO from last clone

SHOW:	LXI	D,CURRST	; say "Current settings:"
	CALL	MEXPRT
	LXI	D,SHOWMSG	; display current parameters	
	JMP	SHOW0

CMDTBL:	DB	'?'+80H
	DW	SHOW
	DB	'BAU','D'+80H
	DW	BAUDCMD
	DB	'PARIT','Y'+80H
	DW	PARITCMD
	DB	0

PARITBL:DB	'EVE','N'+80H
	DW	EVEN
	DB	'E'+80H
	DW	EVEN
	DB	'OD','D'+80H
	DW	ODD
	DB	'O'+80H
	DW	ODD
	DB	'NON','E'+80H
	DW	NONE
	DB	'N'+80H
	DW	NONE
	DB	0

TBAUDTBL: ;  Turbo code   MSPEED code 	     Baud rate
	db	0	;     0	(not supported)	110
	db	5	;     1			300
	db	0	;     2	(not supported)	450
	db	6	;     3			600
	db	0	;     4	(not supported)	710
	db	7	;     5			1200
	db	10	;     6			2400
	db	12	;     7			4800
	db	14	;     8			9600
	db	15	;     9			19200
;
setmodctl:		; this is how I/O is set as default:
	db	0,0,4
sioWR4:	db	046h	; x16 Clock Rate, 1 stop bit, even parity, disabled
	db	3
sioWR3:	db	0c1h	; Rxd 8 data bits, Rx enabled
	db	5
sioWR5:	db	0eah	; DTR, Txd 8 data bits, Tx enabled, RTS

CONTROLN:    ;	This is to init the SIO for 8 data bits, no parity
	DB	0,0,4,046H,3,0C1H,5,0EAH
CONTROLE:    ;	This is to init the SIO for 7 data bits, even parity
	DB	0,0,4,047H,3,041H,5,0AAH
CONTROLO:    ;	This is to init the SIO for 7 data bits, odd parity
	DB	0,0,4,045H,3,041H,5,0AAH
;
;-----------------------------------------------------------------------
;.....
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  DI
	  MVI	A,5		; select Write Register 5
	  OUT	MODCT1
	  lda	sioWR5		; get Current value for WR5
	  ori	010h		; 'or'-in the Break bit
	  JMP	GOODBYE1
;.....
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBYE:  DI
	  MVI	A,5
	  OUT	MODCT1		;SEND TO THE STATUS PORT
	  MVI	A,78H		;TURN OFF DTR, SEND BREAK
;
GOODBYE1: OUT	MODCT1
	  EI
	  MVI	B,3		;WAIT FOR 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  DI
	  MVI	A,5
	  OUT	MODCT1
	  lda	sioWR5		;RESTORE TO NORMAL, current value of WR5
	  OUT	MODCT1
	  EI
	  RET
;.....
HLPMSG:	DB	LF
	DB	'     SET                            (show this message)',CR,LF
	DB	'     SET ?                    (show current parameters)',CR,LF
	DB	'     SET PARITY <  E(ven)  |  O(dd)  |  N(one)  >',CR,LF
	DB	'     SET BAUD <rate>',CR,LF
	DB	'      rate choices:  300 600 1200 2400 4800 9600 19200'
	DB	CR,LF
CRLF:	DB	CR,LF,'$'

HEREBD:	DB	'Modem Speed set to:  $'
HEREPR:	DB	'Parity set to:  $'
CURRBD:	DB	'Current BAUD Rate:  $'
CURRPR:	DB	'Current PARITY setting:  $'
CURRST:	DB	'Current settings:',CR,LF,'$'
;
;-----------------------------------------------------------------------
;
;
; NOTE:  This code patch below needs the ORG and DW's just below it.
;
;  Here below is a slight Turbo "speed-up" patch which is included
;  for the following reasons:
;
;  1)  Since the BIOS vector supplied by TurboDOS for compatability
;	with CP/M is not a real vector, but each JMP simply goes to
;	some code that simulates the BIOS call via BDOS, we might as
;	well do the register loads here, rather than Turbo doing it.
;	(I know, all we save is a JMP instruction)
;
;  2)  Since we have available to us the INI.MEX startup file, it
;	seems ridiculous to allow .DO file processing through MEX,
;	so by using the comm channel routines for CONSOLE stuff,
;	Turbo will not look at any active .DO files.
;
;  3)  It has been observed (mainly while running WordStar) in a
;	Turbo environment that whenever the console status is
;	examined, there appears to be some handshaking being done
;	with the Master Processor EVERY TIME you do a CONSTAT.  So
;	I have included the following TUCONST that I have running in
;	my WordStar to attempt to alleviate some of the Timing
;	problems with MEX under Turbo.  It simply returns a "no
;	character waiting" status every even try, and the real status
;	every odd try.

TUCONST:
	EXX		; (save HL, DE, BC)
	LXI	H,TUTEST
	INR	M		; INCREMENT COUNTER
	DB	0CBH,46H	;  z80 instruction:  BIT 0,(HL)
	MVI	A,0		; RETURN ZERO AS STATUS
	JZ	TUBYE
	MOV	M,A		; STUFF A ZERO
	MVI	C,CCS		; return console status
	MVI	D,CRTN
	CALL	TDOS
TUBYE:	EXX		; (restore HL, DE, BC)
	RET

TUTEST: DB	0

TUCI:	EXX		; (save HL, DE, BC)
	MVI	C,CCI		; input char from comm channel (bypass .DO)
	MVI	D,CRTN		; (console comm channel number)
	CALL	TDOS
	EXX		; (restore HL, DE, BC)
	RET

;
;-----------------------------------------------------------------------
;
;
; NOTE:  This patch is what implements the above TUCONST and TUCI.

	ORG	0D09H

STSVEC:	DW	TUCONST		;console status vector
INVEC:	DW	TUCI		;console input vector

;
;-----------------------------------------------------------------------
;
;	(Version 3.0)
;
; NOTE:  This patch tries to get a little more speed out of timed loops.

	ORG	0D52H

timbas:	dw	16		;timing constant (originally = 208)

	  END
