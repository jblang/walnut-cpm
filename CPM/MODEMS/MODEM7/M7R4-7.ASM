; M7R4-7.ASM -- TRS-80 Model IV w/montezuma micro overlay for MDM7xx
; includes options for Hayes Smartmodem and the Anchor Mark XII.
; Will work with a standard external modem with no options selected.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the TRS-80 (Zero ORG CP/M) computer to the modem pro-
; gram.  Much of  the information contained here is not in the MDM7xx.ASM
; file. 
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It 
; defaults to 1200 baud for the Anchor or Smartmodem, 300 baud 
; for an external modem.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4580 0100
;		-IM7R4-7.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4580 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MODEM7.COM	(now have a modified .COM file)
;
;        OR you can use MLOAD24:
;
;		A>MLOAD24 M740.COM=MDM740.COM,M7R4-7.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 01/27/85 - Fixed disconnect problems		- Ed Richter
; 07/13/84 - Revised for MDM740 and MOD IV      - Ed Richter
; 11/11/83 - Renamed to M7R1-1.ASM, no changes	- Irv Hoff
; 08/27/83 - Revised to work with MDM712	- Irv Hoff
; 07/25/83 - Adapted for TRS-80 (zero ORG CP/M)	- Phil Becker
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - First version of this file		- Irv Hoff
; 06/30/85 - Fixed Break tone problem           - Richie Dervan
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
; Change the following information to match your equipment.
; PORT should be set to the base port address for the RS-232 port.
;
PORT:		EQU	0E8H		;MASTER RESET PORT
MODCTL1:	EQU	PORT+2		;MODEM CONTROL PORT
MODDATP:	EQU	PORT+3		;MODEM DATA IN PORT
MODDCDB:	EQU	20H		;CARRIER DETECT BIT
BAUDRP:		EQU	PORT+1		;BAUD RATE PORT
MODCTL2:	EQU	PORT+2		;2ND MODEM CONTROL PORT
MODRCVB:	EQU	80H		;BIT TO TEST FOR RECEIVE
MODRCVR:	EQU	80H		;VALUE WHEN READY
MODSNDB:	EQU	40H		;BIT TO TEST FOR SEND
MODSNDR:	EQU	40H		;VALUE WHEN READY
;
		ORG	100H
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMMODEM:	EQU	YES	;used for this ovlay with Hayes or Anchor
AUTDIAL:	DB 	YES    	;yes if HAYES Smartmodem or compatible
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	3	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	4	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	4	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
		DS	1	;reserved (old ACKNAK flag)		10DH
BAKUPBYTE:	DB	NO     ;yes=change any file same name to .BAK	10EH
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
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'K'-40H	;^K = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40h	;^^ = Send next character		127H
		DS	2
IN$MODCTL1:	JMP     STATSND		;go to "get status" 		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
IN$BAUDRP:	RET ! NOP ! NOP 	;by-pass this
OUT$BAUDRP:	RET ! NOP ! NOP		;don't need this one
OUT$MODCTL1:	OUT	MODCTL1 ! RET	;out modem control port #1	15AH
OUT$MODCTL2:	RET ! NOP ! NOP		;don't need this one		15DH
LOGONPTR:	DW	LOGON		;for user message.		160H
JMP$DIAL:	DS	3		;autodial rtn jump			162H
JMP$DISCONT:	DS	3		;disconnect rtn
JMP$GOODBYE:	JMP     GOODBYE		;go to disconnect		168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	RET ! NOP ! NOP		;by-pass this   		16EH
JMP$NOPARITY:	RET ! NOP ! NOP		;(by-pass PMMI routine)		171H
JMP$PARITY:	RET ! NOP ! NOP		;(by-pass PMMI routine)		174H
JMP$SETUPR:	JMP	SETUPR		;initialize USART and modem	177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;print header msg		17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
; Do not change the following six lines.
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	19H,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	1EH,19H,0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Trade 80 Modem 740 - Richie Dervan',CR,LF
		IF	SMMODEM
		DB	'Version for Hayes or compatible',CR,LF,0
		RET
		ENDIF
		DB	'Version for external modem',CR,LF,0
		RET
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
; CTL-L if TRANLOGON has been set TRUE.  You can use several lines if
; desired.  End with a 0.
;
LOGON:		DB	'RICHIE DERVAN',CR,LF,0
;
; Add your own routine here to send a break tone to reset some time-share
; computers, if desired.
;
SENDBRK:	MVI	A,0E9H		
		OUT	MODCTL1		;send break tone
 		MVI	B,3
		CALL	JMP$TIMER	;delay 300 msec
		MVI	A,0ECH
		OUT	MODCTL1		;reset RS232
		RET
