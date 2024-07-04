; MXO-R213.ASM -- TRS-80 Model II overlay file for Mex.  1/11/87
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the TRS-80 Model II (and probably Models 12 and 16)
; computers to MEX.	Requires Pickles & Trout CP/M.
;
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.	
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 01/11/87 - Added Parity,Stopbit,Length SET	- Biff Bueffel
; 01/26/86 - Added Mex Set command		- Biff Bueffel
; 06/07/85 - Corrected 9600 baud error {p&t pg. 16.8} - Bob Perigo
; 04/20/85 - Baud change with P&T 2.2m system functions - Bob Perigo
; 11/11/83 - Renamed to M7R2-1.ASM, no changes	- Irv Hoff
; 09/18/83 - Modified M712XE.ASM for 
;	     TRS-80 Model II and Pickles
;	     & Trout CP/M (should also 
;	     work on Mods 12 and 16)	        - Joseph Katz
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
TAB:		EQU	09H		;HORIZONTAL TAB
;
YES:		EQU	0FFH
NO:		EQU	0
;
; MEX service processor stuff
;
MEX	EQU	0D00H		;address of the service processor
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
;
PRINT	EQU	9		;MEX/BDOS print-string function call
;
;
PORT:		EQU	0F4H		;TRS-80 II serial output port A
MODCTL1:	EQU	PORT+2		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+2		;Modem status port
MODRCVB:	EQU	01H		;Bit to test for receive
MODRCVR:	EQU	01H		;Value when receive ready
MODSNDB:	EQU	04H		;Bit to test for send
MODSNDR:	EQU	04H		;Value when send ready		
;
SDB8            EQU     01100000B       ;set data bits to 8
SDB7            EQU     01000000B       ;... and 7
SDB6            EQU     00100000B       ;... and 6
SDB5            EQU     0               ;... and 5
RDB             EQU     10011111B       ;reset data bits
DATBITM         EQU     01100000B       ;data bit mask
;
SPOFF           EQU     0               ;set parity to off
SPODD           EQU     00000001B       ;set parity to odd
SPEVEN          EQU     00000011B       ;set parity to even
RPOFF           EQU     11111100B       ;reset parity bits (to off)
PARITYM         EQU     00000011B       ;parity mask
;
SSB1            EQU     00000100B       ;set stop bits to 1
SSB15           EQU     00001000B       ;... and 1.5
SSB2            EQU     00001100B       ;... and 2
RSB             EQU     11110011B       ;reset stop bits
STPBITM         EQU     00001100B       ;stop bit mask
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
		DB	NO	;yes=PMMI S-100 Modem			103H
		DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TPULSE:		DB	'P'     ;T=touch, P=pulse (Smartmodem-only)     105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED: 	DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY: 	DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFLG:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	NO	;cursor control routine 		10CH
		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKFLG:		DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFL:		DB	YES	;yes=default to CRC checking		10FH
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
		DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP: 	DB	YES	;yes=do not overwrite CCP		116H
		DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
		DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST: 	DB	YES	;yes=printer available on printer port	119H
XOFTST:		DB	NO	;yes=check for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
NDELAY: 	DB	30	;for future expansion			11EH
EXITCHR: 	DB	'E'-40H	;^E=Exit to Main menu			11FH
BRKCHR: 	DB	'@'-40H ;^@ = Send a 300 ms. break tone         120H
NOCONN:		DB	'N'-40H ;^N = Disconnect from the phone line    121H
LOGCHR: 	DB	'L'-40H ;^L = Send logon                        122H
LSTCHR: 	DB	'P'-40H ;^P = Toggle printer                    123H
UNSAVE: 	DB	'R'-40H ;^R = Close input text buffer           124H
TRNCHR:		DB	'T'-40H ;^T = Transmit file to remote           125H
SAVCHR:		DB	'Y'-40H ;^Y = Open input text buffer            126H
EXTCHR: 	DB	'^'-40H ;^^ = Send next character               127H
;
;
		DS	2		;				
