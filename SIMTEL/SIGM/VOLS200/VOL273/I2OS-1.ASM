; I2OS-1.ASM  -  Osborne OS-1 overlay file  for IMP  - 10/27/85
;
;			6850  ACIA
;
;  NOTE ..... This overlay will NOT, repeat, NOT work with the
;	      Osborne COMM-PAC modem or the CTS DATACOMM modem.
;	      These two modems are 300 bps only and do not have
;	      the faster baud rates necessary to take advantage
;	      of the IMP program.
;
;	      The new 1K CRC protocol is not supported at 300
;	      bps in IMP or KMD. In addition, YAM batch transfers
;	      with IMP and KMD are supported only with 1K CRC
;	      protocol at 1200 and 2400 bps.
;
;	      No real advantage is gained with using IMP at 300
;	      bps.  Osborne COMM-PAC and CTS DATACOMM users
;	      should continue to use MDM740.
;
;-----------------------------------------------------------------------
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Many terminals will clear the screen with a CTL-Z.  If yours does, put
; a 1AH at CLEAR: (010AH).  Many terminals use two characters, the first
; normally an ESC.  For example, ESC *.  In this case put '*' at CLEAR:
; (The ESC will automatically be typed with no CTL-character present.)
; If you don't know what your terminal uses, put a 0 at CLEAR: and IMP2
; will scroll up 24 blank lines to clear the CRT for things like MENU,
; looking at the function key table, typing CTL-Z in command mode, etc.
;
; Use the "SET" command to change the baudrate when desired.  The value
; at MSPEED controls the baudrate when the program is first called up.
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD to merge into the main file:
;
;		MLOAD IMP.COM=IMP2xx.COM,I2OS-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 10/27/85  Modified for Osborne 1 computer	- Roy Robinson
;	    two hardware equates added		  FOG #4 RCP/M
;						  (415) 591-6259
; 06/27/85  Written for use with IMP2		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
; DOCUMENTATION FOR THIS IMP OVERLAY:
;
;-------------------
;
; If you intend to use this overlay with none of the hardware modifica-
; tions to the main logic board described in this overlay, set the
; DTRMOD equate to NO.	You will have the following baud rate selections:
; 300 and 1200 bps.  An unmodified Osborne 1 will not work if the DTRMOD
; equate is set to YES.
;
; The NUEVO equate concerns the use of a "piggy-back" 80 column video
; board made by NUEVO ELECTRONICS with an optional baud rate generator.
; NUEVO ELECTRONICS may be contacted at: (713) 341-6001.
;
;-------------------
; The NUEVO equate:
;
; If you have the NUEVO 80 column video board with the baud rate option
; installed, set the NUEVO equate to YES.  You will then have the fol-
; lowing baud rate selections: 300, 1200, 2400, 4800, 9600, and 19,200
; bps.	Setting either the HS1200 or HS2400 equate to YES, along with
; the matching MSPEED value will configure IMP2 to 1200 or 2400 bps re-
; spectively when the program is executed.
;
; If your NUEVO 80 column board does NOT have the optional baud rate
; generator, set the NEUVO equate to NO.  Since the NUEVO baud rate
; generator is not installed, you will have the following baud rate
; selections: 300 and 1200 bps.
;
; Contact NUEVO ELECTRONICS if you wish to install the baud rate option
; on your NUEVO 80 column board.
;
;--------------------
;The DTRMOD equate:
;
; If you decide to install the DTR modification to your Osborne 1 main
; logic board, set the DTRMOD equate to YES.  This DTR modification can
; be installed in an Osborne 1 with or without the Osborne or NUEVO 80
; column video boards.	The DTR modification gives the Osborne 1 the
; ability to force the modem to hang up the phone by dropping the 6850
; ACIA RTS line which is connected to the modem DTR input.  The modifi-
; cation offers the Osborne 1 hardware control of the modem, rather than
; depending on the software generated "ATH" modem command.
;
; The DTR modification is required if your modem does not follow the
; Hayes/Racal-Vadic/USRobotics/Prometheus modem software commands.
;
; If you do use the DTR modification, you will need to configure a spe-
; cial RS-232 cable from your Osborne 1 serial port to your external
; modem.  Your modem must support the DTR input signal line and you must
; set the modem DTR switch or program the modem internal memory to moni-
; tor its DTR signal input.
;
; New RS-232 modem cable to be used with OCC-1 and external modem when
; using DTR control:
;
;
;	  OCC-1 		       MODEM
;
;	 2    RXD		      3    RXD
;	 3    TXD		      2    TXD
;	 5    RTS (new function)      20   DTR
;	 7    GND		      7    GND
;
;	DTR SUPPORT MODIFICATION
;
; OSBORNE 1 MAIN LOGIC BOARD TRACE CUTS:
; The Osborne 1 main logic board is organized into zones which are iden-
; tified on the COMPONENT side of the main logic board with LETTERS found
; along the left side of the board and NUMBERS found along the rear of
; the  board (i.e., the 6850 ACIA device is located in zones C4, C5, and
; C6 and the MC1458 device is located in zone E3).  If you are unsure
; how to count pin numbers on IC devices, find a friend who does, attend
; a user group meeting, or take your computer to a computer store/service
; center for further aid.
;
; --------------------------
; Solder Side:
;
; Cut the trace running from pin 5 to pin 6 on the inner row of pads
; used to mount the RS-232 female serial connector at the front of the
; main logic board.  Pin 1 is the pad with a wide ground trace.
;
; Component side:
;
; Cut the trace from pin 5 of the 6850 ACIA device in zone C4 to resistor
; R20 (10K ohm) located in zone D5.
;
; PART ADDITIONS:
; --------------
; Solder side:
;
; Add a jumper wire from pin 1 of the MC1458 device in zone E3 to pin 5
; on the inner row of the RS-232 serial port pads.
; Pin 1 is the pad with the wide ground trace.
;
; Add a jumper wire from pin 3 of the MC1458 device in zone E3 to pin 5
; of the same MC1458 device in zone E3.
;
; Using the component side or solder side (whichever side you feel more
; comfortable for mounting  the two - 1/4 watt resistors):
;
; Mount a 10K ohm resistor from Vcc which is +5 volts (pin 14 of the
; 74LS02 device in zone D2 is a good solder point) to pin 2 of the MC1458
; device in zone E3.
;
; Mount a 220 ohm resistor from pin 5 of the 6850 ACIA device in zone
; C4 to pin 2 of the MC1458 device in zone E3.	Pin 2 of the MC1458
; device in zone E3 should now have two resistors attached to it.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;*    TAMPERING WITH YOUR MAIN LOGIC BOARD MAY VOID ANY  WARRANTY
;     OR SERVICE AGREEMENTS ON YOUR COMPUTER.
;*    UNPLUG   YOUR   COMPUTER	 FROM  THE   AC   OUTLET   BEFORE
;     DISASSEMBLING THE COMPUTER.  USE COMMON SENSE.
;*    ALTHOUGH	THE MODIFICATION HAS BEEN TESTED ON SEVERAL  MAIN
;     LOGIC  BOARDS  HAVING  DIFFERENT	REVISION    LEVELS,   THE
;     MODIFICATION IS DONE AT YOUR OWN RISK.
;
;*    INSTALLATING THIS DTR MODIFICATION WILL NO LONGER ALLOW YOU
;     TO USE THE 9 PIN MODEM PORT WITH THE COMM-PAC OR DATACOMM
;     MODEMS.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
;	EQUATES FOR MODIFICATIONS TO STANDARD OZZIE MAIN LOGIC BOARD
;
DTRMOD	EQU	NO	; YES, if hardware mods have been installed on
			;   Osborne 1 main logic board to support DTR
			;   control of external modem.
			;   Do not set to YES if you have not installed
			;   DTR modifications.
			;   (see discussion above)
			;
