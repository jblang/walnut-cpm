
; I2CC-3.ASM - CCS 2719 and CCS 2830 overlay file for IMP - 10/27/85
;
;		    Z80 DART AND 8430 CTC TIMER
;		    (Uses 4.000 mhz clock and
;		    on-board 3.6864 MHz clock.)
;
; The CCS 2830 uses only the master system clock (4.0 MHz).
;
; This file adapts an S-100 computer using a CCS 2719 parallel/serial or
; CCS2830 board to the modem program.
;
; You can use either Port A or Port B for the modem serial port.  The
; values for both ports are shown, set for whichever port you prefer by
; changing the "PORTA" equate.
;
; The CTC timer uses the master system clock (4.0 MHz) for the "Timer
; mode" (07H command byte).  It uses the 3.6864 MHz xtal on the CCS 2719
; board in the "counter mode" (47H command word.)  Your divisor values
; for the various speeds would be configured accordingly.
;
;
; NOTE:  Check the clear screen and clear to end of line values as they
;	 differ from what you use.  Insert the appropriate values if so.
;
;-----------------------------------------------------------------------
;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Many terminals will clear the screen with a CTL-Z.  If yours does, put
; a 1AH at CLEAR: (010AH).  Many terminals use two characters, the first
; normally an ESC.  For example, ESC *.  In this case put '*' at CLEAR:
; (The ESC will automatically be typed with no CTL-character present.)
; If you don't know what your terminal uses, put a 0 at CLEAR: and IMP
; will scroll up 24 blank lines to clear the CRT for things like MENU,
; looking at the function key table, typing CTL-Z in command mode, etc.
;
; Use the "SET" command to change the baudrate when desired.  The value
; at MSPEED controls the baudrate when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to merge the results
;		of this program to the original .COM file:
;
;		A>MLOAD IMP.COM=IMP.COM,I2CC-x.HEX
;
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 10/27/85 - Restored baud rates to those normally used with this equip-
;	     ment.  If others are needed, install those on an individual
;	     basis, please.  Other incidental changes.
;						- Irv Hoff
; 10/17/85 - Added baud rates, and equates	- Fred Townsend
; 07/17/85 - Written for use with IMP		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
YES	EQU	0FFH
NO	EQU	0
;
;
; Select one of the following:
;
CCS2719	EQU	YES
CCS2830	EQU	NO
;
;
; Values shown are for a Z80 SIO
;
; NOTE:  Port A is 54H (CTC timer 50H), Port B is 56H (CTC timer 51H)
;
PORTA	EQU	YES	;Yes = Port A, No = Port B (Used on 2719 only)
;
	 IF	CCS2719	AND PORTA
PORT	EQU	54H	; Your base data port (port A)
BRPORT	EQU	50H	; Baud rate control port (CTC)
	 ENDIF		; CCS2719 AND PORTA
;
	 IF	CCS2719	AND NOT	PORTA
PORT	EQU	56H	; Your base data port (port B)
BRPORT	EQU	51H	; Baud rate control port (CTC)
	 ENDIF		; CCS2719 AND NOT PORTA
;
;
;-----------------------------------------------------------------------
;
; NOTE:  The CCS2830 has numerous ports available, insert correct pair
;
	 IF	CCS2830
PORT	EQU	0C4H	; Your base data port
BRPORT	EQU	0C0H	; Baud rate control port (CTC)
	 ENDIF		; CCS2830
