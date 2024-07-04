;     Title  'MEX Overlay for the Kaypro 4'84 Internal Modem --- Version 1.0'
;
;
REV	EQU	10		;overlay revision level
;  
;  MEX Overlay for Kaypro 4'84 computers with internal modem.
;  A full-featured SET command processor is implemented, including
;  all options supported by SUPRTERM.
;
;  The following SET commands are supported:
;
;					   
;	SET Command
;
;	DELAY <N>			Number of seconds to wait before
;					aborting a call in progress
;	ORIG 				Set modem to Originate mode
;					(inhibit auto-answer mode)
;	ANSWER				Set modem to auto-answer mode
;	TONE 				Set modem to Tone dialing
;	PULSE                           Set modem to Pulse dialing
;	PARITY                          Set parity to odd, even, or none
;	STOPBITS                        Set Stopbits to 1, 1.5 or 2
;	LENGTH                          Set word length to 5, 6, 7, 8
;
;	MANUAL				Modem goes off hook and activates
;                                       in Originate or Answer mode
;					(generates carrier tone)
;
;
;  This overlay is intended to be fully compatible with the
;  MEX structure and should be readily upward compatible with
;  the predicted MEX 2.0.
;
;  Calling conventions for the various overlay entry points
;  are detailed more fully in the PMMI overlay (MXO-PMxx.ASM,
;  where xx=revision number).
;
;  History:
;
;  9/9/84   1.0  Initial version.
;
;  Credits:
;
;  M7KP-1 overlay structure by Irv Hoff
;  Smartmodem dialing routine by Ron Fowler
;  Kaypro 4'84 internal modem support by John Smith
;  MXO-KP overlay structure also by John Smith
;  Parity, Length and Stopbit routines by Norm Saunders
;  Melange by Terry Carroll
;
;------------------------------------------------------------
;
; Misc equates
;
NO	EQU	0
YES	EQU	0FFH
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9
;
;
;
; Kaypro port definitions
;
INTPORT	EQU	0DH		;base internal port
PIODAT	EQU	21H		;internal modem pio data port
PIOCT1	EQU	PIODAT+2	;internal modem pio control port
INTCT1	EQU	INTPORT+2	;internal modem control port
INTDAT	EQU	INTPORT		;internal modem data port
;
; Kaypro bit definitions
;
MDRCVB	EQU	01H		;modem receive bit (DAV)
MDRCVR	EQU	01H		;modem receive ready
MDSNDB	EQU	04H		;modem send bit
MDSNDR	EQU	04H		;modem send ready bit
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
;
;
	ORG	TPA		;we begin
;
	DS	3		;MEX has a JMP START here
;
	DS	2		;not used by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (Used by this overlay)
CLOCK:	DB	46		;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	1		;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	DB	5		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	DB	5		;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	DB	5		;number of directory columns
SETFL:	DB	YES		;yes=user-defined SET command
SCRTST:	DB	YES		;yes=if home cursor and clear screen
				;routine at CLRSCRN
	DB	0		;was once ACKNAK, now spare
BAKFLG:	DB	YES		;yes=make .BAK file
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
LOCNXT:	DB	NO		;yes=local cmd if EXTCHR precedes
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
IGNCTL:	DB	NO 		;yes=do not send control characters
				;above CTL-M to CRT in terminal mode
				;no=send any incoming CTL-char to CRT
EXTRA1:	DB	0		;for future expansion
EXTRA2:	DB	0		;for future expansion
BRKCHR:	DB	'@'-40H		;^@ = Send a 300 ms. break tone
NOCONN:	DB	'N'-40H		;^N = Disconnect from phone line
LOGCHR:	DB	'L'-40H		;^L = Send logon
LSTCHR:	DB	'P'-40H		;^P = Toggle printer
UNSVCH:	DB	'R'-40H		;^R = Close input text buffer
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer
EXTCHR:	DB	'^'-40H		;^^ = Send next character
;
	DS	2		;not used
