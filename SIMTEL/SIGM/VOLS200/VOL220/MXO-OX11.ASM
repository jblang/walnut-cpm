       Title	'MEX overlay for Osborne Executive, version 1.1'
;
;
; (delete above title line if not assembling with MAC)
;
;
REV	EQU	11		;overlay revision level
;  
;  MEX Overlay for Osborne EXECUTIVE with external
;  modem connected to the MODEM port (port 0CH).
;
;  Incorporates a fully implemented SET BAUD function
;  using the MEX processor.  The initialization routine
;  has been modified to allow sending an initialization
;  string to the modem.  (The string is defined at the
;  end of this overlay.)  This is for the US Robotics 
;  Password modem.  (It sets dialing to tone mode,
;  turns on the echo mode, turns on the extended response
;  codes, and defeats the auto-answer function.)  It can
;  be eliminated or modified for appropriate use.  
;
;  If you exit to CPM without disconnecting, when you 
;  re-enter MEX, the program will skip the initialization
;  procedure (both port initialization and modem
;  initialization) and remind you to do a SET BAUD to the
;  rate in effect.  Although the rate has not been changed,
;  later functions may not operate properly.  You may cover
;  this in advance by entering the command on the command
;  line when re-calling MEX.  For example:
;       MEX SET BAUD 300; T 
;
;  Assembly notes:
;	This overlay incorporates a disconnect routine which
;	lowers DTR for 300 ms.  Accordingly, if you use the
;	Smartmodem overlay, set DISC to FALSE in MXO-SMxx.ASM.
;
;	If your modem does not require an initialization string,
;	you may replace the string at SMINIT by a single DB 0.  
;
;
;  Calling conventions for the various overlay entry points
;  are detailed more fully in the PMMI overlay (MXO-PMxx.ASM,
;  where xx=revision number).
;
;  History as a MEX overlay:
;
;  07/01/84	v1.1: Provided support for all MEX baud rates.
;		Made overlay clonable at any baud rate.
;		Included additional SET routines.
;
;  06/24/84	MEXified the overlay	- Bob Abrahams, Los Angeles, CA
;               Named MXO-OX10.ASM        CIS 72406,1355
;
;  History as a MDM overlay:
;
;  11/11/83	Renamed to M7OX-1.ASM		- Irv Hoff
;  07/27/83     Renamed to work with MDM712	- Irv Hoff
;     :			:			     :
;     :			:			     :
;  07/17/83     Combined George Peace Osborne version
;		with Roy Robinson Osborne version
;		then renamed MDM711OX.ASM	- Irv Hoff         
;
;------------------------------------------------------------
;
; Misc equates:
;
NO	EQU	0
YES	EQU	NOT NO
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9
ESC	EQU	27
BELL	EQU	7
;
; Osborne EXECUTIVE port definitions:
;
PORT	EQU	0Ch		;base port (data or status)
MODCT1	EQU	PORT+1		;modem control port
MODDAT	EQU	PORT		;modem data port
BAUDRP	EQU	04h		;modem baud rate port
;
; Osborne EXECUTIVE bit definitions:
;
MDRCVB	EQU	01H		;modem receive bit (DAV)
MDRCVR	EQU	01H		;modem receive ready
MDSNDB	EQU	04H		;modem send bit
MDSNDR	EQU	04H		;modem send ready bit
;
; MEX Service Processor codes:
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
;		-------------------------------------
;
;  From MEXPAT10 -- to establish <ESC> as terminal escape character
	  ORG	0D1Fh
ESCCHR:	  DB	ESC	;Terminal mode escape character = <ESC>	
;
;		------------------------------------
;
	ORG	TPA		;we begin
;
	DS	3		;MEX has a JMP START here
;
;
PMODEM:	DB	NO		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	DB	YES		;yes=Smartmodem / \ referenced by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (not referenced by MEX)
CLOCK:	DB	40		;clock speed x .1, up to 25.5 mhz.
				;4 MHz for Osborne Executive
MSPEED:	DB	5		;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	3		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	8		;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		;number of directory columns
SETFL:	DB	YES		;yes=user-defined SET command
SCRTST:	DB	YES		;yes=if home cursor and clear screen
				;routine at CLRSCRN
ACKNAK:	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	NO		;yes=make .BAK file
CRCDFL:	DB	YES		;yes=default to CRC checking
				;no=default to Checksum checking
TOGCRC:	DB	YES		;yes=allow toggling of Checksum to CRC
CVTBS:	DB	NO		;yes=convert backspace to rub
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub
ADDLF:	DB	NO		;no=no LF after CR to send file in
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR
TRNLOG:	DB	NO		;yes=allow transmission of logon
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP
LOCNXT:	DB	YES		;yes=local cmd if EXTCHR precedes
				;no=not local cmd if EXTCHR precedes
TOGLOC:	DB	YES		;yes=allow toggling of LOCNXTCHR
LSTTST:	DB	YES		;yes=allow toggling of printer on/off
				;in terminal mode. Set to no if using
				;the printer port for the modem
