
; M7LO-2.ASM -- Lobo Max-80 overlay file for MDM7xx.  06/01/84
;
; This overlay adapts the MDM7xx program to Max-80 computers from Lobo.
;	N O T E  -  This overlay sets the default baud rate to 1200 and
;		    starts off using serial port A.  It includes code to
;		    initialize the SIO so that XCONFIG need not be used.
;		    It also allows you to change the serial port used
;		    via the SET command. (fv)
;
; You will want to look this file over carefully.  There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using an external modem that
; does not match one of the other special overlays.
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
;		4x00 0100
;		-IM7LO-2.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4x00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)
;			^
;			This Value may vary depending upon vers of MDM7xx
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/84 - Cleaned up vers. nr. and Save      - Dennis Recla
; 12/20/83 - Revised set baud routine & set default
;	     1200 Baud. Also adds init coding	- Fred Viles
; 11/11/83 - Renamed to M7LO-1.ASM, no changes	- Irv Hoff
; 10/07/83 - Revised to include modem break	- Steven J. Davidson
; 08/22/83 - Revised to work with Max-80	- Larry Richards
; 07/27/83 - Revised to work with MDM712	- Irv Hoff
; 04/04/83 - 1st version of M712GP		- Irv Hoff
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
;	For port B use 0F7E6 (PORT) and 0F7D4 (BAUDRP).
;
;	For port A use:
;
PORT:		EQU	0F7E4H		;MAX-80 data port
MODCTL1:	EQU	PORT+1		;modem control port MAX-80
MODDATP:	EQU	PORT		;modem data in port
MODDATO:	EQU	PORT		;modem data out port
MODDCDB:	EQU	4		;carrier detect bit
MODDCDA:	EQU	0		;value when active
BAUDRP:		EQU	0F7D0H		;baud rate port MAX-80
MODCTL2:	EQU	PORT+1		;2nd modem control port
MODRCVB:	EQU	1		;bit to test for receive
MODRCVR:	EQU	1		;value when ready
MODSNDB:	EQU	4		;bit to test for send
MODSNDR:	EQU	4		;value when ready
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
CLOCK:		DB	50	;clock speed in MHz x10, 25.5 MHz max.	106H
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
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	NO	;yes=allow toggling of bksp to rub	112H
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
IN$MODCTL1:	LDA	MODCTL1 ! RET	;in modem control port MAX-80	12AH
		DS	6
OUT$MODDATP:	STA	MODDATP ! RET	;out modem data port MAX-80	134H
		DS	6
IN$MODDATP:	LDA	MODDATP ! RET	;in modem data port MAX-80	13EH
		DS	6
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H

CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				156H
;				The following are only used for PMMI
;				routines in MDM7xx, but OUT$MODCTL1 is
;				called from this overlay
OUT$MODCTL1:	STA	MODCTL1		;out modem control port #1	15AH
OUT$MODCTL2:	RET  !	NOP	! NOP	;out modem control port #2	15DH
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
; Routine to clear to end of screen.
;
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	1BH,59H,0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	1BH,2AH,0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for Lobo Max-80, defaults to Serial '
		DB	'port A at 1200 Baud',CR,LF,0
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
LOGON:	  DB	'Hello from a Lobo MAX-80 computer',CR,LF,0
;.....
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-share computers.
;
SENDBRK:  MVI	A,5
	  CALL	OUT$MODCTL1
	  MVI	A,0F8H		;send a break tone
	  JMP	GOODBYE1
;.....
;
;
; This routine sends a 300 ms. break tone and/or sets DTR low for the
; same length of time to disconnect some modems such as the Bell 212A,
; etc.	The second entry (GOODBYE1) just sends the modem break, needed
; to "alert" some timesharing services.
;
;
GOODBYE:  MVI	A,5
	  CALL	OUT$MODCTL1	;send to the status port
	  MVI	A,68H		;turn off dtr
;
GOODBYE1: CALL	OUT$MODCTL1
	  MVI	B,3		;wait for 300 ms.
	  CALL	JMP$TIMER
	  MVI	A,5
	  CALL	OUT$MODCTL1
	  MVI	A,0E8H		;restore to normal, 8 bits, dtr on, etc.
	  CALL	OUT$MODCTL1
	  RET
;.......
;
;
; --- Initialize Serial Port hardware and establish default baud rate.
;
INITMOD:
;					Set the default baud rate
	CALL	SETDEFB
;					Initialize the SIO
REINIT:
	MVI	A,01
	CALL	OUT$MODCTL1	; SELECT REGISTER
	MVI	A,0	; SET TO DISABLE INTERRUPTS ON THIS CHANNEL
	CALL	OUT$MODCTL1
	MVI	A,04H
	CALL	OUT$MODCTL1	; SELECT REGISTER
	MVI	A,044H	; 16X CLOCK, 1 STOP BIT, NO PARITY
	CALL	OUT$MODCTL1
	MVI	A,03
	CALL	OUT$MODCTL1	; SELECT REGISTER
	MVI	A,0C1H	; 8 BITS/CHAR., RX ENABLE, AUTO DISABLE
	CALL	OUT$MODCTL1
	MVI	A,05
	CALL	OUT$MODCTL1	; SELECT REGISTER
	MVI	A,0EAH	; DTR, 8 BITS/CHAR., TX ENABLE, RTS
	JMP	OUT$MODCTL1
