; MXO-TV11.ASM -- TeleVideo TS-802 overlay file for MEX10.  07/18/84
;
REV	EQU	11		; overlay revision level
;
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; This overlay uses the modem port (20H) on the TeleVideo TS-802 
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 07/18/84 - Changed labels to conform to MXO-PM10 model
;	     changed baud rate to default to mspeed 
;	     rewrote and enhanced set baud routines       - Bob Puckett
; 05/24/84 - MEXified overlay			- Biff Bueffel
; 11/11/83 - Renamed to M7TV-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM711	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM711	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/27/83 - Revised to work with TV802		- Irv Hoff
; 02/17/83 - Modified MDM703CF for Datapoint
;	     1560 computers using an external
;	     modem				- Irv Hoff
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
PORT:		EQU	20H		;TeleVideo ST-802 data port
;
BAUDRP:		EQU	08H		;CTC port for baud rate
CPORT:	EQU	PORT+2		;Modem control port
MODCTL2:	EQU	PORT+2		;Modem control port
DPORT:	EQU	PORT		;Modem data port
MODDCDB:	EQU	4		;carrier detect bit
MODDCDA:	EQU	0		;value when active
DAV:	EQU	1		;bit to test for receive ready
DAV:	EQU	1		;value when ready
TBMT:	EQU	4		;bit to test for send ready
TBMT:	EQU	4		;value when ready
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'P'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
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
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	NO	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	YES	;yes=check for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONNCT:	DB	'L'-40H	;^L = Disconnect from the phone line	121H
LOGCHR:		DB	'N'-40H	;^N = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
INCTL1:		IN	CPORT ! RET	;in modem control port		12AH
		DS	7
OTDATA:		OUT	DPORT ! RET	;out modem data port		134H
		DS	7
INPORT:		IN	DPORT ! RET	;in modem data port		13EH
		DS	7
;
MASKR:		ANI	DAV	! RET	;bit to test for receive ready	148H
TESTR:		CPI	DAV	! RET	;value of rec. bit when ready	14BH
MASKS:		ANI	TBMT	! RET	;bit to test for send ready	14EH	
TESTS:		CPI	TBMT	! RET	;value of send bit when ready	151H
		DS	6		;				154H
OTCTL1:		OUT	CPORT	! RET	;out modem control port #2	15AH
;
		DS	5		;Not used by MEX 		160H
		DS	6
GOODBV:		JMP	GOODBYE		;				168H
INMODV:		JMP	NITMOD		;go to user written routine	16BH
NEWBDV:		JMP	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
SETUPV:		JMP	SETUPR		;				177H
		DS	3		;Not used by MEX		17AH
VERSNV:		JMP	SYSVER		;				17DH
BREAKV:		JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines
;
ILPRTV:		DS	3		;				183H
INBUFV:		DS	3		;				186H
ILCMPV:		DS	3		;				189H
INMDMV:		DS	3		;				18CH
		DS	3		;				18FH
TIMERV:		DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  
;
CLREOSº		LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLRSCRN:	LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
;
SYSVER:		MVI	C,ILP		;				1A7H
		CALL 	MEX
		DB	'TeleVideo TS-802 Overlay V. '
		DB	REV/10 + '0'
		DB	'.'
		DB	REV MOD 10 + '0'
		DB	CR,LF,0
		RET
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,5
	  OUT	CPORT
	  MVI	A,0F8H		;SEND A BREAK TONE
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBYE:  MVI	A,5
	  OUT	CPORT		;SEND TO THE STATUS PORT
	  MVI	A,068H		;TURN OFF DTR, SEND BREAK
;
GOODBYE1: OUT	CPORT	
	  MVI	B,3		;WAIT 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,5
	  OUT	CPORT
	  MVI	A,0E8H		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	CPORT
	  RET
