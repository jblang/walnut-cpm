; M7PC-1.ASM -- Overlay for IBM PC With a Baby Blue Z80 CPU for MDM7xx.
; 11/11/83
;
; This overlay adapts the MDM7xx program to the IBM PC With a Baby Blue
; Z-80 CPU card.
;
; Some Z-80 code is used in this overlay to allow it to fit inside of
; 400H.  (Start of dialing routines.)  It is included by some EQU's at
; the beginning.  DO NOT REMOVE THEM.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; The 'SET' command can be used to change the baud rate to a selected
; value.  It comes up at 300 baud.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DEBUG DDT.COM
;		-G
;		DDT VERS 2.2
;		-I MDM7xx.COM	   (Original version with bound header)
;		-R
;		NEXT  PC
;		4300 0100
;		-IM7PC-1.HEX	   (note the "I" command)
;		-R		   ("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0		   (return to CP/M)
;		Program terminated normally
;		-RCS
;		CS xxxx		   (present code seg. pointer)
;		:1000		   (segment address of Baby Blue memory)
;		-RCS
;		CX xxxx
;		:4200		   (size of program to be saved)
;		-NMDM7xx.CPM	   (note extention .CPM not .COM)
;		-W		   (write the file)
;		Writing 4200 bytes
;		-Q		   (exit from debug)
;		A>BIND MDM7xx.CPM  (bind on the header to all programs
;					 to run under CP/M)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/11/83 - Renamed to M7PC-1.ASM, no changes	- Irv Hoff
; 09/04/83 - Adapted to IBM PC With a Baby Blue Z80 CPU from
;	     MDM710OT.ASM (Otrona)		- David Rounds
;	
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;======================Z80 BRANCH EQUATES===============================
;
;
BNC	EQU	30H
BZ	EQU	28H
BR	EQU	18H
BC	EQU	38H
BNZ	EQU	20H
;
;;; EXAMPLE OF USE OF Z80 BRANCH INSTRUCTIONS
;;;
;;;		ORG	100H
;;;
;;;  NEXT:  DB	 BR,START-NEXT-2 AND 0FFH  ;branch to start:
;;;  START: DB	 BR,NEXT-START-2 AND 0FFH  ;branch to next:
;;;
;;;	    END  100H
;;;
;=======================================================================
;
;
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
CLS:		EQU	1AH		;clear screen
;
;
; BDOS EQUATES
;
BDOS:		EQU	0005H
WRCON:		EQU	02H
RDCON:		EQU	01H
PUNCH:		EQU	04H
;
;
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
PORT		EQU	03F8H
MODCTL1		EQU	PORT+3		;line control register
MODCTL2		EQU	PORT+4		;modem control register
MODDATO		EQU	PORT		;data out port
MODDATP		EQU	PORT		;data in port
MODST1		EQU	PORT+5		;line status register
MODST2		EQU	PORT+6		;modem status register
;
MODRCVB		EQU	01H
MODRCVR		EQU	01H
MODSNDB		EQU	20H
MODSNDR		EQU	20H
;
;
		ORG	100H
;
;
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	25	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=allow toggling of printer on/off	119H
;
;
; Change the following to match the needs of the computer you will be
; to using terminal (T) (non-protocal)
;
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
;
;
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'U'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODST1:	CALL	XSTATUS ! RET	;read status port 1		12AH
		DS	6
OUT$MODDATP:	CALL	XOUTPUT ! RET	;write to output		134H
		DS	6
IN$MODDATP:	CALL	XINPUT ! RET	;read from input		13EH
		DS	6
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H

CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				156H
;
OUT$MODCTL1	JMP	CONTRL1		;write to control port #1	15AH
OUT$MODCTL2:	JMP	CONTRL2		;write to control port #2	15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
;
		RET  !	NOP  !	NOP	; bypass PMII routine		16EH
		RET  !	NOP  !	NOP	; bypass PMII routine		171H
		RET  !	NOP  !	NOP	; bypass PMII routine		174H
;
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
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
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'Y',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	CLS,0,0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	CR,LF,'IBM PC  With Baby Blue CP/M card'
		DB	CR,LF,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can use several lines if
; desired.  End with a 0
;
LOGON:	  DB	'Hello from an IBM-PC with Baby Blue CP/M Card'
	  DB	CR,LF,0
;.....
;
;
;  IBM-PC AUX PORT CONTROL PORT OUTPUT ROUTINES
;
CONTRL1:  PUSH	H
	  PUSH	D
	  PUSH	B
	  MOV	E,A
	  LXI	H,3FBH
	  MVI	C,0FEH
	  CALL	BDOS
	  POP	B
	  POP	D
	  POP	H
	  RET
;.....
;
;
CONTRL2:  PUSH	H
	  PUSH	D
	  PUSH	B
	  MOV	E,A
	  LXI	H,3FCH
	  MVI	C,0FEH
	  CALL	BDOS
	  POP	B
	  POP	D
	  POP	H
	  RET
;.....
;
;
XSTATUS:  PUSH	H
	  PUSH	D
	  PUSH	B
	  LXI	H,MODST1
	  MVI	C,0FFH
	  CALL	BDOS
	  POP	B
	  POP	D
	  POP	H
	  RET
;.....
;
;
XOUTPUT:  PUSH	H
	  PUSH	D
	  PUSH	B
	  MOV	E,A
	  LXI	H,MODDATP
	  MVI	C,0FEH
	  CALL	BDOS
	  POP	B
	  POP	D
	  POP	H
	  RET
;.....
;
;
XINPUT:	  PUSH	H
	  PUSH	D
	  PUSH	B
	  LXI	H,MODDATP
	  MVI	C,0FFH
	  CALL	BDOS
	  POP	B
	  POP	D
	  POP	H
	  RET
;.....
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,43H		;send a break tone
	  CALL	OUT$MODCTL1
	  JMP	GOODBYE1
;.....
;
;
; Set DTR low for 300 ms. to disconnect some modems
;
GOODBYE:  MVI	A,0		;turn off DTR	
	  CALL	OUT$MODCTL2
;
GOODBYE1: MVI	B,3		;wait for 300 ms.
	  CALL	JMP$TIMER
	  MVI	A,3		;restore to normal, DTR on, 8 bits, etc.
	  CALL	OUT$MODCTL1
	  MVI	A,1
	  CALL	OUT$MODCTL2
	  RET
;.....
;
;
; The following is the initialization routine for the IBM-PC with a Baby
; Blue Z-80 CPU:
;
;
INITMOD:  LXI	H,BD1200	;set initial baud rate to 1200 baud.
	  JMP	LOADBD
;.....
;
;
; Setup routine to allow changing modem speed with the set command.
;
SETUPR:	  LDAX	D		;get input buffer length
	  INX	D		;increment pointer past entered command
	  INX	D		;increment pointer past entered command
	  INX	D		;increment pointer past entered command
	  INX	D		;increment pointer past entered command
	  INX	D		;increment pointer past entered command
	  CPI	3		;length of "set" command
	  JNZ	SETUPX		;process entered speed
	  LXI	D,BAUDBUF	;point to new input buffer
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (110,300,600,1200,2400,'
	  DB	'4800,9600,19200): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
;
SETUPX:	  CALL	GETPOINT	;get pointer in 'B'
	  MOV	A,B
	  CPI	0FFH
;
SET1:	  DB	BNZ,SET2-SET1-2 AND 0FFH ;jmp if no error
	  CALL	JMP$ILPRT
	  DB	'Bad Baud Rate Selection',CR,LF
	  DB	'Present Speed Unchanged.',CR,LF,LF,0
	  RET
;...
;
;
SET2:	  LXI	H,BD110		;get starting address of table
	  DAD	B		;add offset
	  DAD	B		;...
	  MOV	A,C		;baud rate code
	  STA	MSPEED		;save it for reference
;
LOADBD:   PUSH	H		;save pointer to divisor
	  MVI	A,80H		;set flag to access divisor register
	  CALL	OUT$MODCTL1
	  POP	H
	  PUSH	H
	  MOV	E,M
	  LXI	H,3F8H
	  MVI	C,0FEH
	  CALL	BDOS
	  POP	H
	  INX	H
	  MOV	E,M
	  LXI	H,3F9H
	  MVI	D,0FEH
	  CALL	BDOS
	  MVI	A,3		;set communications parameters..
	  CALL	OUT$MODCTL1	;..no parity, 8 bits
	  MVI	A,1
	  CALL	OUT$MODCTL2	;enable dtr
	  RET
;.....
;
;
; Subroutine to get baud table entry number in 'B'
;
GETPOINT: LXI	B,0		;first entry=0
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'110',0
	  RNC			;go if got match
	  INX	B		;first is entry 0
	  CALL	JMP$INLNCOMP
	  DB	'300',0
	  RNC			;go if got match
;
	  INX	B
	  CALL	JMP$INLNCOMP
	  DB	'600',0
	  RNC			;go if got match
;
	  INX	B
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  RNC			;go if got match
;
	  INX	B
	  CALL	JMP$INLNCOMP
	  DB	'2400',0
	  RNC			;go if got match
;
	  INX	B
	  CALL	JMP$INLNCOMP
	  DB	'4800',0
	  RNC			;go if got match
;
	  INX	B
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  RNC			;go if got match
;
	  INX	B
	  CALL	JMP$INLNCOMP
	  DB	'19200',0
	  RNC			;go if got match
;
	  MVI	B,0FFH		;all matches failed
	  RET
;....
;
;
; Table of baudrate divisors
;
;
;
BD110:	  DW	1047
BD300:	  DW	384
BD600:	  DW	192	
BD1200:	  DW	96
BD2400:   DW	48
BD4800:   DW	24
BD9600:	  DW	12
BD19200:  DW	6
;
;
BAUDBUF:  DB	10,0
	  DS	10
;.......
;
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU:  RET
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;.....
;
	  END
LNCOMP
	  DB	'300',0
	  RNC			;go if