
; MXO-BBI0.ASM --
;	Big Board I (& incidentally XEROX 820, II) overlay file for
;	MEX10. 16 June 1985
;
; You will want to look this file over carefully.  There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Big Board I to MEX Version 1.0.  This overlay
; is not intended to support MDM7xx in any of it's incarnations.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.  Please note the
; extensions to the SET command below.  You may now set the parity,
; word size, & number of stop bits in addition to the baud rate.  The
; SET command also implements a local help file.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 06/18/85 - Removed auto-baud bug & added	- Richard Williams
;            help file.
; 06/16/85 - Expanded SET command & cleaned	- Richard Williams
;            up listing for 80 columns.
; 11/12/84 - Addapted to Big Board I		- Richard Williams
; 05/24/84 - MEXified overlay			- Biff Bueffel
; 11/11/83 - Renamed to M7XE-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 03/03/83 - Modified MDM705KP for XEROX
;            820-II computers with external
;            modems				- David Wurz	
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; The obligatory equates...
;
YES:		EQU	0FFH
NO:		EQU	0
;	
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Here are the equates for the conditional assembly switches...
;
; Two serial ports are available.  See initialization area for info.
; Port A is the commonly used port.
PORT$A	EQU	YES		;set to no for Port B
PORT$B	EQU	NOT PORT$A
;
; This overlay can display the port status on every invocation of the
; set baud routine (ALWAYS = YES) or will display the status on a null
; argument SET command and/or a SET command with only the expanded
; arguments (ALWAYS =NO).  If ALWAYS = YES, then the port status will
; also be displayed on an auto baud rate change from the phone
; directory.
ALWAYS	EQU	NO		;do not display port status
;				; on every change.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Instruction equates...
;
IN$RET	EQU	0C9H	;unconditional return
IN$MVI	EQU	03EH	;move immediate to reg. A
IN$ANI	EQU	0E6H	;AND immediate with reg. A
IN$ORI	EQU	0F6H	;OR immediate with reg. A
IN$LHLD	EQU	02AH	;load reg. HL at address
IN$EOC	EQU	076H	;End Of Coffee
;
; Character equates...
;
BELL:	EQU	007H	;bell
CR:	EQU	00DH	;carriage return
ESC:	EQU	01BH	;escape
LF:	EQU	00AH	;linefeed
;
; MEX service processor stuff...
;
MEX	EQU	0D00H	;address of the service processor.
INMDM	EQU	255	;get char from port to A, CY=no more within 100 ms.
TIMER	EQU	254	;delay 100ms * reg B.
TMDINP	EQU	253	;B=# secs to wait for char, cy=no char.
CHEKCC	EQU	252	;check for ^C from KBD, Z=present.
SNDRDY	EQU	251	;test for modem-send ready.
RCVRDY	EQU	250	;test for modem-receive ready.
SNDCHR	EQU	249	;send a character to the modem (after sndrdy).
RCVCHR	EQU	248	;receive a char from the modem (after rcvrdy).
LOOKUP	EQU	247	;table search: see CMDTBL comments for info.
PARSFN	EQU	246	;parse filename from input stream.
BDPARS	EQU	245	;parse baud-rate from input stream.
SBLANK	EQU	244	;scan input stream to next non-blank.
EVALA	EQU	243	;evaluate numeric from input stream.
LKAHED	EQU	242	;get next char w/o removing from input.
GNC	EQU	241	;get char from input, cy=1 if none.
ILP	EQU	240	;inline print.
DECOUT	EQU	239	;decimal output.
PRBAUD	EQU	238	;print baud rate.
;
PRINT	EQU	9	;MEX/BDOS print-string function call.
;
; MEX baud rate command numbers...
;
C110	EQU	000H	; 110 baud
C300	EQU	001H	; 300 baud
C450	EQU	002H	; 450 baud  ** not supported on this machine **
C600	EQU	003H	; 600 baud
C710	EQU	004H	; 710 baud  ** not supported on this machine **
C1200	EQU	005H	; 1200 baud
C2400	EQU	006H	; 2400 baud
C4800	EQU	007H	; 4800 baud
C9600	EQU	008H	; 9600 baud
C19200	EQU	009H	; 19200 baud
CERROR	EQU	0FFH	; for `unrecognized' baud rates.
;
	ORG	100H
	DS	3	;(for  "JMP   START" instruction)
;
; MEX variables, constants, flags, & what have you...
;
PMMI:	DB	NO	;yes=PMMI S-100 Modem			103H
SMDM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TORP:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
			;
			;  Change the clock speed to suit
			;  your system...
CLOCK:	DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
			;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
			;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
			;default time to send character in ter-
			;minal mode file transfer for slow BBS.
CRDLY:	DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
			;default time for extra wait after CRLF
			;in terminal mode file transfer
			;
NUMCOL:	DB	5	;number of DIR columns shown		10AH
USET:	DB	YES	;yes=user-added Setup routine		10BH
SCRN:	DB	YES	;Cursor control routine			10CH
			;
ACKNAK:	DB	YES	;yes=resend a record after any non-ACK	10DH
			;no=resend a record after a valid NAK
BAKUP:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDEF:	DB	YES	;yes=default to CRC checking		10FH
CRCTOG:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
			;
CNVRUB:	DB	NO	;yes=convert backspace to rub		111H
TOGRUB:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO	;no=no LF after CR to send file in	113H
			;terminal mode (added by remote echo)
TOGLF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRNLOG:	DB	YES	;yes=allow transmission of logon	115H
			;write logon sequence at location LOGON
SAVCCP:	DB	YES	;yes=do not overwrite CCP		116H
LCLNXT:	DB	NO	;yes=local command if EXTCHR precedes	117H
			;no=external command if EXTCHR precedes
LCLTGL:	DB	YES	;yes=allow toggling of LCLNXT		118H
LSTTST:	DB	YES	;yes=printer available on printer port	119H
XOFFT:	DB	YES	;yes=check for XOFF from remote	while	11AH
			;sending a file in terminal mode
XONWT:	DB	NO	;yes=wait for XON after CR while	11BH
			;sending a file in terminal mode
TGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
			;
EXTRA1:	DB	0	;for future expansion			11EH
EXTRA2:	DB	0	;for future expansion			11FH
			;
BRKCHR:	DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
HANGUP:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:	DB	'L'-40H	;^L = Send logon			122H
LSTCHR:	DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:	DB	'R'-40H	;^R = Close input text buffer		124H
TRANS:	DB	'T'-40H	;^T = Transmit file to remote		125H
SAVE:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:	DB	'^'-40H	;^^ = Send next character		127H
	DS	2	;					128H
;
; MEX jump vectors (& such)...
;
ICTL1:	MVI	A,00$010$000B	;,reset latched status bits,.	12AH
	OUT	CTL1
	IN	CTL1		;get the status bits
	RET
	DS	3
;
ODATP:	OUT	DATP ! RET	;out modem data port		134H
	DS	7
;
IDATP:	IN	DATP ! RET	;in modem data port		13EH
	DS	7
;
ARCVB:	ANI	RCVB ! RET	;bit to test for receive ready	148H
CRCVR:	CPI	RCVR ! RET	;value of receive bit when rdy	14BH
;
ASNDB:	ANI	SNDB ! RET	;bit to test for send ready	14EH
CSNDR:	CPI	SNDR ! RET	;value of send bit when ready	151H
	DS	6		;				154H
;
OCTL1:	OUT	CTL1 ! RET	;out modem control port		15AH
OCTL2:	OUT	CTL2 ! RET	;out modem status port		15DH
	DS	2		;Not used by MEX		160H
	DS	6		;				162H
;
GBYEV:	JMP	GBYE		;hang up.			168H
;
INITV:	JMP	INIT		;go to user written routine	16BH
;
NEWBV	JMP	NEWB		;Change baudrate		16EH
	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
;
SETBV:	JMP	SETB		;user `SET' baud rate		177H
	DS	3		;				17AH
