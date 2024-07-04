; MXO-OS22.ASM - OSBORNE 1 OVERLAY                                  24 AUG 84
; for MEX11.COM - Changed START location to 0EB9H
; Mark S. Stein, Morton Grove RBBS RCP/M (312) 470-0017
;
; MXO-OS21.ASM - Osborne I Overlay 				     10JULY84
; for MEX10.COM & MDM7xx.COM file - 10 JULY 84			     10JULY84
;
; This version is a synthesis of MXO-OS01, MXO-OS12.  The primary    10JULY84
; change from Bob Schultz's MXO-OS01 version is implementation of    10JULY84
; the  NEWBD  vector, allowing support of the optional baud  rate    10JULY84 
; entry for phone numbers.
; 
;	-- Howard Gerber, WB5YWS				     10JULY84
;	   contact me through the OZZ-HAM RCP/M (713) 893-0424	     10JULY84
;	   or The Weekender (713) 492-8700			     10JULY84

; Bob Schultz's notes follow:					     10JULY84
 
; This file is derived from MDM711OS.ASM by Irv Hoff and Paul Kelly.
; It was necessary to put in some kludges to make it work with MEX10.
; The problem was that MEX10 called the modem routines before it called
; the modem initialization routine.  Since the modem routines MUST be
; above 4000H, ozy wasn't very happy.  While I was at it, I cleaned up
; the baud rate routines so that the default baud rate can be set by
; setting MSPEED to the desired value.  I also added a send break routine
; and a disconnect routine.  Unfortunately, these routines will work only
; if you use the modem connector rather than the RS-232 connector.  It
; seems that ozy was designed to use the RS-232 connector to be able to
; drive a printer at the same time that the modem connector is being used.
; I don't know why anyone would want a serial printer when a parallel
; printer is cheaper, but that's the way OCC did it.  The problem with
; sending a break through the serial port is the MC6850 ACIA can only send
; a break when RTS is ON.  This is quite reasonable, but the hardware
; design of the Osborne I clamps the transmitted data from the RS-232
; connector to a MARK when RTS is on.  Since a break is a SPACE, this
; doesn't work very well.  The only solutions are: 1) Build an interface
; to convert the modem connector signals to proper RS-232 signals
; 2) Modify the main logic board.  This looks like it would be very
; easy to do, but I haven't tried it.  Just lift the ends of the resistors
; R20 (10K) and R35 (1.0K) that are connected together and connect the
; ends off the board with a wire.  I don't know if the resistors are
; labeled, or even if the mod will work.  It should, but there are as
; many gotcha's in hardware as there are in software.  Good luck.  If you
; do make the mod, set the RS232 EQU to NO.

; This file should also work with MDM730 -- I mean MDM740 or perhaps it's
; now MDM750.  Just set MEX to off.  But if you can get MEX, why bother
; with MDM?

; A few helpful hints for MEX10.  When MEX starts up, it tries to READ 
; INI.MEX.  You can create the INI file with an editor and put any MEX
; commands that you want into it.  Or else you can disable the feature
; with STAT INITFILE OFF and then clone it.  When you get sick of the
; prompt that you get when entering terminal mode type POKE $40A0 $C9
; and then clone it.  The clone number is two bytes at 5335H with the
; low order byte first.

; I'm releasing this file as version 0.1 without as much testing as I'd
; like to do only because I can hear the anguished cries of Osborne owners
; who are faced with yet another version of MDM and can't get MEX running.
; When I have more time, I'll release an upgraded version 1.0.

; You can contact me through just about any RCPM system in Toronto.

;	Bob Schultz

; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
 
BELL:	EQU	07H		;bell
CR:	EQU	0DH		;carriage return
ESC:	EQU	1BH		;escape
LF:	EQU	0AH		;linefeed

YES:	EQU	0FFH
NO:	EQU	0

START:	EQU	0EB9H	;location MEX10 jumps to -- for kludge

RS232:	EQU	YES	;set this to YES if you're
				;   using the RS232 connector
				;and to NO if you're using the modem connector
MEX:	EQU	YES	;set this to YES for MEX10
				;and to NO for MDM7

; values to send to 6850 control register for
; 8 bits, no parity, 1 stop bit
IF	RS232			;RTS MUST be off
BAUD3:		EQU	56H		;300 baud 8-bit no parity
BAUD12:		EQU	55H		;1200 baud 8-bit no parity
ENDIF
IF NOT	RS232			;RTS on seems reasonable
BAUD3:		EQU	16H		;300 baud 8-bit no parity
BAUD12:		EQU	15H		;1200 baud 8-bit no parity
BRKBIT:		EQU	60H		;bits to set to send break
RTSBIT:		EQU	40H		;bit to turn off RTS
ENDIF