;
; Routine to return status of the modem port
;
STATSND:	IN	MODCTL1		;in modem contol port
		PUSH 	B		;just in case
		ANI	0DFH		;isolate status and clear CD bit
		MOV	B,A		;save status
		IN 	PORT		;get CD bit
		ANI	MODDCDB		;isolate CD bit
		ORA	B		;merge CD with status
		POP	B		;restore B
		RET
;
; Add your own routine here to put DTR low and/or send a break tone.
;
GOODBYE:  LDA	AUTDIAL		;is it auto dial modem
	  ORA	A	
	  JNZ	GOODBY1		;yes then go to disconnect
	  MVI   A,0EBH		;no - DTR off, send BRK
          OUT	MODCTL1		;send cmd
	  MVI	B,3
	  CALL	JMP$TIMER	;delay 300 msec
	  MVI	A,0ECH
	  OUT	MODCTL1		;reset DTR 	
	  RET
;
GOODBY1:  MVI	A,0EAH      	;auto dial disconnect
	  OUT	MODCTL1		;drop dtr
	  MVI	B,3
	  CALL	JMP$TIMER	;delay 300 msec
	  MVI	A,0ECH		;reset DTR
	  OUT	MODCTL1
	  RET

;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
INITMOD:  MVI	A,1
	  OUT	PORT		;reset the USART to
	  MVI	A,0ECH		;8,no,1,DTR, and RTS
	  OUT	MODCTL1
	  LDA	MSPEED		;what speed was selected by MSPEED
	  CPI	1
	  JZ	OK300
	  CPI	5		;initialize to selected speed
	  JZ	OK1200
	  CPI	6
	  JZ	OK2400
	  CPI	7
	  JZ	OK4800
;
;Routine used to initialize and reset speed and baud rate
;
INIT1:	  MVI	A,0000H
	  STA	MSPEED
INIT2:	  MVI	A,0000H
	  OUT	BAUDRP
	  RET	  	  	  		
;
;sets the modem speed via the SET command.
;
SETUPR:   LXI	D,BAUDBUF	;point to input buffer
	  CALL	JMP$ILPRT
	  DB	'INPUT BAUD RATE (300, 1200, 2400, 4800, 9600): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;test input param
	  DB	'300',0
	  JNC	OK300
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$INLNCOMP
	  DB	'2400',0
	  JNC	OK2400
	  CALL	JMP$INLNCOMP
	  DB	'4800',0
	  JNC	OK4800
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
	  CALL	JMP$ILPRT	;bad parameter
	  DB	'+++ Baud rate not supported +++',CR,LF,0
	  JMP	SETUPR		;try again
;
OK300:	  MVI	A,1
	  LHLD	BD300
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400:	  MVI	A,6
	  LHLD	BD2400
	  JMP	LOADBD
;
OK4800:	  MVI	A,7
	  LHLD	BD4800
;
OK9600	  MVI	A,8
	  LHLD	BD9600
;
LOADBD:   STA	INIT1+1
	  MOV	A,L
	  STA	INIT2+1
	  JMP	INIT1
;
; TABLE OF BAUD RATE PARAMS
;
BD300:	  DW	0055H
BD1200:	  DW	0077H
BD2400:	  DW	00AAH
BD4800:	  DW	00CCH
BD9600:	  DW	00EEH
;
BAUDBUF:  DB	10,0
	  DS	10
;----------------------------------------------------------------------
; If using Smartmodem or Anchor this is unavailable without a special
; change.
;
SPCLMENU:  RET
;----------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem or Anchor)
;				 0C00H (without Smartmodem)
;
	  END