;
SYSVV:	JMP	SYSV		;display system version		17DH
;
BRKV:	JMP	SNDBRK		;send break			180H
;
; Do not change the following six lines.
;
ILPRTV:	DS	3		;in line print			183H
INBUFV	DS	3		;input buffer			186H
ILCMPV:	DS	3		;in line comparison		189H
INMDMV	DS	3		;input from modem		18CH
NSCRNV:	DS	3		;new screen			18FH
TIMERV:	DS	3		;timer				192H
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCN is clear
; entire screen.  
;
CLREOS:	LXI	D,EOSMSG	;				195H
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLRSCN:	LXI	D,CLSMSG	;				19EH
	MVI	C,PRINT
	CALL	MEX
	RET
;....
;
; Display system version...
;
SYSV:	MVI	C,ILP		;				1A7H
	CALL	MEX
	DB	CR,LF
	DB	'Version for Big Board I Serial Port A [004H]'
	DB	CR,LF,0
	RET
;....
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SNDBRK:	MVI	A,XMTREG
	OUT	CTL1
	MVI	A,BRK		;send a break tone.
	JMP	GBYE1
;.....
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GBYE:	MVI	A,XMTREG
	OUT	CTL1		;send to the status port
	MVI	A,DISCON	;turn off dtr
;
GBYE1:	OUT	CTL1		;set RS-232 bits
	MVI	B,3		;wait for 300 ms.
	MVI	C,TIMER
	CALL	MEX
	CALL	SETXMT		;restore the transmitter to normal
	RET
