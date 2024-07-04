;//////////////////////////////////////////////////////////////////////////////
;
     Title  'MEX Overlay for Advanced Digital Super Six / Super Quad SBC'
;
;//////////////////////////////////////////////////////////////////////////////
;
REV	EQU	10		; revision number * 10
;
;-----------------
;  
;  MEX Overlay for Advanced Digital Computers using the on board RS232 EIA
;  port.  The SBC utilizes a Z80 DART and a dual baud rate generator with
;  one oddball... the initial baudrate for the console and the serial port
;  is set with 7 Berg jumpers upon reset through a read only IO port. The 8th
;  bit is the side select bit for the floppy controller. The dual baud rate 
;  generator needs 8 bits to be set, 4 bits for each channel. This overlay
;  therefore brings in the jumpers, masks the side bit, extracts the default
;  console baud rate, or's in the modem baud rate and writes it out to the 
;  generator. Type ahaed buffer may be installed with this overlay ... the 
;  interrupt vector is not modified. In addition, A full-featured SET command 
;  processor is implemented to select the serial communications character-
;  istics of serial port 02, the modem port. A SET <cr> shows the current 
;  default settings, a SET ? brings up help and a SET XXXXXXX where XXXXXXX 
;  is defined in the following table will SET a new parameter.
;
;	Available SET Commands:
;
;	DELAY <n> (seconds)			BAUD <rate> 110-19.2K
;	ORIG (originate mode)			ANSWER	(mode)
;	TONE (dialing)				PULSE (dialing)
;	MONITOR (speaker on)			QUIET (speaker off)
;	PARITY (Odd, Even, None)		STOPBITS (1, 1.5, 2)
;	LENGTH (5, 6, 7, or 8)     	
;
;----------------
;
;  History:	
;
;  10/01/84 ...	MXO-AD10.ASM
;
;		Original version ... Tested with MEX112 ... Extractions 
;		from MXO-KP40.ASM ... Would appreciate a note of any 
;		problems be left on my RCPM MINIRBBS. 
;
;        	                        		John Sojak - SYSOP
;							Smokin Silicon RCPM
;							312 / 941-0049
;
;//////////////////////////////////////////////////////////////////////////////

;
;	conditionals
;
NO	EQU	0000
YES	EQU	NOT NO

;
;	msc constants
;
TPA	EQU	100H
CR	EQU	13
LF	EQU	10
TAB	EQU	9

;
;------------------------------------------------------------
;
; Advanced Digital port definitions
;
CTRLPT	EQU	03H		;serial status port
DATAPT	EQU	02H		;serial data port
BAUDRP	EQU	18H		;baud rate write port
BDJMPS	EQU	15H		;default jumper read port
;
; Advanced Digital bit definitions
;
MDRCVB	EQU	01H		;modem receive bit (DAV)
MDRCVR	EQU	01H		;modem receive ready
MDSNDB	EQU	04H		;modem send bit
MDSNDR	EQU	04H		;modem send ready bit
MDMDCD	EQU	08H		;modem data carrier detect 
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
MSPEED:	DB	5		;sets display time for sending a file
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
CLREOS:	
;	LXI	D,EOSMSG
;	MVI	C,PRINT
;	CALL	MEX
	RET
;
CLS:	
;	LXI	D,CLSMSG
;	MVI	C,PRINT
;	CALL	MEX
	RET
;------------------------------------------------------------
;
; end of fixed area
;
;------------------------------------------------------------
;
; input control/status port
;
INC:	MVI	A,10H
	OUT	CTRLPT
	IN	CTRLPT
	RET
;
; input data port
;
IND	IN	DATAPT
	RET
;
; output data port
;
OUTD:	OUT	DATAPT
	RET
;
; Print out the overlay version
;
SYSVER:	  CALL	MILP
	  DB	'Advanced Digital Overlay - Version '
	  DB	REV/10+'0'
	  DB	'.'
	  DB	REV MOD 10+'0'
	  DB	CR,LF
	  DB    0
	  RET
