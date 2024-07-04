;     Title  'MEX Overlay for Kaypros Version SM 4.0'
;
REV	EQU	40		;OVERLAY REVISION LEVEL
;
;
;  MEX Overlay for Kaypro Computers, external smartmodems,
;  either Anchor or Hayes-compatible.
;
;  A full-featured SET command processor is implemented.
;  The following table outlines the SET command options:
;
;		
;	SET Command
;
;	ANCHOR				Sets modem to respond to
;					Anchor modem commands; although
;					Anchor modems are considered Hayes
;					compatible, there ARE a few
;					differences which require special
;					processing considerations.
;
;	DELAY <N>			Number of seconds to wait before
;					aborting a call in progress
;
;	BAUD <RATE>			Set modem to Baud rate specified.
;					Baud rates supported are 110, 300,
;					600, 1200, 2400, 4800, 9600, 19200
;
;	ORIG                            Set modem to Originate mode
;	ANSWER                          Set modem to Auto-answer mode
;	TONE                            Set modem to Tone dialing
;	PULSE                           Set modem to Pulse dialing
;	MONITOR				Turn Hayes monitor ON
;	QUIET				Turn Hayes monitor OFF
;	PARITY                          Set Parity to Odd, Even, or Off
;	STOPBITS                        Set number of Stop Bits to 1, 1.5, 2
;	LENGTH 				Set word length to 5, 6, 7, 8
;
;	MANUAL ORIG <or> ANSWER		Place modem in active state and
;					generate Answer or Originate
;					carrier tone
;
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
;  12/20/84 4.0  Fixed bugs in send break and initialization routines.
;					       -- Kim Levitt
;
;  11/25/84 3.0  Added SILENT option to quiet that damn beep-beep-
;		 beep while dialing out. Speaker will come on at
;	         end of dialing.
;					       -- Kim Levitt
;
;  9/19/84  2.0  Fixed bug in DISCON routine that left DTR/RTS off,
;		 added "soft" abort (any key except ^C) to abort a
;		 CALL in progress, but not repeats or next CALL cmds.
;					       -- Kim Levitt
;
;  9/9/84   1.0  The universal Kaypro overlay distributed previously
;		 combined support for both the internal modem on the 4'84
;		 and external smartmodems.  This overlay supports external
;	 	 smartmodems only, and thus provides more flexibility for
;		 expansion and adaptability to new MEX releases.  The only
;		 additional feature of this overlay is support for 
;		 entering Terminal mode via generation of manual Originate
;		 or Answer carrier tones.  Clarity of documentation for
;                the SET command has also been improved.
;						Terry Carroll
;
;
;  Credits:
;
;  M7KP-1 overlay structure by Irv Hoff
;  Smartmodem dialing routine by Ron Fowler
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
; Silent dial option:
;
SILENT	EQU	YES		;if YES, speaker is silenced during dial
;
; (NOTE: This may not work on all "smart" modems, it works on the
;  Hayes.. Set it to NO if it doesn't dial out ok...)
;
; Kaypro port definitions
;
EXPORT	EQU	04H		;base external port
EXTCT1	EQU	EXPORT+2	;external modem status port
EXTDAT	EQU	EXPORT		;external modem data port
BAUDRP	EQU	00H		;external modem baud rate port
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
CLREOS:	LXI	D,EOSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
;
CLS:	LXI	D,CLSMSG
	MVI	C,PRINT
	CALL	MEX
	RET
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
	  DB	'KAYPRO Overlay --- Version SM'
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
	  ORI	9AH		;Send a break
 	  OUT	EXTCT1
	  MVI	B,3		;DELAY 300 MS.
	  CALL  MTIME
	  MVI	A,5
	  OUT	EXTCT1
	  LDA	REG5
	  OUT	EXTCT1		;stop break
	  RET
;
; Disconnect Routine
;
DISCON:	  LDA	MODMTYP
	  ORA   A
	  JZ	DISCONH
;
; Disconnect Anchor Modem.
; Anchor does not respond to DTR so the only way to disconnect is through
; standard Smartmodem disconnect commands
;
DISCONA:  MVI	B,20	
	  CALL  MTIME		;wait 2 seconds
	  LXI	H,SMATN		;send '+++'
	  CALL	SMSEND
	  MVI	B,40            ;wait 4 more seconds (Anchor is slow)
	  CALL  MTIME
	  LXI	H,SMDISC	;send 'ATH'
	  CALL	SMSEND
	  MVI	B,10		;wait 1 second
	  CALL  MTIME
	  RET
;
; Disconnect Hayes, etc.
;
DISCONH:  MVI	A,5
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
	  LDA	MSPEED		;GET DEFAULT BAUD RATE
	  CALL	PBAUD		;SET IT
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
	  DB	'ANCHO','R'+80H		; SET TO ANCHOR MODEM
	  DW	SETANCH
	  DB	'MANUA','L'+80H		; SET TO MANUAL MODE
	  DW	MANUAL
	  DB	0			;TABLE TERMINATOR
;
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL  MILP
	  DB	CR,LF
	  DB	'SET values:',CR,LF,0
	  CALL	CRLF
	  CALL  MDMSHOW
	  CALL	CRLF
	  CALL	MDSHOW
	  CALL	CRLF
	  CALL	TPSHOW
	  CALL	CRLF
	  CALL	BDSHOW
	  CALL  CRLF
	  CALL	DLSHOW
	  CALL	CRLF
	  CALL	MONSHO
	  CALL  CRLF
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
	  DB	CR,LF,'SET ANCHOR    - Set modem to respond to Anchor commands'
	  DB	CR,LF,'SET ORIG      - Set modem to Originate mode'
	  DB	CR,LF,'                (Disable auto-answer mode)'
	  DB	CR,LF,'SET ANSWER    - Set modem to auto-answer mode'
	  DB	CR,LF,'SET TONE      - Set modem for Touchtone dialing'
	  DB	CR,LF,'SET PULSE     - Set modem for Pulse dialing'
	  DB	CR,LF,'SET DELAY     - <N> seconds to wait for answer'
	  DB	CR,LF,'SET PARITY    - OFF, EVEN or ODD'
	  DB	CR,LF,'SET STOPBITS  - 1, 1.5 or 2'
	  DB	CR,LF,'SET LENGTH    - 5, 6, 7 or 8'
	  DB	CR,LF,'SET QUIET     - Turn Modem monitor OFF'
	  DB	CR,LF,'SET MONITOR   - Turn Modem monitor ON'
	  DB	CR,LF,'SET BAUD      - 110, 300, 600, 1200, 2400, '
	  DB	'4800, 9600, 19200'
	  DB	CR,LF,'SET MANUAL    - ORIG or ANSWER'
	  DB	CR,LF,'                Manually generate Answer or Originate '
	  DB    'carrier tone'
	  DB	CR,LF,CR,LF,0
	  RET
;
; SET ANCHOR processor
;
SETANCH:  MVI   A,0FFH
	  STA   MODMTYP
	  MVI   A,041H
	  STA	DIALAB
	  MVI   A,00H
	  STA   MONFLG
MDMSHOW:  LDA	MODMTYP
	  ORA	A
	  JZ	MDMSHOH	
	  CALL	MILP
	  DB	'Anchor Modem',0
	  RET
MDMSHOH:  CALL	MILP
	  DB	'Hayes-compatible Smartmodem',0
	  RET
;
; Set manual processor
; Note: manual mode does not change the auto-answer status of the modem
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
MANORIG:  MVI   B,30		;FORCE 3 SECOND DELAY ON ORIGINATE END
	  CALL  MTIME
	  LXI	H,SMATD		;SEND OUT 'ATD'
	  CALL	SINIT
	  CALL  MILP
	  DB    CR,LF,'Manual originate mode......',CR,LF
	  DB	'The modem is now awaiting detection of an answer tone......'
	  DB	CR,LF,CR,LF,0
	  JMP	GOMAN
MANANS:	  LXI	H,SMATA		;SEND OUT 'ATA'
	  CALL	SINIT
	  CALL  MILP
	  DB    CR,LF,'Manual answer mode -- carrier tone sent',CR,LF,CR,LF,0
	  JMP   GOMAN
;
SMATD:	  DB	'ATD',CR,0
SMATA:	  DB	'ATA',CR,0
;
GOMAN:	  MVI   B,20
	  CALL  MTIME
	  CALL  MILP
	  DB    'Enter Terminal Mode at the next command prompt',CR,LF
	  DB	'to check status of the connection',CR,LF,CR,LF
	  DB	'To return to voice mode,',CR,LF
	  DB	'disconnect from within terminal mode <ESC N>,',CR,LF
	  DB	'or from the command line <DSC>',CR,LF,CR,LF,0
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
	  OUT	BAUDRP		;IF OK, SET IT
	  MOV	A,E		;GET MSPEED CODE BACK
	  STA	MSPEED		;SET IT
	  ORA	A		;RETURN NO ERRORS
PBEXIT:	  POP	B
	  POP	D
	  POP	H
	  RET
;
BAUDTB:	  DB	02H		;110
	  DB	05H		;300
	  DB	0		;450 (not supported)
	  DB	06H		;600
	  DB	0		;710 (not supported)
	  DB	07H		;1200
	  DB	0AH		;2400
	  DB	0CH		;4800
	  DB	0EH		;9600
	  DB	0FH		;19200 
;
; SET MODEM STATUS TO ENABLE OR DISABLE AUTO-ANSWER
;
ORIG:	  XRA	A
	  STA	ANSFLG		;SET ORIG FLAG
	  LXI	H,SMO		;SEND OUT ATS0=0
	  CALL	SINIT
	  JMP	MDSHOW
;
SMO:	  DB	'ATS0=0',CR,0
SMA:	  DB	'ATS0=1',CR,0
;
ANS:	  MVI	A,0FFH
	  STA	ANSFLG		;SET ANS FLAG
	  LXI	H,SMA		;SEND OUT ATS0=1
	  CALL	SINIT
;
MDSHOW:	  LDA	ANSFLG
	  ORA	A
	  JZ	MDORIG		
	  CALL	MILP
	  DB	'Auto-answer mode',0
	  RET
MDORIG:	  CALL	MILP
	  DB	'Originate mode -- auto-answer disabled',0
	  RET
;
;
; Monitor control processor
;
QUIET: 	  XRA	A
	  STA	MONFLG
	  LXI	H,SMQT
	  CALL	SINIT
	  JMP	MONSHO
;
MONIT: 	  MVI	A,0FFH
	  STA	MONFLG
	  LXI	H,SMMON
	  CALL	SINIT
;
MONSHO:	  LDA	MONFLG
	  ORA	A
	  JZ	MONOFF
	  CALL	MILP
	  DB	'Monitor Speaker ON',0
	  RET
;
MONOFF:	  CALL	MILP
	  DB	'Monitor Speaker OFF',0
	  RET
;
SMQT:	  DB	'ATM0',CR,0
SMMON:	  DB	'ATM1',CR,0
;
; Set dial processor
;
STTONE:	  MVI	B,'T'
	  JMP	SDIAL1
;
STPULSE:  MVI	B,'P'
;
SDIAL1:   LDA	TPULSE
	  CPI	B
	  JZ	TPSHOW
	  MOV	A,B
	  STA	TPULSE
	  CPI	'P'
	  MVI	A,01010000B	;PULSE DIAL
	  JZ	SDIAL2
	  MVI	A,01000000B	;TONE DIAL
;
SDIAL2:   STA	DIALWD
;
TPSHOW:	  LDA	DIALWD
	  ANI	00010000B
	  JZ	TPTONE
	  CALL	MILP
	  DB	'Pulse Dialing',0
	  RET
TPTONE:	  CALL	MILP
	  DB	'Touchtone Dialing',0	  
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
; Smartmodem dialing routine from Ron Fowler's MXO-SM10.ASM
;
DIAL:	  LHLD	DIALPT		;FETCH POINTER
	  CPI	254		;START DIAL?
	  JZ	STDIAL		;JUMP IF SO
	  CPI	255		;END DIAL?
	  JZ	ENDIAL		;JUMP IF SO
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
STDIAL:   LXI	H,DIALBF	;SET UP BUFFER POINTER
	  SHLD	DIALPT
	  RET
;
; Here on an end-dial sequence
;
ENDIAL:
;
	   IF	SILENT
	  LDA	MONFLG		;check monitor speaker flag
	  ORA	A		;to see if on or off
	  JZ	LEAVOFF		;if off, leave it off
	  MVI	M,'M'		;if we silenced speaker to dial,
	  INX	H		;turn it on again
	  MVI	M,'1'
	  INX	H
LEAVOFF:
	   ENDIF
;
	  MVI	M,CR		;STUFF END-OF-LINE INTO BUFFER
	  INX	H		;FOLLOWED BY TERMINATOR
	  MVI	M,0
	  LDA	TPULSE		;GET OVERLAY'S TOUCH-TONE FLAG
;
	   IF	SILENT
	  STA	SMDIAL+5
	   ENDIF
;
	   IF	NOT SILENT
	  STA	SMDIAL+3	;PUT INTO STRING
	   ENDIF
;
	  LXI	H,SMDIAL	;POINT TO DIALING STRING
	  CALL	SMSEND		;SEND IT
;
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
	  MVI	C,DCONIO
	  MVI	E,DCONIN	;USE BDOS DIRECT CONSOLE INPUT FUNCTION
	  CALL	BDOS
	  POP	B
	  CPI	'C'-40H		;^C?
	  JNZ	SMNEXT		;IF NOT, JUMP
	  CALL	SMDMOFF		;YES, SHUT DOWN THE MODEM
	  MVI	A,3		;RETURN ABORT CODE
	  RET
SMNEXT:	  CPI	0		;ANY OTHER KEY
	  JNZ	SMTIMO		;YES, TREAT LIKE TIMEOUT
	  DCR	C		;NO
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
SMANAL:   PUSH  PSW
	  LDA	MODMTYP
	  ORA	A
	  JZ	SMANALH
;
; Analyze Modem response codes for Anchor modems.
; Anchor echoes the digits as they are being dialed.  The returned digits
; are interpreted as call return codes, shutting down the modem too early.
;
SMANALA:  POP   PSW
          MVI	B,0		;PREP CONNECT CODE
	  CPI	'C'		;"CONNECT"?
	  RZ
	  INR	B		;PREP BUSY CODE B=1
	  CPI	'B'
	  RZ
	  INR	B		;PREP NO CONNECT MSG B=2
	  CPI	'N'		;N=NO CONNECT
	  RZ
	  MVI	B,4		;PREP MODEM ERROR
	  CPI	'E'		;E=ERROR
	  RZ
	  JMP	WTLF
;
; Analyze Modem response codes for Hayes, etc.
;
SMANALH:  POP   PSW
          MVI	B,0		;PREP CONNECT CODE
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
SMDMOFF:  LDA	DIALAB
	  MOV	B,A
	  MVI	C,SNDCHR
	  CALL	MEX
	  MVI	B,20		;TWO SECOND WAIT TO SETTLE DOWN
	  CALL	MTIME
	  LDA	MODMTYP		;TEST MODEM TYPE
	  ORA	A
	  JZ	DISCON		;IF HAYES TYPE, JUMP TO DISCON
	  RET			;IF ANCHOR, RETURN
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
SMDIAL:	  DB	'AT'
;
	   IF	SILENT
	  DB	'M0'		;Turn off speaker during dialing
	   ENDIF
;
	  DB	'DT'		;Smartmodem dial prefix
;
DIALBF:	  DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	  DS	2		;DIAL POSITION POINTER
DIALWD:	  DB	01000000B	;PULSE/TONE DIAL WORD
DIGIT	  DB	0		;SAVE DIALED DIGIT
MSPDSV:	  DB	0		;SAVE EXTERNAL MODEM MSPEED
MONFLG:	  DB	0FFH		;0: MONITOR OFF - 0FFH: MONITOR ON
ANSFLG:	  DB	0		;0: ORIGINATE   - 0FFH: ANSWER
NDELAY:	  DB	30		;NO. SECONDS FOR ANSWER
MODMTYP:  DB    0		;0=HAYES, ETC., - 0FFH=ANCHOR MODEM
DIALAB:	  DB	CR		;CHARACTER TO USE TO ABORT DIAL SEQUENCE
;
SMATN:    DB	'+++',0		;Smartmodem online 'attention'
SMDISC:	  DB	'ATH',CR,0	;Smartmodem disconnect (used by Anchor)
SMINIT:   DB	'ATM1 S0=0 S7=60 Q0 X1',CR,0	;MODEM INIT STRING
;
EOSMSG:	  DB	17H,'$'		;CLEAR TO END-OF-SCREEN
CLSMSG:	  DB	1AH,'$'		;CLEAR WHOLE SCREEN
	  END