;
; Low-level modem I/O routines.
;
INCTL1:	JMP	INC		;in modem control port
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
;
OTDATA:	JMP	OUTD		;out modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non=PMMI
;
INPORT: JMP	IND		;in modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
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
LOGON:	DS	2		;needed for MDM compat, not ref'd by MEX
DIALV:	JMP	DIAL
DISCV:	JMP	DISCON
GOODBV:	JMP	GOODBYE		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	RET!NOP!NOP		;cannot change baud rate for internal modem
NOPARV:	RET!NOP!NOP		;set modem for no-parity
PARITV:	RET!NOP!NOP		;set modem parity
SETUPV:	JMP	SETCMD		;SET cmd: jump to a RET if you don't write SET
SPMENV:	RET!NOP!NOP		;not used with MEX
VERSNV:	JMP	SYSVER		;Overlay's voice in the sign-on message
BREAKV:	JMP	SBREAK		;send a break
;
; MDM calls supported in MEX 1.0 but not recommended for use.
;
ILPRTV:	DS	3		;replace with MEX function 9
INBUFV:	DS	3		;replace with MEX function 10
ILCMPV:	DS	3		;replace with table lookup funct. 247
INMDMV:	DS	3		;replace with MEX function 255
NXSCRV:	DS	3		;not supported by MEX (returns w/no action)
TIMERV:	DS	3		;replace with MEX function 254
;
CLREOS:	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLS:	LXI	D,CLSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
; end of fixed area
;
;------------------------------------------------------------
;
; Low level modem routine area
;
INC:	MVI	A,10H
	OUT	INTCT1
	IN	INTCT1
	RET
;
IND:	IN	INTDAT
	RET
;
OUTD:	OUT	INTDAT
	RET
;
; Print out the overlay version
;
SYSVER:	  CALL	MILP
	  DB	CR,LF
	  DB	'Overlay for Kaypro 4',27H,'84 Internal Modem ----- '
	  DB	'Version '
	  DB	REV/10+'0'
	  DB	'.'
	  DB	REV MOD 10+'0'
	  DB	CR,LF
	  DB    0
	  RET
;
; Break, disconnect and goodbye routines
;
SBREAK:	  MVI	A,5
	  OUT	INTCT1
	  LDA	REG5
	  ORI	00010000B	;ENABLE BREAK
	  OUT	INTCT1
	  MVI	B,3		;DELAY 300 MS.
	  CALL	MTIME
	  MVI	A,5
	  OUT	INTCT1
	  LDA	REG5
	  ANI	11101111B	;TURN OFF BREAK
	  OUT	INTCT1
	  RET
;
DISCON:	  MVI	A,01000000B	;SET MODEM ON-HOOK
	  OUT	PIODAT		;
	  CALL	MDMSQ
	  MVI   A,00H		;RESET TO ORIGINATE MODE
	  STA	ANSFLG
	  RET
;
GOODBYE:  RET			;NO DISCONNECT OR CHANGE IN SETTINGS 
;
; Initialize RS-232 port, PIO port and default modes.
;
NITMOD:   CALL	INC		;SEE IF MODEM IS CONNECTED, I.E., RETURNING
	  ANI	08H		;   TO ACTIVE MODEM FROM CPM
	  RNZ			;SKIP IF CONNECTED
	  CALL	NITSIO		;INITIALIZE EXTERNAL RS-232 PORT
	  MVI	A,0FH		;OUTPUT MODE CONTROL WORD
	  OUT	PIOCT1		;TO PIO
	  MVI	A,01011111B	;PREVENT DIALER DIAGNOSTIC MODE
	  OUT	PIODAT
	  MVI	B,1
	  CALL	MTIME		;WAIT 100 MS
	  MVI	A,11011111B
	  OUT	PIODAT
	  MVI	B,1
	  CALL	MTIME		;WAIT 100 MS
	  MVI	A,01011111B
	  OUT	PIODAT		;DIALER RESET COMPLETE
	  MVI	A,87H		;SET INTERRUPT MODE
	  OUT	PIOCT1	  	;FOR PIO
	  MVI	A,86H		;VECTORED INTERRUPT LOW ORDER ADR
	  OUT	PIOCT1		;TO PIO
	  MVI	A,01000000B
	  OUT	PIODAT
	  MVI	A,00H
	  STA	ANSFLG
	  LDA	TPULSE
	  CPI	'T'
	  JZ	TONE
PULSE:	  MVI	A,01010000B	;SET PULSE MODE, ON-HOOK
	  STA 	DIALWD
	  RET
TONE:	  MVI	A,01000000B	;SET TONE MODE, ON-HOOK
	  STA	DIALWD
	  RET
