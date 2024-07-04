; M7AP-1.ASM Apple overlay file for MDM7xx.  11/11/83
;
; This overlay file enables Apple II computers with the Apple Super
; Serial card and external modem to use the MDM7xx phone modem program.
; It also supports the following Apple modem configurations:
;
;	a) CCS 7710 serial interface and external modem
;	b) SSM serial interface and external modem
;	c) Apple communications interface and external modem
;	d) Mountain Hardware CPS Multifunction card and external modem
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; Much of the information contained here is not in the MDM7xx.ASM file.
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
;		-IM7AP-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/11/83 - Renamed to M7AP-1.ASM, no changes	- Irv Hoff
; 10/07/83 - Added CPS card support		- Wally Hubbard
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 07/01/83 - Revised to work with MDM711	- Irv Hoff
; 06/22/83 - Revised to work with MDM710	- Irv Hoff
; 05/27/83 - Updated to work with MDM709	- Irv Hoff
; 05/15/83 - Revised to work with MDM708	- Irv Hoff
; 04/11/83 - Updated to work with MDM707	- Irv Hoff
; 04/04/83 - Updated to work with MDM706	- Irv Hoff
; 02/27/83 - Updated to work with MDM705	- Irv Hoff
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
SSC:		EQU	NO	;YES for Super Serial Card
SSM:		EQU	NO	;YES for SSM serial card
CPS:		EQU	YES	;YES for CPS card
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
MODRCVB:	EQU	08H	;bit to test for received data
MODRCVR:	EQU	08H	;modem receive ready
MODSNDB:	EQU	10H	;bit to test for ready to send
MODSNDR:	EQU	10H	;modem send ready bit
		 ENDIF		;endif SSC
;
;
; (Any slot with any CPS function assigned to it may be used.)
;
		 IF	CPS
SLOT:		EQU	2	;Slot = 1 or 2 for normal CP/M.
MODCR:		EQU	0E0FEH+SLOT*100H  ;control port of CPS card
MODDATP:	EQU	0E0FAH+SLOT*100H  ;data port of CPS card
MODCTL1:	EQU	0E0FBH+SLOT*100H  ;status port of CPS card
MODRCVB:	EQU	02H	;bit to test for receive
MODRCVR:	EQU	02H	;value when ready
MODSNDB:	EQU	01H	;bit to test for send
MODSNDR:	EQU	01H	;value when ready
		 ENDIF		;endif CPS
;
;
; Apple status bit equates for CCS, Comcard and SSM
;
		 IF	NOT SSC AND NOT CPS
MODSNDB:	EQU	02H	;bit to test for send
MODSNDR:	EQU	02H	;value when ready
MODRCVB:	EQU	01H	;bit to test for receive
MODRCVR:	EQU	01H	;value when ready
		 ENDIF		;not SSC and not CPS
;
;
; We have software control over the Super Serial and CPS cards, so
; SETUPRTST is YES for those cards, below.
;
;
		ORG	100H
;
;
; Change the clock speed to match your equipment.  The Microsoft Softcard
; operates at 2 MHz.
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-pmmi	104H
TOUCHPULSE:	DB	'P'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHz, 37=3.68 MHz, 40=4 MHz, etc.
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
SCRNTEST:	DB	NO	;Cursor control routine 		10CH
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
EOSCLR:		DB	0,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	0,0,0,0,0	;				1A1H
		RET			;				1A6H
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Apple II with external modem'
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
; CTL-L if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:	DB	'Hello there from an Apple user',CR,0
;
;
; You can add your own routine here to send a break tone to reset time-
; share computers, if desired.
;
	 IF NOT CPS
SENDBRK:RET
	 ENDIF		;endif not CPS
;
	 IF CPS
SENDBRK:MVI	A,80H	;open the command register
	STA	MODCR	;by storing 80H in MODCR
	MVI	A,3FH	;send a break by storing
	STA	MODCTL1	;$3F in MODCTL1
	XRA	A	;close the command register
	STA	MODCR	;by storing 00H in MODCR
	RET
	 ENDIF		;endif CPS
;
; You can add your own routine here to set DTR low and/or send a break
; tone to disconnect.
;
GOODBYE:RET
;
;.....
;
;
; The following address is used to set data bits, parity, stop bits
; and baud rate on the Super Serial Card.
;
	 IF SSC
