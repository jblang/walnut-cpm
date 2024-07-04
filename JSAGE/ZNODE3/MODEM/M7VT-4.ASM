; M7VT-4.ASM -- DEC Micro Overlay File for MDM7xx  01-Sep-84
;
; This OverlayFile supports the DEC Micros VT180, Rainbow and DECmate II
; with CP/M.
;
;	NOTE:  The speed of this program runs at whatever baudrate
;	       you have set your currently booted disk via CONFIG.
;	       If you need a different speed, you will need to boot
;	       a disk with a different CONFIG speed for that port.
;	       This requires a separate disk for each baud rate,
;	       with a subsequent reboot for the new speed.
;
; The micro's COMM-port is used.  Baudrates are "parallel" to the con-
; sole baudrates, no need for a "special" baudrate routine.  BDOS calls
; are used since the COMM-port is I/O-wise reader/punch.
;
; I/O byte redirection is used in conjunction with a direct BIOS-CONSTAT
; call to test for COMM-status.
;
; This technique (although a little slower than direct I/O using inter-
; rupt on INPUT) is general enough to be system independent.  Set one of
; the following selections to YES:
;
;		RAINBO1 for (old) Version 1 CP/M 80/86
;		RAINBO2 for (current) Version 2 of CP/M 80/86
;		DECMATE for DECmate II with CP/M option
;		ROBIN	for the VT180 (aka ROBIN)
;
;					- B. Eiben
;					  DEC Large System Marketing
;					  Marlboro, Mass.
;
;***********************************************************************
;
; You will want to look this file over carefully.  There are a number of
; options that you can use to configure the program to suit your taste.
;
; You could look at other overlay files to see how the GOODBYE and/or
; SETUPR areas are handled.  You could then adapt one of those, if ap-
; propriate for your equipment in this overlay.  Some examples:
;
;     "DP"  Datapoint 1560 overlay using 8251 I/O and CTC timers for
;	       setting baud rates
;     "H8"  Heath H89 overlay for 8250 I/O and programmable baud rates
;     "HZ"  Zenith 120 overlay for 2661B initialization and baud rates
;     "XE"  Xerox 820II overlay for Z80-SIO intialization, etc.
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
;		4A00 0100
;		-IM7VT-1.HEX		(note the "I" command)
;		-R			("R" loads in the .HEX file)
;		NEXT  PC
;		4A00 0000
;		-G0			(return to CP/M)
;		A>SAVE 73 MDM7xx.COM	(now have a modified .COM file)
;
; -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
;
; Or (easier and less error-prone) use MLOAD21.COM instead of the above
; DDT.COM merge-technique:
;
;		MLOAD21 MODEM.COM=MDM7xx.COM,M7VT-2.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 09/01/84  Updated for MDM740			- Irv Hoff
; 29/08/84  Changed to split Rainbow V1/V2	- B. Eiben
;	    (incompatible I/O byte)
; 11/24/83  Changed to add Rainbow and Decmate	- B. Eiben
; 11/11/83  Renamed to M7VT-1.ASM, no changes	- Irv Hoff
; 08/09/83  Revised to work with a VT180	- Michael Gwilliam
; 04/04/83  First version of this file		- Irv Hoff
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
ROBIN:		EQU	yes		;aka DEC VT180
RAINBO1:	EQU	NO		;Rainbow Software V1
RAINBO2:	EQU	NO		;Rainbow Software V2
DECMATE:	EQU	NO		;.. with CP/M option
;
;
;
BDOS:		EQU	0005		;address of BDOS entry
PUNCH:		EQU	4		;punch function
READER:		EQU	3		;reader function
MODDCDB:	EQU	4		;carrier detect bit
MODDCDA:	EQU	0		;value when active
MODRCVB:	EQU	0FFH		;bit to test for recedive
MODRCVR:	EQU	0FFH		;value when ready
MODSNDB:	EQU	0FFH		;bit to test for send
MODSNDR:	EQU	0FFH		;value when ready
;
;
		ORG	100H
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
AUTODIAL:	DB	YES	;yes=HAYES-type modem, no=other 	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
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
SETUPTST:	DB	NO	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	YES	;Cursor control routine 		10CH
RETRY:		DB	NO	;yes=reset the error limit to try again 10DH
				;no=resend a record after a valid-NAK
BAKUPBYTE:	DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVRUB:	DB	YES	;yes=convert rub to backspace		111H
TOGGLERUB:	DB	YES	;yes=allow toggling of rub to backspace 112H
BADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
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
IGNORCTL:	DB	YES	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send 300 ms. break tone		120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H	;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'\'-40H	;^\ = Send next character		127H
				;changed to be closer to KERMIT (B.G.E)
;
;
		DS	2		;				128H
;
IN$MODCTL1:	JMP	INCTL		;in modem control port		12AH
		DS	7
