; M7SCAT.ASM  Novation Smart-Cat overlay for MDM714 - 03/10/84
; NOTES: (1) This overlay will not work with MDM724. (CEH)
;	 (2) The machine dependent code in this overlay is for
;	     the H/Z H-89.  It might need to be changed for you use.
;
; This overlay is a modification of M7RV-1.ASM, which was written for
; the Racal-Vadic VA212PA modem.  That overlay had some problems with
; sending characters out to the modem too fast for it to accept them.
; This problem was corrected in the overlay for the VA3451.  This overlay
; was, in turn, created from it.  The delay timer routine is called TIMER5,
; and is called with a delay value in the B register.  This value is
; obtained from the value that is stored at the TDELAY equate, which
; must be selected before assembly.  TDELAY is the number of 100mS
; segments in the delay.  The default value for the Smart-Cat is 3.
;
; A DEBUG feature had been added that can be selected by setting the
; DBUG equate to YES.  This function was added mainly to permit
; debugging with full control over the DTR signal to the phone.  This
; function might be desired as a permanent feature.  It becomes one of
; the SET choices if selected, and appears in the SET menu.
;
; This overlay is configured for the Heath/Zenith H-89.  Other machines
; will require changes to the PORT addresses and functions and the
; INITMOD routine as required for a particular UART.  Also, change
; SETUPR, SETDTRH, and SETDTRL as required.  Changes might also be
; needed at the CLREOS and CLRSCRN DB values.  The SYSVER can be
; configured to any reasonable signon desired.
;
; Caution is advised in setting up names in the internal number library.
; The Smart-Cat does not have an offline command arrangement, as found
; in the Hayes SmartModem and The Vadic units.	It reserves the character
; '%' to tell the modem that a command is comming.  This character is
; not sent out to the line, and will be accepted at any time to set the
; modem into the command mode.	This character is sent out by the program
; as a preamble to sending out the phone number.  IT SHOULD NEVER be
; included in the library listing in ANY location.  The modem also recog-
; nizes several other characters that may be placed within the phone
; number string.  They are 'I' (impulse dialing - default is DTMF),
; 'P' (pause), and 'W' (wait).	Also '*' and '#' (used in PABX dialing).
; All other alpha characters are discarded by the program.
; The reserved alpabetical characters may appear in the name field of
; the library listing, BUT ONLY AS LOWER CASE CHARACTERS).  The program
; scans the entire library entry for the number; hence, NO RESERVED
; character or NO DIGIT may appear unless it is actually part of the
; number.  If Novation ever adopts the procedure of sending control
; strings only when DTR is off, then placing the modem in UNLISTEN
; mode when DTR is on, this problem can be solved.
;
; Another consequence of this arrangement is that the modem can not be
; used for XMODEM transfers unless it is placed into the UNLISTEN mode,
; either by internal switch or by terminal mode command.  After this is
; done, the power must be cycled to get it back into command mode.  It
; also defaults to 7-bit characters for ASCII operation.  It must be set
; for 8-bit characters for XMODEM transfers.
;
; This code may not be optimum by any means.  The TDELAY value of 3
; might be reduced without causing problems.  The 3.5 second delay that
; is provided at DISCONNT2 to provide plenty of time for the modem to
; recover from a disconnect might be greater than needed and slows the
; response to redialing.  The disabled code at DISCONNT that was supposed
; to help reinitialize the modem prevented the program from working,
; perhaps because there was insufficient time delay to recover from it.
; the %I initialization command was not used because the modem takes
; 5-10 seconds to cycle through its routine.  It might have been used
; to some advantage.  If the program seems slow, the user is invited to
; experiment with these values and features.
;
; The Novation Smart-Cat modem is configured as follows:
;
;	SWITCH		SETTING 	RESULT
;	1		OFF		Transparent mode not forced
;	2		ON		Not quiet mode
;	3		ON		Verbose responses (required here)
;	4		ON		1200 baud default data rate
;	5		OFF		Auto-answer off
;	6		OFF		Carrier detect not required.
;
; For PABX use, # and * may be used on the phone number command line.
; (Read the manual for use of the I, P, and W commands within the number).
;
; Initialization routines need to be changed to support your I/O devices
; are INITMOD:,  SETUPR: SETDTRH: and SETDTRL: - Examples for USART
; initialization may be found in BYE2-16.LBR.  The modem is disconnected
; from on-line by dropping the DTR line, this must be implemented in the
; SETDTRL: routine in accordance with your I/O devices.  The modem is
; enabled by setting DTR high and must be implemented in your SETDTRH:
; routine.
;
;	To install the overlay make your changes for the USART
;	dependent routines.  This overlay may directly be used
;	if using a Zilog Z-80 SIO for I/O and a CTC for the baud
;	rate clock, just change ports and time constant for CTCs
;
;	A>DDT MDM7xx.COM   (Any .COM version of MDM714)
;	DDT VERS 2.2
;	NEXT   PC
;	4300  0100
;	-IM7SCAT.HEX
;	-R
;	NEXT   PC
;	4300  0000
;	-G0		   (or CTRL-C)
;
;	A>SAVE 66 M7SCAT.COM
;
;***********************************************************************
;
; 03/10/84 - Configured for the Novation
;	     Smart-Cat Modem and called M7SCAT.ASM - Charles Horn
; 03/03/84 - Configured for the VA3451 and
;			   called M7RV3451.ASM	- Charles Horn
; 11/11/83 - Renamed to M7RV-1.ASM, no changes	- Irv Hoff
; 10/15/83 - First version for Racal-Vadic	- Fred Willink
;
;***********************************************************************
;
; Change these equates for YOUR ports
; Change the value at MODDATP if it does not match what you are using.
;
MODDATP:	EQU	0D8H		;data port for H89
MODCTL1:	EQU	MODDATP+5	;status port for H89
MODRCVB:	EQU	1		;bit to test for received data
MODRCVR:	EQU	1		;modem receive ready
MODSNDB:	EQU	20H		;bit to test for ready to send
MODSNDR:	EQU	20H		;modem send ready bit
;
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
YES:		EQU	0FFH
NO:		EQU	0
;
DBUG:		EQU	YES		;Set to NO for normal use (CEH)
;
TDELAY: 	EQU	3		;DELAY5 value. 1=100 mS, 2=200mS,etc.
;
CANCEL:		EQU	'X'-40H	;^X = Cancel
ESC:		EQU	'['-40H	;^[ = escape
BELL:		EQU	'G'-40H	;^G = bell character
LF:		EQU	'J'-40H	;^J = linefeed
CR:		EQU	'M'-40H	;^M = carriage return
PRINT:		EQU	9
BDOS:		EQU	0005H
;
LIBLEN:		EQU	34
;
;=======================================================================
;
		ORG	0100H
;
;
		JMP	START	;skip the data area below
;
PMMIMODEM:	DB	NO
SMARTMODEM:	DB	YES	; yes=Novation Smart-Cat. The main
				; program test this byte to use the
				; new routines
		DS	1
CLOCK:		DB	20	;clock speed x10, up to 25.5 mhz.
				;2 MHz=20, 3.68 MH=37, 4 MHz=40, etc.
MSPEED:		DB	5	;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY: 	DB	0	;Default time to send character in
				;terminal mode file transfer (0-9)
CRDLY:		DB	0	;End of line delay after CRLF in terminal
				;mode file transfer (0-9).
				;0=zero delay, 1=10mS, 5=50mS, 9=90mS.
NOOFCOL:	DB	5	;number of columns in directory
SETUPTST:	DB	YES	;yes=non-PMMI setup routine
SCRNTEST:	DB	YES	;yes=home cursor and clear screen
		DS	29
;
;
; Handles in/out ports for data and status
;
IN$MODCTL1:	IN	MODCTL1 ! RET	;in modem control port
		DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
OUT$MODDATP:	OUT	MODDATP	! RET	;out modem data port
		DB	0,0,0,0,0,0,0	;spares if needed for non=PMMI
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port
		DB	0,0,0,0,0,0,0	;spares if needed for non-PMMI
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when ready
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready
;
IN$BAUDRP:	RET	!  NOP	! NOP	 ;in baudrate port
OUT$BAUDRP:	RET	!  NOP	! NOP	 ;out baudrate port
OUT$MODCTL1:	OUT	MODCTL1	! RET	 ;out modem control port #1
OUT$MODCTL2:	RET	!  NOP	! NOP	 ;out modem control port #2
;
LOGONPTR:	DW	LOGON
JMP$DIAL:	JMP	DIAL
JMP$DISCONNT:	JMP	DISCONNT
JMP$GOODBYE:	JMP	GOODBYE
JMP$INITMOD:	JMP	INITMOD
JMP$NEWBAUD:	RET
		DS	2
JMP$NOPARITY:	RET
		DS	2
JMP$PARITY:	RET
		DS	2
JMP$SETUPR:	JMP	SETUPR
JMP$SPCLMENU:	RET
		DS	2
JMP$SYSVER:	JMP	SYSVER
JMP$BREAK	RET
		DS	2
;
JMP$ILPRT:	JMP	ILPRT
JMP$INBUF:	JMP	INBUF
JMP$INLNCOMP:	JMP	INLNCOMP
JMP$INMODEM:	JMP	INMODEM
JMP$NXTSCRN:	JMP	NXTSCRN
JMP$TIMER:	JMP	TIMER
;
;
; Clear sequences are for H/Z H-89.  Change to match
; your terminal.
;
CLREOS:		CALL	ILPRT
		DB	ESC,'J',0,0,0	;HZ-89
		RET
;.....
;
;
CLRSCRN:	CALL	ILPRT
		DB	ESC,'E',0,0,0	;HZ-89
		RET
;.....
;
;
;======================== SIGN-ON MESSAGE ==============================
;
; Send version number and date
;
SYSVER: CALL	ILPRT
	DB	'Version for the Novation SmartCat Modem',CR,LF
	DB	'(Starts at 1200 Baud)',CR,LF,0
	RET
;.....
;
;
;==================== LOGON MESSAGE (IF ANY) ===========================
;
; Insert your logon message here.  End with a 0 (for "CALL ILPRT").
;
LOGON:	DS	59		;UP TO 59 CHARACTERS ALLOWED
	DB	0		;TO TERMINATE THE LOGON MESSAGE
;.....
;
;
;===================== USART INITIALIZATION ============================
;
; Begining of USART dependent routines change as needed
;
;=======================================================================
;
; NOTE: The DTR line is used to control the modem
;

INITMOD:  MVI	A,5		;default transfer speed to 1200 baud
	  STA	MSPEED
	  DI			;turn off interrupts for init.
	  XRA	A
	  OUT	MODDATP+1	;interrupt enable register
	  MVI	A,80H		;insure out of mode to set baud rate
	  OUT	MODDATP+3	;line control register
	  OUT	MODDATP+3	;again
;
LSPSPD:   MVI	A,60H		;default 'LSP' speed for 1200 baud
	  OUT	MODDATP		;register for 'LSP' speed if enabled
;
MSPSPD:   MVI	A,00H		;default 'MSP' speed for 1200 baud
	  OUT	MODDATP+1	;register for 'MSP' speed if enabled
;
	  MVI	A,03H		;8-level, 1 stop bit, no parity
	  OUT	MODDATP+3	;line control register
	  MVI	A,01H		;set 'DTR' for proper modem output level
	  OUT	MODDATP+4	;modem control register
	  EI			;restore interrupts to normal
	  RET
;.....
;The following routine changes the baud rate for the H89 with the SET
; command.
;
;SETUPR = SPEED CHANGE
SETUPR:	  LXI	D,BAUDBUF	;point to input buffer for INLNCOMP
	  CALL	JMP$ILPRT
	IF DBUG
	  DB	'(DTR ON: Type ON) (DTR OFF: Type OFF)',CR,LF
	ENDIF	;DBUG
	  DB	'Input Baud Rate (300, 450, 600, 1200, 9600): ',0
	  CALL	JMP$INBUF
	  LXI	D,BAUDBUF+2
	  CALL	JMP$INLNCOMP	;compare BAUDBUF+2 with characters below
	  DB	'300',0
	  JNC	OK300		;go if got match
	  CALL	JMP$INLNCOMP
	  DB	'450',0
	  JNC	OK450
	  CALL	JMP$INLNCOMP
	  DB	'600',0
	  JNC	OK600
	  CALL	JMP$INLNCOMP
	  DB	'1200',0
	  JNC	OK1200
	  CALL	JMP$INLNCOMP
	  DB	'9600',0
	  JNC	OK9600
;
	IF DBUG 		;not normally needed
	  CALL	JMP$INLNCOMP
	  DB	'ON',0
	  JNC	SETDTRH
	  CALL	JMP$INLNCOMP
	  DB	'OFF',0
	  JNC	SETDTRL
	ENDIF	;DBUG
;
	  CALL	JMP$ILPRT	;all matches failed - tell operator
	  DB	'++ Incorrect entry ++',CR,LF,BELL,0
	  JMP	SETUPR		;try again
;
OK300:	  MVI	A,1		;MSPEED 300 baud value
	  LHLD	BD300		;get 300 baud parameters in HL
	  JMP	LOADBD		;go load them
;
OK450:	  MVI	A,2
	  LHLD	BD450
	  JMP	LOADBD

OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
;
LOADBD:	  STA	INITMOD+1	;store speed to show transfer time 
	  MOV	A,L		;get least significant baud rate byte
	  STA	LSPSPD+1	;store in INITMOD
	  MOV	A,H		;get most signifcant baud rate byte
	  STA	MSPSPD+1	;store in INITMOD
	  JMP	INITMOD		;reset H89 8250
;
;
; Table of baud rate parameters
;
BD300:	  DW	0180H
BD450:	  DW	0100H
BD600:	  DW	00C0H
BD1200:	  DW	0060H
BD9600:	  DW	000CH
;
BAUDBUF:  DB	10,0
	  DS	10
;
;
;RAISE DTR TO ENABLE MODEM
;
SETDTRH:  MVI	A,01H
	  OUT	MODDATP+4	
	  RET
;
;DROP DTR TO DISABLE MODEM
;
SETDTRL:  MVI	A,00H
	  OUT	MODDATP+4
	  RET
; 
;		    End of USART dependent routines
;=======================================================================
;
;		     RACAL-VADIC DIALING ROUTINES
;
;=======================================================================
;
; Dialing routine
;
DIAL:	  XRA	A
	  STA	CRFLAG
	  STA	RINGBKFL
	  STA	RINGFLG
	  LXI	H,0
	  SHLD	DIALCT
	  LXI	H,CMDBUF+1
	  MOV	A,M
	  CPI	3+1
	  JC	DIAL1			;if only CAL was entered
;
;
; If there were only 3 characters, then "CAL<RET>" was typed -- the user
; obviously expecting to get a phone number (or letter) from the library
; file.  If 4 or more, a number (or letter) was typed in from the menu
; command line, so move the characters down 4 to compensate.  Needed for
; auto-redialing of menu command line entries.
;
	  MOV	C,A
	  MVI	B,0
	  SUI	4
	  MOV	M,A
	  INX	H
	  XCHG
	  LXI	H,CMDBUF+6
	  CALL	MOVER
	  JMP	DIAL4			;with letter or number at CMDBUF+2
;...
;
;
; Comes here if no phone number was manually entered after "CAL" and if
; no phone library letter was entered.	Displays the phone number li-
; brary, then asks for an entry.
;
DIAL1:	  MVI	C,13
	  LXI	H,NUMBLIB
	  LXI	D,BUFFER
	  CALL	NEWLINE
	  STAX	D
	  INX	D
;
DIAL2:	  MVI	B,LIBLEN
	  CALL	MOVE
	  CALL	SPACES
	  MVI	B,LIBLEN
	  CALL	MOVE
	  CALL	NEWLINE
	  DCR	C
	  JNZ	DIAL2
;
DIAL3:	  MVI	A,'$'
	  STAX	D
	  CALL	CLRTST		;clear screen
	  MVI	C,PRINT
	  LXI	D,BUFFER	;show library
	  CALL	BDOS
	  CALL	ILPRT
	  DB	CR,LF,'Enter library letter or phone number,',CR,LF
	  DB	'CTL-X quits while dialing or ringing: ',0
	  LXI	D,CMDBUF
	  CALL	INBUF		;get input, library letter or phone #
;
;
; You now have either a library letter or a manually entered phone num-
; ber.	These either came from the menu command line or from the library
; command line.  Next we see if a letter, if so, get the corresponding
; line with phone number from the library.  If a number we ignore the
; library look-up.  (Ringback numbers must end with letter 'R'.)
;
DIAL4:	  LXI	H,CMDBUF+1
	  MOV	A,M
	  ORA	A
	  JZ	DIALEXIT	;no entry in command line exit
	  PUSH	H
	  CALL	DISCONNT	;hangup modem and drop DTR
	  POP	H
	  INX	H
	  MVI	B,'A'
	  MVI	E,0
	  MVI	C,26
	  MOV	A,M
;
DIAL5:	  CMP	B
	  JZ	DIAL6		;If a letter
	  INR	B
	  INR	E
	  DCR	C
	  JZ	DIAL9		;If a number
	  JMP	DIAL5
;
;
; Now have a match between the requested letter and one in the library
; E-reg. holds the decimal equivalent (1-26) of the letter (A-Z).
;
DIAL6:	  LXI	H,NUMBLIB	;come here if a letter
	  LXI	B,LIBLEN
	  MOV	A,E
	  ORA	A
	  JZ	DIAL8
;
DIAL7:	  MOV	A,M
	  ORA	A
	  JZ	DIALBAD
	  DAD	B
	  DCR	E
	  JNZ	DIAL7
;
;
; Now have the line in the phone number library matching the requested
; letter so store that line starting at 'CMDBUF+1'
;
DIAL8:	  MVI	B,LIBLEN
	  LXI	D,CMDBUF+1
	  XCHG
	  MOV	M,B
	  XCHG
	  INX	D
	  CALL	MOVE
;
;
; Now have the full line including phone number in 'CMDBUF' area.
;
DIAL9:	  LDA	SMARTMODEM	;comes here if CAL (number)
	  ORA	A
	  CNZ	SMINIT		;turns DTR back on
;	
DIAL10:	  LXI	H,CMDBUF+1
	  MOV	E,M
	  INX	H
;
DIAL11:	  MOV	A,M
	  ORA	A
	  JZ	DIALBAD
;
;
; Dial a digit, check keyboard for abort
;
	  CALL	DIALA
	  CALL	STAT
	  JZ	DIAL13
	  CALL	KEYIN
	  CPI	CANCEL
	  JNZ	DIAL13
	  JMP	DIALEXIT
;
DIAL13:	  INX	H
	  DCR	E
	  JNZ	DIAL11
;
;
; Show the number of dial attempts
;
	  MVI	B,CR		;end with cr to start dialing
	  CALL	TIMER5		;preset delay (CEH)
	  CALL	SENDCHR
	  MVI	B,30		;wait 3 sec for SmartCat to echo number
	  CALL	TIMER		;...and gobble whatever
;
EATIT:	  CALL	JMP$INMODEM	;gobble anything else that remains
	  JNC	EATIT
;
	  CALL	ILPRT
	  DB	' - try #',0
	  LHLD	DIALCT
	  INX	H
	  SHLD	DIALCT
	  CALL	DECOUT
	  MVI	A,' '
	  CALL	TYPE
;
DIAL14:   CALL	JMP$INMODEM	;gobble some more if there
	  JNC	DIAL14
	  JMP	SMRESULT
;
DIALAGN:  LDA	CRFLAG
	  ORA	A
	  JNZ	DIALAGN1
	  CALL	ILPRT
	  DB	' Redial? '
	  DB	'(Y/N/C): ',BELL,0
	  CALL	KBDCHR
	  CALL	CRLF
	  CPI	'N'
	  JZ	DIALAGN2
	  CPI	'Y'
	  JZ	DIALAGN1
	  CPI	'C'
	  JNZ	DIALAGN
	  MVI	A,1
	  STA	CRFLAG
;
DIALAGN1: MVI	B,35
	  CALL	TIMER
	  CALL	CRLF
	  LDA	RINGBKFL
	  ORA	A
	  JZ	DIAL4
	  STA	CMDBUF+1
	  JMP	DIAL4
;.....
;
;
DIALAGN2: CALL	DIALBGN		;disconnect the modem
	  JMP	MENU
;
;
; Connection has been made
;
CONMADE:  CALL	ILPRT
	  DB	CR,LF,LF,'CONNECTION MADE',BELL,0
	  LDA	CRFLAG
	  ORA	A
	  JZ	RETURN
	  CALL	ILPRT
	  DB	' - hit any key to stop the bell ',0
;
CONMADE1: CALL	STAT
	  JZ	CONMADE2
	  CALL	KEYIN
	  XRA	A
	  JMP	RETURN
;
CONMADE2: MVI	B,10
	  CALL	TIMER
	  MVI	A,BELL
	  CALL	TYPE
	  JMP	CONMADE1
;.....
;
;
; Automatic dialing routine, prints the number being dialed
;
DIALA:	  CALL	TYPE		;comes here with character in A
	  CPI	'R'
	  JNZ	DIALA1
	  PUSH	PSW
	  MOV	A,E
	  CPI	1		;was 'R' last character?
	  JZ	RINGBK
	  POP	PSW
;
DIALA1:	  MOV	B,A
	  CALL	DIALAD
	  MOV	A,B
	  CPI	'*'		;* is valid dial digit, must not be in name
	  JZ	DIALA2
	  CPI	'#'		;# is valid dial digit, must not be in name
	  JZ	DIALA2
	  CPI	'I'		;I indicates pulse dialing is requested.
	  JZ	DIALA2		;all I's, P's, and W's
	  CPI	'P'		;in the library names MUST be lower case.
	  JZ	DIALA2
	  CPI	'W'
	  JZ	DIALA2
	  CPI	'0'
	  RC
	  CPI	'9'+1
	  RNC
;
;
; Must be a number.  Send it to the modem
;
DIALA2:
	  MOV	C,A
	  CALL	TIMER5		;preset delay (CEH)
	  JMP	SENDCHR 	;In main program. RETs to caller
;
;
; Print bad library number message and abort if a null is encountered.
;
DIALBAD:  CALL	ILPRT
	  DB	CR,LF,'++ Bad library number called ++',CR,LF,0
;
DIALEXIT: CALL	DISCONNT
;
DIALEXT1: CALL	CRLF
	  XRA	A
	  STA	CRFLAG
;
DIALEXT2: CALL	JMP$INMODEM
	  JNC	DIALEXT2
	  CALL	JMP$GOODBYE
	  JMP	MENU
;.....
;
;
DIALBGN:  JMP	DISCONNT
;
;
; Do any alternate dialing such as 'MCI' or 'SPRINT'
;
DIALAD:	  MOV	A,B
	  CPI	'<'
	  JNZ	DIALAD1
	  PUSH	H
	  LXI	H,ALTDIAL1
	  JMP	DIALAD2
;
DIALAD1:  CPI	'>'
	  RNZ
	  PUSH	H
	  LXI	H,ALTDIAL2
;
DIALAD2:  MOV	A,M
	  CPI	'$'
	  JZ	DIALAD3
	  CALL	TYPE
	  MOV	B,A
	  CALL	TIMER5		;preset delay (CEH)
	  CALL	SENDCHR 	;In main program
	  INX	H
	  CALL	STAT
	  JZ	DIALAD2
	  CALL	KEYIN
	  CPI	CANCEL
	  JZ	DIALEXIT
	  JMP	DIALAD2
;
DIALAD3:  MVI	A,' '
	  CALL	TYPE
	  POP	H
	  RET
;.....
;
;
; Provide a preset delay between command characters to the modem (CEH)
; (See header for usege)
;
TIMER5:
	  PUSH	H	;Save all registers
	  PUSH	D
	  PUSH	B
	  PUSH	PSW
	  MVI	A,TDELAY	;Get selected delay value
	  ANA	A		;Zero?
	  JZ	TIMER5A 	;If so - no delay
	  MOV	B,A		;Number of 100 mS intervals
	  CALL	TIMER
TIMER5A:  POP	PSW	;Restore registers
	  POP	B
	  POP	D
	  POP	H
	  RET
;.....
;
;
; Disconnect the Smartmodem from the phone line
;
GOODBYE:
DISCONNT: CALL	SETDTRH 	;in case it wasn't
;(disbled)LXI	H,DISC0 	;send the hangup command
;(disbled)CALL	SENDMDM
;
	  CALL	TIMER5		;delay some and
DISCONN2: CALL	JMP$INMODEM	;gobble any return garbage
	  JNC	DISCONN2
	  CALL	SETDTRL 	;now drop the DTR
	  MVI	B,35		;and give modem time to
	  CALL	TIMER		;reinitialize
	  RET
;.....
;
;
DISC0:	  DB	'%H',CR,'$'	;not called if disabled above but is
;.....				;used by the HANGUP routine.
;
;
; Set Smartmodem for dialing
;
SMINIT:	  CALL	SETDTRH		;enable dtr
	  LXI	H,SM$DAL1	;put out the dial command
	  CALL	SENDMDM
	  RET
;
SMINIT1:  RET
;.....
;
;
SM$DAL1:  DB	'%D ','$'	  ;send the <CM>, DIAL command, and SPACE
;
;
; Send the string pointed to by 'HL' to both the CRT and the modem.
;
SENDOUT:  PUSH	H
	  CALL	SENDNOW
	  POP	H
	  MOV	A,M
	  CPI	'$'
	  RZ
	  MOV	A,M
	  CALL	TIMER5		;preset delay between string char (CEH)
	  CALL	OUT$MODDATP	;Call to main program
	  CALL	TYPE
	  INX	H
	  JMP	SENDOUT
;.....	
;
;
; Send the string pointed to by 'HL' to the modem only
;
SENDMDM:  PUSH	H
	  CALL	SENDNOW
	  POP	H
	  MOV	A,M
	  CPI	'$'
	  RZ
	  CALL	TIMER5		;preset delay between string char (CEH)
	  CALL	OUT$MODDATP	;Call to main program
	  INX	H
	  JMP	SENDMDM
;......
;
;
; Checks for answer from Smartmodem
;
SMRESULT: LXI	H,RESULBUF
	  PUSH	H
;
SMRESUL2: CALL	RCVREADY	;loop here 'till something happens
	  JZ	SMRESUL1
	  CALL	STAT
	  JZ	SMRESUL2
	  CALL	KEYIN
	  CPI	CANCEL
	  JNZ	SMRESUL2
	  MVI	B,CR
	  CALL	TIMER5		;preset delay (CEH)
	  CALL	SENDCHR 	;Call to main program
	  POP	H
	  JMP	DIALEXT1
;
RESULBUF: DS	16
;
SMRESUL1: CALL	JMP$INMODEM
	  JC	SMRESUL4	;no more characters coming
;
SMRESUL6: ANI	7FH
	  CPI	' '
	  JZ	SMRESUL1	;throw away spaces, lf, cr, nuls
	  CPI	LF		;bell, %, and * in the resulbuf
	  JZ	SMRESUL1
	  CPI	00H
	  JZ	SMRESUL1
	  CPI	'*'
	  JZ	SMRESUL1
	  CPI	CR
	  JZ	SMRESUL1
	  CPI	BELL
	  JZ	SMRESUL1
	  CPI	'%'
	  JZ	SMRESUL1
	  POP	H
	  MOV	M,A
	  INX	H
	  PUSH	H
	  JMP	SMRESUL1	;get next char for RESULBUF
;
;
; Compare the SmartCat response
;
SMRESUL4: POP	H
	  LXI	D,RESULBUF
	  CALL	INLNCOMP
	  DB	'OK',0			;should never happen in dialing
	  JNC	DISCONNT		;....routine
	  CALL	INLNCOMP
	  DB	'BUSY',0		;busy response
	  JNC	NUM$BUSY
	  CALL	INLNCOMP
	  DB	'NO AN',0		;no answer
	  JNC	FAILCAL
	  CALL	INLNCOMP
	  DB	'NO DI',0		;no dialtone
	  JNC	NO$DT
	  CALL	INLNCOMP
	  DB	'RI',0			 ;ringing...
	  JNC	RING
	  CALL	INLNCOMP
	  DB	'CONNECT',0		;connection made...
	  JNC	CONMADE
	  CALL	INLNCOMP
	  DB	'CONN L',0		;connection lost...
	  JNC	CARLOST
;
SMDM1:	  JMP	FAILCAL
;.....
;
;
; Carrier lost is a result of the remote end hanging up or a failure
; in the telephone circuit.  This is reported by the SmartCat.
;
CARLOST:  CALL	CRLF
	  CALL	ILPRT
	  DB	'Connection lost....',0
	  JMP	DISCONNT
;.....
;
;
; Failed call is the result of no answer after 60 sec of ringing, wrong
; baud rate, or an incorrect response from the modem.
;
FAILCAL:  CALL	CRLF
	  CALL	ILPRT
	  DB	'No answer... Failed call....',0
	  JMP	DIALAGN
;
;
; No dial tone can occur when using the alternate dialing option and a
; dial tone is not detected after the pause 'P' or within 5 sec after
; the start of the modem dialing routine
;
NO$DT:	  CALL	CRLF
	  CALL	ILPRT
	  DB	'No dial tone present....',0
	  JMP	DIALAGN
;
NUM$BUSY: CALL	CRLF
	  CALL	ILPRT
	  DB	'Number busy....',0
	  JMP	DIALAGN
;
RING:	  CALL	CRLF
	  CALL	ILPRT
	  DB	'Ringing....',0
	  LDA	RINGFLG
	  ORA	A
	  JZ	SMRESULT
	  JMP	RINGBK1
;
;
; Handles the special ringback numbers.  Dials, lets it ring only once,
; hangs up and then redials.
;
RINGFLG:  DB	0
;
RINGBK:	  POP	PSW
	  LDA	CMDBUF+1
	  STA	RINGBKFL
	  STA	RINGFLG
	  SUI	1
	  STA	CMDBUF+1
	  RET
;.....
;
;
; Hang up and redial
;
RINGBK1:  CALL	CRLF
	  CALL	ILPRT
	  DB	'Ringback active - hanging up on first ring....',0
	  CALL	HANGUP
	  MVI	B,50
	  CALL	TIMER
	  CALL	CRLF
	  JMP	DIAL9
;.....
;
;
HANGUP:   MVI	B,CR		;abort the dialing process
	  CALL	SENDCHR
	  CALL	TIMER5		;delay some
	  LXI	H,DISC0 	;send the hangup command
	  CALL	SENDMDM
	  XRA	A
	  STA	RINGFLG		;clear flag for next dial
	  CALL	TIMER5		;wait some
;
HANGUP1:  CALL	JMP$INMODEM	;wait for the modem to complete its
	  JNC	HANGUP1 	;response to the abort
	  JMP	DISCONNT	;return here
;.....
;
;
; Time-out routine.  Must be called with mask in 'D' reg. for input at
; relative port 2 and number of seconds (times 10) in 'C' reg.
;
WAIT:	  MVI	B,2
	  CALL	TIMER
	  CALL	IN$MODCTL1
	  ANA	D
	  RZ
	  PUSH	B
	  PUSH	D
	  CALL	STAT
	  JZ	WAIT1
	  CALL	KEYIN
	  CPI	CANCEL
	  JZ	WAIT2
;
WAIT1:	  POP	D
	  POP	B
	  DCR	C
	  JNZ	WAIT
	  STC
	  RET
;.....
;
;
WAIT2:	  POP	D
	  POP	B
	  JMP	DONETCD
;.....
;
;
; Patch for SETUPENT: to prevent sending of Hayes commands to SmartCat
;
;
	  ORG	404BH
;
;
SETUPENT: LDA	SETUPTST
	  ORA	A
	  JZ	NOTVLD
	  CALL	JMP$SETUPR
	  JMP	XPRT
;
NOTVLD:	  EQU	39A3H
;
;
; Lets fix the byebye routine it calls GOODBYE: directly  and not
; through the jump vectors at the begining
;
;
	  ORG	39C6H
;
;
BYEBYE:	  LDA	PMMIMODEM
	  ORA	A
	  CNZ	JMP$GOODBYE
	  LDA	SMARTMODEM
	  ORA	A
	  CNZ	JMP$GOODBYE
	  CALL	ILPRT
	  DB	CR,LF,'<<Exit to CP/M>>',CR,LF,0
	  JMP	EXIT
;.....
;
;
; Fix for ILPRT: when exits routine the stack dose not contain the cor-
; rect location of the next instruction.  Shouldn't make any difference
; as points to NOP, but?
;
;
	  ORG	262EH
;
;
ILPRT:	  XTHL
;
ILPRT1:	  MOV	A,M
	  INX	H
	  ORA	A
	  JZ	ILPRT2
	  CALL	CTYPE
	  JMP	ILPRT1
;
CTYPE:	  EQU	257BH
ILPRT2	  EQU	263BH
;
;
; Fix for DONETCD: the routines GOODBYE: and DISCONNT: are the same so
; no need to call twice.
;
;
	  ORG	2511H
;
;
DONETCD:  CALL	ILPRT
	  DB	CR,LF,'<< DISCONNECTED >>',BELL,CR,LF,0
	  CALL	JMP$GOODBYE
	  JMP	MENU0
;
MENU0:	  EQU	2CB6H
;
;
; M712RACL.ASM uses these routines located in the main program
;
TIMER:	  EQU	0B80H		;timer routine
INLNCOMP: EQU	2A2BH		;compare routine
ILPRT:	  EQU	262EH		;print string routine
CRLF:	  EQU	2588H		;print crlf
CMDBUF:	  EQU	42F8H		;cmd buffer
RINGBKFL: EQU	42F4H		;ring back flag
KEYIN:	  EQU	25A0H		;kbd input
STAT:	  EQU	2595H		;console status
SENDCHR:  EQU	26B7H		;send character
RCVREADY: EQU	188DH		;reciever ready
INMODEM:  EQU	1AD2H		;in modem
KBDCHR:	  EQU	25C1H		;wait for keyboard input
CRFLAG:	  EQU	42E5H		;cr flag
ALTDIAL1: EQU	0BD0H		;alt dial 1
ALTDIAL2: EQU	0BE8H		;alt dial 2
TYPE:	  EQU	25B4H		;type
MENU:	  EQU	2CFDH		;menu
NUMBLIB:  EQU	0C00H		;number library
BUFFER:	  EQU	4700H
CLRTST:	  EQU	41B7H		;clear screen test
MOVER:	  EQU	2AFAH		;move routine
MOVE:	  EQU	26AEH
SPACES:	  EQU	415DH
INBUF:	  EQU	2951H
DECOUT:	  EQU	25D4H
INBUF:	  EQU	2951H
NXTSCRN:  EQU	4187H
RETURN:	  EQU	14CAH
SENDNOW:  EQU	189FH
DONETCD:  EQU	2511H
DIALCT:	  EQU	42DAH
NEWLINE:  EQU	4154H
START:	  EQU	0F75H		;start
EXIT:	  EQU	2671H
XPRT:	  EQU	382FH
;
	  END
 