; M7NH-2.ASM -- North Star Horizon - HSIO-4 overlay file for MDM7xx. 01/14/84
;
; This overlay adapts the MDM7xx program to the North Star Horizon
; HSIO-4 serial I/O board. It uses the 8251 USART.
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
; It supports all the baud rates that the HSIO-4 supports even
; when it is not likeley you are running a dial up modem at that
; speed. I.E. 19200 baud. This still could be useful for a direct
; connection between two systems though.
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
;		4300 0100
;		-IM712GP.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM712.COM	(now have a modified .COM file)
;
;	use	A>SAVE 68 MDM715.COM	for ver 7.15 and
;		A>SAVE 69 MDM716.COM	for ver 7.16
; Check the .DOC files for other versions.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 01/14/83 - Rnamed and revised for mdm716	- Lloyd Miller
;		Adapted from MDM712GP.ASM
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
; THE FOLLOWING EQU CORRESPONDS TO PORT A OF THE HSIO-4
; 
PORT:		EQU	010H
MODCTL1:	EQU	PORT+3		;MODEM CONTROL PORT
MODDATP:	EQU	PORT+2		;MODEM DATA IN PORT
MODDATO:	EQU	PORT+2		;MODEM DATA OUT PORT
BAUDRP:		EQU	PORT		;BAUD RATE PORT
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
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200   107H
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
;
; ACKNAK IS OBSOLETE
		DS	1
;ACKNAK:	DB	NO	;yes=resend a record after any non-ACK	10DH
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
IGNORCTL:	DB	NO	;yes=CTL-chars above ^M not displayed	11DH
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
		DS	2		;				128H
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port	     	12AH
		DS	7
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
;
		DS	12		;				156H
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
; The following are set up for a Soroc terminal
;
CLREOS:		CALL	JMP$ILPRT	;				195H
		DB	ESC,'Y',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'+',0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Version for external modem'
		DB	' on a North Star Horizon / HSIO-4 port A'
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
; Add your own routine here to send a break tone to reset some time-share
; computers, if desired.
;
SENDBRK:
	MVI	A,2FH
	OUT	MODCTL1
	MVI	B,3
	CALL	JMP$TIMER	;300MS
	JMP	RESUME
;.....
;
;
; Add your own routine here to put DTR low and/or send a break tone.
; Check other routines such as MDM709DP.ASM which is using this feature.
;
GOODBYE:
	MVI	A,18H	; ERR RESET, SEND BREAK, DROP DTR
	OUT	MODCTL1
	RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.  You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
INITMOD:
	MVI	A,3	; stuff contreg in case it is waiting for sync bytes or
	OUT	MODCTL1	; has just been reset!
	OUT	MODCTL1
	MVI	A,40H	; INTERNAL RESET TO USART
	OUT	MODCTL1
	XTHL ! XTHL	; PAUSE FOR USART TO RESET
	MVI	A,4EH	; MODE ( ASYNC, 1 STOP, DISABLE PARITY,8BIT)
	OUT	MODCTL1
; INIT SPEED 300 OR 1200 ONLY ( SET MSPEED BYTE ABOVE FOR INITIAL SPEED
	LDA	MSPEED
	CPI	1
	MVI	A,6
	JZ	INIT300
	MVI	A,4
INIT300:
	OUT	BAUDRP
	JMP	RESUME
;
SETUPR:
	CALL	JMP$ILPRT
	DB	'SELECT SPEED -',CR,LF,LF
	DB	' A =   110 BAUD',CR,LF
	DB	' B =   300',CR,LF
	DB	' C =   600',CR,LF
	DB	' D =  1200',CR,LF
	DB	' E =  2400',CR,LF
	DB	' F =  4800',CR,LF
	DB	' G =  9600',CR,LF
	DB	' H = 19200',CR,LF
	DB	'(CR TO RECONECT WITHOUT SPEED CHANGE)-',0
	LXI	D,BAUDBUF
	CALL	JMP$INBUF
	LDA	BAUDBUF+1
	ORA	A
	JZ	RESUME
	LDA	BAUDBUF+2
	CPI	'H'+1
	JNC	SETUPR
	SUI	'A'
	JC	SETUPR
	ADD	A
	MOV	C,A
	MVI	B,0
	LXI	H,BAUDTAB
	DAD	B
	MOV	A,M
	STA	MSPEED
	INX	H
	MOV	A,M
	OUT	BAUDRP
RESUME:
	MVI	A,37H	; RTS, ERR RESET, RCV ENA, DTR, XMIT ENA
	OUT	MODCTL1
	RET
BAUDBUF:	DB	1,0
		DS	1
BAUDTAB	DB	0,7
	DB	1,6
	DB	3,5
	DB	5,4
	DB	6,3
	DB	7,2
	DB	8,1
	DB	9,0

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
