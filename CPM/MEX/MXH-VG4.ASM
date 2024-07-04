;     Title  'MEX Overlay for the Vector 4 Computer Version 1.0'
;			- Dick LeBleu
;       		- Winnipeg, Canada
;			- 5 Oct 1986
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
ANCHOR	EQU	NO		;YES, ONLY if using Anchor Modem
ANDAB	EQU	65		;Anchor dial abort character ('A')
;
;
;  
;  MEX Overlay for Vector 4 Computers with external modems.
;  A full-featured SET command processor
;  is implemented to select between modems as well as set
;  specific characteristics of each one.  The following table
;  outlines the SET command options:
;
;	SET Command		         
;
;	PORT <C | P>		 	 	
;	DELAY <n> (seconds)	         
;	BAUD <rate>		         
;	ORIG (originate mode)	         
;	ANSWER	(mode)		         
;	TONE (dialing)		         
;	PULSE (dialing)		         
;	MONITOR (speaker on)	         
;	QUIET (speaker off)	         
;	PARITY (Odd, Even, None)         
;	STOPBITS (1, 1.5, 2)	         
;	LENGTH (5, 6, 7, or 8)           
;	MANUALO (turn off carrier tone   
;		for Originate mode)
;	MANUALA (turn on carrier tone    
;		for Answer mode)     
;
;............
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
; 08/08/86  1.0  Modified for Vector 4 by Dick Le Bleu. 8251 instead of sio
;	
; 30/12/85  1.0  Modified for Ibex by Dick Le Bleu.  Added set port
;                command for switching between port A(Blue) and
;		 B(Black).
;	
;  9/19/84  4.1	 Fixed DISCON1 routine for non-Anchors, was leaving
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
;	 	 Corrected error when setting STOPBITS to 1.5, which
;		 was resetting parity off at the same time.  With the
;		 the improvements to the internal modem support, all
;		 features of SUPRTERM are now supported by this overlay.
;	 	 Enhanced SET MANUAL processing for internal modem
;		 to support manual Originate or Answer carrier tones.
;		 Version level changed to eliminate confusion between
;		 2.X and 3.X overlays currently in circulation.
;		 Updated comments and documentation in all sections.
;	        	                           Terry Carroll
;
;  8/26/84  2.8  Added equate to support Anchor Signalman Mark XII modem.
;		 This overlay now supports DSC, dial abort (^C),
;		 and accurate SET DELAY processing for Anchor modems.
;		 Also incorporated the PARITY, STOPBITS and LENGTH
;		 commands from the Norm Saunders overlay (MXO-KP3X) in
;		 an attempt to unify the MEX overlay identity crisis.
;
;  8/03/84  2.7	 Added call to DISCON: (disconnect routine) in the
;		 Smartmodem dialing routine at SMDMOFF:.  It appeared that
;		 when either the delay timer timed out or a CTRL -C
;		 abort coincided with a connect, the modem did 
; 		 connect, even though the overlay responded with
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
;		 of the value of this overlay.  Restored this
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
;  6/02/84  2.4  Code was turning off RTS       Dennis Quinn
;		 after disconnect sequence.     Royal Oak, MI
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
; Vector 4 default port definitions
;
DCD	EQU	YES		;if supported by port
CMBAUD 	EQU	11h		; modem baud rate port
PTBAUD	EQU	12h		; printer baud rate port
COMCTL	EQU	05h		; modem status port
COMDAT	EQU	04h		; modem data port
PRTCTL	EQU	07H		; printer status port
PRTDAT	EQU	06h		; printer data port
;
; Vector 4 bit definitions
;
MDRCVB	EQU	02H		;modem receive bit (DAV)
MDRCVR	EQU	02H		;modem receive ready
MDSNDB	EQU	01H		;modem send bit
MDSNDR	EQU	01H		;modem send ready bit
MDSDCD	EQU	80H		;modem DCD ready bit
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
;	MACLIB	Z80
;
	ORG	TPA		;we begin
