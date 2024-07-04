; NOTE:  This overlay is VERY dependent on version of the MDM7xx
;	that it is running with.  As of 5 Mar 84, it is configured
;	for MDM727.OBJ as distributed.  Be careful if configuring
;	for different versions of MDM7xx.
;	You should be able to configure it for your system just
;	by modifying the two routines SETDTRH and SETDTRL.  They
;	are USART-specific.  Then just overlay this file AFTER
;	overlaying your normal configure file.  Make sure that
;	your normal configure file doesn't go past 3FFH since this
;	one starts at 400H.
;
; M727RV.ASM  Racal-Vadic VA212PA overlay for MDM727
;
; The Racal-Vadic VA212PA modem is configured as follows
;
;	    1*2  STANDART OPTN	 2*1  ASYNCH/SYNCH
;	    3*2  DATA RATE SEL	 4*1  103 OPERATION
;	    5*3  CHARACTER LEN	 6*1  ORIG/ANS MODE
;	    7*2  SLAVE CLOCK	 8*2  DTR CONTROL
;	    9*2  ATT/UNATT DISC  10*1 LOSS CXR DISC
;	    11*2 REC SPACE DISC  12*2 SEND SPACE DIS
;	    13*1 ABORT DISC	 14*1 REMOT TST RESP
;	    15*4 DSR CONTROL	 16*2 CXR CONTROL
;	    17*1 AUTO LINKING	 18*3 ALB CONTROL
;	    19*6 AUTO ANSWER	 20*1 TERMINAL BELL
;	    21*1 LOCAL COPY	 22*3 DIAL MODE
;	    23*2 BLIND DIAL	 24*1 CALL PROGRESS
;	    25*2 FAIL CALL SEL	 26*9 AUTO REDIAL
;
; #, K, and * may be used in the phone number command line,
; CAL #8K9Kxxx-xxx-xxxx (up to 31 digits).
;
; Initialization routines need to be changed to support your I/O devices
; are: SETDTRH and SETDTRL - Examples for USART
; initialization may be found in BYE2-16.LBR.  The modem is disconnected
; from on-line by dropping the DTR line, this must be implemented in the
; SETDTRL: routine in accordance with your I/O devices.  The modem is
; enabled by setting DTR high and must be implemented in your SETDTRH:
; routine.
;
;	To install the overlay make your changes for the USART
;	dependent routines.  This overlay may directly be used
;	if your system uses the Intel 8251 USART.
;
;	A>DDT MDM727.COM	<== Start with MDM727.COM (or .OBJ)
;	DDT VERS 2.2
;	NEXT   PC
;	4A00  0100
;	-IM7xx-1.HEX
;	-R			<== Read in your normal MDM7xx overlay
;	-IM727RV.HEX
;	-R			<== Read in this to add PA212 support
;	NEXT   PC
;	4A00  0000
;	-G0
;
;	A>SAVE 73 MDM727.COM
;
; K, # and * are valid characters for the Racal (#8K9Kxxx-xxxx) and may
; be included in the phone number.  #8 is used by some PBX systems to
; have a clear phone line with no call waiting signals. INSURE ALL NAMES
; IN THE PHONE NUMBER LIBRARY HAVE LOWER CASE "k" and phone numbers upper
; case "K" if needed.
;
;***********************************************************************
;
; 3/5/84   - Adjusted equates for mdm727
; 2/18/84  - Adjusted equates for MDM724
; 2/16/84  - Adjusted equates for MDM723 and modified DIAL routine so
;		it can handle the new 36 number phone number library.
; 1/5/84   - Set up equates at end for MDM716 and removed all hardware-
;		specific routines (except SETDTRH and SETDTRL) so that
;		this file can be used with most other systems assuming
;		there is an overlay for those systems already.
; 11/11/83 - Renamed to M7RV-1.ASM, no changes	- Irv Hoff
; 10/15/83 - First version for Racal-Vadic	- Fred Willink
;
;***********************************************************************
;
YES:		EQU	0FFH
NO:		EQU	0
;
CANCEL:		EQU	'X'-40H	;^X = Cancel
ESC:		EQU	'['-40H	;^[ = escape
BELL:		EQU	'G'-40H	;^G = bell character
LF:		EQU	'J'-40H	;^J = linefeed
CR:		EQU	'M'-40H	;^M = carriage return
PRINT:		EQU	9
BDOS:		EQU	0005H
;
LIBLEN:		EQU	34	; Length of each phone number
;
;=======================================================================
;
		ORG	0100H
;
;
		DS	3	; Skip JMP START
;
PMMIMODEM:	DB	NO
SMARTMODEM:	DB	YES	; yes=Racal-Vadic VA122PA the main
				; program test this byte to use the
				; new routines
		DS	1
CLOCK:		DS	1	;clock speed x10, up to 25.5 mhz.
				;2 MHz=20, 3.68 MH=37, 4 MHz=40, etc.
MSPEED:		DS	1	;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
		DS	3
SETUPTST:	DS	1	;yes=non-PMMI setup routine
SCRNTEST:	DS	1	;yes=home cursor and clear screen
		DS	29
;
;
; Handles in/out ports for data and status
;
IN$MODCTL1:	DS	10		;in modem control port
OUT$MODDATP:	DS	10		;out modem data port
IN$MODDATP:	DS	10		;in modem data port
ANI$MODRCVB:	DS	3		;bit to test for receive ready
CPI$MODRCVR:	DS	3		;value of receive bit when ready
ANI$MODSNDB:	DS	3		;bit to test for send ready
CPI$MODSNDR:	DS	3		;value of send bit when ready
;
IN$BAUDRP:	DS	3		 ;in baudrate port
OUT$BAUDRP:	DS	3		 ;out baudrate port
OUT$MODCTL1:	DS	3		 ;out modem control port #1
OUT$MODCTL2:	DS	3		 ;out modem control port #2
;
LOGONPTR:	DS	2
JMP$DIAL:	JMP	DIAL		; \
JMP$DISCONNT:	JMP	DISCONNT	;  > We change these vectors
JMP$GOODBYE:	JMP	GOODBYE		; /
JMP$INITMOD:	DS	3
JMP$NEWBAUD:	RET			; Defeat this one...
		DS	2
JMP$NOPARITY:	RET			;  ...and this one...
		DS	2
JMP$PARITY:	RET			;  ...and this one...
		DS	2
JMP$SETUPR:	DS	3
JMP$SPCLMENU:	RET			;  ...and this one.
		DS	2
JMP$SYSVER:	DS	3
JMP$BREAK:	DS	3
;
JMP$ILPRT:	DS	3
JMP$INBUF:	DS	3
JMP$INLNCOMP:	DS	3
JMP$INMODEM:	DS	3
JMP$NXTSCRN:	DS	3
JMP$TIMER:	DS	3
;
;.....

; After all the absolute locations above will generally be the user's
;  hardware-specific subroutines.  We allow up to 3FFH for those and
;  then start some routines of our own that support the Racal-Vadic PA212
;  modem.  If the user's routines need more room, this might be able to
;  start a little lower, but just a few bytes probably.

	ORG	400H
;
; NOTE: You will have to change these next two routines if you don't
;	have an 8251A for your USART.
;
ENABL	EQU	37H
DTR	EQU	2
;
; Raise DTR to enable modem
;
SETDTRH:  MVI	A,enabl
	  JMP	OUT$MODCTL1
;.....
;
;
; Drop DTR to disable modem
;
SETDTRL:  MVI	A,enabl-dtr
	  JMP	OUT$MODCTL1
	  RET
;.....
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
DIAL:	  XRA	A		; Zero out some flags
	  STA	CRFLAG
	  STA	RINGBKFL
	  STA	RINGFLG
	  STA	DOT		; Indicates dot encountered in library
	  LXI	H,0
	  SHLD	DIALCT
	  LXI	H,CMDBUF+1	; Point to character count of user
	  MOV	A,M		;  input to prompt
	  CPI	3+1		; More than 3 letters input ?
	  JC	DIAL1		; No, then go display library of #'s
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
	  SUI	4		; Adjust count down by 4
	  MOV	M,A		; Store back in CMDBUF+1
	  INX	H		; Point to CMDBUF+2
	  XCHG
	  LXI	H,CMDBUF+6
	  CALL	MOVER		; Move buffer down by 4
	  JMP	DIAL4
;...
;
;
; Comes here if no phone number was manually entered after "CAL" and if
; no phone library letter was entered.	Displays the phone number li-
; brary, then asks for an entry.
;
DIAL1:	  MVI	C,18		; Lines of phone numbers to display
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
	  CALL	JMP$ILPRT
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
	  MOV	A,M		; Get character count
	  ORA	A		; No entry ?
	  JZ	DIALEXIT	;  then exit
	  PUSH	H
	  CALL	DISCONNT	;disconnect the modem and place in idle
	  POP	H
	  MOV	A,M		; Get count again
	  CPI	1		; One character (ie. get phone number
	  JZ	DIAL4A		;  from library) ?
	  MVI	A,YES		; Set dot flag so that we don't skip
	  STA	DOT		;  anything user types in
	  JMP	DIAL9
DIAL4A:
	  INX	H		; Point to user entry
	  MVI	B,'A'		; Need to compare against A-Z
	  MVI	E,0
	  MVI	C,'Z'-'A'+1	; How many to check
	  MOV	A,M		; Get user input character
;
DIAL5:	  CMP	B		; Compare against letter (A-Z)
	  JZ	DIAL6		; Got match
	  INR	B		; Next letter
	  INR	E		; Keep count
	  DCR	C
	  JNZ	DIAL5		; Loop for all letters
; Checked all letters, now do numbers 0-9
	  MVI	B,'0'		; Start at 0
	  MVI	C,'9'-'0'+1	; How many to check
DIAL5A:
	  CMP	B		; Compare against number
	  JZ	DIAL6		; Got match
	  INR	B		; Next number
	  INR	E		; Keep counter
	  DCR	C
	  JNZ	DIAL5A		; Loop for all numbers (0-9)
	  JMP	DIAL9		; This should only happen with illegal
				;  entries.
;
;
; Now have a match between the requested letter and one in the library
; E-reg. holds the decimal equivalent (0-25) of the letter (A-Z) or
; (26-35) of the number (0-9).
;
DIAL6:	  LXI	H,NUMBLIB	; Starting address of library
	  LXI	B,LIBLEN	; Length of each entry of library
	  MOV	A,E
	  ORA	A
	  JZ	DIAL8
;
DIAL7:	  MOV	A,M
	  ORA	A		; Make sure we don't go past library
	  JZ	DIALBAD		; Jump if we do
	  DAD	B		; Index into library by (E)*LIBLEN
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
DIAL9:	  LDA	SMARTMODEM
	  ORA	A
	  CNZ	SMINIT
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
	  MVI	B,CR		;end with cr
	  CALL	SENDCHR
;
EATIT:	  CALL	JMP$INMODEM	;gobble the modem response
	  JNC	EATIT
	  CALL	JMP$ILPRT
	  DB	' - try #',0
	  LHLD	DIALCT
	  INX	H
	  SHLD	DIALCT
	  CALL	DECOUT
	  MVI	A,' '
	  CALL	TYPE
	  MVI	B,CR
	  CALL	SENDCHR
;
DIAL14:	  CALL	JMP$INMODEM
	  JNC	DIAL14
	  JMP	SMRESULT
;
DIALAGN:  LDA	CRFLAG
	  ORA	A
	  JNZ	DIALAGN1
	  CALL	JMP$ILPRT
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
	  CALL	JMP$TIMER
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
CONMADE:  CALL	JMP$ILPRT
	  DB	CR,LF,LF,'CONNECTION MADE',BELL,0
	  LDA	CRFLAG
	  ORA	A
	  JZ	RETURN
	  CALL	JMP$ILPRT
	  DB	' - hit any key to stop the bell ',0
;
CONMADE1: CALL	STAT
	  JZ	CONMADE2
	  CALL	KEYIN
	  XRA	A
	  JMP	RETURN
;
CONMADE2: MVI	B,10
	  CALL	JMP$TIMER
	  MVI	A,BELL
	  CALL	TYPE
	  JMP	CONMADE1
;.....
;
;
; Automatic dialing routine, prints the number being dialed
;
DIALA:	  CALL	TYPE
	  CPI	'R'
	  JNZ	DIALA1
	  PUSH	PSW
	  MOV	A,E
	  CPI	1
	  JZ	RINGBK
	  POP	PSW
;
DIALA1:	  MOV	B,A
	  CALL	DIALAD
	  CPI	'.'		; Are we at a dot in the string ?
	  JNZ	DIALA1A		; Jump around if no
	  MVI	A,YES
	  STA	DOT		; Set flag if yes
DIALA1A:
	  LDA	DOT		; Have we encountered a dot yet ?
	  ORA	A
	  RZ			; Return if no
	  MOV	A,B
	  CPI	'*'		;* is valid dial digit
	  JZ	DIALA2
	  CPI	'#'		;# is valid dial digit
	  JZ	DIALA2
	  CPI	'K'		;k indicates wait for next dial tone
	  JZ	DIALA2		;all k's in phone # library should be
	  CPI	'0'		;lower case.
	  RC
	  CPI	'9'+1
	  RNC
;
;
; Sends the digit to the modem.
;
DIALA2:	  MOV	C,A
	  JMP	SENDCHR
;
;
; Print bad library number message and abort if a null is encountered.
;
DIALBAD:  CALL	JMP$ILPRT
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
	  CALL	SENDCHR
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
; Disconnect the Smartmodem from the phone line
;
GOODBYE:
DISCONNT: CALL	SETDTRL		;drop dtr
	  LXI	H,DISC0		;send the idle command just in case
	  CALL	SENDMDM		;the modem was in command mode instead
				;of on line
DISCONN2: CALL	JMP$INMODEM	;gobble the idle message from the
	  JNC	DISCONN2	;modem after the 'I' command is
	  MVI	B,10		;sent and give it time to
	  CALL	JMP$TIMER	;reinitialize
	  CALL  SETDTRH		; Set DTR active again
	  RET
;.....
;
;
DISC0:	  DB	'I',CR,'$'
DOT:	  DS	1		; Flag for don encountered
;.....
;
;
; Set Smartmodem for dialing
;
SMINIT:	  CALL	SETDTRH		;enable dtr
	  LXI	H,SM$DAL1	;put racal in command mode
	  CALL	SENDMDM
	  JMP	SMRESULT	;get results (hello:i'M READY)
;
SMINIT0:  MVI	B,10
	  CALL	JMP$TIMER
	  LXI	H,SM$DAL2	;put racal in dial mode
	  CALL	SENDMDM
	  CALL	JMP$INMODEM	;gobble the modem echo smresult 
				;will take care of the the rest
	  JMP	SMRESULT	;number?
;
SMINIT1:  RET
;.....
;
;
SM$DAL1:  DB	'E'-40H,CR,'$'	;get into command mode
;
SM$DAL2:  DB	'D',CR,'$'	;dial
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
	  CALL	OUT$MODDATP
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
	  CALL	OUT$MODDATP
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
SMRESUL2: CALL	RCVREADY
	  JZ	SMRESUL1
	  CALL	STAT
	  JZ	SMRESUL2
	  CALL	KEYIN
	  CPI	CANCEL
	  JNZ	SMRESUL2
	  MVI	B,CR
	  CALL	SENDCHR
	  POP	H
	  JMP	DIALEXT1
;
RESULBUF: DS	16
;
SMRESUL1: CALL	JMP$INMODEM
	  JC	SMRESUL4
;
SMRESUL6: ANI	7FH
	  CPI	' '
	  JZ	SMRESUL1	;throw away spaces, lf, cr, nuls
	  CPI	LF		;bell, and * in the resulbuf
	  JZ	SMRESUL1
	  CPI	00H
	  JZ	SMRESUL1
	  CPI	'*'
	  JZ	SMRESUL1
	  CPI	CR
	  JZ	SMRESUL1
	  CPI	BELL
	  JZ	SMRESUL1
	  POP	H
	  MOV	M,A
	  INX	H
	  PUSH	H
	  JMP	SMRESUL2
;
;
; Compare the Racal response
;
SMRESUL4: POP	H
	  LXI	D,RESULBUF
	  CALL	INLNCOMP
	  DB	'HE',0			;hello:i'M READY
	  JNC	SMINIT0
	  CALL	INLNCOMP
	  DB	'NU',0			;number?
	  JNC	SMINIT1
	  CALL	INLNCOMP
	  DB	'BU',0			;busy
	  JNC	NUM$BUSY
	  CALL	INLNCOMP
	  DB	'DI',0			;dialing...
	  JNC	SMRESULT
	  CALL	INLNCOMP
	  DB	'RI',0			;ringing...
	  JNC	RING
	  CALL	INLNCOMP
	  DB	'AN',0			;answer tone
	  JNC	SMRESULT
	  CALL	INLNCOMP
	  DB	'ON',0			;on line
	  JNC	CONMADE
	  CALL	INLNCOMP
	  DB	'NO',0			;no dial tone
	  JNC	NO$DT
	  CALL	INLNCOMP
	  DB	'FA',0			;failed call
	  JNC	FAILCAL
	  CALL	INLNCOMP
	  DB	'VO',0			;voice
	  JNC	VOICE
	  CALL	INLNCOMP
	  DB	'ID',0			;idle
	  JNC	FAILCAL
;
SMDM1:	  JMP	FAILCAL
;.....
;
;
VOICE:	  CALL	CRLF
	  CALL	JMP$ILPRT
	  DB	'VOICE !!! pick up reciever and enter return ',BELL,0
	  CALL	KBDCHR
	  CPI	CR
	  JNZ	VOICE
	  CALL	SENDCHR
;
VOICE1:	  CALL	JMP$INMODEM	;gobble modem response
	  JNC	VOICE1
	  CALL	DISCONNT
	  JMP	MENU
;
;
; Failed call is the result of no answer after 60 sec of ringing, wrong
; baud rate, or an incorrect response from the modem.
;
FAILCAL:  CALL	CRLF
	  CALL	JMP$ILPRT
	  DB	'No answer... Failed call....',0
	  JMP	DIALAGN
;
;
; No dial tone can occur when using the alternate dialing option and a
; dial tone is not detected after the pause 'K' or within 5 sec after 
; the start of the modem dialing routine
;
NO$DT:	  CALL	CRLF
	  CALL	JMP$ILPRT
	  DB	'No dial tone present....',0
	  JMP	DIALAGN
;
NUM$BUSY: CALL	CRLF
	  CALL	JMP$ILPRT
	  DB	'Number busy....',0
	  JMP	DIALAGN
;
RING:	  LDA	RINGFLG
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
RINGBK1:  CALL	HANGUP
	  MVI	B,50
	  CALL	JMP$TIMER
	  CALL	CRLF
	  JMP	DIAL9
;.....
;
;
HANGUP:   MVI	B,CR		;abort the dialing process
	  CALL	SENDCHR
	  XRA	A
	  STA	RINGFLG		;clear flag for next dial
;
HANGUP1:  CALL	JMP$INMODEM	;wait for the modem to complete its
	  JNC	HANGUP1		;response to the cr
	  JMP	DISCONNT	;return here
;.....
;
;
; Time-out routine.  Must be called with mask in 'D' reg. for input at
; relative port 2 and number of seconds (times 10) in 'C' reg.
;
WAIT:	  MVI	B,2
	  CALL	JMP$TIMER
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
; Patch for SETUPENT: to prevent sending of Hayes commands to Racal
;
;
	  ORG	SETUPENT
;
;
	  LDA	SETUPTST
	  ORA	A
	  JZ	NOTVLD
	  CALL	JMP$SETUPR
	  JMP	XPRT
;
;
;
; Lets fix the byebye routine. It calls GOODBYE: directly  and not
; through the jump vectors at the begining so make it use the jump
; vectors.
;
;
	  ORG	BYEBYE
;
;
	  LDA	PMMIMODEM
	  ORA	A
	  CNZ	JMP$GOODBYE
	  LDA	SMARTMODEM
	  ORA	A
	  CNZ	JMP$GOODBYE
	  CALL	JMP$ILPRT
	  DB	CR,LF,'<<Exit to CP/M>>',CR,LF,0
	  JMP	EXIT
;.....
;
;
; Fix for DONETCD: the routines GOODBYE: and DISCONNT: are the same so
; no need to call twice.
;
;
	  ORG	DONETCD
;
;
	  CALL	JMP$ILPRT
	  DB	CR,LF,'<< DISCONNECTED >>',BELL,CR,LF,0
	  CALL	JMP$GOODBYE
	  JMP	MENU0
;
;
;
; M727RV.ASM uses these routines located in the main program.
;  These equates have to be set for particular releases of MDM7xx.
;  Currently they are set for MDM727.
;
ALTDIAL1: EQU	0DCEH		;alt dial 1
ALTDIAL2: EQU	0DE6H		;alt dial 2
BUFFER:	  EQU	4E00H
BYEBYE:	  EQU	402EH
CLRTST:	  EQU	484FH		;clear screen test
CMDBUF:	  EQU	4992H		;cmd buffer
CRFLAG:	  EQU	497DH		;cr flag
CRLF:	  EQU	2B4FH		;print crlf
DECOUT:	  EQU	2B91H
DIALCT:	  EQU	4972H
DONETCD:  EQU	2AD8H
EXIT:	  EQU	2C2EH
INBUF:	  EQU	2F12H
INLNCOMP: EQU	2FE9H		;compare routine
KBDCHR:	  EQU	2B7EH		;wait for keyboard input
KEYIN:	  EQU	2B67H		;kbd input
MENU:	  EQU	32C6H		;menu
MENU0:	  EQU	327FH
MOVE:	  EQU	2C6FH
MOVER:	  EQU	30B8H		;move routine
NEWLINE:  EQU	4801H
NOTVLD:	  EQU	3F59H
NUMBLIB:  EQU	0E00H		;number library
RCVREADY: EQU	1E28H		;receiver ready
RETURN:	  EQU	196EH
RINGBKFL: EQU	498DH		;ring back flag
SENDCHR:  EQU	2C78H		;send character
SENDNOW:  EQU	1E3AH
SETUPENT: EQU	46DEH
SPACES:	  EQU	480AH
STAT:	  EQU	2B5CH		;console status
TYPE:	  EQU	2B71H		;type
XPRT:	  EQU	3DDFH
;
	  END