MODDLL:	EQU	0E0ABH		;SSC ACIA control register
;
;
; Control over number of data bits, parity and number of stop
; bits (thru MSB300:) has not been implemented.  These must be
; set using the slide switches on the Super Serial Card.
;
; The following is used to initialize the Apple SSC on execution of the
; program.  Change it to initialize the modem port on your micro if you
; wish.  It initializes to 300 baud.
;
INITMOD:
	MVI	A,1		;default transfer time to 300
	STA	MSPEED
	LDA	MODDLL		;current baudrate from MODDLL
	ANI   0F0H		;zero the last 4 bits
;
INITMOD1:
	ORI   06H		;get default baudrate (300)
	STA	MODDLL		;store default baudrate
	RET
	 ENDIF			;SSC
;.....
;
;
; The following may be used to initialize the Mountain Hardware CPS
; Multifunction Card for eight bits, no parity, one stop bit, and
; 300 baud.  This does not alter the CPS defaults outside of MDM7xx.
;
	 IF CPS
INITMOD:
	MVI	A,1		;set MSPEED at 1 (=300 baud)
	STA	MSPEED
	MVI	A,80H		;open the command register
	STA	MODCR		;by storing 80H in MODCR
	MVI	A,37H		;initialize the serial chip
	STA	MODCTL1		;by storing 37H in MODCTL1
	MVI	A,4EH		;set 1 stop bit, no parity
	STA	MODDATP		;by storing $4E in MODDATP
;
INITMOD1:
	MVI	A,35H		;set baud rate at 300 by storing
	STA	MODDATP		;35H in MODDATP (same address - the two 
				;registers cycle with each write)
	XRA	A		;close the command register
	STA	MODCR		;by storing 00 in MODCR
;
;
; The MDM7xx.COM routine that checks to see if the printer is ready
; does not work with the CPS card.  This routine changes it.  Check
; to make sure the original code sequence CALL 0000H, ORA A, RZ, is
; located at GOLIST.  A new routine to send the character to the
; printer is also provided, to eliminate the need for the CPS patches.
;
GOLIST:	EQU	01A8FH		;MDM7xx.COM location of GOLIST
	LXI	H,PRCHECK	;store the address of the
	SHLD	GOLIST+1	;PRCHECK routine at GOLIST+1
	LXI	H,PRINTCHAR	;store the address of the
	SHLD	GOLIST+15	;PRINTCHAR routine
	RET
;.....
;
;
; Substitute routines for status checks and printing:
;
PRCHECK:
	LDA	0E0F9H+SLOT*100H ;read the status port
	ANI	040H		 ;mask off unused bits
	RET
;.....
;
;
PRINTCHAR:
	MOV	A,C		 ;move char to A
	STA	0E0FDH+SLOT*100H ;send it to the printer
	RET
	 ENDIF			;CPS
;.....
;
;
;
	 IF NOT SSC AND NOT CPS
INITMOD:RET			;intialization goes here, if needed
SETUPR:	RET			;routine to change baud rates, if needed
	 ENDIF			;NOT SSC AND NOT CPS
;.....
;
;
; Changes the modem baud rate with SET command.
;
	 IF SSC OR CPS
SETUPR: LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	CALL	JMP$ILPRT
	DB	'Input Baud Rate (300,600,1200): ',0
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
	CALL	JMP$ILPRT	;all matches failed - tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	JMP	SETUPR		;try again
;
OK300:	MVI	A,1		;MSPEED 300 baud value
	LHLD	BD300		;get 300 baud parameters in HL
	JMP	LOADBD		;go load them
;
OK600:	MVI	A,3
	LHLD	BD600
	JMP	LOADBD

OK1200:	MVI	A,5
	LHLD	BD1200
;
LOADBD:	STA	INITMOD+1
	MOV	A,L		;get baud rate byte
	STA	INITMOD1+1	;store in INITMOD
	JMP	INITMOD		;reset SSC ACIA baud rate
	 ENDIF			;endif SSC or CPS
;
;
; Table of baud rate parameters
;
	 IF SSC
BD300:	DW	0006H
BD600:	DW	0007H
BD1200:	DW	0008H
	 ENDIF			;SSC
;
	 IF CPS
BD300:	DW	0035H
BD600:	DW	0036H
BD1200:	DW	0037H
	 ENDIF			;CPS
;
;
BAUDBUF:DW    10,0		;TELLS CLEARBUF ROUTINE IT CAN..
	DS	10		;..CLEAR NEXT 10 BYTES
;
;-----------------------------------------------------------------------
;
; The following routine can be used to display commands on the screen
; of interest to users of this equipment.  If using the Hayes Smartmodem
; this is unavailable without a special address change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE: MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				0C00H (without Smartmodem)
;
	END
