
; M7H8-6.ASM -- Heath/Zenith H89 overlay file for MDM7xx.  01/24/85
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; This file places particular emphasis on using the Heath/Zenith equip-
; ment with 8250 serial I/O.  Much of the information contained here is
; not in the main file.  If not using the Heath/Zenith H89/Z89 equipment
; some of the routines here will illustrate what you could do with your
; unit.
;
; Use the "SET" command to change baudrate when desired.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
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
;		-IM7H8-6.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM.COM	(now have a modified .COM file)
;
;		NOTE: If the MDM7nn file gets bigger the SAVE 73 will be
;		larger. Be sure to check the hex number under NEXT..
;
;-----------------------------------------------------------------------
;
;	Quick, easy alternate method of combining this overlay with
;	MDM740.COM file using MLOAD.COM (Current version is MLOAD24.)
;
;		A>MLOAD MDM7.COM=MDM740.COM,M7H8-n.HEX <ret>
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 02/12/85 - Set to default to 1200 bps, added SETSPD option.  Use the
;  M7H8-7    M7RV-6.ASM overlay for use with Racal-Vadic 1200v or 2400v
;	     smartmodems after using this overlay first.  Other changes.
;					- Irv Hoff
;
; 01/24/85 - Added support for Racal Vadic/Hayes 2400 baud smartmodems
;  M7H8-6				- Larry Snyder
;
; 07/15/84 - Added support for 2400 baud modems
;  M7H8-5				- Larry Snyder
;
; 03/16/84 - Added smartmodem EQU so IF/ENDIF statements would work
;  M7H8-4A   work corectly.		- Mike Allen
;
; 02/26/84 - Corrected to allow smartmodem YES without overrunning
;  M7H8-4    0400H in assembly. 	- Bill Wood
;
; 02/15/84 - Made default baud-rate follow the MSPEED equate.
;  M7H8-3				- Rich Berg
;
; 12/11/83 - Restricted baud-rate selection for Hayes users.  Changed
;  M7H8-2    signon for Hayes, tells default modem speed at signon.
;					- Tom Bering
;
; 10/03/82 - First version of this file	- Irv Hoff
;
;-----------------------------------------------------------------------
;
;
; Set the speed you wish the unit to automatically initialize at:
;
SETSPD	EQU	5		; 2=300, 5=1200, 6=2400 bps (select one)
;
;-----------------------------------------------------------------------
;
;
NO	EQU	0
YES	EQU	0FFH		; (must be a 8-bit value for ASM.COM)
;
;
BELL	EQU	07H		; Bell
CR	EQU	0DH		; Carriage return
ESC	EQU	1BH		; Escape
LF	EQU	0AH		; Linefeed
;
;
; Change the value at MODDATP if it does not match what you are using.
;
MODDATP	EQU	0D8H		; Data port for H89
MODCTL1	EQU	MODDATP+5	; Status port for H89
MODRCVB	EQU	1		; Bit to test for received data
MODRCVR	EQU	1		; Modem receive ready
MODSNDB	EQU	20H		; Bit to test for ready to send
MODSNDR	EQU	20H		; Modem send ready bit
;
;-----------------------------------------------------------------------
;
;
		ORG	100H
;
;
; Change the clock speed if needed, to match your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 plug in modem		103H
AUTODIAL:	DB	YES	;yes=Hayes protocol, no=other		104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	20	;clock speed in MHz x .1, 25.5 MHz max. 106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	SETSPD	;set to desired default. 1=300 2=450	107H
				;4=600 5=1200 6=2400 8=9600
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;cursor control routine 		10CH
RETRY:		DB	YES	;reset the error limit to try again	10DH
				;no abort after 10 consecutive errors
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVRUB:	DB	YES	;yes=convert rub to backspace		111H
TOGGLERUB:	DB	YES	;yes=allow toggling rub to backspace	112H
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
XOFFTST:	DB	YES	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	NO	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone 	120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H	;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1	! RET	;in modem control port		12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP	! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP	! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	12		;PMMI only calls		154H
;
;
LOGONPTR:	DW	LOGON		;for user message.		160H
		DS	6		;				162H
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INIT		;go to user written routine	16BH
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
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM:	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;
; The following clear the screen for the H19 or H89 terminal
;
CLREOS:	CALL	JMP$ILPRT		;				195H
	DB	ESC,'J',0,0,0		;				198H
	RET				;				19DH
;
CLRSCRN:CALL	JMP$ILPRT		;				19EH
	DB	ESC,'E',0,0,0		;				1A1H
	RET				;				1A6H
