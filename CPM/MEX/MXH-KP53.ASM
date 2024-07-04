	Title  'MexPlus Overlay for Kaypros Version 5.3'
;
REV	EQU	53		;OVERLAY REVISION LEVEL
;
;
;  MexPlus Hardware (MXH) Overlay for Kaypro Computers
;  using an external smartmodem.
;
;  NOTE: To fully implement MEXPLUS you need also get:
;
;    MXT-KP*.OVR     Kaypro termcap (video) overlay
;    MXM-SM*.OVR     Smartmodem dialing overlay
;    MXC-K484.OVR    For Kaypro Internal factory clock, or
;    MXC-LG10.OVR    Legacy KP10 clock overlay
;
;  MEXPLUS uses the following conventions:
;
;  MXH-*.OVR	Hardware overlay for computer
;  MXT-*.OVR	Terminal capability overlay
;  MXC-*.OVR	Real-time clock overlay for 8080/Z80 vers
;  MXM-*.OVR	Modem overlay
;
;  These overlays are available from The NightOwl Connection
;  if you are subscriber or thru The DatCOM Super System
;  (813) 937-3608  300/1200 bps (annual fee also req'd).
;
;  //////////////////////////////////////////////////////////
;
;  A full-featured SET command processor is implemented.
;  The following table outlines the SET command options:
;
;		
;	SET Command
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
;  History:
;  08/12/85   v5.3  Trimmed down the code, it was 7 bytes too long.
;		    Remember, this thing HAS to end by 0AFF!;  Also,
;		    all the Smartmodem code that's still here (I
;		    thought somebody removed all that???) induced me
;		    to do a new Kaypro overlay, MXH-KG10 (Kaypro Gen-
;		    eric), with no Smartmodem code.  I've been able
;		    to test it only on a couple of Kaypro models -- I
;		    think it should work for all -- I'd appreciate any
;		    feedback from people using the KG10 overlay.
;						--Ron Fowler
;
;  07/12/85   v5.2  Removed and rewote code for 'eye wash' as it made a
;		    nice generic kp overlay kp-video dependent. Changed
;		    code to enter mex's video attribute routines the way
;		    its supposed to be done. Also changed modem init to
;		    wait 30 sec before timout. Was hanging up prematurely
;		    on many long distance calls. 
;						    -- Mike Woodward
;
;  05/28/85   v5.1   Added some video 'eye-wash' to the console
;                    displays to make em look nicer.
;                                                    -- Steve Sanders
; 
;  05/26/84   v5.0   Modified MXO-KPS4 for MexPlus compatibility.
;					             -- Terry Carroll
;
;------------------------------------------------------------
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
;
; MEX service processor equates
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
; MEX TERMINAL OVERLAY VECTORS
CLS	EQU	140FH		;clear screen
ENTREV	EQU	1415H		;enter rev video
EXREV	EQU	1418H		;exit rev video
ENTBRT	EQU	141BH		;enter bright (exit dim?)
EXBRT	EQU	141EH		;exit bright (enter dim?)
;
PRINT	EQU	9		;BDOS/MEX print-string function call
;
BELL	EQU	7		;bell
TAB	EQU	9
CR	EQU	13		;carriage return
LF	EQU	10		;linefeed
ESC	EQU	1BH		;escape
YES	EQU	0FFH
NO	EQU	0
;
I8080	EQU	YES		;FOR TRANSLATOR - DO NOT CHANGE
I8086	EQU	NO
CPM	EQU	YES
PCDOS	EQU	NO
;
;
; ## The following JUMP instruction is necessary for MEXPLUS loadable overlays
;
	ORG	100H
	DB	0C3H		;##JMP INSTRUCTION (MEX 1.2)
;
; Change the clock speed to suit your system
;
	DS	2		;(for  "JMP   START" instruction)

	DB	NO		;yes=PMMI S-100 Modem			103H
	DB	YES		;yes=HAYES Smartmodem, no=non-PMMI	104H