;.....
;
;
; TeleVideo TS-802 baud rate change.  Sets CTC at port 08H for baudrate
; in/out.
;
;
NITMOD:   MVI	A,0		;SELECT REG.
	  OUT	CPORT		;SEND TO THE STATUS PORT
	  MVI	A,18H		;RESET THE Z8SIO CHIP
	  OUT	CPORT		;SEND TO THE STATUS PORT
	  MVI	A,4		;SELECT REG.
	  OUT	CPORT		;SEND TO THE STATUS PORT
	  MVI	A,44H		;16X, 1-STOP, NO PARITY
	  OUT	CPORT		;SEND TO THE STATUS PORT
	  MVI	A,3		;SELECT REG.
	  OUT	CPORT		;SEND TO THE STATUS PORT
	  MVI	A,0C1H		;ENABLE RECEIVE SECTION
	  OUT	CPORT		;SEND TO THE STATUS PORT
	  MVI	A,5		;SELECT REG.
	  OUT	CPORT		;SEND TO THE STATUS PORT
	  MVI	A,0EAH		;DTR, RTS, 8-BITS, ENABLE SEND SECTION
	  OUT	CPORT		;SEND TO THE STATUS PORT
;
	  LDA	MSPEED		;DEFAULT TRANSFER TIME MSPEED
	  CALL	NEWBAUD		;GO CHANGE BAUD RATE
	  RET
;
;.......
;
;
SETUPR:	  MVI	C,SBLANK	;Any arguments?
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
	  DB	CR,LF
          DB   'Only 300, 450, 600, 1200, 2400, 4800, 9600 or 19200'
	  DB   ' allowed on SET command'
          DB   CR,LF,'Example: SET 1200',CR,LF,0
	  RET
;
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'45','0'+80H
	  DW	OK450
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
	  DB	'1920','0'+80H
	  DW	OK19K
	  DB	0
;
OK300:	MVI	A,1
	JMP	NEWBAUD
OK450:	MVI	A,2
	JMP	NEWBAUD
OK600:	MVI	A,3
	JMP	NEWBAUD
OK1200:	MVI	A,5
	JMP	NEWBAUD
OK2400:	MVI	A,6
	JMP	NEWBAUD
OK4800:	MVI	A,7
	JMP	NEWBAUD
OK9600:	MVI	A,8
	JMP	NEWBAUD
OK19K:	MVI	A,9
	JMP	NEWBAUD

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
;
;
;
NEWBAUD:
	STA	MSPEED		; SAVE MSPEED
	LXI	H,BAUDTB
	MOV	E,A
	MVI	D,0		; DE HAS OFFSET
	DAD	D		; HL POINTS TO CORRECT BAUD RATE
	MOV	C,M		; GET DIVISOR IN C

LOADBD:	MVI	A,047H		;SET UP FOR BAUD CHANGE
	OUT	BAUDRP
	MOV	A,C		;GET DIVISOR
	OUT	BAUDRP
	RET

;
;
; TABLE OF BAUDRATE PARAMETERS
; NOTE: 110 AND 710 BAUD ARE UNIMPLEMENTED
;
BAUDTB:
BD110:    DB   0                ; -0
BD300:	  DB	0080H		; -1    38400/300  CONVERTED TO HEX VALUE
BD450:	  DB	0055H		; -2    38400/450  CONVERTED TO HEX VALUE
BD600:	  DB	0040H		; -3    38400/600  CONVERTED TO HEX VALUE
BD710:    DB   0                ; -4
BD1200:	  DB	0020H		; -5    38400/1200 CONVERTED TO HEX VALUE
BD2400:   DB    0010H           ; -6
BD4800:   DB    0008H           ; -7
BD9600:	  DB	0004H		; -8    38400/9600 CONVERTED TO HEX VALUE	
BD19K:	  DB	0002H		; -9    38400/19200
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	ESC,'y',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,'*',0,0,0,'$'
;	       (END OF INITMOD AND SETUP ROUTINES)
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)	
;
	  END
;
