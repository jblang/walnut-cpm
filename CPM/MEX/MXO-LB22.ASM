;MX0-LB22.ASM -- AMPRO 'LITTLE BOARD' OVERLAY FILE FOR MEX
;
;

VER	EQU	2	; Version 
REV	EQU	2	; Revision Level
;
;
; Modified from Jerry Haigwood's M7LB-2.ASM with inserts from
;    MXO-KP41.ASM John Smith, et al.. 
;
; Modified from the general purpose overlay by Jerry Haigwood, KY4Z
;
; This overlay adapts the MEX program by Ronald Fowler to the 
;   AMPRO Series 100 computer, using the Z80 DART and the 
;   Z80 CTC.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the AMPRO Series 100 
; computer with the Z80 DART serial port "B" and the Z80 CTC baud rate
; generator.  If you are not using this equipment then you might still
; want to look over this file to gain knowledge on how to write your
; own version of this overlay.  Some other overlays which might help
; are:
;
;     "H8"  Heath H89 overlay for 8250 I/O and programmable baud rates
;     "HZ"  Zenith 120 overlay for 2661B initialization and baud rates
;     "XE"  Xerox 820II overlay for Z80-SIO intialization, etc.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;               assembler. Then use MLOADxx to overlay the relulting
;               .HEX file over the MEXxx.COM.
;
;	A>REN MEXxxx.OBJ=MEXxxx.COM <-- THIS PRESERVES THE UNINSTALLED
;                                       VERSION IN AN UNRUNABLE FORM.
;       A>ASM MXO-LB01
;       A>MLOADxx MEXXxx.COM=MEXXxx.OBJ,MXO-LB01.HEX
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 12/18/85 - Corrected 2400 Baud problem, 
;            Neatened up printing routines
;            Added jump so that SM overlays can set baud rate
;                                           - Mike Vore
;
; 10/02/85 - Cleaned up misc. trash
;            Added Version and Rev     - Mike Vore
;
;
;
; 09/30/85 - Added "FULL SETUP"  routines (5-6-7-8 bits
;                                          No, Even, Odd parity
;                                          1- 1.5- 2 stopbits)
;            "BREAK" sent with 'esc' @ in terminal mode.
;            Disconnects modem with 'esc' N in terminal mode 
;                 by lowering HSO (Hand Shake Out), J4-P4  (for DTR)
;                 
;                                           - Mike Vore, W3CCV
;
;
; 12/23/83 - First version of this file		- Jerry Haigwood
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
TAB:		EQU	09H		;tab character
;
YES:		EQU	0FFH
NO:		EQU	0
;
BRKWT		EQU	3		;Break Wait Time Hundreds Of mSec
GBYTME		EQU	3		;Goodbye pause Hundreds of mSec
HNGUPT		EQU	2		;Hangup  pause Seconds
;
; Change the following information to match your equipment
; This is for the Little Board Serial Port B
;
PORT:		EQU	8CH
MODCTL1		EQU	PORT		;MODEM CONTROL PORT
MODDATP:	EQU	PORT-4		;MODEM DATA IN PORT
MODRCVB:	EQU	1		;BIT TO TEST FOR RECEIVE
MODRCVR:	EQU	1		;VALUE WHEN READY
MODSNDB:	EQU	4		;BIT TO TEST FOR SEND
MODSNDR:	EQU	4		;VALUE WHEN READY
CTC:		EQU	50H		;CTC addr
;
;
;
; MEX SERVICE PROCESSOR
;
MEX	EQU	0D00H		;ADDRESS OF THE SERVICE PROCESSOR
INMDM	EQU	255		;GET CHAR FROM PORT TO A, CY=NO MORE IN 100 MS
TIMER	EQU	254		;DELAY 100MS * REG B
TMDINP	EQU	253		;B=# SECS TO WAIT FOR CHAR, CY=NO CHAR
CHEKCC	EQU	252		;CHECK FOR ^C FROM KBD, Z=PRESENT
SNDRDY	EQU	251		;TEST FOR MODEM-SEND READY
RCVRDY	EQU	250		;TEST FOR MODEM-RECEIVE READY
SNDCHR	EQU	249		;SEND A CHARACTER TO THE MODEM (AFTER SNDRDY)
RCVCHR	EQU	248		;RECV A CHAR FROM MODEM (AFTER RCVRDY)
LOOKUP	EQU	247		;TABLE SEARCH: SEE CMDTBL COMMENTS FOR INFO
PARSFN	EQU	246		;PARSE FILENAME FROM INPUT STREAM
BDPARS	EQU	245		;PARSE BAUD-RATE FROM INPUT STREAM
SBLANK	EQU	244		;SCAN INPUT STREAM TO NEXT NON-BLANK
EVALA	EQU	243		;EVALUATE NUMERIC FROM INPUT STREAM
LKAHED	EQU	242		;GET NXT CHAR W/O REMOVING FROM INPUT
GNC	EQU	241		;GET CHAR FROM INPUT, CY=1 IF NONE
ILP	EQU	240		;INLINE PRINT
DECOUT	EQU	239		;DECIMAL OUTPUT
PRBAUD	EQU	238		;PRINT BAUD RATE
;
CONOUT	EQU	2		;SIMULATED BDOS FUNCTION 2: CONSOLE CHAR OUt
PRINT	EQU	9		;simulated BDOS function 9: print string
INBUF	EQU	10		;input buffer, same structure as BDOS 10
;
		ORG	100H
