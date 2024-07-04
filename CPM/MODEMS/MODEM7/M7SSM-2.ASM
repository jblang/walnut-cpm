; M7SSM-2.ASM -- SSM-I/O Board 
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; Much of the information contained here is not in the MDM712.ASM file.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the results
;		of this program to the original .COM file:
;
;		A>DDT MDM7xx.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4x00 0100
;		-IM7SSM-2.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4x00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)
;			^
;                       May vary depending upon version of MDM7xx.COM
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 04/30/84 - Renamed and revised for MDM7xx.COM -Dennis Recla
;
; 11/02/83 - Modified M712CS.ASM for CCS-SYSTEM and any S-100 type
;	     computer with the SSM I/O Board and an external 212A
;            (Bell 212A or Hayes Smartmodem 1200) modem.
;						- Harry Kaemmerer
;
; 10/29/83 - Modified MDM705XE for CCS-SYSTEM 320/420 and any S-100 type
;	     computers with the CCS-2830 I/O Board and an external 212A
;            (Bell 212A or Hayes Smartmodem 1200) modem.
;						- Harry Kaemmerer
;          
; 07/27/83 - Renamed to work with MDM712	- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
;
YES:		EQU	0FFH
NO:		EQU	0
;
PORT:		EQU	0AH		;Modem DART/SIO base port
MODCTL1:	EQU	PORT		;Modem control port
MODDATP:	EQU	PORT+1		;Modem data port
MODCTL2:	EQU	PORT		;Modem status port
MODRCVB:	EQU	01H		;Your bit to test for receive
MODRCVR:	EQU	01H		;Your value when receive ready
MODSNDB:	EQU	02H		;Your bit to test for send
MODSNDR:	EQU	02H		;Your value when send ready		
;
		ORG	100H
		DS	3	;(for  "JMP   START" instruction)
;
; Change the clock speed to suit your system
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	NO	;yes=HAYES Smartmodem 1200		104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;1=300 5=1200 8=9600 			107H
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms   108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	yes	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Clear Sreen routine 			10CH
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
TRANLOGON:	DB	no	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFFTST:	DB	NO	;yes=check for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	no	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
		DS	2		;				128H
IN$MODCTL1:	IN	MODCTL1		;get status
		RET ! NOP ! NOP
		NOP ! NOP
		DS	3
;
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		134H
		DS	7
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;				154H
OUT$MODCTL1:	ret ! nop ! nop		; Cant be used with a UART 	15AH
OUT$MODCTL2:	ret ! nop ! nop		; Cant be used with a UART 	15DH
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
; Do not change the following six lines.
;
JMP$ILPRT:	DS	3		;				183H
JMP$INBUF	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:		CALL	JMP$ILPRT	;Clears at all time all!	195H
		DB	0,0,0,0,0	;not in use for phk		198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;for TeleVideo 920 Terminal	19EH
		DB	1AH,0,0,0,0	;				1A1H
		RET			;				1A6H
					;
;-----------------------------------------------------------------------
;
;        You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER) if using the Hayes Smartmodem
;	 or by address 0C00H (2659 bytes) otherwise.
;
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'SSM I/O Board'
		DB	CR,LF,0
		RET
					;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; CTL-L if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:		DB	'XMODEM S',0	;,CR,LF,0
					;
;-----------------------------------------------------------------------
;
SENDBRK:  RET			; Cant be used with a UART
GOODBYE:  RET			; Cant be used with a UART
GOODBYE1: RET			; Cant be used with a UART
INITMOD:			; Cant be used with a UART
INITMOD1: MVI	A,5		; DEFAULT TRANSFER TIME TO 1200 BAUD
	  STA	MSPEED		;
INITMOD2: RET			; Cant be used with a UART
				;
;-----------------------------------------------------------------------
;
; Setup routine to allow changing modem speed with the SET command.
;
SETUPR:	  LXI	D,BAUDBUF	;POINT TO NEW INPUT BUFFER
	  CALL	JMP$ILPRT
	  DB	'Input Baud Rate (300 and 1200 set your Modem also): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;COMPARE BAUDBUF+2 WITH CHARACTERS BELOW
	  DB	'300',0
	  JNC	OK300		;GO IF GOT MATCH
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$ILPRT	;ALL MATCHES FAILED, TELL OPERATOR
	  DB	'Incorrect entry!',CR,LF,BELL,0
	  JMP	SETUPR		;TRY AGAIN
;
OK300:	  MVI	A,1
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
;
LOADBD:	  STA	INITMOD1+1	;CHANGE TIME-TO-SEND TO MATCH BAUDRATE
	  JMP	INITMOD1	;REINITIALIZE TO NEW BAUDRATE, THEN DONE
;
baudbuf:  DB	10,0
	  DS	10
;
;-----------------------------------------------------------------------
;
; The following routine can be used as an auxiliary menu for notes of
; interest to a particular computer, etc.  If using the Hayes Smartmodem
; this is unavailable without a special address change.
;
SPCLMENU: RET
;
;-----------------------------------------------------------------------
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	  END
