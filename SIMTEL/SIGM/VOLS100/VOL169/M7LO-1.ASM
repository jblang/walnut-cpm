
; M7LO-1.ASM -- Lobo Max-80 overlay file for MDM7xx.  11/11/83
;
; This overlay adapts the MDM7xx program to Max-80 computers from Lobo.
; You will want to look this file over carefully.  There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using an external modem that
; does not match one of the other special overlays.
;
; If using the Hayes Smartmodem, switch SW6 should normally be down.  If
; for any reason you must have it up, then use the Lobo XCONFIG.COM to
; to disable the hardware and sofware handshaking on the RS-232C ports.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
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
;		-IM7LO-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/11/83 - Renamed to M7LO-1.ASM, no changes	- Irv Hoff
; 10/07/83 - Revised to include modem break	- Steven J. Davidson
; 08/22/83 - Revised to work with Max-80	- Larry Richards
; 07/27/83 - Revised to work with MDM712	- Irv Hoff
; 04/04/83 - 1st version of M712GP		- Irv Hoff
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
PORT:		EQU	0F7E4H		;MAX-80 data port
MODCTL1:	EQU	PORT+1		;modem control port MAX-80
MODDATP:	EQU	PORT		;modem data in port
MODDATO:	EQU	PORT		;modem data out port
MODDCDB:	EQU	4		;carrier detect bit
MODDCDA:	EQU	0		;value when active
BAUDRP:		EQU	0F7D0H		;baud rate port MAX-80
MODCTL2:	EQU	PORT+1		;2nd modem control port
MODRCVB:	EQU	1		;bit to test for receive
MODRCVR:	EQU	1		;value when ready
MODSNDB:	EQU	4		;bit to test for send
MODSNDR:	EQU	4		;value when ready
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	50	;clock speed in MHz x10, 25.5 MHz max.	106H
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
IN$MODCTL1:	LDA	MODCTL1 ! RET	;in modem control port MAX-80	12AH
		DS	6
OUT$MODDATP:	STA	MODDATP ! RET	;out modem data port MAX-80	134H
		DS	6
IN$MODDATP:	LDA	MODDATP ! RET	;in modem data port MAX-80	13EH
		DS	6
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H

CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				156H
;
OUT$MODCTL1:	NOP  !	NOP		;out modem control port #2	15AH
OUT$MODCTL2:	LDA	MODCTL2	! RET	;out modem control port #1	15DH
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
; Routine to clear to end of screen.
;
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	1BH,59H,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	1BH,2AH,0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Lobo Max-80',CR,LF,0
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
LOGON:	  DB	'Hello from a Lobo MAX-80 computer',CR,LF,0
;.....
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,5
	  STA	MODCTL1
	  MVI	A,0F8H		;send a break tone
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and/or sets DTR low for the
; same length of time to disconnect some modems such as the Bell 212A,
; etc.	The second entry (GOODBYE1) just sends the modem break, needed
; to "alert" some timesharing services.
;
;
GOODBYE:  MVI	A,5
	  STA	MODCTL1		;send to the status port
	  MVI	A,68H		;turn off dtr
;
GOODBYE1: STA	MODCTL1
	  MVI	B,3		;wait for 300 ms.
	  CALL	JMP$TIMER
	  MVI	A,5
	  STA	MODCTL1
	  MVI	A,0E8H		;restore to normal, 8 bits, dtr on, etc.
	  STA	MODCTL1
	  RET
;.......
;
;
; Uses the initialization already established by CP/M BIOS on a reboot.
;
INITMOD:  RET
;.....
;
;
SETUPR:	  LXI	D,BAUDBUF	;point to new buffer
	  CALL	JMP$ILPRT
	  DB	'Input baud rate (300, 600, 1200, 2400, 4800, '
	  DB	'9600 or 19200):',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2	;past the 2 size bytes
	  CALL	JMP$INLNCOMP
	  DB	'300',0
	  JNC	OK300		;see if 300 baud
	  CALL	JMP$INLNCOMP
	  DB	'600',0
	  JNC	OK600		;see if 600 baud
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200		;see if 1200 baud
	  CALL	JMP$INLNCOMP
	  DB	'2400',0
	  JNC	OK2400		;see if 2400 baud
	  CALL	JMP$INLNCOMP
	  DB	'4800',0
	  JNC	OK4800		;see if 4800 baud
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600		;see if 9600 baud
	  CALL	JMP$INLNCOMP
	  DB	'19200',0
	  JNC	OK19200		;see if 19200 baud
	  CALL	JMP$ILPRT	;both matches failed
	  DB	'++  INCORRECT ENTRY ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;.....
;
;
OK300:	  MVI	A,1		;for 300 baud
	  MVI	B,5
	  JMP	SAVEALL
;...
;
;
OK600:	  MVI	A,3		;for 600 baud
	  MVI	B,6
	  JMP	SAVEALL
;...
;
;
OK1200:	  MVI	A,5		;for 1200 baud
	  MVI	B,7
	  JMP	SAVEALL
;...
;
;
OK2400:	  MVI	A,6		;for 2400 baud
	  MVI	B,10
	  JMP	SAVEALL
;...
;
;
OK4800:	  MVI	A,7		;for 4800 baud
	  MVI	B,12
	  JMP	SAVEALL
;...
;
;
OK9600:	  MVI	A,8		;for 9600 baud
	  MVI	B,14
	  JMP	SAVEALL
;...
;
;
OK19200:  MVI	A,9		;for 19200 baud
	  MVI	B,15
	  JMP	SAVEALL
;...
;
;
SAVEALL:  STA	MSPEED
	  MOV	A,B
	  STA	BAUDRP
	  RET
;.....
;
;
BAUDBUF:  DB	10,0
	  DS	10
;.....
;
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU:  RET
;
;
; NOTE:  Must terminate prior to 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;.....
;
	  END
;
	  JNC	OK19200		;see if 19200 baud
	  CALL	JMP$ILPRT	;both matches failed
