
; M7IN-3.ASM -- Overlay file for the CompuPro I3/I4/SS1.  4/26/84
;
; This overlay adapts the MDM7xx program to the CompuPro Interfacer 3 or
; Interfacer 4 or System Support 1 serial cards using the 2651 USART chip.
; (Note:  It is very easy to modify this file to work with the Apple CPS
; Multifunction card too.)
;
; NOTE TO INTERFACER 4 USERS:
; The 'MIDDLE' serial port and the Centronics port can have their addresses
; changed using a hardware option.  Godbout did this to maintain software
; compatibility with their bios.  In order to prevent problems, use the
; 'RIGHT' serial port (RELATIVE USER 5) instead of the center serial
; port (RELATIVE USER 6).  Also, read page 19 of the manual, the modem
; port will probably have to be set up in the 'MASTER MODE'.  While 
; you're reading the manual, read the section on 'WAIT STATE LOGIC'.
; I'm using a CPU-Z running at 6Mhz, with a 300 baud modem and two wait
; states (jumper at J7).  Without them, I get 'o's for 'n's and 'g's
; for 'f's, and the checksums are never right.  (AWW 12/20/83)
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using an external modem that
; is connected to a serial port.  This includes acoustic modems as well
; as "intelligent" modems such as the Hayes Smartmodem, Racal-Vadic, Bell
; Dataphone 212A, etc.
;
; This overlay is capable of changing the UART port number, setting the
; baud rate and parameters, disconnecting the  modem, and sending breaks.
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
;		4B00 0100
;		-IM7IN-2.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4B00 0000
;		-G0			(return to CP/M)
;		A>SAVE 74 MDM7xx.COM	(now have a modified .COM file)
;
; =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =   =
;
; 04/26/84 - Modified to take further advantage of the software selectable
;	     features provided by CompuPro	- Chuck Rider
; 11/20/83 - Interfacer 4 Note Added            - A.W. Warren
; 11/11/83 - Renamed to M7IN-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/11/83 - Modifed somewhat for MDM711	- Irv Hoff
; 07/08/83 - Adapted from MDM711GP.ASM		- Paul Traina
;
; =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =
;
BELL:	EQU	07H		;bell
CR:	EQU	0DH		;carriage return
ESC:	EQU	1BH		;escape
LF:	EQU	0AH		;linefeed
;
YES:	EQU	0FFH
NO:	EQU	0
;
; Change the following to match your equipment
;
GBCI3:	EQU	YES		;yes= Godbout Interfacer 3
GBCI4:	EQU	NO		;yes= Godbout Interfacer 4
GBCSS1: EQU	NO		;yes= Godbout SS1 board
UARTOP: EQU	YES		;yes= allow user to change UART number
BAUDOP: EQU	YES		;yes= allow user to change baud rate
PARMOP: EQU	YES		;yes= allow user to change bits and parity
;
; =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =   =	  =
;
	IF     GBCI3 OR GBCI4
BASE:	EQU	010H		;base port of CompuPro I3 or I4 cards
UPORT:	EQU	BASE+7		;user (UART select) port
MDM:	EQU	5		;default UART that controls modem port
	ENDIF
;
	IF     GBCSS1
BASE:	EQU	05CH		;base of serial section of CompuPro SS1
UPORT:	EQU	0EFH		;this should be some UNUSED port on...
MDM:	EQU	0		;...system - MDM7 will OUT the value...
	ENDIF		       ;...MDM to it.
;
;
DPORT:	EQU	BASE		;data port
SPORT:	EQU	BASE+1		;status port
MPORT:	EQU	BASE+2		;mode port
CPORT:	EQU	BASE+3		;control port
;
TBMT:	EQU	01H		;transmit buffer empty
DAV:	EQU	02H		;data available
;
		ORG	100H
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	80	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 3=600 5=1200 6=2400	107H
				;7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine			10CH
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
IGNORCTL:	DB	NO	;yes=CTL-chars above ^M not displayed	11DH
PARM:		DB	06EH	;6E=8N1 EE=8N2 7E=8E1 FE=8E2 6A=7N1	11EH
				;EA=7N2 7A=7E1 FA=7E2
				;default data bits, parity, and stop bits
EXITCHR		DB	'E'-40H ;^E = Exit to main menu			11FH
BRKCHR:		DB	'@'-40H ;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H ;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H ;^L = Send logon			122H
LSTCHR:		DB	'P'-40H ;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H ;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H ;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H ;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	LDA	UART		;in modem control port		12AH
		OUT	UPORT
		IN	SPORT
		RET
		DS	2

OUT$MODDATP:	PUSH	PSW		;out modem data port		134H
		LDA	UART
		OUT	UPORT
		POP	PSW
		OUT	DPORT
		RET

IN$MODDATP:	LDA	UART		;in modem data port		13EH
		OUT	UPORT
		IN	DPORT
		RET
		DS	2

ANI$MODRCVB:	ANI	DAV	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	DAV	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	TBMT	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	TBMT	! RET	;value of send bit when ready	151H
		DS	6		;				156H
;
OUT$MODCTL1:	RET	! DS 2		;out modem control port #1	15AH
OUT$MODCTL2:	RET	! DS 2		;out modem control port #2	15DH
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
JMP$TIMER	DS	3		;				192H
;
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above). TV-920
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'Y',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'*',0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT
		DB	'Version for CompuPro '

		IF	GBCSS1
		DB	'System Support-1'
		ENDIF

		IF	GBCI3
		DB	'Interfacer-3 (port ',MDM+'0',')'
		ENDIF

		IF	GBCI4
		DB	'Interfacer-4 (port ',MDM+'0',')'
		ENDIF

		DB	CR,LF,0
		RET

