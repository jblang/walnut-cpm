; M7R3-1.ASM -- TRS-80 Model III w/Omikron Mapper overlay for MDM7xx
;  includes options for Lynx autodial modem and standard RS-232 board
; (should also work with Model 4 and CP/M 2.2)
; 01/15/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the TRS-80 (Zero ORG CP/M) computer to the modem pro-
; gram.  Much of  the information contained here is not in the MDM7xx.ASM
; file. Set the Lynx options switch to NO to run with the RS-232 board.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; With the Lynx, the "SET" command will force the modem to go
; on-line, but cannot change the fixed baud rate of 300. With RS-232,
; use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
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
;		-IM7R3-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4580 0000
;		-G0			(return to CP/M)
;		A>SAVE 69 MODEM7.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 01/15/84 - Revised for Model 3 and Lynx modem - Gary Phillips
; 11/11/83 - Renamed to M7R1-1.ASM, no changes	- Irv Hoff
; 08/27/83 - Revised to work with MDM712	- Irv Hoff
; 07/25/83 - Adapted for TRS-80 (zero ORG CP/M)	- Phil Becker
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - First version of this file		- Irv Hoff
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
; Change the following information to match your equipment
;
;PORT should be set to the base port address for either the Lynx or RS-232
PORT:		EQU	0E8H
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
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
LYNX:		EQU	YES	;yes if Lynx in use
PMMIMODEM:	DB	LYNX	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'P'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	21	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	4	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
		DS	1	;reserved (old ACKNAK flag)		10DH
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
;	note that ESC is SHIFT-BREAK under Omikron CP/M
EXTCHR:		DB	ESC	;ESC = Send next character		127H
;
;
;	a value of 55 gives a pulse rate of about 20/sec.
;	a higher value will slow the dialing down for older
;	phone systems.
PULSERATE:	DB	55	;pulse rate for dialing
CHGBAUD:	DB	'B'-40H	;will force Lynx on-line
				;from terminal mode
IN$MODCTL1:	IN	MODCTL1 	;in modem control port		12AH
		PUSH	B
		ANI	0DFH
		MOV	B,A		;save status
		JMP	CTLPT2		;continue
		DS	1
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
;
;
; CONTINUE STATUS READ
;
CTLPT2:		IN	PORT		;READ CD PORT
		ANI	MODDCDB		;ISOLATE CD
		ORA	B		;MERGE STATUS
		POP	B
		RET
;
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
	IF	LYNX
IN$BAUDRP:	JMP	DTIMER		;simulate PMMI timer
OUT$BAUDRP:	RET ! NOP ! NOP		;don't need this one
OUT$MODCTL1:	JMP	DIALHOOK	;dial port
	ENDIF
	IF	NOT LYNX
		DS	6
OUT$MODCTL1:	OUT	MODCTL1 ! RET	;out modem control port #1	15AH
	ENDIF
OUT$MODCTL2:	RET ! NOP ! NOP		;don't need this one		15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
JMP$DIAL:	DS	3		;autodial rtn jump			162H
JMP$DISCONNT:	JMP	GOODBYE		;disconnect rtn
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	JMP	SETUPR		;force Lynx on-line			16EH
JMP$NOPARITY:	RET ! NOP ! NOP		;(by-pass PMMI routine)		171H
JMP$PARITY:	RET ! NOP ! NOP		;(by-pass PMMI routine)		174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
; Do not change the following six lines.
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	1FH,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	1CH,1FH,0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'TRS-80 Model III W/Omikron Mapper',CR,LF
	IF	LYNX
		DB	'Lynx autodial modem',CR,LF
	ENDIF
		DB	0		;end msg
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
; CTL-L if TRANLOGON has been set TRUE.  You can use several lines if
; desired.  End with a 0.
;
LOGON:		DB	'This is a TRS-80 using CP/M',CR,LF,0
;.....
;
;
; Add your own routine here to send a break tone to reset some time-share
; computers, if desired.
;
SENDBRK:	MVI	A,0E3H		;send break
		JMP	GBYE1
