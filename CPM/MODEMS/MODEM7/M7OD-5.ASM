; M7OD-5.ASM - Overlay for Osborne-01 with the COMM-PAC Modem 05/07/84
;		     Auto-dialing supported.
;
;	   This overlay will work (ONLY) with MDM740.COM
;
;=======================================================================
;
; You will want to look this file over carefully.  There are a number of
; options that can be used to configure the program to suit your taste.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 300 baud when the program is first called up, but remember, the
; COMM-PAC only works at 300 baud.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original .COM file:
;
;		A>DDT MDM740.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4A00 0100
;		-IM7OD-5.HEX		(note the "I" command)
;		-R			(loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM740.COM	(or MDM.COM )
;
;		You now have a modified .COM file.
;
;=======================================================================
;Rev. 5  05/07/84 - Modified to work with MDM740.COM
;					- Irv Hoff
;
;Rev. 4  04/06/84 - Updated to work with MDM730.COM.
;					- John Riehl, FOG #2836
;					  Days:  1-713-644-7070
;					  Home:  1-713-488-1257
;
;Rev. 3  03/17/84 - Updated to work with MDM727A.COM.
;					- John Riehl
;
;
;Rev. 2  02/05/84 - Updated to work with MDM720.COM  Removed routines
;		    which were already in the main program and made
;		    an effort to retain the Smartmodem routines.	
;					- John Riehl
;
;Rev. 1  12/08/83 - Changed from CTL-C to CTL-V to turn on carrier
;		    after using telephone dialer in the Terminal mode.
;		    Changed from CTL-^ to <ESC> for "Send next character"
;		    function.		- John Riehl
;
;	 12/05/83 - Original derived from M712OS.ASM
;		    by Irv Hoff and Paul Kelly
;					- John Riehl	
;=======================================================================
;
BDOS:		EQU	5
PRINT:		EQU	9
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
PORT		EQU	2A00H
MODCTLP:	EQU	PORT	;status register for RS232
MODDATP:	EQU	PORT+1	;data resister for RS232
MODSNDB:	EQU	2	;bit to test for ready to send
MODSNDR:	EQU	2	;modem send ready when high
MODRCVB:	EQU	1	;bit to test for received data
MODRCVR:	EQU	1	;modem receive ready when high
MODCARB:	EQU	4	;modem carrier on when low
;
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;		     SPECIAL EQUATES FOR COMM-PAC
;
MCBON:		EQU	40H	;mask to turn on MCB
MCBOFF:		EQU	0BFH	;mask to turn off MCB
;
WAITCTS:	EQU	150	;number of seconds (x5) to wait for the
				;computer to answer after PMMI auto-dial
				;100=20 sec, 150=30 sec, 255=51 sec.
				;any number 0-255 acceptable
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; Change CLOCK to match your equipment
;
		ORG	100H
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;must be NO leave this alone		103H
AUTODIAL:	DB	NO	;yes=HAYES-type autodial modem		104H
TOUCHPULSE:	DB	'P'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	3	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;cursor control routine 		10CH
RETRY:		DB	YES	;yes=reset the error limit to try again 10DH
				;no=abort after 10 consecutive errors
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVRUB:	DB	YES	;yes=convert rub to backspace		111H
TOGGLERUB:	DB	YES	;yes=allow toggling of rub to backspace 112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
NOSAVE:		DB	NO	;DO NOT CHANGE, MUST BE 'NO' FOR OS-1	116H
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
COMMPAC:	DB	YES	;yes=Osborne COMM-PAC modem		11EH
EXTRA2:		DB	0	;					11FH
CARRIER:	DB	'V'-40H	;^V = Turn on carrier			120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H	;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	ESC	;ESC= Send next character		127H
;
PULSERATE:	DB	125	;125=20pps dialing, 1=10pps
CHGBAUD:	DB	'B'-40H	;^B = Used with PMMIMODEM in terminal
				; mode to change baud rate on fly
;
IN$MODCTLP:	CALL	OSTAT	! RET	;get the I/O status		12AH
OUT$MODCTLP:	CALL	OSET	! RET	;setup I/O			12EH
		DS	2
;
OUT$MODDATP:	CALL	OSOUT	! RET	;send a character to the I/O	134H
		DS	6
;
IN$MODDATP:	CALL	OSIN	! RET	;get a character from the I/O	13EH
		DS	6
;
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
;
IN$BAUDRP:	JMP	IN$MODCTLP	;check modem carrier status	154H
;
;
;====================== SPECIAL PMMI PORT ==============================
;
OUT$BAUDRP:	RET  !	NOP  !	NOP	;out baudrate port
;
;================== END OF SPECIAL PMMI PORT ===========================
;
;
OUT$MODCTL1:	JMP	MODCTL1		;turn on modem carrier		15AH
OUT$MODCTL2:	JMP	MODCTL2		;re-initialize modem		15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
JMP$DIAL:	JMP	DIAL		;				162H
JMP$DISCONNT:	DS	3		;				165H
JMP$GOODBYE:	DS	3		;				168H
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	16BH
JMP$NEWBAUD:	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	16EH
JMP$NOPARITY:	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	171H
JMP$PARITY:	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	RET  !	NOP  !	NOP	;(by-passes PMMI routine)	17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	MODCTL1		;Turn on carrier		180H
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
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	0,0,0,0,0	;O-1 has no clear EOS.		198H
		RET			;				19DH
;
CLRSCRN:	CALL JMP$ILPRT		;				19EH
		DB	1AH,0,0,0,0	;O-1 clear screen, home cursor	1A1H
		RET			;				1A6H
;
;
;======================= SIGN-ON MESSAGE ============================== 
;
; Send version number and date
;
SYSVER:	  CALL	JMP$ILPRT
	  DB	'Version for Osborne COMM-PAC modem',CR,LF,0
	  RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by address 0C00H
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:	  DB	'Your 3 minutes is up, deposit 25 cents',CR,LF,0
;.....
;
;
ACIACTLB: DB	56H	;ACIA control byte
;.....
;
;
; This is the Osborne initialization routine.
;	
INITMOD:  LDA	FINITFLG	;flag set yet?
	  ORA	A
	  RNZ			;if yes, already been this way once
	  INR	A		;otherwise set flag..
	  STA	FINITFLG	;..and initialize this routine
	  LHLD	BDOS+1		;find start of bdos
	  LXI	D,-0100H	;go to first page ahead of BDOS
	  DAD	D		;HL now positioned one page below BDOS
	  PUSH	H		;save the address
	  LXI	D,BDJ		;point to our routine to put there
	  LXI	B,CDLEN+2	;set length of code
	  XCHG
	  DB	0EDH,0B0H	;Z80 LDIR
	  LHLD	BDOS+1		;get BDOS address back once more
	  POP	D		;get the starting address off stack
	  PUSH	D		;put it back on the stack
	  INX	D		;point to address position
	  XCHG			;put into 'HL'
	  MOV	M,E		;store 'LSP' address
	  INX	H		;get 'LSP' location
	  MOV	M,D		;store 'MSP' address
	  POP	H		;get the address back once more
	  SHLD	BDOS+1		;new address to protect for overwrite
	  LXI	D,OSIN-BDJ	;get the length of routine to move
	  DAD	D		;compute address of the 'OSIN' routine
	  SHLD	IN$MODDATP+1	;patch call for "get char." routine
	  LXI	D,OSOUT-OSIN
	  DAD	D
	  SHLD	OUT$MODDATP+1	;patch call for "send char." routine
	  LXI	D,OSTAT-OSOUT
	  DAD	D
	  SHLD	IN$MODCTLP+1	;patch call for "get status" routine
	  LXI	D,OSET-OSTAT
	  DAD	D
	  SHLD	OUT$MODCTLP+1	;patch jmp for "send ACIA ctl" routine
;
	  MVI	A,1		;MSPEED 300 bps value
	  STA	MSPEED
;
;
; Set the initial baud rate to 300
;
	  MVI	A,56H		;for 300 bps
SETUPR1:  STA	ACIACTLB
;
MODCTL2:  PUSH	B
	  MVI	C,3
;
CNT:	  MVI	B,6BH
	  LDA	ACIACTLB
	  ORI	MCBON
	  CALL	SETBAUD
	  CALL	DELAY
	  MVI	B,6BH
	  LDA	ACIACTLB
	  ANI	MCBOFF
	  CALL	SETBAUD
	  CALL	DELAY
	  DCR	C
	  JNZ	CNT
	  MVI	B,6BH
	  LDA	ACIACTLB
	  ORI	MCBON
	  CALL	SETBAUD
	  CALL	DELAY
	  MVI	B,6BH
	  MVI	A,3
	  CALL	SETBAUD
	  CALL	DELAY
	  LDA	ACIACTLB
	  ORI	MCBON
	  CALL	SETBAUD
	  POP	B
	  RET
;...
;
;
SETBAUD:  PUSH	H
	  CALL	OUT$MODCTLP
	  POP	H
	  XRA	A		;clear carry
	  RET
;.....
;
;
; change the baud rate with the set command
;
SETUPR:	  PUSH	H
;
AGAIN:	  LXI	D,BAUDBUF	;point to input buffer
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300, 1200): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'300',0
	  MVI	A,1		;mspeed 300 baud
	  STA	MSPEED
	  MVI	A,56H		;Osborne 300 BPS
	  JNC	OK		;go if got match