;
; Break, disconnect and goodbye routines
;
SBREAK:   MVI	A,5
	  OUT	CTRLPT
	  LDA	WR5
	  ORI	00010000B	;ENABLE BREAK
	  OUT	CTRLPT
	  MVI	B,3		;DELAY 300 MS.
	  CALL	MTIME
	  MVI	A,5
	  OUT	CTRLPT
	  LDA	WR5
	  ANI	11101111B	;TURN OFF BREAK
	  OUT	CTRLPT
	  RET
;
; Disconnect Routine
;
DISCON:   MVI	A,5
	  OUT	CTRLPT		;SEND TO THE STATUS PORT
	  MVI	A,68H		;TURN OFF DTR
	  OUT   CTRLPT
;
; GOODBYE routines are called by MEX prior to exit to CP/M
;
GOODBYE:  MVI	B,3		;DELAY 300 MS.
	  CALL  MTIME
	  MVI	A,5
	  OUT	CTRLPT		;SEND TO THE STATUS PORT
	  LDA	WR5
	  ORI	10000000B	;RAISE DTR
	  OUT	CTRLPT
	  RET
;
; Initialize RS-232 port, PIO port and default modes.
;
NITMOD: CALL	INC		;SEE IF CARRIER ie RETURNING TO MEX WITH
	ANI	MDMDCD		;   A CALL ACTIVE 
	RNZ			;SKIP IF CONNECTED

	LDA	DFBAUD		;GET THE DEFAULT BAUD RATE
	STA   	MSPDSV		;SEED THE MSPEED VALUE
	STA	MSPEED		;AND KEEP IT CURRENT
	CALL	PBAUD		;SET THE BAUD RATE

	LDA	WR5		;DEFAULT DTR AND CTS
	STA	REG5
 	CALL  	NITSIO		;INITIALIZE THE DART
	LDA	MONFLG		;GET MONITOR DEFAULT
	ORA	A
	MVI	A,'0'		;SPEAKER OFF
	JZ	NITMOD4
	MVI	A,'1'		;SPEAKER ON

NITMOD4:  STA	SMINIT+3	;PUT IT IN SMINIT STRING
	  LDA	ANSFLG		;GET MODE DEFAULT
	  ORA	A
	  MVI	A,'0'		;ORIGINATE
	  JZ	NITMOD5
	  MVI	A,'1'		;ANSWER

NITMOD5:  STA	SMINIT+8	;PUT IT IN SMINIT STRING
	  LXI	H,SMINIT

SINIT:	  CALL	SMSEND		;SEND THE INIT STRING

SMTLP1:	  MVI	C,INMDM		;WAIT FOR MODEM RESPONSE
	  CALL	MEX
	  JNC	SMTLP1		;EAT EVERYTHING UNTIL SILENCE FOR
	  RET			; 100 MSEC
;
;	Initialize the Zilog DART chip 
;
NITSIO:	  
NITSIO2:  MVI	A,00H		;Select reg. 0
	  CALL  OUTCTL1
	  LDA	REG0		;Command byte
	  CALL  OUTCTL1
	  MVI	A,04H		;Select reg. 4
	  CALL  OUTCTL1
	  LDA	REG4		;Receive/transmit control byte
	  CALL  OUTCTL1
	  MVI	A,03H		;Select reg. 3
	  CALL  OUTCTL1
	  LDA	REG3		;Receiver logic byte
	  CALL  OUTCTL1
	  MVI	A,05H		;Select reg. 5
	  CALL  OUTCTL1
	  LDA	REG5		;Transmitter logic byte
	  CALL  OUTCTL1
;
;           			;Save REG5 values for modem selected
NITEND:	  LDA  REG5
       	  STA  WR5		;Save external modem REG5
	  RET
;
OUTCTL1:  OUT   CTRLPT
	  RET
;
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
SETBAD:	  LXI	D,SETBMS
	  MVI	C,PRINT
	  CALL	MEX
	  RET