;.....
;
; Big Board I initialization -- sets up Z80 SIO & the COM8116...
;
;	Serial Port A = 004H	<=- the prefered choice.
;	Serial Port B = 005H
;
;	Either port is acceptable & the usage will depend upon the
;	configuration of your system.  If you are using an external
;	terminal, you will need to use Serial Port A.  If you are
;	using the on board video & a serial printer, then you will
;	need to use Serial Port B.  If you are using an external
;	terminal and a serial printer, check into obtaining a port
;	expansion board.  The jumper boards for the serial channels
;	will need to be set.  The following table lists the jumpers:
;
;	Signal	<pt A>	<pt B>	Direction
;		JB4	JB5
;	======	======	======	======================
;	TxD	 7- 8	 7- 8	from computer to modem
;	RxD	11-12	11-12	from modem to computer
;	RTS	15-16	15-16	from computer to modem
;	CTS	19-20	19-20	from modem to computer
;	DTR	23-24	23-24	from computer to modem
;	DCD	27-28	27-28	from modem to computer
;	RxC	31-32	(Port A receive baud rate clock)
;	TxC	35-36	(Port A transmit baud rate clock)
;
	IF	PORT$A
PORT	EQU	004H	;Big Board I Serial Output Port A.
GENR	EQU	000H	;Big Board I Baud Rate Generator for Port A.
	ENDIF	;Port A
;
	IF	PORT$B
PORT	EQU	005H	;Big Board I Serial Output Port B.
GENR	EQU	00CH	;Big Board I Baud Rate Generator for Port B.
	ENDIF	;Port B
;
CTL1:	EQU	PORT+2	;Modem control port.
DATP:	EQU	PORT	;Modem data port.
CTL2:	EQU	PORT+2	;Modem status port.
;
CMDREG	EQU	000H	;SIO command register.
FMTREG	EQU	004H	;SIO serial format register.
RCVREG	EQU	003H	;SIO receiver control register.
XMTREG	EQU	005H	;SIO transmitter control register.
;
RCVB:	EQU	01H	;Your bits to test for receive.
RCVR:	EQU	01H	;Your value when receive ready.
SNDB:	EQU	04H	;Your bits to test for send.
SNDR:	EQU	04H	;Your value when send ready.
DCDB	EQU	08H	;Your bit to test for Data Carrier Detect.
DCDR	EQU	08H	;Your value when Data Carrier Detect(ed).
;
; The following values are sent to the Transmitter Control
; (Reg. 5) of the SIO.
;
NORMAL:	EQU	1$11$0$1$0$1$0B	;Your value for normal comm'n mode.
BRK:	EQU	1$11$1$1$0$1$0B	;Your value for send break.
DISCON:	EQU	0$11$0$0$0$0$0B	;Your value for disconnection.
;
; Baud rate constants for the COM8116 baud rate generator...
;
G50	EQU	000H	; 50 baud
G75	EQU	001H	; 75 baud
G110	EQU	002H	; 110 baud
G135	EQU	003H	; 135 baud
G150	EQU	004H	; 150 baud
G300	EQU	005H	; 300 baud
G600	EQU	006H	; 600 baud
G1200	EQU	007H	; 1200 baud
G1800	EQU	008H	; 1800 baud
G2000	EQU	009H	; 2000 baud
G2400	EQU	00AH	; 2400 baud
G3600	EQU	00BH	; 3600 baud
G4800	EQU	00CH	; 4800 baud
G7200	EQU	00DH	; 7200 baud
G9600	EQU	00EH	; 9600 baud
G19200	EQU	00FH	; 19200 baud
GERROR	EQU	0FFH	; baud rate error code
;
; Initialize the Z80 SIO...
;
INIT:	MVI	A,CMDREG	;select the command register
	OUT	CTL1
	MVI	A,00$011$000B	;& ,reset the port,.
	OUT	CTL1
	CALL	SETFMT		;set the serial format
	CALL	SETRCV		;set & enable the receiver
	CALL	SETXMT		;set & enable the transmitter
