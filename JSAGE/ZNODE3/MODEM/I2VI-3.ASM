
; I2VI-3.ASM  -  Visual 1050 computer overlay for IMP  -  12/01/87
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; Interrupt vectors
;
int$port	equ	0C0h
int$initial	equ	010h
int$mask	equ	1110$1111b	; All on except VERT
all$ints	equ	1111$1111b	; All interrupts enabled
vert$clear	equ	0A0h		; Clear vert interrupt
;
; RS-232 8251
;
p$aux1$data	equ 8Ch	; rs-232 xmit/recv data
p$aux1$control	equ 8Dh	; rs-232 control/status
;
; Miscellaneous 8255
p$printer	equ 91h	; printer bits
p$misc		equ 92h	; miscellaneous bits
p$8255$control	equ 93h	; 8255 control port
;
;  Lpt masks
;
misc$lpt$strobe	equ	0000$0001b	; handshake strobe
misc$lpt$avail	equ	0010$0000b	; lpt available
misc$lpt$nobusy	equ	0001$0000b	; finished printing
; equates for mode byte bit fields
;
mb$input		equ 0000$0001b	; device may do input
mb$output		equ 0000$0010b	; device may do output
mb$in$out		equ mb$input+mb$output
;
mb$soft$baud		equ 0000$0100b	; software selectable
;					; baud rates
;
mb$serial		equ 0000$1000b	; device may use protocol
mb$xon$xoff		equ 0001$0000b	; XON/XOFF protocol
;					; enabled
; port c base baud rate definitions
;
misc$base01200	equ 0000$0000b  ; port c 1200 baud
misc$base02400	equ 0000$0100b  ; port c 2400 baud
misc$base19200	equ 0000$1000b  ; port c 19200 baud
misc$base09600	equ 0000$1100b  ; port c 9600 baud
misc$baudmask	equ 0000$1100b  ; mask for port c base baud rate
mode$div16	equ 0000$0010b  ; 16x baud rate factor
mode$div64	equ 0000$0011b  ; 64x baud rate factor
;
baud$300	equ      misc$base01200 or mode$div64 	; 300 baud
baud$600	equ      misc$base02400 or mode$div64 	; 600 baud
baud$1200	equ      misc$base01200 or mode$div16 	; 1200 baud
baud$2400	equ      misc$base02400 or mode$div16 	; 2400 baud
baud$4800	equ      misc$base19200 or mode$div64 	; 4800 baud
baud$9600	equ      misc$base09600 or mode$div16 	; 9600 baud
baud$19200	equ      misc$base19200 or mode$div16 	; 19.2k baud
;
; 8251 Modes
;
mode$s2	        equ 1000$0000b  ; stop bit high
mode$s1         equ 0100$0000b  ; stop bit low
mode$ep	        equ 0010$0000b  ; even parity
mode$pen        equ 0001$0000b  ; parity enable
mode$12         equ 0000$1000b  ; char length high
mode$11         equ 0000$0100b  ; char length low
mode$b2         equ 0000$0010b  ; baud rate factor high
mode$b1		equ 0000$0001b  ; baud rate factor low
com$eh    	equ 1000$0000b  ; enter hunt mode
com$ir		equ 0100$0000b  ; internal reset
com$rts		equ 0010$0000b  ; request to send
com$er		equ 0001$0000b  ; error reset
com$sbrk	equ 0000$1000b  ; send break
com$rxe		equ 0000$0100b  ; receive enable
com$dtr		equ 0000$0010b  ; data terminal ready
com$txe     	equ 0000$0001b  ; transmit enable
;
; some common values
;
mode$eight	equ 0000$1100b  ; eight data bits
mode$onestop	equ 0100$0000b  ; one stop bit
mode$baudmask	equ 0000$0011b  ; to get baud bits from port c
mode$default   	equ mode$onestop or mode$eight or mode$div16
                                ; one stop, eight data, no parity, 16x
com$default	equ com$rts or com$rxe 
			        ; request to send and receive enable
;
; Miscellaneous 8255
lpt$mode0	equ 088H        ; Mode:A=0&OT, CH=IN, B=0&OT, c=OT
lpt$baud	equ 0000$1100b  ; 1200 baud
;
;
YES	EQU	0FFH
NO	EQU	0
;
PORT	EQU	08CH	; Visual 8251A serial base port
MDCTL1	EQU	PORT+1	; Modem control port
MDDATP	EQU	PORT	; Modem data port
MDRCV	EQU	02H	; Modem receive ready
MDSND	EQU	01H	; Modem send ready bit
MDTXE	EQU	05H	; Modem send buffer empty, holding buffer empty
;
BRPORT	EQU	92H	; Port for setting baud rate
;
MDMODE	EQU	82H	; Insures 8251A is out of mode with DTR high
MDRSET	EQU	42H	; Resets USART for additional commands
MDSET1	EQU	4EH	; 1 stop bit, no parity, 8 bits, x16
MDSET2	EQU	0CEH	; 2 stop bits, no parity, 8 bits, x16
MDCOM	EQU	37H	; Reset error flags, RCV, DTR, TX ready
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
	DS	3		; Skip the data area below