;
;
;	Initialize the Zilog SIO chip
;
NITSIO:	  MVI	A,0  		;Select reg. 0
	  OUT	INTCT1
	  LDA	REG0		;Command byte
	  OUT	INTCT1
	  MVI	A,4  		;Select reg. 4
	  OUT	INTCT1
	  LDA	REG4		;Receive/transmit control byte
	  OUT	INTCT1
	  MVI	A,3  		;Select reg. 3
	  OUT	INTCT1
	  LDA	REG3		;Receiver logic byte
	  OUT	INTCT1
	  MVI	A,5  		;Select reg. 5
	  OUT	INTCT1
	  LDA	REG5		;Transmitter logic byte
	  OUT	INTCT1
	  RET
;
; Set command processor
;
SETCMD:	  MVI	C,SBLANK	;ANY ARGUMENTS?
	  CALL  MEX
	  JC	SETSHO		;IF NOT, DISPLAY DEFAULT(S)
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL  MEX		;PARSE THE ARGUMENT
	  PUSH	H		;SAVE ANY PARSED ARGUMENTS ON STACK
	  RNC			;IF WE HAVE ONE, RETURN TO IT
	  POP	H		;OOPS, INPUT NOT FOUND IN TABLE
SETERR:	  LXI	D,SETEMS
	  MVI	C,PRINT
	  CALL	MEX
	  RET
SETEMS:	  DB	CR,LF,'SET command error',CR,LF,'$'
;
; Argument table
;
CMDTBL:   DB	'?'+80H			; HELP
	  DW	SETHELP
	  DB	'ORI','G'+80H		; ORIGINATE MODE
	  DW	ORIG
	  DB	'ANSWE','R'+80H		; ANSWER MODE
	  DW	ANS
	  DB	'TON','E'+80H		; TONE DIALING
	  DW	STTONE
	  DB	'PULS','E'+80H		; PULSE DIALING
	  DW	STPULSE
	  DB	'DELA','Y'+80H		; SET DELAY
	  DW	DELAY
	  DB	'PARIT','Y'+80H		; SET PARITY
	  DW	STPRTY
	  DB	'STOPBIT','S'+80H	; SET STOPBITS
	  DW    STSTOP
	  DB	'LENGT','H'+80H		; SET LENGTH
	  DW	STBITS
	  DB	'MANUA','L'+80H		; SET MANUAL
	  DW	MANUAL
	  DB	0			;TABLE TERMINATOR
;
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL  MILP
	  DB	CR,LF
	  DB	'Current SET values:',CR,LF,0
          CALL	CRLF
	  CALL	MDSHOW
	  CALL	CRLF
	  CALL	TPSHOW
	  CALL	CRLF
	  LDA 	MSPEED
	  MVI   C,PRBAUD
	  CALL	MEX
	  CALL	CRLF
	  CALL	CRLF
	  CALL  SHPRTY
	  CALL	CRLF
	  CALL	SHSTOP
	  CALL	CRLF
	  CALL  SHBITS
	  CALL	CRLF
	  CALL  CRLF
	  RET
;
; "SET ?" processor
;
SETHELP:  CALL	MILP
	  DB	CR,LF,'SET ORIG      - Originate mode: auto-answer inhibited'
	  DB	CR,LF,'SET ANSWER    - Place modem in auto-answer mode'
	  DB	CR,LF,'SET TONE      - Use Tone Dialing'
	  DB	CR,LF,'SET PULSE     - Use Pulse Dialing'
	  DB	CR,LF,'SET DELAY     - <N> seconds to wait for answer'
	  DB	CR,LF,'SET PARITY    - OFF <or> EVEN <or> ODD'
	  DB	CR,LF,'SET STOPBITS  - 1 <or> 1.5 <or> 2'
	  DB	CR,LF,'SET LENGTH    - 5 <or> 6 <or> 7 <or> 8'
	  DB	CR,LF,'SET MANUAL    - ORIG <or> ANSWER'
	  DB    CR,LF,'                Manually place modem in Originate or'
	  DB	CR,LF,'                Answer mode and send the appropriate'
	  DB    CR,LF,'                carrier tone'
	  DB	CR,LF,CR,LF,0
	  RET
;
; Set mode processor
;
ORIG:	  MVI	A,00H
	  STA	ANSFLG		;SET ORIG FLAG
	  JMP	MDSHOW
