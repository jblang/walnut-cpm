; MXO-EP12.ASM -- Epson QX-10 overlay file for MEX11.  08/25/84
;
; Changed call locations in sysver for 1.1    -- jw 08/25/84
;
; Update to add 8/7 bit, even/no parity option to baud rate setting.
; Initial screen change.                      -- jw 07/11/84
;
; This is essentially Biff Bueffel's MEX overlay which I have modified
; to correct a few minor bugs, add more allowable baud rates to the
; SET command for null-modem transfers, and change a few initialization
; parameters and comments to reflect the requirements of some local
; BBS's.  You may notice some old carry-overs from the MDM7xx series
; overlays, however, these carry-overs will simply be ignored by MEX.
;
; Updated / Upgraded 06/07/84  -- J. L. Bewley  (Rev. JLB-1)
; Mile High Epson User's Group -- Denver, Colo.
; Updated to incorporate MEXNEWS.001,001,003  06/13/84  (Rev. JLB-2)
;
;
; This overlay is used to adapt the MEX10.COM program to the Epson
; QX-10 computer using an external Hayes Smartmodem (tm) or compatible
; modem attached to the QX-10's serial port.  It will NOT work with 
; the internal Comrex Communicator modems.
;
; For this overlay to work properly, the DIP switches behind
; the front panel on the Hayes should be set as follows:
;
; Switch:
;   #1   #2   #3   #4   #5   #6   #7   #8
;   UP   UP   DN   UP   DN   UP   DN   DN
;
; It is especially important that Switch #1 be set UP to enable
; disconnect by DTR.  In general, these switch settings are
; compatible with Valdocs usage.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the QX-10 computer to the modem program.  
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.
; Also, this revision has been set to start out in the CHECKSUM mode
; to be compatible with TBBS, some RBBS, and other older BBS software
; which does not support the CRC mode.  If you desire the CRC mode
; default, simply change the CRCDFLT to TRUE below and reassemble,
; or, within MEX, use the STAT command to set CRC ON and CLONE your
; copy of MEX.  Use SET to change baud rate and CLONE for new start up.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 07/11/84 - Changed SET routine, initial scrn  - Jim Wright
; 06/13/84 - Customized Biff Bueffel's overlay  - Jim Bewley
; 05/24/84 - MEXified the overlay		- Biff Bueffel
; 11/11/83 - Renamed to M7EP-1.ASM, no changes	- Irv Hoff
; 08/27/83 - Revised to work with MDM712	- Irv Hoff
; 07/25/83 - Changed M710XE.ASM forEpson QX-10	- Phil Becker
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
BR7A:		EQU	7AH		;Baud rate divisors
BR7B:		EQU	7BH
BR4E:		EQU	4EH
BR4F:		EQU	4FH
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
PORT:		EQU	11H		;Epson QX-10 serial output port
MODCTL1:	EQU	PORT+2		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+2		;Modem control port
MODRCVB:	EQU	01H		;Your bit to test for receive
MODRCVR:	EQU	01H		;Your value when receive ready
MODSNDB:	EQU	04H		;Your bit to test for send
MODSNDR:	EQU	04H		;Your value when send ready		
;
;
		ORG	100H
;
;
; Change the clock speed as needed for your system.
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	1	;0=0 delay  1=10ms  5=50ms - 9=90ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	1	;0=0 delay 1=100ms 5=500ms - 9=900ms	109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	NO	;no=default to CHECKSUM checking	10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;not supported by MEX			115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=allow toggling of printer on/off	119H
XOFFTST:	DB	YES	;yes=chcks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'D'-40H	;^D = Send a 300 ms. break tone		120H
NOCXNNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'O'-40H	;^O = Send Log-On Message		122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'F'-40H	;^F = Send Next Character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	MVI	A,10H		;channel 0, reset interrupts.	12AH
		OUT	MODCTL1
		IN	MODCTL1		;get the status bits
		RET
		DS	3
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6
;
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port		15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem status port		15DH
;
;
LOGONPTR:	DW	LOGON		;for MDM7xx Log-On Message	160H
		DS	6		;				162H
JMP$GOODBYE:	RET			;MEX patch to prevent DSC 	168H
		DS	2		;from BYE command.  See note
					;in MEXNEWS.001  (JLB)
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
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
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	017H,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	01AH,0,0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	CLRSCRN		;
		CALL	JMP$ILPRT	;
		DB	ESC,3DH,28H,3DH
		DB	'  M',ESC,29h,'odem ',ESC,28h,'EX',ESC,29h,'ecutive  '
		DB	ESC,3DH,2AH,3DH,'Epson QX-10 Ver 1.11'
		DB	ESC,3DH,2CH,3DH,'  Clone Level - ',0
		CALL	46ECH		;43E9H	ver1.0
		CALL	JMP$ILPRT
	 	DB	CR,LF,ESC,3DH,2DH,3CH,'Rate = ',0
	  	CALL	SETUPD
	  	CALL	JMP$ILPRT
		DB	ESC,3DH,2EH,3DH,' HELP or ? for aid '
		DB	ESC,3DH,2FH,3DH,'(c) 1984 Ron Fowler'
		DB	ESC,28H
		DB	ESC,3DH,32H,3FH,0
		RET