NUEVO	EQU	NO	; YES, if Nuevo 80 column upgrade WITH baud rate
			;   option has been installed
			;   (see discussion above)
;
; Values shown are for the 6850 ACIA serial I/O device
;
PORT	EQU	2A00H	; OCC-1 base address
			; (memory mapped for data and status)
MDCTL1	EQU	PORT	; Modem control address (memory mapped i/o)
MDDATP	EQU	PORT+1	; Modem data address (memory mapped i/o)
MDRCV	EQU	01H	; Modem receive data register full (RDRF)
MDSND	EQU	02H	; Modem transmit data register empty (TDRE)
MDTXE	EQU	02H	; Modem transmit buffer empty (set to MDSND)
RMDRCV	EQU	0FEH	; Used with SSTAT routines
RMDSND	EQU	0FDH	; Used with SSTAT routines
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
CLEAR:	 DB	1AH	; Clear screen character (ESC not needed)	10AH
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
NODTR:	 DB	NO	; Yes if no DTR and using +++ to disconnect	11EH
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: CALL	OSTAT		;					11FH
	  RET			;					122H
	  DB	0,0,0,0,0,0	; Spares if needed			123H
;
I$MDTXE:  CALL	OSTAT		;					129H
	  RET			;					12CH
	  DB	0,0,0,0,0,0	; Spares if needed			12DH