ANS:	  MVI	A,0FFH
	  STA	ANSFLG		;SET ANS FLAG
	  CALL	MDSHOW
	  CALL  CRLF
	  CALL  MILP
	  DB	'Waiting for ring.....',CR,LF,0
	  CALL	CRLF
;
WFANS:	  MVI	C,CHEKCC	;CHECK FOR ABORT
	  CALL	MEX
	  JZ	ENDANS		;ABORT AUTO-ANSWER MODE
	  CALL	INCTL1		;CHECK FOR RING INDICATOR
	  ANI	20H
	  JZ    WFANS		;IF NOT, LOOP 'TIL ABORT OR RING
	  MVI	B,10		;WAIT 1 SECOND BEFORE SENDING CARRIER
	  CALL	MTIME		;(PER FCC REQUIREMENTS)
	  CALL  MDMON		;IF RING, TURN ON MODEM
	  CALL	MILP
	  DB	'Ring detected......',CR,LF
	  DB	'Answer tone sent......',CR,LF
	  DB	'Waiting for carrier response from caller......',CR,LF,0
	  JMP   ENDIAL		;WAIT FOR CALLER'S CARRIER
ENDANS:   CALL  CRLF
	  CALL	MILP
	  DB	'^C entered.....auto-answer mode aborted'
	  DB	CR,LF
	  DB    'Returning to ',0
	  JMP   ORIG
;
MDSHOW:	  LDA	ANSFLG
	  ORA	A
	  JZ	MDORIG
	  CALL	MILP
	  DB	'Auto-answer mode - ^C to abort',0
	  RET
MDORIG:	  CALL	MILP
	  DB	'Originate mode  -  auto-answer inhibited',0
	  RET
;
; Set dial processor
;
STTONE:	  MVI	B,'T'
	  JMP	SDIAL1
STPULSE:  MVI	B,'P'
SDIAL1:   LDA	TPULSE
	  CPI	B
	  JZ	TPSHOW
	  MOV	A,B
	  STA	TPULSE
	  CPI	'P'
	  MVI	A,01010000B	;PULSE DIAL
	  JZ	SDIAL2
	  MVI	A,01000000B	;TONE DIAL
SDIAL2:   STA	DIALWD
TPSHOW:	  LDA	DIALWD
	  ANI	00010000B
	  JZ	TPTONE
	  CALL	MILP
	  DB	'Pulse Dialing',0
	  RET
TPTONE:	  CALL	MILP
	  DB	'Tone Dialing',0	  
	  RET
;
; Set manual processor
;
MANUAL:	  MVI	C,SBLANK	;check for ORIG <or> ANSWER
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,MANTBL	;check for proper syntax
	  MVI	C,LOOKUP
	  CALL	MEX
	  PUSH	H		;match found, go do it!
	  RNC			;
	  POP	H		;no match: fix stack and
	  JMP	SETERR		;  print error
;
MANORIG:  MVI   A,00H
	  STA	ANSFLG		;SET ORIG FLAG
	  MVI   B,30
	  CALL  MTIME		;FORCE 3 SECOND WAIT FOR ORIGINATOR
	  CALL  MILP
	  DB    'Manual originate mode -- carrier tone sent',CR,LF,CR,LF,0
	  JMP	GOMAN
MANANS:   MVI   A,0FFH
	  STA	ANSFLG		;SET ANS FLAG
	  CALL  MILP
	  DB    'Manual answer mode -- carrier tone sent',CR,LF,CR,LF,0
GOMAN:	  CALL  MILP
	  DB    'Enter Terminal Mode at the next command prompt',CR,LF
	  DB	'to check status of the connection',CR,LF,CR,LF
	  DB	'To return to voice mode,',CR,LF
	  DB	'disconnect from within terminal mode <ESC N>,',CR,LF
	  DB	'or from the command line <DSC>',CR,LF,CR,LF,0
	  CALL	MDMON
OFF:	  MVI	A,00010000B	;GO OFFHOOK
	  OUT	PIODAT
	  MVI	B,10		;WAIT 1 SEC
	  CALL	MTIME
	  RET