;.....
;
;-----------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTRL-O  (^-O) if TRANLOGON has been set TRUE.  You can put in several
; lines if desired.  End with a 0.
; Note:  Only works with MDM7xx -- Not MEX
;
LOGON:		DB	'This is an Epson QX-10 Computer',CR,LF,0
;
;------------------------------------------------------------
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,5
	  OUT	MODCTL1
          MVI	A,0FAH	; Send a BREAK TONE
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:  MVI	A,5
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,07AH		;TURN OFF DTR, SEND BREAK
;
GOODBYE1: OUT	MODCTL1
	  MVI	B,3		;DELAY 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0EAH		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCTL1
	  RET
;.....
;
;
; Epson QX-10 initialization -- sets CTC timer 00H for send and receive
; baudrate.
;
;
INITMOD:  
	  MVI	A,5
	  STA	MSPEED
	  MVI	A,0B6H
	  OUT	7
	  MVI	A,068H
	  OUT	6
	  MVI	A,000H
	  OUT	6
	  CALL	SETUP7201
INITMOD1: MVI	A,BR4E
	  RET	  
;.....
;
;
SETUPR:	  CALL	JMP$ILPRT
	  DB	CR,LF,'Baud Rate = ',0
	  CALL	SETUPD
	  CALL	JMP$ILPRT
	  DB	CR,LF,LF,0           	                        
	  CALL	JMP$ILPRT
	  DB	CR,'Input New Baud Rate (1=300, 2=1200): ',0
  	  MVI	C,1
	  CALL	5
	  CPI	31H
	  JZ	OK3		
	  CPI	32H
	  JZ	OK12
	  CPI	0DH
	  RZ	
	  JMP	SETUPR		;TRY AGAIN
;
OK3:	  MVI	A,1		;SET UP SPEED COMMAND
	  STA	MSPEED		;STORE SPEED
	  MVI	A,0B6H
	  OUT	7
	  MVI	A,0A0H
	  OUT	6
	  MVI	A,1
	  OUT	6
	  JMP	SETUPF		;GO TO FORMAT SETUP
;
OK12:	  MVI	A,5		;SET UP SPEED COMMAND
	  STA	MSPEED		;STORE SPEED
	  MVI	A,0B6H
	  OUT	7
	  MVI	A,068H
	  OUT	6
	  MVI	A,0
	  OUT	6
;
SETUPF:
	  CALL	JMP$ILPRT
	  DB	CR,LF
	  DB	'Input Format (1=8N1, 2=7E1): ',0
	  MVI	C,1
	  CALL	5
	  CPI	31H
	  JZ	OK8N1		
	  CPI	32H
	  JZ	OK7E1
	  JMP	SETUPF		;TRY AGAIN
;
OK7E1:	  MVI	A,3
	  STA	PARITYBITS
	  MVI	A,040H
	  STA	DATABITS
	  LDA	MSPEED
	  CPI	5
	  JZ	OK7E1H
	  MVI	A,BR7B
	  JMP	SETUPDN
OK7E1H:	  MVI	A,BR7A
	  JMP	SETUPDN
;
OK8N1:	  MVI	A,0
	  STA	PARITYBITS
	  MVI	A,0C0H
	  STA	DATABITS
	  LDA	MSPEED
	  CPI	5
	  JZ	OK8N1H
	  MVI	A,BR4F
	  JMP	SETUPDN
OK8N1H:	  MVI	A,BR4E 
;
SETUPDN:  STA	INITMOD1+1
SETUP7201:
	  MVI	A,4
	  OUT	013H
	  LDA	PARITYBITS
	  MOV	B,A
	  LDA	STOPBITS
	  ORA	B
	  MOV	B,A
	  MVI	A,040H
	  ORA	B
	  OUT	013H
	  MVI	A,3
	  OUT	013H
	  LDA	DATABITS
	  ORI	1
	  OUT	013H
	  MVI	A,5
	  OUT	013H
	  LDA	DATABITS
	  RRC
	  ORI	08AH
	  OUT	013H
	  RET
;
;
PARITYBITS:	DB	0
STOPBITS:	DB	4
DATABITS:	DB	0C0H
;
;
SETUPD:	  LDA	INITMOD1+1
	  CPI	BR7A
	  JNZ	OK7B
	  CALL	JMP$ILPRT
	  DB	'1200 Baud - 7E1',0
	  RET
OK7B:	  CPI	BR7B
	  JNZ	OK4E
	  CALL	JMP$ILPRT
	  DB	'300 Baud - 7E1',0
	  RET
OK4E:	  CPI	BR4E
	  JNZ	OK4F
	  CALL	JMP$ILPRT
	  DB	'1200 Baud - 8N1',0
	  RET
OK4F:	  CALL	JMP$ILPRT
	  DB	'300 Baud - 8N1',0
	  RET
;
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;
; The following routine can be used as an auxiliary menu for notes of
; interest to a particular computer, etc.  If using the Hayes Smartmodem
; this is unavailable without a spcial address change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:  Must Terminate Prior to 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	  END
;

