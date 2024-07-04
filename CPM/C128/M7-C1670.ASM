
	title	'M7-C1670 (MDM) 1670 or HAYES overlay for C128     31 Oct 85'

; M7-C1670.ASM -- Commodore 128 overlay file for MDM7xx.
;
; overlay setup by Von Ertwine for C128 using 1670 modem
; or the 1011A (RS232 converter)
;	10/31/85
;
;	build new system by using to following:
;
;	MAC M7-C1670 $pz-s
;	MLOAD MDM7x0.com=MDM7x0.COM,M7-C1670.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =

	page

$*MACRO		; only show code produced by MAC not MACRO expansion


;
eom		equ	00h		; end of message
bell		equ	07h		; bell
lf		equ	0Ah		; linefeed
cr		equ	0Dh		; carriage return
esc		equ	1Bh		; escape

no		equ	0
yes		equ	not(no)

	page
;
;	C128 info
;
dev$no:		equ	6
XxD$config:	equ	0fd4Eh
;		bit 7	0=no parity	1=parity
;		bit 6	0=mark/space	1=odd/even
;		bit 5	0=space/even	1=mark/odd
;		bit 1	0=1 stop bit	1=2 stop bits
;		bit 0	0=7 data bits	1=8 data bits
RS232$status:	equ	XxD$config+1
;		bit 7	1=send data, 0=no data
;		bit 6	1=sending data now
;		bit 5	1=recv que active
;		bit 4	1=parity error
;		bit 3	1=framing error
;		bit 2	not used
;		bit 1	receiving data now
;		bit 0	data byte ready
xmit$data:	equ	RS232$status+1
recv$data:	equ	xmit$data+1
;
MODRCVB:	EQU	01H		; bit to test for receive
MODRCVR:	EQU	01H		; value when receive ready
MODSNDB:	EQU	80H		; bit to test for send
MODSNDR:	EQU	00H		; value when send ready		

data$port$a	equ	0DD00h
;		bit 2	TxD Data (output)

data$port$b	equ	data$port$a+1
data$port$b$dir	equ	data$port$b+2
;		bit 7	Data Set Ready (input)
;		bit 6	Clear to Send (input)
;		bit 5	Place Phone On Hook (active low output)
;		bit 4	Carrier Detect (active low input)
;		bit 3	Ring Indicator (active low input)
;		bit 2	Data Terminal Ready (active hi output)
;		bit 1	Request to Send (active hi output)
;		bit 0	Received Data (input)

	page
;
setb	macro	?N,?R
	db	0cbh,?N*8+?R+0C0h
	endm

res	macro	?N,?R
	db	0cbh,?N*8+?R+80h
	endm

@chk	macro	?DD
	if (?DD GT 7Fh) and (?DD LT 0FF80h)
	'Displacement Error'
	endif
	endm

jr	macro	?N
	db	18h,?N-$-1
	@chk	?N-$
	endm

jrz	macro	?N
	db	28h,?N-$-1
	@chk	?N-$
	endm

jrnz	macro	?N
	db	20h,?N-$-1
	@chk	?N-$
	endm

jrc	macro	?N
	db	38h,?N-$-1
	@chk	?N-$
	endm

jrnc	macro	?N
	db	30h,?N-$-1
	@chk	?N-$
	endm

inp	macro	?R
	db	0EDh,?R*8+40h
	endm

outp	macro	?R
	db	0EDh,?R*8+41h
	endm

	page

		ORG	100H

		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	yes	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	11	;clock speed in MHz x10, 25.5 MHz max.	106H
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
SETUPTST:	DB	YES	;yes=user-added Setup routine		10BH
SCRNTEST:	DB	yes	;Cursor control routine 		10CH
ACKNAK:		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKUPBYTE:	DB	yes	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	no	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	YES	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	no	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
TOGGLELOC:	DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	no	;yes=printer available on printer port	119H
XOFFTST:	DB	YES	;yes=check for XOFF from remote	while	11AH
				;sending a file in terminal mode
