; MXO-NA1.ASM -- North Star Advantage overlay for MEX - 84/11/26
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the MEX "SET" command to change the baudrate when desired.  Use
; "SET" to see the current baud rate and "SET xxxx" to set to xxxx.  It
; starts out at the value selected from the "DBDRTx" equates.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to overlay the the results
;		of this program to the original .COM file:
;
;		A>MLOAD MEX.COM=MEX112.COM,MXO-NA1.ASM
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/26/84 - MEXified overlay                   - Ian Cottrell
; 07/26/84 - Added default baud rate and slot # - Ian Cottrell
; 11/11/83 - Renamed to M7NA-1.ASM, no changes	- Irv Hoff
; 09/14/83 - Changed M712HZ.ASM TO M712AF.ASM	- Robert Lehman
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 02/17/83 - 1st version of M712HZ.ASM		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; MEX Service Processor
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
CONOUT	EQU	2		;simulated BDOS function 2: console char out
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
RON:		EQU	01H		;reverse video on
ROFF:		EQU	02H		;reverse video off
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
SLOT:		EQU	6		;slot used for modem port
PORT:		EQU	(6-SLOT)*16	;addr for selected slot
BAUDRP:		EQU	PORT+8          ;baud rate port for Advantage
MODDATP:	EQU	PORT		;data port for Advantage
MODCTL1:	EQU	PORT+1		;status port for Advantage
MODRCVB:	EQU	2		;bit to test for received data
MODRCVR:	EQU	2		;modem receive ready
MODSNDB:	EQU	1		;bit to test for ready to send
MODSNDR:	EQU	1		;modem send ready bit
;
					;110 baud not supported
DBDRT1:		EQU	NO		;default to 300 baud
					;450 baud not supported
DBDRT3:		EQU	NO		;default to 600 baud
					;710 baud not supported
DBDRT5:		EQU	NO		;default to 1200 baud
DBDRT6:		EQU	NO		;default to 2400 baud
DBDRT7:		EQU	YES		;default to 4800 baud
DBDRT8:		EQU	NO		;default to 9600 baud
DBDRT9:		EQU	NO		;default to 19,200 baud
;
		IF	DBDRT1
DEFBD:		EQU	40H		;baud rate register value for 300
DEFMSPD:	EQU	1		;MSPEED value for 300
		ENDIF			;DBDRT1
;
		IF	DBDRT3
DEFBD:		EQU	60H		;baud rate register value for 600
DEFMSPD:	EQU	3		;MSPEED value for 600
		ENDIF			;DBDRT3
;
		IF	DBDRT5
DEFBD:		EQU	70H		;baud rate register value for 1200
DEFMSPD:	EQU	5		;MSPEED value for 1200
		ENDIF			;DBDRT5
;
		IF	DBDRT6
DEFBD:		EQU	78H		;baud rate register value for 2400
DEFMSPD:	EQU	6		;MSPEED value for 2400
		ENDIF			;DBDRT6
;
		IF	DBDRT7
DEFBD:		EQU	7CH		;baud rate register value for 4800
DEFMSPD:	EQU	7		;MSPEED value for 4800
		ENDIF			;DBDRT7
;
		IF	DBDRT8
DEFBD:		EQU	7EH		;baud rate register value for 9600
DEFMSPD:	EQU	8		;MSPEED value for 9600
		ENDIF			;DBDRT8
;
		IF	DBDRT9
DEFBD:		EQU	7FH		;baud rate register value for 19,200
DEFMSPD:	EQU	9		;MSPEED value for 19,200
		ENDIF			;DBDRT9
;
SMODEM		EQU	YES		;if using Smartmodem
;
;
;
; The Advantage uses the 8251
;
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H

		IF	SMODEM
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-Hayes	104H
		ENDIF		;SMODEM

		IF	NOT SMODEM
SMARTMODEM:	DB	NO	;yes=Hayes Smartmodem, no=non-Hayes	104H
		ENDIF		;SMODEM

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
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
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
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH
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
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		125H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		126H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 	;in modem control port		12AH
		RET
		DS	7
OUT$MODDATP:	OUT	MODDATP 	;out modem data port		134H
		RET
		DS	7
IN$MODDATP:	IN	MODDATP 	;in modem data port		13EH
		RET
		DS	7
ANI$MODRCVB:	ANI	MODRCVB 	;bit to test for receive ready  148H
		RET
;
CPI$MODRCVR:	CPI	MODRCVR 	;value of rcv. bit when ready   14BH
		RET
;
ANI$MODSNDB:	ANI	MODSNDB 	;bit to test for send ready     14EH
		RET
;
CPI$MODSNDR:	CPI	MODSNDR 	;value of send bit when ready   151H
		RET
		DS	12
;
		DS	2		;not used by MEX		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	JMP	NEWBAUD		;change baud rate		16EH
		RET  			;(by-passes PMMI routine)	171H
		NOP
		NOP
		RET  			;(by-passes PMMI routine)	174H
		NOP
		NOP
JMP$SETUPR:	JMP	SETUPR		;				177H
		DS	3		;not used by MEX		17AH
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
CLREOS:		LXI	D,EOSMSG
		MVI     C,PRINT
		CALL	MEX
		RET
