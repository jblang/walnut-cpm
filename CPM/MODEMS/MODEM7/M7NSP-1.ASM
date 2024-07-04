; M7NSP-1.ASM - NSC Starplex overlay file for MDM7xx	08/15/83
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the NSC Starplex Development System to the modem pro-
; gram.  There are two versions of this program, determined by the selec-
; tion of the equate VAX.  This equate set YES sets the program up for a
; single baud rate option of 2400 baud for optimum performance with the
; system connected directly to a port on the DEC VAX 11/780.  This option
; requires special attention to setting up the Starplex 8253 baud rate
; clock counter.  The NOT VAX option sets up the program to operate as a
; normal Modem 711 program, with selection of either 300 or 1200 baud,
; as originally written.  This overlay program is an adaptation of one
; that was written for the Morrow Decision computer, using the 8251 USART.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
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
;		-IM7NSP-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4x00 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
;                       ^
;                     Value may vary with version of MDM7xx
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 04/11/84 - Renamed to M7NSP-1.ASM            - Dennis Recla  
; 08/15/83 - Revised for use with MDM711 on the
;	     NSC Starplex Development System -	- Charles Horn
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
PORT:		EQU	0EEH		;Starplex data port
MODCTL1:	EQU	PORT+1		;Modem status port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+1		;Modem control port
CLKPORT:	EQU	PORT-10H	;Baud clock rate port
MODRCVB:	EQU	2		;bit to test for received data
MODRCVR:	EQU	2		;modem receive ready
MODSNDB:	EQU	1		;bit to test for ready to send
MODSNDR:	EQU	1		;modem send ready bit
;
VAX:		EQU	NO		;YES = for VAX ll/780; 2400 baud only
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=Touch, P=Pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED: 	DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY: 	DB	0	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	0	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	NO	;Cursor control routine 		10CH
ACKNAK: 	DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	YES	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP: 	DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST: 	DB	NO	;no=no printer on printer port (modem)	119H
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1: 	DB	0	;for future expansion			11EH
EXTRA2: 	DB	0	;for future expansion			11FH
BRKCHR: 	DB	'@'-40H ;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H ;^N = Disconnect from phone line	121H
LOGCHR: 	DB	'O'-40H ;^O = Send logon			122H
LSTCHR: 	DB	'P'-40H ;^P = Toggle printer			123H
UNSAVE: 	DB	'R'-40H ;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H ;^Y = Open input text buffer		126H
EXTCHR: 	DB	'^'-40H ;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	151H
		DS	12
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE 	;				168H
JMP$INITMOD:	JMP	INITMOD 	;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK 	;				180H
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
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
; The SCRNTST option must be set "YES" for these to work.  These are now
; set for the NSC Starplex Development System.
;
CLREOS: 	CALL	JMP$ILPRT	;				195H
		DB	0,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	0,0,0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER: 	CALL	JMP$ILPRT	;				1A7H
		DB	'Version for NSC Starplex Development System'
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
; CTL-O if TRANLOGON has been set YES.	You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:	  DB	'This is a Dummy Logon Message',CR,LF,0
;.....
;
;
;=======================================================================
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computer.
;
SENDBRK:  MVI	A,1FH		;SEND BREAK TONE
	  JMP	GOODBYE1
;...
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI	A,15H		;SEND BREAK, TURN OFF DTR
;
GOODBYE1: OUT	MODCTL1 	;SEND TO STATUS PORT
	  MVI	B,3		;WAIT 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,07H		;NORMAL SEND/RECEIVE WITH DTR
	  OUT	MODCTL1 	;SEND TO STATUS PORT
	  RET
;.....
;
;
; USART initialization -- sets the 8251A for 8 bits, 1 stop pulse,
; DTR high, using the Starplex RS-232 port no. 2, to 1200 baud then
; divides by 64 for 300, or by 16 for 1200 baud via "SET" command.  Set
; at present to default to 300 baud. The VAX option is fixed at 2400 baud.
;
INITMOD:  MVI	A,1		;TRANSFER TIME FOR 300 BAUD
	  STA	MSPEED	
	  DI			;DISABLE INTERRUPTS FOR THIS
	  XRA	A
	  MVI	B,4		;INSURE
OUTMODE:  OUT	MODCTL1 	;..OUT
	  DCR	B		;....OF
	  JNZ	OUTMODE 	;......MODE
	  MVI	A,40H		;RESET UART AND
	  OUT	MODCTL1 	;..SET TO MODE
;
INITMOD1:
	  IF	VAX		;VAX 11/780
	  MVI	A,4EH		;DIVIDE BY 16
	  ENDIF ;VAX
	  IF	NOT VAX 	;NORMAL MODEM711
	  MVI	A,4FH		;DEFAULT TO DIVIDE BY 64 FOR 300 BAUD
	  ENDIF ;NOT VAX
	  OUT	MODCTL1 	;SET MODE
	  MVI	A,37H		;RTS,RESET ERR FLAGS,DTR,RX&TX ENABLE
	  OUT	MODCTL1 	;MODEM STATUS PORT
	  IN	MODDATP 	;CLEAR
	  IN	MODDATP 	;..GARBAGE
;
	  MVI	A,0B6H		;TIMER 2 MODE
	  OUT	CLKPORT+1
	  IF	VAX
	  MVI	A,30H		;LS BYTE FOR 2400 BAUD
	  ENDIF ;VAX
	  IF NOT VAX
	  MVI	A,60H		;NORMAL STARPLEX DIVISOR
	  ENDIF ;NOT VAX
	  OUT	CLKPORT
	  MVI	A,00H		;MS BYTE FOR BAUD DIVISOR
	  OUT	CLKPORT
	  EI			;ENABLE INTERRUPTS
	  RET
;.....
;
SETUPR:
	  IF	VAX
	  CALL	JMP$ILPRT
	  DB	'Baud Rate is fixed at 2400 for VAX 11/780...',CR,LF,0
	  JMP	INITMOD 	;NONE OF THE FOLLOWING FOR VAX
	  ENDIF ;VAX
	  IF	NOT VAX
	  LXI	D,BAUDBUF	;POINT TO NEW INPUT BUFFER
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 1200): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	  DB	'300',0
	  JNC	OK300		;GO IF GOT MATCH
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$ILPRT	;ALL MATCHES FAILED, TELL OPERATOR
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;TRY AGAIN
;
OK300:	  MVI	A,1		;MSPEED 300 BAUD VALUE
	  MVI	B,4FH		;DIVIDE BY 64 FOR 300 BAUD
	  JMP	LOADBD		;GO LOAD THEM
;
OK1200:   MVI	A,5
	  MVI	B,4EH		;DIVIDE BY 16 FOR 1200 BAUD
;
;
LOADBD:   STA	INITMOD+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,B		;GET BAUDRATE BYTE
	  STA	INITMOD1+1	;STORE IN INITMOD
	  JMP	INITMOD 	;REINITIALIZE TO NEW BAUDRATE, THEN DONE
	  ENDIF ;NOT VAX
;
;
BAUDBUF:  DB	10,0
	  DS	10
;.....
;
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;		
;
; These routines can be used for your equipment, be sure to end with RET
;
SPCLMENU: RET
;		
;=======================================================================
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem).
;
	  END
;
