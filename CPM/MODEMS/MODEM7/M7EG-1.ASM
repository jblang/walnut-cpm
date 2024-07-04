; M7EG-1.ASM -- EAGLE IIE overlay file for MDM7xx.  
;
; Modified from the general purpose overlay by Jerry Haigwood, KY4Z
;
; This overlay adapts the MDM7xx program to the EAGLE IIE-2 series
; computer, using the Z80 SIO and Z80 CTC.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the EAGLE IIE series
; computer with the Z80 SIO serial port "B" and the Z80 CTC baud rate
; generator.  If you are not using this equipment then you might still
; want to look over this file to gain knowledge on how to write your
; own version of this overlay.  Some other overlays which might help
; are:
;
;     "H8"  Heath H89 overlay for 8250 I/O and programmable baud rates
;     "HZ"  Zenith 120 overlay for 2661B initialization and baud rates
;     "XE"  Xerox 820II overlay for Z80-SIO intialization, etc.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM7XX.COM	(substitute the correct version
;		DDT VERS 2.2		 number for "X")
;		NEXT  PC
;		4600 0100
;		-IM7EG-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4600 0000
;		-G0			(return to CP/M)
;		A>SAVE 69 MDM7XX.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;02/14/84 - First version of this file		- Jerry Haigwood
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
;
; Change the following information to match your equipment
;
PORT:		EQU	1BH		;SIO port B
MODCTL1		EQU	PORT		;MODEM CONTROL PORT
MODDATP:	EQU	PORT-1		;MODEM DATA IN PORT
MODRCVB:	EQU	1		;BIT TO TEST FOR RECEIVE
MODRCVR:	EQU	1		;VALUE WHEN READY
MODSNDB:	EQU	4		;BIT TO TEST FOR SEND
MODSNDR:	EQU	4		;VALUE WHEN READY
CTC:		EQU	02H		;CTC addr
;
		ORG	100H
;
;
; Change the clock speed if needed, to match your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	NO	;Cursor control routine 		10CH
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
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
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
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port	     	12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	12		;				156H
;
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	16EH
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	171H
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
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
		DB	0,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	0,0,0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for EAGLE IIE Computer'
		DB	CR,LF,'Initial baud rate set for 300',CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can use several lines if
; desired.  End with a 0.
;
LOGON:		DB	'This is an EAGLE IIE computer',CR,LF,0
;.....
;
;
; Add your own routine here to send a break tone to reset some time-share
; computers, if desired.
;
SENDBRK:	RET
;.....
;
;
; Add your own routine here to put DTR low and/or send a break tone.
; Check other routines such as MDM709DP.ASM which is using this feature.
;
GOODBYE:	RET
;.....
;
;
; The following is used to initialize the Z80 SIO port "B".
; Baud rate is initially set to 300.
;
INITMOD:DI			;no interupts during setup
	MVI	A,1		;default transfer speed to 300 baud
	STA	MSPEED
	MVI	A,04H		;write register 4 of DART 
	OUT	PORT		;contol port
	MVI	A,84H		;x32, 1 stop bit, no parity
	OUT	PORT
	MVI	A,03H		;write register 3 of DART
	OUT 	PORT
	MVI	A,0C1H		;rcv 8 bits/char, rcv enable
	OUT	PORT
	MVI	A,05H		;write register 5 of DART
	OUT	PORT
	MVI	A,6AH		;tx 8 bits/char, tx enable, rts enable
	OUT	PORT
	MVI	A,45H		;counter mode, control word time
	OUT	CTC		;  constant follows
	MVI	A,208		;x208
	OUT	CTC
	EI
	RET
;.....
;
;
SETUPR:	LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	CALL	JMP$ILPRT
	DB	'Input Baud Rate (300, 450, 600, 1200, 9600): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	DB	'300',0
	JNC	B300		;jump if good match
	CALL 	JMP$INLNCOMP
	DB	'450',0
	JNC	B450
	CALL 	JMP$INLNCOMP
	DB	'600',0
	JNC	B600
	CALL 	JMP$INLNCOMP
	DB	'1200',0
	JNC	B1200
	CALL 	JMP$INLNCOMP
	DB	'9600',0
	JNC	B9600
	CALL	JMP$ILPRT	;no matches, tell operator
	DB	LF,'++ Incorrect entry ++',CR,LF,LF,BELL,0
	JMP	SETUPR		;try it again
;
B300:	MVI	A,1		;MSPEED 300 baud value
	STA	MSPEED
	CALL	DART		;set up DART
	MVI	A,208		;x208
	OUT	CTC
	RET
;.....
;
;
B450:	MVI	A,2		;MSPEED 450 baud value
	STA	MSPEED
	CALL	DART		;set up DART
	MVI	A,156		;x156
	OUT	CTC
	RET
;.....
;
;
B600:	MVI	A,3		;MSPEED 600 baud value
	STA	MSPEED
	CALL	DART		;set up DART
	MVI	A,104		;x104
	OUT	CTC
	RET
;.....
;
;
B1200:	MVI	A,5		;MSPEED 1200 baud value
	STA	MSPEED
	CALL	DART		;set up DART
	MVI	A,52		;x52
	OUT	CTC
	RET
;.....
;
;
B9600:	MVI	A,8		;MSPEED 9600 baud value
	STA	MSPEED
	MVI	A,04H		;write register 4
	OUT	PORT		;control port DART
	MVI	A,44H		;x16, 1 stop bit, no parity
	OUT	PORT
	MVI	A,45H		;counter mode time constant follows
	OUT	CTC		;  control word
	MVI	A,13		;x13
	OUT	CTC
	RET
;.....
;
;
DART:	MVI	A,04H		;write register 4 DART
	OUT	PORT		;control port
	MVI	A,84H		;x32, 1 stop bit, no parity
	OUT	PORT
	MVI	A,45H		;time constant follows
	OUT	CTC		;  control word
	RET
;.....
;
;
BAUDBUF:DB	10,0
	DS	10	
;
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU:
	RET
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;.....
;
	END
;
