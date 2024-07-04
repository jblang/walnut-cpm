; MXO-LB3.ASM- AMPRO "Little Board" overlay for MEX10.	   04/04/85
;
TITLE	'MXO-LB3R.ASM Customized Ampro MEX overlay'
PAGE	45
;
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the AMPRO "Little Board" computer to the modem program.  
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 08/23/85 - Changed incorrect Jump to
;	     GOODBYE routine so modem won't
;	     disconnect on CPM,EXIT,or SYSTEM	 - Rick Swenton
; 08/17/85 - Added code to support 450 baud	 - Rick Swenton
; 04/04/84 - Added DISCV to allow modem disconnect on ESC N
;	     (present GOODBY routine is only called when exiting
;	     MEX to CPM)			 -Norman Beeler 	
; 03/29/85 - Added 2400 and 4800 baud capability -Norman Beeler
; 09/14/84 - Adapt for AMPRO "Little Board"	- Charlie Sanborn
; 05/28/84 - MEXify labels			- Biff Bueffel
; 05/23/84 - Corrected clear-screen problem	- Biff Bueffel	
; 05/22/84 - Rewritten for MEX10		- Biff Bueffel
; 11/11/83 - Renamed to M7KP-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/25/83 - Revised to work with MDM709	- Irv Hoff
; 04/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 02/27/83 - Updated to work with MDM705	- Irv Hoff
; 02/17/83 - Modified MDM703CF for Kaypro II
;	     computers with external modems	- Irv Hoff
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
PORT:		EQU	88H		;Ampro "B" serial output port
MODCT1: 	EQU	PORT+4		;Modem control port
MODDAT: 	EQU	PORT		;Modem data port
MODCT2: 	EQU	PORT+4		;Modem control port
MDRCVB: 	EQU	01H		;Your bit to test for receive
MDRCVR: 	EQU	01H		;Your value when receive ready
MDSNDB: 	EQU	04H		;Your bit to test for send
MDSNDR: 	EQU	04H		;Your value when send ready		
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
		ORG	100H
;
;
; Change the clock speed as needed for your system.
;
		DS	3	;(for  "JMP   START" instruction)
;
PMODEM: 	DB	NO	;yes=PMMI S-100 Modem			103H
SMODEM: 	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TPULSE: 	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED: 	DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY: 	DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS: 	DB	5	;number of DIR columns shown		10AH
SETFLG: 	DB	YES	;yes=user-added Setup routine		10BH
SCRTST: 	DB	YES	;Cursor control routine 		10CH
		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKFLG: 	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFL: 	DB	YES	;yes=default to CRC checking		10FH
TOGCRC: 	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK: 	DB	YES	;yes=allow toggling of bksp to rub	112H
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
XOFTST: 	DB	NO	;yes=chcks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF: 	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL: 	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1: 	DB	0	;for future expansion			11EH
EXITCHR:		DB	'E'-40H ;^E = Exit to main menu 		11FH
BRKCHR: 	DB	'@'-40H ;^@ = Send a 300 ms. break tone 	120H
NOCONN: 	DB	'N'-40H ;^N = Disconnect from the phone line	121H
LOGCHR: 	DB	'L'-40H ;^L = Send logon			122H
LSTCHR: 	DB	'P'-40H ;^P = Toggle printer			123H
UNSAVE: 	DB	'R'-40H ;^R = Close input text buffer		124H
TRNCHR: 	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR: 	DB	'Y'-40H ;^Y = Open input text buffer		126H
EXTCHR: 	DB	'^'-40H ;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
INCTL1: 	MVI	A,10H		;channel 0, reset interrupts.	12AH
		OUT	MODCT1
		IN	MODCT1		;get the status bits
		RET
		DS	3
;
OTDATA: 	OUT	MODDAT ! RET	;out modem data port		134H
		DS	7
INPORT: 	IN	MODDAT ! RET	;in modem data port		13EH
		DS	7
MASKR:		ANI	MDRCVB	! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of receive bit when rdy	14BH
MASKS:		ANI	MDSNDB	! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR	! RET	;value of send bit when ready	151H
		DS	6
;
OUTCTL1:	OUT	MODCT1	! RET	;out modem control port 	15AH
OUTCTL2:	OUT	MODCT2	! RET	;out modem status port		15DH
;
;
		DS	2		;				160H
		DS	3		;				162H
DISCV:		JMP	GOODBY		;disconnect on ^N
GOODBV: 	RET  !	NOP  !	NOP	;return to CP/M 		168H
INMODV: 	JMP	NITMOD		;go to user written routine	16BH
NEWBDV: 	JMP	NEWBAUD 	;Set new baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
SETUPV: 	JMP	SETCMD		;				177H
		DS	3		;				17AH