TPULSE:	DB	'T'		;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:	DB	50		;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:	DB	5		;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:	DB	5		;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:	DB	5		;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:	DB	5		;number of DIR columns shown		10AH
SETFLG:	DB	YES		;yes=user-added Setup routine		10BH
SCRTST:	DB	YES		;Cursor control routine 		10CH
	DB	YES		;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKFLG:	DB	YES		;yes=change any file same name to .BAK	10EH
CRCDFL:	DB	YES		;yes=default to CRC checking		10FH
TOGCRC:	DB	YES		;yes=allow toggling of CRC to Checksum	110H
CVTBS:	DB	NO		;yes=convert backspace to rub		111H
TOGLBK:	DB	YES		;yes=allow toggling of bksp to rub	112H
ADDLF:	DB	NO		;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:	DB	YES		;yes=allow toggling of LF after CR	114H
	DB	YES		;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:	DB	YES		;yes=do not overwrite CCP		116H
	DB	NO		;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
	DB	YES		;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:	DB	YES		;yes=printer available on printer port	119H
XOFTST:	DB	NO		;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:	DB	NO		;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:	DB	YES		;yes=allow toggling of XOFF checking	11CH
IGNCTL:	DB	NO		;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:	DB	0		;for future expansion			11EH
EXITCHR	DB	'E'-40H		;^E = Exit to main menu			11FH
BRKCHR:	DB	'@'-40H		;^@ = Send 300 ms. break tone		120H
NOCONN:	DB	'N'-40H		;^N = Disconnect from the phone line	121H
LOGCHR:	DB	'L'-40H		;^L = Send logon			122H
LSTCHR:	DB	'P'-40H		;^P = Toggle printer			123H
UNSAVE:	DB	'R'-40H		;^R = Close input text buffer		124H
TRNCHR:	DB	'T'-40H		;^T = Transmit file to remote		125H
SAVCHR:	DB	'Y'-40H		;^Y = Open input text buffer		126H
EXTCHR:	DB	'^'-40H		;^^ = Send next character		127H
	DS	2		;unused by MEX				128H
;
;
; Low-level modem I/O routines.
;
INCTL1:	JMP	INCTRL		;in modem control port
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
;
OTDATA:	JMP	OUTDTA		;out modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non=PMMI
;
INPORT: JMP	INDATA		;in modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
;
; Bit-test routines. 
;
MASKR:	ANI MDRCVB      	;bit to test for receive ready
	RET
TESTR:	CPI MDRCVR      	;value of receive bit when ready
	RET
MASKS:	ANI MDSNDB      	;bit to test for send ready
	RET
TESTS:	CPI MDSNDR      	;value of send bit when ready
	RET
;
;
; ## Following are two new entrie points for MEXPLUS
; DCDTST returns data-carrier detect in A: 0 if no carrier
;  present, 0FFH if carrier is present, and 0FEH if overlay
;  doesn't know (i.e., doesn't support carrier detect)
; RNGDET works similarly for ring-detect.
;
DCDTST:	JMP	DCDVEC		;data carrier detect			154H
RNGDET:	JMP	RNGVEC		;ring-detect				157H
;
; End of MEXPLUS added vectors
;
	DB	0,0,0,0,0	;reserved space, assumed 0
;									15FH
SMDISC:	DS	3		;software disconnect (in smartmodem overlay)
;
	DS	3		;DIALV: not done here (maybe MXO-SM)	162H
DISCV:	JMP	DISCON		;disconnect (if not used, should be JMP SMDISC)
GOODBV:	JMP	GOODBYE		;					168H
INMODV:	JMP	NITMOD		;go to user written routine		16BH
	JMP	PBAUD		;NEWBDV					16EH
	RET 			;NOPARV					171H
	NOP
	NOP
	RET 			;PARITV					174H
	NOP
	NOP
SETUPV:	JMP	SETCMD		;					177H
	DS	3		;not used by MEX			17AH
VERSNV:	JMP	SYSVER		;					17DH
BREAKV:	JMP	SBREAK		;					180H
;
; Do not change the following six lines (they provide access to routines
; in MEX that are present to support MDM7 overlays -- they will likely
; be gone by MEX v2.0).
;
ILPRTV:	DS	3		;					183H
INBUFV	DS	3		;					186H
ILCMPV:	DS	3		;					189H
INMDMV:	DS	3		;					18CH
	DS	3		;					18FH