IN$MODCTL1:	MVI	A,10H		;channel 0, reset interrupts	
		OUT	MODCTL1
		IN	MODCTL1		;get the status bits
		RET
		DS	3
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	
		DS	6		;				
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port 	
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem status port		
;
;
		DS	2		;Not used by MEX.		160H
		DS	6		;				162H
GOODBV:		JMP	GOODBY 		;				168H
INMODV:		JMP	NITMOD	 	;go to user written routine	16BH
NEWBDV:		JMP  	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
SETUPV:		JMP	SETCMD		;				177H
		DS	3		;Not used by MEX		17AH
VERSNV:		JMP	SYSVER		;				17DH
BREAKV:		JMP	SBREAK	 	;				180H
;
;
; Do not change the following six lines.
;
ILPRTV:		DS	3		;				183H
INBUFV:		DS	3		;				186H
ILCMPV:		DS	3		;				189H
INMDMV		DS	3		;				18CH
		DS	3		;				18FH
TIMERV:		DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  
;
CLREOS:		LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLS:	LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
SYSVER:		MVI	C,ILP		;				1A7H
		CALL	MEX
		DB	'TRS-2 VERSION (FOR P&T & SERIAL PORT A)'
		DB	CR,LF,0
		RET
;
;
SBREAK:  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0F8H		;SEND A BREAK TONE
	  JMP	GOODBY1
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBY:   MVI	A,5
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,78H		;TURN OFF DTR
;
GOODBY1:  OUT	MODCTL1
	  MVI	B,3		;WAIT FOR 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0E8H		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCTL1
	  RET
;
;	
; TRS-80 II initialization -- Uses P&T service calls for baud change
;
NITMOD:  MVI	B,0		;PORT CALL
	  MVI	C,0		;SETUP A NO PARITY
	  MVI	D,0E6H		;RTS HI, 1 STOP, 8 BITS, DTR HI
PTCODE:	  MVI	E,5H		;P&T'S SPEED CODE DEFAULT {1200}
	  LXI	H,0		;NO PROTOCOL
	  CALL	40H		;DO IT
	  RET
;
;
;
; Setup routine to allow changing modem speed with the SET command.
;
;
;Set command processor
;
SETCMD:	  MVI	C,SBLANK	;ANY ARGUMENTS?
	  CALL  MEX
	  JC	SETSHO		;IF NOT, DISPLAY DEFAULT(S)
	  LXI	D,CMDTBL
          MVI	C,LOOKUP
	  CALL  MEX		;PARSE THE ARGUMENT
	  PUSH	H		;SAVE ANY PARSED ARGUMENTS ON STACK
	  RNC			;IF WE HAVE ONE, RETURN TO IT
	  POP	H		;OOPS, INPUT NOT FOUND IN TABLE
SETERR:   CALL 	MILP
	  DB	CR,LF,'SET command error',CR,LF,0
	  RET
;
;Argument table
;
CMDTBL:   DB	'?'+80H			;HELP
	  DW	SETHELP
	  DB	'ORI','G'+80H		;ORIGINATE MODE
	  DW	ORIG
	  DB	'ANSWE','R'+80H		;ANSWER MODE
	  DW	ANS
	  DB	'TON','E'+80H		;TONE DIALING
	  DW	STTONE
	  DB	'PULS','E'+80H		;PULSE DIALING
	  DW	STPULSE
	  DB	'DELA','Y'+80H		;SET DELAY
	  DW	DELAY
	  DB	'BAU','D'+80H		;SET BAUD
	  DW	STBAUD
	  DB	'PARIT','Y'+80H		;SET PARITY
	  DW	STPRTY
	  DB	'STOPBIT','S'+80H	;SET STOPBITS
	  DW    STSTOP
	  DB	'LENGT','H'+80H		;SET LENGTH
	  DW	STBITS
	  DB	0			;TABLE TERMINATOR
