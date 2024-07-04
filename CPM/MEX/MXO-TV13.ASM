;     Title  'MEX Overlay for the TeleVideo Computer Version 1.3'
;
REV	EQU	13		;OVERLAY REVISION LEVEL
;
;
;  MEX Overlay for TeleVideo TS-802H Computers, use MXM-2400
;  external overlay with this one to support SSET commands.
;
;  A full-featured SET command processor is implemented.
;  The following table outlines the SET command options:
;
;	SET Command
;
;	BAUD <RATE>			Set modem to Baud rate specified.
;					Baud rates supported are 110, 300,
;					600, 1200, 2400, 4800, 9600, 19200
;
;	PARITY                          Set Parity to Odd, Even, or Off
;	STOPBITS                        Set number of Stop Bits to 1, 1.5, 2
;	LENGTH 				Set word length to 5, 6, 7, 8
;
;  This overlay includes the smartmodem dialing routine from
;  MXO-SM13.ASM by Ron Fowler which has been slightly modified
;  to allow programmable delay for answer.  (Note that this is
;  different from the "ATS7=nn".).
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
;  08/16/85 1.3  Stripped out Smartmodem stuff so overlay can be
;		 used with MXM-2400 overlay for USR/Hayes 2400s.
;					-- Kim Levitt
;
;  12/19/84 1.0  Created new Televideo overlay from MXO-KPS3 overlay
;		 Fixed break bug while I was at it..
;					-- Kim Levitt
;
;  Credits:
;
;  M7KP-1 overlay structure by Irv Hoff
;  Parity, Length and Stopbits routines by Norm Saunders
;  MXO-KP overlay structure by John Smith
;  Art work by Terry Carroll
;  Bug fix/feature added by Kim Levitt
;  Based on an idea by an inspired hacker
;  Music by John Williams
;  Directed by Stanley Kubrick
;
;------------------------------------------------------------
;
; Miscellaneous equates
;
NO	EQU	0
YES	EQU	0FFH
;
TPA	EQU	100H
;
CR	EQU	13
LF	EQU	10
TAB	EQU	9
;
; Televideo port definitions
;
EXPORT	EQU	20H		;base external port
EXTCT1	EQU	EXPORT+2	;external modem status port
EXTDAT	EQU	EXPORT		;external modem data port
BAUDRP	EQU	08H		;external modem baud rate port
;
; Z80 SIO bit definitions
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
DCONIO	EQU	6		;BDOS Direct Console IO function #
DCONIN	EQU	0FFH		;BDOS DCONIO Flag for input
BDOS	EQU	5		;BDOS Function caller
;
;
	ORG	TPA		;we begin
;
	DS	3		;MEX has a JMP START here
;
	DS	2		;not used by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (Used by this overlay)
CLOCK:	DB	46		;clock speed x .1, up to 25.5 mhz.
MSPEED:	DB	6		;sets display time for sending a file
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
DIALV:	RET!NOP!NOP		;need MXM overlay for modem for this
DISCV:	JMP	DISCON
GOODBV:	JMP	GOODBYE		;called before exit to CP/M
INMODV:	JMP	NITMOD		;initialization. Called at cold-start
NEWBDV:	JMP	PBAUD		;set baud rate
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
;------------------------------------------------------------
;
; end of fixed area
;
;------------------------------------------------------------
;
; Low level modem routine area
;
INC:	MVI	A,10H
	OUT	EXTCT1
	IN	EXTCT1
	RET
;
IND:	IN	EXTDAT
	RET
;
OUTD:	OUT	EXTDAT
	RET
;
; Print out the overlay version
;
SYSVER:	  CALL	MILP
	  DB	'TeleVideo TS-802H Overlay -- Version '
	  DB	REV/10+'0'
	  DB	'.'
	  DB	REV MOD 10+'0'
	  DB	CR,LF,CR,LF
	  DB    0
	  RET
;
; Break, disconnect and goodbye routines
;
SBREAK:   MVI	A,5
	  OUT	EXTCT1
	  LDA	REG5
	  ORI	9AH		;set break + RTS/DTR/TXEN
 	  OUT	EXTCT1
	  MVI	B,3		;DELAY 300 MS.
	  CALL  MTIME
	  MVI	A,5		;then re-address WR5
	  OUT	EXTCT1
	  LDA	REG5		;get current REG5 values
	  OUT	EXTCT1		;and restore/stop break
	  RET
;
; Disconnect Routine
;
DISCON:
	  MVI	A,5
	  OUT	EXTCT1		;SEND TO THE STATUS PORT
	  MVI	A,68H		;TURN OFF DTR/RTS
	  OUT	EXTCT1
	  MVI	B,10		;DELAY 1 SEC.
	  CALL  MTIME
	  MVI	A,5
	  OUT	EXTCT1
	  MVI	A,0EAH		;TURN 'EM BACK ON AGAIN
	  OUT	EXTCT1
	  RET
;
; GOODBYE routines are called by MEX prior to exit to CP/M
;
GOODBYE:  RET			;NOTE: EXIT TO CP/M WITH NO CHANGE TO
				;CONNECT STATUS OR SETTINGS (PARITY, ETC)
;
; Initialize RS-232 port, Smartmodem, and default modes.
;
NITMOD:   CALL	INC		;SEE IF MODEM IS CONNECTED, I.E., RETURNING
	  ANI	08H		;   TO ACTIVE MODEM FROM CPM
	  RNZ			;SKIP IF CONNECTED
          CALL  NITSIO
	  LDA	MSPEED		;Get default baud rate
	  CALL	PBAUD		;Set default baud rate
	  RET			;Return