SETBMS:	  DB	CR,LF,'SET command not valid for modem',CR,LF,'$'
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
	  DB	'MONITO','R'+80H	; MONITOR ON
	  DW	MONIT
	  DB	'QUIE','T'+80H		; MONITOR OFF
	  DW	QUIET
	  DB	'BAU','D'+80H		; SET BAUD
	  DW	STBAUD
	  DB	'DELA','Y'+80H		; SET DELAY
	  DW	DELAY
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
	  DB	'Current settings:',CR,LF,0
	  CALL	CRLF
	  CALL	TPSHOW
	  CALL	CRLF
	  CALL	BDSHOW
	  CALL  CRLF
	  CALL	DLSHOW
	  CALL	CRLF
	  CALL	MONSHO
	  CALL	CRLF
	  CALL  SHPRTY
	  CALL	CRLF
	  CALL	SHSTOP
	  CALL	CRLF
	  CALL  SHBITS
	  CALL  CRLF
	  CALL  CRLF
	  RET
;
; "SET ?" processor
;
SETHELP:  CALL	MILP
	  DB	CR,LF,'SET ORIG'
	  DB	CR,LF,'SET ANSWER'
	  DB	CR,LF,'SET TONE'
	  DB	CR,LF,'SET PULSE'
	  DB	CR,LF,'SET DELAY     - <N> seconds'
	  DB	CR,LF,'SET PARITY    - OFF, EVEN or ODD'
	  DB	CR,LF,'SET STOPBITS  - 1, 1.5 or 2'
	  DB	CR,LF,'SET LENGTH    - 5, 6, 7 or 8'
	  DB	CR,LF,'SET QUIET     - Speaker OFF'
	  DB	CR,LF,'SET MONITOR   - Speaker ON'
	  DB	CR,LF,'SET BAUD      - 110, 300, 600, 1200, 2400, '
	  DB	'4800, 9600, 19200'
	  DB	CR,LF,CR,LF,0
	  RET
;
; "SET BAUD" processor
;
STBAUD:	  	MVI	C,BDPARS	;FUNCTION CODE: PARSE A BAUDRATE
	  	CALL	MEX		;LET MEX LOOK UP CODE
	  	JC	SETERR		;JUMP IF INVALID CODE
	  	CALL	PBAUD		;NO, TRY TO SET IT
	  	JC	SETERR		;IF NOT ONE OF OURS, BOMB OUT

BDSHOW:	  	LDA	MSPEED		;GET CURRENT BAUD RATE
	  	MVI	C,PRBAUD	;LET MEX PRINT IT
	  	CALL	MEX
	  	RET 
;
; This routine sets baud rate passed as MSPEED code in A.
; Returns CY=1 if baud rate not supported.
;
PBAUD:	  	PUSH	H		;DON'T ALTER ANYBODY
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
	  	STA	DFBAUD		;SAVE CURRENT RATE
	  	MOV	B,A		;SAVE THE NEW BAUD FOR A SEC
	  	IN	BDJMPS		;GET THE CURRENT CONSOLE BAUD 
	  	ANI	00001111b	;ISOLATE IT
	  	ORA	B		;AND MAKE A COMPOSITE WITH MODEM BAUD
	  	OUT	BAUDRP		;SET IT
	  	MOV	A,E		;GET MSPEED CODE BACK
	  	STA	MSPEED		;SET IT

PBEXIT:	  	POP	B
	  	POP	D
	  	POP	H
	  	RET
;
BAUDTB:	  	DB	020H		;110
	  	DB	050H		;300
	  	DB	00h		;450 (not supported)
	  	DB	060H		;600
	  	DB	00h		;710 (not supported)
	  	DB	070H		;1200
	  	DB	0A0H		;2400
	  	DB	0C0H		;4800
	  	DB	0E0H		;9600
	  	DB	0F0H		;19200 
;
; SET MODE PROCESSOR ---- SET MODEM PARAMETERS
;
ORIG:	  	XRA	A
	  	STA	ANSFLG		;SET ORIG FLAG
	  	LXI	H,SMO		;SEND OUT ATS0=0
	  	CALL	SINIT
		CALL	MILP
		DB	'Originate mode',0
		RET

