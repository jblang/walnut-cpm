; MXO-AL10.ASM -- ALTOS SERIES 5 overlay file for MEX10.   05/26/84	
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the ALTOS SERIES 5 computers to MEX10.
;
; This uses the CPMSETUP.COM file that came with your ALTOS SERIES 5.
;
; First run CPMSETUP and set the printer (serial) for 300 baud.  This
; will write the boot track data so every time you boot that disk your
; serial port is set for 300 baud.  Do the same for 1200 baud mode and
; boot as needed.  Use port labled J9 (far right) on the back of the
; Altos (DP25).  Remember the J9 port is wired as a modem port so you
; will need to rewire the modem cable to the correct pins (data out to
; data receive, pins 2 and 3 and CTS -- clear to send,	etc...).
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 05/26/84 - MEXified the overlay.		- Biff Bueffel
; 11/11/84 - Renamed to M7AL-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/17/83 - Revised to work with MDM711	- Irv Hoff
; 07/02/83 - Modified MDM710XE for ALTOS
;	     SERIES 5 computers with external
;	     modem				- Jeff King
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
PORT:		EQU	1EH		;ALTOS SERIES 5 serial output port
MODCTL1:	EQU	PORT+1		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+1		;Modem status port
MODRCVB:	EQU	01H		;Your bit to test for receive
MODRCVR:	EQU	01H		;Your value when receive ready
MODSNDB:	EQU	04H		;Your bit to test for send
MODSNDR:	EQU	04H		;Your value when send ready		
;
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
TOUCHPULSE:	DB	'T'     ;T=touch, P=pulse (Smartmodem-only)     105H
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
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	NO	;cursor control routine 		10CH
ACKNAK: 	DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
		DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP: 	DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST: 	DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=check for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1: 	DB	0	;for future expansion			11EH
EXTRA2: 	DB	0	;for future expansion			11FH
BRKCHR: 	DB	'@'-40H ;^@ = Send a 300 ms. break tone         120H
20H
NOCONNCT:	DB	'N'-40H ;^N = Disconnect from the phone line    121H
LOGCHR: 	DB	'L'-40H ;^L = Send logon                        122H
LSTCHR: 	DB	'P'-40H ;^P = Toggle printer                    123H
UNSAVE: 	DB	'R'-40H ;^R = Close input text buffer           124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote           125H
SAVECHR:	DB	'Y'-40H ;^Y = Open input text buffer            126H
EXTCHR: 	DB	'^'-40H ;^^ = Send next character               127H
;
;
		DS	2		;				128H
IN$MODCTL1:	MVI	A,10H		;channel 0, reset interrupts	12AH
		OUT	MODCTL1
		IN	MODCTL1 	;get the status bits
		RET
		DS	3
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	151H
		DS	6		;				154H
OUT$MODCTL1:	OUT	MODCTL1 ! RET	;out modem control port 	15AH
OUT$MODCTL2:	OUT	MODCTL2 ! RET	;out modem status port		15DH
;
;
		DS	2		;Not used by MEX.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE 	;				168H
JMP$INITMOD:	JMP	INITMOD 	;go to user written routine	16BH
JMP$NEWBAUD:	JMP  	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;Not used by MEX		17AH
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
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  
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
		DB	'Version for ALTOS SERIES 5 at serial port 1E'
		DB	CR,LF,0
		RET
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SENDBRK:  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0F8H		;SEND A BREAK TONE
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBYE:  MVI	A,5
	  OUT	MODCTL1 	;SEND TO THE STATUS PORT
	  MVI	A,068H		;TURN OFF DRT
;
GOODBYE1: OUT	MODCTL1
	  MVI	B,3		;WAIT FOR 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0E8H		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCTL1
	  RET
;.....
;
;	
; Altos series 5 initialization -- sets CTC timer 00H for send and receive
; baudrate.
;
INITMOD:  MVI	A,0		;SELECT REGISTER
	  OUT	MODCTL1
	  MVI	A,18H		;THROW OUT OF MODE
	  OUT	MODCTL1
	  MVI	A,04H		;SELECT REGISTER
	  OUT	MODCTL1
	  MVI	A,44H		;SET ASCII PARAMETERS
	  OUT	MODCTL1
	  MVI	A,03H		;SELECT REG.
	  OUT	MODCTL1
	  MVI	A,0C1H		;ENABLE RECEIVE
	  OUT	MODCTL1
	  MVI	A,05H		;SELECT REG.
	  OUT	MODCTL1
	  MVI	A,0EAH		;ENABLE SEND, 'DTR', 'RTS'
	  OUT	MODCTL1
;
INITMOD1: MVI	A,1		;DEFAULT TRANSFER TIME TO 300 BAUD
	  STA	MSPEED
	  MVI	A,47H		;DEFAULT TO 300 BAUD
	  OUT	00H		;SEND TO 'CTC' TIMER
;
INITMOD2: MVI	A,05H		;INITIALIZE TO 300 BAUD
	  OUT	00H
	  RET
;.....
;
;
; Setup routine to allow changing modem speed with the SET command.
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
	  DB	CR,LF,'Only 300 or 1200 allowed on SET command',CR,LF,0
	  RET
;
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'120','0'+80H
	  DW	OK1200
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
OK300:	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD
;
OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:   MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK9600:   MVI	A,8
	  LHLD	BD9600
;
LOADBD:   STA	INITMOD1+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,L		;GET BAUDRATE BYTE
	  STA	INITMOD2+1	;SEND TO 'CTC' TIMER FOR NEW BAUDRATE
	  JMP	INITMOD1	;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	5
	  JZ	OK1200
	  RET
;
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300:	  DW	0005H
BD600:	  DW	0006H	
BD1200:   DW	0007H
BD9600:   DW	000EH
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	0,0,0,0,'$'		  	
CLSMSG:	  DB	0,0,0,0,'$'
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	  END
;