XOFTST:	DB	NO		;yes=allow testing of XOFF from remote
				;while sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after sending CR while
				;transmitting a file in terminal mode	
TOGXOF:	DB	YES		;yes=allow toggling of XOFF testing
IGNCTL:	DB	YES		;yes=do not send control characters
				;above CTL-M to CRT in terminal mode
				;no=send any incoming CTL-char to CRT
EXTRA1:	DB	0		;for future expansion
EXTRA2:	DB	0		;for future expansion
BRKCHR:	DB	'B'-40H		;^@ = Send a 300 ms. break tone
NOCONN:	DB	'N'-40H		;^N = Disconnect from phone line
LOGCHR:	DB	'I'-40H		;^L = Send logon
LSTCHR:	DB	'P'-40H		;^P = Toggle printer
UNSVCH:	DB	'R'-40H		;^R = Close input text buffer
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer
EXTCHR:	DB	'\'-40H		;^\ = Send next character
;
	DS	2		;not used
;
; Low-level modem I/O routines.
;
INCTL1:	MVI	A,10H
	OUT	MODCT1
	IN	MODCT1		;in modem control port
	RET
	DB	0,0,0		;spares, if needed (10 bytes total)
;
OTDATA:	OUT	MODDAT		;out modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares, if needed (10 bytes total)
;
INPORT:	IN	MODDAT		;in modem data port
	RET
	DB	0,0,0,0,0,0,0	;spares, if needed (10 bytes total)
;
; Bit-test routines. 
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready
;
	DS	12
;
;
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:	DS	3
DISCV:	JMP	DISCON
GOODBV:	JMP	GOODBYE		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		;set baud rate
NOPARV:	DS	3		;set modem for no-parity
PARITV:	DS	3		;set modem parity
SETUPV:	JMP	SETCMD		;SET cmd: jump to a RET if you don't write SET
SPMENV:	DS	3		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV:	JMP	SBREAK		;send a break
;
; The following jump vector provides the overlay with access to special
; routines in the main program (retained and supported in the main pro-
; gram for MDM overlay compatibility). These should not be modified by
; the overlay.
;
; Note that for MEX 2.0 compatibility, you should not try to use these
; routines, since this table will go away with MEX 2.0 (use the MEX
; service call processor instead).
;
ILPRTV:	DS	3		;replace with MEX function 240
INBUFV:	DS	3		;replace with MEX function 10
ILCMPV:	DS	3		;replace with table lookup funct. 247
INMDMV:	DS	3		;replace with MEX function 255
NXSCRV:	DS	3		;not supported by MEX (returns w/no action)
TIMERV:	DS	3		;replace with MEX function 254
;
CLREOS:	CALL	ILPRT
	DB	ESC,'Y',0
	RET
	DB	0,0
;
CLS:	CALL	ILPRT
	DB	ESC,'Z',0
	RET
	DB	0,0
;
;
; end of fixed area
;
ILPRT:	  MVI	C,ILP		;MEX In-line print
	  JMP	MEX
;
SYSVER:	  CALL	ILPRT
	  DB	'For Osborne Executive MODEM port, ver. '
	  DB	REV/10+'0'
	  DB	'.'
	  DB	REV MOD 10+'0'
	  DB	CR,LF,0
	  RET
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SBREAK:   MVI	A,5
	  OUT	MODCT1
	  MVI	A,0F8H		;SEND A BREAK TONE		
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
DISCON:   MVI	A,5
	  OUT	MODCT1		;SEND TO THE STATUS PORT
	  MVI	A,68H		;TURN OFF DTR
;
GOODBYE1: OUT	MODCT1
	  MVI	B,3		;DELAY 300 MS.
	  MVI	C,TIMER
	  CALL	MEX
GOODBYE:  MVI	A,5
	  OUT	MODCT1
	  MVI	A,0E8H		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCT1
	  RET
;.....
;
;
; Osborne EXECUTIVE RS232 initialization -- 
;  Checks to see if a call is in progress (carrier on).  If so,
;  it sends a warning message.  Otherwise it sets the CTC timer
;  04h for send and receive baudrate and sends the modem
;  initialization string.
;
;
NITMOD:
;
	CALL	INCTL1		;GET SIO STATUS
	ANI	08H		;SEE IF CARRIER IS PRESENT
	JZ	NODCD		;IF NOT, DO NORMAL INITIALIZE
	CALL	ILPRT		;IF SO, ISSUE SPECIAL MESSAGE INSTEAD
	DB	CR,LF
	DB	'++ Call in progress --',CR,LF
	DB	'   SET BAUD to rate in effect for this call. ++'
	DB	BELL,CR,LF,LF,0
	RET
;
NODCD:
	  MVI	A,00H		;SELECT REG.
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
	  MVI	A,0EAH		;ENABLE SEND, DTR, RTS
	  OUT	MODCT1
	  LDA	MSPEED		;GET INITIAL BAUD RATE
	  CALL  PBAUD		;SET UP INITIAL RATE