;
; Manual originate / answer command table
;
MANTBL:   DB	'ORI','G'+80H		;MANUAL ORIGINATE MODE
	  DW	MANORIG
	  DB	'ANSWE','R'+80H		;MANUAL ANSWER MODE
	  DW	MANANS
	  DB	0
;
; Set delay processor
;
DELAY:	  MVI	C,EVALA
	  CALL	MEX
	  MOV	A,H
	  ORA	A
	  JNZ	SETERR
	  MOV	A,L
	  STA	NDELAY
DLSHOW:	  CALL	MILP
	  DB	'Answer Delay is ',0
	  LDA	NDELAY
	  MOV	L,A
	  MVI	H,0
	  MVI	C,DECOUT
	  CALL	MEX
	  CALL	MILP
	  DB	' seconds',0
	  RET
;
;	SET PARITY command: reset transmit/receive parity
;
;		Parity is controlled by bits 0 and 1 of
;		the byte sent to the SIO write-register
;		4 as follows:
;
;		   Parity	Bit 1	   Bit 0
;	             Off          -          0
;	 	     Odd	  0	     1
;		     Even	  1	     1
;
STPRTY:	  MVI	C,SBLANK	;check for parity code
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,PARTBL	;check for proper syntax
	  MVI	C,LOOKUP
	  CALL	MEX
	  PUSH	H		;match found, go do it!
	  RNC			;
	  POP	H		;no match: fix stack and
	  JMP	SETERR		;  print error
;
PROFF:	  LDA	REG4		;get register 4 byte
	  ANI	0FEH		;reset bit 0
	  JMP	PARTB1		;
PREVEN:	  LDA	REG4		;
	  ORI	003H		;set bits 0 & 1
	  JMP	PARTB1		;
PRODD:	  LDA	REG4		;
	  ORI	001H		;set bit 0
	  ANI	0FDH		;reset bit 1
PARTB1:	  STA	REG4		;
	  CALL	NITSIO		;re-initialize the USART
	  CALL	SHPRTY		;print the result
	  RET     		;
SHPRTY:	  CALL	MILP		;display parity
	  DB	'Parity:  ',TAB,' ',0
	  LDA	REG4		;
	  ANI	001H		;test bit 0
	  CPI	0		;if bit0=0 then parity off
	  JNZ	SHPRT1		;
	  CALL	MILP		;
	  DB	'Off',0		;
	  RET
SHPRT1:	  LDA	REG4		;
	  ANI	002H		;test bit 1
	  CPI	0		;if bit1=0 then parity odd
	  JNZ	SHPRT2		;
	  CALL	MILP		;
	  DB	'Odd',0		;
	  RET			;
SHPRT2:	  CALL	MILP		;
	  DB	'Even',0	;
	  RET
;
;	SET PARITY command table
;
PARTBL:	  DB	'OF','F'+80H	;"set parity off"
	  DW	PROFF
	  DB	'EVE','N'+80H	;"set parity even"
	  DW	PREVEN
	  DB	'OD','D'+80H	;"set parity odd"
	  DW	PRODD
	  DB	0		;<<== end of parity table
;
;	SET STOPBITS command: reset number of stop bits
;
;		The number of stop bits is controlled by bits
;		2 and 3 of the byte sent to the SIO write-
;		register 4, as follows:
;
;		    Stop bits	   Bit 3	Bit 2
;			1	     0            1
;		       1.5	     1		  0
;			2	     1		  1
;
;
STSTOP:	  MVI	C,SBLANK	;check for stop bits
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,STPTBL	;check for proper syntax
	  MVI   C,LOOKUP
	  CALL	MEX		;
	  PUSH	H		;match found, go do it!
	  RNC			;
	  POP	H		;no match: fix stack and
	  JMP	SETERR		;  print error
;
STOP01:	  LDA	REG4		;get register 4 byte
	  ANI	0F7H		;reset bit 3
	  ORI	004H		;set bit 2
	  JMP	STSTP1		;
STOP02:	  LDA	REG4		;
	  ORI	00CH		;set bits 2 and 3
	  JMP	STSTP1		;
STOP15:	  LDA	REG4		;
	  ORI	008H		;set bit 3
	  ANI	0FBH		;reset bit 2
STSTP1:	  STA	REG4		;
	  CALL	NITSIO		;
	  CALL	SHSTOP		;print the result
	  RET
