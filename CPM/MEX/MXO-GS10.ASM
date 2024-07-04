;	TITLE  'MEX Overlay for Apple ][ / IIgs port / Smartmodem'
;
;  MXO-GS10.ASM created 11/11/88   by   Nick Sayer
;
REV	EQU	10		; Nov 11, 1988
;
; 
; This overlay is specific for the following hardware:
;
;	Apple ][ +/e  with PCPI Applicard
;	Apple IIgs Modem Port
;	Hayes compatible intelligent modem
;
;			- Nick Sayer (N6QQQ)
;				November 11, 1988
;
; Kudos to Henry Middlebrook for this overlay. I used his overlay outline,
; deleted his most of the hardware specific code and replaced it with a
; fleshed out version of a similar overlay I wrote for IMP245.COM.
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
; 11/11/88 - Coded for Apple IIgs I/O     -GS10 - Nick Sayer
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
MSPEED:	DB	6	;sets display time for sending a file		107H
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
BRKCHR:	DB	'B'-40H	;^@ = Send a 300 ms. break tone			120H
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
VERMSG:	DB	CR,LF,TAB,TAB,'  Version for Apple ][ / Applicard'
	DB	CR,LF
	DB	TAB,TAB,'IIgs modem port  '
	DB	'Overlay Version ',REV/10+'0','.'
	DB	REV MOD 10+'0'
	DB	CR,LF,LF,'$'
	DB	0,'Overlay by Nick Sayer (N6QQQ)',0,'$'
;
;----------------------------------------------------------------------
;
; These routines are specific to the Apple ][+ with Applicard.  The
; routines read modem hardware (Apple Super Serial Card ACIA) directly
; from the Applicard.
;

;====================== CUSTOMIZATION EQUATES ==========================
;
SLOT	EQU	2		; Slot of serial interface
SLOTOFF	EQU	16*SLOT		; Hardware offset for $C0(8+n)0
SLOTOF2	EQU	256*SLOT	; Firmware offset for $Cn00
;
MDRCVR	EQU	1		; Bit to test for char present
MDRCVB	EQU	1		; Compare mask to test for char present
MDSNDR	EQU	4		; Bit to test for send ready
MDSNDB	EQU	4		; Compare mask to test for send ready
;-----------------------------------------------------------------------
;
; This routine sends a break tone for 300 ms
;
SENDBRK:
	MVI	B,0		; Param doesn't matter
	MVI	C,'S'		; Ctrl-A + S is send break
	JMP	GSCMD		; Send it out
;
;	CALL	CMDENA		; Enable Ctrl-A commands
;	MVI	A,01H		; Ctrl-A
;	CALL	GSSEND		; Send it out
;	MVI	A,'S'		; Ctrl-A + S is send-break command
;	CALL	GSSEND		; Send it out
;	JMP	CMDDIS		; Disable Ctrl-A commands and return
;
;
; This routine sets DTR low for 300 ms to disconnect the phone
;
DISCON:
	MVI	A,0FFH		; Lower DTR
	CALL	CMDDTR		; Set DTR status
	MVI	B,3
	MVI	C,TIMER		; Delay 300 ms
	CALL	MEX
	MVI	A,00H		; Bring DTR back
	CALL	CMDDTR		; Set DTR status
	RET
;
;.....
;
GOODBYE:
	RET			; Nothing to do when exiting
;
;.....
;
;
;=========================== INITMOD ===================================
;
;
INITMOD:
	CALL	GSINIT		; Init via 6502 routines
;
	MVI	A,0
	STA	PARSV
	STA	WRDSV		; 8N1
	LDA	MSPEED		; Get default speed
	JMP	PBAUD		; Let PBAUD do the work
;
INITMOD1:
	LDA	BAUDSV		; Get baud chars
	MOV	B,A
	MVI	C,'B'		; Baud setting char
	CALL	GSCMD		; Do it
	LDA	PARSV		; Get parity value
	MOV	B,A
	MVI	C,'P'		; Parity command
	CALL	GSCMD		; Do it
	LDA	WRDSV		; Get word format char
	MOV	B,A
	MVI	C,'D'		; Fall into GSCMD
;
; GSCMD takes a BCD number in B and an ascii character in C and sends
; them out with a ctrl-A and enabled commands.
;
GSCMD:	PUSH	H
	PUSH	D
	PUSH	B
	CALL	CMDENA		; Enable Ctrl-A commands
	MVI	A,81H		; Send a Ctrl-A
	CALL	GSSEND		; Send it
	POP	B		; Get Char back
	PUSH	B		; And save it again
	MOV	A,B
	RAR
	RAR
	RAR
	RAR
	CALL	SENDHX
	POP	B
	PUSH	B
	MOV	A,B
	CALL	SENDHX
	POP	B
	PUSH	B
	MOV	A,C
	CALL	GSSEND
	CALL	CMDDIS		; Disable Ctrl-A cmds and return
	POP	B
	POP	D
	POP	H
	RET
SENDHX:	ANI	0FH
	ORI	0B0H		; Make it a number
	JMP	GSSEND		; Send it and ret
;
;.....
;
;
;========================== APPLE I/O ==================================
;
RDBYTE:	EQU	0FFE0H		; Read 1 byte from Apple (A = byte)
WRBYTE:	EQU	0FFE3H		; Write 1 byte to Apple (C = byte)
RDWORD:	EQU	0FFE6H		; Read 2 bytes from Apple (DE = word)
WRWORD:	EQU	0FFE9H		; Write 2 bytes to Apple (DE = word)
WRLOTS:	EQU	0FFEFH		; FROM (HL), SEND NUM BYTES IN DE TO HOST
POKLOT:	EQU	2
CALL1:	EQU	3
PEEK1:	EQU	6		; Command
POKE1:	EQU	7		; Command
;
POKE:	MOV	B,A
	MVI	C,POKE1
	CALL	WRBYTE
	CALL	WRWORD
	MOV	C,B
	CALL	WRBYTE
	RET
;
PEEK:	MVI	C,PEEK1
	CALL	WRBYTE
	CALL	WRWORD
	CALL	RDBYTE
	RET
;
CALL65:	MVI	C,CALL1
	CALL	WRBYTE
	CALL	WRWORD
	RET
;
GSINIT:				; Initialize and move 6502 code in
;
	LXI	D,0C00DH+SLOTOF2
	CALL	PEEK
	STA	INITPT
;
	LXI	D,0C00FH+SLOTOF2
	CALL	PEEK
	STA	WRITPT
;
	LXI	D,0C00EH+SLOTOF2
	CALL	PEEK
	STA	READPT
;
	LXI	D,0C012H+SLOTOF2
	CALL	PEEK
	STA	EXTPT
;
	MVI	C,POKLOT	; Going to put the 6502 code in place
	CALL	WRBYTE
	LXI	D,0300H		; Put it at 300H
	CALL	WRWORD
	LXI	D,END65-ST65+1	; Length
	CALL	WRWORD
	LXI	H,ST65
	LXI	D,END65-ST65+1
	CALL	WRLOTS		; Put it in place
;
	LXI	D,INIT65
	CALL	CALL65
	RET
;
ST65:
	DB	04CH,013H,003H	; 	JMP	INIT
	DB	04CH,01AH,003H	; 	JMP	READ
	DB	04CH,024H,003H	; 	JMP	WRITE
	DB	04CH,02FH,003H	; 	JMP	SETDTR
	DB	04CH,03EH,003H	; 	JMP	SETCMD
	DB	04CH,06AH,003H	; 	JMP	STATUS
	DS	1		; DATA	DFS	1
	DB	0A2H,0C0H+SLOT	; INIT	LDX	#Cn
	DB	0A0H,SLOTOFF	;	LDY	#n0
	DB	04CH
INITPT	DS	1		;
	DB	0C0H+SLOT	;	JMP	CARD_INIT
	DB	0ADH,012H,003H	; WRITE	LDA	DATA
	DB	0A2H,0C0H+SLOT	;	LDX	#Cn
	DB	0A0H,SLOTOFF	;	LDY	#n0
	DB	04CH
WRITPT	DS	1
	DB	0C0H+SLOT	;	JMP	CARD_WRIT
	DB	0A2H,0C0H+SLOT	; READ	LDX	#Cn
	DB	0A0H,SLOTOFF	;	LDY	#n0
	DB	020H
READPT	DS	1
	DB	0C0H+SLOT	;	JSR	CARD_READ
	DB	08DH,012H,003H	;	STA	DATA
	DB	060H		;	RTS
	DB	0ADH,012H,003H	;SETDTR	LDA	DATA
	DB	08DH,07EH,003H	;	STA	DTRBYT
	DB	0A9H,07AH	;	LDA	#>DTRBUF
	DB	0A2H,003H	;	LDX	#<DTRBUF
	DB	0A0H,000H	;	LDY	#00
	DB	04CH
EXTPT	DS	1
	DB	0C0H+SLOT	;EXTJMP	JMP	CARD_EXT
	DB	0A9H,000H	;SETCMD	LDA	#00
	DB	08DH,081H,003H	;	STA	CMDSPOT
	DB	0A9H,080H	;	LDA	#>CMDBUF
	DB	0A2H,003H	;	LDX	#<CMDBUF
	DB	0A0H,000H	;	LDY	#00
	DB	020H,03BH,003H	;	JSR	EXTJMP
	DB	0ADH,086H,003H	;	LDA	CMDBYT
	DB	02CH,012H,003H	;	BIT	DATA
	DB	010H,003H	;	BPL	SKIP
	DB	029H,07FH	;	AND	#7F
	DB	02CH		;	DFB	$2CH	;SKIP 2 BYTES
	DB	009H,080H	; SKIP	ORA	#80
	DB	08DH,086H,003H	;	STA	CMDBYT
	DB	0A9H,001H	;	LDA	#01
	DB	08DH,081H,003H	;	STA	CMDSPOT
	DB	0A9H,080H	;	LDA	#>CMDBUF
	DB	0A2H,003H	;	LDX	#<CMDBUF
	DB	0A0H,000H	;	LDY	#00
	DB	04CH,03BH,003H	;	JMP	EXTJMP
	DB	0A9H,088H	;STATUS	LDA	#>STATBUF
	DB	0A2H,003H	;	LDX	#<STATBUF
	DB	0A0H,000H	;	LDY	#0
	DB	020H,03BH,003H	;	JSR	EXTJMP
	DB	0ADH,08CH,003H	;	LDA	STATBYT
	DB	08DH,012H,003H	;	STA	DATA
	DB	060H		;	RTS
	DB	003H,00BH	;	DFB	03,0B
	DS	4		;	DFS	4
	DB	003H,001H	;	DFB	03,01
	DS	6		;	DFS	6
	DB	003H,006H	;	DFB	03,06
	DS	4		;	DFS	4
END65:	DS	1
;
INIT65:	EQU	0300H
WRIT65:	EQU	0303H
READ65:	EQU	0306H
SDTR65:	EQU	0309H
SCMD65:	EQU	030CH
STAT65:	EQU	030FH
DATA65:	EQU	0312H
;
RD$MODDATP:			; Read a character
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	D,READ65
	CALL	CALL65
	LXI	D,DATA65
	CALL	PEEK
	POP	H
	POP	D
	POP	B
	RET
WR$MODDATP:			; Write a character, or a command byte
GSSEND: PUSH	B
	PUSH	D
	PUSH	H
	LXI	D,DATA65
	CALL	POKE
	CALL	CALL65
	POP	H
	POP	D	
	POP	B
	RET
RD$MODSTAP:			; Get status byte
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	D,STAT65
	CALL	CALL65
	LXI	D,DATA65
	CALL	PEEK
	POP	H
	POP	D
	POP	B
	RET
CMDENA:				; Enable Ctrl-A cmds in out stream
	MVI	A,0FFH
	LXI	D,DATA65
	CALL	POKE
	LXI	D,SCMD65
	JMP	CALL65
CMDDIS:				; Disable Ctrl-A cmds in out stream
	MVI	A,000H
	LXI	D,DATA65
	CALL	POKE
	LXI	D,SCMD65
	JMP	CALL65
CMDDTR:				; Bit 7 of A is new DTR state
	LXI	D,DATA65
	CALL	POKE
	LXI	D,SDTR65
	JMP	CALL65
;
;-----------------------------------------------------------------------
;
;.....
;
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
	DB	08H,10H,12H,14H,15H	;1200,2400,4800,9600,19200
BAUDSV: DB	10H			;current baud byte
;
; Parity/wordlen table equates
;
P8N1		EQU	000H	;8 NONE 1
P7E1		EQU	013H	;7 EVEN 1
P7O1		EQU	011H	;7 ODD 1
P7N1		EQU	010H	;7 NONE 1
;
;----------------------------------------------------------------------
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
PSWSET:	DB	00H		;storage and default (8N1)
PARSV:	DB	00H		;storage and default (no parity)
WRDSV:	DB	00H		;storage and default (8 data, 1 stop bits)
;
FIXPSW:	MOV	A,L		;PSW byte from table
	STA	PSWSET		;save it
	ANI	0FH		;mask low for parity bits
	STA	PARSV		;put in storage
	LDA	PSWSET		;get back PSW byte
	RAR			;first shift into lower nibble..
	RAR			;...away we go...
	RAR			;.....and go...
	RAR			;......and done
	ANI	0FH		;mask for word bits
	STA	WRDSV		;put in storage
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