VERSNV: 	JMP	SYSVER		;				17DH
BREAKV: 	JMP	SBREAK		;				180H
;
;
; Do not change the following six lines.
;
ILPRTV: 	DS	3		;				183H
INBUFV: 	DS	3		;				186H
ILCMPV: 	DS	3		;				189H
INMDMV: 	DS	3		;				18CH
		DS	3		;				18FH
TIMERV: 	DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS: 	LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLS:	LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
;
SYSVER: 	MVI	C,ILP		;				
		CALL	MEX
		DB	CR,LF
		DB	'Version for AMPRO using Z80 DART on port 088H',CR,LF
		DB	'Overlay Version 2   08/23/85  by Rick Swenton',CR,LF
		DB	CR,LF,LF,LF,0
		RET
;
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SBREAK:  MVI	A,5
	  OUT	MODCT1
	  MVI	A,7AH			 ;SEND A BREAK TONE		 
	  JMP	GOODBY1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBY:  MVI	A,5
	  OUT	MODCT1		;SEND TO THE STATUS PORT
	  MVI	A,78H		;TURN OFF RTS
;
GOODBY1: OUT	MODCT1
	  MVI	B,3		;DELAY 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,5
	  OUT	MODCT1
	  MVI	A,6AH	       ;RESTORE TO NORMAL, 8 BITS, RTS ON, ETC.
	  OUT	MODCT1
	  RET
;.....
;
;
; AMPRO initialization -- set up Z80-DART & CTC Channel 01 (clock source)
;
;
NITMOD:   MVI	A,00H		;SELECT REG.
	  OUT	MODCT1
	  MVI	A,18H		;THROW OUT OF MODE
	  OUT	MODCT1
	  MVI	A,04H		;SELECT REG.
	  OUT	MODCT1
	  MVI	A,44H		;SET ASCII PARAMETERS
	  OUT	MODCT1
	  MVI	A,03H		;SELECT REG.
	  OUT	MODCT1
	  MVI	A,0C1H		;ENABLE RECEIVE
	  OUT	MODCT1
	  MVI	A,05H		;SELECT REG.
	  OUT	MODCT1
	  MVI	A,6AH	       ;ENABLE SEND, DTR, RTS
	  OUT	MODCT1
;
NITMOD1:  MVI	A,5		;SET FILE TRANSFER TIME
	  STA	MSPEED
	  MVI	A,47H
	  OUT	50H		;SEND TO 'CTC' TIMER

NITMOD2:  MVI	A,68H		;INITIALIZE TO 1200 BAUD
	  OUT	50H		;SEND TO 'CTC' TIMER
	  RET
;.....
;
;
; Sets the modem speed via the SET command.
;
;
SETCMD:   MVI	C,SBLANK	;Any arguments?
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
	  DB	CR,LF,'Only 300, 450, 600, 1200, 2400, 4800 or 9600 allowed with SET'
	  DB	CR,LF,0
	  RET
;
CMDTBL:   DB	'30','0'+80H
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
	  DB	0
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
OK300	  MVI	A,84H		;Load DART Reg 4 with x32
	  STA	NITMOD+13
	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD
;
OK450	  MVI	A,84H		;Load DART Reg 4 with x32  
	  STA	NITMOD+13
	  MVI	A,2
	  LHLD	BD450
	  JMP	LOADBD
;
OK600	  MVI	A,44H		;Load DART Reg 4 with x16
	  STA	NITMOD+13
	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200	  MVI	A,44H		;Same as for 600
	  STA	NITMOD+13
	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400	  MVI	A,44H
	  STA	NITMOD+13
	  LHLD	BD2400
	  JMP	LOADBD
;
OK4800	  MVI	A,44H
	  STA	NITMOD+13
	  LHLD	BD4800
	  JMP	LOADBD	
;
OK9600	  MVI	A,44H		;As above
	  STA	NITMOD+13
	  MVI	A,8
	  LHLD	BD9600
;
LOADBD:   STA	NITMOD1+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,L		;GET BAUDRATE BYTE
	  STA	NITMOD2+1	;SEND TO 'CTC' FOR NEW BAUDRATE
	  JMP	NITMOD		;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
;
NEWBAUD:  CPI	1
	  JZ	OK300	       
	  CPI	2
	  JZ	OK450
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
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300:	  DW	00D0H		;62400/300    (x32)
BD450:	  DW	008AH		;62400/450    (x32)
BD600:	  DW	00D0H		;62400/600    (x32)
BD1200:   DW	0068H		;124800/1200  (x16)
BD2400	  DW	0034H		;124800/2400  (x16)
BD4800	  DW	001AH		;124800/4800  (x16)
BD9600:   DW	000DH		;124800/9600  (x16)
;
BAUDBUF:  DB	10,0
	  DS	10
;
; NOTE: The following two lines are terminal dependent, and are
; currently set for a VT-52. Change for your terminal.
;
EOSMSG:   DB	01BH,4AH,'$'		       
CLSMSG:   DB	01BH,48H,1BH,4AH,'$'
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00 (with Smartmodem)
;				 
;
	  END
;

-----------