MODCTLP:	EQU	2A00H	;status register for RS232
MODDATP:	EQU	MODCTLP+1 ;data resister for RS232
MODSNDB:	EQU	2	;bit to test for ready to send
MODSNDR:	EQU	2	;modem send ready when high
MODRCVB:	EQU	1	;bit to test for received data
MODRCVR:	EQU	1	;modem receive ready when high

	ORG	100H

IF	MEX
	JMP	INITMOD	;I hate this kludge
ENDIF
IF NOT	MEX
	DS	3
ENDIF

PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	YES	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	9	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	9	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	4	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;cursor control routine 		10CH
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
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	NO	;no=do not save CCP, may be overwritten 116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	NO 	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'B'-40H	;^B = Send a 300 ma. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'W'-40H	;^W = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'\'-40H	;^\ = Send next character		127H
		DS	2		;				128H

IN$MODCTLP:	CALL	$-$	! RET	;get the I/O status		12AH
		DS	6		;patched to OSTAT by INITMOD

OUT$MODDATP:	CALL	$-$	! RET	;send a character to the I/O	134H
		DS	6		;patched to OSOUT by INITMOD 

IN$MODDATP:	CALL	$-$	! RET	;get a character from the I/O	13EH
		DS	6		;patched to OSIN by INITMOD

ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	151H
		DS	12		;				156H
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	3		;				162H
JMP$DISCON	JMP	DISCON		;				165h
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:
IF	MEX
		RET  !  NOP  !  NOP	;already initialized by kludge	16BH
ENDIF
IF NOT	MEX
		JMP	INITMOD		;initialize modem code and 6850
ENDIF

IF	MEX
		JMP  NEWBD	; support optional NEWBD    10JULY84	16EH
ENDIF
IF NOT	MEX
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	16EH
ENDIF

		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	171H
		RET  !  NOP  !  NOP	;(by-passes PMMI routine)	174H
JMP$SETUPR:	JMP	SETUPR		;				177H
JMP$SPCLMENU:	JMP	SPCLMENU	;				17AH
JMP$SYSVER:	JMP	SYSVER		;				17DH
JMP$BREAK:	JMP	SENDBRK		;				180H

; Do not change the following six lines.

JMP$ILPRT:	DS	3		;				183H
JMP$INBUF	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H

CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	0,0,0,0,0	;O-1 has no clear EOS.		198H
		RET			;				19DH

CLRSCRN:	CALL JMP$ILPRT		;				19EH
		DB	1AH,0,0,0,0	;O-1 clear screen, home cursor  1A1H
		RET			;				1A6H

SYSVER:	CALL	JMP$ILPRT	;				1A7H
			
	DB	CR,LF
	DB	01BH,')'	;into half intensity
	DB	'For the Osborne 1: '
	DB	01BH,'('	;out of half intensity
	DB	'Revised by M. Stein - 08/24/84'
	DB      CR,LF,LF,0
	RET

;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;-----------------------------------------------------------------------

; You can put in a message at this location which can be called up with
; CTL-W if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.

LOGON:		DB	0


; Sends a 300 msec break.  Will work only with the modem connector. 

SENDBRK:
IF NOT	RS232
		PUSH	H
		LDA	BAUD		;turn on break
		ORI	BRKBIT
		CALL	OSET
		MVI	B,3		;wait for 300 ms
		CALL	JMP$TIMER
		LDA	BAUD		;turn off break 
		CALL	OSET
		POP	H
ENDIF
		RET


;  Drops RTS for 3 sec.  RTS is not available on the RS232 connector. 

DISCON:
IF NOT	RS232
		PUSH	H
		LDA	BAUD		;drop RTS
		ORI	RTSBIT
		CALL	OSET
		MVI	B,30		;wait for 3 sec
		CALL	JMP$TIMER
		LDA	BAUD		;restore RTS
		CALL	OSET
		POP	H
ENDIF
		RET


; if you put a routine in here, it should NOT do a disconnect when
; using MEX.  That's handled by the DISCON routine above

GOODBYE:	RET

; You can put any items in this area you wish to display that are of in-
; terest to those using this equipment.  If using the Hayes Smartmodem
; this is unavailable without a special address change.  End the routine
; with a RET.

SPCLMENU:	RET


; This is the Osborne initialization routine.

INITMOD:
IF NOT	MEX			;MEX could not be cloned if this code was in
	LDA	FINITFLG	;flag set yet?
	ORA	A
	RNZ			;return if have already been here
	INR	A
	STA	FINITFLG	;set flag
