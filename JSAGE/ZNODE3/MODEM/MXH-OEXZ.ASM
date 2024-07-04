;     Title  'MexPlus Overlay for the Osborne Executive Computer Version 1.0'
;	Modelled from MXO-KP41.ASM Overlay
;			- Dick LeBleu
;
; Misc equates
;
REV	EQU	10		;OVERLAY REVISION LEVEL
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
;
;  A full-featured SET command processor
;  is implemented to select between modems as well as set
;  specific characteristics of each one.  The following table
;  outlines the SET command options:
;
;	SET Command
;
;	PORT (Modem,Printer)               NOT ANY MORE
;	DELAY <n> (seconds)		   YES
;	BAUD <rate>			   YES
;	ORIG (originate mode)		   YES
;	ANSWER	(mode)			   YES
;	MONITOR (speaker on)		   YES
;	QUIET (speaker off)		   YES
;	PARITY (Odd, Even, None)	   YES
;	STOPBITS (1, 1.5, 2)		   YES
;	LENGTH (5, 6, 7, or 8)		   YES
;	MANUALO (turn off carrier tone	   YES
;		for Originate mode)
;	MANUALA (turn on carrier tone	   YES
;		for Answer mode)
;
;............
;
;
;  This overlay includes portions of the smartmodem dialing routine from
;  MXO-SM13.ASM by Ron Fowler.
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
;;11/30/88	 I discovered that this overlay is apparently too
;;		 big for use with Z3PLUS (or something?). When I 
;;		 got Z3PLUS, (and after a lot of PEEKing both in
;;		 and out of MEX+) I discovered that when I ran 
;;		 MEX+ with this overlay installed, it "trashed"
;;		 the first 4 bytes in the Z3ENV so ZCPR specific
;; 		 programs would not run.  However I like most features
;;               of the improved SET command.  I re-wrote nothing.
;; 		 All I did was get rid of the PORT switching (which
;;		 I never had a use for) parts of the SET command.
;;		 Everything that I commented out has two semi-colons
;;		 (like this comment) in front of it so others with more
;;		 knowledge can perhaps find a smarter fix.  This overlay
;;		 is a little smaller in size and causes no problems on
;;               my Exec. with Z3PLUS.
;;		                        Don Strait, Cincinnati, OH.  
; 04/04/87       Revised for Osborne Executive computer for use
;		 with both modem and printer ports
;
; 08/03/86  1.0  Modified for MexPlus by Dick Le Bleu. Removed
;		 Tone and Pulse Dial since they are now a STAT
;		 command.  Also most routines for the Dial and
;		 Smdisconnect have been removed. All references
;		 to Anchor modems removed since MexPlus can now
;		 be STAT to SMDISC instead of DTR type DISC.
;
; 30/12/85  1.0  Modified for iBEX by Dick Le Bleu.  Added set port
;		 command for switching between port A(Blue) and
;		 B(Black).
;
;  9/19/84  4.1  Fixed DISCON1 routine for non-Anchors, was leaving
;		 DTR and RTS off, now lowers them for one sec and
;		 raises it.. Also added code to dial routine to allow
;		 any character (other than ^C) typed during a dial
;		 command to abort THAT dial attempt, but will
;		 proceed with repetition or next command. ^C will
;		 abort call in progress and any other CALL cmds
;		 lined up. (This is for "dumb" Smartmodems that
;		 don't detect busy, if you hear busy, just hit
;		 the space bar and it will give it up and try the
;		 next one or try calling again.) -- Kim Levitt
;
;  9/9/84   4.0  Upgraded internal modem support to include
;		 SET PARITY, STOPBITS, and LENGTH.
;		 Corrected error when setting STOPBITS to 1.5, which
;		 was resetting parity off at the same time.  With the
;		 the improvements to the internal modem support, all
;		 features of SUPRTERM are now supported by this overlay.
;		 Enhanced SET MANUAL processing for internal modem
;		 to support manual Originate or Answer carrier tones.
;		 Version level changed to eliminate confusion between
;		 2.X and 3.X overlays currently in circulation.
;		 Updated comments and documentation in all sections.
;						   Terry Carroll
;
;  8/26/84  2.8  Added equate to support Anchor Signalman Mark XII modem.
;		 This overlay now supports DSC, dial abort (^C),
;		 and accurate SET DELAY processing for Anchor modems.
;		 Also incorporated the PARITY, STOPBITS and LENGTH
;		 commands from the Norm Saunders overlay (MXO-KP3X) in
;		 an attempt to unify the MEX overlay identity crisis.
;
;  8/03/84  2.7  Added call to DISCON: (disconnect routine) in the
;		 Smartmodem dialing routine at SMDMOFF:.  It appeared that
;		 when either the delay timer timed out or a CTRL -C
;		 abort coincided with a connect, the modem did
;		 connect, even though the overlay responded with
;		 NO ANSWER. Added these calls to make sure there
;		 is no unannounced connect.	John C. Smith
;
;  6/10/84  2.6  Undid revision 2.5.  MEX is intended NOT to disconnect
;		 from the phone line on re-entering CPM; DCD detection
;		 supports this function as well as preventing the
;		 modem initialization string from being sent to the
;		 remote computer.  For Smartmodem, set switch 6 up;
;		 for other modems, enable DCD detection.  Also,
;		 the internal modem initialization had been commented
;		 out without documentation.  This defeats one-half
;		 of the value of this overlay.	Restored this
;		 initialization.
;
;  6/03/84  2.5  Commented out three lines	Dennis Quinn
;		 at NITMOD2 which prevented	Royal Oak, MI
;		 "off the shelf" Smartmodem
;		 from being initialized.  Reason for this is that
;		 the Smartmodem asserts DCD even when no carrier
;		 is being detected unless the case is opened and
;		 an option switch is set.  Side effect of commenting
;		 out these lines is re-entering MEX will transmit
;		 the initialization sequence to the remote if you
;		 are on-line.  If you set the appropriate option
;		 switch (I can't remember which switch it is and
;		 my Smartmodem book is at the office), uncomment
;		 the code and all will be well.
;
;  6/02/84  2.4  Code was turning off RTS	Dennis Quinn
;		 after disconnect sequence.	Royal Oak, MI
;		 This was causing problems
;		 with certain modems which are more intelligent than
;		 the Smartmodem and require RTS before they will
;		 assert CTS.  Enabled 110 baud operation for those
;		 who are masochists.
;
;
;  5/29/84  2.2  Corrected SET ? to display	Steve Sanders
;		 proper SET ORIG command instead
;		 of SET ORIGINATE
;
;  5/18/84  1.0  Original version		John Smith - Manlius, NY
;
;  Credits:
;
;  M7KP-1 overlay structure by Irv Hoff
;  Smartmodem dialing routine by Ron Fowler
;
;  Bug Reports:
;
;  Would appreciate a note of any problems be left on the
;  Computers Etc. RBBS at 315-446-7793.
;
;
;------------------------------------------------------------
;
; Osborne default port definitions
;
MODEM	EQU	YES		; Modem Port selected
;;PRNT	EQU	NO		; Printer Port selected
DCD	EQU	YES		;if supported by port
;
	IF	MODEM