TIMERV	DS	3		;					192H
;
;
	ORG	200H		;## NEW BOUNDARY FOR MEX1.2
;------------------------------------------------------------
;
; end of fixed area
;
;------------------------------------------------------------
;
; Low level modem routine area
;
INCTRL:	MVI	A,10H
	OUT	EXTCT1
	IN	EXTCT1
	RET
;
INDATA:	IN	EXTDAT
	RET
;
OUTDTA:	OUT	EXTDAT
	RET
;
; Print out the overlay version
;
SYSVER:	  CALL  MILP
	  DB	CR,LF
	  DB	'KAYPRO MexPlus Overlay --- Version '
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
; ## return data carrier detect status
;      0    = no carrier
;      255  = carrier present
;      254  = we don't know (DCD not supported)
;
DCDVEC:	MVI	A,0FEH		;get status port
	RET			;return "we don't know" detect
;
; ## return ring-detect status:
;
;     0   =  not ringing
;     255 =  ring detected
;     254 =  we don't kno
;
RNGVEC:	MVI	A,0FEH		;return "we don't know"
	RET
;
; Disconnect Hayes, etc.
;
DISCON:   MVI	A,5
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
NITMOD:   CALL	INCTRL		;SEE IF MODEM IS CONNECTED, I.E., RETURNING
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
SETERR:	  CALL	ENTREV		;TERMINAL OVERLAY ENTER REV VIDEO
	  LXI	D,SETEMS
	  MVI	C,PRINT
	  CALL	MEX
	  CALL  EXREV		;TERMINAL OVERLAY EXIT REV VIDEO
	  CALL  CRLF
	  RET
SETEMS:	  DB	CR,LF,'=> SET command error <='
	  db	CR,LF,'$'
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
	  DB	'PARIT','Y'+80H		; SET PARITY
	  DW	STPRTY
	  DB	'STOPBIT','S'+80H	; SET STOPBITS
	  DW    STSTOP
	  DB	'LENGT','H'+80H		; SET LENGTH
	  DW	STBITS
	  DB	'MANUA','L'+80H		; SET TO MANUAL MODE
	  DW	MANUAL
	  DB	0			;TABLE TERMINATOR
;
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL  ENTREV			;TERMINAL OVERLAY ENTER REV VIDEO
	  CALL  MILP
	  DB	' Current SET values: '
	  db	CR,LF,0
	  CALL	EXREV			;TERMINAL OVERLAY EXIT REV VIDEO
	  CALL	CRLF
	  CALL	MDSHOW
	  CALL	TPSHOW
	  CALL	BDSHOW
	  CALL	MONSHO
	  CALL	CRLF
	  CALL  SHPRTY
	  CALL	SHSTOP
	  CALL  SHBITS
	  CALL  CRLF
	  CALL  CRLF
	  RET
;
; "SET ?" processor
;
SETHELP:  CALL  CLS
	  CALL	ENTREV
	  CALL	MILP
	  db	' Available SET Commands: '
	  db	CR,LF,0
	  CALL  EXREV
	  CALL  MILP
	  DB	CR,LF,'SET ORIG      - Set modem to Originate mode'
	  DB	CR,LF,'                (Disable auto-answer mode)'
	  DB	CR,LF,'SET ANSWER    - Set modem to auto-answer mode'
	  DB	CR,LF,'SET TONE      - Set modem for Touchtone dialing'
	  DB	CR,LF,'SET PULSE     - Set modem for Pulse dialing'
	  DB	CR,LF,'SET PARITY    - OFF, EVEN or ODD'
	  DB	CR,LF,'SET STOPBITS  - 1, 1.5 or 2'
	  DB	CR,LF,'SET LENGTH    - 5, 6, 7 or 8'
	  DB	CR,LF,'SET QUIET     - Turn Modem monitor OFF'
	  DB	CR,LF,'SET MONITOR   - Turn Modem monitor ON'
	  DB	CR,LF,'SET BAUD      - 300, 1200, 2400, 4800, 9600, 19200'
	  DB	CR,LF,'SET MANUAL    - ORIG or ANSWER'
	  DB	CR,LF,'                Manually generate Answer or Originate '
	  DB    'carrier tone'
	  DB	CR,LF,CR,LF,0
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
	  DB	'Modem now awaiting detection of an answer tone......'
	  DB	CR,LF,CR,LF,CR,LF,0
	  JMP	GOMAN
