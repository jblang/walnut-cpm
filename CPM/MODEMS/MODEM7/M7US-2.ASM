; M7US-2.ASM -- U.S. Robotics S-100 overlay for MDM7xx.  03/17/84
;
; This overlay adapts the MDM7xx program to the U.S. Robotics S-100
; autodial modem.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; This overlay is capable of setting the baud rate and sending breaks.
; Although disconnecting the modem is not supported (by use of a function
; to lower DTR), the control-N command still works, as it uses "+++"
; which causes the U.S.R. S-100 modem to hang up.  If you are running a
; system which has a clock speed of more than 4 MHz, be sure to see
; the routine INITMOD, as you will have to "uncomment" some do-nothing
; time wasting statements to slow your computer down for the modem.
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
;		4A00 0100
;		-IM7US-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 03/17/83 - Updated to match MDM728		- Bob plouffe
; 12/21/83 - Added "commented" delays in init-
;	     ialization for fast systems.	- Phil Lapsley
; 12/19/83 - Now sends AT command in the
;            initialization routine to get
;            the attention of the USR S-100     - Phil Lapsley
; 12/17/83 - Created from M7GP-1.ASM		- Phil Lapsley
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
PORT:		EQU	000H
MODCTL1:	EQU	PORT+1		;MODEM CONTROL PORT
MODDATP:	EQU	PORT		;MODEM DATA IN PORT
MODDATO:	EQU	PORT		;MODEM DATA OUT PORT
MODDCDB:	EQU	080H		;CARRIER DETECT BIT
MODDCDA:	EQU	080H		;VALUE WHEN ACTIVE
MODRCVB:	EQU	2		;BIT TO TEST FOR RECEIVE
MODRCVR:	EQU	2		;VALUE WHEN READY
MODSNDB:	EQU	1		;BIT TO TEST FOR SEND
MODSNDR:	EQU	1		;VALUE WHEN READY
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
NORETRY		DB	NO	;yes=DON'T ALLOW RETRY/QUIT OPTION	10DH
				;no=ALLOW RETRY/QUIT AFTER 10 TIMEOUTS
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
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1	! RET	;in modem control port		12AH
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
OUT$MODCTL1:	OUT	MODCTL1	! RET	;out modem control port #1	15AH
OUT$MODCTL2:	RET  !	NOP  !  NOP	;ctl-port #2 is not used	15DH
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
		DB	0,0,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	0,0,0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for U.S.R. S-100 autodial'
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
;.....
;
;
; The following routine sends a break "character" to the remote
; computer for 300 ms.  The "MSPEED" value is needed to decide whether
; or not the modem is at 300, 600, or 1200 baud.  The routine must
; know this because U.S.R. set up the RTS bit of the command resgister
; as a baud rate selection bit, and this routine must be careful not
; to change it, or the user will end up at a different baud rate
; after the break "character" is sent.  Note that the "MVI A, 01FH" does
; not change any flags.
;
SENDBRK:	LDA	MSPEED		; Get speed byte
		CPI	3		; Are we at 600 baud?
		MVI	A, 01FH		; Set up for 600 (no flag changes)
		JZ	SBRK2		; And if we are, go do that
		MVI	A, 03FH		; Otherwise, set up for 300/1200
SBRK2:		OUT	MODCTL1		; Send break
		PUSH	PSW		; Save value
		MVI	B, 3		; 300 ms delay value
		CALL	JMP$TIMER	; Wait that long
		POP	PSW		; Restore command byte
		ANI	0F7H		; Turn off break bit
		OUT	MODCTL1		; Send command byte to UART
		RET
