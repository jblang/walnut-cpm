;		NEWBAUD.ASM ver 2.2
;		(revised 08/14/82)
;	by Keith Petersen and Dave Hardy
;
;REMOTE BAUD RATE CHANGE UTILITY FOR PMMI MODEMS and external
; modems that use a WD8250 chip.
;
;Allows a remote user to change baud rate without
;having to call back.
;
;This program is compatible with CP/M 1.4, 2.x., and MP/M
;
;11/15/82 Added equates for WD8250. rlb
;
;08/14/82 Added LSPEED and MSPEED equates so versions of
;	  XMODEM (5.0 and up) that examine address 03dh to
;	  get the baud rate for calculating send time and
;	  marking the LOG.SYS file will work properly if this
;	  program is run. Set LSPEED true only if your BYE
;	  program sets the baud rate at address 03dh. XMODEM
;	  will now have the correct baud rate available.
;	  (0=110,1=300,2=450,3=600,4=710)  Tim Cannon. 
;
;12/27/80 Added code to set new stack because some systems
;	  require more stack space than available in CP/M's
;	  default stack.  (KBP)
;
TRUE	EQU	0FFFFH
FALSE	EQU	0
;
PMMI	EQU	FALSE	;TRUE PMMI MODEM
WD8250	EQU	TRUE	;TRUE EXTERNAL MODEM USING A 8250 CHIP
;
	IF	PMMI
;
;PMMI modem port equates
;
;Set TPORT to the base address of your PMMI modem
;(all other modem equates are based on this value).
;
TPORT	EQU	0C0H	;UART CONTROL/STATUS PORT
DPORT	EQU	TPORT+1 ;MODEM DATA PORT
RPORT	EQU	TPORT+2 ;RATE GEN/MODEM STATUS
CPORT	EQU	TPORT+3 ;MODEM CONTROL
;
;The following equates are used to set up the PMMI modem
;
P08BIT	EQU	0CH	;8 DATA BITS
P0NOPY	EQU	10H	;NO PARITY
P0TSB	EQU	40H	;2 STOP BITS
P0NORM	EQU	P08BIT+P0NOPY	    ;USE 8 BITS, NO PARITY
P0110	EQU	P08BIT+P0NOPY+P0TSB ;SAME W/2 STOP BITS
;
;Baud rate divisors
;
B110	EQU	142	;110 BAUD
B300	EQU	52	;300 BAUD
B450	EQU	35	;450 BAUD
B600	EQU	26	;600 BAUD
B710	EQU	22	;710 BAUD
	ENDIF
;
	IF WD8250
;
DPORT	EQU	0D8H	;DATA PROT
LPORT	EQU	DPORT+3	;LINE COONTROL
CPORT	EQU	DPORT+4	;MODEM CONTROL

;
;****************LINE STATUS MASKS*****************************
;
P0TBMT	EQU	20H	;XMIT BUFFER EMPTY
P0DAV	EQU	01H	;DATA AVAILABLE
;
*****************BAUD RATE DIVISORS****************************
;
BR110LS	EQU	017H	;110 BAUD
BR110MS	EQU	004H
BR300LS	EQU	080H	;300 BAUD
BR300MS	EQU	001H
BR450LS	EQU	000H	;450 BAUD
BR450MS	EQU	001H
BR600LS	EQU	0C0H	;600 BAUD
BR600MS	EQU	000H
BR120LS	EQU	060H	;1200 BAUD
BR120MS	EQU	000H
	ENDIF
;
;Equates for XMODEM version 5.0 and up.
;
LSPEED	EQU	TRUE	;True if your BYE pgm. sets baud rate.
MSPEED	EQU	03DH	;location of current baud rate.
;
BDOS	EQU	5	;BDOS ENTRY ADDRESS
CR	EQU	0DH	;CARRIAGE RETURN
LF	EQU	0AH	;LINEFEED
PRINT	EQU	9	;PRINT STRING FUNCTION
;
	ORG	100H
;
;Save old stack pointer and set new one
;
START:	LXI	H,0
	DAD	SP	 ;GET OLD STACK
	SHLD	STACK	 ;SAVE IT
	LXI	SP,STACK ;SET NEW STACK
;
;Print sign-on message
	LXI	D,MSG	 ;SEND MESSAGE TO CONSOLE
	MVI	C,PRINT	 ;VIA BDOS "PRINT STRING" FUNCTION
	CALL	BDOS
;
;Now wait until last character of message
;is finished before changing baud rate
	LXI	H,0
	LXI	D,1	;DELAY VALUE
;
SLO:	DAD	D	;ADD ONE
	JNC	SLO	;NO CARRY YET, COUNT MORE
;
;Get new baud rate, then return to CP/M
	CALL	CHANGE	;CHANGE TO NEW BAUD RATE
	LHLD	STACK	;GET OLD STACK POINTER
	SPHL		;RESTORE IT
	RET		;RETURN TO CP/M
;
;Read the modem at different baud rates until a CR is found
;
CHANGE:	IN	DPORT	 ;CLEAR ANY GARBAGE FROM MODEM PORT
	IN	DPORT	 ;CLEAR IT TWICE JUST TO BE SURE
;
;
	IF	PMMI
	MVI	A,B110	 ;SELECT 110 BAUD INITIALLY
	OUT	RPORT	 ;SET BAUD RATE IN MODEM
	MVI	A,P0110  ;SELECT 8 DATA, NO PARITY, 2 STOP BITS FOR 110 BAUD
	OUT	TPORT
	MVI	A,7FH	 ;SET MODEM FILTER FOR <300
	OUT	CPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 110