;
I$MDDATP: CALL	OSIN		;					133H
	  RET			;					136H
	  DB	0,0,0,0,0,0	; Spares if needed			137H
;
O$MDDATP: CALL	OSOUT		;					13DH
	  RET			;					140H		
	  DB	0,0,0,0,0,0	; Spares if needed			141H
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
J$EXITVEC:
	  JMP	RSTINT		;					159H
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
LOGPTR:	DW	LOGON		; Pointer to display LOGON message	1A5H
;
SYSVR:	CALL	J$ILPRT		; Display the following line		1A7H
	DB	'Version for Osborne 1 Computer'	;		1AAH
;
	 IF	NUEVO
	DB	' with Neuvo 80 column upgrade and baud rate option'
	 ENDIF			; NUEVO
;
	DB	CR,LF
;
	 IF	DTRMOD
	DB	'DTR supported',CR,LF
	 ENDIF			; DTRMOD
;
	 IF	NOT DTRMOD
	DB	'DTR not supported',CR,LF
	 ENDIF			; NOT DTRMOD
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
LOGON:	DB	'Greetings from an Osborne 1 user',CR,LF,0
;
;-----------------------------------------------------------------------
;
;
; This routine sets RTS output low for 300 ms to disconnect the phone.
; RTS output from 6850 is connected to the DTR input of the modem.
;
GOODBYE:
	MVI	B,'S'-40H	; X-off to stop host if needed
	CALL	J$SNDCHR
	MVI	B,1		; Wait a moment to let it react
	CALL	J$TIMER
;
	 IF	 DTRMOD
	MVI	C,77H		; Send break, RTS active,
	CALL	STBAUD		; Send to status port routine
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	C,57H		; Turn off break and disable RTS
	CALL	STBAUD		; Send to status port routine
	MVI	B,1		; Slight delay
	CALL	J$TIMER
	LDA	BAUDRTE		; Normal I/O RTS active, same baud rate
	MOV	C,A
	JMP	STBAUD		; Send to status port routine
	 ENDIF			; DTRMOD
;
	RET

;.....
;
;
; You can use this area for any special initialization or setup you may
; wish to include.  Each must stop with a RET.	You can check the other
; available overlays for ideas how to write your own routines if that
; may be of some help.
;
;
INITMOD:  LHLD	0005H+1		; Find start of bdos
	  LXI	D,-0100H	; Go to first page ahead of bdos
	  DAD	D		; HL now positioned one page below bdos
	  PUSH	H		; Save the address
	  LXI	D,BDJ		; Point to our routine to put there
	  LXI	B,CDLEN+2	; Set length of code
	  XCHG
	  DB	0EDH,0B0H	; Z80 LDIR instruction