;.....
;
;
; The U.S.R. S-100 does not have a "quick-disconnect" feature like
; the Hayes does (by lowering DTR).  Therefore, "GOODBYE" is not
; implemented.  Yet control-N still works to hang up (see note
; above in introduction)
;
GOODBYE:	RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	This initialization
; sets up 300 baud, 8 data bits, 1 stop bit, no parity.  Due to a
; quirk in the U.S.R. S-100 (it seems to have plenty of 'em), after
; you change baud rates, you should send an "AT" followed by a
; carriage return.  Therefore, this is done after every initialization
; when there is no carrier present.
;
; NOTE: The U.S.R. S-100 does not operate too well at clock speeds of
;	over 4 MHz.  If you are running at that speed or higher, you
;	should uncomment (by removing the preceding semicolon) the
;	lines with XCHG.  These serve as time wasting routines to
;	let the U.S.R. S-100 catch up.  This is not a problem when
;	doing character I/O, as the program checks to see if the
;	modem is ready to accept a character.
;
INITMOD:  	XRA	A		; Zero accumulator
		OUT	MODCTL1		; Clear 8251A
;		XCHG			; For fast systems
;		XCHG			; For fast systems
		OUT	MODCTL1		; Twice
;		XCHG			; For fast systems
;		XCHG			; For fast systems
		OUT	MODCTL1		; Three times, even
;		XCHG			; For fast systems
;		XCHG			; For fast systems
		MVI	A, 040H		; Reset UART command
		OUT	MODCTL1
;		XCHG			; For fast systems
;		XCHG			; For fast systems
MODEBT:		MVI	A, 04FH		; 8 bits, 1 stop, no parity
		OUT	MODCTL1
;		XCHG			; For fast systems
;		XCHG			; For fast systems
CMDBT:		MVI	A, 037H		; On hook, Tx/Rx enable, reset errs
		OUT	MODCTL1
;		XCHG			; For fast systems
;		XCHG			; For fast systems
BDCODE:		MVI	A, 1		; 300 baud code
		STA	MSPEED
		IN	MODCTL1		; Get the current status
		ANI	MODDCDB		; See if there is a carrier
		RNZ			; If so, don't do AT stuff
		MVI	B, 1		; 100 ms
		CALL	JMP$TIMER	; Wait that long for things to settle
		MVI	B, 'A'		; "A" of AT command
		CALL	OUTMOD		; Output to the modem
		MVI	B, 'T'		; "T" of AT command
		CALL	OUTMOD		; Output
		MVI	B, CR		; Followed by a carriage return
		CALL	OUTMOD		; Output that too
		RET
;
; Output a character to the U.S.R. S-100
; (NOTE: This routine is not normally present in most overlays,
; 	 and is used by the INITMOD routine above.)
;
OUTMOD		IN	MODCTL1		; Get status
		ANI	MODSNDB		; Mask for ready status
		JZ	OUTMOD		; Loop if not ready
		MOV	A, B		; Otherwise get the character
		OUT	MODDATP		; Output to the data port
		RET			; And return

;
; This routine prompts the user for a new baud rate
; (on the U.S.R. this can be 300, 600, or 1200, as mdm7xx
; has no provision for 150 baud) and sets the modem to that
; baud rate.
;
SETUPR:		LXI	D, BAUDBUF	; Point to new input buffer
		CALL	JMP$ILPRT	; Print following line:
		DB	'Input baud rate (300, 600, 1200): ', 0
		CALL	JMP$INBUF	; Get a line into the buffer
		LXI	D, BAUDBUF + 2	; compare BAUDBUF+2 with characters
		CALL	JMP$INLNCOMP
		DB	'300', 0
		JNC	OK300
		CALL	JMP$INLNCOMP
		DB	'600', 0
		JNC	OK600
		CALL	JMP$INLNCOMP
		DB	'1200', 0
		JNC	OK1200
		CALL	JMP$ILPRT
		DB	'++ Incorrect entry ++', CR, LF, BELL, 0
		JMP	SETUPR		; Try again
;
OK300:		LXI	B, BD300	; Point to intializers for 300 baud
		MVI	A, 1		; 300 baud value
		JMP	LOADBD		; Go load it
;
OK600:		LXI	B, BD600
		MVI	A, 3
		JMP	LOADBD
;
OK1200:		LXI	B, BD1200
		MVI	A, 5
;
LOADBD:		STA	BDCODE + 1	; Change baud rate code value
		LDAX	B		; Get mode byte value
		STA	MODEBT + 1	; Change mode byte
		INX	B		; Point to cmd byte
		LDAX	B		; Get cmd byte
		STA	CMDBT + 1	; Change cmd byte
		JMP	INITMOD		; (Re)initialize modem
;
; Baudrate parameters (mode byte, command byte)
; All values give 8 data bits, 1 stop bit, no parity.
;
BD300:		DB	04FH, 037H	; 300 baud
BD600:		DB	04EH, 017H	; 600 baud
BD1200:		DB	04EH, 037H	; 1200 baud
;
BAUDBUF:	DB	10, 0
		DS	10
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