;
	DB	0C3H		;JMP instruction - requd for MEX+
	DS	2		;MEX has a JMP START here
;
	DS	2		;not used by MEX
TPULSE:	DB	'T'		;T=touch, P=pulse (Used by this overlay)
CLOCK:	DB	50		;clock speed x .1, up to 25.5 mhz.
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
INCTL1:	JMP	INCTL		;in modem control port
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
;
OTDATA:	JMP	OUTDAT		;out modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non=PMMI
;
INDATA: JMP	INDAT		;in modem data port
	DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
;
; Bit-test routines. 
;
MASKR:	ANI MDRCVB ! RET	;bit to test for receive ready
TESTR:	CPI MDRCVR ! RET	;value of receive bit when ready
MASKS:	ANI MDSNDB ! RET	;bit to test for send ready
TESTS:	CPI MDSNDR ! RET	;value of send bit when ready
;
	DS	3
DCDV:	JMP	CHKDCD
RNGV:	JMP	CHKRNG
	DS	3
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
	ORG	0200H
;
;  read data reg
;
INDAT:	IN	COMDAT
	RET
;
;  write data reg
;
OUTDAT:	OUT	COMDAT
	RET
;
;  read control reg
;
INCTL:	IN	COMCTL
	RET
;
;  write control reg
;
OUTCTL:  OUT   COMCTL
	  RET
;
;  write baud rate counter
;
OUTBD:	OUT	CMBAUD
	RET
;
; MEX+ enhancements - Check for DCD A=0FFh if present, else 0
;
CHKDCD:	PUSH	H
	PUSH	D
	PUSH	B
	CALL	INCTL
	ANI	MDSDCD
	JZ	DCDRET
	MVI	A,0FFH
DCDRET:	POP	B
	POP	D
	POP	H
	RET
;
; MEX+ enhancements - CHeck for Ring detect - (not used)
;
CHKRNG:
	XRA	A		;a=0
	RET
; Print out the overlay version
;
SYSVER:	  CALL	MILP
	  DB	CR,LF
	  DB	'Vector 4 Overlay - Version '
	  DB	REV/10+'0'
	  DB	'.'
	  DB	REV MOD 10+'0'
;
    IF ANCHOR
          DB	'A'		;APPEND 'A' SUFFIX TO IDENTIFY OVERLAY
				;VERSION AS CONFIGURED FOR ANCHOR MODEM
    ENDIF
;
	  DB	CR,LF
	  DB    0
	  RET
;
; Break, disconnect and goodbye routines
;
SBREAK:   LDA	CMD
	  PUSH	PSW
	  ORI	008H		;SET BREAK
	  CALL	OUTCTL
	  MVI	B,3		;DELAY 300 MS.
	  CALL	MTIME
	  POP	PSW
	  CALL	OUTCTL
	  RET
;
; Disconnect Routine
;
DISCON: 
  
    IF ANCHOR
				;Anchor does not respond to DTR
				;so the only way to disconnect is through
				;standard Smartmodem disconnect commands
          MVI	B,20	
	  MVI	C,TIMER		;wait 2 seconds
	  CALL	MEX
	  LXI	H,SMATN		;send '+++'
	  CALL	SMSEND
	  MVI	B,40            ;wait 4 more seconds (Anchor is slow)
	  MVI	C,TIMER
	  CALL	MEX
	  LXI	H,SMDISC	;send 'ATH'
	  CALL	SMSEND
	  MVI	B,10		;wait 1 second
	  MVI	C,TIMER
	  CALL	MEX
	  RET
    ENDIF
;
    IF NOT ANCHOR
          LDA	CMD
	  PUSH	PSW
	  ANI	0DDH
	  CALL	OUTCTL		;SEND TO THE STATUS PORT
	  MVI	B,10		;WAIT ONE SECOND
	  MVI	C,TIMER
	  CALL	MEX
	  POP	PSW
	  CALL	OUTCTL
	  RET
    ENDIF
