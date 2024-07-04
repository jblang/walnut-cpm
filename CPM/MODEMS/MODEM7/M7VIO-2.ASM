; M7VIO-2.ASM -- Ithaca VIO w/ 2651 overlay.  06/30/85.
;
; Replaces M7VIO-1.ASM and supports the SET command at 2400 Baud.
; It starts out at 1200 baud when the program is first called up.
; Tested with the Hayes Smartmodem 1200 and US Robotics Courier 2400.
;
; One small problem surfaced. When calling with the Courier at 2400,
; if the other end answers at 1200, the Courier resets to 1200 and
; expects you to do the same with the UART. That code was not added
; here and if it happens to you, the simplest recovery is to get out
; of MODEM and start over.
;
; TO USE: First edit this file filling in answers for your own
;	  equipment. Then assemble with ASM.COM or equivalent
;	  assembler. Then use DDT to overlay the the results
;	  of this program to the original .COM file:
;
;		A>DDT MDM729.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7VIO-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000		(MDM729 is 73 sectors)
;		-G0			(return to CP/M)
;		A>SAVE 73 MODEM.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/30/85 - Added 2400 Baud support - Dave Crane
; 03/24/84 - Added SMODEM commands - Dave Crane
; 09/18/83 - MDM711HZ modified for Ithaca VIO+2651 - Dave Crane
; 07/01/83 - Revised to work with MDM711 - Irv Hoff
; 06/22/83 - Revised to work with MDM710 - Irv Hoff
; 05/27/83 - Revised to work with MDM709 - Irv Hoff
; 05/15/83 - Revised to work with MDM708 - Irv Hoff
; 04/11/83 - Updated to work with MDM707 - Irv Hoff
; 04/04/83 - Updated to work with MDM706 - Irv Hoff
; 02/27/83 - Updated to work with MDM705 - Irv Hoff
; 02/17/83 - Modified MDM703CF to work with
;	     Heath/Zenith -100 series com-
;	     puters with 2661B I/O		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
; Modem cable assumed set up as follows:
;
;	Modem		Ithaca VIO board	Function
;	2		3			TXD	->	RXD
;	3		2			RXD	<-	TXD
;			4-\			RTS	-\	(jumpered)
;			5-/			CTS	-/	(together)
;	8		20		Carrier=DCD	->	DSR
;	7		7			Ground	--	Ground
;	22		22			RI	->	not used
;	20		8			DTR	<-	DTR
;
; Be certain the 2651 pin 16 (DCD) is tied to ground. If it floats, the
; chip will never indicate data available. This was a flaw in several
; Rev/B boards tested, even though the documentation indicates Rev/B fixed
; the problem.
;
; This diagram and logic also applies to BYEII and XMODEM but note that data-
; set ready, not the ring indicator, is the signal that a call is coming in.
; SmartModem switches are assumed to be UUDU DUUD for BYE. XMODEM doesn't care.
; USR Courier 2400 switches are assumed UUDD DUDD DU; it will work with the
;     same switch settings as the Hayes 1200.
;
;		DCC 3/26/84
;
;=======================================================================
;
MODDATP:  EQU	20H		;BASE PORT = Data Port
MODSTAT:  EQU	MODDATP+1	;STATUS PORT
MODMODE:  EQU	MODDATP+2	;MODE PORT
MODCTLP:  EQU	MODDATP+3	;CONTROL PORT

