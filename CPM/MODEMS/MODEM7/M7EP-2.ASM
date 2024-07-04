; M7EP-2.ASM -- Epson QX-10 overlay file for MDM7xx.  06/01/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the QX-10 computer to the modem program.  Much of
; the information contained here is not in the MDM7xx.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown	below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
;
;	TO USE:	First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this	program to the original .COM file:
;
;
;=============================================================================
;
;	SPECIAL	NOTE:  The MDMLNK.COM utility, if available to you, will
;		overlay	the .HEX file on the .COM file in one simple step.
;		See MDMLNK instructions for further details.
;
;=============================================================================
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7EP-2.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return	to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)
;
; =   =	  =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 06/01/84 - Slight changes for MDM740		- Robert Flagg
; 04/10/84 - Added parity, stop bit, word length - jw
; 11/11/83 - Renamed to M7EP-1.ASM, no changes	- Irv Hoff
; 08/27/83 - Revised to work with MDM712	- Irv Hoff
; 07/25/83 - Changed M710XE.ASM forEpson QX-10	- Phil Becker
;
; =   =	  =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
TRUE		EQU	0FFH
FALSE		EQU	0
;
BR7A:		EQU	7AH
BR7B:		EQU	7BH
BR4E:		EQU	4EH
BR4F:		EQU	4FH
;
PORT:		EQU	11H		;Epson QX-10 serial output port
MODCTL1:	EQU	PORT+2		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+2		;Modem control port
MODRCVB:	EQU	01H		;Your bit to test for receive
MODRCVR:	EQU	01H		;Your value when receive ready
MODSNDB:	EQU	04H		;Your bit to test for send
MODSNDR:	EQU	04H		;Your value when send ready		
;
;
		ORG	100H
;
;
; Change the clock speed as needed for your system.
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
AUTODIAL:	DB	NO	;yes=HAYES Smartmodem, no=non-Hayes	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400	7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
RETRY:		DB	YES	;yes=reset the error limit to try again 10DH
				;no=abort after 10 consecutive errors
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVRUB:	DB	YES	;yes=convert rub to backspace		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of rub to backspace 112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do	not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=allow toggling of printer on/off	119H
XOFFTST:	DB	YES	;yes=chcks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCXNNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^O = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	MVI	A,10H		;channel 0, reset interrupts.	12AH
		OUT	MODCTL1
		IN	MODCTL1		;get the status bits
		RET
		DS	3
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6
;
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port		15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem status port		15DH
;
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	66EH
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
; Clear	sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	017H,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	01AH,0,0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	CLRSCRN
		CALL	JMP$ILPRT	;				1A7H
		DB	1BH,29H,'VERSION FOR EPSON QX-10',1BH,28H
		DB	CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:	 You can change the SYSVER message to be longer or shorter.  The