;
SMO:	DB	'ATS0=0',CR,0
SMA:	DB	'ATS0=1',CR,0
;
ANS:	MVI	A,0FFH
	STA	ANSFLG		;SET ANS FLAG
	LXI	H,SMA		;SEND OUT ATS0=1
	CALL	SINIT
	CALL	MILP
	DB	'Answer mode',0
	RET
;
;
; Monitor control processor
;
QUIET:	  XRA	A
	  STA	MONFLG
	  LXI	H,SMQT
	  CALL	SINIT
	  JMP	MONSHO

MONIT:	  MVI	A,0FFH
	  STA	MONFLG
	  LXI	H,SMMON
	  CALL	SINIT

MONSHO:	  LDA	MONFLG
	  ORA	A
	  JZ	MONOFF
	  CALL	MILP
	  DB	'Speaker On',0
	  RET
MONOFF:	  CALL	MILP
	  DB	'Speaker Off',0
	  RET
SMQT:	  DB	'ATM0',CR,0
SMMON:	  DB	'ATM1',CR,0
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
	  DB	'Pulse Dial',0
	  RET
TPTONE:	  CALL	MILP
	  DB	'Tone Dial',0	  
	  RET
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
;		the byte sent to the DART write-register
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
;		2 and 3 of the byte sent to the DART write-
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
;		sent to the DART write-register 3 and for the trans-
;		mitter circuit by bits 5 and 6 of the byte sent to
;		the DART write-register 5.  The assumption has been
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
DIAL:	  LHLD	DIALPT		;FETCH POINTER
	  CPI	254		;START DIAL?
	  JZ	STDIAL1		;JUMP IF SO
	  CPI	255		;END DIAL?
	  JZ	ENDIAL1		;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
	  MOV	M,A		;PUT CHAR IN BUFFER
	  INX	H		;ADVANCE POINTER
	  SHLD	DIALPT		;STUFF PNTR
	  RET			;ALL DONE
;
; Here on a start-dial sequence
;
STDIAL1:  LXI	H,DIALBF	;SET UP BUFFER POINTER
	  SHLD	DIALPT
	  RET
;
; Here on an end-dial sequence
;
ENDIAL1:  MVI	M,CR		;STUFF END-OF-LINE INTO BUFFER
	  INX	H		;FOLLOWED BY TERMINATOR
	  MVI	M,0
	  LDA	TPULSE		;GET OVERLAY'S TOUCH-TONE FLAG
	  STA	SMDIAL+3	;PUT INTO STRING
	  LXI	H,SMDIAL	;POINT TO DIALING STRING
	  CALL	SMSEND		;SEND IT
WAITSM:	  MVI	C,INMDM
	  CALL	MEX		;CATCH ANY OUTPUT FROM THE MODEM
	  JNC	WAITSM		;LOOP UNTIL NO MORE CHARACTERS
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM.
;
RESULT:	  LDA	NDELAY		;GET DELAY COUNT
	  MOV	C,A
SMWLP:	  PUSH	B
	  MVI	B,1		;CHECK FOR A CHAR, UP TO 1 SEC WAIT
	  MVI	C,TMDINP	;DO TIMED INPUT
	  CALL	MEX
	  POP	B
	  JNC	SMTEST		;JUMP IF MODEM HAD A CHAR
	  PUSH	B		;NO, TEST FOR CONTROL-C FROM CONSOLE
	  MVI	C,CHEKCC
	  CALL	MEX
	  POP	B
	  JNZ	SMNEXT		;IF NOT, JUMP
	  CALL	SMDMOFF		;YES, SHUT DOWN THE MODEM
	  MVI	A,3		;RETURN ABORT CODE
	  RET
SMNEXT:	  DCR	C		;NO
	  JNZ	SMWLP		;CONTINUE
