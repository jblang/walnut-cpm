;MDM overlay for the H/Z89 running CP/M 2.204 with the Z-89-11 card installed
;This overlay sould work, but I have not tested it..
;Equates for enhanced programmable communication interface chip 2661-3.
;Port Displacements.
;		EQU	0		data
;		EQU	1		status
;		EQU	1		syn1/syn2/dle
;		EQU	2		mode
;		EQU	3		command
;
;Status Registers
;		EQU	00000001b	transmitter ready
;		EQU	00000010b	receiver ready
;		EQU	00000100b	transmitter empty
;		EQU	00000100b	data set change
;		EQU	00001000b	parity error
;		EQU	00010000b	overrun error
;		EQU	00100000b	frame error
;		EQU	00100000b	sync detected
;		EQU	01000000b	data carrier detect
;		EQU	10000000b	data set ready
;
;Mode Register 1
;		EQU	00000011b	mode and baudrate factor
;		EQU	000h		synchronous 1x rate
;		EQU	001h		asynchronous 1x rate
;		EQU	002h		asynchronous 16x rate
;		EQU	003h		asynchronous 64x rate
;
;		EQU	00001100b	character length
;		EQU	000h		length 5
;		EQU	004h		length 6
;		EQU	008h		length 7
;		EQU	00Ch		length 8
;		EQU	00010000b	Parity control (0=disabled, 1=enabled)
;		EQU	00100000b	parity type (0=odd, 1=even)
;
;		EQU	11000000b	asynchronous stop bit length
;		EQU	040h		length 1
;		EQU	080h		length 1.5
;		EQU	0C0h		length 2
;
;		EQU	01000000b	synchronous transparency control
;					(0=normal, 1=transparent)
;		EQU	10000000b	number of sync characters
;					(0=double, 1=single)
;
;Mode Register 2
;		EQU	00001111b	baud rate selection
;		EQU	11110000b	see text
;
;Command Register
;		EQU	00000001b	transmitter enable
;		EQU	00000010b	data terminal ready
;		EQU	00000100b	receiver enable
;		EQU	00001000b	send break (async)
;		EQU	00001000b	send dle (sync)
;		EQU	00010000b	reset status errors
;		EQU	00100000b	request to send
;
;		EQU	11000000b	operating mode
;		EQU	000h		normal
;		EQU	040h		mode1
;		EQU	080h		local loop back
;		EQU	0C0h		remote loop back
;
;BAUDRATE SELECTION VALUES
;
;		EQU	0		50
;		EQU	1		75
;		EQU	2		110
;		EQU	3		134.5
;		EQU	4		150
;		EQU	5		300
;		EQU	6		600
;		EQU	7		1200
;		EQU	8		1800
;		EQU	9		2000
;		EQU	10		2400
;		EQU	11		3600
;		EQU	12		4800
;		EQU	13		7200
;		EQU	14		9600
;		EQU	15		19200
;
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
MODDATP:	EQU	0D8H		;data port for H/Z89
MODCTL1:	EQU	MODDATP+1	;status port for H/Z89
MODRCVB:	EQU	2		;bit to test for received data
MODRCVR:	EQU	2		;modem receive ready
MODSNDB:	EQU	1		;bit to test for ready to send
MODSNDR:	EQU	1		;modem send ready bit
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-Hayes	
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz max.	
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		
SETUPTST:	DB	YES	;yes=user-added Setup routine	
SCRNTEST:	DB	YES	;Cursor control routine 		
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	
CRCDFLT:	DB	YES	;yes=default to CRC checking		
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	
CONVBKSP:	DB	NO	;yes=convert backspace to rub		
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	
ADDLF:		DB	NO	;no=no LF after CR to send file in	
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	
TRANLOGON:	DB	YES	;yes=allow transmission of logon	
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	
LSTTST:		DB	YES	;yes=printer available on printer port	
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	
EXTRA1:		DB	0	;for future expansion		
EXTRA2:		DB	0	;for future expansion			
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	
LOGCHR:		DB	'L'-40H	;^L = Send logon			
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		
EXTCHR:		DB	'^'-40H	;^^ = Send next character		
;
;
		DS	2		;				
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		
		DS	31
;
LOGONPTR:	DW	LOGON		;for user message.		
		DS	6		;				