;
	  LHLD	0005H+1		; Get bdos address back once more
	  POP	D		; Get starting address off the stack
	  PUSH	D		; Put it back on the stack
	  INX	D		; Point to address position
	  XCHG			; Put into HL register pair
	  MOV	M,E		; Store 'LSP' address
	  INX	H		; Get 'LSP' location
	  MOV	M,D		; Store 'MSP' address
	  POP	H		; Get the address back once more
	  SHLD	0005H+1		; New address to protect from overwrite
;
	  LXI	D,OSIN-BDJ	; Get length of routine to move
	  DAD	D		; Commute address of the OSIN routine
	  SHLD	I$MDDATP+1	; Patch call for "GET CHARACTER" routine
	  LXI	D,OSOUT-OSIN
	  DAD	D
	  SHLD	O$MDDATP+1	; Patch call for "SEND CHARACTER" routine
	  LXI	D,OSTAT-OSOUT
	  DAD	D
	  SHLD	I$MDCTL1+1	; Patch call for "ACIA STATUS" routine
	  SHLD	I$MDTXE+1	; Patch call for "TRANSMIT BUFFER EMPTY"
;
;
;  Set requested baud rate then finished with initialization
;
	LDA	MSPEED		; Get the selected value
	CPI	1		; 300 bps
	JZ	OK300
	CPI	5		; 1200 bps
	JZ	OK1200
;
	 IF	NUEVO
	CPI	6		; 2400 bps
	JZ	OK2400
	 ENDIF			; NUEVO
;
	JMP	STUPR1		; Else ask what is wanted
;......
;
;
;-----------------------------------------------------------------------
;
RSTINT:	  JMP	0000H		; Osborne 1 likes this jump upon exit
;.....
;
;
;-----------------------------------------------------------------------
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
;
	 IF	NOT NUEVO
	DB	'Input Baud Rate (300, 1200): ',0
	 ENDIF			; NOT NUEVO
;
	 IF	NUEVO
	DB	'Input Baud Rate (300, 1200, 2400, 4800, '
	DB	'9600, 19200): ',0
	 ENDIF			; NUEVO
;
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
;
	 IF	NUEVO
	CALL	J$INLNCP
	DB	'2400',0
	JNC	OK2400
	CALL	J$INLNCP
	DB	'4800',0
	JNC	OK4800
	CALL	J$INLNCP
	DB	'9600',0
	JNC	OK9600
	CALL	J$INLNCP
	DB	'19200',0
	JNC	OK19200
	 ENDIF			; NUEVO
;
	CALL	J$ILPRT		; All matches failed, tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,CR,LF,0
	JMP	STUPR1		; Try again
;...
;
;
	 IF	NOT NUEVO
OK300:	MVI	A,1		; MSPEED 300 baud value
	 ENDIF			; NOT NUEVO
;
	 IF	NOT NUEVO AND DTRMOD
	MVI	C,16H		; X64 clock, 8 DB 1 SB, RTS active
	 ENDIF			; NOT NUEVO AND DTRMOD
;
	 IF	NOT NUEVO AND NOT DTRMOD
	MVI	C,56H		; X64 clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; NOT NUEVO AND NOT DTRMOD
;
	 IF	NOT NUEVO
	JMP	LOADBD		; Load ACIA control byte
;
OK1200:	MVI	A,5		; MSPEED 1200 baud value
	 ENDIF			; NOT NUEVO
;
	 IF	NOT NUEVO AND DTRMOD
	MVI	C,15H		; X16 clock, 8 DB 1 SB, RTS active
	 ENDIF			; NOT NUEVO AND DTRMOD
;
	 IF	NOT NUEVO AND NOT DTRMOD
	MVI	C,55H		; X16 clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; NOT NUEVO AND NOT DTRMOD
;
OK2400:	 IF	NOT NUEVO
;
LOADBD:	STA	MSPEED
	MOV	A,C		; Move ACIA control byte from C to A
	STA	BAUDRTE		; Save ACIA control byte
	 ENDIF			; NOT NUEVO
