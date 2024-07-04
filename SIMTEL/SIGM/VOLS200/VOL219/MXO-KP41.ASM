;     Title  'MEX Overlay for the Kaypro Computer Version 4.1'
;
;
; Misc equates
;
REV	EQU	41		;OVERLAY REVISION LEVEL
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
;  MEX Overlay for Kaypro Computers with either internal or
;  external modems.  A full-featured SET command processor
;  is implemented to select between modems as well as set
;  specific characteristics of each one.  The following table
;  outlines the SET command options:
;
;					   Available for
;	SET Command		     Internal         External
;
;	INTERNAL			YES		YES
;	EXTERNAL			YES		YES
;	DELAY <n> (seconds)		YES		YES
;	BAUD <rate>			NO		YES
;	ORIG (originate mode)		YES		YES
;	ANSWER	(mode)			YES		YES
;	TONE (dialing)			YES		YES
;	PULSE (dialing)			YES		YES
;	MONITOR (speaker on)		NO		YES
;	QUIET (speaker off)		NO		YES
;	PARITY (Odd, Even, None)	YES		YES
;	STOPBITS (1, 1.5, 2)		YES		YES
;	LENGTH (5, 6, 7, or 8)     	YES		YES
;	MANUALO (turn on carrier tone	YES		NO
;		for Originate mode)
;	MANUALA (turn on carrier tone	YES		NO
;		for Answer mode)
;
;............
;
;  OWNERS OF OLDER MODEL KAYPRO II OR 4
;
;  If you are using an older model Kaypro II or 4 without the
;  internal modem, do not use the SET INTERNAL command - it
;  is not functional.  This overlay will work with ALL
;  Kaypro computers released to date including the original
;  Kaypro II & 4 and the more recent models with graphics - 
;  the new Kaypro 2, 4-84 and 10.
;
;............
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
;		 SET PARITY, STOPBITS, and LENGTH.  Also cleaned
;		 up internal modem auto-answer logic (it now works).
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
;		 an attempt to unify the Kaypro MEX overlay identity crisis.
;		 The new SET commands are NOT implemented for the 4'84
;		 internal modem.  The SET ? command and the SET without
;		 arguments correctly distinguishes between the internal
;		 and external modem support.          Terry Carroll
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
;		 initialization.  This overlay has been tested with
;		 Kaypro II, 4, 4-84, 10, new 2.  Any substantive
;		 change must be tested with all models prior to 
;		 release in this sequence - or - clearly indicate
;		 new limitations.  Cleaned up code in NITMOD: for
;		 PIO init and RS-232 init.  John C. Smith
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
;  5/31/84  2.3  Changed code to be compatible  John Smith - Manlius, NY
;		 with the older Kaypro models
;		 enabled 19,200 baud operation.
;
;  5/29/84  2.2  Corrected SET ? to display	Steve Sanders
;		 proper SET ORIG command instead
;		 of SET ORIGINATE
;
;  5/28/84  2.1  Added conditional for old      Steve Sanders
;                Kaypro 2/4 
;
;  5/27/84  2.0  Added internal modem and	John Smith - Manlius, NY
;		 revised SET commands.    
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
; Kaypro port definitions
;
INTPORT	EQU	0DH		;base internal port
INTCT1	EQU	INTPORT+2	;internal modem control port
INTDAT	EQU	INTPORT		;internal modem data port
PIODAT	EQU	21H		;internal modem pio data port
PIOCT1	EQU	PIODAT+2	;internal modem pio control port
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
DCONIO	EQU	6		;BDOS Direct Console I/O function #
DCONIN	EQU	0FFH		;BDOS DCONIO flag for input
BDOS	EQU	5		;address of BDOS function caller
;
;
	ORG	TPA		;we begin
;
	DS	3		;MEX has a JMP START here
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
; input control/status port
;
INC:	CALL	MDMSEL
	JZ	INC1
	MVI	A,10H
	OUT	EXTCT1
	IN	EXTCT1
	RET
INC1:	MVI	A,10H
	OUT	INTCT1
	IN	INTCT1
	RET
;
; input data port
;
IND	CALL	MDMSEL
	JZ	IND1
	IN	EXTDAT
	RET
IND1:	IN	INTDAT
	RET
;
; output data port
;
OUTD:	PUSH	PSW
	CALL	MDMSEL
	JZ	OUTD1
	POP	PSW
	OUT	EXTDAT
	RET
