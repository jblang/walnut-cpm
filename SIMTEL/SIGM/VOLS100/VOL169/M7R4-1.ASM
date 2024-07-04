; M7R4-1.ASM -- Tandy TRS-80 Mod 4 under Montezuma Micro's CP/M 2.2
;		overlay file for MDM716 -- 01/08/84
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Tandy Model 4 computer to the modem program.
; Much of the information contained here is not in the main file.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the MDM716 "SET" command to change the baudrate when desired.  It
; starts out at 300 baud when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM716.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4300 0100
;		-IM7R4-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 69 MDM716.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 01/08/84 - Fixed to support all baud rates	- Richard Press, M.D.
; 11/26/83 - Modified for the TRS80 Mod 4	- Steven J. Davidson, M.D.
; 08/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/25/83 - Adapted for TRS-80 (zero ORG CP/M)	- Phil Becker
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/25/83 - Updated to work with MDM709	- Irv Hoff
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
PORT:		EQU	0EAH		;TRS80 Mod 4 Modem Status Port
MODCTL1:	EQU	PORT		;Modem status port
MODCTL2:	EQU	PORT		;Modem control port
MODDATP:	EQU	PORT+1		;Modem data port
MODDCDB:	EQU	20H		;CARRIER DETECT BIT
MODDCDA:	EQU	20H		;VALUE WHEN ACTIVE
BAUDRP:		EQU	PORT-1		;Baud rate port
MODRCVB:	EQU	80H		;Recv. Ready Mask bit
MODRCVR:	EQU	80H		; -value when ready
MODSNDB:	EQU	40H		;XMIT. READY MASK bit
MODSNDR:	EQU	40H		; -value when ready
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;

PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem			104H
TONEPULSE:	DB	'T'	;T=tone, P=Pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	3	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	3	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after a non-ACK	10DH
				;no=resend a record only after NAK
BAKKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
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
LOCONEXTCHR:	DB	YES	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	19H
XOFFTST:	DB	NO	;yes=chcks for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR		DB	'@'-40H	;Send a 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'T'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'Y'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'R'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'@'-40H	;^@ = Send next character		127H
;
;
		DS	2		;				128H
;
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
CTLPT2:		IN	0E8H		;READ CD PORT
		ANI	20H		;ISOLATE CD
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
		DS	6		;				156H
;
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port #2	15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem control port #1	15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	16EH
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	171H
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	174H
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
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	; 				195H
		DB	019H,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	01AH,0,0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'*** Version for Tandy TRS80 Mod 4 ***'	
		DB	'*** with Montezuma Micro CP/M 2.2 ***'
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
; CTL-O if TRANLOGON has been set YES.  You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:	  DB	'Hello, This is a TRS80 Mod 4 computer',CR,LF,0
;
;=======================================================================
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:
	MVI	A,0E8H		; 8 bit words, 1 stop bit, no parity,
	JMP	GOODBYE1	; DTR & RTS disabled, *BREAK bit SET*
;
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:
;
	MVI	A,0EBH			;SEND BREAK, TURN OFF DTR
;
GOODBYE1:
;
	OUT	MODCTL1		;SEND TO STATUS PORT
	MVI	B,3		;DELAY ABOUT 300 MS.
	CALL	JMP$TIMER
	MVI	A,0ECH		;NORMAL SEND/RECEIVE WITH DTR
	OUT	MODCTL1		;SEND TO STATUS PORT
	RET
;
;
; TRS80 Mod 4 initialization -- sets CTC timer 0 for baudrate in/out.
;
; TRS80 Mod 4 specific equates for initialization.
;
CTCCMD:	  EQU	0E8H		;Master Reset, UART cntrl. register
CTC0:	  EQU	0E9H		;BR19411 Timer control Timer 0 (port A)
IB300	  EQU	55H		;Default 300 baud
;
INITMOD:  MVI	A,1		;Reset UART and enable it
	  OUT	CTCCMD		
;
	  MVI	A,0ECH		;8 bits, no parity, 1 stop bit, enable DTR
	  OUT	MODCTL1		;				and RTS
;
LSBD:	  MVI	A,IB300
	  OUT	CTC0  
;
INITMOD1: MVI	A,1		;DEFAULT TRANSFER TIME TO 300 BAUD
	  STA	MSPEED
	  RET
;
;.....
;
;
SETUPR:	  LXI	D,BAUDBUF	;POINT TO NEW INPUT BUFFER
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 600, 1200, '
	  DB	'4800, 9600, 19200): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	  DB	'300',0
	  JNC	OK300		;GO IF GOT MATCH
	  CALL	JMP$INLNCOMP
	  DB	'600',0
	  JNC	OK600
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
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
OK300:	  MVI	A,1		;MSPEED 300 BAUD VALUE
	  LHLD	BD300		;GET 300 BAUD PARAMETERS IN 'HL'
	  JMP	LOADBD		;GO LOAD THEM
;
OK600:    MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP   LOADBD
;
OK4800:	  MVI	A,7
	  LHLD	BD4800
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD
;
OK19200:  MVI	A,9
	  LHLD	BD19200		;FALL THRU.....
;
LOADBD:	  STA	INITMOD1+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  MOV	A,L		;GET BAUDRATE BYTE
	  STA	LSBD+1		;STORE IN INITMOD
	  JMP	LSBD		;REINITIALIZE TO NEW BAUDRATE, THEN DONE
	  RET		
;
;
; TABLE OF BAUDRATE PARAMETERS
;
BD300:	DB	55H		;  300 BAUD
BD600:	DB	66H		;  600 BAUD
BD1200:	DB	77H		; 1200 BAUD
BD4800:	DB	0CCH		; 4800 BAUD
BD9600:	DB	0EEH		; 9600 BAUD
BD19200:
;
	DB	0FFH		;19200 BAUD
;
BAUDBUF:  DB	10,0
	  DS	10
;
;	       (END OF INITMOD AND SETUP ROUTINES)
;=======================================================================
;		
;
; These routines can be used for your equipment, be sure to end with RET
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU: RET
;		
;=======================================================================
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;                                0BC0H (without Smartmodem)
;
	  END
;
