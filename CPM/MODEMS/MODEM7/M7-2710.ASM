
; M7-2710.ASM -- California Computer Systems 2710 Serial I/O
;
;                        By Dennis Recla  04/11/84
;
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the CCS 2710 board
; with 8250 serial I/O at location 78H.  Much of the information contained 
; here is not in the main file.  If not using the CCS 2710 Serial I/O
; some of the routines here will illustrate what you could do with your
; unit.
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
;		4X00 0100
;		-IM7-2710.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4X00 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
;                       ^
;                      Value may vary with version of MDM7xx
; 
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 
;        M7-2710.ASM             Dennis Recla  04/11/84
;
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
MODDATP:	EQU	078H		;data port for CCS 2710 Board
MODCTL1:	EQU	MODDATP+5	;status port for CCS 2710
MODRCVB:	EQU	1		;bit to test for received data
MODRCVR:	EQU	1		;modem receive ready
MODSNDB:	EQU	20H		;bit to test for ready to send
MODSNDR:	EQU	20H		;modem send ready bit
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
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	8	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	8	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
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
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'O'-40H	;^O = Send logon			122H
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
; The following clear the screen for the Televideo 950 terminal
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'t',0,0,0,0,0,0,0	;			198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'*',0,0,0,0,0,0,0	;			1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for CCS 2710 @ 78H with 8250 I/O'
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
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:	  DB	'Hello ...Hello...  Anyone there ???',CR,LF,0
;.....
;
;
; This routine sends a 300 ms. break tone to reset some time-share
; computers.
;
SENDBRK:  MVI	A,40H		;SET BREAK TONE
	  OUT	MODDATP+3
	  JMP	GOODBYE1	;SEND A 300 MS. BREAK TONE
;.....
;
;
; This routine sends a 300 ms. break tgone and set DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  XRA	A
	  OUT	MODDATP+4	;SET DTR AND RTS LOW
	  MVI	A,40H		;SET BREAK TONE
	  OUT	MODDATP+3
;
GOODBYE1: MVI	B,3		;WAIT 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,03H		;RESET TO NORMAL 8 BITS
	  OUT	MODDATP+3
	  MVI	A,01H
	  OUT	MODDATP+4	;RESET DTR HIGH
	  RET
;.....
;
;
; The following is used to initialize the CCS 2710 8250 I/O port
;
INITMOD:  MVI	A,1		;default transfer speed to 300 baud
	  STA	MSPEED
	  DI			;turn off interrupts for init.
	  XRA	A
	  OUT	MODDATP+1	;interrupt enable register
	  MVI	A,80H		;insure out of mode to set baud rate
	  OUT	MODDATP+3	;line control register
	  OUT	MODDATP+3
;
LSPSPD:	  MVI	A,80H		;default 'LSP' speed for 300 baud
	  OUT	MODDATP		;register for 'LSP' speed if enabled
;
MSPSPD:	  MVI	A,01H		;default 'MSP' speed for 300 baud
	  OUT	MODDATP+1	;register for 'MSP' speed if enabled
;
	  MVI	A,03H		;8-level, 1 stop bit, no parity
	  OUT	MODDATP+3	;line control register
	  MVI	A,01H		;set 'DTR' for proper modem output level
	  OUT	MODDATP+4	;modem control register
	  EI			;restore interrupts to normal
	  RET
;.....
;
;
; The following routine changes the baud rate for the CCS 2710 with the SET
; command.
;
SETUPR:	  LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 450, 600, 1200, 2400, 4800, 9600): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'300',0
	  JNC	OK300		;go if got match
	  CALL	JMP$INLNCOMP
	  DB	'450',0
	  JNC	OK450
	  CALL	JMP$INLNCOMP
	  DB	'600',0
	  JNC	OK600
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL  JMP$INLNCOMP
	  DB    '2400',0
	  JNC   OK2400
	  CALL  JMP$INLNCOMP
	  DB    '4800',0
	  JNC   OK4800
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$ILPRT	;all matches failed - tell operator
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;
OK300:	  MVI	A,1		;MSPEED 300 baud value
	  LHLD	BD300		;get 300 baud parameters in HL
	  JMP	LOADBD		;go load them
;
OK450:	  MVI	A,2
	  LHLD	BD450
	  JMP	LOADBD

OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400:   MVI   A,6
	  LHLD  BD2400
	  JMP   LOADBD
;
OK4800:   MVI   A,7
	  LHLD  BD4800
	  JMP   LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
;
LOADBD:	  STA	INITMOD+1	;store speed to show transfer time 
	  MOV	A,L		;get least significant baud rate byte
	  STA	LSPSPD+1	;store in INITMOD
	  MOV	A,H		;get most signifcant baud rate byte
	  STA	MSPSPD+1	;store in INITMOD
	  JMP	INITMOD		;reset CCS 2710 Serial I/O 8250
;
;
; Table of baud rate parameters
;
BD300:	  DW	0180H
BD450:	  DW	0100H
BD600:	  DW	00C0H
BD1200:	  DW	0060H
BD2400:   DW    0030H
BD4800:   DW    0018H
BD9600:	  DW	000CH
;
BAUDBUF:  DB	14,0
	  DS	14
;
;-----------------------------------------------------------------------
;
; This routine can be used for your equipment, be sure to end with RET
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	  END
;