;	 end of	your last routine should terminate by 0380H (473 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0B80H (2521 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O	if TRANLOGON has been set YES.	You can put in several lines if
; desired.  End with a 0.
;
LOGON:	  DB	'Hello from an Epson QX-10 user.',CR,LF,0
;.....
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0F8H		;SEND A	BREAK TONE		
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI	A,5
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,68H		;TURN OFF DTR, SEND BREAK
;
GOODBYE1: OUT	MODCTL1
	  MVI	B,3		;DELAY 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0E8H		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCTL1
	  RET
;.....
;
;
; Epson	QX-10 initialization -- sets CTC timer 00H for send and receive
; baudrate.
;
;
INITMOD:  MVI	A,1
	  STA	MSPEED
	  MVI	A,0B6H
	  OUT	7
	  MVI	A,068H
	  OUT	6
	  MVI	A,000H
	  OUT	6
	  CALL	SETUP7201
INITMOD1: MVI	A,BR4F
	  RET	
;.....
;
;
SETUPR:	  CALL	JMP$ILPRT
	  DB	CR,LF,'Baud Rate = ',0
	  CALL	SETUPD
	  CALL	JMP$ILPRT
	  DB	CR,LF,LF,0					
	  CALL	JMP$ILPRT
	  DB	CR,'Input New Baud Rate (1=300, 2=1200): ',0
	  MVI	C,1
	  CALL	5
	  CPI	31H
	  JZ	OK3		
	  CPI	32H
	  JZ	OK12
	  CPI	0DH
	  JZ	OKBAUD
	  JMP	SETUPR		;TRY AGAIN
;
OK3:	  MVI	A,1		;SET UP	SPEED COMMAND
	  STA	MSPEED		;STORE SPEED
	  MVI	A,0B6H
	  OUT	7
	  MVI	A,0A0H
	  OUT	6
	  MVI	A,1
	  OUT	6
	  JMP	SETUPF		;GO TO FORMAT SETUP
;
OK12:	  MVI	A,5		;SET UP	SPEED COMMAND
	  STA	MSPEED		;STORE SPEED
	  MVI	A,0B6H
	  OUT	7
	  MVI	A,068H
	  OUT	6
	  MVI	A,0
	  OUT	6
;
SETUPF:
	  CALL	JMP$ILPRT
	  DB	CR,LF
	  DB	'Input Format (1=8N1, 2=7E1): ',0
	  MVI	C,1
	  CALL	5
	  CPI	31H
	  JZ	OK8N1		
	  CPI	32H
	  JZ	OK7E1
	  JMP	SETUPF		;TRY AGAIN
;
OK7E1:	  MVI	A,3
	  STA	PARITYBITS
	  MVI	A,040H
	  STA	DATABITS
	  LDA	MSPEED
	  CPI	5
	  JZ	OK7E1H
	  MVI	A,BR7B
	  JMP	SETUPDN
OK7E1H:	  MVI	A,BR7A
	  JMP	SETUPDN
;
OK8N1:	  MVI	A,0
	  STA	PARITYBITS
	  MVI	A,0C0H
	  STA	DATABITS
	  LDA	MSPEED
	  CPI	5
	  JZ	OK8N1H
	  MVI	A,BR4F
	  JMP	SETUPDN
OK8N1H:	  MVI	A,BR4E
;
SETUPDN:  STA	INITMOD1+1
SETUP7201:
	  MVI	A,4
	  OUT	013H
	  LDA	PARITYBITS
	  MOV	B,A
	  LDA	STOPBITS
	  ORA	B
	  MOV	B,A
	  MVI	A,040H
	  ORA	B
	  OUT	013H
	  MVI	A,3
	  OUT	013H
	  LDA	DATABITS
	  ORI	1
	  OUT	013H
	  MVI	A,5
	  OUT	013H
	  LDA	DATABITS
	  RRC
	  ORI	08AH
	  OUT	013H
	  JMP	OKBAUD

PARITYBITS:	DB	0
STOPBITS:	DB	4
DATABITS:	DB	0C0H


OKBAUD:	  CALL	JMP$ILPRT
	  DB	CR,LF,0
	  RET
;
SETUPD:	  LDA	INITMOD1+1
	  CPI	BR7A
	  JNZ	OK7B
	  CALL	JMP$ILPRT
	  DB	'1200 Baud - 7E1',0
	  RET
OK7B:	  CPI	BR7B
	  JNZ	OK4E
	  CALL	JMP$ILPRT
	  DB	'300 Baud - 7E1',0
	  RET
OK4E:	  CPI	BR4E
	  JNZ	OK4F
	  CALL	JMP$ILPRT
	  DB	'1200 Baud - 8N1',0
	  RET
OK4F:	  CALL	JMP$ILPRT
	  DB	'300 Baud - 8N1',0
	  RET
;
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;
; The following routine can be used as an auxiliary menu for notes of
; interest to a particular computer, etc.  If using the Hayes Smartmodem
; this is unavailable without a spcial address change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:	 MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	  END
;