SHSTOP:	  CALL	MILP		;display stop-bits
	  DB	'Stop bits:',TAB,' ',0
	  LDA	REG4		;
	  ANI	004H		;test bit 2
	  CPI	0		;if bit2=0 then 1.5
	  JNZ	SHSTP1		;
	  CALL	MILP		;
	  DB	'1.5',0		;
	  RET
SHSTP1:	  LDA	REG4		;
	  ANI	008H		;test bit 3
	  CPI	0		;if bit3=0 then 1
	  JNZ	SHSTP2		;
	  CALL	MILP		;
	  DB	'1',0		;
	  RET
SHSTP2:	  CALL	MILP		;
	  DB	'2',0		;
	  RET
;
;	SET STOPBITS command table
;
STPTBL:	  DB	'1'+80H		;"set stop 1"
	  DW	STOP01
	  DB	'2'+80H		;"set stop 2"
	  DW	STOP02
	  DB	'1.','5'+80H	;"set stop 1.5"
	  DW	STOP15
	  DB	0		;<<== End of stop-bits table
;
;	SET LENGTH command: set bits per character
;
;		The number of bits per character is controlled for
;		the receiver circuit by bits 6 and 7 of the byte
;		sent to the SIO write-register 3 and for the trans-
;		mitter circuit by bits 5 and 6 of the byte sent to
;		the SIO write-register 5.  The assumption has been
;		made here that both transmission and reception will
;		be carried on at the same number of bits per charac-
;		ter.  The bit configurations are shown for register
;		3 only, but are the same for register 5:
;
;		    BPC		Bit 7		Bit 6
;		     5		  0		  0
;		     6		  1   		  0
;		     7		  0		  1
;		     8		  1		  1
;
STBITS:	  MVI	C,SBLANK	;check for bits/char
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,BITTBL	;check for proper syntax
	  MVI	C,LOOKUP
	  CALL	MEX
	  PUSH	H		;match found, go do it!
	  RNC			;
	  POP	H		;no match: fix stack and
	  JMP	SETERR		;  print error
;
BIT5:	  LDA	REG3		;
	  ANI	0BFH		;reset bit 6
	  ANI	07FH		;reset bit 7
	  STA	REG3		;
	  LDA	REG5		;
	  ANI	0DFH		;reset bit 5
	  ANI	0BFH		;reset bit 6
	  JMP	STBTS1		;
BIT6:	  LDA	REG3		;
	  ANI	0BFH		;reset bit 6
	  ORI	080H		;set bit 7
	  STA	REG3		;
	  LDA	REG5		;
	  ANI	0DFH		;reset bit 5
	  ORI	040H		;set bit 6
	  JMP	STBTS1		;
BIT7:	  LDA	REG3		;
	  ORI	040H		;set bit 6
	  ANI	07FH		;reset bit 7
	  STA	REG3		;
	  LDA	REG5		;
	  ORI	020H		;set bit 5
	  ANI	0BFH		;reset bit 6
	  JMP	STBTS1		;
BIT8:	  LDA	REG3		;
	  ORI	040H		;set bit 6
	  ORI	080H		;set bit 7
	  STA	REG3		;
	  LDA	REG5		;
	  ORI	020H		;set bit 5
	  ORI	040H		;set bit 6
STBTS1:	  STA	REG5		;
	  CALL	NITSIO		;
	  CALL	SHBITS		;print the result
	  RET
SHBITS:	  CALL	MILP		;display bits/char
	  DB	'Bits/char:',TAB,' ',0
	  LDA	REG5		;
	  ANI	040H		;test bit 6
	  CPI	0		;if bit6=0 then 6 bpc
	  JNZ	SHBTS2		;
	  LDA	REG5		;
	  ANI	020H		;test bit 5
	  CPI	0		;if bit5=0 then 5 bpc
	  JNZ	SHBTS1		;
	  CALL	MILP		;
	  DB	'5',0		;
	  RET			;
SHBTS1:	  CALL	MILP		;
	  DB	'7',0		;
	  RET			;
SHBTS2:	  LDA	REG5		;
	  ANI	020H		;test bit 5
	  CPI	0		;if bit5=0 then 6 bpc
	  JNZ	SHBTS3		;
	  CALL	MILP		;
	  DB	'6',0		;
	  RET			;
SHBTS3:	  CALL	MILP		;
	  DB	'8',0		;
	  RET