;
CLRSCRN:	LXI	D,CLSMSG
		JMP	CLREOS+3
;
;
SYSVER:		MVI	C,ILP
		CALL	MEX
		DB	'Version for North Star Advantage - Slot ',SLOT+30H
		DB	CR,LF
		IF SMODEM
		DB	'with Hayes Smartmodem'
		DB	CR,LF
		ENDIF
		DB	'Default Baud Rate:  '
		IF	DBDRT1
		DB	RON,'300',ROFF
		ENDIF
		IF	DBDRT3
		DB	RON,'600',ROFF
		ENDIF
		IF	DBDRT5
		DB	RON,'1200',ROFF
		ENDIF
		IF	DBDRT6
		DB	RON,'2400',ROFF
		ENDIF
		IF	DBDRT7
		DB	RON,'4800',ROFF
		ENDIF
		IF	DBDRT8
		DB	RON,'9600',ROFF
		ENDIF
		DB	' baud'
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
;	 or by address 0C00H (2659 bytes available) otherwise.
;
;-----------------------------------------------------------------------
; This routine allows a 300 ms. break tone to be send to reset some
; time-share computers.
;
SENDBRK:  MVI	A,08H		;send a break tone for 300 ms.
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212a, etc.
;
GOODBYE:  MVI	A,0AH		;set break, DTR low
;
GOODBYE1: OUT	MODCTL1		;put command register out of mode
	  IN	MODCTL1		;make sure it is now clear
	  IN	MODCTL1		;try once more
	  MVI	B,3		;delay for 300 ms.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,37H		;reset RTS, flags, DTR low, enable R/T
	  OUT	MODCTL1		;send to command register
	  IN	MODCTL1		;clear any incoming chars.
	  IN	MODCTL1		;try once more
	  XRA	A		;clear the 'A' reg.
	  RET
;.....
;
;
; The following are used in setting up the modem port.
; Since N/S Bios only initializes the first 3 ports, the
; 8251 for the selected slot is initialized.
;
INITMOD:  LXI	H,INITSTR	;point to initialization string
	  LXI	B,5*256+PORT+1	;B=count, C=UART cmd port
	  DB	0EDH,0B3H	;Z-80 OTIR instruction
	  MVI	A,DEFBD		;start at default baud rate
	  OUT	BAUDRP		;send to baud rate port
	  MVI	A,DEFMSPD	;default xfer time to default baud rate
	  STA	MSPEED
	  IN	MODCTL1		;clear any incoming chars.
	  IN	MODCTL1		;try once more
	  XRA	A		;clear the 'A' reg.
	  RET

INITSTR:  DB	80H,80H		;fillers to ensure known state
	  DB	040H		;internal reset
	  DB	04EH		;1 stop bit, 8 data bits, no parity
				;16x clock
	  DB	037H		;TX on, RX on, DTR low, RTS low
				;reset errors
;.....
;
;
; The following changes the baud rate with the set command.
;
SETUPR:	  MVI	C,SBLANK	;any arguments?
	  CALL	MEX
	  JC	TELL		;if not, go display baud rate
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;parse agrument
	  PUSH	H		;save any arg addrs on stack
	  RNC			;if we have one, return to it
	  POP	H		;oops, input not found in table
	  MVI	C,ILP
	  CALL	MEX		;tell user input not valid
	  DB	'++ Incorrect Entry ++',CR,LF,BELL,0
	  RET

CMDTBL:	  DB	'30','0'+80H
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
	  DB	'1920','0'+80H
	  DW	OK19200
;
TELL:	  MVI	C,ILP
	  CALL	MEX
	  DB	CR,LF,'Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET

OK300:	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD

OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD

OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD

OK2400:	  MVI	A,6
	  LHLD	BD2400
	  JMP	LOADBD

OK4800:	  MVI	A,7
	  LHLD	BD4800
	  JMP	LOADBD

OK9600:	  MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD

OK19200:  MVI	A,9
	  LHLD	BD19200
	
LOADBD:	  STA	MSPEED		;set xfer time
	  MOV	A,L		;get least significant baud rate byte
	  OUT	BAUDRP		;set baud rate
	  RET

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
	  CPI	9
	  JZ	OK19200
	  RET
;.....
;
;
; Table of baudrate parameters for N/S SIO board 
;
BD300:	  DW	0040H
BD600:	  DW	0060H
BD1200:	  DW	0070H
BD2400:	  DW	0078H
BD4800:	  DW	007CH
BD9600:	  DW	007EH
BD19200:  DW	007FH
	;
BAUDBUF:  DB	10,0
	  DS	10
;
;-----------------------------------------------------------------------
;
; The following routine could be used to display selections of interest
; to owners of this computer.  If using the Hayes Smartmodem this is
; unavailable without a special change.
;
SPCLMENU: RET
;
EOSMSG:	  DB	15,0,0,0,0,'$'	;clear to eos for N/S Advantage
CLSMSG:	  DB	30,15,0,0,0,'$'	;clear screen (home and clear eos)

;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	  END
;
