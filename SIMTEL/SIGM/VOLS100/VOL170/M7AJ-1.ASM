
; M7AJ-1.ASM Apple J-CAT modem overlay file for MDM7xx - 11/11/83
;
;			  NOTICE
;
; This file is a patch of the M712AP.ASM overlay designed to allow auto-
; dialing through a Novation J-Cat modem and to provide for more than
; one "logon" message.
;
; Some of the patches here rely on addresses within the main body of the
; MDM7xx12.COM file.  They are correct addresses for the copy of MDM712
; that I downloaded from Oxgate in October 1983.  However, there is no
; guarantee that those addresses will be the same if the main program is
; updated.
;
; The equates and patches in this file are set up for the combination of
; an Apple Super Serial Card in slot 2, with a Novation J-Cat modem.  The
; J-cat is 300-baud only, so I have eliminated the routine for changing
; baud rate that was in the original Apple overlay.
;
; In order to dial with the J-Cat, the modem's OHK line (pin 7 on the
; modem's card-edge connector; blue unconnected line in the DB25 con-
; nector provided with the modem) must be connected to the Apple's
; AN(0) annunciator (pin 15 on the game I/O socket). {Actually, it
; could be connected to one of the other annunciator ports, if the
; "onhook" and "offhook" equates below are changed to refer to that
; annunciator.}
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  
; This overlay file enables Apple II computers with the Apple Super
; Serial card and external modem to use the MDM712 phone modem program.
; It also supports the following Apple modem configurations:
;
;	a) CCS 7710 serial interface and external modem
;	b) SSM serial interface and external modem
;	c) Apple communications interface and external modem
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; Much of the information contained here is not in the MDM712.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up.
;
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
;		-IM7AJ-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/11/83 - Renamed to M7AJ-1.ASM, no changes	- Irv Hoff
; 10/06/83 - Multiple logon messages		- D. W. Walker
; 10/04/83 - J-Cat dialing routines added	- D. W. Walker
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 02/12/83 - Used MDM703CF to make this file
;	     for Apple computers using a var-
;	     iety of serial interface cards
;	     with external modem.		- Bruce Kargol
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H	;bell
CR:		EQU	0DH	;carriage return
ESC:		EQU	1BH	;escape
LF:		EQU	0AH	;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
;
CCS:		EQU	NO	;YES for CCS 7710
COMCARD:	EQU	NO	;YES for Apple comcard
SSC:		EQU	YES	;YES for Super Serial Card
SSM:		EQU	NO	;YES for SSM serial card
;
		 IF	CCS
MODDATP:	EQU	0E0A1H	;data port of CCS 7710
MODCTL1:	EQU	0E0A0H	;status port of CCS 7710
	 	 ENDIF		;endif CCS
;
		 IF	COMCARD
MODDATP:	EQU	0E0AFH	;data port of Comcard
MODCTL1:	EQU	0E0AEH	;status port of Comcard
		 ENDIF		;endif Comcard
;
		 IF	SSM
MODDATP:	EQU	0E0A5H	;data port of SSM
MODCTL1:	EQU	0E0A4H	;status port of SSM
		 ENDIF		;endif SSM
;
		 IF	SSC
MODDATP:	EQU	0E0A8H	;data port of Apple Super Serial Card 
MODCTL1:	EQU	0E0A9H	;modem status port of Super Serial Card
MODRCVB:	EQU	08H     ;bit to test for received data
MODRCVR:	EQU	08H     ;modem receive ready
MODSNDB:	EQU	10H	;bit to test for ready to send
MODSNDR:	EQU	10H	;modem send ready bit
		 ENDIF		;endif SSC
;
;
; Apple status bit equates for CCS, Comcard and SSM
;
		 IF	NOT SSC
MODSNDB:	EQU	02H	;bit to test for send
MODSNDR:	EQU	02H	;value when ready
MODRCVB:	EQU	01H	;bit to test for receive
MODRCVR:	EQU	01H	;value when ready
		 ENDIF		;not SSC
;
;
; We have software control over the Super Serial Card so allow INITMOD
; SETUPR routines.
;
;
		ORG	100H
;
;
; Change the clock speed to match your equipment
;
		DS	3	;(for  "JMP   START" instruction)
;
; J-Cat dialing routines patched over PMMI routines {DWW 10-04-83}
;
PMMIMODEM:	DB	YES	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-pmmi	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	3	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	NO	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in'	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	NO 	;yes=do not overwrite CCP		116H
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
		DS	2		;				128H