;
;	SET LENGTH command table
;
BITTBL:	  DB	'5'+80H		;"set bits 5"
	  DW	BIT5
	  DB	'6'+80H		;"set bits 6"
	  DW	BIT6
	  DB	'7'+80H		;"set bits 7"
	  DW	BIT7
	  DB	'8'+80H		;"set bits 8"
	  DW	BIT8
	  DB	0		;<<== end of bpc table
;
;
; Dialing routine
;
DIAL:     CPI	254		;START DIAL?
	  JZ	STDIAL		;JUMP IF SO
	  CPI	255		;END DIAL?
	  JZ	ENDIAL		;JUMP IF SO
	  CPI	','		;SMARTMODEM PAUSE COMMAND
	  JNZ	CKCAR		;IF NOT, CONTINUE
	  MVI	B,20		;DELAY 2 SECONDS
	  CALL	MTIME
	  RET
CKCAR:	  CPI	'T'		;CHANGE TO TONE DIALING?
	  JNZ	CKCAR1		;NOPE
	  CALL	TONE		;YEP, SET TONE DIALWD
	  JMP	CKCAR2		;SEND IT OUT
CKCAR1:	  CPI	'P'		;CHANGE TO PULSE DIALING?
	  JNZ	CKCAR3		;NOPE
	  CALL	PULSE		;YEP, SET PULSE DIALWD
CKCAR2:	  OUT	PIODAT		;SEND IT OUT
	  RET
CKCAR3:	  CPI	'9'+1		;DIGITS ARE 0-9
	  RNC			;TOO BIG...
	  SUI	'0'
	  RC			;TOO SMALL...
	  STA	DIGIT		;SAVE FOR INTERRUPT ROUTINE
	  PUSH	PSW		;SAVE DIGIT ON STACK TOO
	  LDA	DIALWD		;TONE/PULSE ON-HOOK
	  ANI	10111111B	;OFF HOOK MASK
	  OUT	PIODAT		;SEND IT OUT
	  POP	B		;GET DIGIT BACK
	  ORA	B		;OR IT WITH OFF HOOK & TONE/PULSE
	  OUT	PIODAT		;SEND DIGIT TO DIAL
	  NOP ! NOP ! NOP	;DELAY 3 US
	  ORI	10000000B	;DIGIT READY MASK
	  OUT	PIODAT		;SEND DIGIT READY
	  PUSH	PSW
	  MVI	B,1		;WAIT 100 MS
	  CALL	MTIME
	  POP	PSW
	  ANI	01111111B	;DIGIT NOT READY MASK
	  OUT	PIODAT		;LATCH DIGIT BUFFER
	  HALT			;WAIT FOR PIO STROBE VIA INTERRUPT
;
;  Interrupt service routine
;
INTERR:	  LDA	DIALWD
	  ANI	00010000B
	  MVI	B,2		;200 MS DELAY FOR TONE DIAL
	  JZ	IR1
	  LDA	DIGIT		;GET DIGIT FOR PULSE DELAY
	  ORA	A		;IS IT ZERO?
	  JNZ	ADLY1		;JUMP IF NOT
	  MVI	A,10		;IF ZERO, SET FOR 10 PULSES
ADLY1:	  ADI	10		;ADD INTER-DIGIT PAUSE
	  MOV	B,A
IR1:	  CALL	MTIME
	  DB	0EDH,4DH	;Z80: RETI
;
STDIAL:	  LXI	H,INTERR	;GET INTERRUPT ADDRESS
	  SHLD	0086H		;LOAD IT AT INTERRUPT VECTOR ADDRESS
	  DB	0EDH,05EH	;Z80: IM2, SET VECTORED INTERRUPT 
	  XRA	A
	  DB	0EDH,47H	;Z80: LD I,A, SET HIGH ORDER BYTE TO ZERO
	  EI			;ENABLE INTERRUPTS
	  CALL	MDMSQ		;TURN OFF MODEM
	  CALL	OFF		;GO OFF-HOOK
	  RET
;
ENDIAL:	  DI
	  MVI	A,00010000B	;OFF-HOOK, PULSE MODE
	  OUT	PIODAT
	  LDA	NDELAY		;GET DELAY VALUE
	  MOV	C,A
