;
; M7MH-2.ASM -- Morrow Decision MD-11  computer			08/09/84
;		w/ SmartModem on Auxillary Port
;		overlay file for MDM7xx.
;
;-------------------------------------------------------------------------
;
; 08/09/84 - Updated, more baud rates		- George Reding
; 07/01/84 - First version of M7MH-1.ASM	- George Reding
;	     Modified from M7GP-1.ASM by	- Irv Hoff
;
;-------------------------------------------------------------------------
; Updated version based on additional information obtained from the Morrow
; Corp via Xerox (local service representative). This will allow operation
; at most any baudrate - not previously implemented.   This version is for
; the Zilog SIO/9 chip (identical to  the Zilog SIO  except only channel A
; is operational).   An Intel 8253 CTC chip is used to control baud rates.
;
; Thanks to those who helped me with first version, namely creators of the
; patch named B3SIO.ASM, plus advice from David Bowerman and Gordon Regar.
;						- G.Reding	08/09/84
;-------------------------------------------------------------------------
;
; 	TO USE: First edit this file  selecting your desired options,
;		then assemble with MAC, ASM, or equivalent assembler.
;		Morrow MD-11 users then use SID or DDT to overlay the
;		results of this program to the original COM file.
;
;
;	A>SAVE				<-- type this first
;
;	A>DDT MDM7xx.COM	
;	DDT VERS 2.2
;	NEXT  PC
;	4A00 0100
;	-IM7MH-2.HEX			(note the "I" command)
;	-R				("R" loads in the .HEX file)
;	NEXT  PC
;	4A00 0000
;	-G0				(return to CP/M)
;
;	CP/M 3 SAVE - Version 3.0
;	Enter file (type RETURN to exit): MDM7xx.COM	<-- new filename
;	Beginning hex address 0100	<-- from having used DDT or SID
;	Ending hex address    4A00	<-- you enter both of these
;
;	A>				(now have a modified .COM file)
;
;-------------------------------------------------------------------------
;
;			SIO & CTC Chip Equates
;			""""""""""""""""""""""
; Port addresses:
;
BPORT:		EQU	50H		;Aux Port divisor latch of 8253 CTC.
BPORT2:		EQU	53H		;counter timer mode control.
BASEP:		EQU	70H		;Zilog SIO/9.  Identical to Zilog SIO,
					;except only channel A is operational
					;   (MD-11 Aux Port uses channel A)
DATPORT:	EQU	BASEP		;data port
STPORT:		EQU	BASEP+1		;status/control port
;
; STPORT commands (output to STPORT):
;
RESCHN:		EQU	00011000B	;reset channel
RESSTA:		EQU	00010000B	;reset external status
WRREG1:		EQU	00000000B	;value to write to register 1
WRREG3:		EQU	11000001B	;8 bits/char, rx on
WRREG4:		EQU	01000100B	;16x, 1 stop, no parity
DTROFF:		EQU	00000000B	;dtr and rts off
DTRON:		EQU	11101010B	;drt on, rts on, tx on, 8 bit/char
ONINS:		EQU	00110000B	;error reset
BRKON:		EQU	11111010B	;dtr on, rts on, tx on, break on, 8 bit/char
BRKOFF:		EQU	11101010B	;dtr on, rts on, tx on, break off, 8 bit/char
;
; STPORT status masks:
;
DAV:		EQU	00000001B	;data available
TRDY:		EQU	00000100B	;transmit buffer empty
DCD:		EQU	00001000B	;data carrier detect
CTS:		EQU	00100000B	;clear to send input status
;
;-------------------------------------------------------------------------
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
; Change the following information to match your equipment
;
MODCTL1:	EQU	STPORT		;MODEM CONTROL PORT
MODDATP:	EQU	DATPORT		;MODEM DATA IN PORT
MODDATO:	EQU	DATPORT		;MODEM DATA OUT PORT
MODDCDB:	EQU	DCD		;CARRIER DETECT BIT
MODDCDA:	EQU	0		;VALUE WHEN ACTIVE
MODCTL2:	EQU	STPORT		;2ND MODEM CONTROL PORT
MODRCVB:	EQU	DAV		;BIT TO TEST FOR RECEIVE
MODRCVR:	EQU	DAV		;VALUE WHEN READY
MODSNDB:	EQU	TRDY		;BIT TO TEST FOR SEND
MODSNDR:	EQU	TRDY		;VALUE WHEN READY
;
;-------------------------------------------------------------------------
;
		ORG	100H
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
;
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				156H
;
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port #2	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem control port #1	15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER	DS	3		;				192H
;
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,59H,0,0,0	;				198H
		RET			;				19DH
;
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	1EH,ESC,59H,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Morrow Decision MD-11',CR,LF
		DB	'with SmartModem on Auxillary Port',CR,LF
		DB	0
		RET
;
;-----------------------------------------------------------------------
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 END of your LAST routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;-----------------------------------------------------------------------
;
; Put in a message here which can be called up with CTL-O if TRANLOGON has
; been set TRUE.  You can use several lines if desired.  End with a 0.
;
LOGON:		DB	'This is a Morrow Decision MD-11 computer'
		DB	CR,LF
		DB	0,0,0,0,0,0
;
;
;*************************************************************************
; If any of your routines zap anything other than the Accumulator, then
; you must preserve all other registers.
;*************************************************************************
;
; This will send a break tone to reset some time-share computers.
;
SENDBRK:	MVI	A,5		;setup to write reg 5
		OUT	STPORT
		MVI	A,BRKON		;dtr on, rts on, tx on, break on, 8 bit/char
		OUT	STPORT
		MVI	B,3		;300ms of break
		CALL	JMP$TIMER
		MVI	A,5		;setup to write reg 5
		OUT	STPORT
		MVI	A,BRKOFF	;dtr on, rts on, tx on, break off, 8 bit/char
		OUT	STPORT
		RET
;
;
; This will turn off DTR, etc causing modem to hangup.
;
GOODBYE:	MVI	A,5		;setup to write reg 5
		OUT	STPORT
		MVI	A,DTROFF	;clear dtr causing hangup
		OUT	STPORT
		MVI	B,3		;for 300ms
		CALL	JMP$TIMER
		MVI	A,5		;setup to write reg 5
		OUT	STPORT
		MVI	A,DTRON		;dtr on, rts on, tx on, 8 bit/char
		OUT	STPORT		;so we can use modem again
		RET			;return
;
;
; Setup the modem port (MD-11 Aux Port).
;
INITMOD:	MVI	A,4		;setup to write reg 4
		OUT	STPORT
		MVI	A,WRREG4	;16x, 1 stop, no parity
		OUT	STPORT
;
		MVI	A,1		;setup to write reg 1
		OUT	STPORT
		MVI	A,WRREG1	;value to write to register 1
		OUT	STPORT
;
		MVI	A,3		;setup to write reg 3
		OUT	STPORT
		MVI	A,WRREG3	;initialize receive register
		OUT	STPORT
;
		MVI	A,5		;setup to write reg 5
		OUT	STPORT
		MVI	A,DTRON		;dtr on, 8 bit/char, tx enable, rts
		OUT	STPORT		;so we can use modem
;
		IN	DATPORT		;clean out garbage
		IN	DATPORT		;make sure its clear
		JMP	SET300		;setup default baud (300)
					;and return
;
;
; The following set the baud rate for the modem.  If you do not support a
; particular rate, then put the label in front of the SETINV routine.  If
; the baud rate change was successful, make SURE the Zero flag is set.
;
SETUPR:		LXI	D,BAUDBUF	;point to new input buffer
		CALL	JMP$ILPRT
		DB	'Select baud rate '
		DB	'(300, 450, 600, 710, 1200): ',0
		CALL	JMP$INBUF
		LXI	D,BAUDBUF+2
		CALL	JMP$INLNCOMP	;compare baudbuf+2 with below
		DB	'300',0
		JNC	SET300		;if match, do it
		CALL	JMP$INLNCOMP	;else check..
		DB	'450',0
		JNC	SET450
		CALL	JMP$INLNCOMP	;..until we
		DB	'600',0
		JNC	SET600
		CALL	JMP$INLNCOMP	;..find a match
		DB	'710',0
		JNC	SET710
		CALL	JMP$INLNCOMP	;..and do it
		DB	'1200',0
		JNC	SET1200
		CALL	JMP$ILPRT	;else say no match
		DB	'++ Incorrect entry ++',CR,LF,BELL,0
		JMP	SETUPR		;try again
;
;
SET300:		MVI	A,1		;value for MSPEED
		STA	MSPEED		;store it
;
		MVI	A,3EH		;Aux:=  Mode 3  (Channel 0)
		OUT	BPORT2		;counter timer mode control
		LXI	H,BD300		;baud rate value
		JMP	SETBAUD		;go finish setting
;
;
SET450:		MVI	A,2
		STA	MSPEED
		MVI	A,3EH
		OUT	BPORT2
		LXI	H,BD450
		JMP	SETBAUD
;
;
SET600:		MVI	A,3
		STA	MSPEED
		MVI	A,3EH
		OUT	BPORT2
		LXI	H,BD600
		JMP	SETBAUD
;
;
SET710:		MVI	A,4
		STA	MSPEED
		MVI	A,3EH
		OUT	BPORT2
		LXI	H,BD710
		JMP	SETBAUD
;
;
SET1200:	MVI	A,5
		STA	MSPEED
		MVI	A,3EH
		OUT	BPORT2
		LXI	H,BD1200
;
;
SETBAUD:	MOV	A,L
		OUT	BPORT		;Aux Port divisor latch LOW
		MOV	A,H
		OUT	BPORT		;Aux Port divisor latch HIGH
		XRA	A		;say rate okay
		RET			;return
;
;
; The returns a 255 because we were not able to set to the proper baud rate
; because either the serial port or the modem cant handle it.
;
SET110:		DS	0		;110 baud not supported
;
SETINV:		ORI	0FFH		;make sure zero flag is not set
		RET			;return
;
;
; The following divisors for BPORT (Aux Port divisor latch) for the Morrow
; MD-11 were obtained from Morrow Corp, except the 450 and 710 bps which I
; calculated based on the others (correct?). Bauds other than 300 and 1200
; I haven't tested - no means to do so. Labels correspond with baud rates.
;						-G.Reding	08/09/84
BD110:		EQU	08E0H
BD300:		EQU	0341H
BD450:		EQU	022DH
BD600:		EQU	01A1H
BD710:		EQU	0160H
BD1200:		EQU	00D0H
BD2400:		EQU	0068H
BD4800:		EQU	0034H
BD9600:		EQU	001AH
BD19200:	EQU	000DH
;
;
BAUDBUF:	DB	10,0
		DS	10
;
;
; If using Hayes Smartmodem following is unavailable without a special
; change.
;
SPCLMENU:  RET
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	  END
;
