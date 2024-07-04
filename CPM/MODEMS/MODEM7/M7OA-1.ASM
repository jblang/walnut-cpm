; M7OA-1.ASM -- Otrona Attache overlay file for MDM7xx - 11/11/83
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Otrona Attache computer to MDM7xx.
;
; Much of the information contained here is not in the MDM7xx.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the SET command to change baud rate if needed.  This updates the
; CMOS RAM value.  When the program is first called used, the baud rate
; is the same as currently set by the Valet function.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4300 0100
;		-IM7OA-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/11/83 - Renamed to M7OA-1.ASM, no changes	- Irv Hoff
; 09/01/83 - Updated to work with MDM712	- Irv Hoff
; 08/27/83 - Added optional BIOS patch		- Arley Dealey
; 06/30/83 - Revised to work with Otrona	- Arley Dealey
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 03/03/83 - Modified MDM705KP for XEROX
;	     820-II computers with external
;	     modems				- David Wurz	
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
BDOS		EQU	005H
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
WARMSTART:	EQU	0000H
;
;
PORT:		EQU	0F0H		;Otrona Attache modem port
MODCTL1:	EQU	PORT+1		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+1		;Modem status port
MODRCVB:	EQU	01H		;Your bit to test for receive
MODRCVR:	EQU	01H		;Your value when receive ready
MODSNDB:	EQU	04H		;Your bit to test for send
MODSNDR:	EQU	04H		;Your value when send ready
;
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
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
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of LOGON	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=allow toggling of printer on/off	119H
XOFFTST:	DB	NO	;yes=check for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'\'-40H	;\ = Send a 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^J = Send logon		(LF)	122H
LSTCHR:		DB	'P'-40H	;^L = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^T = Close input text buffer	(DC4)	124H
TRANCHR:	DB	'T'-40H ;^F = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^R = Open input text buffer    (DC2)	126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
IN$MODCTL1:	MVI	A,010H		;				12AH
		OUT	MODCTL1
		IN	MODCTL1		;get the status bits
		RET
		DS	3
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				154H
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port 	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem status port		15DH
;
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !	NOP  !	NOP	;by-passes PMMI routine		16EH
		RET  !	NOP  !	NOP	;by-passes PMMI routine		171H
		RET  !	NOP  !	NOP	;by-passes PMMI routine		174H
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
JMP$TIMER:	DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'J',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'K',0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:	  CALL	JMP$ILPRT		;				1A7H
		DB	'Version for Otrona Attache, comm. port 0F0H'
		DB	CR,LF,0
		RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H if using the
;	 Hayes Smartmodem or by address 0C00H otherwise.
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:	  DB	'This is an Otrona Attache computer',CR,LF
	  DB	0
;.....
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SENDBRK:  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0F8H		;SEND A BREAK TONE
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBYE:  MVI	A,5
	  OUT	MODCTL1		;SEND TO THE STATUS PORT
	  MVI	A,68H		;TURN OFF DRT, SEND BREAK
;
GOODBYE1: OUT	MODCTL1
	  MVI	B,3		;WAIT FOR 300 MS.
	  CALL	JMP$TIMER
	  MVI	A,5
	  OUT	MODCTL1
	  MVI	A,0E8H		;RESTORE TO NORMAL, 8 BITS, DTR ON, ETC.
	  OUT	MODCTL1
	  RET
;.....
;
;	
; Otrona Attache initialization
;
; The following is an Otrona BIOS patch written by Allen Edwards.  The
; LISTST routine in the standard BIOS has two errors which prevent it
; from it from working correctly.  This patch does not support printer
; redirection via the IOBYTE.
;
INITMOD:  LHLD	00000H+1	;get BIOS warm boot vector
	  LXI	D,02AH+1	;offset to LISTST
	  DAD	D		;add offset to vector
	  SHLD	HACK1+1		;*** MODIFY THE CODE ***
;
HACK1:	  LHLD	0D000H		;'HL' now has pointer to LISTST
	  XCHG			;move it to 'DE'
	  LXI	B,NEWCODE	;point to new code with 'BC'
;
PTCHLP:	  LDAX	B		;get next byte of new code
	  ORA	A		;done?
	  JZ	INITMOD1	;yes, go finish init...
	  STAX	D		;no, so put in the byte
	  INX	B		;update the pointers
	  INX	D
	  JMP	PTCHLP		;and go do next byte
;
;
; New code for LISTST
;
NEWCODE:  MVI	A,010H
	  OUT	0F3H
	  IN	0F3H
	  ORI	0DBH		;turn on all bits except CTS & TxRE
	  CPI	0FFH		;check for both CTS & TxRE true
	  RZ			;if so, printer ready, return A=0FFH
	  XRA	A		;else not ready so return with A=0
	  RET