;
;
; These routines and equates are at the beginning of the program so
; they can be patched by a monitor or overlay file without re-assembling
; the program.
;
MSPEED:	 DB	5	; 0=110 1=300 2=450 3=600 4=710 5=1200		103H
			; 6=2400 7=4800 8=9600 9=19200 default
HS2400:	 DB	YES	; Yes=2400 bps highest speed			104H
HS1200:	 DB	NO	; Yes=1200 bps highest speed			105H
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
TCHPUL:	 DB	'P'	; T=tone, P=Pulse (Hayes 2400 modems)		10FH
;.....
;
;
ADDLFD:	 DB	NO	; Yes=add LF after CR to send file in terminal	110H
			;   mode (normally added by remote echo)
CONVRUB: DB	YES	; Yes=convert rub to backspace			111H
CRCDFLT: DB	YES	; Yes=default to CRC checking			112H
IGNRCTL: DB	YES	; Yes=CTL-chars above ^M not displayed		113H
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
BRKCHR:	 DB	'Q'	; Send a break tone				11DH
NODTR:	 DB	NO	; Yes if no DTR and need ATH0 to disconnect	11EH
;.....
;
;
; Handles in/out ports for data and status
;
I$MDCTL1: IN	MDCTL1		;					11FH
	  RET			; Spares if needed			121H
	  DB	0,0,0,0,0,0,0	; Spares if needed			122H