MANANS:	  LXI	H,SMATA		;SEND OUT 'ATA'
	  CALL	SINIT
	  CALL  MILP
	  DB    CR,LF,CR,LF,'Manual answer mode -- carrier tone sent',CR,LF
	  DB    CR,LF,0
	  JMP   GOMAN
;
SMATD:	  DB	'ATD',CR,0
SMATA:	  DB	'ATA',CR,0
;
GOMAN:	  MVI   B,20
	  CALL  MTIME
	  CALL  MILP
	  DB    'Enter Terminal Mode at next command prompt',CR,LF
	  DB	'to check status of connection',CR,LF,CR,LF
	  DB	'To return to voice mode,',CR,LF
	  DB	'disconnect from within terminal mode <ESC N>,',CR,LF
	  DB	'or from command line <DSC>',CR,LF,CR,LF,CR,LF,0
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
	  CALL  CRLF
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
	  DB	'Auto-answer mode',CR,LF,0
	  RET
MDORIG:	  CALL	MILP
	  DB	'Originate mode',CR,LF,0
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
	  DB	'Monitor Speaker ON',CR,LF,0
	  RET
;
MONOFF:	  CALL	MILP
	  DB	'Monitor Speaker OFF',CR,LF,0
	  RET
;
SMQT:	  DB	'ATM0',CR,0
SMMON:	  DB	'ATM1',CR,0
;
; Set dial processor
;
STTONE:	  MVI	A,'T'
	  STA   TPULSE
	  JMP	TPSHOW
;
STPULSE:  MVI	A,'P'
          STA	TPULSE
;
TPSHOW:	  LDA	TPULSE
	  CPI	54H
	  JZ	TPTONE
	  CALL	MILP
          DB	'Pulse Dialing',CR,LF,0
	  RET
TPTONE:	  CALL	MILP
	  DB	'Touchtone Dialing',CR,LF,0	  
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
	  DB	'Off',CR,LF,0	;
	  RET
SHPRT1:	  LDA	REG4		;
	  ANI	002H		;test bit 1
	  CPI	0		;if bit1=0 then parity odd
	  JNZ	SHPRT2		;
	  CALL	MILP		;
	  DB	'Odd',CR,LF,0	;
	  RET			;
SHPRT2:	  CALL	MILP		;
	  DB	'Even',CR,LF,0	;
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
	  DB	'1.5',CR,LF,0	;
	  RET
SHSTP1:	  LDA	REG4		;
	  ANI	008H		;test bit 3
	  CPI	0		;if bit3=0 then 1
	  JNZ	SHSTP2		;
	  CALL	MILP		;
	  DB	'1',CR,LF,0	;
	  RET
SHSTP2:	  CALL	MILP		;
	  DB	'2',CR,LF,0	;
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
	  DB	'5',CR,LF,0	;
	  RET			;
SHBTS1:	  CALL	MILP		;
	  DB	'7',CR,LF,0	;
	  RET			;
SHBTS2:	  LDA	REG5		;
	  ANI	020H		;test bit 5
	  CPI	0		;if bit5=0 then 6 bpc
	  JNZ	SHBTS3		;
	  CALL	MILP		;
	  DB	'6',CR,LF,0	;
	  RET			;
SHBTS3:	  CALL	MILP		;
	  DB	'8',CR,LF,0	;
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
MSPDSV:	  DB	0		;SAVE EXTERNAL MODEM MSPEED
MONFLG:	  DB	0FFH		;0: MONITOR OFF - 0FFH: MONITOR ON
ANSFLG:	  DB	0		;0: ORIGINATE   - 0FFH: ANSWER
SMINIT:   DB	'ATM1 S0=0 S7=30 Q0 X1',CR,0	;MODEM INIT STRING
	  END
                                                                                 