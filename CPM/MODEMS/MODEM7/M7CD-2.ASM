; M7CD-2.ASM	MODIFIED TO INIT AND CHANGE BAUD RATES ON THE TUART
;		SECOND PORT AT 20H
;               6/24/84 BY CARL AHLERS
; M7CD-1.ASM -- OVERLAY FOR CROMEMCO CDOS 2.54 OR GREATER COPIED
;               FROM M7GP-1.ASM DATED 11/11/83 BY FORD BUCKNER
; This is setup for use with a TUART board on PORT 50 driving a
; US ROBOTICS 212a modem.
;
; M7GP-1.ASM -- General purpose overlay file for MDM7xx.  11/11/83
;
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using an external modem that
; does not match one of the other special overlays.  You would use the
; normal CP/M "Configure" program to set the modem to whatever baud rate
; you would normally use (such as 300 or 1200, etc.)  Then perhaps just
; make a second .COM file if you need both 300 and 1200 and do not wish
; to write your own initialization or "set baud" routine.
;
; You could look at other overlay files to see how the GOODBYE and/or
; SETUPR areas are handled.  You could then adapt one of those, if ap-
; propriate for your equipment in this overlay.  Some examples:
;
;     "DP"  Datapoint 1560 overlay using 8251 I/O and CTC timers for
;	       setting baud rates
;     "H8"  Heath H89 overlay for 8250 I/O and programmable baud rates
;     "HZ"  Zenith 120 overlay for 2661B initialization and baud rates
;     "XE"  Xerox 820II overlay for Z80-SIO intialization, etc.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
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
;		-IM7GP-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/24/84 - Renamed to M7CD-2.asm              - Carl Ahlers
; 11/27/83 - Renamed to M7CD-1.asm              - Ford Buckner
; 11/11/83 - Renamed to M7GP-1.ASM, no changes	- Irv Hoff
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 07/01/83 - Revised to work with MDM710	- Irv Hoff
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
PORT:		EQU	050H
MODCTL1:	EQU	PORT		;MODEM CONTROL PORT
MODDATP:	EQU	PORT+1		;MODEM DATA IN PORT
MODDATO:	EQU	PORT+1		;MODEM DATA OUT PORT
MODCMDP:	EQU	PORT+2		;MODEM COMMAND PORT
MODMASK:	EQU	PORT+3		;MODEM INTERRUPT PORT
MODCTL2:	EQU	PORT+4		;2ND MODEM CONTROL PORT
BAUDRP:		EQU	PORT     	;BAUD RATE PORT
;
PORT@:		EQU	020H
MODCTL1@:	EQU	PORT@		;MODEM CONTROL PORT
MODDATP@:	EQU	PORT@+1		;MODEM DATA IN PORT
MODDATO@:	EQU	PORT@+1		;MODEM DATA OUT PORT
MODCMDP@:	EQU	PORT@+2		;MODEM COMMAND PORT
MODMASK@:	EQU	PORT@+3		;MODEM INTERRUPT PORT
MODCTL2@:	EQU	PORT@+4		;2ND MODEM CONTROL PORT
BAUDRP@:	EQU	PORT@    	;BAUD RATE PORT
;
MODDCDB:	EQU	2		;CARRIER DETECT BIT
MODDCDA:	EQU	2		;VALUE WHEN ACTIVE
MODRCVB:	EQU	40H             ;BIT TO TEST FOR RECEIVE
MODRCVR:	EQU	40H		;VALUE WHEN READY
MODSNDB:	EQU	80H		;BIT TO TEST FOR SEND
MODSNDR:	EQU	80H		;VALUE WHEN READY
;
STOPBIT:	EQU	80H		;SETS MSB=1 FOR ONE STOP BIT
BAUDRATE:	EQU	STOPBIT+08H	;1200 BAUD & ONE STOP BIT
RESET:		EQU	9		;RESET TU-ART
LOW$RNG:		EQU	0		;LOW BAUD RATE RANGE
HIGH$RNG:		EQU	10H		;HIGH BAUD RATE RANGE
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
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
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
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
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
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
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H

CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				156H
;
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port #2	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem control port #1	15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
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
		DB	1BH,'J',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	1BH,'E',0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Cromemco Version with TU-ART & 3102'
		DB	CR,LF,0
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
; desired.  End with a 0.
;
LOGON:		DB	'How are you today?',CR,LF,0
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SENDBRK:  RET
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBYE:  RET
;.....
;
;	
; CROMEMCO TU-ART initialization
;
INITMOD:  PUSH	B
	  MVI	A,RESET
	  ADI   LOW$RNG		;RESET AND SELECT BAUD RATE RANGE
	  MOV	B,A
	  OUT	MODCMDP@
	  MVI	A,BAUDRATE	;SET BAUD RATE
	  MOV	C,A
	  OUT	BAUDRP@
	  MVI	A,0		;SET FOR NO INTERUPTS
	  OUT	MODMASK@
;
INITMOD1: MOV	A,B		;RESET AND SELECT BAUD RATE RANGE
	  OUT	MODCMDP
;
INITMOD2: MOV	A,C		;SET BAUD RATE
	  OUT	BAUDRP
;
INITMOD3: MVI	A,0		;SET FOR NO INTERUPTS
	  OUT	MODMASK	
	  POP 	B
	  RET
;.....
;
;
; Setup routine to allow changing modem speed with the SET command.
;
SETUPR:
	  LXI	D,BAUDBUF	;POINT TO NEW INPUT BUFFER
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300,1200,2400,4800,9600,19200): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	  DB	'300',0
	  JNC	OK300		;GO IF GOT MATCH
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
	  CALL	JMP$INLNCOMP
	  DB	'19200',0
	  JNC	OK19200
	  CALL	JMP$ILPRT	;ALL MATCHES FAILED, TELL OPERATOR
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;TRY AGAIN
;
OK300:	  MVI	A,RESET
	  ADI	LOW$RNG
	  PUSH	B
	  MOV	B,A
	  LDA	BD300
          MOV	C,A
	  MVI	A,1		;MSPEED VALUE FOR FILE TRANFER TIME
	  JMP	LOADBD
;
OK1200:	  MVI	A,RESET
	  ADI	LOW$RNG
	  PUSH	B
	  MOV	B,A
	  LDA	BD1200
          MOV	C,A
	  MVI	A,5
	  JMP	LOADBD
;
OK2400:	  MVI	A,RESET
	  ADI	LOW$RNG
	  PUSH	B
	  MOV	B,A
	  LDA	BD2400
	  MOV	C,A
	  MVI	A,6
	  JMP	LOADBD
;
OK4800:	  MVI	A,RESET
	  ADI	LOW$RNG
	  PUSH	B
	  MOV	B,A
	  LDA	BD4800
	  MOV	C,A
	  MVI	A,7
	  JMP	LOADBD
;
OK9600:	  MVI	A,RESET
	  ADI	LOW$RNG
	  PUSH	B
	  MOV	B,A
	  LDA	BD9600
	  MOV	C,A
	  MVI	A,8
	  JMP	LOADBD
;
OK19200:  MVI	A,RESET
	  ADI	HIGH$RNG
	  PUSH	B
	  MOV	B,A
	  LDA	BD19200
	  MOV	C,A
	  MVI	A,9
;
LOADBD:	  STA	MSPEED		;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,M		;GET "MSP" BAUD RATE BYTE
	  JMP	INITMOD1	;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;.....
;
;
; Table of baud rate values
;
;BD300:	  DB	STOPBIT+4H	;300 baud + STOP BIT
;BD1200:  DB	STOPBIT+8H	;1200 baud + STOP BIT
;BD2400:  DB	STOPBIT+10H	;2400 baud + STOP BIT
;BD4800:  DB	STOPBIT+20H	;4800 baud + STOP BIT
;BD9600:  DB	STOPBIT+40H	;9600 baud + STOP BIT
;BD19200: DB	STOPBIT+10H	;19200 baud + STOP BIT 
;
BD300:	  DB	84H		;300 baud & ONE STOP BIT
BD1200:	  DB	88H		;1200 baud & ONE STOP BIT
BD2400:	  DB	90H		;2400 baud & ONE STOP BIT
BD4800:	  DB	0A0H		;4800 baud & ONE STOP BIT
BD9600:	  DB	0C0H		;9600 baud & ONE STOP BIT
BD19200:  DB	90H		;19200 baud & ONE STOP BIT (USE HIGH RANGE)
;
BAUDBUF:  DB	10,0
	  DS	10
;.....
;
;
; The following routine can be used as an auxiliary menu for notes of
; interest to a particular computer, etc.  If using the Hayes Smartmodem
; this is unavailable without a special address change.
;
SPCLMENU: RET
;.....
;
;
; NOTE:   MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
; 				  0C00H (without Smartmodem)
;
	  END
;
