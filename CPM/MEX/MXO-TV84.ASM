
; MXO-TV804.ASM -- TeleVideo TS-804 overlay file for MEX10. 04/02/86
;		  - Originally MXO-TV802.ASM -
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the modem port on the TeleVideo TS-804 to the modem
; program.
;
; Edit this file for your preferences then follow the Installation
; instructions provided with MEX10.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 04/02/86 - Revised to work with TS804 	- Bill Dale
; 05/22/84 - Revised to work with MEX10 	- Bob Robesky
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM711	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/27/83 - Revised to work with TV802 	- Irv Hoff
; 02/17/83 - Modified MDM703CF for Datapoint
;	     1560 computers using an external
;	     modem				- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL		EQU	07H		;bell
CR		EQU	0DH		;carriage return
ESC		EQU	1BH		;escape
LF		EQU	0AH		;linefeed
;
YES		EQU	0FFH
NO		EQU	0
;
;
PORT		EQU	1EH		;TeleVideo TS-804 data port
;
BAUDRP		EQU	0EH		;CTC port for baud rate
MODCTL1		EQU	PORT+1		;Modem control port
MODCTL2		EQU	PORT+1		;Modem control port
MODDATP		EQU	PORT		;Modem data port
MODDCDB		EQU	4		;carrier detect bit
MODDCDA		EQU	0		;value when active
MODRCVB		EQU	1		;bit to test for receive ready
MODRCVR		EQU	1		;value when ready
MODSNDB		EQU	4		;bit to test for send ready
MODSNDR		EQU	4		;value when ready
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
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	NO	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=check for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone 	120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'O'-40H	;^O = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H	;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1	! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP	! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP	! RET	;in modem data port		13EH
		DS	7
;
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rec. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				154H
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port #2	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem control port #1	15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,79H,0,0,0	;ESC y - clear to end of screen 198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,2AH,0,0,0	;ESC * clear CRT, home cursor	11AH
		RET			;				1A6H
;
;
SYSVER:		MVI	C,ILP
		CALL	MEX
		DB	'Version for TeleVideo TS-804'
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
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set YES.	You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:	  DB	'XVY61937,OUTRAGE',CR,LF,0
;
;=======================================================================
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
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
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,068H		;TURN OFF DTR, SEND BREAK
;
GOODBYE1: OUT	MODCTL1
	  MVI	B,3		;WAIT 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0E8H		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCTL1
	  RET
;.....
;
;
; TeleVideo TS-804 baud rate change.  Sets CTC at port 0EH for baudrate
; in/out.
;
;
INITMOD:  MVI	A,0		;SELECT REG.
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,18H		;RESET THE Z8SIO CHIP
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,4		;SELECT REG.
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,44H		;16X, 1-STOP, NO PARITY
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,3		;SELECT REG.
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,0C1H		;ENABLE RECEIVE SECTION
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,5		;SELECT REG.
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,0EAH		;DTR, RTS, 8-BITS, ENABLE SEND SECTION
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
;
INITMOD1: MVI	A,5		;DEFAULT TRANSFER TIME TO 1200 BAUD
	  STA	MSPEED
	  MVI	A,47H
	  OUT	BAUDRP
;
INITMOD2: MVI	A,68H		;DEFAULT TO 1200 BAUD
	  OUT	BAUDRP
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
	  DB	CR,LF,'Only 300, 1200, 2400 or 9600 allowed on SET command',CR,LF,0
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
	  CALL	MEX		;PRINT CURRENT BAUD RATE
	  DB	CR,LF,'Baud rate is now: ',0
	  LDA	MSPEED
	  MVI	C,PRBAUD
	  CALL	MEX
	  RET
;
OK300:	  MVI	A,1		;MSPEED 300 BAUD VALUE
	  LHLD	BD300		;GET 300 BAUD PARAMETERS IN 'HL'
	  JMP	LOADBD		;GO LOAD T
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400:	  MVI	A,6
	  LHLD	BD2400
	  JMP	LOADBD

OK9600:	  MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD
;
LOADBD:	  STA	INITMOD1+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,L		;GET BAUDRATE BYTE
	  STA	INITMOD2+1	;STORE IN INITMOD
	  JMP	INITMOD1	;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300:	  DW	0734H		;7800/300  CONVERTED TO HEX VALUE
BD1200:	  DW	4768H		;124800/1200 CONVERTED TO HEX VALUE
BD2400:	  DW	4734H		;124800/2400 CONVERTED TO HEX VALUE
BD9600:	  DW	470DH		;124800/9600 CONVERTED TO HEX VALUE;
;
BAUDBUF:  DB	10,0
	  DS	10
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;-----------------------------------------------------------------------
;
; These routines can be used for your equipment, be sure to end with RET
; If using the Hayes Smartmodem this is unavailable without a special
; address change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
; +++ end of MEX TeleVideo 804 overlay
;----------------------------------------------------------------------
;
; +++ THIS IS THE MXPAT10.ASM FILE
;
; This is the patch file for MEX 1.0 -- you may edit this file to change
; various initial variables. Assemble with ASM or MAC, then use MLOAD
; to patch the changes into MEX:
;
;	ASM MEXPAT10.AAZ			;assemble the edited file
;	MLOAD NEWMEX.COM=MEX.OBJ,MEXPAT10	;patch MEX
;
; You may also pull this file into your modem overlay (be sure you in-
; clude the ORG statement below).
;
; The order of the patch variables supported here will not change from
; version to version (i.e., new items will be added on to the end).
;
;
	ORG	0D00H		;location of patch variables
;
LF	EQU	10		;define ASCII linefeed code
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
; MEX.	Sophisticated modem overlays requiring additional space may change
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
OUTVEC:	DS	2		;console output vector
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
;
;----- End of MEXPAT10 area
;