OUTD1:	POP	PSW
	OUT	INTDAT
	RET
;
; Print out the overlay version
;
SYSVER:	  CALL	MILP
	  DB	CR,LF
	  DB	'KAYPRO Overlay - Version '
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
SBREAK:   CALL	MDMSEL
	  JNZ	SBREAK1
	  MVI	A,5
	  OUT	INTCT1
	  LDA	WR5
	  ORI	00010000B	;ENABLE BREAK
	  OUT	INTCT1
	  MVI	B,3		;DELAY 300 MS.
	  CALL	MTIME
	  MVI	A,5
	  OUT	INTCT1
	  LDA	WR5
	  ANI	11101111B	;TURN OFF BREAK
	  OUT	INTCT1
	  RET
;
SBREAK1:  MVI	A,5
	  OUT	EXTCT1
	  MVI	A,0FAH		;SEND A BREAK TONE		
	  OUT	EXTCT1
	  JMP	GOODBYE
;
; Disconnect Routine
;
DISCON:   CALL	MDMSEL
	  JNZ	DISCON1		;JUMP TO EXTERNAL MODEM DISCONNECT
	  MVI	A,01000000B	;SET MODEM ON-HOOK
	  OUT	PIODAT		;
	  CALL	MDMSQ
	  RET
;
DISCON1:
;

    IF ANCHOR
				;Anchor does not respond to DTR
				;so the only way to disconnect is through
				;standard Smartmodem disconnect commands
				;
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
          MVI	A,5
	  OUT	EXTCT1		;SEND TO THE STATUS PORT
	  MVI	A,68H		;TURN OFF DTR/RTS
	  OUT   EXTCT1
	  MVI	B,10		;WAIT ONE SECOND
	  MVI	C,TIMER
	  CALL	MEX
	  MVI	A,5		;TURN IT BACK ON
	  OUT	EXTCT1
	  MVI	A,0EAH
	  OUT	EXTCT1
	  RET
    ENDIF
;
; GOODBYE routines are called by MEX prior to exit to CP/M
;
GOODBYE:  MVI	B,3		;DELAY 300 MS.
	  CALL  MTIME
	  RET
;
; Initialize RS-232 port, PIO port and default modes.
;
NITMOD:   CALL	INC		;SEE IF MODEM IS CONNECTED, I.E., RETURNING
	  ANI	08H		;   TO ACTIVE MODEM FROM CPM
	  RNZ			;SKIP IF CONNECTED
	  CALL	MDMSEL
	  JNZ	NITMOD2		;JUMP TO INITIALIZE EXTERNAL RS-232
;
;         Initialize Internal RS-232 and PIO port
;
	  LDA	WR5
	  STA   REG5
	  CALL  NITSIO
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
;         Initialize External RS-232 and Smartmodems
;
NITMOD2:  LDA	ER5
	  STA	REG5
          CALL  NITSIO
          MVI	A,47H
	  OUT	BAUDRP		;SEND TO 'CTC' TIMER
	  LDA	DFBAUD		;SET DEFAULT BAUD RATE
	  OUT	BAUDRP		;SEND TO 'CTC' TIMER
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
;	Initialize the Zilog SIO chip for either modem
;
NITSIO:	  CALL  MDMSEL
	  JNZ   NITSIO1
	  MVI   A,15
	  STA   OUTCTL1+1
	  JMP   NITSIO2
NITSIO1:  MVI   A,6
	  STA   OUTCTL1+1
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
	  CALL MDMSEL
	  JNZ  NITEND
	  LDA  REG5
	  STA  WR5		;Save internal modem REG5
	  RET
NITEND:	  LDA  REG5
       	  STA  ER5		;Save external modem REG5
	  RET
;
OUTCTL1:  OUT   EXTCT1
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
	  CALL  MODEMSH
	  CALL  CRLF
	  RET