JMP$GOODBYE:	JMP	GOODBYE		;				
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	
JMP$SETUPR:	JMP	SETUPR		;				
JMP$SPCLMENU:	JMP	SPCLMENU	;				
JMP$SYSVER:	JMP	SYSVER		;				
JMP$BREAK:	JMP	SENDBRK		;				
;
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				
JMP$INBUF	DS	3		;				
JMP$INLNCOMP:	DS	3		;				
JMP$INMODEM	DS	3		;				
JMP$NXTSCRN:	DS	3		;				
JMP$TIMER:	DS	3		;				
;
;
CLREOS:		CALL	JMP$ILPRT	;				
		DB	ESC,'J',0,0,0	;				
		RET			;				
;
CLRSCRN:	CALL	JMP$ILPRT	;				
		DB	ESC,'E',0,0,0	;CLEAR ENTIRE SCREEN		
		RET			;				
;
;
SYSVER:		CALL	JMP$ILPRT	;				
		DB	'Version for Zenith Z-89-11'
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
LOGON:	  DB	'Hello from a Heath H/Z-89 computer',CR,LF,0
;.....
;	
;
; This routine allows a 300 ms. break tone to be send to reset some
; time-share computers.
;
SENDBRK:  MVI	A,1DH		;SEND A BREAK TONE FOR 300 MS.
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI	A,05H		;SET BREAK, DTR LOW
;
GOODBYE1: OUT	MODDATP+3	;PUT COMMAND REGISTER OUT OF MODE
	  IN	MODDATP+3	;MAKE SURE IT IS NOW CLEAR
	  IN	MODDATP+3	;TRY ONCE MORE
	  MVI	B,3		;DELAY FOR 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,37H		;RESET RTS, FLAGS, DTR LOW, ENABLE R/T
	  OUT	MODDATP+3	;SEND TO COMMAND REGISTER
	  IN	MODDATP+3	;CLEAR ANY INCOMING CHARS.
	  IN	MODDATP+3	;TRY ONCE MORE
	  XRA	A		;CLEAR THE 'A' REG.
	  RET
;.....
;
;
; The following are used in setting up the 2661-3 I/O port.
;
INITMOD:  MVI	A,1		;DEFAULT TRANSFER TIME TO 300 BAUD
	  STA	MSPEED
	  XRA	A		;SET RTS, FLAGS, DTR, DISABLE R/T
	  OUT	MODDATP+3	;PUT COMMAND REGISTER OUT OF MODE
	  IN	MODDATP+3	;MAKE SURE IT IS NOW CLEAR
	  IN	MODDATP+3	;TRY ONCE MORE
	  MVI	A,4EH		;1 STOP, NO PARITY, 8 BITS, 16X ASYNCH
	  OUT	MODDATP+2	;SEND TO MODE REGISTER 1
;
INITMOD1: MVI	A,0F5H		;START WITH 300 BAUD, 
	  OUT	MODDATP+2	;SEND TO MODE REGISTER 2
	  MVI	A,37H		;RESET RTS, FLAGS, DTR LOW, ENABLE R/T
	  OUT	MODDATP+3	;SEND TO COMMAND REGISTER
	  IN	MODDATP+3	;CLEAR ANY INCOMING CHARS.
	  IN	MODDATP+3	;TRY ONCE MORE
	  XRA	A		;CLEAR THE 'A' REG.
	  RET
;.....
;
;
; The following changes the baud rate with the SET command.
;
SETUPR:	  LXI	D,BAUDBUF
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (110, 300, 1200, 9600): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP
	  DB	'110',0
	  JNC	OK110
	  CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	  DB	'300',0
	  JNC	OK300		;GO IF GOT MATCH
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$ILPRT	;ALL MATCHES FAILED, ASK AGAIN
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;TRY AGAIN
;
OK110:	  MVI	A,0		;MSPEED 110 BAUD VALUE
	  LHLD	BD110		;GET 110 BAUD PARAMETERS IN 'HL'
	  JMP	LOADBD		;GO LOAD THEM
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
;
LOADBD:	  STA	INITMOD+1
	  MOV	A,L		;get least significant baud rate byte
	  STA	INITMOD1+1	;store in INITMOD1
	  JMP	INITMOD		;reset 2661
;.....
;
;
; TABLE OF BAUDRATE PARAMETERS FOR 2661 I/O
;
BD110:	  DW	00F2H
BD300:	  DW	00F5H
BD1200:	  DW	00F7H
BD9600:	  DW	00FEH
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