WTLP:	  PUSH	B		;SAVE DELAY COUNTER
	  MVI	B,10		;1 SEC DELAY
	  CALL	MTIME
	  MVI	C,CHEKCC	;WAS CTRL-C HIT?
	  CALL	MEX		
	  POP	B		;GET DELAY COUNTER BACK
	  JZ	CTRC		;IF CTRC, GO TO ABORT
	  CALL	INCTL1		;GET MOD CTRL PORT
	  ANI	08H		;CHECK DCD
	  JZ	NOTYET		;DCD=0, THEN NO ANSWER
	  LDA	ANSFLG		;TEST MODE FLAG (ANS OR ORIG)
	  ORA	A		;IF IN ANSWER MODE, MODEM IS ALREADY ON
	  JZ    TURNON
	  CALL	MILP
	  DB	CR,LF,CR,LF,'Carrier detected......'
	  DB	07H
	  DB	CR,LF,'Enter Terminal mode at the command prompt',CR,LF,LF,0
	  JMP	IMCNCT
TURNON:	  CALL	MDMON		;DCD=1, CONNECT, TURN ON MODEM
IMCNCT:	  MVI	A,0		;RETURN CONNECT CODE
	  RET
NOTYET:	  DCR	C
	  JNZ	WTLP
	  CALL	DISCON
	  MVI	A,2		;RETURN TIMEOUT CODE
	  RET
CTRC:	  CALL	DISCON
	  MVI	A,3		;RETURN ABORT CODE
	  RET
;
MDMSQ:	  MVI	A,5		;SETS MODEM OFF
	  OUT	INTCT1
	  LDA	ANSFLG
	  ORA	A
	  JNZ	MSQ1
	  LDA   REG5
  	  ANI	01111111B	;ORIG MODE,TX SQUELCH ON
	  ORI	00001000B
	  JMP	MSQ2
MSQ1:	  LDA   REG5
     	  ORI	10001000B	;ANS MODE, TX SQUELCH ON
MSQ2:	  OUT	INTCT1
	  RET
;
MDMON:	  MVI	A,5		;SETS MODEM ON
	  OUT	INTCT1
	  LDA	ANSFLG
	  ORA	A
	  JNZ	MON1
	  LDA   REG5
	  ANI	01111111B	;ORIG MODE,TX SQUELCH OFF
	  ORI   00001010B
	  JMP	MON2
MON1:	  LDA   REG5
          ORI   10001010B	;ANS MODE, TX SQUELCH OFF
MON2:	  OUT	INTCT1
	  RET
;
MILP:	  MVI	C,ILP
	  JMP	MEX
	  RET
;
MTIME:	  MVI	C,TIMER
	  JMP	MEX
	  RET
;
COMMA:	  CALL	MILP
	  DB	', ',0
	  RET
;
CRLF:	  CALL	MILP
	  DB	CR,LF,0
	  RET
;
MDMSEL:	  LDA	EXTMDM
	  ORA	A
	  RET
;
;==========================================================================
;                            Data Area
;==========================================================================
;
; Default UART parameters 
;
REG0:	  DB	00011000B	;RESET CHANNEL A
REG3:	  DB	11000001B	;ENABLE RECEIVE AT 8 BITS/CHAR
REG4:	  DB	01000100B	;NO PARITY, 1 STOP BIT, CLOCK X16
REG5:	  DB	01101000B	;INTERNAL MDM CTRL REGISTER 5
;
; Miscellaneous Default Data
;
DIALBF:	  DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	  DS	2		;DIAL POSITION POINTER
EOSMSG:	  DB	17H,'$'		;CLEAR TO END-OF-SCREEN
CLSMSG:	  DB	1AH,'$'		;CLEAR WHOLE SCREEN
DIALWD:	  DB	01000000B	;PULSE/TONE DIAL WORD
DIGIT	  DB	0		;SAVE DIALED DIGIT
MSPDSV:	  DB	0		;SAVE EXTERNAL MODEM MSPEED
DFBAUD:	  DB	5		;5: 300, 6: 600, 7: 1200, 0EH: 9600
EXTMDM:	  DB	0FFH		;0: INTERNAL    - 0FFH: EXTERNAL
;
ANSFLG:	  DB	0		;0: ORIGINATE   - 0FFH: ANS
NDELAY:	  DB	30		;NO. SECONDS FOR ANSWER
;
	  END