; "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL  MILP	
	  DB	CR,LF
	  DB	'SET values:',CR,LF,CR,LF,0
	  CALL	MDSHOW
	  CALL	CRLF
	  CALL	TPSHOW
	  CALL	CRLF
	  CALL	DLSHOW
	  CALL	CRLF		
	  CALL	BDSHOW
	  CALL	CRLF
	  CALL  SHPRTY
	  CALL	CRLF
	  CALL	SHSTOP
	  CALL	CRLF
	  CALL  SHBITS
	  CALL	CRLF
	  RET
;"SET ?" processor
;
SETHELP:  CALL	MILP

	  DB	CR,LF,'SET ORIG'
	  DB	CR,LF,'SET ANSWER'
	  DB	CR,LF,'SET TONE'
	  DB	CR,LF,'SET PULSE'
	  DB	CR,LF,'SET DELAY     - <N> seconds'
	  DB	CR,LF,'SET BAUD      - 300, 600, 1200, 2400, '
	  DB	'4800, 9600'
	  DB	CR,LF,'SET PARITY    - OFF, EVEN or ODD'
	  DB	CR,LF,'SET STOPBITS  - 1, 1.5 or 2'
	  DB	CR,LF,'SET LENGTH    - 5, 6, 7 or 8'
	  DB	CR,LF,CR,LF,0
	  RET
;"SET BAUD" processor
;
STBAUD:	  MVI	C,SBLANK	;
	  CALL	MEX
	  JC	SETERR		;
	  LXI	D,BDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;Parse argument
	  PUSH	H		;Save any parsed argument addrs on stack
	  RNC			;If we have one, return to it
	  POP	H		;Oops, input not found in table
	  CALL	MILP		;Tell user input not valid
	  DB	CR,LF,'That baudrate not supported by SET command',CR,LF,0
	  RET
;
BDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'60','0'+80H
	  DW	OK600
	  DB	'120','0'+80H
	  DW	OK1200
	  DB	'240','0'+80H
	  DW	OK2400
	  DB	'480','0'+80H
	  DW	OK4800
	  DB	'960','0'+80H
	  DW	OK9600
	  DB	0
;
;
OK300:	  MVI	A,1
	  MVI	H,BD300
	  JMP	LOADBD
;
OK600:	  MVI	A,3
	  MVI	H,BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  MVI	H,BD1200
	  JMP	LOADBD
;
OK2400:	  MVI	A,6
	  MVI	H,BD2400
	  JMP	LOADBD
;
OK4800:	  MVI	A,7
	  MVI	H,BD4800
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  MVI	H,BD9600
;
LOADBD:	  STA	MSPEED		;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,H		;GET P&T PARAMETER
	  STA	PTCODE+1	;PUT IT TO USE
	  JMP	NITMOD		;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	3
	  JZ	OK600
	  CPI	5
	  JZ	OK1200
	  CPI	6
	  JZ	OK2400
	  CPI	7
	  JZ	OK4800
	  CPI	8
	  JZ	OK9600
	  RET
;
;	TABLE OF P&T BAUDRATE PARAMETERS
;
BD300:	  EQU	3H
BD600:	  EQU	4H
BD1200:	  EQU	5H
BD2400:	  EQU	6H
BD4800:	  EQU	7H
BD9600:	  EQU	8H	;the 9 on pg 16.8 of p&t 2.2m manual is typo.
;
BDSHOW:	  LDA	MSPEED		;GET CURRENT BAUD RATE
	  MVI	C,PRBAUD	;LET MEX PRINT IT
	  CALL	MEX
	  RET 
;
;
;SET MODE PROCESSOR 
;
ORIG:	  XRA	A
	  STA	ANSFLG		;SET ORIG FLAG
	  LXI	H,SMO		;SEND OUT ATS0=0
	  CALL	SMSEND
	  RET