EXPORT	EQU	0CH		;base external port
SELPRT	EQU	0
	ENDIF			;modem port
;
;;IF	PRNT
;;EXPORT	EQU	0EH		;base external port
;;SELPRT	EQU	0FFH
;;	ENDIF			;printer port

EXTCT1	EQU	EXPORT+1	;external modem status port
EXTDAT	EQU	EXPORT		;external modem data port
;
BRPORT	EQU	04H		; CTC timer port to set baudrate
;
; Executive bit definitions
;
MDRCVB	EQU	01H		;modem receive bit (DAV)
MDRCVR	EQU	01H		;modem receive ready
MDSNDB	EQU	04H		;modem send bit
MDSNDR	EQU	04H		;modem send ready bit
MDSDCD	EQU	08H		;modem DCD ready bit
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
DCONIO	EQU	6		;BDOS Direct Console I/O function #
DCONIN	EQU	0FFH		;BDOS DCONIO flag for input
BDOS	EQU	5		;address of BDOS function caller
;
;
	ORG	TPA		;we begin
;
	DB	0C3H		;flags a LOADable overlay
	DS	2		;MEX has a JMP START here
;
	DS	2		;not used by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (Used by this overlay)
CLOCK:	DB	40		;clock speed x .1, up to 25.5 mhz.
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
IGNCTL:	DB	NO		;yes=do not send control characters
				;above CTL-M to CRT in terminal mode
				;no=send any incoming CTL-char to CRT