;
; Add your own routine here to put DTR low and/or send a break tone.
; Check other routines such as MDM709DP.ASM which is using this feature.
;
	IF	LYNX
GOODBYE:
		XRA	A	;disconnect phone line
		OUT	BAUDRP
		RET
	ENDIF
	IF	NOT LYNX
GOODBYE:	MVI	A,0EBH	;DTR off, send BRK
	ENDIF
GBYE1:	  OUT	MODCTL1		;SEND CMD
	  MVI	B,3
	  CALL	JMP$TIMER	;DELAY 300 MS
	  MVI	A,0ECH		;NORMAL DTR ON
	  OUT	MODCTL1
	  RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
INITMOD:  MVI	A,1
	  OUT	PORT		;RESET RS232
	  MVI	A,0ECH		;8/N/1 DTR & RTS ON
	  OUT	MODCTL1
;
INITM1:	  MVI	A,1		;SET FILE XFER TIME
	  STA	MSPEED
;
	IF	NOT LYNX
INITM2:	  MVI	A,55H		;INIT TO 300 BAUD
	  OUT	BAUDRP
	ENDIF
	  RET
;
;.....
;
;  SETS THE MODEM SPEED VIA THE SET COMMAND.
;
	IF	NOT LYNX
SETUPR:	  LXI	D,BAUDBUF	;POINT TO INPUT BUFFER
	  CALL	JMP$ILPRT
	  DB	'INPUT BAUD RATE (300, 1200, 2400, 4800): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;TEST INPUT PARAM
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
	  CALL	JMP$ILPRT	;BAD PARAM
	  DB	'++ INCORRECT ENTRY ++',CR,LF,0
	  JMP	SETUPR		;TRY AGAIN
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
LOADBD:	  STA	INITM1+1	;CHANGE MSPEED PARAM
	  MOV	A,L		;GET BRG BYTE
	  STA	INITM2+1	;SET IT IN
	  JMP	INITM1		;REINIT BAUD RATE AND RET
;.....
;
;
; TABLE OF BAUD RATE PARAMS
;
BD300:	  DW	0055H
BD1200:	  DW	0077H
BD2400:	  DW	00AAH
BD4800:	  DW	00CCH
;
BAUDBUF:  DB	10,0
	  DS	10
	ENDIF
;.....
	IF	LYNX
SETUPR:	MVI	A,02H	;code to go on-line
	OUT	BAUDRP
	RET
;
DIALHOOK:		;flip dial hook
	ORA	A	;if A=0 put on hook
	JZ	DIALH2
	MVI	A,02H	;else take off hook
DIALH2:	OUT	BAUDRP
	RET
;
DTIMER:		;simulate PMMI timer function
	DB	0D9H	;Z-80 EXX instruction
	LDA	PULSERATE	;msec between flips
	MOV	B,A	;put in counter
DTIMER0:
	MVI	C,126	;delay for 1 msec @ 2MHz
DTIMER1:
	DCR	C
	JNZ	DTIMER1
	DCR	B
	JNZ	DTIMER0
	LDA	DCNT	;check last value passed
	ANI	80H	;was bit 7 set?
	JNZ	DTIMER2
	ORI	80H	;zero last time, set this
	JMP	DTIMER3
DTIMER2:
	XRA	A
DTIMER3:
	MOV	B,A	;save value
	IN	PORT	;check carrier detect value
	ANI	MODDCDB
	JZ	DTIMER4
	MVI	A,04H	;set PMMI carrier detect flag
DTIMER4:
	ORA	B	;add timer bit value
	DB	0D9H	;EXX to restore regs
	STA	DCNT
	RET		;return with flags
DCNT	DB	0
	ENDIF
;
; If using Smartmodem or Lynx this is unavailable without a special
; change.
;
SPCLMENU:  RET
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem or Lynx)
;				 0C00H (without Smartmodem)
;.....
;
	  END