;
; and the COM8116 baud rate generator.
;
CRATE:	MVI	A,C300		;`default' transfer time to 300 baud.
	STA	MSPEED
	MVI	A,47H		;generator set up
	OUT	GENR		;send to baud rate generator
GRATE:	MVI	A,G300		;initialized at 300 baud.
	OUT	GENR		;send to baud rate generator
	RET
;
; SIO register set routines...
;
SETFMT:	MVI	A,FMTREG	;select the format register
	OUT	CTL1
SFRMT:	MVI	A,01$00$01$00B	;& set clock rate,, 1 stop bit, no parity.
	OUT	CTL1
	RET
;
SETRCV:	MVI	A,RCVREG	;select receiver control register
	OUT	CTL1
SRCVR:	MVI	A,11$00000$1B	;& set 8 bit character,, enable receive.
	OUT	CTL1
	RET
;
SETXMT:	MVI	A,XMTREG	;select transmit control register
	OUT	CTL1
SXMTR:	MVI	A,NORMAL	;& enable send, 'dtr', 'rts'
	OUT	CTL1
	RET
;.....
;
; Setup routine to allow changing modem speed with the SET command.
;
; As documented, SET either displays the baud rate settings (with a null
; argument) or is used to set the baud rate.  The expanded SET now
; allows the parity, word size, & stop bits to be set.  These additional
; arguments may occur singly or in combination with other parameters. 
; If multiple arguments are used with the set command, then spaces must
; separate them.  Command arguments may occur in any order as long as
; the baud rate is the last argument.  All arguments after the baud rate
; are ignored.  The serial parameters are displayed at the end of each
; routine invocation if ALWAYS = YES and are always displayed if the
; arguments do not include a baud rate setting.
;
; The SET command also includes a local help screen that lists the
; arguments that affect the port status.  The help screen is invoked
; by a `?' or `HELP' argument.
;
; Included in the table of allowable arguments are some null arguments
; intended for documentation purposes.  These arguments have no effect
; on the port status.
;
; The following is a table of the available options:
;
; Type		Value	Setting
; =============	=======	=======
; Baud Rate-	50	50 baud
;		75	75 baud
;		110	110 baud
;		134.5	134.5 baud
;		150	150 baud
;		300	300 baud	<=- default value
;		600	600 baud
;		1200	1200 baud
;		1800	1800 baud
;		2000	2000 baud
;		2400	2400 baud
;		3600	3600 baud
;		4800	4800 baud
;		7200	7200 baud
;		9600	9600 baud
;		19200	19200 baud
;
; Parity-	NO	no parity	<=- default value
;		ODD	odd parity
;		EVEN	even parity
;
; Word Size-	8	8 bits per char	<=- default value
;		7	7 bits per char
;
; Stop Bits-	1	1 stop bit	<=- default value
;		1.5	1.5 stop bits
;		2	2 stop bits
; 
; Null Args.-	BPS	null
;		BAUD	 "
;		PARITY	 "
;		WORD	 "
;		SIZE	 "
;		STOP	 "
;		BIT	 "
;		BITS	 "
;
; For example,
;
;	SET NO 8 2 110		<=- note: baud rate last
;	or
;	SET  NO PARITY  8 BIT CHAR  2 STOP BITS  110 BAUD
;
; Sets 110 baud, no parity, 8 bit character size, & 2 stop bits.  If
; ALWAYS = YES, then the port status will be displayed.  If ALWAYS = NO,
; then the port status will not be displayed.  Note thet the second
; command line has the same result as the first.
;
;	SET   7 BIT WORD SIZE   ODD PARITY   1.5 STOP BITS
;
; Doesn't change the baud rate (from whatever it was before) and
; sets the parity to odd, 7 bit character size, & 1.5 stop bits.  The
; port status will be displayed because the baud rate was not specified.
;
;	SET 2 STOP BITS
;
; Changes the number of stop bits to 2.  Again, the port status will
; be displayed.
;
; This expansion is entirely compatable with read files.  Auto setting
; of the baud rate from the phone directory is still limited to the
; recognized baud rates of MEX (i.e. 110,300,600,1200,2400,4800,9600,
; & 19200). 450 baud and 710 baud cannot be supported on this machine.
; Serial format parameters cannot be set from the phone directory.
;
; SET command extension types...
;
PARITY	EQU	0FEH		; set parity command
WORDSZ	EQU	0FDH		; set word size
STOPBT	EQU	0FCH		; set stop bits
HELP	EQU	0FBH		; call for help
TRASH	EQU	0FAH		; null arguments
;
RMASK	EQU	00$111111B	;receiver char size clearing mask
RBITS	EQU	11$000000B	;I wish I was a real live assembler
TMASK	EQU	1$00$11111B	;transmitter char size clearing mask
CHAR7B	EQU	01$000000B	;7 bits per character value
CHAR8B	EQU	11$000000B	;8 bits per character value
;
PMASK	EQU	111111$00B	;parity enable clearing mask
PBITS	EQU	000000$11B	;I wish I was a real live assembler
PAROFF	EQU	000000$00B	;bits to set for parity off
PARODD	EQU	000000$01B	;bits to set for odd parity
PAREVN	EQU	000000$11B	;bits to set for even parity
;
SMASK	EQU	1111$00$11B	;stop bits clearing mask
SBITS	EQU	0000$11$00B	;I wish I was a real live assembler
STOP10	EQU	0000$01$00B	;bits to set for one stop bit
STOP15	EQU	0000$10$00B	;bits to set for one and a half stop bits
STOP20	EQU	0000$11$00B	;bits to set for two stop bits
;
SETB:	MVI	C,SBLANK	;Any arguments?
	CALL	MEX
	JC	TELL		;If not, go display baud
	LXI	D,CMDTBL
	MVI	C,LOOKUP
	CALL	MEX		;Parse argument
	JC	CMDERR		;If not found then proclaim goof
	MOV	A,H		;Get the command number
	;
	CPI	PARITY		;Check for parity set
	JZ	PARSET		;If so, go set the parity
	;
	CPI	WORDSZ		;Check for word size
	JZ	WRDSET		;If so, go set the word size
	;
	CPI	STOPBT		;Check for stop bits
	JZ	STPSET		;If so, go set stop bits
	;
	CPI	TRASH		;Check for null argument
	JZ	SETB		;If so, continue parsing
	;
	CPI	HELP		;Check for help command
	JZ	HELPUS		;If so, print help file
	;
	CPI	CERROR		;Check for unsupported command rate
	JNZ	LOADBD		;Continue if supported
	;
	PUSH	H		;else, save the generator rate
	MVI	C,ILP		;& print warning message.
	CALL	MEX
	DB	CR,LF,'-=*=- WARNING -=*=-',CR,LF
	DB	'MEX does not recognize this baud rate !!',CR,LF,LF,0
	POP	H		;restore the generator rate
	JP	GENSET		;& go set it
	;