BASEP	EQU	MODDATP 	;Base port for Intersystems VIO
DPORT	EQU	BASEP		;Modem data port
SPORT	EQU	BASEP+1 	;Modem status port
MPORT	EQU	BASEP+2 	;Modem mode select port
CPORT	EQU	BASEP+3 	;Modem control port
;
;	Modem status port equates
;
TBMT	EQU	00000001b		;Transmit buffer empty
DAV	EQU	00000010b		;Data available
PE	EQU	00001000b		;Parity error
OE	EQU	00010000b		;Overrun error
FE	EQU	00100000b		;Framing error
DCD	EQU	01000000b		;Carrier detect
RDET	EQU	10000000b		;Ring detect
;  (In this configuration RDET is actually data set ready)
;
;	Mode port equates
;
E8NO1	EQU	01001110b		;8 data bits, no p, 1 stop, 16x rate
EBASE	EQU	00110000b		;Mode register 2 base
B110	EQU	EBASE+2 		;110 baud (not implemented)
B300	EQU	EBASE+5 		;300 baud
B600	EQU	EBASE+6 		;600 baud (not implemented)
B1200	EQU	EBASE+7 		;1200 baud
B2400	EQU	EBASE+10		;2400 baud
B4800	EQU	EBASE+12		;4800 baud (not implemented)
B9600	EQU	EBASE+14		;9600 Baud
;
;	Command port equates
;
CBASE	EQU	00000101b		;Command base
RISET	EQU	00010000b		;Reset errors
DTR	EQU	00000010b		;Turn on DTR
RTS	EQU	00100000b		;Turn on RTS
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-Hayes	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
;
CLOCK:		DB	57	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED: 	DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY: 	DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	NO	;Cursor control routine 		10CH
NORETRY:	DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP: 	DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST: 	DB	NO	;yes=printer available on printer port	119H
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1: 	DB	0	;for future expansion			11EH
EXTRA2: 	DB	0	;for future expansion			11FH
BRKCHR: 	DB	'@'-40H ;^@ = Send a 300 ms. break tone 	120H
NOCONNCT:	DB	'N'-40H ;^N = Disconnect from the phone line	121H
LOGCHR: 	DB	'O'-40H ;^O = Send logon			122H
LSTCHR: 	DB	'P'-40H ;^P = Toggle printer			123H
UNSAVE: 	DB	'R'-40H ;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H ;^Y = Open input text buffer		125H
EXTCHR: 	DB	'^'-40H ;^^ = Send next character		126H
;
		DS	2		;				128H
;
IN$MODSTAT:	IN	MODSTAT ! RET	;in modem status port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
;--->		DS	31
		DS	7
;--->
;
ANI$MODRCVB:	ANI	DAV	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	DAV	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	TBMT	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	TBMT	! RET	;value of send bit when ready	151H
		DS	6		;				156H
OUT$MODCTL1:	OUT	MODCTLP ! RET	;out modem control port #2	15AH
OUT$MODCTL2:	OUT	MODCTLP ! RET	;out modem control port #1	15DH
;
;--->
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE 	;				168H
JMP$INITMOD:	JMP	INITMOD 	;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK 	;				180H
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;		TVI, Lear Siegler, etc.
;
CLREOS: 	CALL	JMP$ILPRT	;				195H
		DB	ESC,79H,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,3AH,0,0,0	;CLEAR ENTIRE SCREEN		1A1H
		RET			;				1A6H
;
;
SYSVER: 	CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Ithaca VIO/2651 at port 20H'
		DB	CR,LF,0
		DB	RET
;.....
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes available) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set YES.	You can put in several lines if
; desired.  End with a 0.
;
LOGON:	  DB	'DAVE;CRANE',CR,LF,0
;.....
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,3DH		;SEND A BREAK TONE FOR 300 MS.
	  MVI	B,3		;DELAY FOR 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,CBASE+RISET+DTR+RTS
	  OUT	MODCTLP 	;Xmit, Recv, DTR, RTS on, reset.
	  IN	MODDATP 	;CLEAR ANY INCOMING CHARS.
	  IN	MODDATP 	;TRY ONCE MORE
	  RET
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc. 
;
GOODBYE:  CALL	SENDBRK 	;SEND 300MS BREAK TONE
	  MVI	A,CBASE 	;SET BREAK, DTR & RTS LOW
	  OUT	MODCTLP 	;PUT COMMAND REGISTER OUT OF MODE
	  MVI	B,3		;DELAY FOR 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,CBASE+RISET+DTR+RTS
	  OUT	MODCTLP 	;SEND TO COMMAND REGISTER
	  IN	MODDATP 	;CLEAR ANY INCOMING CHARS.
	  IN	MODDATP 	;TRY ONCE MORE
	  XRA	A		;CLEAR THE 'A' REG.
	  RET