;
	  LXI	H,SMINIT	;MODEM INITIALIZATION STRING
	  CALL	SMSEND		;SEND TO MODEM
SMTLP:	  MVI	B,1
	  MVI	C,TMDINP	;EAT ANY RESPONSE CHARACTERS
	  CALL  MEX
	  JNC	SMTLP		;UNTIL 100 MS OF QUIET TIME
	  RET
;
SMSEND:	  MVI	C,SNDRDY	;WAIT FOR MODEM READY
	  CALL	MEX
	  JNZ	SMSEND
	  MOV	A,M		;FETCH NEXT CHARACTER
	  INX	H
	  ORA	A		;END?
	  RZ			;DONE IF SO
	  MOV	B,A		;NO, POSITION FOR SENDING
	  MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	  CALL	MEX
	  JMP	SMSEND
;
; Sets the modem speed via the SET command.
;
SETCMD:	  MVI	C,SBLANK	;ANY ARGUMENTS?
	  CALL  MEX
	  JC	BDSHOW		;IF NOT, DISPLAY BAUD RATE
	  MVI	C,LKAHED	;LOOK AT NEXT CHARACTER
	  CALL	MEX		;TO SEE IF DIGIT 1-9
	  CPI	'1'		;IS IT TOO SMALL?
	  JC	NOTNUM
	  CPI	'9'+1		;IS IT TOO BIG?
	  JC	STBAUD
NOTNUM:	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL  MEX		;PARSE THE ARGUMENT
	  PUSH	H		;SAVE ANY PARSED ARGUMENTS ON STACK
	  RNC			;IF WE HAVE ONE, RETURN TO IT
	  POP	H		;OOPS, INPUT NOT FOUND IN TABLE
SETERR:	  CALL	ILPRT	
	  DB	CR,LF,'++ SET command error ++',BELL,CR,LF,LF,0
	  RET
;
; Argument table
;
CMDTBL:	  DB	'?'+80H		;HELP
	  DW	STHELP
	  DB	'BAU','D'+80H	;"SET BAUD"
	  DW	STBAUD
	  DB	'INI','T'+80H	;"SET INIT"
	  DW	NITMOD
	  DB	0		;TABLE TERMINATOR
;
; "SET ?" processor
;
STHELP:	  CALL  ILPRT
	  DB	CR,LF,'SET <rate> or SET BAUD <rate>'
	  DB	CR,LF,'  <rate> is one of:'
	  DB	'  110 300 450 600 710 1200 2400 4800 9600 19200'
	  DB	CR,LF,LF,0
	  RET
;
; "SET BAUD" processor
;
STBAUD:	  MVI	C,BDPARS	;FUNCTION CODE: PARSE A BAUDRATE
	  CALL	MEX		;LET MEX LOOK UP CODE
	  JC	SETERR		;JUMP IF INVALID CODE
	  CALL	PBAUD		;NO, TRY TO SET IT
	  JC	SETERR		;IF NOT ONE OF OURS, BOMB OUT
BDSHOW:	  CALL	ILPRT		;DISPLAY BAUD
	  DB	'Baud: ',0
	  LDA	MSPEED		;GET CURRENT BAUD RATE
	  MVI	C,PRBAUD	;LET MEX PRINT IT
	  CALL	MEX
	  CALL	ILPRT		;CR,LF
	  DB	CR,LF,0
	  RET 
;
; This routine sets baud rate passed as MSPEED code in A.
; Returns CY=1 if baud rate not supported (if supported,
; this routine must set the new MSPEED code).
;
PBAUD:	  PUSH	H		;DON'T ALTER ANYBODY
	  PUSH	D
	  PUSH 	B
	  STA	MSPEED		;ALL RATES SUPPORTED
	  ADD	A		;DOUBLE IT
	  MOV	E,A		;MSPEED CODE TO DE
	  MVI	D,0
	  LXI	H,BAUDTB	;OFFSET INTO TABLE
	  DAD	D
	  MOV	A,M		;FETCH LSB CODE
	  OUT	BAUDRP		;SEND IT
	  INX	H		;SECOND BYTE
	  MOV	A,M		;FETCH MSB CODE
	  OUT	BAUDRP		;SEND IT

	  ORA	A		;RETURN NO ERRORS
PBEXIT:	  POP	B
	  POP	D
	  POP	H
	  RET
;
BAUDTB:			;TABLE OF VALUES TO SEND TO 8253 TIMER
			;SEND LSB, THEN MSB (NOTE:  PSEUDO-OP DW
			;STORES LSB THEN MSB, SO SEQUENCE IS CORRECT.)
	  DW	0417H		;110
	  DW	0180H		;300
	  DW	0100H		;450
	  DW	00C0H		;600	
	  DW	00A2H		;710
	  DW	0060H		;1200
	  DW	0030H		;2400
	  DW	0018H		;4800
	  DW	000CH		;9600
	  DW	0006H		;19200
;
;
SMINIT:   DB	'ATTE1X1S0=0',CR,0	;MODEM INITIALIZE STRING
;
	  END