EXTRA1:	DB	0		;for future expansion
EXITCHR: DB	'E'-40h		;for future expansion
BRKCHR:	DB	'@'-40H		;^B = Send a 300 ms. break tone
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
	DS	7		;spares if needed for non-PMMI
;
OTDATA:	JMP	OUTD		;out modem data port
	DS	7		;spares if needed for non=PMMI
;
INPORT:	JMP	IND		;in modem data port
	DS	7		;spares if needed for non-PMMI
;
; Bit-test routines.
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready
;
DCDCHK:	JMP	CHKDCD
RNGCHK:	JMP	CHKRNG
	DB	0,0,0,0,0
;
SMDISC:	DS	3		;now in mdm ovl (SMDISC)
DIALV:	DS	3		; "  "  "  "
DISCV:	JMP	DISCON		;hardware disconnect
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
; Not required since MexPlus uses terminal overlay
;
CLREOS:	DS	9		;clear to end of screen
;
CLS:	DS	9		;clear screen
;
	ORG	0200H
;------------------------------------------------------------
;
; end of fixed area
;
;------------------------------------------------------------
;
; input control/status port
;
INC:	MVI	A,10H
	CALL	OUTCTL1
	CALL	INSTAT
	RET
;
; * *	All i/o to serial port made through here to allow
;	changing port address ie Modem vs Printer
;
;  write control reg
;
OUTCTL1:  OUT	EXTCT1
	  RET
;
;  read status register
;
INSTAT:	  IN	EXTCT1
	  RET
;
; input data port
;
IND:	IN	EXTDAT
	RET
;
; output data port
;
OUTD:	OUT	EXTDAT
	RET
;
; Check for DCD on
;
CHKDCD:	PUSH B ! PUSH D	! PUSH H
	CALL	INC
	ANI	08H
	JZ	DCDRET		;no carrier present
	MVI	A,0FFH		;carrier present
DCDRET:	POP H !	POP D !	POP B
	RET
;
CHKRNG:	XRA	A		;CLEAR	A
	RET			;not used
;
; Print out the overlay version
;
SYSVER:	  CALL	MILP
	  DB	CR,LF
	  DB	'MexPlus Overlay - Version for Osborne Executive - '
	  DB	REV/10+'0'
	  DB	'.'
	  DB	REV MOD	10+'0'
	  DB	CR,LF
	  DB	0
	  RET
;
; Break, disconnect and goodbye routines
;
SBREAK:	  MVI	A,5
	  CALL	OUTCTL1
	  LDA	REG5
	  ORI	00010000B	;ENABLE BREAK
	  CALL	OUTCTL1
	  MVI	B,3		;DELAY 300 MS.
	  CALL	MTIME
	  MVI	A,5
	  CALL	OUTCTL1
	  LDA	REG5
	  ANI	11101111B	;TURN OFF BREAK
	  CALL	OUTCTL1
	  RET
;
; Disconnect Routine
;
DISCON:	  MVI	A,5
	  CALL	OUTCTL1		;SEND TO THE STATUS PORT
	  MVI	A,01101000B	;TURN OFF DTR/RTS
	  CALL	OUTCTL1
	  MVI	B,10		;WAIT ONE SECOND
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,5		;TURN IT BACK ON
	  CALL	OUTCTL1
	  LDA	REG5
	  CALL	OUTCTL1
	  RET
