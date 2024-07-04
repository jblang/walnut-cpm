
; M7C3-1.ASM -- CP/M Plus overlay file for MODEM7.  11/19/83
;
; This overlay adapts the MODEM7 program to use the auxiliary device
; in CP/M Version 3.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the Auxiliary device
; properly configured under CP/M 3.
;
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with MAC.COM or equivalent
;		assembler.  Then use SID to overlay the the results
;		of this program to the original .COM file:
;
;		A>SID MDM712
;		CP/M 3 SID - Version 3.0
;		NEXT MSZE  PC  END
;		4300 4300 0100 D3FF
;		#E M7C3-1.HEX		("E" loads in the .HEX file)
;		NEXT MSZE  PC  END
;		031E 4300 0100 D3FF
;		#W MDM712.COM,100,42FF	("W" writes the modified .COM file)
;		0084h record(s) written
;		#G0			(return to CP/M)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/19/83 - Edited M712GP.ASM for this file	- Jim Lopushinsky
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
BDOS:		EQU	5
DEVICE:		EQU	1	;CP/M's MODEM device number
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
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
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
SAVCCP:		DB	NO	;yes=do not overwrite CCP		116H
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
IN$MODCTL1:	RET			;			     	12AH
		DS	9
OUT$MODDATP:	JMP	AUXOUT		;out modem data port		134H
		DS	7
IN$MODDATP:	JMP	AUXIN		;in modem data port		13EH
		DS	7
ANI$MODRCVB:	RET			;				148H
		DS	2
CPI$MODRCVR:	JMP	AUXINST		;value of rcv. bit when ready	14BH
ANI$MODSNDB:	RET			;				14EH
		DS	2
CPI$MODSNDR:	JMP	AUXOUTST	;value of send bit when ready	151H
		DS	6		;				156H
;
OUT$MODCTL1:	RET			;				15AH
		DS	2
OUT$MODCTL2:	RET			;				15DH
		DS	2
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
JMP$TIMER	DS	3		;				192H
;
; 
; Routine to clear to end of screen.  If using CLREOS and CLRSCRN, set
; SCRNTEST to YES at 010AH (above).
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'k',0,0,0	;Setup for Adds Viewpoint	198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	12,0,0,0,0	;Setup for Adds Viewpoint	1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for CP/M Plus (Device '
		DB	DEVICE+'0',')'
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
LOGON:		DB	'The cow jumped over the moon',CR,0
;.....
;
;
; Add your own routine here to send a break tone to reset some time-share
; computers, if desired.
;
SENDBRK:	RET
;.....
;
;
; Add your own routine here to put DTR low and/or send a break tone.
; Check other routines such as MDM709DP.ASM which is using this feature.
;
GOODBYE:	RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.  You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
INITMOD:  	MVI	C,12
		CALL	BDOS	;Get version #
		CPI	30H
		JNC	ISCPM3
		CALL	JMP$ILPRT
		DB	'Requires CP/M Version 3',CR,LF,0
		RST	0

ISCPM3:		MVI	A,20	;BIOS return character I/O table function
		STA	FUNC
		MVI	C,50
		LXI	D,FUNC
		CALL	BDOS
		PUSH	H	;Save the table address for later
		LXI	H,7	;Offset to baud rate
		MVI	A,DEVICE
		ORA	A
		JZ	ISZERO
		LXI	D,8

DEVLP:		DAD	D
		DCR	A
		JNZ	DEVLP

ISZERO:		POP	D	;Get Table address
		DAD	D	;Form baud rate address
		SHLD	BAUDAD
		RET
;
SETUPR:	  	CALL	JMP$ILPRT
		DB	'Input Baud Rate (300, 1200, 9600 ,19200): ',0
		LXI	D,BAUDBUF
		CALL	JMP$INBUF
		LXI	D,BAUDBUF+2
		CALL	JMP$INLNCOMP
		DB	'300',0
		JNC	OK300
		CALL	JMP$INLNCOMP
		DB	'1200',0
		JNC	OK1200
		CALL	JMP$INLNCOMP
		DB	'9600',0
		JNC	OK9600
		CALL	JMP$INLNCOMP
		DB	'19200',0
		JNC	OK19200
		CALL	JMP$ILPRT
		DB	'++ Incorrect entry ++',CR,LF,BELL,0
		JMP	SETUPR

OK300:		MVI	A,1
		MVI	B,6
		JMP	LOADBD

OK1200:		MVI	A,5
		MVI	B,8
		JMP	LOADBD

OK9600:		MVI	A,8
		MVI	B,14
		JMP	LOADBD

OK19200:	MVI	A,9
		MVI	B,15

LOADBD:		STA	MSPEED
		LHLD	BAUDAD
		MOV	M,B
		LXI	H,DEVICE
		SHLD	BCREG
		MVI	A,21
		STA	FUNC
		MVI	C,50
		LXI	D,FUNC
		JMP	BDOS

AUXIN:		DB	0D9H	;EXX
		MVI	C,3
		CALL	BDOS
		DB	0D9H	;EXX
		RET

AUXOUT:		DB	0D9H	;EXX
		MVI	C,4
		MOV	E,A
		PUSH	PSW
		CALL	BDOS
		POP	PSW
		DB	0D9H	;EXX
		RET

AUXINST:	DB	0D9H	;EXX
		MVI	C,7
		CALL	BDOS
		DB	0D9H	;EXX
		INR	A	;Reverse sense
		RET

AUXOUTST:	DB	0D9H	;EXX
		MVI	C,8
		CALL	BDOS
		DB	0D9H	;EXX
		INR	A	;Reverse sense
		RET

BAUDBUF:	DB	10,0
		DS	2

FUNC:		DS	1
AREG:		DS	1
BCREG:		DS	2
DEREG:		DS	2
HLREG:		DS	2
BAUDAD:		DS	2
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
;