;
; GOODBYE routines are called by MEX prior to exit to CP/M
;
GOODBYE:  MVI	B,3		;DELAY 300 MS.
	  CALL  MTIME
	  RET
;
; Initialize RS-232 port and default modes.
;
NITMOD:   CALL	CHKDCD		;SEE IF MODEM IS CONNECTED, I.E., RETURNING
	  CPI   0   		;TO ACTIVE MODEM FROM CPM
	  RNZ			;SKIP IF CONNECTED
;
;         Initialize Internal RS-232 and PIO port
;
NITMOD2:  CALL  NITSIO
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
;	Initialize the 8251 chip 
;
NITSIO:	LXI	H,INITSQ	;POINT TO SEQUENCE
	MVI	B,INITSE	;NUMBER OF BYTES IN SEQUENCE
INIT1:	MOV	A,M		;GET A BYTE
	CALL	OUTCTL		;SEND CHAR TO STATUS PORT
	XTHL			;DELAY IN CASE OF 6 MHZ.
	XTHL
	INX	H		;POINT TO NEXT
	DCR	B
	JNZ	INIT1		;SEND ENTIRE SEQUENCE
INIT2:
	MVI	C,0FFH		;<C> = 0FFH IF INTERRUPTS ENABLED
	LXI	H,0		;PUSH KNOWN VALUE ONTO STACK
	PUSH	H
	POP	H
;	LDAI			;CHECK Z-80 INTERRUPT STATUS
	DB	0EDH,057H
	JP	INIT3		;JUMP IF INTERRUPTS ARE ENABLED
	DCX	SP		;NOW VERIFY THAT INTERRUPTS ARE
	DCX	SP		;REALLY DISABLED BY CHECKING
	POP	H		;KNOWN VALUE ON STACK TO SEE
	MOV	A,H		;IF INTERRUPT SERVICE ROUTINE
	ORA	A		;WAS CALLED.
	JNZ	INIT3		;JUMP IF INTERRUPTS ARE REALLY ENABLED
	MVI	C,0		;<C> = 000H IF INTERRUPTS ARE DISABLED
INIT3:	DI			;PROTECT BAUDRATE SET SEQUENCE
	LXI	H,BAUDRATE	;SET SELECTED BAUDRATE
	MOV	A,M
	CALL	OUTBD
	INX	H
	MOV	A,M
	CALL	OUTBD
	MOV	A,C		;CHECK INTERRUPT STATUS
	ORA	A
	JZ	INITEXIT	;LEAVE INTERRUPTS DISABLED
	EI			;ELSE RE-ENABLE INTERRUPTS

INITEXIT:
	RET
*
INITSQ: DB	000H,000H,000H
RESET:	DB	040H		;SET FOR CONTROL SEQUENCE
CNTL:	DB	04EH		;DEFAULT CNTL 1 STP, NO PAR, 8 BIT, 16X
CMD:	DB	027H		;RTS, RCV EN, TX EN, DTR
*
INITSE	EQU	$-INITSQ
*
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
	  DB	'POR','T'+80H		; ORIGINATE MODE
	  DW	STPORT
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
	  DB	'MANUAL','O'+80H	; SET MANUAL ORIGINATE
	  DW	MANUALO
	  DB	'MANUAL','A'+80H	; SET MANUAL ANSWER
	  DW	MANUALA
	  DB	0			;TABLE TERMINATOR