OUT$MODDATP:	JMP	OUTDATA		;out modem data port		134H
		DS	7
IN$MODDATP:	JMP	INDATA		;in modem data port		13EH
		DS	7
ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H

CPI$MODRCVR:	CPI	MODRCVR	! RET	;value of rcv. bit when ready	14BH
ANI$MODSNDB:	MVI	A,MODSNDB ! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H
		DS	6		;Together these do nothing	156H
;
OUT$MODCTL1:	RET ! NOP ! NOP		;out modem control port #2	15AH
OUT$MODCTL2:	RET ! NOP ! NOP		;out modem control port #1	15DH
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
CLREOS:	CALL	JMP$ILPRT	;				195H
	DB	ESC,'[','0','J',0;				198H
	RET			;				19DH
;
CLRSCRN:JMP	DECVT100	;				19EH
	DB	0,0,0,0,0	;				1A1H
	RET			;				1A6H
;
SYSVER:	CALL	JMP$ILPRT	;				1A7H
XSO:	EQU	14		;"shift out" character
XSI:	EQU	15		;"shift in" character
	DB	'Version for: ',ESC,'[7m',ESC,')0'
	DB	'd',XSO,'x',XSI
	DB	'i',XSO,'x',XSI
	DB	'g',XSO,'x',XSI
	DB	'i',XSO,'x',XSI
	DB	't',XSO,'x',XSI
	DB	'a',XSO,'x',XSI
	DB	'l',ESC,'[m '
;
	 IF ROBIN
	DB	'DEC VT180 and external modem'
	 ENDIF				;ROBIN
;
	 IF RAINBO1
	DB	'DEC Rainbow V1 and external modem'
	 ENDIF				;RAINBO1
;
	 IF RAINBO2
	DB	'DEC Rainbow V2 and external modem'
	 ENDIF				;RAINBO2
;
	 IF DECMATE
	DB	'DECMATE II and external modem'
	 ENDIF				;DECMATE
;
	DB	CR,LF,0
	RET
;.....
;
;
; Modem I/O primitive
;
; Subroutine to output a character to the modem.  This routine does it's
; own status checking.
;
OUTDATA:PUSH	B		;save...
	PUSH	D		;...the...
	PUSH	H		;...registers.
	MOV	E,A		;move output byte into E
	MVI	C,PUNCH		;use the BDOS function
	CALL	BDOS		;go
	POP	H		;restore...
	POP	D		;...the...
	POP	B		;...registers.
	RET
;.....
;
;
; Subroutine to input a character from the modem.
; This routine will wait until one becomes available.
;
INDATA:	PUSH	B		;save...
	PUSH	D		;...the...
	PUSH	H		;...regesters.
	MVI	C,READER	;use the BDOS function
	CALL	BDOS		;go
	POP	H		;restore...
	POP	D		;...the...
	POP	B		;...registers.
	RET
;.....
;
;
; Screen- Clearing needs more space than left above
;
DECVT100:
	CALL JMP$ILPRT
	DB	ESC,'[','2','J',ESC,'[','H',0
	RET
;
;
; The Check for characters at COMM-Port using I/O redirection
;
IOBYTE	EQU	3		;some definitions
;
	 IF RAINBO1 OR ROBIN
DEFIO	EQU	95H		;the "standard" setting
BATIO	EQU	56H
	 ENDIF			;RAINBO1 OR ROBIN
;
	 IF RAINBO2
DEFIO	EQU	15H		;the "standard" setting
BATIO	EQU	96H
	 ENDIF			;RAINBO2
;
	 IF DECMATE
DEFIO	EQU	81H		;the "standard" setting
BATIO	EQU	42H
	 ENDIF			;DECMATE
;
INCTL:	PUSH	B
	PUSH	D
	PUSH	H		;save the environment
	MVI	A,BATIO		;change I/O byte
	STA	IOBYTE
	CALL	BCONST		;call BIOS direct - see INITMOD
	PUSH	A
	MVI	A,DEFIO		;change I/O byte back
	STA	IOBYTE
	POP	A
	POP	H		;restore environment
	POP	D
	POP	B
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
; CTL-O if TRANLOGON has been set YES.	You can use several lines if
; desired.  End with a 0.
;
LOGON:	DB	'How are you today?',CR,LF,0
;.....
;
;
; Add your own routine here to send a break tone to reset some time-
; share computers, if desired.
;
SENDBRK:RET
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
INITMOD:LHLD	1		;Get BIOS jump-table adress
	LXI	D,3
	DAD	D		;CONSTAT routine in BIOS
	SHLD	BCONST+1	;modify our "routine"
	RET
;
BCONST:	JMP	$-$		;address "filled in" by above code
;
SETUPR:	RET
;.....
;
;
; If using the Hayes Smartmodem this is unavailable without a special
; change.
;
SPCLMENU: RET
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;.....
;
	  END
;