;
	  DB	0		;sentinel for end of patch
	   ENDIF
;
;
; Read current communications baud & set MDM7xx variable
;
INITMOD1: MVI	C,9		;BDOS string output request
	  LXI	D,INITMSG0
	  CALL	BDOS
;
BDRQST:	  MVI	C,6		;BDOS direct console i/o request
	  MVI	E,0FFH		;direct console input request
	  CALL	BDOS		;get communication port baud
	  ORA	A		;anything in the buffer yet?
	  JZ	BDRQST		;no, wait until there is...
	  ANI	00FH		;mask off high nybble
	  CPI	0		;75 baud?
	  JZ	BADBAUD		;yes, its bogus...
	  CPI	2		;134.5 baud?
	  JZ	BADBAUD		;yes, thats bogus too...
	  CPI	3		;150 baud?
	  JZ	BADBAUD		;and so is this one...
	  CPI	4		;300 baud?
	  JNZ	CHK600		;no, skip ahead...
	  MVI	A,1		;special case, set it for 300 baud
	  JMP	INITEXIT
;
CHK600:	  CPI	5		;600 baud?
	  JNZ	ADJUST		;no, skip ahead...
	  MVI	A,3		;special case, set it
	  JMP	INITEXIT	;and get out...
;
ADJUST:	  DCR	A		;adjust it to MDM712 value
;
INITEXIT: STA	MSPEED		;save the baud value
	  RET
;.....
;
;
INITMSG0: DB	018H		;clear keyboard buffer
	  DB	ESC,'?',8	;read communications baud
	  DB	'$'
;
BADBAUD:  CALL	JMP$ILPRT
	  DB	CR,LF
	  DB	ESC,'U"'	;set highlight attribute
	  DB	'++ Invalid baud ++'
	  DB	ESC,'U '	;clear all attributes
	  DB	CR,LF,LF,BELL
	  DB	0
;
;
; Setup routine to allow changing modem speed with the SET command.
;
SETUPR:	  LXI	D,BAUDBUF	;point to new input buffer
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 600, 1200, 9600, 19200): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'300',0
	  JNC	OK300		;go if got match
	  CALL	JMP$INLNCOMP
	  DB	'600',0
	  JNC	OK600
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$INLNCOMP
	  DB	'19200',0
	  JNC	OK19200
	  CALL	JMP$ILPRT	;all matches failed, tell operator
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;
OK300:	  MVI	A,1
	  CALL	PREAMBLE
	  LDA	BD300
	  JMP	SETBDEXIT
;
OK600:	  MVI	A,3
	  CALL	PREAMBLE
	  LDA	BD600
	  JMP	SETBDEXIT
;
OK1200:	  MVI	A,5
	  CALL	PREAMBLE
	  LDA	BD1200
	  JMP	SETBDEXIT
;
OK9600:	  MVI	A,8
	  CALL	PREAMBLE
	  LDA	BD9600
	  JMP	SETBDEXIT
;
OK19200:  MVI	A,9
	  CALL	PREAMBLE
	  LDA	BD19200
;
;
; Fall into SETBDEXIT
;
SETBDEXIT:MVI	C,6		;BDOS direct console i/o request
	  MOV	E,A		;move char to 'E' reg. for output
	  CALL	BDOS		;direct I/O to prevent tab expansion
	  CALL	JMP$ILPRT	;set new baud from COMOS RAM parameter
	  DB	ESC,'<'
	  DB	0
	  RET
;.....
;
;
PREAMBLE: STA	MSPEED		;set the appropriate file transfer speed
	  MVI	C,9		;BDOS string output request
	  LXI	D,SETBDMSG
	  PUSH	B
	  CALL	BDOS
	  POP	B
	  RET
;.....
;
;
; Table of Otrona baud parameters
;
BD110:	  DB	001H
BD300:	  DB	004H
BD600:	  DB	005H	
BD1200:	  DB	006H
BD9600:	  DB	009H
BD19200:  DB	00AH
;.....
;
;
; Control message to set new baud
;
SETBDMSG: DB	ESC,'@',8	;write communications baud
	  DB	'$'
;
;
; Control message to enable new baud
;
NEWBDMSG: DB	ESC,'<'		;set communications baud from CMOS RAM
	  DB	'$'
;
;
; Input buffer for baud specification
;
BAUDBUF:  DB	10,0
	  DS	10
;
;-----------------------------------------------------------------------
;
; The following routine can be used as an auxiliary menu for notes of
; interest to a particular computer, etc.  If using the Hayes Smartmodem
; this is unavailable without a special address change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
;
	  END