;
;
; Change the clock speed if needed, to match your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
				;This defines the DEFAULT SPEED when
				;loading the program, REG4 and CTC1
				;will be set at load time.
				;
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	NO	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	YES	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	NO	;yes=do not overwrite CCP		116H
                                ;no=overwrite CCP, Large ASCII captures
                                ; might need this set to NO
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
;
;
;	Next 8 DBs used in MDM7xx not by MEXxxx, kept here for 
;       reference only.
;         'esc'=Escape character defined with STAT ESC command.
;
BRKCHR:		DB	'@' ;'esc'-@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N' ;'esc'-N = Disconnect from the phone line	121H
LOGCHR:		DB	'x' ;'esc'-x = Send Key 'x' (defined by KEY) 	122H
LSTCHR:		DB	'P' ;'esc'-P = Toggle printer			123H
UNSAVE:		DB	'U' ;'esc'-U = Unstart input text capture	124H
TRANCHR:	DB	'T' ;'esc'-T = Transmit file to remote		125H
SAVECHR:	DB	'S' ;'esc'-S = Start input text capture		126H
EXTCHR:		DB	' ' ;'esc' - 'esc'  = Send escape character	127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port	     	12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	12		;				156H
;
;
LOGONPTR	DS	2		;FOR USER MESSAGE, NOT USED
;
;  DIALV will be overwritten by SM overlays
;
DIALV		DS	3		;reserved for dial routine jump
;  DISCV May be modified by SM overlays, depending on method of disconnect.
DISCV		JMP	DISCON		;disconnect modem
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$SETBAUD     JMP     STBAUD2		;set baud from dial overlay
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	171H
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETCMD		;				177H
JMP$SPCLMENU	RET ! NOP ! NOP		;
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER	DS	3		;				192H
;
; 
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
;
CLREOS:		LXI 	D,CLRLIN 	; To clear to End Of Screen
		MVI	C,PRINT	        ; Put Terminal Data at CLRLIN
		CALL	MEX
		RET
;
;
CLRSCN:		LXI	D,CLS		; Put Terminal Sequence for
		MVI	C,PRINT		; Screen Clear at CLS
		CALL	MEX
		RET
;
; END OF FIXED ADDRESS ----------------------------------
;

SYSVER:		LXI	D,VERSMSG
		MVI	C,PRINT
		CALL	MEX
		RET
;
VERSMSG:
		DB	'AMPRO LITTLE BOARD AND SERIES 100 COMPUTER'
		DB	' VERSION ',VER+'0','.', REV+'0',CR, LF,LF
		DB	'FULL SET COMMANDS !',CR,LF,LF,'$'