ENDIF
	LHLD	0005H+1		;FIND START OF BDOS
	LXI	D,-0100H	;GO TO FIRST PAGE AHEAD OF BDOS
	DAD	D		;HL NOW POSITIONED ONE PAGE BELOW BDOS
	PUSH	H		;SAVE THE ADDRESS
	LXI	D,BDJ		;POINT TO OUR ROUTINE TO PUT THERE
	LXI	B,CDLEN+2	;SET LENGTH OF CODE
	XCHG
	DB	0EDH,0B0H	;Z80 LDIR

	LHLD	0005H+1		;GET BDOS ADDRESS BACK ONCE MORE
	POP	D		;GET THE STARTING ADDRESS OFF STACK
	PUSH	D		;PUT IT BACK ON THE STACK
	INX	D		;POINT TO ADDRESS POSITION
	XCHG			;PUT INTO 'HL'
	MOV	M,E		;STORE 'LSP' ADDRESS
	INX	H		;GET 'LSP' LOCATION
	MOV	M,D		;STORE 'MSP' ADDRESS
	POP	H		;GET THE ADDRESS BACK ONCE MORE
	SHLD	0005H+1		;NEW ADDRESS TO PROTECT FOR OVERWRITE

	LXI	D,OSIN-BDJ	;GET THE LENGTH OF ROUTINE TO MOVE
	DAD	D		;COMUTE ADDRESS OF THE 'OSIN' ROUTINE
	SHLD	IN$MODDATP+1		;PATCH CALL FOR "GET CHAR." ROUTINE
	LXI	D,OSOUT-OSIN
	DAD	D
	SHLD	OUT$MODDATP+1	;PATCH CALL FOR "SEND CHAR." ROUTINE
	LXI	D,OSTAT-OSOUT
	DAD	D
	SHLD	IN$MODCTLP+1	;PATCH CALL FOR "GET STATUS" ROUTINE
	MVI	C,BAUD3		;300 baud for 6850
	LDA	MSPEED
	CALL	NEWBD		; set baud rate			10JULY84
IF	MEX
	JMP	START		;more kludge
ENDIF
IF NOT	MEX
	RET
ENDIF


NEWBD:	CPI	1		;				10JULY84
	JZ	OK300		;				10JULY84
	CPI	5		;				10JULY84
	JZ	OK1200		;				10JULY84
	RET			;				10JULY84

OK300:	MVI	A,1		; MSPEED 300 bps		10JULY84
	MVI	C,BAUD3		; 01 300 bps			10JULY84
	STA	MSPEED		;				10JULY84
	JMP	STBAUD		;				10JULY84

OK1200:	MVI	A,5		; MSPEED 1200 bps		10JULY84
	MVI	C,BAUD12	; 01 1200 bps			10JULY84
	STA	MSPEED		;				10JULY84
STBAUD:	PUSH	H		;				10JULY84
	CALL	OSET1		; set baud rate			10JULY84
	POP	H		;				10JULY84
	XRA	A		; clear carry			10JULY84
	RET			;				10JULY84

; stuff the control register on the 6850

OSET:	MOV	C,A
OSET1:	LHLD	1		;GET BIOS+3 ADDRESS
	MVI	L,3CH		;SPECIAL OSBORNE ROUTINE
	PCHL			;BRANCH TO IT


; Change the baud rate with the SET command

SETUPR:	  PUSH	H

AGAIN:	LXI	D,BAUDBUF	;POINT TO INPUT BUFFER
	CALL	JMP$ILPRT
	DB	'Input Baud Rate (300, 1200): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2

	CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	DB	'300',0
	MVI	A,1		;MSPEED 300 BAUD
	MVI	C,BAUD3		;OSBORNE 300 BAUD
	JNC	OK		;GO IF GOT MATCH

	CALL	JMP$INLNCOMP
	DB	'1200',0
	MVI	A,5		;MSPEED 1200 BAUD
	MVI	C,BAUD12	;OSBORNE 1200 BAUD
	JNC	OK

	CALL	JMP$ILPRT	;ALL MATCHES FAILED - TELL OPERATOR
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	JMP	AGAIN		;TRY AGAIN

OK:	STA	MSPEED		;SET MSPEED
	MOV	A,C
	STA	BAUD		;save 6850 control register image
	CALL	OSET
	POP	H
	XRA	A		;CLEAR CARRY
	RET

BAUDBUF:  DB	10,0
	  DS	10
BAUD:	  DS	1
IF NOT	MEX
FINITFLG: DB	0
ENDIF


; --- ROUTINES THAT GET PLACED JUST UNDER 'BDOS' OVERLAYING 'CCP'

BDJ:	JMP	$-$		;THIS GETS PATCHED TO JUMP TO BDOS ENTRY

OSIN:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITCH TO ALTERNATE PAGE
	LDA	MODDATP		;GET DATA BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET


OSOUT:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITDH TO ALTERNATE PAGE
	STA	MODDATP		;SEND DATA BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET


OSTAT:	DI			;DISABLE INTERRUPTS
	OUT	0		;SWITCH TO ALTERNATE PAGE
	LDA	MODCTLP		;GET STATUS BYTE
	OUT	1		;SWITCH PAGES BACK
	EI			;RE-ENABLE INTERRUPTS
	RET


CDLEN:	EQU	$-BDJ		;LENGTH OF CODE TO COPY

;-----------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	END