;
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  MVI	A,5		;MSPEED 1200 bps
	  STA	MSPEED
	  MVI	A,55H		;Osborne 1200 baud
	  JNC	OK
	  CALL	JMP$ILPRT	;all matches failed - tell operator
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	AGAIN		;try again
;...
;
;
OK:	  POP	H
	  JMP	SETUPR1
;.....
;
;
MODCTL0:  LDA	ACIACTLB
	  ORI	MCBON
	  CALL	SETBAUD
	  CALL	BIGDELAY
;.....
;
;
MODCTL1:  LDA	ACIACTLB
	  ANI	MCBOFF
	  CALL	SETBAUD
	  RET
;.....
;
;
DELAY:	  DCR	B
	  JNZ	DELAY
	  RET
;.....
;
;
BIGDELAY1:MOV	B,A
	  CALL	DELAY
	  DCR	C
	  JNZ	BIGDELAY1
	  RET
;
BIGDELAY: PUSH	PSW
	  PUSH	B
	  MVI	B,40
	  MVI	C,0
	  MOV	A,B
	  CALL	BIGDELAY1
	  POP	B
	  POP	PSW
	  RET
;.....
;
;
BAUDBUF:  DB	10,0
	  DS	10
;
FINITFLG: DB	0
;.....
;
;
; Routines that get placed just under 'BDOS' overlaying 'CCP'
;
BDJ:	JMP	$-$		;this gets patched to jump to BDOS entry
;
OSIN:	DI			;disable interrupts
	OUT	0		;switch to alternate page
	LDA	MODDATP		;get data byte
	OUT	1		;switch pages back
	EI			;enable interrupts
	RET