;
CLS  		DB	0,0,0,0,0,'$'   ; <<- set this and the next for
					;     your screen clear and line
					;     clear sequences.
CLRLIN		DB	0,0,0,0,0,'$'
;.....
;
;
;-----------------------------------------------------------------------
;.....
;
;
;
SENDBRK:	MVI	A,5
		OUT	PORT
		MVI	A,0FAh	; Send 'BREAK' command to DART
		OUT	PORT
		MVI	B,BRKWT	; Wait 
		CALL	MTIME
		MVI	A,5
		OUT	PORT
		LDA	REG5	; Send setup back to DART
		OUT	PORT
		RET
;.....
;
;
;
;.....
;
;
; The following is used to initialize the AMPRO Z80 DART port "B".
; Baud rate is initially set from MSPEED value
;
INITMOD:  DI		;no interupts during setup
	  LDA 	MSPEED	; get the initial MSPEED value and go
			; set the baud rate with it
	  CALL	PBAUD
;
NITSIO:	  DI		; All DART sets go here
;
	  MVI	A,04H	;write register 4 of DART 
	  OUT	PORT	;contol port
	  LDA	REG4	; mult, stop bits, parity bits
	  OUT	PORT	;	
;
	  MVI	A,03H	;write register 3 of DART
	  OUT 	PORT	;
	  LDA	REG3	; rcv n bits/char, rcv enable
	  OUT	PORT	;
;
	  MVI	A,05H	;write register 5 of DART
	  OUT	PORT	;
	  LDA	REG5	; BITS/CHAR, TX ENABLE, RTS ENABLE
	  OUT	PORT	;
;
	  MVI	A,45H	;counter mode,contol word time constant follows
	  OUT	CTC	;CTC channel 1
;
	  LDA	CTC1	; MULTIPLIER
	  OUT	CTC	;CTC channel 1
	  EI		;
	  RET
;
;------------------------------------------------------------
;
;;
;
; Disconnect Routine
;
; Disconnects by lowering J4-P4 (Hand Shake Out) -connect
;  to DTR on semi-smart modems like Novation J-Cat
;
;  Hangs up modem for 2 seconds
;
;
DISCON:	  MVI	A,5		;OUTPUT TXOFF,RXOFF,DTROFF TO 
	  OUT	PORT		;TO DART PORT 5
	  MVI	A,0
	  OUT   PORT
 	  MVI	B,HNGUPT*10		; WAIT 2 SEC
	  CALL  MTIME
	  MVI	A,5		; THEN RESET DART TO ORIGINAL STATUS
	  OUT	PORT
	  LDA	REG5
	  OUT	PORT
	  RET
;
;
;
; GOODBYE routines are called by MEX prior to exit to CP/M
;
GOODBYE:  MVI	B,GBYTME		;DELAY 300 MS.
	  CALL  MTIME
	  RET
;
;  SET COMMAND PROCESSOR
;
SETCMD:	  MVI	C,SBLANK	;ANY ARGUMENTS?
	  CALL	MEX
	  JC	SETSHO		;IF NOT, DISPLAY DEFAULTS
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
SETBAD:	  LXI	D,SETEMS
	  MVI	C,PRINT
	  CALL	MEX
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
	  DB 	'PULS','E'+80H		;SET PULSE FOR SM OVERLAY
	  DW	SWPULSE
	  DB	'TON','E'+80H		;SET TONE FOR SM OVERLAY
	  DW    SWTONE
	  DB	'$'			;TABLE TERMINATOR
;
;
;  "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL  MILP
	  DB	CR,LF
	  DB	'SET values:',CR,LF,0
          CALL	CRLF
	  CALL	MILP
	  DB	'Baud Rate: ',TAB,0
	  CALL	BDSHOW
	  CALL	CRLF
	  CALL  SHPRTY
	  CALL	CRLF
	  CALL	SHSTOP
	  CALL	CRLF
	  CALL  SHBITS
	  CALL	CRLF
	  CALL	SHDIAL
	  CALL  CRLF
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
	  DB	'4800, 9600'
	  DB    CR,LF,'SET PULSE     - For Pulse Dialing'
          DB    CR,LF,'SET TONE      - For Tone Dialing'
	  DB	CR,LF,CR,LF,0
	  RET
