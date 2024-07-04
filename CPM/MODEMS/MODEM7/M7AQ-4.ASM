; M7AQ-4.ASM Apple Micromodem overlay file for MDM730  05/18/84
;
; This overlay file for MDM730 program is based on M712AP.ASM to support
; the AppliCard or Softcard and the Micromodem ][.  Please note the specific
; equates for 6MHz on AppliCard.  Since code changes in the main sec-
; tion were necessary to support auto-dial with the Micromodem, MDM730
; specific equates are defined in this overlay.
;
; In the code section of this overlay, code sections, labels, etc. which
; go to the main program are listed in <lower-case>.  Code that is called
; through established MDM7xx overlay vectors are listed in <UPPER CASE>
; and, therefore, can be modified.  Take care in changing code which
; overlays main program.
;
; NOTE: When using this overlay, be careful to save the working file un-
; der a different name than original file since major changes are made
; in the main program by this overlay.	MDM730 requires 73 sectors be
; saved rather than 66 or more as in earlier MDM7xx programs.
;					- Henry Middlebrook
;
;----------------------------------------------------------------------
;
; This overlay file enables Apple ][ computers to use the following
; Apple modem configuration at 300 baud only:
;
;	> Hayes Micromodem ][ and 6 MHz PCPI AppliCard <
;	> Hayes Micromodem ][ and Microsoft Softcard or equivalent <
;	
; It can be modified to be used with most of the available Z-80 processor
; boards available for the Apple including SoftCard and PCPI Applicard.
;
; You will want to look this file over carefully.  There are a number of
; options that you can use to configure the program to suit your taste.
;
; Edit this file for your preferences then follow the "TO USE:" example.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM730.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7AQ-4.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 M730.COM    (now have a new .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 05/18/84 - Renamed to avoid confusion with another M7AQ-3 which
;	     didn't have as many features.	- Keith Petersen
; 04/22/84 - Added conditionals for Softcard, fixed so no hangup
;	     if program exited and restarted, revised with
;	     MDM730 addresses			- Ross Alford
; 03/15/84 - Revised with MDM729 addresses	- Henry Middlebrook
; 03/10/84 - Revised with MDM727 addresses	- Henry Middlebrook
; 02/29/84 - Revised with MDM724 addresses	- Henry Middlebrook
; 02/28/84 - Revised for MM][ Auto Dial 	- Henry Middlebrook
; 08/27/83 - Revised to work with Applicard	- William Cook
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
; 02/12/83 - Used MDM703CF to make this file
;	     for Apple computers using a var-
;	     iety of serial interface cards
;	     with external modem.		- Bruce Kargol
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;	SPECIAL EQUATES FOR OVERLAYING ROUTINES IN MAIN PROGRAM
;	-------------------------------------------------------
;
;		These equates are specific to MDM730!
;
DIAL18:		EQU	05DFH
CONMADE:	EQU	06AFH
DIALA2:		EQU	072BH
DIALBGN:	EQU	07AFH
DISCONNT:	EQU	0826H
GOODBYE:	EQU	DISCONNT
RINGBK:		EQU	0950H
RINGBK2:	EQU	0989H
WAIT:		EQU	09C6H
PMMI$MENU:	EQU	09EDH	;SPCLMENU entry in main program
SPCLMENU$DB:	EQU	09F8H	;SPCLMENU data area
TIMER:		EQU	0CBBH
RESTART1:	EQU	1433H
BREAK:		EQU	20AEH	
BREAK1:		EQU	20CBH	
;
;
;-------------- START OF MAIN OVERLAY ---------------------------------
;
BELL:		EQU	07H	;bell
CR:		EQU	0DH	;carriage return
ESC:		EQU	1BH	;escape
LF:		EQU	0AH	;linefeed
FSW:		EQU	15H	;Data format byte for Micromodem, see manual
;
YES:		EQU	0FFH
NO:		EQU	0
;
SOFTCARD:	EQU	YES	;Yes for Softcard, Z-Card, etc.
APPLICARD:	EQU	NO	;Yes for Applicard
MMII:		EQU	YES	;YES for Micromodem II
;
		IF	APPLICARD
OFFSET:		EQU	0C000H
		ENDIF		;Applicard
;
		IF	SOFTCARD
OFFSET:		EQU	0E000H
		ENDIF		;Softcard
;
MODDATP:	EQU	0A7H + OFFSET	;data port of MMII
MODCTLP:	EQU	0A6H + OFFSET	;status port of MMII
MODCTLP2:	EQU	0A5H + OFFSET	;control port 2 of MMII
;
		IF	APPLICARD
RDBYTE:		EQU	0FFE0H	;read a byte from Apple (A = byte)
WRBYTE:		EQU	0FFE3H	;write a byte to Apple (C = byte)
RDWORD:		EQU	0FFE6H	;read 2 bytes from Apple (DE = bytes)
WRWORD:		EQU	0FFE9H	;write 2 bytes to Apple (DE = bytes)
RDNBYTS:	EQU	0FFECH	;read n bytes (DE = count, HL = buffer)
WRNBYTS:	EQU	0FFEFH	;write n bytes (DE = count, HL = buffer)
;
PEEK1BYTE:	EQU	6	;command to peek 1 byte in the Apple
POKE1BYTE:	EQU	7	;command to poke 1 byte in the Apple
		ENDIF		;Applicard
;
;
; Status bit equates for 6850 in Micromodem ][
;
MODSNDB:	EQU	02H	;bit to test for send
MODSNDR:	EQU	02H	;value when ready
MODRCVB:	EQU	01H	;bit to test for receive
MODRCVR:	EQU	01H	;value when ready
;
;----------------------------------------------------------------------
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	YES	;MUST be yes for MM ][			103H
SMARTMODEM:	DB	NO	;MUST be no for MM ][ implementation	104H
TOUCHPULSE:	DB	'P'	;T=touch, P=pulse (Smartmodem-only)	105H
;
		IF	APPLICARD
CLOCK:		DB	6	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
				;Applicard values should not be multiplied
				;by 10 because of 6502 overhead
		ENDIF		;Applicard
;
		IF	SOFTCARD
CLOCK:		DB	20
		ENDIF		;Softcard
;
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	0	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	0	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	NO	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	NO	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in'     113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	NO	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	NO	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'B'-40H	;ESC = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H	;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'Z'-40H	;^Z = Send next character		127H
		DS	2	;for PMMI control chars 		128H
;
;
IN$MODCTLP:	JMP	RD$MODCTLP	;				12AH
		DS	7
OUT$MODDATP:	JMP	WR$MODDATP	;				134H
		DS	7
IN$MODDATP:	JMP	RD$MODDATP	;				13EH
		DS	7
;
;
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
;
;
LOGONPTR:	DW	LOGON		;for user message.		160H
JMP$DIAL:	DS	6		;to main dial routines		162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
JMP$NOPARITY:	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
JMP$PARITY:	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H
;
;
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;IN-LINE print routine		183H
JMP$INBUF:	DS	3		;get kbd input routine		186H
JMP$INLNCOMP:	DS	3		;IN-LINE compare routine	189H
JMP$INMODEM:	DS	3		;100 msec or char recd routine	18CH
JMP$NXTSCRN:	DS	3		;prints mess and then next scrn 18FH
JMP$TIMER:	DS	3		;.1 sec X 'B' reg timer 	192H
;
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,0D9H,0,0,0	;for Soroc/Televideo		198H
		RET			;(or VideoTerm) 	       19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,0AAH,0,0,0	;for Soroc/Televideo		1A1H
		RET			;(or VideoTerm) 	       1A6H
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
;
		IF	SOFTCARD
		DB	'Modem 730 for Softcard '
		ENDIF
;
		IF	APPLICARD
		DB	'Modem 730 for 6 Mhz Applicard '
		ENDIF
;
		DB	'and Micromodem ][',CR,LF,0
		RET
;.....
;
;
; User routines can be added after SYSVER routine.  With this overlay
; all user added routines and data blocks must end before 0400H since
; PMMI routines are used.
;
;---------------- START OF LOCAL OVERLAY ROUTINES ---------------------
;
; The following routines communicate with hardware in Apple Slots
; directly from Applicard.
;
;
; Read the modem control port
;
RD$MODCTLP:
	PUSH	D
	LXI	D,MODCTLP
	CALL	PEEK
	POP	D
	RET
;.....
;
;
; Write the modem control port
;
WR$MODCTLP:
	PUSH	D
	LXI	D,MODCTLP
	CALL	POKE
	POP	D
	RET
;.....
;
;
; Write the modem control port 2
;
WR$MODCTLP2:
	PUSH	D
	LXI	D,MODCTLP2
	CALL	POKE
	POP	D
	RET
;.....
;
;
; Read the modem data port
;
RD$MODDATP:
	PUSH	D
	LXI	D,MODDATP
	CALL	PEEK
	POP	D
	RET
;.....
;
;
; Write the modem data port
;
WR$MODDATP:
	PUSH	D
	LXI	D,MODDATP
	CALL	POKE
	POP	D
	RET
;.....
;The peek and poke routines are only necessary for the Applicard,
;but are just redefined for the Softcard
;
	IF	APPLICARD
;
;
; Peek at 1 byte in the Apple
;   Entry: DE = address
;   Exit:  A  = data
;
PEEK:	PUSH	B
	MVI	C,PEEK1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	CALL	RDBYTE
	POP	B
	RET
;.....
;
;
; Poke 1 byte into the Apple
;   Entry: DE = address
;   Exit:  A  = data
;
POKE:	PUSH	B
	MOV	B,A
	MVI	C,POKE1BYTE
	CALL	WRBYTE
	CALL	WRWORD
	MOV	C,B
	CALL	WRBYTE
	POP	B
	RET
;
	ENDIF		;Applicard complicated I/O
;
	IF	SOFTCARD
PEEK:	LDAX	D
	RET
;
POKE:	STAX	D
	RET
;
	ENDIF		;Softcard simple I/O
;.....
;
;
; You can put in a message at this location which can be called up with
; CTL-L if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:		DB	CR,'vax',CR,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;.....
;
;
; This routine will send a BREAK through MM ][.  Routine is called
; through patch in main program and JMP$BREAK vector here.
;
SENDBRK:
	MVI	A,60H		;BREAK byte to ACIA
	CALL	WR$MODCTLP	;send to ACIA
	PUSH	B
	LXI	B,300		;send break for 300 msecs
	CALL	DELAY
	POP	B
	MVI	A,FSW		;re-init modem w/current status
	CALL	WR$MODCTLP
	RET
;.....
;
;
; This routine initializes MM ][ on first entry to MDM730 and is
; used after that to re-initialize modem to current status.
;
DTR:	DB	8FH		;300 baud, orig, carrier on, off-hook
;
MODSTAT:
	DB	00H		;value of 00 indicates cold start, no hangup
;
INITMOD:
	MVI	A,1		;MSPEED 300 baud value
	STA	MSPEED
;
INITMOD2:
	MVI	A,3		;reset ACIA
	CALL	WR$MODCTLP
	MVI	A,FSW		;Send word status to ACIA
	CALL	WR$MODCTLP
	LDA	MODSTAT		;get current modem params
	ORA	A		;if 00, is a cold start, dont bother
	RZ			;initializing in case connected
	CALL	WR$MODCTLP2
	RET
;.....
;
;
; This routine is called from main program with MODSTAT set for
; disconnect of MM][.
;
HANGUP$MM:
	CALL	INITMOD2
	PUSH	B
	LXI	B,1000		;wait 1 second for MM][ disconnect
	CALL	DELAY
	POP	B
	RET
;.....
;
;
; The following routine can be used to change baud rate or word/parity
; settings.  This routine is called each time a menu entry is selected
; and is designed to allow setup changes before entry to terminal mode.
;
SETUPR:	RET
;.....
;
;
; The following routine can be used to display commands on the screen
; of interest to users of this equipment.  If using the Hayes Smartmodem
; this is unavailable without a special address change.  In this overlay
; a datablock is overlayed on the original PMMI special menu and this
; routine is called by JMP$SPCLMENU vector in main program.  The info
; screen can be eliminated by replacing this code with a simple RET.
;
SPCLMENU:
	JMP	PMMI$MENU	;this jumps to main program
	RET
;.....
;
;
; This routine on 6 MHz AppliCard will delay for the number of
; milliseconds passed in 'BC' register.  PSW, DE, HL registers saved.
; For a 4MHz AppliCard change number of timing loops from 3 to 2.
;
DELAY:	PUSH	PSW
	PUSH	H
	PUSH	D		;contains delay time
;
	IF	APPLICARD
	MVI	A,3		;loop through 3 times
	ENDIF
;
	IF	SOFTCARD
	MVI	A,1		;loop through 1 time
	ENDIF
;
DELAY0:	PUSH	B
	INR	B		;will later be decremented
;
DELAY1:	MVI	E,126		;count for .1 msec Z-80 at 2 MHz
;
DELAY2:	DCR	E
	JNZ	DELAY2
	DCR	C		;run down LO byte then..
	JNZ	DELAY1
	DCR	B		;..HI byte back down
	JNZ	DELAY1		;If not done keep going
	POP	B		;Otherwise, get delay time back...
	DCR	A		;...and loop back again...
	JNZ	DELAY0		;...for 3 times (6 MHz).
	POP	D
	POP	H
	POP	PSW		;unload stack
	RET
;.....
;
;
;------------ START OF ROUTINES TO BE OVERLAYED IN MAIN PROGRAM --------
;
; These routines have been written such that Smartmodem routines are
; not disturbed.  Conditional assembly routines can be added to support
; serial I/O cards and Smartmodem.
;.....
;
;
; This routine is called after dialing is complete; routine expects
; modem to return with Carrier Detect, then passes control
; to CONMADE routine.
;
OVL1:	ORG	DIAL18
;
	MVI	A,3		;clear ACIA port 1
	CALL	WR$MODCTLP
	MVI	B,1		;read modem or come back in .1 secs
	CALL	TIMER
	MVI	A,8DH		;set modem for off-hook, orig, etc
	CALL	WR$MODCTLP2
	MVI	D,4		;mask for Carrier Detect
	MVI	C,96H		;time limit for CD (about 30 secs)
	CALL	WAIT
	JNC	CONMADE		;got it, then continue
	CALL	DISCONNT	;no, then drop..
;.....
;
;
; This routine replaces the original disconnect routine. It resets
; all modem values to standby, onhook status.
;
OVL2:	ORG	DISCONNT+7
;
	MVI	A,0DH		;restores modem defaults
	STA	MODSTAT
	CALL	HANGUP$MM
	RET
;.....
;
;
; This CALL is to replace PMMI call..reads modem port for CD status.
;
OVL3:	ORG	WAIT+5
;
	CALL	RD$MODCTLP	;check for Carrier Detect
;
;.....
;
; This routine replaces unnecessary PMMI code. Jump is forced to
; overlay SETUPR routine.
;
OVL4:	ORG	RESTART1+12
;
	CNZ	SETUPR
;.....
;
;
OVL5:	ORG	BREAK+4
;
	JMP	BREAK1		;jump over PMMI routine, use
;.....				;BREAK routine here
;
;
; This routine replaces PMMI dialing routine in main program.
;
OVL6:	ORG	DIALA2+8
;
PULSE:	PUSH	B		;digit dialed is in 'B' reg
	MVI	A,0DH		;set modem on-hook..
	CALL	WR$MODCTLP2
	LXI	B,61		;..for 61 msecs
	CALL	DELAY
	MVI	A,8DH		;set modem off-hook..
	CALL	WR$MODCTLP2
	LXI	B,39		;..for 39 msecs
	CALL	DELAY
	POP	B		;get back number from stack
	DCR	C		;..one less pulse
	JNZ	PULSE		;go back for next pulse if not done
	LXI	B,600		;otherwise, wait 600 msecs
	CALL	DELAY
	RET
;.....
;
;
; This routine is called after number is entered or found in library,
; but before dial-pulsing routine is called. Off-hook status saved
; for re-init after dialing.
;
OVL7:	ORG	DIALBGN+5
;
	LDA	DTR		;get DTR byte
	STA	MODSTAT		;save for post dial re-init
	MVI	A,8DH		;set modem off-hook
	CALL	WR$MODCTLP2
	LXI	B,3000		;wait 3 secs for dialtone
	CALL	DELAY
	ORA	A		;must return with carry clear
	RET
;.....
;
;
; This routine re-inits modem ACIA registers and modem status
; from MODSTAT set at DIALBGN (above).
;
OVL8:	ORG	CONMADE
;
	LDA	MODSTAT		;Do nothing step since we are...
	CALL	INITMOD2	;...going to re-init ACIA anyway!
;.....
;
;
; This text block overlays original PMMI special menu data and is
; called through jumps in overlay code and back to start of the
; PMMI menu. This data section must end prior to 0CB4H!!
;
OVL9:	ORG	SPCLMENU$DB
;
	DB	'           '
	DB	'Additional Information for Micromodem ][ Users',CR,LF
	DB	'           '
	DB	'---------- ----------- --- ---------- -- -----'
	DB	CR,LF,LF,LF
	DB	'          '
	DB	'This overlay allows the MM ][ to operate in the',CR,LF
	DB	'          '
	DB	'originate mode only at 300 baud.  Word status is',CR,LF
	DB	'          '
	DB	'fixed to 7 Data Bits, Even parity, and 1 Stop Bit.'
	DB	CR,LF,LF,LF
	DB	0
	RET
;.....
;
;
; The Micromodem ][ cannot be used for RingBack dialing.  This patch
; defeats PMMI routine and gives error message.
;
OVL10:	ORG	RINGBK+5
;
	JMP	RINGBK2
;
;
	ORG	RINGBK2+3
;
	DB	CR,LF,'+ No Ringback for Micromodem ][ +',0
;.....
;
;
;------------- END OF PATCHES TO MAIN PROGRAM AREA --------------------
;
;
	  END
