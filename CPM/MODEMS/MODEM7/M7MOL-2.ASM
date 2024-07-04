; M7MOL-2.ASM  -- Overlay file for MOLECULAR SuperMicro series. 
;
; Use the "SET" command to change baudrate when desired.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4x00 0100
;		-IM7MOL-2.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4x00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)
;			^
;                       May vary depending upon version of MDM7xx
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 04/30/84 - Renamed and revised for MDM7xx.COM - Dennis Recla
; 12/07/83 - Revised for MOLECULAR SuperMicros  - Gene Head
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
; Change the value at MODDATP if it does not match what you are using.
;
MODDATP:	EQU	062H		;data port for Multi I/O
MODCTL1:	EQU	MODDATP+1	;status port for Multi I/O
MODCTL2:	EQU	31H		;speed control port
MODRCVB:	EQU	1H		;bit to test for received data
MODRCVR:	EQU	1H		;modem receive ready
MODSNDB:	EQU	4H		;bit to test for ready to send
MODSNDR:	EQU	4H		;modem send ready bit
;
;
		ORG	100H
;
; Change the clock speed if needed, to match your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-Hayes	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	9	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	9	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	NO	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
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
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=allow toggling of printer on/off	119H
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	NO	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
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
OUT$MODDATP:	OUT     MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP	! RET	;input modem data port		13EH
		DS      7
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
;
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		DS	9		;				16EH
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
; The following clear the screen for the H19 terminal
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'J',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'E',0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'For Molecular Super Micro'
		DB	CR,LF
		DB	'List Device must not be set to local'
		DB	CR,LF,0
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
; CTL-L if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:	  DB	0
;.....
;
;
; This routine sends a 300 ms. break tone to reset some time-share
; computers.
;
SENDBRK:  MVI	A,15H
	  OUT	MODCTL1
	  MVI	A,7FH
	  OUT	MODCTL1
	  LXI	B,300H
BREAK0:	  MVI	A,0DCH
BREAK1:	  DCR	A
	  NOP
	  JNZ	BREAK1
	  DCX	B
	  MOV	A,B
	  ORA	C
	  JNZ	BREAK0
	  MVI	A,15H
	  OUT	MODCTL1
	  MVI	A,6FH
	  OUT	MODCTL1
	  RET

;.....
;
;
; This routine sends a 300 ms. break tgone and set DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  RET
;.....
;
;
; The following is used to initialize the Multi I/O 8250 port
;
INITMOD:  MVI	A,1		;select write register one
	  OUT	MODCTL1
	  XRA	A		;turn off interupts
	  OUT   MODCTL1
	  MVI	A,4		;select write register 4
	  OUT   MODCTL1		
	  MVI	A,44H		;select 8 bit xsfr
	  OUT   MODCTL1	
	  MVI	A,3		;select write register 3
	  OUT   MODCTL1
	  MVI	A,0C1H		;8-bit receive - receive enable
	  OUT   MODCTL1
	  MVI	A,5		;select write register 5
	  OUT   MODCTL1
	  MVI	A,0EAH		;8-bit transmit -transmit enable
	  OUT   MODCTL1
	  MVI	A,10H		;reset interupts - select register 0
  	  OUT   MODCTL1
	  RET
;
;
; The following routine changes the baud rate for the Multi I/O with the SET
; command.
;
SETUPR:	  LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 1200, 2400, 4800, 9600): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'300',0
	  LXI	H,BD300
	  JNC	LOADBD		;go if got match
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  LXI	H,BD1200
	  JNC	LOADBD
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'2400',0
	  LXI	H,BD2400
	  JNC	LOADBD		;go if got match
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'4800',0
	  LXI	H,BD4800	
	  JNC	LOADBD		;go if got match
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  LXI	H,BD9600
	  JNC	LOADBD
	  CALL	JMP$ILPRT	;all matches failed - tell operator
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;
LOADBD:	  CALL	INITMOD
	  MOV   A,H
	  OUT	MODCTL2
	  MOV	A,L
	  OUT	MODCTL2
	  RET
;
; Table of baud rate parameters
;
BD300:	  EQU	0734H
BD1200:	  EQU	4768H
BD2400:   EQU	4734H
BD4800:	  EQU   471AH
BD9600:	  EQU	470DH
;
BAUDBUF:	DB	10,0
		DS	10

;-----------------------------------------------------------------------
;
; This routine can be used for your equipment, be sure to end with RET
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	  END
;
 