;
IN$MODCTL1:	LDA	MODCTL1 ! RET	;in modem control port		12AH
		DS	6
OUT$MODDATP:	STA	MODDATP ! RET	;out modem data port		134H
		DS	6
IN$MODDATP:	LDA	MODDATP ! RET	;in modem data port		13EH
		DS	6		;spares if needed
;
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
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
JMP$TIMER:	DS	3		;				192H
;
;
CLREOS:		CALL	JMP$ILPRT	;				195H
EOSCLR:		DB	esc,'Y',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	esc,'*',0,0,0	;				1A1H
		RET			;				1A6H
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Apple II with J-Cat modem'
		DB	CR,LF,0
		RET
;.....
;
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
;
; Pad each message with nulls to make 20 bytes, so new logon routine can
; find the right one
;
;   ^L1 will send first message to modem,
;   ^L2 will send second message, and so on
;
LOGON:	DB	'The Source......',CR,0,0,0
	DB	'Compuserve...',CR,0,0,0,0,0,0
	DB	'Etc...',CR,0,0,0,0,0,0,0,0,0,0,0,0,0
;
NUMLOGS:EQU	3		;number of valid logon messages
STAT:	EQU	2595H		;keypress routine
GETCHR:	EQU	25A0H		;get typed char
TYPE:	EQU	25B4H		;send char to console
;
LOGSELCT:
	PUSH	B
	PUSH	D
	LXI	H,LOGON
	LXI	D,20
;
KYLP:	CALL	STAT		;wait for next keypress
	JZ	KYLP
	CALL	GETCHR		;get key
	CPI	'1'		;in range?
	JC	NOGOOD
	CPI	NUMLOGS+'0'+1
	JNC	NOGOOD
	SUI	'0'		;in range, make it binary
	MOV	C,A
;
FINDLP:	DCR	C		;count down	
	JZ	DONE
	DAD	D		;not found yet, add 20 to hl
	JMP	FINDLP
;
NOGOOD:	MVI	A,BELL
	CALL	TYPE
;
DONE:	POP	D
	POP	B
	RET			;return with hl pointing to log message
;.....
;
;
; Values for Novation J-Cat using Ann(0) as offhook line
;
ONHOOK:	EQU	0E058H
OFFHOOK:EQU	0E059H
COMMAND:EQU	MODCTL1+1	;ssc command register
DTR:	EQU	0BH		;dtr, xmit on(rts low), irq disabled
;
;
; Send break through SSC -- 233 millisecond space tone
;
SENDBRK:LDA	COMMAND	
	PUSH	PSW		;save register content
	ORI	0CH		;set bits 2,3
	STA	COMMAND 	;break line
	PUSH	B
	LXI	B,233		;wait 233 msec
	CALL	DELAY
	POP	B
	POP	PSW		;get original register
	STA	COMMAND 	;restore it
	RET
;.....
;
;
; You can add your own routine here to set DTR low and/or send a break
; tone to disconnect.
;
GOODBYE:STA	ONHOOK
	PUSH	B
	LXI	B,25		;on hook for 25 msec
	CALL	DELAY
	POP	B
	STA	OFFHOOK
	PUSH	B
	LXI	B,20		;off hook for 20 msec
	CALL	DELAY
	POP	B
	STA	ONHOOK		;final disconnect
	RET
;.....
;
;
; ---->	DELAY: Wait for the number of millisecsonds in B,C
;
DELAY:	PUSH	D		;save d,e
	INR	B		;bump b for later dcr
;
DELAY1	MVI	E,126		;delay count for 1 millisec (apple z80
				;   clock-2.041 mhz.)
DELAY2:	DCR	E		;count
	JNZ	DELAY2		;  down
	DCR	C		;more millisecs?
	JNZ	DELAY1		;  yes
	DCR	B		;no - more in hi byte?
	JNZ	DELAY1		;  yes
	POP	D		;  no,	restore d,e
	RET
;.....
;
;
; The following address is used to set data bits, parity, stop bits
; and baud rate on the Super Serial Card.
;
MODDLL:	EQU	MODCTL1+2	;ssc acia control register
;
;
; End of SSC specific equates for initialization.
; The following is used to initialize the Apple SSC on execution of the
; program.
;
INITMOD:MVI	A,1		;default transfer time to 300
	STA	MSPEED
	MVI	A,DTR
	STA	COMMAND
	LDA	MODDLL		;current baudrate from moddll
	ANI	0F0H		;zero the last 4 bits
