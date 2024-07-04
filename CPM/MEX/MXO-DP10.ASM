
; MXO-DP10.ASM -- Datapoint 1560 overlay file for MEX10.  05/24/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Datapoint 1560 computer to the modem program.
; Much of the information contained here is not in the main file.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the MEX "SET" command to change the baudrate when desired.  It
; starts out at 300 baud when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 05/24/84 - MEXified the overlay		- Biff Bueffel
; 11/11/83 - Renamed to M7DP-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/25/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 02/27/83 - Updated to work with MDM705	- Irv Hoff
; 02/17/83 - Modified MDM703CF for Datapoint
;	     1560 computers using an exter-
;	     nal modem				- Irv Hoff
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
PORT:		EQU	028H		;Datapoint 1560 Modem Data Port
MODCTL1:	EQU	PORT+1		;Modem status port
MODCTL2:	EQU	PORT+1		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;

		DB	NO	;					103H
		DB	NO	;					104H
TONEPULSE:	DB	'T'	;T=tone, P=Pulse (Smartmodem-only)	105H
CLOCK:		DB	37	;clock speed in MHz x10, 25.5 MHz max.	106H
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
ACKNAK:		DB	YES	;yes=resend a record after a non-ACK	10DH
				;no=resend a record only after NAK
BAKKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	NO	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	19H
XOFFTST:	DB	NO	;yes=chcks for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR		DB	'@'-40H	;Send a 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from phone line	121H
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
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	31
;
		DS	2		;Not used by MEX		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	JMP	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;				17AH
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
;
SYSVER:		MVI	C,ILP
		CALL	MEX
		DB	'Version for Datapoint 1560 modem port 28H'	
		DB	CR,LF,0
		RET
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,1FH
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI	A,15H		;SEND BREAK, TURN OFF DTR
;
GOODBYE1: OUT	MODCTL1		;SEND TO STATUS PORT
	  MVI	B,3		;DELAY ABOUT 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,07H		;NORMAL SEND/RECEIVE WITH DTR
	  OUT	MODCTL1		;SEND TO STATUS PORT
	  RET
;
;
; Datapoint 1560 initialization -- sets CTC timers 20H and 1AH for
; baudrate in/out.
;
INITMOD:  MVI	A,1		;DEFAULT TRANSFER TIME TO 300 BAUD
	  STA	MSPEED
	  MVI	A,47H
	  OUT	20H
	  OUT	1AH
;
INITMOD1: MVI	A,20H		;DEFAULT TO 300 BAUD
	  OUT	20H
	  OUT	1AH
	  RET
;.....
;
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
OK300:	  MVI	A,1		;MSPEED 300 BAUD VALUE
	  LHLD	BD300		;GET 300 BAUD PARAMETERS IN 'HL'
	  JMP	LOADBD		;GO LOAD THEM
;
OK450:	  MVI	A,2
	  LHLD	BD450
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
;
LOADBD:	  STA	INITMOD+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,L		;GET BAUDRATE BYTE
	  STA	INITMOD1+1	;STORE IN INITMOD
	  JMP	INITMOD		;REINITIALIZE TO NEW BAUDRATE, THEN DONE
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
BD300:	  DW	0020H		;9600/300  CONVERTED TO HEX VALUE
BD450:	  DW	0015H		;9600/450  CONVERTED TO HEX VALUE
BD1200:	  DW	0008H		;9600/1200 CONVERTED TO HEX VALUE
BD9600:	  DW	0001H		;9600/9600 CONVERTED TO HEX VALUE	
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	ESC,'y',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,':',0,0,0,'$'
;	       (END OF INITMOD AND SETUP ROUTINES)
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	  END
;