SETBMS:	  DB	CR,LF,'SET command not valid for modem',CR,LF,'$'
;
; Argument table
;
CMDTBL:   DB	'?'+80H			; HELP
	  DW	SETHELP
	  DB	'EXTERNA','L'+80H	; EXTERNAL MODEM
	  DW	EXTM
	  DB	'INTERNA','L'+80H	; INTERNAL MODEM
	  DW	INTM
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
	  DB	'MANUAL','O'+80H	; SET MANUAL ORIGINATE
	  DW	MANUALO
	  DB	'MANUAL','A'+80H		; SET MANUAL ANSWER
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
	  CALL	MODEMSH
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
	  DB	CR,LF,'SET INTERNAL'
	  DB	CR,LF,'SET EXTERNAL'
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
	  DB    CR,LF,'SET MANUALO   - Manual Originate mode'
	  DB	CR,LF,'SET MANUALA   - Manual Answer mode'
	  DB	CR,LF,CR,LF,0
	  RET
;
; "SET MODEM" processor
;
INTM:	  MVI	B,0
	  JMP	STMDM
EXTM:	  MVI	B,0FFH
STMDM:	  LDA	EXTMDM		;GET THE PRIOR MDM FLAG
	  CMP	B		;COMPARE TO THE SELECTED MODE
	  JZ	MODEMSH		;IF THE SAME, JUST SHOW IT
	  MOV	A,B		;OTHERWISE, GET THE NEW ONE
	  STA	EXTMDM		;STORE IT
	  ORA	A		;
	  JNZ	STMODM1		;EXTERNAL MODEM WAS SELECTED
;
;	        INTERNAL MODEM SELECTED
;
	  LDA	MSPEED		;GET THE EXTERNAL MODEM MSPEED VALUE
	  STA	MSPDSV		;AND SAVE IT
	  LDA	WR5		;GET INTERNAL MODEM REGISTER 5 VALUE
	  STA	REG5		;AND STORE IT IN COMMON REG5 AREA
	  MVI	A,1		;MSPEED FOR 300 BAUD INTERNAL MODEM
	  JMP	STMODM2
;
STMODM1:  LDA	ER5		;GET EXTERNAL MODEM REGISTER 5 VALUE
	  STA	REG5		;AND STORE IT IN COMMON REG5 AREA
	  LDA   MSPDSV		;GET EXTERNAL MODEM MSPEED VALUE
STMODM2:  STA	MSPEED
	  CALL	NITMOD		;AND INITIALIZE THE NEW MODEM
MODEMSH:  CALL	MDMSEL		;THEN SHOW RESULT
	  JZ	SHINT
	  CALL	MILP
	  DB	'External Modem',0
	  RET
SHINT:	  CALL	MILP
	  DB	'Internal Modem',0
	  RET
;
; "SET BAUD" processor
;
STBAUD:	  CALL  MDMSEL
	  JZ    SETBAD
       	  MVI	C,BDPARS	;FUNCTION CODE: PARSE A BAUDRATE
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
	  STA	DFBAUD		;SAVE CURRENT RATE
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
;
	  CALL	MDMSEL		;IF EXTERNAL MODEM ANSWER MODE
	  RNZ			;EXIT --- ELSE POLL THE PORT FOR RING
;
; WFANS is the internal modem auto-answer function.  Since the
; modem is not truly auto-answer, the program must continually poll
; the port for detection of a ring, then 'answer', i.e., go off hook
; and turn on carrier.  The ENDIAL routine then  waits for a response
; from the caller (a carrier tone); the routine waits for the number
; of seconds specified by the SET DELAY command.
;
	  CALL	CRLF
WFANS:	  MVI	C,CHEKCC	;CHECK FOR ABORT
	  CALL	MEX
	  JZ	ENDANS		;ABORT AUTO-ANSWER MODE
	  CALL	INCTL1		;CHECK FOR RING INDICATOR
	  ANI	20H
	  JZ    WFANS		;IF NOT, LOOP 'TIL ABORT OR RING
	  MVI	B,10		;WAIT 1 SECOND BEFORE SENDING CARRIER
	  CALL	MTIME		
	  CALL  MDMON		;IF RING, TURN ON MODEM
	  CALL	MILP
	  DB	'Ring detected',CR,LF,0
	  JMP   ENDIAL		;WAIT FOR CALLER'S CARRIER
;
ENDANS:   CALL  CRLF
	  CALL	MILP
	  DB	'^C entered: auto-answer mode aborted'
	  DB	CR,LF
	  DB	'Returning to ',0
	  JMP	ORIG
;
MDSHOW:	  LDA	ANSFLG
	  ORA	A
	  JZ	MDORIG		
	  CALL	MDMSEL
	  JNZ	MDSHOW1
	  CALL	MILP
	  DB	'Auto-answer mode: ^C to abort',0
	  RET