;
ANS:	  MVI	A,0FFH
	  STA	ANSFLG		;SET ANS FLAG
	  LXI	H,SMA		;SEND OUT ATS0=1
	  CALL	SMSEND
	  RET			;EXIT 
;
;Send string to the SmartModem
;
SMSEND:	  MVI	C,SNDRDY	;WAIT FOR MODEM READY
	  CALL	MEX
	  JNZ	SMSEND
	  MOV	A,M		;FETCH NEXT CHARACTER
	  INX	H
	  ORA	A		;END?
	  RZ			;DONE IF SO
	  MOV	B,A		;NO, POSITION FOR SENDING
	  MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	  CALL	MEX
	  JMP	SMSEND
;
MDSHOW:	  LDA	ANSFLG
	  ORA	A
	  JZ	MDORIG		
	  CALL	MILP
	  DB	'Auto-answer mode',0
	  RET
MDORIG:	  CALL	MILP
	  DB	'Originate mode',0
	  RET
;
SMO:	  DB	'ATS0=0',CR,0
SMA:	  DB	'ATS0=1',CR,0
SMD:	  DB	'ATS7=60',CR,0
;
;Set dial processor
;
STTONE:	  MVI	A,'T'
	  JMP	SDIAL1
STPULSE:  MVI	A,'P'
SDIAL1:   STA	TPULSE
	  RET
TPSHOW:	  LDA	TPULSE
	  CPI	'T'
	  JZ	TPTONE
	  CALL	MILP
	  DB	'Pulse Dial',0
	  RET
TPTONE:	  CALL	MILP
	  DB	'Tone Dial',0	  
	  RET
;
;Set delay processor
;
DELAY:	  MVI	C,EVALA
	  CALL	MEX
	  MOV	A,H
	  ORA	A
	  JNZ	SETERR
	  MOV	A,L
	  STA	NDELAY
	  LXI	H,SMD
	  CALL	SMSEND
	  RET
DLSHOW:	  CALL	MILP
	  DB	'Answer Delay is ',0
	  LHLD	NDELAY
	  MVI	H,0
	  MVI	C,DECOUT
	  CALL	MEX
	  CALL	MILP
	  DB	' seconds',0
	  RET
;
;	SET PARITY command: reset transmit/receive parity
;
STPRTY:	  MVI	C,SBLANK	;check for parity code
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,PARTBL	;check for proper syntax
	  MVI	C,LOOKUP
	  CALL	MEX
	  JC	SETERR
 	  LDA	NITMOD+3
	  ANI	RPOFF		;Reset parity bits (also sets parity off)
	  PCHL			;go to the proper section
;
PREVEN:	  ORI	SPEVEN
	  JMP	PARTB1
PRODD:	  ORI	SPODD
PARTB1:	  STA	NITMOD+3	;Also comes to this point if set parity to off
	  JMP	NITMOD
;
SHPRTY:	  CALL	MILP
	  DB	'Parity:  ',TAB,' ',0
	  LDA	NITMOD+3
	  ANI	PARITYM
	  CPI	SPOFF	;parity off?
	  JNZ	SHPRT1
	  CALL	MILP
	  DB	'Off',0
	  RET
SHPRT1:	  CPI	SPODD	;parity odd?
	  JNZ	SHPRT2
	  CALL	MILP
 	  DB	'Odd',0
	  RET
SHPRT2:	  CALL	MILP		;
	  DB	'Even',0	;
	  RET
;
;	SET PARITY command table
;
PARTBL:	  DB	'OF','F'+80H	;"set parity off"
	  DW	PARTB1
	  DB	'EVE','N'+80H	;"set parity even"
	  DW	PREVEN
	  DB	'OD','D'+80H	;"set parity odd"
	  DW	PRODD
	  DB	0		;<<== end of parity table
;
;-------
;	SET STOPBITS command: reset number of stop bits
;