;...
;
;
	 IF	NUEVO
OK300:	MVI	A,1		; MSPEED 300 baud value
	MVI	C,05H		; Get 300 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK1200:	MVI	A,5		; MSPEED 1200 baud value
	MVI	C,07H		; Get 1200 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK2400:	XRA	A		; Reset to maximum auto-speed for
	STA	MANUAL		; 2400 bps auto-step down modems
	MVI	A,6		; MSPEED 2400 baud value
	MVI	C,0AH		; Get 2400 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK4800:	MVI	A,7		; MSPEED 4800 baud value
	MVI	C,0CH		; Get 4800 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK9600:	MVI	A,8		; MSPEED 9600 baud value
	MVI	C,0EH		; Get 9600 bps byte
	JMP	LOADBD		; Load baud rate generator control byte
;
OK19200:MVI	A,9		; MSPEED 9600 baud value
	MVI	C,0FH		; Get 9600 bps byte
;
LOADBD:	STA	MSPEED
	MOV	A,C		; Move baud rate byte from c to a
	OUT	06H		; Send to NUEVO baud rate generator port
	 ENDIF			; NUEVO
;
	 IF	NUEVO AND DTRMOD
	MVI	A,15H		; 16X clock, 8 DB 1 SB, RTS active
	 ENDIF			; NUEVO AND DTRMOD
;
	 IF	NUEVO AND NOT DTRMOD
	MVI	A,55H		; 16X clock, 8 DB 1 SB, RTS inactive
	 ENDIF			; NUEVO AND NOT DTRMOD
;
	 IF	NUEVO
	  STA	BAUDRTE		; Save ACIA control byte
	 ENDIF			; NUEVO
;...
;
;
STBAUD:	PUSH	H
	CALL	OSET
	POP	H
	RET
;.....
;
;
OSET:	LHLD	1		; Get bios+3 address
	MVI	L,3CH		; Extended bios routine for baud rate select
	PCHL			; branch to it
;.....
;
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;
BAUDRTE:DB	0	; Storage location for baud rate byte
SSTAT:	DB	0	; RAM location serves as a secondary status register
			;   for 6850 ACIA status register.
			;   This RAM register is used since the  6850 ACIA
			;   clobbers its own internal status register
			;   (with regard to TDRE and RDRF status bits) when
			;   data is traveling in both directions via the
			;   serial port -- important for ascii text uploads.
;.....
;
;
; --- ROUTINES THAT ARE PLACED JUST UNDER BDOS OVERLAYING THE CCP
;
BDJ:	JMP	$-$		; This gets patched to jump to bdos entry
;
OSIN:	LDA	SSTAT		; Update SSTAT location in RAM
	ANI	RMDRCV		; before inputing data
	STA	SSTAT
;
	DI			; Disable interrupts
	OUT	0		; Switch to alternate bank
	LDA	MDDATP		; Get data input
	OUT	1		; Switch to main bank
	EI			; Re-enable interrupts
	RET
;.....
;
;
OSOUT:	DI			; Disable interrupts
	OUT	0		; Switch to alternate bank
	STA	MDDATP		; Send data output
	OUT	1		; Switch to main bank
	EI			; Re-enable interrupts
;
	LDA	SSTAT		; Update SSTAT location in RAM
	ANI	RMDSND		; after outputing data
	STA	SSTAT
	RET
;.....
;
;
OSTAT:	DI			; Disable interrupts
	OUT	0		; Switch to alternate bank
	LDA	MDCTL1		; Get status byte
	OUT	1		; Switch to main bank
	EI			; Re-enable interrupts
;
	PUSH	B		; Update SSTAT location in RAM
	MOV	B,A		; using current ACIA status register
	LDA	SSTAT		; bits and earlier ACIA status register
	ORA	B		; bits
	STA	SSTAT
	POP	B
	RET
;.....
;
;
CDLEN	EQU	$-BDJ		; Length of code to relocate
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE: Must terminate by 0400H
;
	END