;
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL  MILP
	  DB	CR,LF
	  DB	'SET values:',CR,LF,0
          CALL	CRLF
	  CALL	MDSHOW
	  CALL	CRLF
	  CALL	TPSHOW
	  CALL	CRLF
	  CALL	PTSHOW
	  CALL	CRLF
	  CALL	BDSHOW
	  CALL  CRLF
	  CALL	DLSHOW
	  CALL	CRLF
	  CALL	MONSHO
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
	  DB	CR,LF,'SET PORT      - C or P'
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
	  DB	CR,LF,'SET BAUD      - 110, 300, 600, 1200'
	  DB	CR,LF,'                2400, 4800, 9600'
	  DB    CR,LF,'SET MANUALO   - Manual Originate mode'
	  DB	CR,LF,'SET MANUALA   - Manual Answer mode'
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
	  PUSH	A		;SAVE MSPEED
	  ADD	A		;DOUBLE INDEX INTO BAUD RATE TBL
	  MOV	E,A		;MSPEED CODE TO DE
	  MVI	D,0
	  LXI	H,BAUDTB	;OFFSET INTO TABLE
	  DAD	D
	  MOV	A,M		;FETCH CODE
	  ORA	A		;0 MEANS UNSUPPORTED CODE
	  STC			;PREP CARRY IN CASE UNSUPPORTED
	  JZ	PBEXIT		;EXIT IF BAD
	  STA	BAUDRATE	;SAVE IN BAUDRATE LO
	  INX	H
	  MOV	A,M		;NOW UPPER BYTE
	  STA	BAUDRATE+1
	  CALL	INIT2
	  POP	A		;GET MSPEED CODE BACK
	  STA	MSPEED		;SET IT
	  ORA	A		;RETURN NO ERRORS
PBEXIT:	  POP	B
	  POP	D
	  POP	H
	  RET
;
* DELAY CONSTANTS FOR BAUD RATE GENERATION
*
BAUDTB:	  DW	0470H		;110
	  DW	001A1H		;300
	  DW	0		;450 (not supported)
	  DW	00D0H		;600
	  DW	0		;710 (not supported)
	  DW	0068H		;1200
	  DW	0034H		;2400
	  DW	001AH		;4800
	  DW	000DH		;9600
	  DW	0		;19200(not supported) 

BAUDRATE:
	DW	0068H	;DEFAULT
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
; Port control processor
;	
STPORT:	  MVI	C,SBLANK	;check for stop bits
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,PRTTBL	;check for proper syntax
	  MVI   C,LOOKUP
	  CALL	MEX		;
	  PUSH	H		;match found, go do it!
	  RNC			;
	  POP	H		;no match: fix stack and
	  JMP	SETERR		;  print error
;
PRTC:	MVI	A,COMDAT
	STA	INDAT+1
	STA	OUTDAT+1
	MVI	A,COMCTL
	STA	INCTL+1
	STA	OUTCTL+1
	MVI	A,CMBAUD
	STA	OUTBD+1
	XRA	A
	STA	PTFLG
	CALL	PTSHOW
	JMP	NITSIO
;
PRTP:	MVI	A,PRTDAT
	STA	INDAT+1
	STA	OUTDAT+1
	MVI	A,PRTCTL
	STA	INCTL+1
	STA	OUTCTL+1
	MVI	A,PTBAUD
	STA	OUTBD+1
	MVI	A,0FFH
	STA	PTFLG
	CALL	PTSHOW
	JMP	NITSIO
;
PTSHOW:	  LDA	PTFLG
	  ORA	A
	  JZ	PTSHOW1	
	  CALL	MILP
	  DB	'Printer port selected',0
	  RET
PTSHOW1:  CALL	MILP
	  DB	'Communications port selected',0
	  RET
PTFLG:	  DB	0
;
;	SET PORT command table
;
PRTTBL:	  DB	'C'+80H		;"set stop 1"
	  DW	PRTC
	  DB	'P'+80H		;"set stop 2"
	  DW	PRTP
	  DB	0		;<<== End of stop-bits table

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
; Set manual processor
;
MANUALO:  MVI	A,00H
	  STA   ANSFLG
	  LXI	H,SMMANO
      	  CALL	SMSEND
	  JMP	OFF
