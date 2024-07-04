;     MXO-ZB11.ASM -- Telcon Zorba overlay file for MEX10 - 05/24/84
;
;
; Use the MEX "SET" command to change the baudrate when desired.  It
; starts out at 300 baud when the program is first called up.
;
;  TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
;	<modified 12/8/84 Bill Pechter, added additional baud rates>
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
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
DPORT:		EQU	020H		;ZORBA Modem Data Port
MODCT1:		EQU	DPORT+1		;Modem status port
MODCT2:		EQU	DPORT+1		;Modem control port
MODDAT:		EQU	DPORT		;Modem data port
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;

PMODEM:		DB	NO	;yes=PMMI S-100 Modem			103H
SMODEM:		DB	YES	;yes=HAYES Smartmodem			104H
TPULSE:		DB	'T'	;T=tone, P=Pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	3	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFLG:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES	;cursor control routine 		10CH
		DB	YES	;yes=resend a record after a non-ACK	10DH
				;no=resend a record only after NAK
BAKFLG:		DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFL:		DB	YES	;yes=default to CRC checking		10FH
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
		DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
		DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
		DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	19H
XOFTST:		DB	NO	;yes=chcks for XOFF from remote	while	11AH
 				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXITCHR:	DB	'E'-40H	;'E'= Exit to main menu			11FH
BRKCHR		DB	'@'-40H	;Send a 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRNCHR:		DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:		DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'\'-40H	;^\ = Send next character		127H
;
;
		DS	2		;				128H
;
INCTL1:		IN	MODCT1 ! RET	;in modem control port		12AH
		DS	7
OTDATA:		OUT	MODDAT ! RET	;out modem data port		134H
		DS	7
INPORT:		IN	MODDAT ! RET	;in modem data port		13EH
		DS	7
MASKR:		ANI	2      ! RET
TESTR:		CPI	2      ! RET
MASKS:		ANI	1      ! RET
TESTS:		CPI	1      ! RET
		DS	12		
;
		DS	2		;Not used by MEX		160H
		DS	6		;				162H
GOODBV:		JMP	GOODBY		;				168H
INMODV:		JMP	NITMOD		;go to user written routine	16BH
NEWBDV:		JMP	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
SETUPV:		JMP	SETCMD		;				177H
		DS	3		;				17AH
VERSNV:		JMP	SYSVER		;				17DH
BREAKV:		JMP	SBREAK		;				180H
;
;
; Do not change the following six lines.
;
ILPRTV:		DS	3		;				183H
INBUFV:		DS	3		;				186H
ILCMPV:		DS	3		;				189H
INMDMV:		DS	3		;				18CH
		DS	3		;				18FH
TIMERV:		DS	3		;				192H
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
;
CLREOS:		LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLRSCRN:	LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
SYSVER:		MVI	C,ILP		;				1A7H
		CALL	MEX
		DB	'*** Version for Gemini/Telcon ZORBA ***'	
		DB	CR,LF,0
		RET
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SBREAK:   MVI	A,1FH
	  JMP	GOODBY1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBY:  MVI	A,07H		;SEND BREAK, TURN OFF DTR
;
;	disabled to avoid dropping line when leaving mex
;
;
GOODBY1:  OUT	MODCT1		;SEND TO STATUS DPORT
	  MVI	B,3		;DELAY ABOUT 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,07H		;NORMAL SEND/RECEIVE WITH DTR
	  OUT	MODCT1		;SEND TO STATUS DPORT
	  RET
;
;
; ZORBA initialization -- sets CTC timer 0 for baudrate in/out.
;
; ZORBA specific equates for initialization.
;
CTCCMD:	  EQU	03H		;8253 Timer control/status
CTC0:	  EQU	00H		;Timer 0 (port A)
LSB300	  EQU	83H		;Default 300 baud
MSB300	  EQU	06H
;
;
NITMOD:   MVI	A,1		;DEFAULT TRANSFER TIME TO 300 BAUD
	  STA	MSPEED
;
NITMOD1:  MVI	A,36H		;SQUARE WAVE MODE, PORT A
	  OUT	CTCCMD
;
LSBD:	  MVI	A,LSB300
	  OUT	CTC0
;
MSBD:	  MVI	A,MSB300
	  OUT	CTC0
	  RET
;.....
;
;
;
SETCMD:	  MVI	C,SBLANK	;Any arguments?
	  CALL	MEX
	  JC	TELL		;If not, go display baud
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;Parse argument
	  PUSH	H		;Save any parsed argument addrs on stack
	  RNC			;If we have one, return to it
	  POP	H		;Oops, input not found in table
	  MVI	C,ILP
	  CALL	MEX		;Tell user input not valid
	  DB	'++(Only 300,450,600,1200,2400,9600,19200 supported)++',CR,LF,0 
	  RET
;
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  ;
	  DB	'45','0'+80H
	  DW	OK450
	  ;
	  DB	'60','0'+80H
	  DW	OK600
	  ;
	  DB	'120','0'+80H
	  DW	OK1200
	  ;
	  DB	'240','0'+80H
	  DW	OK2400
	  ;						
	  DB	'480','0'+80H
	  DW	OK4800
	  ;
	  DB	'960','0'+80H
	  DW	OK9600
	  ;
	  DB	'1920','0'+80H
	  DW	OK19200
	  ;
	  DB	'30','0'+80H
	  DW	OK300
	  DB	0
;
;
TELL:	  MVI	C,ILP
	  CALL	MEX		;Print current baud rate
	  DB	CR,LF,'Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
;
OK300:	  MVI	A,1		;MSPEED 300 BAUD VALUE
	  LHLD	BD300		;GET 300 BAUD PARAMETERS IN 'HL'
	  JMP	LOADBD		;GO LOAD THEM
;
OK450:	  MVI	A,2
	  LHLD	BD450
	  JMP	LOADBD
;
OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400:	  MVI	A,6
	  LHLD	BD2400
	  JMP	LOADBD
;
OK4800:	  MVI	A,7
	  LHLD	BD4800
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD
;
OK19200:  MVI	A,9
	  LHLD	BD19200		;FALL THRU.....
;
LOADBD:	  STA	NITMOD+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,L		;GET LEAST SIGNIFICANT BAUDRATE BYTE
	  STA	LSBD+1		;STORE IN NITMOD
	  MOV	A,H		;GET MOST SIGNIFICANT BAUDRATE BYTE
	  STA	MSBD+1		;STORE IN NITMOD
	  JMP	NITMOD		;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	2
	  JZ	OK450
	  CPI	5
	  JZ	OK1200
	  CPI	6
	  JZ	OK2400
	  CPI	7
	  JZ	OK4800
	  CPI	8
	  JZ	OK9600
	  CPI	9
	  JZ	OK19200
	  RET
;
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300:	  DW	0683H		;  300 BAUD
BD450:	  DW	0457H		;  450 BAUD
BD600:	  DW	0341H		;  600 BAUD
BD1200:	  DW	01A1H		; 1200 BAUD
BD2400:	  DW	00D0H		; 2400 BAUD
BD4800:	  DW	0068H		; 4800 BAUD
BD9600:	  DW	0034H		; 9600 BAUD
BD19200:  DW	001AH		;19200 BAUD
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	ESC,'J',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,'E',0,0,0,'$'
;	       (END OF NITMOD AND SETUP ROUTINES)
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	  END
;