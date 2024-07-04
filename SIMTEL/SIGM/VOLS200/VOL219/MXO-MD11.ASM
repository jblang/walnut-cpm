; MXO-MD11.ASM - Morrow Micro Decision overlay file for MEX10.  05/15/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Morrow Micro Decision computer to the mex pro-
; gram.  While this computer has two serial ports, one is used for the
; CRT/keyboard and the other for the printer.
; Connect the modem in place of the printer.
;
;NOTE: This version MXO-MD11 is updated for the Morrow MD-3A
;which has a parallel printer port.  If the parallel port is used
;for the printer, no printer changes are necessary.  ALSO the
;address in the CONOUT: routine has been corrected.  Use version
;-MD10 if your unit is not an MD-3A with the parallel printer port
;
;
 ; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 05/15/84 - Converted from MDM7xx to MEX10     - Sandy Berger
; 03/25/84 - Revised for use with MDM730        - Sandy Berger
; 11/11/83 - Renamed to M7MD-1.ASM, no changes	- Irv Hoff
; 07/21/83 - Renamed for use with MDM712	- Irv Hoff
; 07/01/83 - Revised for use with MDM711	- Irv Hoff
; 06/22/83 - Revised for use with MDM710	- Irv Hoff
; 06/22/83 - Altered MDM708DP for Morrow
;	     Micro Decision computers using
;	     an external modem			- Irv Hoff
; 05/28/84 - Altered for model MD-3A            - Alan Bierbaum
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
; Set to NO if using an MD2
MD3:		EQU	YES
;
PORT:		EQU	0FEH		;Morrow MD printer port
MODCTL1:	EQU	PORT+1		;Modem status port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+1		;Modem control port
MODRCVB:	EQU	02H		;Modem receive bit
MODRCVR:	EQU	02H		;Modem receive ready
MODSNDB:	EQU	01H		;Modem send bit
MODSNDR:	EQU	01H		;Modem send ready bit
;
; MEX service processor stuff
;
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
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=Touch, P=Pulse (Smartmodem-only)	105H
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
RETRY:		DB	YES	;yes=ask user to reset error count	10DH
				;after 10 consecutive errors
				;no=abort after 10 consecutive errors
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVRUB:	DB	NO	;yes=convert rub to backspace		111H
TOGGLERUB:	DB	YES	;yes=allow toggling of rub to bksp	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	YES	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;no=using modem on printer port		119H
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	NO	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'\'-40H	;^\ = Send 50 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	']'-40H	;^] = Send next character		127H
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
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when ready
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready
		DS	12
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	3		;				162H
JMP$DISCONNT:	JMP	GOODBYE		;				165H
JMP$GOODBYE:	RET ! NOP ! NOP		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	JMP	NEWBAUD		;sets baud rate associated with#16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
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
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
; The SCRNTST option must be set "YES" for these to work.  These are now
; set for the DEC VT100 terminal.
;
CLREOS:		MVI	C,ILP
		CALL	MEX
		DB	ESC,'[J',0
		RET
;
CLRSCRN:	MVI	C,ILP
		CALL	MEX
		DB	ESC,'[H',ESC,'[J',0
		RET
;
;
SYSVER:		MVI	C,ILP
		CALL	MEX
		DB	'Version for Morrow Micro Decision computers'
		DB	CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0B00H if using the
;	Hayes Smartmodem or by address 0D00H otherwise.
;
;-----------------------------------------------------------------------
;
;
LOGON:	  DB	'LOGON GOES HERE',cr,0
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
GOODBYE1: OUT	MODCTL1		;SEND TO STATUS PORT
	  MVI	B,3		;WAIT 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,07H		;NORMAL SEND/RECEIVE WITH DTR
	  OUT	MODCTL1		;SEND TO STATUS PORT
	  RET