LOADBD:	STA	CRATE+1		;change time-to-send to match baudrate
GENSET:	MOV	A,L		;get baudrate byte
	STA	GRATE+1		;send to COM8116 timer for new baudrate
	CALL	CRATE		;reinitialize to new baudrate
	;
	IF	NOT ALWAYS
	RET			;then done!
	ENDIF	;show only on null set or format set.
	;
	IF	ALWAYS
	JMP	TELL		;then done!
	ENDIF	;always show parameters on baud set.
;
CMDERR:	MVI	C,ILP
	CALL	MEX		;Tell user input not valid
	DB	CR,LF,'-=*=- Undefined SET argument -=*=-',CR,LF,LF,0
	JMP	TELL		;abort the balance of the SET command
				;& display the current status
;
PARSET:	LDA	SFRMT+1		;get the format byte
	ANI	PMASK		;clear the parity bits
	ORA	L		;install the new bits
	STA	SFRMT+1
	CALL	SETFMT		;set the SIO
	JMP	DONSET
;
STPSET:	LDA	SFRMT+1		;get the format byte
	ANI	SMASK		;clear the stop bits
	ORA	L		;install the new bits
	STA	SFRMT+1
	CALL	SETFMT		;set the SIO
	JMP	DONSET
;
WRDSET:	LDA	SRCVR+1		;get the receiver byte
	ANI	RMASK		;clear the word size bits
	ORA	L		;install the new word size
	STA	SRCVR+1
	CALL	SETRCV		;set the SIO
	MOV	A,L		;get the word size
	RRC			;move to proper position for
	MOV	L,A		; transmitter byte
	LDA	SXMTR+1		;get the transmitter byte
	ANI	TMASK		;clear the word size bits
	ORA	L		;install the new word size
	STA	SXMTR+1
	CALL	SETXMT		;set the SIO
