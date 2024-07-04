

;	M7KP-x48.ASM --	Kaypro overlay file for MDM730.    7/30/84

; *********************************************************************
; 7/30/84    Allows optional assembly to facilitate 4800 baud
; M7KP-X48   direct Transfer of files to & from KAYPRO over 3 wires.
;            Assembles normally to M7KP2 if XFR48 is set to NO.
;
;	    Also, can be assembled to connect to either Serial Printer Port
;	    or to Modem Port, if you're using the -84 KP series
;	    that have separate port.  Advantage to using printer
;	    port, if it is not otherwise used, is that you do not
;	    have to switch plugs at your modem port for direct transfer
;	    and normal modem use.  NOTE:  If you're using an older KAYPRO, 
;	    i.e., one with only one serial port, set PRINTPORT to NO.
;
;           How to wire depends on the computer to/from which
;           you want to transfer files.  Try it and see - you can't
;           hurt anything.  If it does not work, reverse wires to
;           pins 2 and 3 on one of the RS-232 plugs.
;
;           Basically, you connect:
;               Pin 7 to Pin 7
;               Pin 2 to pin 3 (or maybe to pin 2)
;               Pin 3 to pin 2 (or maybe to pin 3)
;
;           I made up one RS-232 with a cross-over switch (DPDT), like
;           below, to make it easier to match other systems:
;			|    |          |
;			|    |          |
;			|    |          |
;			2    3          7
;			|    |          |
;		---------------------   |
;		|	|    |	    |	|
;		|	/    \	    |	|
;		|      /      \	    |	|
;		|     / o    o \    |   |    
;		|    / 	 \  /	\   |	|
;		|   /     \/     \  |	|
;		|  o      /\      o |	|
;		|        /  \       |	7
;		|       /    \      |	|
;		|      o      o     |	|
;		|      |      |     |	|	
;               |-------------------|	|
;		       |      |		|
;		       2      3		7
;		       |      |		|
; 		       |      |         |      	
;
; *********************************************************************
; KP7-X48 is based on M7KP-2.
; M7KP-2 was to written to handle a specific problem, to
; communicate with certain time sharing systems.  It should not be
; considered a replacement for M7KP-1.ASM.  It has been written not to
; exceed 896 bytes, a constraint documented in M7KP-1.ASM.  Because of
; this, some code was taken out, (SET baudrate other than 300 or 1200).
;
; You will want to look this file over carefully.  There are a number of
; options that you can use to configure the program to suit your taste.
; This file adapts the Kaypro II computer to the modem program.  Much of
; the information contained here is not in the MDM722.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:", example
; shown below.
;
; Use the "SET" command to change the baudrate, word length, number of
; stop bits, and parity when desired.  It starts out at 300 baud, 8 bit
; word length 1 stop bit, and no parity when the program is first invoked.
;
; TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.   Use DDT to overlay the results of this
;		program to the original .COM file:
;
;		A>DDT MDM7nn.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4900 0100		(might be bigger -- be careful)
;		-IM7KP-X48.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4900 0000		(or whatever)
;		-G0			(return	to CP/M)
;		A>SAVE 72 XFR48.COM	(you now have a modified .COM file
;			|		 saved in XFR48.COM)
;			|
;		   or whatever value
;		   may be appropriate - the 72 relates to 4900 as
;		   follows: Discard the last two digits from the
;		   4900 (or similar) value.  If they were NOT 00,
;		   use the first two digits as is.  If they were
;		   00, reduce the first two by one (e.g., 49 becomes 48).
;		   Now: 48 means 48 hex.  That is 4 16s, and 8 ones.
;		   		(4*16)+8=72
;    
;							E.O.Stork
;  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =
; 02/18/84 - Changed SET routine to change baudrate, word length,
; M7KP-2     number of stop bits, and parity.	- Bill Duerr
;
;  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =
;
;
YES:		EQU	0FFH
NO:		EQU	0
;******************************************************************************
PRINTPORT:	EQU	NO		;usually false, true only if you want 
					; to connect to serial printer port   
					;Set this to NO is using a KAYPRO with
					; only one serial port.

XFR48		EQU	YES		;If YES, disables SET Command	      *
					; Set to NO if you want to use this
					; overlay for normal operation 
;
	IF PRINTPORT