;
; GOODBYE routines are called by MEX prior to exit to CP/M
;
GOODBYE:  MVI	B,3		;DELAY 300 MS.
	  CALL	MTIME
	  RET
;
; Initialize RS-232 port and default modes.
;
NITMOD:	  CALL	INC		;SEE IF MODEM IS CONNECTED, I.E., RETURNING
	  ANI	08H		;TO ACTIVE MODEM FROM CPM
	  RNZ			;SKIP IF CONNECTED
;
;	  Initialize Internal RS-232 and PIO port
;
NITMOD2:  LDA	REG5
	  CALL	NITSIO
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
;	Initialize the Zilog SIO chip for either port
;
NITSIO:	  MVI	A,00H		;Select reg. 0
	  CALL	OUTCTL1
	  LDA	REG0		;Command byte
	  CALL	OUTCTL1
	  MVI	A,04H		;Select reg. 4
	  CALL	OUTCTL1
	  LDA	REG4		;Receive/transmit control byte
	  CALL	OUTCTL1
	  MVI	A,03H		;Select reg. 3
	  CALL	OUTCTL1
	  LDA	REG3		;Receiver logic byte
	  CALL	OUTCTL1
	  MVI	A,05H		;Select reg. 5
	  CALL	OUTCTL1
	  LDA	REG5		;Transmitter logic byte
	  CALL	OUTCTL1
NITEND:	  RET
;
;
; Set command processor
;
SETCMD:	  MVI	C,SBLANK	;ANY ARGUMENTS?
	  CALL	MEX
	  JC	SETSHO		;IF NOT, DISPLAY DEFAULT(S)
	  LXI	D,CMDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;PARSE THE ARGUMENT
	  PUSH	H		;SAVE ANY PARSED ARGUMENTS ON STACK
	  RNC			;IF WE HAVE ONE, RETURN TO IT
	  POP	H		;OOPS, INPUT NOT FOUND IN TABLE
SETERR:	  LXI	D,SETEMS
	  MVI	C,PRINT
	  CALL	MEX
	  CALL	CRLF
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
CMDTBL:	  DB	'?'+80H			; HELP
	  DW	SETHELP
;;	  DB	'MDMPOR','T'+80H	; MODEM PORT COMMAND
;;	  DW	MDMPORT
;;	  DB	'PRTPOR','T'+80H	; PRINTER PORT COMMAND
;;	  DW	PRTPORT
	  DB	'ORI','G'+80H		; ORIGINATE MODE
	  DW	ORIG
	  DB	'ANSWE','R'+80H		; ANSWER MODE
	  DW	ANS
;	  DB	'TON','E'+80H		; TONE DIALING
;	  DW	STTONE
;	  DB	'PULS','E'+80H		; PULSE DIALING
;	  DW	STPULSE
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
	  DW	STSTOP
	  DB	'LENGT','H'+80H		; SET LENGTH
	  DW	STBITS
	  DB	'MANUAL','O'+80H	; SET MANUAL ORIGINATE
	  DW	MANUALO
	  DB	'MANUAL','A'+80H	; SET MANUAL ANSWER
	  DW	MANUALA
	  DB	0			;TABLE TERMINATOR
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL	MILP
	  DB	CR,LF
	  DB	'SET values:',CR,LF,0
	  CALL	CRLF
;;	  CALL	PORTSHOW
;;	  CALL	CRLF
	  CALL	MDSHOW
	  CALL	CRLF
	  CALL	TPSHOW
	  CALL	CRLF
	  CALL	BDSHOW
	  CALL	CRLF
	  CALL	DLSHOW
	  CALL	CRLF
	  CALL	MONSHO
	  CALL	CRLF
	  CALL	CRLF
	  CALL	SHPRTY
	  CALL	CRLF
	  CALL	SHSTOP
	  CALL	CRLF
	  CALL	SHBITS
	  CALL	CRLF
	  CALL	CRLF
	  RET