;
;
; "SET BAUD" processor
;
STBAUD:    MVI	C,BDPARS	;FUNCTION CODE: PARSE A BAUDRATE
	  CALL	MEX		;LET MEX LOOK UP CODE
	  JC	SETERR		;JUMP IF INVALID CODE
STBAUD2	  CALL	PBAUD		;NO, TRY TO SET IT
	  JC	SETERR		;IF NOT ONE OF OURS, BOMB OUT
	  CALL	NITSIO
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
	  STA	TSPEED		;put it in a safe spot
	  ADD	A		;double it for offset into table
	  MOV	E,A		;MSPEED CODE TO DE
	  MVI	D,0
	  LXI	H,BAUDTB	;OFFSET INTO TABLE
	  DAD	D
	  MOV	A,M		;FETCH CODE
	  ORA	A		;0 MEANS UNSUPPORTED CODE
	  STC			;PREP CARRY IN CASE UNSUPPORTED
	  JZ	PBEXIT		;EXIT IF BAD
	  STA	CTC1		;
	  INX	H
	  LDA	REG4
	  ANI	0FH
	  ORA	M
	  STA	REG4
	  LDA	TSPEED
	  STA	MSPEED
	  ORA	A		;RETURN NO ERRORS
PBEXIT:	  POP	B
	  POP	D
	  POP	H
	  RET
;
BAUDTB	DB	0,0		;110 (NOT SUPPORTED)
	DB	208,080H	;300
	DB	156,080h	;450 
	DB	208,040H	;600
	DB	0,0
	DB	104,040H	;1200
	DB	52,040H		;2400
	DB	26,040H		;4800
	DB	13,040H		;9600
	  DB	0FH		;19200 (Not Supported) 
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
;                       REG5--->Bit 6           Bit 5
;		    BPC	REG3--->Bit 7		Bit 6
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
	  DB	0		;<<== end of bit table
;
	  RET
;
;
;
SWPULSE:  MVI	A,'P'		; Put 'P' into Touch/Pulse byte
	  STA	TOUCHPULSE	; for SM Overlay to grab	
	  JMP	SHDIAL
;
SWTONE	  MVI	A,'T'		; Or put 'T' there
	  STA	TOUCHPULSE
	  
;
SHDIAL:	  LDA	TOUCHPULSE	; Grab Flag 
	  CPI	'T'		; if Tone then say so
	  JZ	TONED
	  CPI	'P'		; likewise if pulse
	  JZ	PULSED
	  LXI	D,BADFLA	; But if bad say so
	  MVI   C,PRINT		; should never get here, just for 
	  CALL	MEX		; safety
	  RET
TONED:	  LXI	D,TONEFLF
	  MVI	C,PRINT
	  CALL	MEX
	  RET
PULSED	  LXI	D,PULSEF
	  MVI	C,PRINT
	  CALL	MEX
	  RET
BADFLA:	  DB	'BAD TOUCH/PULSE FLAG',CR,LF,'$'
TONEFLF	  DB	'Tone Dial','$'
PULSEF    DB    'Pulse Dial','$'
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
;
;==========================================================================
;                            Data Area
;==========================================================================
;
; Default UART parameters (Initalized for  RS-232 port B)
;
REG3:	  DB	0C1H	;ENABLE RECEIVE AT 8 BITS/CHAR
REG4:	  DB	004H	;NO PARITY, 1 STOP, CLOCK RATE SET AT INITALIZE TIME
REG5:	  DB	06AH	;ENABLE TRANSMIT AT 8 BITS/CHAR
CTC1	  DB     0	;Also set at initalize time
;
; Miscellaneous Default Data
;
;
TSPEED	  DB	1		;TEMP SPEED AREA
;
;
	  END