MANUALA:  MVI	A,0FFH
	  STA   ANSFLG
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
;		Parity is controlled by bits 4 and 5 of
;		the byte sent to the 8251 CNTL register
;		as follows:
;
;		   Parity	Bit 5	   Bit 4
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
PROFF:	  LDA	CNTL		;get register 4 byte
	  ANI	0CFH		;reset bit 4,5
	  JMP	PARTB1		;
PREVEN:	  LDA	CNTL		;
	  ORI	030H		;set bits 4 & 5
	  JMP	PARTB1		;
PRODD:	  LDA	CNTL		;
	  ORI	010H		;set bit 4
	  ANI	0DFH		;reset bit 5
PARTB1:	  STA	CNTL		;
	  CALL	NITSIO		;re-initialize the USART
	  CALL	SHPRTY		;print the result
	  RET     		;
SHPRTY:	  CALL	MILP		;display parity
	  DB	'Parity:  ',TAB,' ',0
	  LDA	CNTL		;
	  ANI	010H		;test bit 4
	  CPI	0		;if bit4=0 then parity off
	  JNZ	SHPRT1		;
	  CALL	MILP		;
	  DB	'Off',0		;
	  RET
SHPRT1:	  LDA	CNTL		;
	  ANI	020H		;test bit 5
	  CPI	0		;if bit5=0 then parity odd
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
;		6 and 7 of the byte sent to the 8251 CONTROL
;		register, as follows:
;
;		    Stop bits	   Bit 7	Bit 6
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
STOP01:	  LDA	CNTL		;get CNTL byte
	  ANI	07FH		;reset bit 7
	  ORI	040H		;set bit 6
	  JMP	STSTP1		;
STOP02:	  LDA	CNTL		;
	  ORI	0C0H		;set bits 6 and 7
	  JMP	STSTP1		;
STOP15:	  LDA	CNTL		;
	  ORI	080H		;set bit 7
	  ANI	0BFH		;reset bit 6
STSTP1:	  STA	CNTL		;
	  CALL	NITSIO		;
	  CALL	SHSTOP		;print the result
	  RET
SHSTOP:	  CALL	MILP		;display stop-bits
	  DB	'Stop bits:',TAB,' ',0
	  LDA	CNTL		;
	  ANI	040H		;test bit 6
	  CPI	0		;if bit6=0 then 1.5
	  JNZ	SHSTP1		;
	  CALL	MILP		;
	  DB	'1.5',0		;
	  RET
SHSTP1:	  LDA	CNTL		;
	  ANI	080H		;test bit 7
	  CPI	0		;if bit7=0 then 1
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
;		The number of bits per character is controlled 
;		by bits 2 and 3 of the control byte
;
;		    BPC		Bit 3		Bit 2
;		     5		  0		  0
;		     6		  0   		  1
;		     7		  1		  0
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
BIT5:	  LDA	CNTL		;
	  ANI	0F3H		;reset bit 2,3
	  JMP	STBTS1		;
BIT6:	  LDA	CNTL		;
	  ANI	0F7H		;reset bit 3
	  ORI	004H		;set bit 2
	  JMP	STBTS1		;
BIT7:	  LDA	CNTL		;
	  ORI	008H		;set bit 3
	  ANI	0FBH		;reset bit 2
	  JMP	STBTS1		;
BIT8:	  LDA	CNTL		;
	  ORI	00CH		;set bit 2,3
STBTS1:	  STA	CNTL		;
	  CALL	NITSIO		;
	  CALL	SHBITS		;print the result
	  RET
SHBITS:	  CALL	MILP		;display bits/char
	  DB	'Bits/char:',TAB,' ',0
	  LDA	CNTL		;
	  ANI	008H		;test bit 3
	  CPI	0		;if bit3=0 then 6 or 5 bpc
	  JNZ	SHBTS2		;
	  LDA	CNTL		;
	  ANI	004H		;test bit 2
	  CPI	0		;if bit2=0 then 5 bpc
	  JNZ	SHBTS1		;
	  CALL	MILP		;
	  DB	'5',0		;
	  RET			;