;
INITMOD1:
	ORI	06H		;get default baudrate (300)
	ANI	9FH		;set 8 data bits
	ANI	7FH		;set 1 stop bit
	STA	MODDLL		;store default baudrate
	RET
;.....
;
;
; Changes the modem baud rate with set command.
;
SETUPR: JMP	INITMOD
;
; J-Cat is 300 baud only -- no need to change
;
;
BAUDBUF:DW    10,0		;tells clearbuf routine it can..
	DS	10		;..clear next 10 bytes
;
;-----------------------------------------------------------------------
;
; The following routine can be used to display commands on the screen
; of interest to users of this equipment.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
;-----------------------------------------------------------------------
;
; J-Cat Dialing Routines
;
; The following patches adapt the exisiting PMMI dialing routines
; (located at 0400H) in MDM712.COM to dial through the Novation J-Cat
; modem, if the modem's OHK line is electrically connected to the AN(0)
; pin of the Apple game I/O port.
;
; Sensing of the dial tone and ring signals is not implemented in this
; version.  In theory, that can be accomplished by connecting the J-Cat
; PLS line to one of the Apple's button inputs (or possibly the cassette
; input).
;
NOCNCT:	EQU	0593H		;no connection made
CONNCTD:EQU	05F4H		;phone connected
CKCARR:	EQU	088AH		;check for carrier
;
;
; Wait for carrier
;
	ORG	0577H
;
	MVI	D,20H		;mask for carrier detected bit
	MVI	C,96H		;limit time waiting for carrier
	CALL	CKCARR
	JNC	CONNCTD
	CALL	HANGUP
	JMP	NOCNCT
;
;
; Dial a digit
;
	ORG	0679H
;
PULSE:	PUSH	B
	STA	ONHOOK
	LXI	B,61		;pulse
	CALL	DELAY
	STA	OFFHOOK
	LXI	B,39		;delay between pulses
	CALL	DELAY
	POP	B
	DCR	C		;any more pulses?
	JNZ	PULSE		;yes, do them
	LXI	B,300		;300-millisec delay between digits
	CALL	DELAY
	RET
;.....
;
;
; Wait 2 seconds for dial tone
;
	ORG	06F9H	
;
	MVI	A,DTR
	STA	MODCTL1		;enable modem
	STA	OFFHOOK		;connect phone
	LXI	B,2000
	CALL	DELAY
	ORA	A		;clear carry
	RET
;.....
;
;
; Hang up phone

	ORG	076EH

;
HANGUP:	JMP	GOODBYE
;
;	
; Check for carrier
;
	ORG	088FH
;		
	LDA	MODCTL1 	;get modem status
;	
;		
; Patch out PMMI menu
;
	ORG	08B1H
;
	RET
;.....
;
;
; Number library
;
	ORG	0C00H
;
	DB	'A=The Source..............292-0600'             
	DB	'B=Compuserve..............890-0232'             
	DB	'C=A.P.P.L.E. Crate..1-206-935-9119'             
	DB	'D=Oxgate............1-804-898-7493'             
	DB	'E=Pirates Harbor..........720-3600'             
	DB	'F=Termexec................863-0282'             
	DB	'G=................................'             
	DB	'H=................................'             
	DB	'I=................................'             
	DB	'J=................................'             
	DB	'K=................................'             
	DB	'L=................................'             
	DB	'M=................................'             
	DB	'N=................................'             
	DB	'O=................................'             
	DB	'P=................................'             
	DB	'Q=................................'             
	DB	'R=................................'             
	DB	'S=................................'             
	DB	'T=................................'             
	DB	'U=................................'             
	DB	'V=................................'             
	DB	'W=................................'             
	DB	'X=................................'             
	DB	'Y=................................'             
	DB	'Z=................................'             
;
;
; Patch out PMMI-specific routines, etc.
;
	ORG	0FD5H
;
	CNZ	JMP$INITMOD
	ORG	14EDH
	CALL	JMP$INITMOD
	ORG	18A9H		;patch call to logon select
	CALL	LOGSELCT
	ORG	1AEAH
	JMP	1807H		;use break routine from this file
;.....
;
;
	END

