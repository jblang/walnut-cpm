; M7NA-1.ASM -- North Star Advantage overlay for MDM7xx - 11/11/83
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the MDM7xx "SET" command to change the baudrate when desired.  It
; starts out at 300 baud when the program is first called up.
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
;		4300 0100
;		-IM7NA-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/11/83 - Renamed to M7NA-1.ASM, no changes	- Irv Hoff
; 09/14/83 - Changed M712HZ.ASM TO M712AF.ASM	- Robert Lehman
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 02/17/83 - 1st version of M712HZ.ASM		- Irv Hoff
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
PORT:		EQU	50H		;Slot 1 for Advantage
BAUDRP:		EQU	PORT+8
MODDATP:	EQU	PORT		;data port for Advantage
MODCTL1:	EQU	PORT+1		;status port for Advantage
MODRCVB:	EQU	2		;bit to test for received data
MODRCVR:	EQU	2		;modem receive ready
MODSNDB:	EQU	1		;bit to test for ready to send
MODSNDR:	EQU	1		;modem send ready bit
;
;
; The Advantage uses the 8251
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-Hayes	104H
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
				;no=resend a record after a valid NAK
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
LSTTST:		DB	NO	;yes=printer available on printer port	119H
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
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		125H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		126H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	31
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
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	0FH,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	1EH,0FH,0,0,0	;CLEAR ENTIRE SCREEN		1A1H
		RET			;HOME THEN CLEAR
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for North Star Advantage - Slot 1'
		DB	CR,LF,0
		DB	RET
;.....
;
;
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
LOGON:	  DB	'Hello from a North Star Advantage computer',CR,LF,0
;.....
;	
;
; This routine allows a 300 ms. break tone to be send to reset some
; time-share computers.
;
SENDBRK:  MVI	A,08H		;send a break tone for 300 ms.
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212a, etc.
;
GOODBYE:  MVI	A,0AH		;set break, DTR low
;
GOODBYE1: OUT	MODCTL1		;put command register out of mode
	  IN	MODCTL1		;make sure it is now clear
	  IN	MODCTL1		;try once more
	  MVI	B,3		;delay for 300 ms.
	  CALL	JMP$TIMER
	  MVI	A,37H		;reset RTS, flags, DTR low, enable R/T
	  OUT	MODCTL1		;send to command register
	  IN	MODCTL1		;clear any incoming chars.
	  IN	MODCTL1		;try once more
	  XRA	A		;clear the 'A' reg.
	  RET
;.....
;
;
; The following are used in setting up the slot 1.
;
INITMOD:  MVI	A,1		;default transfer time to 300 baud
	  STA	MSPEED
	  XRA	A		;set RTS, flags, DTR, disable R/T
	  OUT	MODCTL1		;put command register out of mode
	  IN	MODCTL1		;make sure it is now clear
	  IN	MODCTL1		;try once more
	  MVI	A,0AAH
	  OUT	MODCTL1
	  MVI	A,40H
	  OUT	MODCTL1
	  MVI	A,4EH		;1 stop, no parity, 8 bits, 16x asynch
	  OUT	MODCTL1		;send to mode register 1
;
INITMOD1: MVI	A,40H		;start with 300 baud, internal 4 clock
	  OUT	BAUDRP		;send to baud rate port
	  MVI	A,37H		;reset RTS, flags, DTR low, enable R/T
	  OUT	MODCTL1		;send to command register
	  IN	MODCTL1		;clear any incoming chars.
	  IN	MODCTL1		;try once more
	  XRA	A		;clear the 'A' reg.
	  RET
;.....
;
;
; The following changes the baud rate with the set command.
;
SETUPR:	  LXI	D,BAUDBUF
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 1200, 9600, 19200): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'300',0
	  JNC	OK300		;go if got match
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$INLNCOMP
	  DB	'19200',0
	  JNC	OK19200
	  CALL	JMP$ILPRT	;all matches failed, ask again
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;
OK300:	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD
;
OK19200   MVI	A,9
	  LHLD	BD19200
;
LOADBD:	  STA	INITMOD+1
	  MOV	A,L		;get least significant baud rate byte
	  STA	INITMOD1+1	;store in INITMOD1
	  JMP	INITMOD		;reset advantage slot 1 
;.....
;
;
; Table of baudrate parameters for hsio-4 board i/o
;
BD300:	  DW	0040H
BD1200:	  DW	0070H
BD9600:	  DW	007EH
BD19200:  DW	007FH
;
BAUDBUF:  DB	10,0
	  DS	10
;
;-----------------------------------------------------------------------
;
; The following routine could be used to display selections of interest
; to owners of this computer.  If using the Hayes Smartmodem this is
; unavailable without a special change.
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
PR		;try again
;
OK300:	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD
;
OK