;.....
;
;
; Morrow MD  initialization -- sets the 8251A for 8 bits, 1 stop pulse,
; DTR high, requires dip switches be set internally to 1200 baud then
; divides by 64 for 300, or by 16 for 1200 baud via "SET" command.  Set
; at present to default to 1200 baud. The switch settings are only meaningful
; for the MD2 computer. This overlay has MD3 code to set the CTC timer chip
; to 1200 baud. MD2 users should change the MD3 equate near the front.
;
INITMOD:  MVI	A,1		;TRANSFER TIME FOR 300 BAUD
	  STA	MSPEED	
	  MVI	A,087H		;INSURE OUT OF MODE
	  OUT	MODCTL1		;MODEM STATUS PORT
	  OUT	MODCTL1		;SLIGHT EXTRA DELAY
	  MVI	A,40H		;INITIALIZE USART
	  OUT	MODCTL1		;MODEM STATUS PORT
;
INITMOD1: MVI	A,4FH		;DEFAULT TO DIVIDE BY 64 FOR 300 BAUD
	  OUT	MODCTL1		;MODEM STATUS PORT
	  MVI	A,17H		;DTR, RCV, XMT, ERROR RESET
	  OUT	MODCTL1		;MODEM STATUS PORT
	  IN	PORT		;CLEAR DATA PORT
;
; This is the beginning of the MD3 specific code.
;
	  IF	MD3
	  MVI	A,0BEH
	  OUT	0F3H
	  LXI	D,104
	  MOV	A,E
	  OUT	0F2H
	  MOV	A,D
	  OUT	0F2H
	  ENDIF
;
; End of MD3 specific code.
;
	  RET
;.....
;
;
SETUPR:	  MVI	C,SBLANK	;ANY ARGUMENTS?
	  CALL	MEX
	  JC	TELL		;IF NOT, GO DISPLAY BAUD
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;PARSE ARGUMENT
	  PUSH	H		;SAVE ANY PARSED ARGUMENT ADRS ON STACK
	  RNC			;IF WE HAVE ONE, RETURN TO IT
	  POP	H		;OOPS, INPUT NOT FOUND IN TABLE
	  MVI	C,ILP
	  CALL	MEX		;TELL USER INPUT NOT VALID
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
	  CALL	MEX		;PRINT CURRENT BAUD RATE
	  DB	CR,LF,'Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
OK300:	  MVI	A,1		;MSPEED 300 BAUD VALUE
	  MVI	B,4FH		;DIVIDE BY 64 FOR 300 BAUD
	  JMP	LOADBD		;GO LOAD THEM
;
OK1200:	  MVI	A,5
	  MVI	B,4EH		;DIVIDE BY 16 FOR 1200 BAUD
;
;
LOADBD:	  STA	INITMOD+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,B		;GET BAUDRATE BYTE
	  STA	INITMOD1+1	;STORE IN INITMOD
	  JMP	INITMOD		;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
;
BAUDBUF:  DB	10,0
	  DS	10
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	5
	  JZ	OK1200
	  RET
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
;
; Special MEX code for Morrow BIOS to not trap certain escape sequences
;
; Following line must be BIOS address of CONOUT.
CONOUT:	EQU	0F394H
;
; The address of the following line must be substituted at location
; OUTVEC for certain terminals to work properly with
; certain hosts. If you replace the address then all control
; codes sent to the terminal will have their high order bit set so that
; the MORROW will send them through properly and not trap them.
;
SLBTYP:	MOV	A,C
	CPI	20H
	JP	SLBT2
	ORI	80H
SLBT2:	MOV	C,A
	JMP	CONOUT
;=======================================================================
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem).
;
;
; This is the patch file for MEX 1.0 -- you may edit this file to change
; various initial variables.
;
; The order of the patch variables supported here will not change from
; version to version (i.e., new items will be added on to the end).
;
;
	ORG	0D00H		;location of patch variables
;
;
; The following line defines the MEX service call entry point, and
; is not meant to be changed by the user
;
MEX:	DS	3		;MEX service call processor
	DS	3		;reserved
	DS	1		;reserved