PORT:		EQU	0CH		;0Ch for Ser.Print Port
BAUDPORT	EQU	08h		;08h for Ser.Print port
	ENDIF ;printport
	IF NOT PRINTPORT
PORT:		EQU	04h		;04h modem data port
BAUDPORT	EQU	00h		;00h modem port	ENDIF
	ENDIF	;if not printer port
;******************************************************************************
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
MODCTL1:	EQU	PORT+2		;Modem control port
MODDATP:	EQU	PORT		;Modem data port
MODCTL2:	EQU	PORT+2		;Modem control port
;
MODRCVB:EQU	01H	;Your bit to test for receive   .... ...1
MODRCVR:EQU	01H	;Your value when receive ready  .... ...1
;                       ;Int pending                    .... ..1.
MODSNDB:EQU	04H	;Your bit to test for send      .... .1..
MODSNDR:EQU	04H	;Your value when send ready     .... .1..
;DCT:   EQU     80H     ;data carier detect             .... 1...
;                       ;sync hunt                      ...1 ....
;                       ;Clear to Send                  ..1. ....
;                       ;Tx underrun                    .1.. ....
;                       ;Break/Abort                    1... ....
;
; The following are used in setting up the Z80 SIO.
;
;                       ;all sent                       .... ...1
;                       ;parity error                   ...1 ....
;                       ;overrun error                  ..10 ....
;                       ;framing error                  .1.. ....
;                       ;end of frame (SDLC)            1... ....
;WRREG0
;                       ;write to register              .... .xxx
;                       ;reset flags                    ..xx x...
RSTERR:	EQU	30H	;reset parity and overrun flags	..11 0...
RSTINS:	EQU	18H	;reset SIO - register 0         ..01 1...
WRREG1:	EQU	0	;no interrupts - register 1
;                       ;ext int enable                 .... ...1
;                       ;tx int enable                  .... ..1.
;                       ;rx int disable                 ...0 0...
;                       ;rx int on first character      ...0 1...
;                       ;int on all rx char/parity eff  ...1 0...
;                       ;int on all rx char             ...1 1...
;                       ;wait/ready on r/t              ..1. ....
;                       ;wait/ready function            .1.. ....
;                       ;wait/ready enable              1... ....
;
;			;register 3 equates
WRREG3:	EQU	0C1H	;8 Rx bits, Rx enable
RENABLE	EQU	1	;Rx enable -			.... ...1
;                       ;sync character load inhibit -  .... ..1.
;                       ;address serch mode (SDLC) -    .... .1..
;                       ;Rx CRC enabel -                .... 1...
;                       ;Enter hunt phase               ...1 ....
;                       ;Auto enables                   ..1. ....
MSKWD:	EQU	0C0H	;word length mask -		xx.. ....
;                       ;receive five bit work -        00.. ....
RSEVEN:	EQU	040H	;receive seven bit word	-	01.. ....
;                       ;receive six bit word -         10.. ....
REIGHT:	EQU	0C0H	;receive eight bit word	-	11.. ....
;
;			;register 4 equates
WRREG4:	EQU	44H	;16X baud rate,	1 stop bit, no parity
MSKPA:	EQU	03H	;mask for parity bits -		.... ..xx
NONE:	EQU	00H	;no parity -			.... ..00
ODD:	EQU	01H	;odd parity -			.... ..01
EVEN:	EQU	03H	;even parity -			.... ..11
MSKST:	EQU	0CH	;stop bit mask -		.... xx..
;                       ;sync modes enable -            .... 00..
ONE:	EQU	04H	;one stop bit  -		.... 01..
;      	       	       	;1.5 STOP BITS -		.... 10..
TWO:	EQU	0CH	;two stop bits -		.... 11..
;                       ;sync modes -                   ..xx ....
;CLK01: EQU     00H     ;1X clock mode -                00.. ....
CLK16:	EQU	40H	;16X clock mode -               01.. ....
;CLK32: EQU     80H     ;32X clock mode -               10.. ....
;CLK64: EQU     c0H     ;64X clock mode -               11.. ....
;			;register 5 equates
WRREG5:	EQU	0EAH	;8 Tx bits, Tx enable, RTS, DTR
;TXCRC  EQU     001H    ;Tx CRC enable                  .... ...1
;RTS    EQU     002H    ;Request to send                .... ..1.
;SLDC   EQU     004H    ;SDLC/CRC-16                    .... .1..
TENABLE:EQU	008H	;Tx enable			.... 1...
;BREAK  EQU     010H    ;Send break                     ...1 ....
;                       ;Transmit five bit word -       .00. ....
TSEVEN:	EQU	020H	;Transmit seven	bit word -	.01. ....
;                       ;Transmit six bit word -        .10. ....
TEIGHT:	EQU	060H	;Transmit eight	bit word -	.11. ....
;DTR    EQU     080H    ;Data terminal ready            1... ....
DTRON:	EQU	08AH	;Tx enable, RTS, DTR -		1... 1.1.
DTROFF:	EQU	000H	;DTR off, RTS off -		0... ..0.
;
		ORG	100H