;
; NO MODEM RESPONSE WITHIN THE TIME SPECIFIED IN SET DELAY COMMAND
;
SMTIMO:	  CALL	SMDMOFF
	  MVI	A,2		;RETURN TIMEOUT CODE
	  RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
SMTEST:	  ANI	7FH		;IGNORE ANY PARITY
	  CALL	SMANAL		;TEST THE RESULT
	  JC	RESULT		;GO TRY AGAIN IF UNKNOWN RESPONSE
	  MOV	A,B		;A=RESULT 
	  PUSH	PSW		;SAVE IT
SMTLP:	  MVI	C,INMDM		;EAT ANY ADDITIONAL CHARS FROM SMARTMODEM
	  CALL	MEX
	  JNC	SMTLP		;UNTIL 100MS OF QUIET TIME
	  POP	PSW		;RETURN THE CODE
	  RET
;
; Analyze character returned from External Modem
;
SMANAL:	  MVI	B,0		;PREP CONNECT CODE
	  CPI	'C'		;"CONNECT"?
	  RZ
	  CPI	'1'		;NUMERIC VERSION OF "CONNECT"
	  RZ
	  CPI	'5'		;NUMERIC VERSION OF "CONNECT 1200"
	  RZ
	  INR	B		;PREP BUSY CODE B=1
	  CPI	'B'
	  RZ
	  INR	B		;PREP NO CONNECT MSG B=2
	  CPI	'N'		;N=NO CONNECT
	  RZ
	  CPI	'3'		;NUMERIC VERSION OF "NO CONNECT"
	  RZ
	  MVI	B,4		;PREP MODEM ERROR
	  CPI	'E'		;E=ERROR
	  RZ
	  CPI	'4'		;NUMERIC VERSION OF "ERROR"
	  RZ
;
; UNKNOWN RESPONSE, RETURN CARRY TO CALLER. BUT FIRST,
; FLUSH THE UNKNOWN RESPONSE LINE FROM THE MODEM.
;
WTLF:	  CPI	LF		;LINEFEED?
	  STC
	  RZ			;END IF SO
	  MVI	C,INMDM		;NO. GET NEXT CHAR
	  CALL	MEX
	  JNC	WTLF		;UNLESS BUSY, LOOP
	  RET
;
; Send string to the External Modem
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
; Shut down (disconnect) External Modem
;
SMDMOFF:  MVI	B,CR
	  MVI	C,SNDCHR
	  CALL	MEX
	  MVI	B,10		;ONE SECOND WAIT FOR HAYES, ETC
	  CALL	MTIME
	  JMP	DISCON		;MAKE SURE IT IS OFF
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
WR5: 	  DB	11101010B	;MDM CTRL REGISTER 5 (Initial value)
;
; Miscellaneous Default Data
;
SMDIAL:	  DB	'ATDT '		;Smartmodem dial prefix
DIALBF:	  DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	  DS	2		;DIAL POSITION POINTER
DIALWD:	  DB	01000000B	;PULSE/TONE DIAL WORD
DIGIT	  DB	0		;SAVE DIALED DIGIT
MSPDSV:	  DB	0		;SAVE EXTERNAL MODEM MSPEED
DFBAUD:	  DB	05		;0=110,1=300,3=600,5=1200,6=2400
				;7=4800,8=9600,9=19200 
MONFLG:	  DB	0FFH		;0: MONITOR OFF - 0FFH: MONITOR ON
ANSFLG:	  DB	0		;0: ORIGINATE   - 0FFH: ANS
NDELAY:	  DB	30		;NO. SECONDS FOR ANSWER
;
SMATN:    DB	'+++',0		;Smartmodem online 'attention'
SMDISC:	  DB	'ATH',CR,0	;Smartmodem disconnect 
SMINIT:   DB	'ATM1 S0=0 S7=60 X1',CR,0	;MODEM INIT STRING
;
EOSMSG:	  DB	17H,'$'		;CLEAR TO END-OF-SCREEN
CLSMSG:	  DB	1AH,'$'		;CLEAR WHOLE SCREEN
	  END