;.....
;
;
OSOUT:	DI			;disable interrupts
	OUT	0		;switch to alternate page
	STA	MODDATP		;send data byte
	OUT	1		;switch pages back
	EI			;enable interrupts
	RET
;.....
;
;
OSTAT:	DI			;disable interrupts
	OUT	0		;switch to alternate page
	LDA	MODCTLP		;get status byte
	OUT	1		;switch pages back
	EI			;enable interrupts
	RET
;.....
;
;
OSET:	DI
	OUT	0
	STA	MODCTLP
	OUT	1
	EI
	RET
;.....
;
CDLEN:	EQU	$-BDJ		;length of code to copy
;
;
;=======================================================================
;
;		    COMM-Pac dialing routines
;
;=======================================================================
;
; Changes to dialing routines
;
	 ORG	0400H
DIAL:	LDA	COMMPAC
;.....
;
;
; Change to DIAL19
;
	 ORG	05F7H
	DB	0,0,0,0,0
;.....
;
;
; Change to DIALAGN
;
	 ORG	0633H
	DB	'N): ',BELL,0,7CH,7CH
;.....
;
;
; Sends the digit to the modem and converts it to the correct number of
; pulses.  Waits 200 ms. after each digit dialed.
;
	 ORG	071BH
DIALA4:	PUSH	B
	CALL	MODCTL0
	CALL	BIGDELAY
	POP	B
	DCR	C
	JNZ	DIALA4
	MVI	B,2
	JMP	JMP$TIMER
;.....
;
;
; Disconnect from the line, reconnect and wait for the dialtone.
;
	 ORG	07A4H
	CALL	DISCON0
	MVI	B,2		
	CALL	JMP$TIMER
	CALL	OUT$MODCTL1
	MVI	D,MODCARB
	MVI	C,10
	JMP	WAIT
;.....
;
;
; Change to DISCONNT:
;
	 ORG	0824H
DISCON0:XRA	A
	DB	0,0,0
;.....
;
;
; Smartmodem SPKRFLG:
;
	 ORG	089AH
	DB	0FFH
;.....
;
;
; Changes to RINGBK:
;
	 ORG	0994H
	DB	MODCARB		;carrier detect mask
;.....
;
;	
; Change to HANGUP:
;
	 ORG	0A16H
	RET
;.....
;
;
WAIT:	EQU	0A51H
;
;=======================================================================
;
	 ORG	0E00H-2
HEXSHOW:DB	NO		;show hex length
SAVSIZ:	DB	20H		;buffer size = 4k
;.....
;
;
	 ORG	1426H
	DW	COMMPAC		;enable 'C' option in command line
;.....
;
;
	 ORG	152CH
	DW	COMMPAC		;accept 'C' option
;
	 ORG	20B2H
	DB	0C3H		;changes JZ to JMP
;.....
;
;
	 ORG	39A5H
	DW	COMMPAC		;disable 'NUM" desription in menu
;
	 ORG	3A1CH
	DW	COMMPAC		;enable 'CAL' description in menu
;.....
;
;
	 ORG	3B37H
	DB	'  - Turn on MODEM carrier        ',CR,LF,0
;.....
;
;
	 ORG	3EF3H
	DW	COMMPAC		;disable 'NUM' in command mode
;.....
;
;
	 ORG	3F44H
	DW	COMMPAC		;enable 'CAL' in command mode
;.....
;
;
	END