;
; Change the clock speed as needed for your system.
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100	Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in	MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz,	40=4 MHz, etc.
MSPEED:		DB	7	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400	7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character	in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms	109H
				;default time for extra	wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number	of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added	Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor	control	routine			10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	NO	;yes=change any	file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to	CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	YES	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after	CR to send file	in	113H
				;terminal mode (added by remote	echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after	CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission	of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do	not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if	EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=chcks for XOFF from remote	while	11AH
				;sending a file	in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after	CR while	11BH
				;sending a file	in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	NO	;yes=CTL-chars above ^M	not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCXNNCT:	DB	'N'-40H	;^N = Disconnect from the phone	line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H	;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next	character		127H
PULSERATE:	DS	1	;                                       128H
CHGBAUD		DS	1	;        				129H
;
IN$MODCTL1:	MVI	A,10H		;channel 0, reset interrupts.	12AH
		OUT	MODCTL1
		IN	MODCTL1		;get the status	bits
		RET
		DB	0,0,0
;
OUT$MODDATP:	OUT	MODDATP	! RET	;out modem data	port		134H
		DB	0,0,0,0,0,0,0
IN$MODDATP:	IN	MODDATP	! RET	;in modem data port		13EH
		DB	0,0,0,0,0,0,0
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to	test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to	test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when	ready	151H
IN$BAUDRP:	DS	3		;IN baudrate port               154H
OUT$BAUDRP:	DS	3		;OUT baudrate port              157H
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port		15AH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem status port		15DH
;
LOGONPTR:	DW	LOGON		;for user message.		160H
JMP$DAIL:	DS	3		;Use routine in	main program	162H
JMP$DISCONNT:	DS	3		;Use routine in	main program	165H
JMP$GOODBYE:	JMP	GOODBYE		;Routine in this overlay	168H
JMP$INITMOD:	JMP	INITMOD		;Initialization	in this	overlay	16BH
JMP$NEWBAUD:	RET  !	NOP  !	NOP	;Bypass	PMMI routine		16EH
JMP$NOPARITY:	RET  !	NOP  !	NOP	;Bypass	PMMI routine		171H
JMP$PARITY:	RET  !	NOP  !	NOP	;Bypass	PMMI routine		174H
JMP$SETUPR:	JMP	SETUPR		;Set command in	this overlay	177H
JMP$SPCLMENU:	RET  !	NOP  !	NOP	;Bypass	special	menu routine	17AH
JMP$SYSVER:	JMP	SYSVER		;Version message in this overlay17DH
JMP$BREAK:	JMP	SENDBRK		;Break	routine	in this	overlay	180H
;
;
; Do not change	the following six lines, the routine are in main program.
;
JMP$ILPRT:	DS	3		;Inline	print routine		183H
JMP$INBUF	DS	3		;Input buffer routine		186H
JMP$INLNCOMP:	DS	3		;Inline	compare	routine		189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;Timer routine			192H
;
; Clear	sequences -- CLREOS is clear to	end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	017H,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	01AH,0,0,0,0	;				1A1H
		RET			;				1A6H
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
IF NOT XFR48
		DB	'M7KP-2 for Kaypro'	;	1AAH
ENDIF	;if not XFR48
IF	XFR48
		DB	'M7XFR48 for Kaypro'
ENDIF   ; if xfr48

IF PRINTPORT
		DB	' Printer Serial Port',0
ENDIF
IF NOT	PRINTPORT
		DB	' Serial Modem Port',0
ENDIF

		RET
;
; NOTE:	 You can change	the SYSVER message to be longer	or shorter.  The
;	 end of	your last routine should terminate by 0380H (390 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0B80H (2521 bytes) otherwise.
;
; You can put in a message at this location which can be called	up with
; CTL-L	if TRANLOGON has been set YES.	You can	put in several lines if
; desired.  End	with a 0.
;
LOGON:	  DB	'LOGON',CR,LF,0
;
;
; This routine allows a	300 ms.	break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,5		;select	register 5
	  OUT	MODCTL1
	  MVI	A,0F8H		;send a	break tone
	  JMP	GOODBYE1
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such	as the Bell 212A, etc.
;
GOODBYE:  MVI	A,5		;select	register 5
	  OUT	MODCTL1		;send to the status port
	  MVI	A,DTROFF	;turn off dtr
;
GOODBYE1: OUT	MODCTL1
	  MVI	B,3		;delay 300 ms.
	  CALL	JMP$TIMER
	  MVI	A,5		;select	register 5
	  OUT	MODCTL1
	  LDA	REG5+1		;has been set to word length, etc.
	  OUT	MODCTL1
	  RET
;
; Kaypro II initialization -- resets the SIO, sets the interrupt
; mode, the receive and transmit mode.
; Sets the baud rate to BAUDPORT (00 for dataport, 08 for printer port)
;
INITMOD:MVI	A,0		;select	register 0
	OUT	MODCTL1
	MVI	A,RSTINS	;reset SIO - 18h
	OUT	MODCTL1
;
	MVI	A,1		;select	register 1
	OUT	MODCTL1
	MVI	A,WRREG1	;no interrupts
	OUT	MODCTL1
;
	MVI	A,3		;select	register 3 - receive
	OUT	MODCTL1
REG3:	MVI	A,WRREG3	;8 Rx bits, Rx enable
	OUT	MODCTL1
;
	MVI	A,4		;select	register 4
	OUT	MODCTL1
	MVI	A,CLK16		;16X baud rate
PARIT:	ORI	NONE		;type of parity
STPLN:	ORI	ONE		;number of stop bits
	OUT	MODCTL1
;
	MVI	A,5		;select	register 5 - transmit
	OUT	MODCTL1
REG5:	MVI	A,WRREG5	;8 Tx bits, Tx enable, no RTS, no DTR
	OUT	MODCTL1
;
SETBD:	
  IF XFR48		;set to 4800 baud if for direct transfer
	MVI	A,0CH		; 0Ch for 4800
  ENDIF	;xfr48
  IF NOT XFR48
	MVI	A,05H		; 05h for 300 bps,07h for 1200 baud
  ENDIF ;not xfr48
	OUT	BAUDPORT	;00 for data port, 08 for printer port
	RET
;
; The following routine changes the baud rate, word length, stop bits
; and parity on the Z80 SIO from the command level.  Note the routine
; MUST modify the parameters used by the INITMOD routine.
;
	IF	XFR48	;do not support SET command in XFR48
SETUPR:	
	CALL	JMP$ILPRT
	DB	9,7,'SET Command not supported in XFR48',0dh,0ah,0
	RET
	ENDIF ; xfr48

	IF NOT XFR48
SETUPR:	PUSH	H
AGAIN:	LXI	D,BAUDBUF	;point to input	buffer for JMP$INLNCOMP
	CALL	JMP$ILPRT
	DB	1AH,'Baud Rate (300, 1200): ',0
	CALL	JMP$INBUF
	LXI	H,BAUDTB
BAUDLP:	MOV	A,M		;first character to check
	ORA	A		;is it null
	JZ	NOTOK		;no matches found
	STA	BAUDCP		;store in compare area
	INX	H		;point to next character
	MOV	A,M		;second character to check or null
	STA	BAUDCP+1	;store in comparea area
	INX	H		;point to MSPEED constant
	LXI	D,BAUDBUF+2	;compare baudbuf and baudcp
	CALL	JMP$INLNCOMP	;was valid baud specified
BAUDCP:	DB	0,0,0		;baudrate from table gets stored here
	JNC	OK		;match, go save it
	INX	H		;skip MSPEED
	INX	H		;and CTC constant
	JMP	BAUDLP		;and check next entry
NOTOK:	CALL	WRONG		;tell messed up
	JNC	AGAIN2		;null line entered bypass baud change
	JMP	AGAIN		;try again
;
OK:	MOV	A,M		;get MSPEED
	STA	MSPEED		;change	time-to-send to	match baudrate
	INX	H		;point to CTC constant
	MOV	A,M		;and get it
	STA	SETBD+1		;store in INITMOD routine
;
AGAIN2:	LXI	D,BAUDBUF	;point to input	buffer
	CALL	JMP$ILPRT
	DB	'Word Length (7, 8): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;was eight bits	requested
	DB	'8',0
	MVI	A,REIGHT+RENABLE;receive eight bits  -  C1h
	MVI	B,TEIGHT+DTRON	;transmit eight	bits -  EAh
	JNC	OK2
	CALL	JMP$INLNCOMP	;was seven bits requested
	DB	'7',0
	MVI	A,RSEVEN+RENABLE;receive seven bits  - 41h
	MVI	B,TSEVEN+DTRON	;transmit seven	bits - AAh
	JNC	OK2
	CALL	WRONG
	JNC	AGAIN3		;bypass word length change
	JMP	AGAIN2
;
OK2:	STA	REG3+1		;store in MVI instruction
	MOV	A,B		;get transmit word length
	STA	REG5+1		;store in MVI instruction
;
AGAIN3:	LXI	D,BAUDBUF	;point to input	buffer for JMP$INLNCOMP
	CALL	JMP$ILPRT
	DB	'Stop Bits (1, 2): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;was 1 stop bit	requested
	DB	'1',0
	MVI	A,ONE		;1 stop	bit - 04h
	JNC	OK3
	CALL	JMP$INLNCOMP	;was 2 stop bits requested
	DB	'2',0
	MVI	A,TWO		;2 stop	bits - 0Ch
	JNC	OK3
	CALL	WRONG
	JNC	AGAIN4		;bypass stop bit mod
	JMP	AGAIN3		;go ask again
;
OK3:	STA	STPLN+1		;save stop bits	in MVI
;
AGAIN4:	LXI	D,BAUDBUF	;point to input	buffer for JMP$INLNCOMP
	CALL	JMP$ILPRT
	DB	'Parity (None, Even, Odd): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;was no	parity requested
	DB	'N',0		;just check first character
	MVI	A,NONE		;no parity - 00h
	JNC	OK4		;go if got match
	CALL	JMP$INLNCOMP	;was even parity requested
	DB	'E',0
	MVI	A,EVEN		;even parity - 03h
	JNC	OK4
	CALL	JMP$INLNCOMP	;was odd parity	requested
	DB	'O',0
	MVI	A,ODD		;odd parity - 01h
	JNC	OK4
	CALL	WRONG		;no matches
	JNC	GOSET		;bypass parity changes
	JMP	AGAIN4		;try again
;
OK4:	STA	PARIT+1		;save in MVI
;
; now go modify the init routine to initialize the Kaypro to the values
; requested.
;
GOSET:	POP	H		;restore HL register
	JMP	INITMOD		;reset Z80 SIO (and return)
;
WRONG:	CALL	JMP$INLNCOMP	;was null string entered
	DB	' ',0
	RNC			;all is ok
	CALL	JMP$ILPRT	;all matches failed - tell operator
	DB	' Wrong!',CR,LF,BELL,0
	STC			;Set carry flag
	RET
;
; Due to space constraints some baud rates have been commented out
;
BAUDTB:	EQU	$		;Valid baud rates
;                               ;BAUD  MSPEED   CTC
;BD110:	DB	'11',0,2	; 110    0      02
BD300:	DB	'3',0,1,5	; 300    1      05
;BD600:	DB	'6',0,3,6	; 600    3      06
BD1200:	DB	'12',5,7	;1200    5      07
;BD2400:DB	'24',6,10	;2400    6      0A
;BD4800:DB	'48',7,12	;4800    7      0C
;BD9600:DB	'96',8,14	;9600    8      0E
;BD192:	DB	'19',8,15	;19.2    9      0F
	DB	0
;
	ENDIF	;not XFR48

BAUDBUF:
	DB	10,0
	DS	10
;
;---------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0380H (with Smartmodem)
;				 0B80H (without Smartmodem)
;
;---------------------------------------------------------------------
	END