;
I$MDTXE:  IN	MDCTL1		; (Needed for SIO or DART register 1	129H
	  RET			;					12BH
	  DB	0,0,0,0,0,0,0	;					12CH
;
I$MDDATP: JMP	BDOS3		;					133H
	  DB	0,0,0,0		;					136H
	  DB	0,0,0		;					13AH
;
O$MDDATP: JMP	BDOS4		;					13DH
	  DB	0,0,0,0		; OUT modem data port			140H
	  DB	0,0,0		; Spares if needed			144H
;.....
;
;
A$MDRCV:  JMP	BDOS7		;ANI	MDRCV				147H
	  			;RET					149H
;
C$MDRCV:  JMP	BDOS7		;CPI	MDRCV				14AH
	  			;RET					14CH
;
A$MDSND:  JMP	BDOS8		;ANI	MDSND				14DH
	  			;RET					14FH
;
C$MDSND:  JMP	BDOS8		;CPI	MDSND				150H
	  			;RET					152H
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
J$BREAK:  JMP	SENDBRK		; Break routine 			195H
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
	  DB	1bh,'[4m','Version for Visual 1050 Computer' ;		1AAH
	  DB	1bh,'[m',CR,LF,0
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
LOGON:	DB	'Hello... ',CR,0
;.....
;
;
;-----------------------------------------------------------------------
;
; This routine sets a 300 ms break tone
;
SENDBRK:
	MVI	A,3FH		; DTR normal, send break tone
	JMP	GOODBYE+2
;.....
;
;
; This routine sets DTR low for 300 ms to disonnect the phone
;
GOODBYE:
	MVI	A,3DH		; Send break, turn off DTR
	CALL	SETMCTL		; Send to status port
	MVI	B,3		; Delay 300 ms to hang up phone
	CALL	J$TIMER
	MVI	A,17h		; Normal send/receive with DTR
	CALL	SETMCTL		; Send to status port
	RET
;.....
;
;
; Visual initialization -- sets the 8251A for 8 bits, 1 stop pulse,
; DTR high, requires jumper to be set internally to 1200 baud then
; divides by 64 for 300, or by 16 for 1200 baud via "SET" command.  Set
; at present to default to 300 baud.
;
INITMOD:MVI	A,3FH		; Get byte to enable interrupts
	OUT	09DH		; Turn on interrupts
;
;
; The Visual 1050 provides a special function which returns the
; address of the byte where the BIOS keeps the current value of
; the modem control register.  We must modify this byte whenever
; we change the value of this register, or the BIOS will clobber
; it whenever it gets an interrupt from the modem port.
;
	LXI	D,BIOSPB	; Parameter block for BIOS call
	MVI	C,50		; Bdos function for direct BIOS call
	CALL	5
	SHLD	RSPAR		; Save the returned address
	RET
;
	MVI	A,MDMODE	; Insure 8251 is out of mode
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDRSET	; Reset the 8251A for new command
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDSET1	; Set stop pulse, no parity 8 bits, x16
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
	MVI	A,MDCOM		; Error reset, RCV, DTR, TX ready
	OUT	MDCTL1
	XTHL			; Small delay to complete command
	XTHL
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
	JMP	STUPR1		; Else ask what is wanted
;.....
;
;
STUPR:	CALL	J$CMDSPL	; Gives us CMDBUF+6
	JNC	STUPR2
;
STUPR1:	CALL	J$ILPRT
	DB	'Input Baud Rate (300, 1200, 2400, 9600, 19200): ',0
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
	CALL	J$INLNCP
	DB	'19200',0
	JNC	OK19200
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
OK19200:MVI	A,9
	LXI	H,BD19200
;
LOADBD:	STA	MSPEED		; Change time-to-send to match baud rate
	MOV	A,L		; Get baudrate byte
	STA	LOAD1+1		; Send to timer for new baudrate
	MOV	A,H
	OUT	MDCTL1		; Modem status port (mode word)
	MVI	A,17h		;MDCOM		 DTR, RCV, XMT, error reset
	CALL	SETMCTL		; Modem status port
	IN	BRPORT		; Get what was there
	ANI	0F3H		; Clear out the old baud rates
;
LOAD1:	ORI	0		; Set new baudrate
	OUT	BRPORT		; New baud rate now set
	RET
;.....
;
;
; Table of baudrate parameters
;
BD300	EQU	baud$300	;4F00H		 4F divides by 64
BD1200	EQU	baud$1200	;4E00H		 4E divides by 16
BD2400	EQU	baud$2400	;4E04H
BD9600	EQU	baud$9600	;4E08H
BD19200	EQU	baud$19200	;4E10H
;
BAUDBUF:DB	10,0,0,0,0,0
	DB	0,0,0,0,0,0
;.....
;
;
BIOSPB:	DB	30,3
;.....
;
;
; The following routines replace direct modem port I/O with BDOS calls.
; The Visual 1050 BIOS uses interrupt-driven I/O with ring buffers.
; This solves the problem of losing modem input while the console dis-
; play does a carriage return.
;
; Check for input character (receive ready)
;
BDOS7:	PUSH	B		; Save the registers
	MVI	C,7		; Bdos function number
	JMP	BDOS78		; Common routine for BDOS 7 and 8
;.....
;
;
; Check for output character (send ready)
;
BDOS8:	PUSH	B		; Save the registers
	MVI	C,8		; BDOS function number
;
BDOS78:	PUSH	D
	PUSH	H
	CALL	5
	POP	H		; Restore the registers
	POP	D
	POP	B
	ORA	A		; BDOS returns A=0 if not ready
	JZ	CLRZ		; Return Z flag off if not ready
	XRA	A		; Set Z flag if ready
	RET
;
CLRZ:	INR	A		; Clear Z flag (make a non-zero)
	RET
;.....
;
;
; Input a character from modem via BIOS ring buffer
;
BDOS3:	PUSH	B		; Save the registers
	PUSH	D
	PUSH	H
	MVI	C,3		; Bdos function number
	CALL	5
	POP	H		; Restore the registers
	POP	D
	POP	B
	RET			; Input character is in a
;.....
;
;
; Ouput a character to modem via BIOS ring buffer
;
BDOS4:	PUSH	B		; Save the registers
	PUSH	D
	PUSH	H
	MVI	C,4		; BDOS function number
	MOV	E,A		; Character to output must be in 'E'
	CALL	5
	POP	H		; Restore the registers
	POP	D
	POP	B
	RET
;.....
;
;
; The Visual 1050 BIOS keeps the current value of the modem control
; register in a special byte.  We must modify this byte whenever
; we change the value of this register, or the BIOS will clobber
; it whenever it gets an interrupt from the modem port.
;
SETMCTL:PUSH	H
	LHLD	RSPAR		; Address of BIOS byte
	MOV	M,A		; Save new value there
	OUT	MDCTL1		; Output to modem control register
	POP	H
	RET
;.....
;
;
RSPAR:	DS	2		; Addr of BIOS copy of modem control reg
;.....
;
;			       end
;-----------------------------------------------------------------------
;
; NOTE: Must terminate by 0400H
;
	END