;
	IF	LSPEED
	MVI	A,0	 ;store a 0 for 110 baud
	STA	MSPEED
	ENDIF
;
	RZ		 ;YES, EXIT
;
	MVI	A,P0NORM ;SET FOR 1 STOP BIT, ETC., FOR >110 BAUD
	OUT	TPORT
	MVI	A,B300	 ;SET MODEM TO 300 BAUD
	OUT	RPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 300
;
	IF	LSPEED
	MVI	A,1	 ;store a 1 for 300 baud
	STA	MSPEED
	ENDIF
;
	RZ		 ;YES, EXIT
;
	MVI	A,B450	 ;SET MODEM TO 450 BAUD
	OUT	RPORT
	MVI	A,5FH	 ;SET MODEM FILTER FOR >300
	OUT	CPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 450
;
	IF	LSPEED
	MVI	A,2	 ;store a 2 for 450 baud
	STA	MSPEED
	ENDIF
;
	RZ		 ;YES, EXIT
;
	MVI	A,B600	 ;SET MODEM TO 600 BAUD
	OUT	RPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 600
;
	IF	LSPEED
	MVI	A,3	 ;store a 3 for 600 baud
	STA	MSPEED
	ENDIF
;
	RZ		 ;YES, EXIT
;
	MVI	A,B710	 ;SET MODEM TO 710 BAUD
	OUT	RPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 710
;
	IF	LSPEED
	MVI	A,4	 ;store a 4 for 710 baud
	STA	MSPEED
	ENDIF
;
	RZ		 ;YES, EXIT
;
	ENDIF
;
	IF WD8250
TST110	PUSH	D
	MVI	D,BR110MS
	MVI	E,BR110LS
	IF	LSPEED
	MVI	A,0
	STA	MSPEED
	ENDIF
	CALL	SETBAUD
	POP	D
	CALL	TSTBAUD
	JNZ	TST300
	CALL	TSTBAUD
	RZ

TST300	PUSH	D
	MVI	D,BR300MS
	MVI	E,BR300LS
	IF	LSPEED
	MVI	A,1
	STA	MSPEED
	ENDIF
	CALL	SETBAUD
	POP	D
	CALL	TSTBAUD
	JNZ	TST450
	CALL	TSTBAUD
	RZ

TST450	PUSH	D
	MVI	D,BR450MS
	MVI	E,BR300LS
	IF	LSPEED
	MVI	A,2
	STA	MSPEED
	ENDIF
	CALL	SETBAUD
	POP	D
	CALL	TSTBAUD
	JNZ	TST600
	CALL	TSTBAUD
	RZ

TST600	PUSH	D
	MVI	D,BR600MS
	MVI	E,BR600LS
	IF	LSPEED
	MVI	A,3
	STA	MSPEED
	ENDIF
	CALL	SETBAUD
	POP	D
	CALL	TSTBAUD
	JNZ	TST1200
	CALL	TSTBAUD
	RZ

TST1200	PUSH	D
	MVI	D,BR120MS
	MVI	E,BR120MS
	IF	LSPEED
	MVI	A,5
	STA	MSPEED
	ENDIF
	CALL	SETBAUD
	POP	D
	CALL	TSTBAUD
	JNZ	CHANGE
	CALL	TSTBAUD
	RZ
	JMP	CHANGE	 ;KEEP TRYING UNTIL CR IS FOUND
;
SETBAUD	MVI	A,0
	OUT	DPORT+1
	MVI	A,10H
	OUT	CPORT
	MVI	A,80H
	OUT	LPORT
	MOV	A,E	;GET LSB
	OUT	DPORT
	MOV	A,D	;GET MSB
	OUT	DPORT+1
	CPI	4
	JNZ	ONSTOP
	MVI	A,07H
	OUT	LPORT
	JMP	DLOOP
ONSTOP:	MVI	A,03
	OUT	LPORT
DLOOP	XCHG		;PUT DIVISOR IN HL
	DAD	H !DAD H !DAD H !DAD H ;MULTIPLY BY 16
;					SO WE DELAY APPROX 2 CHARS TIMES
DLOOP1	DCX	H
	MOV	A,L
	ORA	H
	JNZ	DLOOP1
	XCHG
	MVI	A,1
	OUT	CPORT
	IN	DPORT
	IN	DPORT
	RET
;
TSTBAUD	CALL	CONIN	;GET CHARACTER FROM MODEM
	CPI	CR	;IF A CARRAIAGE RETURN...
	RZ		;..	RETURN
	CPI	LF	;IF A LINEFEED...
	RZ
	CPI	'C'-40H ;IF A CONTROL C
	RET		;RET ZERO FLAG, ELSE NOT ZERO
;
	ENDIF
;
	IF PMMI
;TSBAUD reads one character from console input and returns
;with the zero flag set if the character is a CR.
;
TSBAUD:	CALL	CONIN	;GET CHARACTER DIRECT FROM CONSOLE
	CPI	CR	;SET ZERO FLAG IF CHARACTER IS CR
	RET		;THEN RETURN
	ENDIF
;
;This routine does a direct console input without echo
;
CONIN:	LHLD	1	;GET CBIOS VECTOR
	LXI	D,6	;ADD OFFSET TO CONIN VECTOR
	DAD	D	;HL NOW = CONIN VECTOR
	PCHL		;GO THERE
;
MSG:	DB	CR,LF,'NEWBAUD ver 2.2 - '
	DB	'Change to new Baud rate,',CR,LF
	DB	'THEN type RETURNs until the system responds.'
	DB	CR,LF,LF,'$'
;
;Temporary storage
;
	DS	60	;ROOM FOR STACK
STACK:	DS	2	;OLD STACK SAVED HERE
;
	END	START