;
; "SET ?" processor
;
SETHELP:  CALL	MILP
;;	  DB	CR,LF,'SET MDMPORT'
;;	  DB	CR,LF,'SET PRTPORT'
	  DB	CR,LF,'SET ORIG'
	  DB	CR,LF,'SET ANSWER'
;	  DB	CR,LF,'SET TONE'
;	  DB	CR,LF,'SET PULSE'
	  DB	CR,LF,'SET DELAY     - <N> seconds'
	  DB	CR,LF,'SET PARITY    - OFF, EVEN or ODD'
	  DB	CR,LF,'SET STOPBITS  - 1, 1.5 or 2'
	  DB	CR,LF,'SET LENGTH    - 5, 6, 7 or 8'
	  DB	CR,LF,'SET QUIET     - Speaker OFF'
	  DB	CR,LF,'SET MONITOR   - Speaker ON'
	  DB	CR,LF,'SET BAUD      - 300, 1200, 2400, 4800, 9600 '
	  DB	CR,LF,'SET MANUALO   - Manual Originate mode'
	  DB	CR,LF,'SET MANUALA   - Manual Answer mode'
	  DB	CR,LF,CR,LF,0
	  RET
;
; SET PORT processor
;
;;MDMPORT:  MVI	A,0DH		; reset ports called in
;;	  STA	OUTCTL1+1	; sio outputs
;;	  STA	INSTAT+1	; 0D=porta ctl/stat
;;	  DCR	A		; 0C=porta data
;;	  STA	IND+1
;;	  STA	OUTD+1
;;	  CALL	NITSIO
;;	  XRA	A		; save port for portshow
;;	  STA	PORT
;;	  JMP	PORTSHOW
;;;
;;PRTPORT:  MVI	A,0FH		; reset ports called in
;;	  STA	OUTCTL1+1	; sio outputs
;;	  STA	INSTAT+1	; 0F=portB ctl/stat
;;	  DCR	A		; 0E=portB data
;;	  STA	IND+1
;;	  STA	OUTD+1
;;	  CALL	NITSIO
;;	  MVI	A,0FFH		; save port for portshow
;;	  STA	PORT
;
;;PORTSHOW:
;;	  LDA	PORT
;;	  ORA	A		;Set flags..
;;	  JNZ	PRT1
;;	  CALL	MILP
;;	  DB	'Port selected - A (Modem)',0
;;	  RET
;;PRT1:	  CALL	MILP
;;	  DB	'Port selected - B (Printer)',0
;;	  RET
;
;;PORT:	  DB	SELPRT
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
	  PUSH	B
	  MOV 	B,A		; save speed
	  ADD	A		;Double A table is in words
	  MOV	E,A		;MSPEED X 2 INDEX TO DE
	  MVI	D,0
	  LXI	H,BAUDTB	;OFFSET INTO TABLE
	  DAD	D
	  MOV	A,M		;FETCH Baudrate low
	  ORA	A		;0 MEANS UNSUPPORTED CODE
	  STC			;PREP CARRY IN CASE UNSUPPORTED
	  JZ	PBEXIT		;EXIT IF BAD

	  OUT	BRPORT		; send low byte
	  INX	H		; Step to upper
	  MOV	A,M		; Get "MSP" baud rate byte
	  OUT	BRPORT

	  MOV	A,B		; recall baudrate
	  STA	MSPEED		;SET IT
	  ORA	A		;RETURN NO ERRORS
PBEXIT:	  POP	B
	  POP	D
	  POP	H
	  RET
;
BAUDTB:	  DW	0		;110 (not supported)
	  DW	0180H		;300 
	  DW	0		;450 (not supported)
	  DW	0		;600 (not supported)
	  DW	0		;710 (not supported)
	  DW	60H		;1200
	  DW 	30H		;2400
	  DW	18H		;4800
	  DW	0CH		;9600
	  DW	0		;19200