XONWAIT:	DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOFF:	DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNORCTL:	DB	no	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXTRA2:		DB	0	;for future expansion			11FH
BRKCHR:		DB	'V'-40H	;^V(^@) = Send a 300 ms. break tone	120H
NOCONNCT:	DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRANCHR:	DB	'T'-40H ;^T = Transmit file to remote		125H
SAVECHR:	DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'O'-40H	;^O(^^) = Send next character		127H
;
;
		DS	2	; used by PMMI					128H
IN$MODCTL1:			; get the status bits			12AH
	lda	RS232$status
	ret
;
; TABLE OF BAUDRATE PARAMETERS
;
BAUD$TABLE:
	db	0	; 0	110	(not used)
	db	6	; 1	300
	db	0	; 2	450	(not used)
	db	7	; 3	600
	db	0	; 4	710	(not used)
	db	8	; 5	1200
;
;
;
OUT$MODDATP:				;out modem data port		134H
	sta	xmit$data
	push	h
	lxi	h,RS232$status
	jmp	out$c128$cont

IN$MODDATP:				;in modem data port		13EH
	lda	recv$data
	push	h
	lxi	h,RS232$status
	jmp	in$c128$cont

ANI$MODRCVB:	ANI	MODRCVB	! RET	;bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	;bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	;value of send bit when ready	151H

;	PMMI Modem Vectors (not used by C128)
;		DS	6		;				154H
;
;	used for C128 (no PMMI modem)  (6 bytes)
;
out$c128$cont:				;				154H
	setb	7,m
	db	21h			; LXI	H,(res 0,m)
;
in$c128$cont:				;				157H
	res	0,m
	pop	h

OUT$MODCTL1:	ret ! nop ! nop		;out modem control port 	15AH
OUT$MODCTL2:	ret ! nop ! nop		;out modem status port		15DH

;
LOGONPTR:	DW	LOGON		;for user message.		160H
jmp$dial	ds	3		;				162H
jmp$disconnect	ds	3		;				165H
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
JMP$INBUF:	DS	3		;				186H
JMP$INLNCOMP:	DS	3		;				189H
JMP$INMODEM	DS	3		;				18CH
JMP$NXTSCRN:	DS	3		;				18FH
JMP$TIMER:	DS	3		;				192H
;
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:
	CALL	JMP$ILPRT		;				195H
	DB	esc,'Y',eom
SPCLMENU:
	ret
	db	0,0			;				19DH
;
CLRSCRN:
	CALL	JMP$ILPRT		;				19EH
	DB	'Z'-40h,eom
	ret
	db	0,0,0			;				1A6H

;
;
;
SYSVER:
	CALL	JMP$ILPRT		;				1A7H
	DB	'C-128 Ver. for 1670 or 1011A ',cr,lf,eom
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
;.....
;
;	
; C128 initialization -- set baudrate.
;
INITMOD:
	mvi	a,1			; set default to 8 bits no parity
	sta	XxD$config
	call	set$default		; set default to 1200 baud
	lxi	b,data$port$b$dir
	mvi	a,6h
	outp	a
	mvi	c,low(data$port$b)
	inp	a
	ori	6			; set DTR bit (active hi)
	outp	a
	ret
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBYE:  				; TURN OFF DTR
	push	b
	lxi	b,data$port$b
	inp	a
	ani	not(6)			; clear DTR and CTS bits
	outp	a
	call	sendbrk			; send 300ms break
	inp	a
	ori	6			; set DTR and CTS bits
	outp	a
	pop	b
	mvi	a,6			; set BAUD RATE back to 300
	jmp	reset$baud		; ..so the system runs faster
					; call/ret
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SENDBRK: 
	di				; system will run faster without
	push	b			; ..interrupts
	lxi	b,data$port$a
	inp	a
	ani	0FBh			; send a break tone will be cleared 
	outp	a			; ..when interrupts turned on
	mvi	b,3			; WAIT at least 300 MS.
	call	jmp$timer		; ..(system running fast)
	pop	b
	ei				; re-enable interrupts. will 
	ret				; ..clear break.