;
SYSVER:	CALL	JMP$ILPRT		;				1A7H
	DB	'Version for Heath H89 with serial modem'
	DB	CR,LF,0
	CALL	JMP$ILPRT
	DB	'Default speed:  ',0
	CALL	BAUD
	CALL	JMP$ILPRT
	DB	' bps',CR,LF,0
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
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:	DB	'Hello from an Heath H89 user',CR,0
;.....
;
;
; This routine sends a 300 ms. break tone to reset some time-share
; computers.
;
SENDBRK:
	MVI	A,40H		; Set break tone
	OUT	MODDATP+3
	JMP	GOODBYE1	; Send a 300 ms. break tone
;.....
;
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.
;
GOODBYE:
	XRA	A
	OUT	MODDATP+4	; Set DTR and RTS low
	MVI	A,40H		; Set break tone
	OUT	MODDATP+3
;
GOODBYE1:
	MVI	B,3		; Wait 300 ms.
	CALL	JMP$TIMER
	MVI	A,03H		; Reset to normal 8 bits
	OUT	MODDATP+3
	MVI	A,01H
	OUT	MODDATP+4	; Reset DTR high
	RET
;.....
;
;
; Auto-selects the default message baudrate from SELECT option at start
; of overlay.
;
BAUD:	LDA	MSPEED
	CPI	1
	JNZ	BAUD5
	CALL	JMP$ILPRT
	DB	'300',0
	RET
;
BAUD5:	CPI	5
	JNZ	BAUD6
	CALL	JMP$ILPRT
	DB	'1200',0
	RET
;
BAUD6:	CPI	6
	JNZ	BAUD8
	CALL	JMP$ILPRT
	DB	'2400',0
	RET
;
BAUD8:	CALL	JMP$ILPRT
	DB	'9600',0
	RET
;
;
; Auto selects baud rate from SELECT option near start of overlay, which
; initializes the H89 8250 I/O port.
;
INIT:	LDA	MSPEED
	CPI	1
	JZ	OK300
	CPI	5
	JZ	OK1200
	CPI	6
	JZ	OK2400
	CPI	8
	JZ	OK9600
;
INITMOD:MVI	A,5		; Default transfer speed to 1200 baud
	STA	MSPEED
	DI			; Turn off interrupts for initialization
	XRA	A
	OUT	MODDATP+1	; Interrupt enable register
	MVI	A,80H		; Insure out of mode to set baud rate
	OUT	MODDATP+3	; Line control register
	OUT	MODDATP+3
;
LSPSPD:	MVI	A,60H		; Default 'LSP' speed for 1200 baud
	OUT	MODDATP		; Register for 'LSP' speed if enabled
;
MSPSPD:	MVI	A,00H		; Default 'MSP' speed for 1200 baud
	OUT	MODDATP+1	; Register for 'MSP' speed if enabled
;
	MVI	A,03H		; 8-level, 1 stop bit, no parity
	OUT	MODDATP+3	; Line control register
	MVI	A,01H		; Set 'DTR' nromal
	OUT	MODDATP+4	; Modem control register
	EI			; Restore interrupts to normal
	RET
;.....
;
;
; The following routine changes the baud rate for the H89 with the SET
; command.
;
SETUPR:	CALL	JMP$ILPRT
	DB	'Select Baud Rate (300, 1200, 2400, 9600) : ',0
	LXI	D,BAUDBUF	; Point to input buffer for INLNCOMP
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2	; Compare BAUDBUF+2 with/chars. below
	CALL	JMP$INLNCOMP
	DB	'1200',0
	JNC	OK1200
	CALL	JMP$INLNCOMP
	DB	'2400',0
	JNC	OK2400
	CALL	JMP$INLNCOMP
	DB	'9600',0
	JNC	OK9600
	CALL	JMP$ILPRT	; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	JMP	SETUPR		; None of these, ask again
;
OK300:	MVI	A,1		; MSPEED 300 baud value
	LHLD	BD300		; Get 300 baud parameters in HL
	JMP	LOADBD		; Go load them
;
OK1200:	MVI	A,5
	LHLD	BD1200
	JMP	LOADBD
;
OK2400:	MVI	A,6
	LHLD	BD2400
	JMP	LOADBD
;
OK9600:	MVI	A,8
	LHLD	BD9600
;
LOADBD:	STA	INITMOD+1	; Store speed to show transfer time
	MOV	A,L		; Get least significant baud rate byte
	STA	LSPSPD+1	; Store in INITMOD
	MOV	A,H		; Get most signifcant baud rate byte
	STA	MSPSPD+1	; Store in INITMOD
	JMP	INITMOD		; Reset H89 8250 for new speed
;.....
;
;
; Table of baud rate parameters
;
BD300:	DW	0180H
BD1200:	DW	0060H
BD2400:	DW	0030H
BD9600:	DW	000CH
;
BAUDBUF:DB	10,0
	DS	10
;
;-----------------------------------------------------------------------
;
; This routine can be used for your equipment, be sure to end with RET.
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	END