;
; SET MODE PROCESSOR ---- SET MODEM SELECTION TO INTERNAL OR EXTERNAL
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
	  CALL	MDSHOW
	  RET
;
MDSHOW:	  LDA	ANSFLG
	  ORA	A
	  JZ	MDORIG
	  CALL	MILP
	  DB	'Auto-answer mode',0
	  RET
MDORIG:	  CALL	MILP
	  DB	'Originate mode: auto-answer disabled',0
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
; display dial stat
;
TPSHOW:	  LDA	TPULSE		
	  CPI	'T'
	  JZ	TPTONE
	  CALL	MILP
	  DB	'Pulse Dial',0
	  RET
TPTONE:	  CALL	MILP
	  DB	'Tone Dial',0
	  RET
;
; Set manual processor
;
MANUALO:  MVI	A,00H
	  STA	ANSFLG
	  LXI	H,SMMANO
	  CALL	SMSEND
	  JMP	OFF
MANUALA:  MVI	A,0FFH
	  STA	ANSFLG
	  LXI	H,SMMANA
	  CALL	SMSEND
OFF:	  MVI	B,10		;WAIT 1 SEC
	  CALL	MTIME
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
	  CALL	BNTOASC
	  SHLD	SMDELAY+5	;save ascii equiv
	  LXI	H,SMDELAY	;send new delay to modem
	  CALL	SINIT
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
;BNTOASC - Convert binary number in A to two ASCII chars in HL
;
BNTOASC:
	PUSH	PSW
	LXI	H,00FFH		;prepare..L=-1
BN10:	INR	L
	SBI	10		;Subtract 10
	JNC	BN10		;one more time if no borrow
	ADI	10		;too far
	ORI	030H		;to ASCII
	MOV	H,A		;Low digit to H 
	MOV	A,L		;now upper
	ORI	030H		;to ascii
	MOV	L,A		;Upper in L
	POP	PSW
	RET
;
;	SET PARITY command: reset transmit/receive parity
;
;		Parity is controlled by bits 0 and 1 of
;		the byte sent to the SIO write-register
;		4 as follows:
;
;		   Parity	Bit 1	   Bit 0
;		     Off	  -	     0
;		     Odd	  0	     1
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
	  RET			;
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
;			1	     0		  1
;		       1.5	     1		  0
;			2	     1		  1
;
;
STSTOP:	  MVI	C,SBLANK	;check for stop bits
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,STPTBL	;check for proper syntax
	  MVI	C,LOOKUP
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
;		    BPC 	Bit 7		Bit 6
;		     5		  0		  0
;		     6		  1		  0
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
;			     Data Area
;==========================================================================
;
; Default UART parameters (Initalized for External RS-232)
;
REG0:	  DB	00011000B	;RESET CHANNEL
REG3:	  DB	11000001B	;ENABLE RECEIVE AT 8 BITS/CHAR
REG4:	  DB	01000100B	;NO PARITY, 1 STOP BIT, CLOCK X16
REG5:	  DB	11101010B	;ENABLE TRANSMIT AT 8 BITS/CHAR
;
; Miscellaneous Default Data
;
MSPDSV:	  DB	0		;SAVE MODEM MSPEED
MONFLG:	  DB	0FFH		;0: MONITOR OFF - 0FFH: MONITOR ON
ANSFLG:	  DB	0		;0: ORIGINATE	- 0FFH: ANS
NDELAY:	  DB	30		;NO. SECONDS FOR ANSWER
;
SMINIT:	  DB	'ATM1 S0=0 S7=30 X1',CR,0	;MODEM INIT STRING
SMDELAY:  DB	'ATS7=30',CR,0	
SMMANO:	  DB	'ATC0',CR,0
SMMANA:	  DB	'ATC1',CR,0
;
	  END
7=30 X1',CR,0	;MODEM INIT STRING
SMDELAY:  DB	'AT