;
DONSET:	JMP	SETB		;go look for more parameters
;....
;
; Display the current baud rate.
;
TELL:	MVI	C,ILP		;get ready...
	CALL	MEX
	DB	CR,LF,'-=*=- Port Status -=*=-',CR,LF,' ',0
	LDA	GRATE+1		;get the current baud rate
	ANI	00FH		;set limit (safety factor)
	ADD	A		; times two...
	LXI	H,CNVTBL	;get the conversion table base
	ADD	L		;add generator code to table base
	MOV	L,A
	MVI	A,000H
	ADC	H
	MOV	H,A
	SHLD	BPNTR		;get the source address
	DB	IN$LHLD		;LHLD instruction
BPNTR:	DS	2		;(vector to where the pointer is)
	LXI	D,BDMSG		;get the destination buffer
	DCX	H		;pre-decrement addresses
	DCX	D
	;
	; move the command from the table to the print buffer
	;
MOVCMD:	INX	H		;point to the next addresses
	INX	D
	MOV	A,M		;get a byte
	ORA	A		;set/clear the negative flag
	PUSH	PSW		;& save it
	ANI	07FH		;strip high bit
	STAX	D		;store the byte
	POP	PSW		;restore flags
	JP	MOVCMD		;continue if high bit not set
	;
	INX	D		;point to the last byte
	XRA	A		;make a zero to end data field
	STAX	D		;& store it
	INX	D		;point to where an instruction should be
	MVI	A,IN$RET	;make a return instruction
	STAX	D		;& store it
	CALL	PRNTBD		;go print the baud rate command
	;
	MVI	C,ILP		;print english stuff...
	CALL	MEX
	DB	' baud',CR,LF,0
;
; Display the parity
;
	LDA	SFRMT+1		;get the format byte
	ANI	PBITS		;select the bits for parity
	CPI	PAROFF		;check for parity off
	JNZ	PCKODD		;if not off, see if odd
	MVI	C,ILP		;else, proclaim no parity
	CALL	MEX
	DB	' NO parity',CR,LF,0
	JMP	PROWRD		;go tell about the char size
PCKODD:	CPI	PARODD		;check for parity odd
	JNZ	PCKEVN		;if not odd, then call it even
	MVI	C,ILP		;else, proclaim odd parity
	CALL	MEX
	DB	' ODD parity',CR,LF,0
	JMP	PROWRD		;go tell about the char size
PCKEVN:	MVI	C,ILP		;should be even parity
	CALL	MEX
	DB	' EVEN parity',CR,LF,0
;
; Display the character size
;
PROWRD:	LDA	SRCVR+1		;get the receiver byte
	ANI	RBITS		;& mask out unneeded bits
	CPI	CHAR7B		;see if 7 bits per char
	JNZ	PCK8BT		;if not, then use 8 bits
	MVI	C,ILP
	CALL	MEX
	DB	' 7 bit char',CR,LF,0
	JMP	PROSTP		;go tell how many stop bits