;
;.....
;
; --- Set modem speed via the SET command.---
;	First get the desired baud rate from the user.
; 	NOTE: only the first 3 characters of the
;	      baud rate string entered by the user
;	      is used.
;
SETUPR:
	LXI	D,BAUDBUF	;POINT TO NEW INPUT BUFFER
	CALL	JMP$ILPRT
	DB	'Input Baud Rate (300, 1200, 9600, etc - space for 1200)',CR,LF
	DB	'   or Port (A or B) or both (A300, B19200, etc): ',0
	CALL	JMP$INBUF
	LXI	H,BAUDBUF+2	; Point to users entry
	MOV	A,M		; Get first character
	CPI	20h		; Space?
	JZ	SETDEFB		; Yes, go set default baud rate
	STA	APORT		; Store character in msg just in case
	SUI	'0'
	CPI	10		; Digit?
	JC	FINDBD		; Yes, go find baud rate in table
	SUI	17
	CPI	2		; 'A' or 'B'?
	JNC	SETERR		; No, invalid entry
;
;			Reset the Serial port in use
;
	RLC			; 'A' = 0, 'B' = 2
	PUSH	PSW		; Save it
	ADI	0E4h		; Data port address low byte
	STA	IN$MODDATP+1
	STA	OUT$MODDATP+1
	INR	A		; Control Port address low byte
	STA	IN$MODCTL1+1
	STA	OUT$MODCTL1+1
	POP	PSW		; Restore 0 or 2
	RLC			; Make 0 or 4
	ADI	0D0h		; Baud rate port address low byte
	STA	BDOUT+1
	CALL	REINIT		; Re-do initialization for new port
	CALL	JMP$ILPRT
	DB	CR,LF,'Serial port '
APORT:	DS	1
	DB	' is now in use.',CR,LF,0
;
	LXI	H,BAUDBUF+3	; Point to next byte in user entry
	MOV	A,M		; Get it
	SUI	'0'
	CPI	10		; Digit?
	RNC			; No, We are all done
;				  Yes, fall thru to set the baud rate
FINDBD: SHLD	PTR		; Save ptr to user entry
	LXI	D,BDTAB	; Point to baud rate table
	MVI	B,NTAB	; Get # of entries to search thru
;				TOP OF LOOP - scanning baud rate table
SLOOP:	LHLD	PTR	; Get ptr to users entry
	PUSH	D	; Save the table pointer
;
	MVI	C,3	; Compare 3 characters of string
SLOOP1:	LDAX	D	; Get next character from table entry
	CMP	M	; Match user string?
	JNZ	X1	; No, so try next table entry
	INX	H	; Yes, so check next character if any
	INX	D
	DCR	C	;
	JNZ	SLOOP1	; Loop to test all 3 characters
;
X1:	POP	H	; Restore pointer to current table entry
	JZ	SETUP	; If match, set baud rate and return
	LXI	D,BWDS+4
	DAD	D	; Point to the next table entry
	XCHG
	DCR	B	; Count down # of table entries
	JNZ	SLOOP	; Loop to test next entry if any
;
SETERR:	CALL	JMP$ILPRT  ; No match found in table, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	JMP	SETUPR	; Give user another try
;
;		Set up the baud rate. HL points to the command string
;
SETDEFB:		;	This entry sets the baud rate to the default
	LXI	D,DEFBD+3
;
SETUP:	LDAX	D	; Get new MSPEED value
	STA	MSPEED	; Store it
;				Loop sending baud rate control bytes
	MVI	C,BWDS	; Init loop counter
SULOOP:	INX	D	; Increment control string pointer
	LDAX	D	; Get next control byte
BDOUT:	STA	BAUDRP	; Send it to the baud rate port
	DCR	C	; Decrement the loop conter
	JNZ	SULOOP	; Loop til done
	RET
;
; --- BAUDRATE TABLE FOR CCS 2719 BAUD RATE GENERATOR ---
;
BWDS	EQU	1	; # OF BYTES TO SEND TO BAUD RATE CHIP
BDTAB:
	DB	'110',0,2
	DB	'300',1,5
	DB	'600',3,6
DEFBD:	DB	'120',5,7	; 1200 BAUD (default)
	DB	'240',6,0Ah	; 2400
	DB	'480',7,0Ch	; 4800
	DB	'960',8,0Eh	; 9600
	DB	'192',9,0Fh	; 19200
;
ENTAB	EQU	$
;
NTAB	EQU	(ENTAB-BDTAB)/(BWDS+4)	; # OF TABLE ENTRYS
;
PTR:	DS	2
;
BAUDBUF:  DB	10,0
	  DS	10
;.....
;
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU:  RET
;
;
; NOTE:  Must terminate prior to 0400H (with Smartmodem)
;				