STSTOP:	  MVI	C,SBLANK	;check for stop bits
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,STPTBL	;check for proper syntax
	  MVI   C,LOOKUP
	  CALL	MEX		;
	  JC	SETERR		;print error
	  LDA	NITMOD+5
	  ANI	RSB		;reset stop bits
	  PCHL			;go do it

STOP01:	  ORI	SSB1
	  JMP	STSTP1
STOP15:	  ORI	SSB15
	  JMP	STSTP1
STOP02:	  ORI	SSB2
STSTP1:	  STA	NITMOD+5
	  JMP	NITMOD
;
;
SHSTOP:	  CALL	MILP		;display stop-bits
	  DB	'Stop bits:',TAB,' ',0
	  LDA	NITMOD+5		;
	  ANI	STPBITM
	  CPI	SSB1
	  JNZ	SHSTP2
	  CALL	MILP
	  DB	'1',0
	  RET
SHSTP2:	  CPI	SSB2
          JNZ	SHSTP15
	  CALL	MILP
	  DB	'2',0
	  RET
SHSTP15:	
	  CALL	MILP
	  DB	'1.5',0
	  RET

;
;	SET STOPBITS command table
;
STPTBL:	  DB	'1'+80H		;"set stop 1"
	  DW	STOP01
	  DB	'2'+80H		;"set stop 2"
	  DW	STOP02
	  DB	'1.','5'+80H	;1.5 stop bits
	  DW	STOP15
	  DB	0		;<<== End of stop-bits table
;
;-------
;	SET LENGTH command: set bits per character
 

STBITS:	  MVI	C,SBLANK	;check for bits/char
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,BITTBL	;check for proper syntax
	  MVI	C,LOOKUP
	  CALL	MEX
	  JC	SETERR
	  LDA	NITMOD+5
	  ANI	RDB		;reset data bits (also = 5 bit)
          PCHL			;go do function

BIT6:	  ORI	SDB6	;6 bits
	  JMP	STBTS1	  
BIT7:	  ORI	SDB7	;7 bits
	  JMP	STBTS1
BIT8:	  ORI	SDB8	;8 bits
STBTS1:	  STA	NITMOD+5	;also comes here if set bits to 5
	  JMP	NITMOD

SHBITS:	  CALL	MILP		;display bits/char
	  DB	'Bits/char:',TAB,' ',0
	  LDA	NITMOD+5		;
	  ANI	DATBITM
	  JZ	SHDB5
	  CPI	SDB6
	  JZ	SHDB6
	  CPI	SDB7
	  JZ	SHDB7
	  CALL	MILP
	  DB	'8',0
	  RET
SHDB7:	  CALL 	MILP
	  DB	'7',0
	  RET
SHDB6:	  CALL	MILP
	  DB	'6',0
	  RET
SHDB5:	  CALL	MILP
	  DB	'5',0
	  RET

;
;	SET LENGTH command table
 
BITTBL:	  DB	'5'+80H		;"set bits 5"
	  DW	STBTS1
	  DB	'6'+80H		;"set bits 6"
	  DW	BIT6
          DB	'7'+80H		;7 BITS
	  DW	BIT7
       	  DB	'8'+80h		;8 bits
	  DW	BIT8
	  DB	0		;<<== end of bpc table
;
;General utility routines
;
MILP:	  MVI	C,ILP		;IN-LINE PRINT
	  JMP	MEX
	  RET
;
CRLF:     CALL  MILP            ;PRINT CARRIAGE RETURN, LINE FEED
          DB    CR,LF,0
          RET
;
;------
;
ANSFLG:   DB	0	
EOSMSG:	  DB	0FH,14H,16H,1AH,02H,'$'		  	
CLSMSG:	  DB	0FH,14H,16H,1AH,0CH,'$'
BAUDBUF:  DB	10,0
	  DS	10
;
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;
	  END