;
; Setup routine to allow changing modem speed with the SET command.
;
SETUPR:
	CALL	JMP$ILPRT		; the 1011A is an RS232 card
	DB	'Device Type (1670,1011A) ',0
	call	read$buffer
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2 
	DB	'1011',0
	jnc	set$1011		; Cy=0 if match
	CALL	JMP$INLNCOMP		; compare to  BAUDBUF+2 
	DB	'1670',0
	jrc	setupr
set$T$P:
	call	JMP$ILPRT
	db	'Touch or Pulse (T,P) ',0
	call	read$buffer
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2 
	DB	'T',0
	lxi	h,'T'*256+YES
	jrnc	set$rate
	CALL	JMP$INLNCOMP		; compare to  BAUDBUF+2
	DB	'P',0
	jrc	set$T$P
set$pluse:
	lxi	h,'P'*256+YES
set$rate:
	shld	SMARTMODEM		; L=smartmodem, H=touch/pluse
	mvi	a,1
	sta	XxD$config		; set 8 bits no parity
set$rate$loop:
	CALL	JMP$ILPRT
	DB	'Baud Rate (300,1200) ',0
	call	read$buffer
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2 
	DB	'300',0
	lxi	h,17+100h		; clock=1.7, mspeed=1
	JRNC	set$baud		;
	CALL	JMP$INLNCOMP
	DB	'600',0
	lxi	h,15+300h		; clock=1.5, mspeed=3
	JRNC	set$baud
	CALL	JMP$INLNCOMP
	DB	'1200',0
	JRC	set$rate$loop
set$default:
	lxi	h,11+500h		; clock=1.1, mspeed=5
;
set$baud:
	shld	CLOCK			; L=CLOCK, H=MSPEED
	mov	e,h
	MVI	D,0
	LXI	H,BAUD$TABLE
	DAD	D
	MOV	A,M			; get BAUD RATE byte
reset$baud:
	push	psw
	mvi	e,3ch			; offset to jmp devtbl
	call	vector$1		; rets HL=char device table start
	lxi	d,dev$no*8+7		; offset to RS232 baud rate
	dad	d			; point to RS232 baud rate byte
	pop	psw
	mov	m,a			; change baud rate

	mvi	c,dev$no		; init RS232 baud rate
	mvi	e,3fh			; offset to jmp ?cinit
vector$1:
	lhld	01
	mov	l,e
ipchl:	pchl				; (call/ret)



set$1011:
	lxi	h,'P'*256+NO
	call	set$rate
set$num$bits:
	CALL	JMP$ILPRT
	DB	'Number Bits (7,8) ',0
	call	read$buffer
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2
	DB	'7',0
	mvi	l,0
	JRNC	set$7			; MATCH found
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2
	DB	'8',0
	JRC	set$num$bits		; wait for valid input
	inr	l			; L=1
set$7:
bad$parity:
	CALL	JMP$ILPRT
	DB	'Parity  (None,Odd,Even,Mark,Space) ',0
	call	read$buffer
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2
	DB	'N',0
	mvi	a,00000000b
	JRNC	set$parity		;
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2
	DB	'O',0
	mvi	a,11100000b
	JRNC	set$parity		;
	CALL	JMP$INLNCOMP		; compare to  BAUDBUF+2
	DB	'E',0
	mvi	a,11000000b
	JRNC	set$parity		;
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2
	DB	'M',0
	mvi	a,10100000b
	JRNC	set$parity		;
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2
	DB	'S',0
	JRC	bad$parity		;
	mvi	a,10000000b
set$parity:
	ora	l			; add in the number of bits
	sta	XxD$config
	ret



read$buffer:
	LXI	D,BAUDBUF		; point to new input buffer
	CALL	JMP$INBUF
	inx	d
	inx	d
	ret
;
;
;
BAUDBUF:
	DB	10,0
	DS	10

; You can put in a message at this location which can be called up with
; CTL-O if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
;
LOGON:
	DB	' C128 running MDM under CP/M 3.0 ',CR,LF,0
;

;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;				 0C00H (without Smartmodem)
;
	  END
;