SHBTS1:	  CALL	MILP		;
	  DB	'6',0		;
	  RET			;
SHBTS2:	  LDA	CNTL		;
	  ANI	004H		;test bit 2
	  CPI	0		;if bit2=0 then 7 bpc
	  JNZ	SHBTS3		;
	  CALL	MILP		;
	  DB	'7',0		;
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
; Smartmodem dialing routine from Ron Fowler's MXO-SM13.ASM
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
;
	IF	DCD		;if DCD is available, take a look at it
	CALL	CHKDCD		;   get the status byte
	INR	A		;   and test the DCD flag
	RZ 			;   return with A=0 if found,
	  			;but otherwise ...
	ENDIF	;DCD
;
CKKCC:	  PUSH	B		;NO, TEST FOR CONTROL-C FROM CONSOLE
	  MVI	C,DCONIO	;USE DIRECT CONSOLE I/O
	  MVI	E,DCONIN	;ASK FOR INPUT
	  CALL	BDOS		;FROM BDOS
	  POP	B
	  CPI	'C'-40H		;^C
	  JNZ	SMNEXT		;IF NOT, JUMP
	  CALL	SMDMOFF		;YES, SHUT DOWN THE MODEM
	  MVI	A,3		;RETURN ABORT CODE
	  RET
SMNEXT:	  CPI	0		;ANY OTHER KEY?
	  JNZ	SMTIMO		;YES, TREAT LIKE NO ANSWER
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
SMANAL:

    IF ANCHOR
				;Anchor echoes the digits as they are
				;being dialed.  The returned digits are
				;interpreted as call return codes, shutting
				;down the modem prematurely
				;
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
    ENDIF
;
    IF NOT ANCHOR
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
    ENDIF
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
SMDMOFF:
;
    IF ANCHOR
	  MVI	B,ANDAB
    ENDIF
;
    IF NOT ANCHOR
	  MVI	B,CR
    ENDIF
;
	  MVI	C,SNDCHR
	  CALL	MEX
;
    IF ANCHOR
	  MVI	B,20		;TWO SECOND WAIT FOR ANCHOR
	  CALL	MTIME
	  RET
    ENDIF
;
    IF NOT ANCHOR
	  MVI	B,10		;ONE SECOND WAIT FOR HAYES, ETC
	  CALL	MTIME
	  JMP	DISCON		;MAKE SURE IT IS OFF
    ENDIF
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
; Miscellaneous Default Data
;
SMDIAL:	  DB	'ATDP '		;Smartmodem dial prefix
DIALBF:	  DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	  DS	2		;DIAL POSITION POINTER
DIALWD:	  DB	01000000B	;PULSE/TONE DIAL WORD
DIGIT	  DB	0		;SAVE DIALED DIGIT
MSPDSV:	  DB	0		;SAVE MODEM MSPEED
MONFLG:	  DB	0FFH		;0: MONITOR OFF - 0FFH: MONITOR ON
ANSFLG:	  DB	0		;0: ORIGINATE   - 0FFH: ANS
NDELAY:	  DB	30		;NO. SECONDS FOR ANSWER
;
SMATN:    DB	'+++',0		;Smartmodem online 'attention'
SMDISC:	  DB	'ATH',CR,0	;Smartmodem disconnect (used by Anchor)
SMINIT:   DB	'ATM1 S0=0 S7=60 X1',CR,0	;MODEM INIT STRING
SMMANO:	  DB	'ATC0',CR,0
SMMANA:	  DB	'ATC1',CR,0
;
EOSMSG:	  DB	010H,'$'	;CLEAR TO END-OF-SCREEN
CLSMSG:	  DB	04H,'$'		;CLEAR WHOLE SCREEN
	  END
SMMANA:	  DB	'ATC1',CR,0
;
EOSMSG:	  DB	010H,'$'	;CLEAR TO END-OF-SCREEN
C