PCK8BT:	MVI	C,ILP
	CALL	MEX
	DB	' 8 bit char',CR,LF,0
;
; Display the number of stop bits
;
PROSTP:	LDA	SFRMT+1		;get format byte
	ANI	SBITS		;mask off unneeded bits
	CPI	STOP10		;check for 1 stop bit
	JNZ	PCKS15		;if not, try 1.5 bits
	MVI	C,ILP
	CALL	MEX
	DB	' 1 stop bit',CR,LF,0
	RET
PCKS15:	CPI	STOP15		;check for 1.5 stop bits
	JNZ	PCKS20		;if not, then 2 stop bits
	MVI	C,ILP
	CALL	MEX
	DB	' 1.5 stop bits',CR,LF,0
	RET
PCKS20:	MVI	C,ILP
	CALL	MEX
	DB	' 2 stop bits',CR,LF,0
	RET
;
; Help section...
;
HELPUS:	MVI	C,ILP		;print the help message
	CALL	MEX
	DB	CR,LF
	DB	'The set command takes the following arguments:',CR,LF,LF
	DB	'  Baud Rates:      50      75     110     134.5',CR,LF
	DB	'                  150     300     600    1200',CR,LF
	DB	'                 1800    2000    2400    3600',CR,LF
	DB	'                 4800    7200    9600   19200',CR,LF,LF
	DB	'      Parity:      NO     ODD    EVEN',CR,LF,LF
	DB	'   Stop Bits:       1     1.5       2',CR,LF,LF
	DB	'   Word Size:       7       8',CR,LF,LF
	DB	'If baud rate is specified, then it must be the',CR,LF
	DB	'last argument in the command string.  Example:',CR,LF,LF
	DB	'        SET NO 8 2 110',CR,LF,LF
	DB	'This sets no parity, 8 bits per word, 2 stop bits,',CR,LF
	DB	'and 110 baud rate.  SET with no arguments displays',CR,LF
	DB	'the current status.',CR,LF,0
	RET			;return
;
; Command table lists what's ok & what values to use...
;
CMDTBL:
;
; Baud Rates...
;
P300:	DB	'30','0'+80H	; 300 baud command
	DB	G300		; L reg
	DB	C300		; H reg
P1200:	DB	'120','0'+80H	; 1200 baud command
	DB	G1200
	DB	C1200
P2400:	DB	'240','0'+80H	; 2400 baud command
	DB	G2400
	DB	C2400
P110:	DB	'11','0'+80H	; 110 baud command
	DB	G110
	DB	C110
;
; Baud rates not Smart Modem compatible
;
P600:	DB	'60','0'+80H	; 600 baud command
	DB	G600
	DB	C600
P4800:	DB	'480','0'+80H	; 4800 baud command
	DB	G4800
	DB	C4800
P9600:	DB	'960','0'+80H	; 9600 baud command
	DB	G9600
	DB	C9600
P19200:	DB	'1920','0'+80H	; 19200 baud command
	DB	G19200
	DB	C19200
;
; baud rates unrecognized by MEX
;
P50:	DB	'5','0'+80H	; 50 baud command
	DB	G50
	DB	CERROR
P75:	DB	'7','5'+80H	; 75 baud command
	DB	G75
	DB	CERROR
P135:	DB	'134.','5'+80H	; 134.5 baud command
	DB	G135
	DB	CERROR
P150:	DB	'15','0'+80H	; 150 baud command
	DB	G150
	DB	CERROR
P1800:	DB	'180','0'+80H	; 1800 baud command
	DB	G1800
	DB	CERROR
P2000:	DB	'200','0'+80H	; 2000 baud command
	DB	G2000
	DB	CERROR
P3600:	DB	'360','0'+80H	; 3600 baud command
	DB	G3600
	DB	CERROR
P7200:	DB	'720','0'+80H	; 7200 baud command
	DB	G7200
	DB	CERROR
;
; Parity commands
;
	DB	'N','O'+80H	; set no parity
	DB	PAROFF
	DB	PARITY
	DB	'OD','D'+80H	; set odd parity
	DB	PARODD
	DB	PARITY
	DB	'EVE','N'+80H	; set even parity
	DB	PAREVN
	DB	PARITY
