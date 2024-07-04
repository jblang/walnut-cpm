; Overlay for the Altos 580 using the COMM 3 port.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Altos 580 to MEX.
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
;  05/01/85	Changed to run with the Altos 580. Also added 2400
;		and 9600 baud.			       - Jeff king
;
;  04/28/85	MEXified overlay                       - Chris Heuser
;  10/22/84     Used Ampro overlay and changed
;       	initmod addresses and other minor
;	        equates to work with the MAGIC
;	        computer PC-88.                        - Chris Heuser
;
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
; Change the following information to match your equipment
;
PORT:		EQU	1CH		;MODEM DATA IN PORT
MODCTL1		EQU	PORT+1		;MODEM CONTROL PORT
MODDATP:	EQU	PORT            ;MODEM DATA IN  COMM PORT 3 
CTC:		EQU	0DH		;ADDR. OF CTC PORT
MODRCVB:	EQU	1		;BIT TO TEST FOR RECEIVE
MODRCVR:	EQU	1		;VALUE WHEN READY
MODSNDB:	EQU	4		;BIT TO TEST FOR SEND
MODSNDR:	EQU	4		;VALUE WHEN READY
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
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=check for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'W'-40H	;^W = Send next character		127H
;
;
		DS	2		;				128H
IN$MODCTL1:	IN      MODCTL1 ! RET   ;in modem control port          12AH
		DS	7
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	12		;				156H
;
;
		DS	2		;Not used by MEX		160H
		DS	3		;				162H
DISCV:		JMP	ADISCV		;Hang up modem wih DSC		165H				165H
GOODBV:		JMP	AGOODBV		;exit routine			168H
INITMOD:	JMP	AINITMOD	;go to user written routine	16BH
NEWBVD:		JMP	ANEWBVD		;Change baudrate		16EH
; 
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3
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
SYSVER:		MVI	C,ILP		;				1A7H
		CALL	MEX
		DB	'Version for ALTOS 580 COMPUTER '
		DB	CR,LF,0
		RET
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SENDBRK:  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0F8H		;SEND A BREAK TONE
	  JMP	AGOODBV
;.....
;
;
; This routine sends a 500 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
ADISCV:	  MVI	A,5
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,68H		;TURN OFF DTR
	  OUT	MODCTL1
	  JMP	AGOODBV
	  RET
;
AGOODBV:  MVI	B,5		;WAIT 500 MS
	  CALL	JMP$TIMER	
	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0EAH		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCTL1
	  RET
;.....
;
;	
; Altos 580 initialization 
;
AINITMOD:  DI            ;no interupts during setup
	  MVI	A,5	;default transfer speed to 300 baud
	  STA	MSPEED 	;
	  MVI	A,04H	;write register 4 of SIO 
	  OUT	MODCTL1	;contol port
	  MVI	A,44H	;x16, 1 stop bit, no parity
	  OUT	MODCTL1	;	
	  MVI	A,03H	;write register 3 of SIO
	  OUT 	MODCTL1	;
	  MVI	A,0C1H	;rcv 8 bits/char, rcv enable
	  OUT	MODCTL1	;
	  MVI	A,05H	;write register 5 of SIO
	  OUT	MODCTL1	;
	  MVI	A,0EAH	;8 bits/char, tx enable, rts enable
	  OUT	MODCTL1	;
	  MVI	A,47H	;counter mode,contol word time constant follows
	  OUT	CTC	;CTC channel 1
	  MVI	A,68h	;
	  OUT	CTC	;CTC channel 1
	  EI            ;
          RET
;
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
	  DB	CR,LF,'Only 300, 1200, 2400 or 9600 on SET command',CR,LF,0
	  RET
;
CMDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'120','0'+80H
	  DW	OK1200
	  DB	'240','0'+80H
	  DW	OK2400
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
OK300:	  MVI	A,1
	  STA	MSPEED
	  CALL	STBAUD1			
	  MVI	A,34H		; Second byte value for CTC 
	  OUT	CTC
	  RET
;
OK1200:	  MVI	A,5
	  STA	MSPEED
	  CALL	SETBAUD
	  MVI	A,68h		; Second byte value for CTC
	  OUT	CTC
	  RET
;
OK2400:	  MVI	A,6
	  STA	MSPEED
	  CALL  SETBAUD
	  MVI	A,34H		; Second byte value for CTC
	  OUT 	CTC
	  RET
;
OK9600:	  MVI	A,8
	  STA	MSPEED
	  CALL SETBAUD
	  MVI	A,0DH
	  OUT	CTC
	  RET
;
; This routne Sets up first byte for CTC (Counter mode)
;
SETBAUD:  MVI	A,04H
	  OUT	MODCTL1
	  MVI	A,44H
	  OUT	MODCTL1
	  MVI	A,47H		; Counter mode of CTC
	  OUT	CTC
	  RET
;
; This routine sets up first byte for CTC (Timer mode)
STBAUD1:  MVI	A,04H
	  OUT	MODCTL1
	  MVI   A,44H
	  OUT   MODCTL1
	  MVI	A,07H		; Timer mode of CTC
	  OUT	CTC
	  RET
;
ANEWBVD:   CPI	1
	  JZ	OK300
	  CPI	5
	  JZ	OK1200
	  CPI	6
	  JZ	OK2400
	  CPI	8
	  JZ	OK9600
	  RET
;
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	27,74,0,0,'$'		  	;KTM2 Clear EOS
CLSMSG:	  DB	27,69,0,0,'$'			;KTM2 Clear Screen
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	  END
;
