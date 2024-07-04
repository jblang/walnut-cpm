
; M7AM-1.ASM -- Apple ][ with Mountain Computer CPS card overlay for
;		MDM7xx.ASM - 11/11/83.
;
; This overlay adapts the MDM7xx program to the Mountain Computer CPS
; card and the Soroc IQ-120 emulator within Apple CP/M.  The LSTSTS BIOS
; entry is configured into the PARPRINT driver at the end by Ron Heiby.
; If you don't implement it, printer buffering won't work at all.
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
;		-IM7AM-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4300 0000
;		-G0			(return to CP/M)
;		A>SAVE 66 MDM7xx.COM	(now have a modified .COM file)
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 11/11/83 - Renamed to M7AM-1.ASM, no changes	- Irv Hoff
; 10/01/83 - Added MARK/NOMARK parity.		- Ron Heiby
; 08/17/83 - Extended SETable items.		- Ron Heiby
; 08/09/83 - Changed log message character.	- Ron Heiby
; 08/17/83 - Modified to M707GP for Apple	- Ron Heiby
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
CLOCK:		DB	20	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	1	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	1	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
NOOFCOL:	DB	5	;number of DIR columns shown		10AH
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	YES	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	NO	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	YES	;yes=local command if EXTCHR precedes	117H
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
IN$MODCTL1:	RET			;in modem control port		12AH
		DS	9
OUT$MODDATP:	ORI	0		;OUT$MODDATP+1 is mask location 134H
		JMP	RH$OUTDATP	;out modem data port		136H
		DS	5
IN$MODDATP:	JMP	RH$INDATP	;in modem data port		13EH
		DS	7
ANI$MODRCVB:	RET  !	NOP  !	NOP	;bit to test for receive ready	148H
CPI$MODRCVR:	JMP	RH$MODRCVR	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	RET  !	NOP  !	NOP	;bit to test for send ready	14EH
CPI$MODSNDR:	XRA A ! RET  !	NOP	;value of send bit when ready	151H
		DS	6		;				154H
;
OUT$MODCTL1:	RET  !	NOP  !	NOP	;out modem control port #2	15AH
OUT$MODCTL2:	RET  !	NOP  !	NOP	;out modem control port #1	15DH
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
		DB	ESC,'Y',0,0,0	;				198H
		RET			;				19DH
;
CLRSCRN:	CALL	JMP$ILPRT	;				19EH
		DB	ESC,'*',0,0,0	;				1A1H
		RET			;				1A6H
	
;
SYSVER:		CALL	JMP$ILPRT	;				1A7H
		DB	'Apple ][ with CPS card',CR,LF,0
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
; CTL-L if TRANLOGON has been set TRUE.  You can use several lines if
; desired.  End with a 0.
;
LOGON:	DB	'L',0
;.....
;
;
; Add your own routine here to send a break tone to reset some Tym-Shar
; computers, if desired.
;
SENDBRK:PUSH	PSW
	PUSH	D
	MVI	A,80H
	STA	0E2FEH
	MVI	A,2FH
	STA	0E2FBH
	LXI	D,10000		;pause here
;
SLEEP1:	DCX	D
	MOV	A,D
	ORA	E		;both d&e zero?
	JNZ	SLEEP1
	MVI	A,27H
	STA	0E2FBH
	MVI	A,00H
	STA	0E2FEH
	POP	D
	POP	PSW
	RET
;.....
;
;
; Add your own routine here to put DTR low and/or send a break tone.
; Check other routines such as MDM709DP.ASM which is using this feature.
;
GOODBYE:RET
;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
INITMOD:LDA	MSPEED		;be sure baud rate set
	CPI	1		;300 baud?
	JZ	OK300
	CPI	5		;1200 baud?
	JZ	OK1200
	CALL	JMP$ILPRT
	DB	'Bad baud. Use SET.',CR,LF,BELL,0
	RET
;.....
;
;
SETUPR:	LXI	D,BAUDBUF	;point to input buffer for inlncomp
	CALL	JMP$ILPRT
	DB	'All but HAYES and baud set NOHAYES!',CR,LF,LF
	DB	'HAYES, NOHAYES, TOUCH, PULSE, BAK, NOBAK,',CR,LF
	DB	'IGNORECTL, NOIGNORE, MARK or NOMARK parity,',CR,LF
	DB	'or cps rate (30 or 120): ',0
	CALL	JMP$INBUF
	LXI	D,BAUDBUF+2
	CALL	JMP$INLNCOMP	;cmpr baudbuf+2 with chars below
	DB	'30',0
	JNC	OK300		;go if got match
	CALL	JMP$INLNCOMP
	DB	'120',0
	JNC	OK1200
	MVI	A,NO		;kill off hayes to avoid sending
	STA	SMARTMODEM	;"at" to the modem.
	CALL	JMP$INLNCOMP
	DB	'NOHAYES',0
	RNC
	CALL	JMP$INLNCOMP
	DB	'HAYES',0
	JC	LBL2
	MVI	A,YES
	STA	SMARTMODEM
	RET
;.....
;
;
LBL2:	CALL	JMP$INLNCOMP
	DB	'TOUCH',0
	JC	LBL3
	MVI	A,'T'
	STA	TOUCHPULSE
	RET
;.....
;
;
LBL3:	CALL	JMP$INLNCOMP
	DB	'PULSE',0
	JC	LBL4
	MVI	A,'P'
	STA	TOUCHPULSE
	RET
;.....
;
;
LBL4:	CALL	JMP$INLNCOMP
	DB	'BAK',0
	JC	LBL5
	MVI	A,YES
	STA	BAKUPBYTE
	RET
;.....
;
;
LBL5:	CALL	JMP$INLNCOMP
	DB	'NOBAK',0
	JC	LBL6
	MVI	A,NO
	STA	BAKUPBYTE
	RET
;.....
;
;
LBL6:	CALL	JMP$INLNCOMP
	DB	'IGNORECTL',0
	JC	LBL7
	MVI	A,YES
	STA	IGNORCTL
	RET
;.....
;
;
LBL7:	CALL	JMP$INLNCOMP
	DB	'MARK',0
	JC	LBL8
	MVI	A,80H
	STA	OUT$MODDATP+1
	RET
;.....
;
;
LBL8:	CALL	JMP$INLNCOMP
	DB	'NOMARK',0
	JC	LBL9
	MVI	A,0
	STA	OUT$MODDATP+1
	RET
LBL9:	CALL	JMP$INLNCOMP
	DB	'NOIGNORE',0
	JC	SETUPR		;none of above, so try again
	MVI	A,NO		;do set to allow control chars
	STA	IGNORCTL
	RET
;.....
;
;
OK300:	MVI	A,1
	STA	MSPEED
	MVI	A,35H		;baud parameter
	PUSH	PSW
	JMP	COMMONBAUD
;
OK1200:	MVI	A,5
	STA	MSPEED
	MVI	A,37H		;baud parameter
	PUSH	PSW
;
COMMONBAUD:
	MVI	A,0
	STA	0E2F8H		;1st baud location on cps
	POP	PSW
	STA	0E2F2H		;2nd baud location on cps
	LXI	H,CPSINIT+1000H	;use memory map offset for 6502
	SHLD	0F3D0H
	LHLD	0F3DEH
	MOV	M,A
	RET
;.....
;
;
CPSINIT:DB	20H,000H,0C2H	;jsr $c200 (to init card)
	DB	60H		;rts
;
BAUDBUF:DW	15,0		;tells clearbuf routine it can...
	DS	15		;..clear next fifteen bytes.
;
RH$OUTDATP:
	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	MOV	C,A
	CALL	0F285H		;'XOUT' serial output routine for cps
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET
;.....
;
;
RH$INDATP:
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	0F28AH		;make sure a character is available
	ANI	01H
	JZ	NOGET		;before actually trying to get it
	CALL	0F280H		;'XINP' serial input routine
;
NOGET:	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
RH$MODRCVR:
	PUSH	B		;value receive ready (0 if char present)
	PUSH	D
	PUSH	H
	CALL	0F28AH		;'XSTAT' get serial status
	ANI	01H		;mask off all other bits
	RAR			;put it into carry
	CMC			;complement it
	RAL			;put it back into accumulater
	ANA	A		;set the flags
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU:
	RET
;.....
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;.....
;
	END
;
learbuf routine it can...
	DS	15		;..clear next fifteen bytes