;
; The following line contains the initial free-memory pointer for
; MEX.  Sophisticated modem overlays requiring additional space may change
; this pointer (ie, move it higher), and thus "protect" an area of RAM.
;
MEMRY:	DS	2		;first free memory pointer
;
; Following are the lowest-level vectors for console and list I/O used
; by MEX.  These normally point to routines that save the registers and
; vector to the appropriate BIOS routines.  Complex applications may
; need to intercept (or even replace) these routines.  If you do this,
; be sure to preserve DE, HL and BC.
;
STSVEC:	DS	2		;console status vector
INVEC:	DS	2		;console input vector
OUTVEC:	DW	SLBTYP		;console output vector
LVEC:	DS	2		;list output vector
LSTVEC:	DS	2		;list status vector
;
; The following line defines the location of the default MEX prompt.
; If you'd like to provide your own initial prompt, add a DW statement
; pointing to a prompt buffer structured as follows:
;
;		DB <max size of buffer>
;		DB <length of actual prompt>
;		DB <prompt string>
;
; <maxsize> and <length> may be equal (especially if you disable the
; ID command by setting CHGPMT, below to 0); the ID command will, if
; left enabled, be limited to the <max size> value.
;
PROMPT:	DS	2		;prompt location
	DS	1		;reserved
TYPLIN:	DB	22		;for TYPE command: # lines/screen
PAUSFL:	DB	1		;for TYPE cmd: 1=pause 0=no pause
SEPCHR:	DB	';'		;multiple command-line separator
;
; following five for SENDOUT command
;
SOWAIT:	DB	4		;# seconds waiting for a sendout echo
SOREPL:	DB	8		;# seconds waiting for initial reply
SOTRIG:	DB	'>'		;sendout trigger char from remote
CANCHR:	DB	'U'-64		;sendout char to cancel line to remote
SORTRY:	DB	6		;sendout # retries
;
;
HEXFLG:	DB	0		;hex/decimal mode
ESCCHR:	DB	0AH		;terminal mode escape char (0AH = linefeed)
NOBELL:	DB	0		;set to 1 to disable bell
;
; Buffer variables.  See BUFFERS.DOC for setup information
;
PSIZE:	DB	2		;default=2k
ASIZE:	DB	255		;"big" capture buffer
XSIZE:	DB	16		;16K transfer buffer
NSIZE:	DB	1		;1k for 85 batch files
PRELEN:	DB	40		;maximum length of PREFIX string
SUFLEN:	DB	40		;maximum length of SUFFIX string
;
; Misc. stuff
;
CDOSFL:	DB	0		;non-zero for CDOS
WTECHO:	DB	0		;non-zero sets "wait-for-echo"
KYSIZE:	DW	400		;size of keystring area, in bytes
CISFLG:	DB	1		;non-zero allows CIS file transfers
CISOK:	DB	1		;non zero allows STAT CIS ON or OFF
CHGPMT:	DB	1		;non-zero allows ID (prompt chg) command
ERRID:	DB	1		;non-zero prints ID msg in err msgs
;
; by setting the following DB to 0, you can disable the HELP
; command, freeing up space used by the help file index.
;
HELPOK:	DB	1		;non-zero allows HELP command
MEXDU:	DB	0		;user \/  alternate area for READ,LOAD,INI.MEX
	DB	0		;drive/\  & HELP.MEX (if SEARCH <>0)
DEBUG:	DB	0		;debugging in term-mode if non-zero
EXCLSY:	DB	1		;non-0 excludes $SYS from batchsend, dir
INIMEX:	DB	1		;non-zero runs INI.MEX (if present) at startup
RTIMER:	DB	1		;receiver wait: # seconds [Plouff patch]
PQSIZE:	DW	150		;size of the modem-port queue
PHSIZE:	DB	30		;phone library size (# entries)
SILENT:	DB	0FFH		;0=silence multi-line & READ cmd echo
ALERT:	DB	255		;alert-bell count on CALL complete
EXTEND:	DB	0		;non-zero: unknown commands goto READ processor
SPLIT:	DB	0		;non-zero: splits phonelib printout, shows baud
SEARCH:	DB	0		;search mode 0,1,2,3
;
; Following is the GLOBAL secondary options table.  To
; set an option to global, change its ASCII character to a 0.
;
RESTT:	DB	'BDLQRSTVX'
;
;
	END