;
;
;-----------------------------------------------------------------------
;
; Common equates
;
MDCTL1	EQU	PORT+1	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MDRCV	EQU	01H	; Modem receive ready
MDSND	EQU	04H	; Modem send ready bit
MDTXE	EQU	01H	; Modem send buffer empty, holding buffer empty
;
;
;-----------------------------------------------------------------------
;
ESC	EQU	'['-40H	; ^[ = Escape
BELL	EQU	'G'-40H	; ^G = Bell character
LF	EQU	'J'-40H	; ^J = Linefeed
NEXTRY	EQU	'K'-40H	; ^K = Try next phone number, abort this try
CR	EQU	'M'-40H	; ^M = Carriage return
CLEARSC	EQU	'Z'-40H	; ^Z = Clears screen, command mode only
EOFCHAR	EQU	'Z'-40H	; ^Z = End of file
;
;
;-----------------------------------------------------------------------
;
;
	ORG	0100H
;
;
	DS	3	; Skip the data area below
;
;
; These routines and equates are at the beginning of the program so
; they can be patched by a monitor or overlay file without re-assembling
; the program.
;
MSPEED:	 DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	 DB	NO	; Yes=2400 bps highest speed			104H
HS1200:	 DB	YES	; Yes=1200 bps highest speed			105H
RACAL:	 DB	NO	; Yes=Racal-Vadic 1200V or 2400V or 2400PA	106H
PROMODM: DB	NO	; Yes=Prometheus ProModem 1200 bps		107H
RESVD1:	 DB	NO	; Reserved for special modems			108H
RESVD2:	 DB	NO	; Reserved for special modems			109H
;
;
CLEAR:	 DB	0CH	; Clear screen character (ESC not needed)	10AH
CLOCK:	 DB	40	; Clock speed in MHz x10, 25.5 MHz max. 	10BH
			; 20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
BYTDLY:	 DB	2	; 0=0 delay  1=10ms  5=50 ms - 9=90 ms		10CH
			;   default time to send character in ter-
			;   minal mode file transfer for slow BBS
CRDLY:	 DB	2	; 0=0 delay 1=100 ms 5=500 ms - 9=900 ms	10DH
			;   default time for extra wait after CRLF
			;   in terminal mode file transfer
NOFCOL:	 DB	5	; Number of directory columns shown		10EH
TCHPUL:	 DB	'T'	; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;.....
;
;
ADDLFD:	 DB	NO	; Yes=add LF after CR to send file in terminal	110H
			;   mode (normally added by remote echo)
CONVRUB: DB	YES	; Yes=convert rub to backspace			111H
CRCDFLT: DB	YES	; Yes=default to CRC checking			112H
IGNRCTL: DB	NO	; Yes=CTL-chars above ^M not displayed		113H
;.....
;
;
EXTCHR:	 DB	'['-40H	; ESC = preceeds local control character	114H
EXITCHR: DB	'E'	; Exit character				115H
FILESND: DB	'F'	; Send file when in terminal mode		116H
NOCONCT: DB	'N'	; Disconnect from phone line			117H
LOGCHR:	 DB	'L'	; Send logon					118H
LSTCHR:	 DB	'P'	; Toggle printer				119H
UNSAVCH: DB	'R'	; Close input text buffer			11AH
SAVECHR: DB	'Y'	; Open input text buffer			11BH
CLEARS:	 DB	'Z'	; Clears screen, terminal mode			11CH
SPARE1:	 DB	0	; For future development			11DH
NODTR:	 DB	NO	; Yes if no DTR and need +++ to disconnect	11EH
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: MVI	A,10H		; Register 0, reset interrupts		11FH
	  OUT	MDCTL1		;					121H
	  IN	MDCTL1		;					123H
	  RET			; IN modem control port 		125H
	  DB	0,0,0		; Spares if needed			126H
;
I$MDTXE:  MVI	A,11H		; Select read register 1		129H
	  OUT	MDCTL1		;					12BH
	  IN	MDCTL1		;					12DH
	  RET			;					12FH
	  DB	0,0,0		;					130H
;
I$MDDATP: IN	MDDATP		;					133H
	  RET			;					135H
	  DB	0,0,0,0,0,0,0	; Spares if needed			136H
;
O$MDDATP: OUT	MDDATP		;					13DH
	  RET			; OUT modem data port			13FH
	  DB	0,0,0,0,0,0,0	; Spares if needed			140H
;.....
;
;
A$MDRCV:  ANI	MDRCV		;					147H
	  RET			;					149H
;
C$MDRCV:  CPI	MDRCV		;					14AH
	  RET			;					14CH
;
A$MDSND:  ANI	MDSND		;					14DH
	  RET			;					14FH
;
C$MDSND:  CPI	MDSND		;					150H
	  RET			;					152H
;
A$MDTXE:  ANI	MDTXE		;					153H
	  RET			;					155H
;
C$MDTXE:  CPI	MDTXE		;					156H
	  RET			;					158H
;.....
;
;
; Special exit vector, used by some computers to reset interrupt vectors
;
J$EXITVEC:RET			;					159H
	  DB	0,0		;					15AH
;.....
;
;
; Jump vectors needed by each overlay
;
J$GOODBYE:JMP	GOODBYE		; Disconnects modem by dropping DTR	15CH
J$INITMOD:JMP	INITMOD		; Initializes modem, autosets baudrate	15FH
J$STUPR:  JMP	STUPR		; SET routine to change baudrate	162H
J$SYSVR:  JMP	SYSVR		; Signon message			165H
;.....
;
;
; "AT" command strings, can be replaced in individual overlay if needed
;
J$STRNGA: DS	3		; 1200 bps "AT" string			168H
J$STRNG1: DS	3		; 2400 bps "AT" string			16BH
;
;
; Next fourteen lines should not be changed by user overlay as these go
; to specific locations in the main program, not in the overlay.
;
;
J$CMDSPL: DS	3		; Allows entry of baudrate on CMD line	16EH
J$CRLF:	  DS	3		; Turns up one new line on display	171H
J$DIAL:	  DS	3		; Start of dialing routine		174H
J$DSCONT: DS	3		; Terminates modem use			177H
J$GOLST:  DS	3		; Printer routine, needed by Apple //e	17AH
J$ILPRT:  DS	3		; Prints an inline string, 0 to end	17DH
J$INBUF:  DS	3		; Stores a keybd string for comparison	180H
J$INLNCP: DS	3		; Inline "compare strings" routine	183H
J$INMDM:  DS	3		; Max .1 sec wait for modem character	186H
J$RCVRSP: DS	3		; For 3801 I/O use (TV-803)		189H
J$SNDCHR: DS	3		; Sends a character to the modem	18CH
J$SNDSTR: DS	3		; Sends a string to the modem, $ to end 18FH
J$TIMER:  DS	3		; .1 second timer (amount in 'B' reg.)	192H
J$NEW1:	  DB	0,0,0		; For future needs			195H
J$NEW2:	  DB	0,0,0		; For future needs			198H
;.....
;
;
; For 2400 bps auto-stepdown units
;
MANUAL:	  DB	0		; For manual selection flag		19BH
J$300:	  JMP	OK300		; Sets baudrate to 300 baud		19CH
J$1200:	  JMP	OK1200		; Sets baudrate to 1200 bps		19FH
J$2400:	  JMP	OK2400		; Sets baudrate to 2400 bps		1A2H
;.....
;
;
LOGPTR:	  DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	  CALL	J$ILPRT		; Display the following line		1A7H
	   IF	CCS2719
	  DB	'Version for CCS 2719 serial port 5 ' ; 		1AAH
	   ENDIF		; CCS2719
;
	   IF	CCS2719	AND PORTA
	  DB	'4'
	   ENDIF		; CCS2719 AND PORTA
;
	   IF	CCS2719	AND NOT	PORTA
	  DB	'6'
	   ENDIF		; CCS2719 AND NOT PORTA
;
;
	   IF	CCS2830
	  DB	'Version for CCS 2830 serial port 0C4H'	;		1AAH
	   ENDIF		; CCS2830
;
	  DB	CR,LF,0
	  RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H (601 bytes
;	 available after start of SYSVER).
;
;-----------------------------------------------------------------------
;
; You can put in a message at this location which can be called up with
; (special character-L).  You can put in several lines.  End with a 0.
;
LOGON:	DB	'This is a CCS-2719 system ',CR,LF,0
;
;-----------------------------------------------------------------------
;
;
; This routine sets DTR low for 300 ms to disconnect the phone
;
GOODBYE:
	MVI	B,'S'-40H	; X-off to stop host if needed
	CALL	J$SNDCHR
	MVI	B,1		; Wait a moment to let it react
	CALL	J$TIMER
	MVI	A,5
	OUT	MDCTL1		; Sned to the status port
	MVI	A,68H		; Turn off DTR, send break
	OUT	MDCTL1
	MVI	B,3		; Wait 300 ms
	CALL	J$TIMER
	MVI	A,5
	OUT	MDCTL1
	MVI	A,0E8H		; Restore to normal, 8 bits, dtr on, etc.
	OUT	MDCTL1
	RET
;.....
;
;
; IMS baud rate change.  Sets CTC for baud rate.
;
INITMOD:
	MVI	A,0		; Select register
	OUT	MDCTL1		; Send to the status port
	MVI	A,18H		; Reset the Z8SIO chip
	OUT	MDCTL1		; Send to the status port
	MVI	A,4		; Select register
	OUT	MDCTL1		; Send to the status port
	MVI	A,4CH		; 16x, 2-stop, no parity (1=44, 2=4C)
	OUT	MDCTL1		; Send to the status port
	MVI	A,3		; Select register
	OUT	MDCTL1		; Send to the status port
	MVI	A,0C1H		; Enable receive section
	OUT	MDCTL1		; Send to the status port
	MVI	A,5		; Select register
	OUT	MDCTL1		; Send to the status port
	MVI	A,0EAH		; DTR, RTS, 8-bits, enable send section
	OUT	MDCTL1		; Send to the status port
;
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
	CPI	6		; 2400 bps
	JZ	OK2400
	CPI	8		; 9600 bps
	JZ	OK9600
;
	 IF	CCS2719
	CPI	9
	JZ	OK19200
	 ENDIF			; CCS2719
;
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	LXI	D,BAUDBUF	; Point to new input buffer
	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, 2400, 9600'
;
	 IF	CCS2719
	DB	' 19200'
	 ENDIF			; CCS2719
;
	DB	'): ',0
	LXI	D,BAUDBUF	; Point to new input buffer
	CALL	J$INBUF
	CALL	J$CRLF
	LXI	D,BAUDBUF+2
;
STUPR2:	CALL	J$INLNCP	; Compare BAUDBUF+2 with chars. below
	DB	'300',0
	JNC	OK300		; Go if got match
	CALL	J$INLNCP
	DB	'1200',0
	JNC	OK1200
	CALL	J$INLNCP
	DB	'2400',0
	JNC	OK2400
	CALL	J$INLNCP
	DB	'9600',0
	JNC	OK9600
;
	 IF	CCS2719
	CALL	J$INLNCP
	DB	'9600',0
	JNC	OK9600
	 ENDIF			; CCS2719
;
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;
OK300:	MVI	A,1		; MSPEED 300 baud value
	LXI	H,BD300		; Get 300 bps parameters in 'HL'
	JMP	LOADBD		; Go load them
;
OK1200:	MVI	A,5
	LXI	H,BD1200
	JMP	LOADBD
;
OK2400:	XRA	A
	STA	MANUAL		; Reset to maximum auto-speed
	MVI	A,6
	LXI	H,BD2400
	JMP	LOADBD
;
OK9600:	MVI	A,8
	LXI	H,BD9600
	JMP	LOADBD
;
	 IF	CCS2719
OK19200:MVI	A,9
	LXI	H,BD19200
	 ENDIF			; CCS2719
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baudrate
	MOV	A,H		; CTC command word
	OUT	BRPORT
	MOV	A,L		; Baudrate
	OUT	BRPORT
	RET
;.....
;
;
; TABLE OF BAUD RATE PARAMETERS
;
; Note:  For the CCS2719, 300 baud uses the 4.000 MHz xtal on the timer
;	 part of the CTC, while the other speeds use a 1.8432 MHz on the
;	 serial board for the counter part of the CTC.
;
	 IF	CCS2719
BD300	EQU	0734H		; 15600/300 (first half is CTC command)
BD1200	EQU	4760H		; 115200/1200
BD2400	EQU	4730H		; 115200/2400
BD9600	EQU	470CH		; 115200/9600
BD19200	EQU	4706H		; 115200/19200
	 ENDIF			; CCS2719
;
;
; Note:  For the CCS2830, all baudrates use the 4.0 MHz xtal on both the
;	 timer part of the CTC and the counter part of the CTC.
;
	 IF	CCS2830
BD300	EQU	0734H		; 15600/300 (first half is CTC command)
BD1200	EQU	4768H		; 124800/1200
BD2400	EQU	4734H		; 124800/2400
BD9600	EQU	470DH		; 1247800/9600
	 ENDIF			; CCS2830
;
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE: Must terminate prior to 0400H
;
	END