;
; The following are used in setting up the 2651 I/O port.
;
INITMOD:  MVI	A,5		;START WITH 1200 BAUD
	  STA	MSPEED		;DEFAULT TRANSFER TIME
	  IN	MODCTLP 	;Clear/Reset Mode toggle on port
	  MVI	A,E8NO1 	;1 STOP, NO PARITY, 8 BITS, ASYNC 16X
	  OUT	MODMODE 	;SEND TO MODE REGISTER 1
INITMOD1: MVI	A,B1200 	;START WITH 1200 BAUD
	  OUT	MODMODE 	;SEND TO MODE REGISTER 2
	  MVI	A,CBASE+RISET+DTR+RTS
				;RESET RTS, FLAGS, DTR LOW, ENABLE R/T
	  OUT	MODCTLP 	;SEND TO COMMAND REGISTER
	  CALL	SMINIT		;Reinitialize the SmartModem to this rate.
	  RET
;.....
;
; The following changes the baud rate with the SET command.
;
SETUPR:   LXI	D,BAUDBUF
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 1200, 2400, 9600): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	  DB	'300',0
	  JNC	OK300		;GO IF GOT MATCH
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$INLNCOMP
	  DB	'2400',0
	  JNC	OK2400
	  CALL	JMP$INLNCOMP
	  DB	'4800',0
	  JNC	OK4800
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$ILPRT	;ALL MATCHES FAILED, ASK AGAIN
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;TRY AGAIN
;
OK300:	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD
;
OK1200:   MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400:   MVI	A,6
	  LHLD	BD2400
	  JMP	LOADBD
;
OK4800:   MVI	A,6		;See comments after next Baud rate:
	  LHLD	BD4800
	  JMP	LOADBD
;
OK9600:   MVI	A,6		;Obviously this won't work with a slower
	  LHLD	BD9600		; modem. It's intended for null modems.
	  JMP	LOADBD
;
LOADBD:   STA	INITMOD+1	;Store in INITMOD instruction
	  MOV	A,L		;get least significant baud rate byte
	  STA	INITMOD1+1	;store in INITMOD1
	  JMP	INITMOD 	;reset 2651
;.....
;
; TABLE OF BAUDRATE PARAMETERS FOR 2651 I/O
;
BD110	DB	EBASE+2 		; 110 BAUD
BD300	DB	EBASE+5 		; 300 BAUD
BD1200	DB	EBASE+7 		;1200 BAUD
BD2400	DB	EBASE+10		;2400 BAUD
BD4800	DB	EBASE+14		;4800 BAUD
BD9600	DB	EBASE+14		;9600 BAUD 
;
BAUDBUF:  DB	10,0
	  DS	10
;
;
SPCLMENU: RET		; Not used

; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
;	      D.C. Hayes Smartmodem 300/1200 'Modem Control'
;	From:		BY2+SMDM.ASM  by Don Brown
;			 Version 1.1	04/24/83
;	Mods: Dave Crane, Dallas RCP/M
;
; These routines may be used along with the more specific modem/
; serial port/baud rate routines commonly found in BY2-MOD.LBR.
;
; The following Smartmodem Default switches are assumed:
;  A. Switches 'Not' configurable by Software Control:
;	1=Up, DTR supported, do Not force to always logic true.
;	6=Up, DCD supported, do Not force to always logic true.
;	7=Up, Single Line RJ11 Telephone connection to Smartmodem.
;	8=Down, Enables modem command recognition, when in Command State.
;  B. Switches 'configurable' by Software Control:
;	2=Up, Send English result codes when in Command State.
;	3=Down, Result Codes are sent to the Terminal.
;	4=Down, Do not echo characters when in Command State.
;	5=Down, Do not answer the telephone.
;
; The USR Courier 2400 switches are almost identical to the Hayes 1200.
; We run the RCP/M with 1,2,6, and 10 UP and the rest DOWN (except "11").
;
; Notes:
;	USR Courier will automatically set itself to the speed of the
;	calling modem, provided the speed is 300 -> 2400 baud.	This
;	relieves us of the need to set the modem (still have to check and
;	set the USART/baud), via software instructions.  110 baud is not
;	supported because Smartmodem cannot differentiate between 110-300
;	baud and will not set itself automatically.
;
;	Code causes DTR to go false in order to Hang-Up the phone.  When
;	DTR goes false, smartmodem will automatically drop the line and go
;	to Local Command State.  However, DTR must be true for Smartmodem
;	to receive and execute commands.  Further, when you turn DTR on, for
;	this purpose, Smartmodem is still set at the Baud rate of the last
;	call and is still in auto answer mode.	If the telephone is ringing
;	when DTR goes true and the number of rings stored in smartmodem
;	register S0 is 1 (and possibly even 2), there may not be enough time
;	to send the first command string before smartmodem goes off the hook
;	into a carrier wait state.  If you send any characters to smartmodem
;	during this carrier wait state (before it has recognizes an incoming
;	carrier and goes On Line), the smartmodem will hang-up the line and
;	return to local command state.	Also, all characters received by it,
;	after this first key character (ie. the 'A' of the required 'AT..'),
;	after in local command state, will be received as random data and
;	may confuse smartmodem's baud rate detector and command decoder,
;	leaving smartmodem in an unpredictable state (which may keep your
;	system down till you manually reset it).  If the command string is
;	sent after smartmodem has recognized carrier and gone on line, it
;	goes out the modem port to the calling modem as data (garbage).
;	Consequently, it is extremely important that smartmodem register S0
;	be set to at least 3 if not 4 rings and the smartmodem command string
;	'ATZ' be executed immediately after DTR is set true!!
;
;	The first command string sent to smartmodem ie. 'ATZ', will set the
;	smartmodem baud rate to the speed at which it was sent (the speed or
;	baud of your USART which was just set in the initialization routines).
;	This command will also cause the Smartmodem to do its own software
;	reset (return to default switch settings).  Note that switch 5 is
;	down so that modem does Not default to auto Answer.  We set auto
;	when we're ready, with the second command string we send.
;
;	The Smartmodem needs at least 250msecs. delay between commands, in
;	order to execute the command and be ready to receive the next command
;	or between data and a command (sometimes longer).
;
; Initialize the Smartmodem.
; DTR must be logic true for Smartmodem to receive and process a command.
; The S0 modem register setting should not be less than 2 and should be the
; last command in the command string.
;
PSPEED: 	EQU	6	;Processor speed - MHz
;
SMINIT:
	CALL	MDMRST		;Reset with 'ATZ'
	CALL	SMDELAY 	;One second delay needed by Smartmodem
	CALL	SMSEND		;Initialize Smartmodem
	DB	'ATQ1E0M1S2=128S7=11S9=6S10=60S0=255',CR,0
	CALL	SMDELAY 	;One second delay needed by Smartmodem
	RET			;Return
;
; Initialize the SmartModem to virgin state
;
MDMRST:
	CALL	SMSEND
	DB	'ATZ',CR,0	; set SmardModem to no auto answer
	RET
;
; Let the Smartmodem have one second before receiving a command.
; ie. one second to process a Command or before any other data
; is sent to it.  DTR must be On for Smartmodem to receive and process
; a command when it is local command state.
;
SMDELAY:
	PUSH	B		;Preserve in case it's in use elsewhere
	MVI	B,10		;Wait one second
DLP1:
	CALL	DELAY
	DCR	B
	JNZ	DLP1		;Keep looping till done
	POP	B		;Done, restore BC
	RET			;Return
;
; Send the Command String to the Smartmodem
; Similiar to how ILPRT sends to console
;
SMSEND:
	XTHL			;Save HL, get address of message
	PUSH	B		;Save BC
;
SMPLP:
	IN	SPORT		;Get modem output status
	ANI	TBMT		;mask junk
	JZ	SMPLP		;Not ready to send yet...
	MOV	A,M		;Ready, get the character..
	OUT	DPORT		;Send the character
	INX	H		;Point to next character
	MOV	A,M		;Get next character
	ORA	A		;Delimiter ? All sent ?
	JNZ	SMPLP		;..No, go send another
	POP	B		;..Yes, restore BC
	XTHL			;...restore HL, get return Address
	RET			;Return
;
;.1 sec delay routine
;
DELAY:
	PUSH	B
	LXI	B,417*PSPEED	;timing constant * speed in MHz
;
DELAY1:
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	DELAY1
	POP	B
	RET
;
	END

	LXI	B,417*PSPEED	;timing constant * speed in MHz
;
DELAY1:
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	