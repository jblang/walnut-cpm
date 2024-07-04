; M7BT-1.ASM -- Beehive "TOPPER" overlay file for MDM7xx.  11/20/85
;
;
; This overlay adapts the MDM7xx program to the Beehive TOPPER 
; computer, using the Z80 DART and Z80 CTC.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the Beehive TOPPER 
; computer with the Z80 DART main serial port and the Z80 CTC baud rate
; generator.  Note that in the TOPPER the Z80 CTC controls the RX speed
; and the TX speed from different CTC port addresses.  The allows the
; TOPPER to operate the RX and TX at different baud rates, in this 
; overlay both will be SET at the same baud rate.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM, LASM.COM, or 
;		equivalent assembler.  Then use MLOAD to overlay the 
; 		results of this program to the original .COM file:
;
;		MLOAD MODEM.COM=MDM7xx.COM,M7BT-1.HEX
;                         ^       ^
;                         |       |
;  Name you want for program     Name of the MODEM source file.
;				  MDM740, MODM700, etc
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; History:
;
; 11/20/85 - Original version from Lillypond Softwares -  Dennis Recla
;                Garland, Texas  (214) 270-1834    
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
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
PORT:		EQU	9AH
MODCTL1		EQU	PORT		;DART Modem Control Port
MODDATP:	EQU	PORT-2		;DART Data Port
MODRCVB:	EQU	1		;Bit to test for receive
MODRCVR:	EQU	1		;Value when ready
MODSNDB:	EQU	4		;Bit to test for send
MODSNDR:	EQU	4		;Value when ready
CTC1:		EQU	90H		;CTC addr RX speed
CTC2:		EQU	91H		;CTC addr TX speed
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
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
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
		DB	ESC,'J',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'E',0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Beehive Topper Computer',CR,LF
		DB      ' From ',ESC,'d','C','Lillypond Softwares '
		DB	ESC,'d','@','11/20/85',CR,LF
		DB	'  Initial baud rate set for 1200',CR,LF,0
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
LOGON:		DB	'This is a Beehive Topper Computer',CR,LF,0
;.....
;
;
; Routine to send a 300 msec. break tone to reset some time-share
; computers.
;
SENDBRK:	MVI 	A,5		;
		OUT 	PORT
		MVI 	A,0FAH		; Send BREAK tone from DART
		JMP	GOODBYE1	
;.....
;
;
; Routine to put DTR low for 300 msec. to disconnect from Modem.
;
GOODBYE:  	MVI	A,05H		;Write register 5 of DART
		OUT	PORT
		MVI	A,68H		;Drop DTR and RTS
;	
GOODBYE1:	OUT	PORT
		MVI	B,3		;Wait for 300 Msec.
		CALL	JMP$TIMER	;Turn on the timer.
		MVI	A,5		;Write register 5 again
		OUT	PORT
		MVI	A,0EAH		;Put things back to normal.
		OUT 	PORT
		RET
;.....
;
;
; The following is used to initialize the TOPPER Z80 DART.
; MAIN Port is used,Baud rate is initially set to 1200.
;
INITMOD:  DI		;no interupts during setup
;
	  MVI	A,5	;default transfer speed to 1200 baud
	  STA	MSPEED 	;
;
	  MVI   A,01H   ;Write register 1 of DART
          OUT   PORT    ;Control Port
          MVI   A,00H   ;Turn off all the interupts from DART
          OUT   PORT    ;  Topper is all interupt driven
;
	  MVI	A,03H	;write register 3 of DART
	  OUT 	PORT	;
	  MVI	A,0C1H	;rcv 8 bits/char, rcv enable
	  OUT	PORT	; (1100 0001)
;
	  MVI	A,04H	;write register 4 of DART 
	  OUT	PORT	;contol port
	  MVI	A,44H	;x16, 1 stop bit, no parity
	  OUT	PORT	; (0100 0100)	
;
	  MVI	A,05H	;write register 5 of DART
	  OUT	PORT	;
	  MVI	A,0EAH	;DTR,8 bits/char, tx enable, rts enable
	  OUT	PORT	; (1110 1010)
;
	  MVI	A,47H	;counter mode,contol word time constant follows
	  CALL  CTCSET	  
	  MVI	A,40H	; 
	  CALL  CTCSET
;	  
	  EI		;System interupts back on
;
	  RET
;
;.....
; 
; Come here to set up the various Baud rates you require.
; 
; 
SETUPR:	  LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	  CALL	JMP$ILPRT	;
	  DB	'Input Baud Rate (300, 1200, 2400, 4800, 9600, 19200): ',0
	  CALL	JMP$INBUF	;
	  LXI	D,BAUDBUF+2	;
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'300',0		;
	  JNC	B300		;jump if good match
	  CALL	JMP$INLNCOMP	
	  DB	'1200',0	;
	  JNC	B1200		;
	  CALL 	JMP$INLNCOMP	;
	  DB	'2400',0
	  JNC	B2400
	  CALL	JMP$INLNCOMP
	  DB	'4800',0
	  JNC	B4800
	  CALL	JMP$INLNCOMP
	  DB	'9600',0	;
	  JNC	B9600		;
	  CALL	JMP$INLNCOMP
	  DB	'19200',0
	  JNC	B19200
	  CALL	JMP$ILPRT	;no matches, tell operator
	  DB	LF,'++ Incorrect entry ++',CR,LF,LF,BELL,0
	  JMP	SETUPR		;try it again
;
;
B300:	  MVI	A,1		;MSPEED 300 baud value
	  STA	MSPEED		
	  CALL	DART1		;set up DART
	  MVI	A,40H		;300 Baud divisor
	  CALL  CTCSET
	  RET
;
B1200:	  MVI	A,5		;MSPEED 1200 baud value
	  STA	MSPEED		
	  CALL	DART		;set up DART
	  MVI	A,40H
	  CALL  CTCSET
	  RET
;
B2400:	  MVI	A,6		;MSPEED 2400 baud value
	  STA	MSPEED		
	  CALL	DART		;set up DART
	  MVI	A,20H
	  CALL  CTCSET
	  RET
;
B4800:	  MVI	A,7		;MSPEED 4800 baud value
	  STA	MSPEED		
	  CALL	DART		;set up DART
	  MVI	A,10H
	  CALL  CTCSET
	  RET
;
B9600:	  MVI	A,8		;MSPEED 9600 baud value
	  STA	MSPEED		
	  CALL  DART		;set up DART
	  MVI	A,08H
	  CALL  CTCSET
	  RET
;
B19200:   MVI	A,9		;MSPEED 19200 baud value
	  STA	MSPEED		
	  CALL  DART
	  MVI	A,04H		;write register 4
	  CALL  CTCSET
	  RET
;
DART:	  MVI	A,04H		;write register 4 DART
	  OUT	PORT		;control port
	  MVI	A,44H		;x16, 1 stop bit, no parity
	  JMP   DART2		;
;
DART1:	  MVI	A,04H		;write register 4 DART
	  OUT	PORT		;control port
	  MVI	A,64H		;x64
DART2:	  OUT	PORT		;
	  MVI	A,47H		;prescale x16, time constant follows
;				 control word
	  CALL  CTCSET
   	  RET
;
CTCSET:	  OUT	CTC1		;set the RX speed
;
	  OUT	CTC2		;set the TX speed
	  RET


BAUDBUF:  DB	10,0
	  DS	10	
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU:  RET
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;.....
;
	  END
;