MDSHOW1:  CALL	MILP
	  DB	'Auto-answer mode',0
	  RET
MDORIG:	  CALL	MILP
	  DB	'Originate mode: auto-answer disabled',0
	  RET
;
;
; Monitor control processor
;
QUIET:	  CALL  MDMSEL
	  JZ	SETBAD
      	  XRA	A
	  STA	MONFLG
	  LXI	H,SMQT
	  CALL	SINIT
	  JMP	MONSHO
MONIT:	  CALL  MDMSEL
	  JZ    SETBAD
      	  MVI	A,0FFH
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
MANUALO:  CALL  MDMSEL
	  JNZ	SETBAD
	  MVI	A,00H
	  STA   ANSFLG
       	  CALL	MDMON
	  JMP	OFF
MANUALA:  CALL  MDMSEL
	  JNZ	SETBAD
	  MVI	A,0FFH
	  STA   ANSFLG
       	  CALL	MDMON
OFF:	  MVI	A,00010000B	;GO OFFHOOK
	  OUT	PIODAT
	  MVI	B,10		;WAIT 1 SEC
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
DIAL:	  PUSH	PSW		;SAVE THE NUMBER
	  CALL	MDMSEL		;EXTERNAL MODEM?
	  JNZ	DIAL1		;USE SMARTMODEM DIALING ROUTINE
	  POP	PSW		;GET THE NUMBER BACK
	  CPI	254		;START DIAL?
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
;
;
; ENDIAL waits for a response from the modem, whether in originate
; or answer mode.  In either case, carrier detection is awaited
; for the length of time specified in the SET DELAY command (value
; stored in NDELAY).  A modest attempt is made to simulate smartmodem
; operation in the answer mode.
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
	  JZ    TURNON		;ELSE TURN ON MODEM, SEND CARRIER
	  CALL	MILP
	  DB	07H		;DING-A-LING
	  DB	CR,LF,CR,LF,'Carrier detected'
	  DB	CR,LF,'Enter Terminal Mode',CR,LF,LF,0
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
; Smartmodem dialing routine from Ron Fowler's MXO-SM13.ASM
;
DIAL1:	  POP	PSW		;GET THE NUMBER BACK
	  LHLD	DIALPT		;FETCH POINTER
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
; Turn off internal modem
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
; Turn on internal modem
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
	  ORI	10001010B	;ANS MODE, TX SQUELCH OFF
MON2:	  OUT	INTCT1
	  RET
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
MDMSEL:	  LDA	EXTMDM		;IDENTIFY MODEM IN USE
	  ORA	A
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
ER5: 	  DB	11101010B	;EXTERNAL MDM CTRL REGISTER 5 (Initial value)
WR5:	  DB	01101000B	;INTERNAL MDM CTRL REGISTER 5 (Initial value)
;
; Miscellaneous Default Data
;
SMDIAL:	  DB	'ATDT '		;Smartmodem dial prefix
DIALBF:	  DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	  DS	2		;DIAL POSITION POINTER
DIALWD:	  DB	01000000B	;PULSE/TONE DIAL WORD
DIGIT	  DB	0		;SAVE DIALED DIGIT
MSPDSV:	  DB	0		;SAVE EXTERNAL MODEM MSPEED
DFBAUD:	  DB	07		;5: 300, 6: 600, 7: 1200, 0EH: 9600
EXTMDM:	  DB	0FFH		;0: INTERNAL    - 0FFH: EXTERNAL
MONFLG:	  DB	0FFH		;0: MONITOR OFF - 0FFH: MONITOR ON
ANSFLG:	  DB	0		;0: ORIGINATE   - 0FFH: ANS
NDELAY:	  DB	30		;NO. SECONDS FOR ANSWER
;
SMATN:    DB	'+++',0		;Smartmodem online 'attention'
SMDISC:	  DB	'ATH',CR,0	;Smartmodem disconnect (used by Anchor)
SMINIT:   DB	'ATM1 S0=0 S7=60 X1',CR,0	;MODEM INIT STRING
;
EOSMSG:	  DB	17H,'$'		;CLEAR TO END-OF-SCREEN
CLSMSG:	  DB	1AH,'$'		;CLEAR WHOLE SCREEN
	  END