;
;	Initialize the Zilog SIO chip
;
NITSIO:	  MVI   A,00H		;Select reg. 0
	  OUT   EXTCT1
	  LDA	REG0		;Command byte
	  OUT   EXTCT1
	  MVI	A,04H		;Select reg. 4
	  OUT   EXTCT1
	  LDA	REG4		;Receive/transmit control byte
	  OUT   EXTCT1
	  MVI	A,03H		;Select reg. 3
	  OUT   EXTCT1
	  LDA	REG3		;Receiver logic byte
	  OUT   EXTCT1
	  MVI	A,05H		;Select reg. 5
	  OUT   EXTCT1
	  LDA	REG5		;Transmitter logic byte
	  OUT   EXTCT1
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
	  CALL  CRLF
	  RET
SETEMS:	  DB	CR,LF,'SET command error',CR,LF,'$'
;
; Argument table
;
CMDTBL:   DB	'?'+80H			; HELP
	  DW	SETHELP
	  DB	'BAU','D'+80H		; SET BAUD
	  DW	STBAUD
	  DB	'PARIT','Y'+80H		; SET PARITY
	  DW	STPRTY
	  DB	'STOPBIT','S'+80H	; SET STOPBITS
	  DW    STSTOP
	  DB	'LENGT','H'+80H		; SET LENGTH
	  DW	STBITS
	  DB	0			;TABLE TERMINATOR
;
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL  MILP
	  DB	CR,LF
	  DB	'SET values:',CR,LF,0
	  CALL	CRLF
	  CALL	BDSHOW
	  CALL  CRLF
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
	  DB	CR,LF,'SET PARITY    - OFF, EVEN or ODD'
	  DB	CR,LF,'SET STOPBITS  - 1, 1.5 or 2'
	  DB	CR,LF,'SET LENGTH    - 5, 6, 7 or 8'
	  DB	CR,LF,'SET BAUD      - 300, 450, 600, 1200, 2400, '
	  DB	'4800, 9600, 19200'
	  DB	CR,LF,CR,LF,0
	  RET
;
; "SET BAUD" processor
;
STBAUD:	  MVI	C,BDPARS	;FUNCTION CODE: PARSE A BAUDRATE
	  CALL	MEX		;LET MEX LOOK UP CODE
	  JC	SETERR		;JUMP IF INVALID CODE
	  CALL	PBAUD		;NO, TRY TO SET IT
	  JC	SETERR		;IF NOT ONE OF OURS, BOMB OUT
BDSHOW:	  LDA	MSPEED		;GET CURRENT BAUD RATE
	  MVI	C,PRBAUD	;LET MEX PRINT IT
	  CALL	MEX
	  RET 
;
; This routine sets baud rate passed as MSPEED code in A.
; Returns CY=1 if baud rate not supported.
;
PBAUD:	  PUSH	H		;DON'T ALTER ANYBODY
	  PUSH	D
	  PUSH 	B
	  MOV	E,A		;MSPEED CODE TO DE
	  MVI	D,0
	  LXI	H,BAUDTB	;OFFSET INTO TABLE
	  DAD	D
	  MOV	A,M		;FETCH CODE
	  ORA	A		;0 MEANS UNSUPPORTED CODE
	  STC			;PREP CARRY IN CASE UNSUPPORTED
	  JZ	PBEXIT		;EXIT IF BAD
	  PUSH	PSW		;NO, SET THE RATE
	  MVI	A,47H
	  OUT	BAUDRP
	  POP	PSW
	  OUT	BAUDRP
	  MOV	A,E		;GET MSPEED CODE BACK
	  STA	MSPEED		;SET IT
	  ORA	A		;RETURN NO ERRORS
PBEXIT:	  POP	B
	  POP	D
	  POP	H
	  RET
;
BAUDTB:	  DB	0H		;110 (not supported)
	  DB	80H		;300
	  DB	55H		;450
	  DB	40H		;600
	  DB	0		;710 (not supported)
	  DB	20H		;1200
	  DB	10H		;2400
	  DB	08H		;4800
	  DB	04H		;9600
	  DB	02H		;19200 
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
	  RET
;
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
; General utility routines
;
MILP:	  MVI	C,ILP		;IN-LINE PRINT
	  JMP	MEX
	  RET
;
MTIME:	  MVI	C,TIMER		;MEX TIMER
	  JMP	MEX
	  RET
;
CRLF:	  CALL	MILP		;PRINT CARRIAGE RETURN, LINE FEED
	  DB	CR,LF,0
	  RET
;
;==========================================================================
;                            Data Area
;==========================================================================
;
; Default UART parameters (Initalized for External RS-232)
;
REG0:	  DB	00011000B	;RESET CHANNEL A
REG3:	  DB	11000001B	;ENABLE RECEIVE AT 8 BITS/CHAR
REG4:	  DB	01000100B	;NO PARITY, 1 STOP BIT, CLOCK X16
REG5:	  DB	11101010B	;ENABLE TRANSMIT AT 8 BITS/CHAR
;
; Miscellaneous Default Data
;
EOSMSG:	  DB	17H,'$'		;CLEAR TO END-OF-SCREEN
CLSMSG:	  DB	1AH,'$'		;CLEAR WHOLE SCREEN
;
	  END