;
; Word Size commands
;
	DB	'7'+80H		; set 7 bit character
	DB	CHAR7B
	DB	WORDSZ
	DB	'8'+80H		; set 8 bit character
	DB	CHAR8B
	DB	WORDSZ
;
; Stop Bits commands
;
	DB	'1'+80H		; set 1 stop bit
	DB	STOP10
	DB	STOPBT
	DB	'1.','5'+80H	; set 1.5 stop bits
	DB	STOP15
	DB	STOPBT
	DB	'2'+80H		; set 2 stop bits
	DB	STOP20
	DB	STOPBT
;
; Help commands
;
	DB	'HEL','P'+80H	; help
	DB	0
	DB	HELP
	DB	'?'+80H		; ?
	DB	0
	DB	HELP
;
; Null arguments
;
	DB	'BP','S'+80H	; 'bps'
	DB	0
	DB	TRASH
	DB	'BAU','D'+80H	; 'baud'
	DB	0
	DB	TRASH
	DB	'PARIT','Y'+80H	; 'parity'
	DB	0
	DB	TRASH
	DB	'CHA','R'+80H	; 'char'
	DB	0
	DB	TRASH
	DB	'WOR','D'+80H	; 'word'
	DB	0
	DB	TRASH
	DB	'SIZ','E'+80H	; 'size'
	DB	0
	DB	TRASH
	DB	'STO','P'+80H	; 'stop'
	DB	0
	DB	TRASH
	DB	'BI','T'+80H	; 'bit'
	DB	0
	DB	TRASH
	DB	'BIT','S'+80H	; 'bits'
	DB	0
	DB	TRASH
;
; Command Table end
;
	DB	0		; end of comparision list.
;
; Backwards Conversion Table - this table is used to report the
; current baud rate from the byte used to set the generator.  This
; bypasses the MEX print baud rate function.
;
CNVTBL:	DW	P50
	DW	P75
	DW	P110
	DW	P135
	DW	P150
	DW	P300
	DW	P600
	DW	P1200
	DW	P1800
	DW	P2000
	DW	P2400
	DW	P3600
	DW	P4800
	DW	P7200
	DW	P9600
	DW	P19200
;
PRNTBD:	MVI	C,ILP
	CALL	MEX
BDMSG:	DS	10	; to print baud rate command string
;....
;
; Set new modem port baud rate.  This routine is used to auto set the
; baud rate from the phone directory and as such is limited to only
; the baud rates that MEX recognizes.  No provisions are made here to
; set the parity, word size, or stop bits.
;
NEWB:	PUSH	PSW		; save the rate code
	LXI	H,GTABLE	; get vector to lookup table
	ADD	L		; add rate code to table base
	MOV	L,A
	MVI	A,000H
	ADC	H
	MOV	H,A
	MOV	L,M		; get generator rate from table
	MOV	A,L		; test for valid rate
	CPI	GERROR
	JNZ	OKBAUD		; continue if valid
	;
	MVI	C,ILP		; else print error message
	CALL	MEX
	DB	CR,LF,'-=*=- ',0
	POP	PSW
	MVI	C,PRBAUD
	CALL	MEX
	MVI	C,ILP
	CALL	MEX
	DB	' -=*=- is not supported - no change.',CR,LF,0
	RET
	;
OKBAUD:	POP	PSW	; restore rate code
	JMP	LOADBD	; & go set the baud rate.
;
GTABLE:	DB	G110	;`0' - 110 baud
	DB	G300	;`1' - 300 baud
	DB	GERROR	;`2' - 450 baud  *** not supported ***
	DB	G600	;`3' - 600 baud
	DB	GERROR	;`4' - 710 baud  *** not supported ***
	DB	G1200	;`5' - 1200 baud
	DB	G2400	;`6' - 2400 baud
	DB	G4800	;`7' - 4800 baud
	DB	G9600	;`8' - 9600 baud
	DB	G19200	;`9' - 19200 baud
;
;
EOSMSG:	DB	017H,0,0,0,'$'
CLSMSG:	DB	01AH,0,0,0,'$'
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	END
code
	LXI	H,GTABLE	; get vector to lookup table
	ADD	L		; add rate code to table base
	MOV	L,A
	MVI	A,00