;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:	 You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.	 You can use several lines if
; desired.  End with a 0.
;
LOGON:	  DB	'AT S7=20 S11=50',CR,0
;.....
;
;
; Add your own routine here to send a break tone to reset some time-
; share computers, if desired.
;
UART:	  DB	MDM		;current UART number
;
SENDBRK:  LDA	UART		;select chip
	  OUT	UPORT
	  MVI	A,2FH		;send break for 300ms
	  JMP	GOODBYE1
;.....
;
;
; Add your own routine here to put DTR low and/or send a break tone.
; Check other routines such as M7DP-x.ASM which uses this feature.
;
GOODBYE:  LDA	UART		;select chip
	  OUT	UPORT
	  XRA	A		;turn off DTR
;
GOODBYE1: OUT	CPORT
	  MVI	B,3		;turn off DTR for 300 ms.
	  CALL	JMP$TIMER
	  MVI	A,27H		;turn DTR back on
	  OUT	CPORT
	  RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
BDOS:	  EQU	5
READCNSL: EQU	1
;
	  IF UARTOP OR BAUDOP OR PARMOP
INVSEL:	  CALL	JMP$ILPRT
	  DB	CR,LF,LF,BELL,'Invalid selection.',0
	  RET
;
SETUPR:	  IF	(GBCI3 OR GBCI4) AND UARTOP
	  LDA	UART
	  ADI	'0'
	  STA	UARTDISP
	  CALL	JMP$ILPRT
	  DB	CR,LF,'Current UART number is '
UARTDISP: DB	' .  Do you wish to change it? (Y/N) ',0
	  MVI	C,READCNSL
	  CALL	BDOS
	  CPI	'Y'
	  JZ	UARTSEL
	  CPI	'y'
	  JNZ	SPEEDSEL
;
UARTSEL:  CALL	JMP$ILPRT
	  DB	CR,LF,'Enter new UART number (0-7) ',0
	  MVI	C,READCNSL
	  CALL	BDOS
	  SBI	'0'
	  JM	UARTINV
	  CPI	8
	  JM	UARTOK
UARTINV:  CALL	INVSEL
	  JMP	UARTSEL
UARTOK:	  STA	UART		;save new UART number
	  ENDIF
;
	  IF	BAUDOP
SPEEDSEL: CALL	JMP$ILPRT
	  DB	CR,LF,'Select baud rate (0=110 1=300 2=600 3=1200 '
	  DB	'4=2400 5=4800 6=9600 7=19.2k) ',0
	  MVI	C,READCNSL
	  CALL	BDOS
	  SBI	'0'
	  JM	SPEEDINV
	  CPI	8
	  JM	SPEEDOK
SPEEDINV: CALL	INVSEL
	  JMP	SPEEDSEL
SPEEDOK:  LXI	H,MSPEDTAB
	  MVI	B,0
	  MOV	C,A
	  DAD	B
	  MOV	A,M		;get new value
	  STA	MSPEED		;and save it
	  ENDIF
;
	  IF	PARMOP
PARMSEL:  CALL	JMP$ILPRT
	  DB	CR,LF,'Select parameter (0=8N1 1=8N2 2=8E1 3=8E2 4=7N1 '
	  DB	'5=7N2 6=7E1 7=7E2) ',0
	  MVI	C,READCNSL
	  CALL	BDOS
	  SBI	'0'
	  JM	PARMINV
	  CPI	8
	  JM	PARMOK
PARMINV:  CALL	INVSEL
	  JMP	PARMSEL
PARMOK:	  LXI	H,PARMTAB
	  MVI	B,0
	  MOV	C,A
	  DAD	B
	  MOV	A,M		;get new parameter
	  STA	PARM		;and save it
	  ENDIF
;
	  CALL	JMP$ILPRT
	  DB	CR,LF,LF,'Modem setup completed.',CR,LF,0
;
INITMOD:  LDA	UART		;select UART
	  OUT	UPORT
	  LDA	PARM		;select data bits, parity, stop bits
	  OUT	MPORT
	  LDA	MSPEED		;select baud rate
	  LXI	H,SPEEDTAB
	  MVI	B,0
	  MOV	C,A
	  DAD	B
	  MOV	A,M
	  OUT	MPORT
	  MVI	A,27H		;turn on DTR, etc.
	  OUT	CPORT
	  RET
;
	  IF	BAUDOP
SPEEDTAB: DB	72H		;  110 bps
	  DB	75H		;  300 bps
	  DB	75H		;  300 bps
	  DB	76H		;  600 bps
	  DB	76H		;  600 bps
	  DB	77H		; 1200 bps
	  DB	7AH		; 2400 bps
	  DB	7CH		; 4800 bps
	  DB	7EH		; 9600 bps
	  DB	7FH		;19200 bps
;
MSPEDTAB: DB	0		;  110 bps
	  DB	1		;  300 bps
	  DB	3		;  600 bps
	  DB	5		; 1200 bps
	  DB	6		; 2400 bps
	  DB	7		; 4800 bps
	  DB	8		; 9600 bps
	  DB	9		;19200 bps
	  ENDIF
;
	  IF	PARMOP
PARMTAB:  DB	06EH		;8N1
	  DB	0EEH		;8N2
	  DB	07EH		;8E1
	  DB	0FEH		;8E2
	  DB	06AH		;7N1
	  DB	0EAH		;7N2
	  DB	07AH		;7E1
	  DB	0FAH		;7E2
	  ENDIF
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU:  RET
;
;
; NOTE:	 MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;.....
;
	  END
