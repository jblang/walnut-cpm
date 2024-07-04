;	TITLE  'MEX Overlay for Apple ][ / SSC / Smartmodem'
;
;  MXO-AP50.ASM created 02/06/85   by   Henry Middlebrook
;
REV	EQU	50		; 14 Feb 1985
;
; 
; This overlay is specific for the following hardware:
;
;	Apple ][ +/e  with PCPI Applicard
;	Apple Super Serial Card
;	Hayes compatible intelligent modem
;
;			- Henry Middlebrook [70766,766]
;				February 14, 1985
;
; This overlay is written in three distinct parts as a "MIXED" type of
; overlay for MEX.  The parts follow the guidelines available in the
; MEX OVERLAY LIST #2 (01/06/85 -- Ron Fowler, NightOwl Software) with
; reference to the PORT, MODEM, and PATCH overlay types.  Thus, you
; should be able to remove or add any one of the three parts without
; severely affecting the overlay operation.  Naturally, removing the
; first section (PORT) will completely disable MEX; however, removing
; or changing the the MODEM (derived from MXO-SM13.ASM) section or
; the PATCH (MEXPAT11.ASM) will minimally affect operation (see LSTST
; and SSET).
;
; >>>>  NOTE:  	Previous versions of MXO-APxx do NOT properly support
;		the PCPI Applicard.  You may not like this overlay;
;		however, you can use it as a reliable guide.
;
;				HM	02/04/85
;
; To use this overlay just set equates as you see fit, assemble with
; ASM.COM then using MLOAD21.COM and MEX112.COM create running MEX:
;
;	A>MLOAD21 MEX.COM=MEX112.COM,MXO-AP50
;
;----------------------------------------------------------------------
;
;			Overlay Update History
;
; 02/06/85 - Coded for Apple SSC I/O      -AP50 - Henry Middlebrook
; 01/28/85 - Created MXO original overlay -AP30	- Henry Middlebrook
;
;======================================================================

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;			PORT OVERLAY SECTION
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
BELL		EQU	07H	;bell
CR		EQU	0DH	;carriage return
ESC		EQU	1BH	;escape
LF		EQU	0AH	;linefeed
TAB		EQU	09H	;tab
YES		EQU	0FFH
NO		EQU	0
;
;----------------------------------------------------------------------
;
;	Apple Super Serial Card equates
;	-------------------------------
;
SSCSLOT		EQU	2		;Slot of Super Serial Card
;
MODDATP		EQU	0C088H + (SSCSLOT*10H)	;data port of ACIA
MODSTAP		EQU	0C089H + (SSCSLOT*10H)	;status port of ACIA
MODCTLP		EQU	0C08BH + (SSCSLOT*10H)	;control port of ACIA
MODCMDP		EQU	0C08AH + (SSCSLOT*10H)	;command port of ACIA
;
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
MDSNDB		EQU	10H
MDSNDR		EQU	10H
MDRCVB		EQU	08H
MDRCVR		EQU	08H
;
; Equates for PSW (Parity, Stop Bit, Word Length) used by SSC ACIA
;  In these bytes the high nibble is the Word Length mask, the low
;  nibble is the Parity mask for the ACIA PSWFIX routine.
;
P8N1		EQU	010H	;8 NONE 1
P7E1		EQU	036H	;7 EVEN 1
P7O1		EQU	032H	;7 ODD 1
P7N1		EQU	030H	;7 NONE 1
;
BRKMSK		EQU	0CH	;mask byte for BREAK function
DISCB		EQU	0AH	;command byte for ACIA to drop DTR
;
;----------------------------------------------------------------------
;
;	MEX Service Processor Calls
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
MSPEED:	DB	1	;sets display time for sending a file		107H
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
; Jump table accessed by MEX to write/read serial port
;
IN$MODSTAP:	JMP	RD$MODSTAP 	;read ACIA status port		12AH
		DS	7
OUT$MODDATP:	JMP	WR$MODDATP	;send character to ACIA		134H
		DS	7
IN$MODDATP:	JMP	RD$MODDATP	;read character from ACIA	13EH
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
;		*** END OF FIXED FORMAT AREA ***
;
;**********************************************************************
;
;		Overlay  Fixed  Messages  Area
;
EOSMSG:	DB	ESC,0D9H,0,0,'$'	;clear to end of screen message
					;for Videx Videoterm / SOROC
;
CLSMSG:	DB	ESC,0AAH,0,0,'$'	;clear screen message
					;for Videx Videoterm / SOROC
;
VERMSG:	DB	CR,LF,TAB,TAB,'Version for Apple ][ / Applicard'
	DB	CR,LF
	DB	TAB,TAB,' SSC card   '
	DB	'Overlay Version ',REV/10+'0','.'
	DB	REV MOD 10+'0'
	DB	CR,LF,LF,'$'
	DB	0,'Overlay by Henry Middlebrook [70766,766]',0,'$'
;
;----------------------------------------------------------------------
;
; These routines are specific to the Apple ][+ with Applicard.  The
; routines read modem hardware (Apple Super Serial Card ACIA) directly
; from the Applicard.
;
; Read the Command Port of ACIA
;
RD$MODCMDP:	PUSH	D
		LXI	D,MODCMDP
		CALL	PEEK
		POP	D
		RET
;
; Write to the Command Port of ACIA
;
WR$MODCMDP:	PUSH	D
		LXI	D,MODCMDP
		CALL	POKE
		POP	D
		RET
;
; Read the Status Port of the ACIA
;
RD$MODSTAP:	PUSH	D
		LXI	D,MODSTAP
		CALL	PEEK
		POP	D
		RET
;
; Write to the Control Port of the ACIA
;
WR$MODCTLP:	PUSH	D
		LXI	D,MODCTLP
		CALL	POKE
		POP	D
		RET
;
; Read the Control Port of the ACIA
;
RD$MODCTLP:	PUSH	D
		LXI	D,MODCTLP
		CALL	PEEK
		POP	D
		RET
;
; Read Data Port of ACIA
;
RD$MODDATP:	PUSH	D
		LXI	D,MODDATP
		CALL	PEEK
		POP	D
		RET
;
; Write to the Serial Data Port of the ACIA
;
WR$MODDATP:	PUSH	D
		LXI	D,MODDATP
		CALL	POKE
		POP	D
		RET
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
; This routine sends a timed Break to modem from SSC card.
;
SENDBRK:CALL	RD$MODCMDP	;get current command status
	STA	CMDSV
	ORI	BRKMSK		;mask to make ACIA send BREAK
	CALL	WR$MODCMDP	;send command
	MVI	B,5
	MVI	C,TIMER		;wait 500 msecs
	CALL	MEX
	LDA	CMDSV		;get old command state
	CALL	WR$MODCMDP	;put it back
	RET
;
;.....
;
; You can add your own routine here to set DTR low and/or send a break
; tone to disconnect when exiting to CPM.
;
GOODBYE:	RET		;just return so exit to system
				;will not cause disconnect
;
;.....
;
; The following is used to initialize the SSC card for eight data bits,
; no parity, one stop bit, and 300 baud.
;
INITMOD:MVI	A,0BH		;default No Parity byte for ACIA
	STA	PARSV		;save it
	MVI	A,10H		;default 8 Data, 1 Stop Bits for ACIA
	STA	WRDSV		;save it
	MVI	A,1		;300 baud marker for PBAUD
	JMP	PBAUD		;let PBAUD setup ACIA
;
; This is the secondary entry used by the overlay to set baud,
; parity, and stop bit parameters of ACIA.
;
INITMOD1:
	LDA	PARSV		;get current parity byte
	ORI	0BH		;enable DTR, RECV IRQ, and RTS
	STA	CMDSV		;save byte for other uses
	CALL	WR$MODCMDP	;send to command port
	PUSH	H
	LXI	H,BAUDSV	;get address of current baud byte
	LDA	WRDSV		;get current word length byte
	ORA	M		;put 'em together
	STA	CTLSV		;...and save for other uses
	POP	H
	CALL	WR$MODCTLP	;now send to control port
	RET
;
CMDSV:	DB	0		;temporary storage
CTLSV:	DB	0		;temporary storage
;
;.....
;
; This routine drops DTR to force modem to disconnect.  Does NOT do
; any initialization.
;
DISCON:	CALL	RD$MODCMDP	;get current command status
	STA	CMDSV		;save it
	MVI	A,DISCB		;get disconnect byte (drops DTR)
	CALL	WR$MODCMDP	;send to ACIA
	MVI	B,10
	MVI	C,TIMER		;wait 1 second
	CALL	MEX
	LDA	CMDSV		;get back command status
	CALL	WR$MODCMDP	;put it back in ACIA register
	MVI	B,10
	MVI	C,TIMER		;wait another second
	CALL	MEX
	RET			;back to program
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
	ORA	A		;0 means unsupported code
	JZ	PBEXIT		;exit if so
	STA	BAUDSV 		;good rate, save it for INITMOD1
	CALL	INITMOD1	;set baud (and PSW)
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
BAUDTB:	DB	03H,06H,0,07H,0		;110,300,450,610,710
	DB	08H,0AH,0CH,0EH,0FH	;1200,2400,4800,9600,19200
BAUDSV: DB	06H			;current baud byte
;
;.....
;
; Sign-on message
;
SYSVER:	LXI	D,VERMSG
	MVI	C,PRINT
	CALL	MEX
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
SHOTBL:	
	DW	BDSHOW		;displays current baud
	DW	PSWSHOW		;displays current PSW
	DW	TPSHOW		;displays current TPULSE byte (0105H)
	DW	CRLF
	DW	0		;<<== table terminator
;
; SET ?  processor
;
STHELP:	CALL 	CLS			;clear screen
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
	CALL	FIXPSW		;routine to set PARSV and WRDSV
	CALL	INITMOD1	;now fix ACIA registers
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
PSWSET:	DB	010H		;storage and default (8N1)
PARSV:	DB	0BH		;storage and default (no parity)
WRDSV:	DB	010H		;storage and default (8 data, 1 stop bits)
;
FIXPSW:	MOV	A,L		;PSW byte from table
	STA	PSWSET		;save it
	ANI	0F0H		;mask for word length bits
	STA	WRDSV		;put in storage
	LDA	PSWSET		;get back PSW byte
	ANI	0FH		;mask for parity bits
	RLC			;first shift into upper nibble..
	RLC			;...away we go...
	RLC			;.....and go...
	RLC			;......and done
	ORI	0BH		;mask needed for ACIA command register
	STA	PARSV		;put in storage
	RET
;
PSWTBL:	DB	'8N','1'+80H
	DW	P8N1		;filled in with equ's
	DB	'7E','1'+80H
	DW	P7E1		; - ditto -
	DB	'7O','1'+80H
	DW	P7O1		; - ditto -
	DB	'7N','1'+80H
	DW	P7N1		; - ditto -
	DB	0		;<<==== table terminator
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
; Compare next input-stream item in table @DE; CY=1 if not found,
; else HL = matched data item
;
TSRCH:	MVI	C,LOOKUP	;get function code
	JMP	MEX		;pass to MEX processor
;
; Print in-line message ... blows away C register
;
ILPRT:	MVI	C,ILP		;get function code
	JMP	MEX		;go do it
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
; Adapted by Henry Middlebrook (1/85)
;
; NOTE: Some redundant parts of the V1.3 overlay were removed when this
;	section was pulled into MXO-SS30.  See the original overlay for
;	additional information on the history and use of this MODEM
;	specific overlay.		-HM-	2/4/85
;
; Written 04/16/84 by Ronald G. Fowler (V1.0)
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
;
LVEC:	DS	2		;list output vector
LSTVEC:	DS	2		;list status vector
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
