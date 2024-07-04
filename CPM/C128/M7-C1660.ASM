	title	'M7-C1660 (MDM) C1660 and C1650 overlay for C128   31 Oct 85'


; M7-C1660.ASM -- Commodore 128 overlay file for MDM7xx.
;
; overlay setup by Von Ertwine for C128 using 1650 or 1660 modem
;	10/31/85
;
;	The default modem type (1650 or 1660) can be setected by
;	setting parmater at 15Ch (modem$type)
;
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

bit	macro	?N,?R
	db	0cbh,?N*8+?R+40h
	endm

exx	macro
	db	0D9h
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

cpir	macro
	db	0edh,0b1h
	endm

	page

		ORG	100H

		DS	3	;(for  "JMP   START" instruction)
;
PMMIMODEM:	DB	NO	;yes=PMMI S-100 Modem			103H
SMARTMODEM:	DB	yes	;yes=HAYES Smartmodem, no=non-PMMI	104H
TOUCHPULSE:	DB	'P'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	17	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
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
BAKUPBYTE:	DB	no	;yes=change any file same name to .BAK	10EH
CRCDFLT:	DB	YES	;yes=default to CRC checking		10FH
TOGGLECRC:	DB	YES	;yes=allow toggling of CRC to Checksum	110H
CONVBKSP:	DB	no	;yes=convert backspace to rub		111H
TOGGLEBK:	DB	YES	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	YES	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGGLELF:	DB	YES	;yes=allow toggling of LF after CR	114H
TRANLOGON:	DB	YES	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
LOCONEXTCHR:	DB	no	;yes=local command if EXTCHR precedes	117H
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
		DS	2		; used by PMMI					128H
IN$MODCTL1:				; get the status bits		12AH
	lda	on$hook$flag
	ora	a
	jz	read$status		; return modem status if off hook
	jmp	modem$ring$test		; test modem? ringing
;
;
;
OUT$MODDATP:				;out modem data port		134H
	push	psw
	lda	on$hook$flag		; 0FFh=on hook, 0=off hook
	ora	a
	jrz	modem$out$cont		; send to modem if off hook
	jmp	modem$cmd		; modem command if on hook

IN$MODDATP:				; in modem data port		13EH
	lda	recv$data
	push	h
	lxi	h,RS232$status
	jmp	in$moddtp$cont

ANI$MODRCVB:	ANI	MODRCVB	! RET	; bit to test for receive ready	148H
CPI$MODRCVR:	CPI	MODRCVR ! RET	; value of receive bit when rdy	14BH
ANI$MODSNDB:	ANI	MODSNDB	! RET	; bit to test for send ready	14EH
CPI$MODSNDR:	CPI	MODSNDR	! RET	; value of send bit when ready	151H

;	PMMI Modem Vectors (not used by C128)
		DS	6		;				154H

OUT$MODCTL1:	ret			; out modem control port 	15AH
on$hook$flag:	db	yes		; yes=0FFh=on hook, no=00=off hook
modem$type:	db	0ffh		; 0ffh=1660(no DTR) 0feh=1660(DTR)
					; 000h=1650			15CH
OUT$MODCTL2:	ret  !  nop  !  nop	; out modem status port		15DH
LOGONPTR:	DW	LOGON		; for user message.		160H
jmp$dial	ds	3		;				162H
;jmp$disconnect	ds	3		;				165H
		ret			;				165H
data$format:	db	1		; number bits and parity
					; 7 bits add 0, 8 bits add 1
					; None=0, Odd=E0, Even=C0
					; Mark=A0, Space=80
		db	0		; not used
JMP$GOODBYE:	JMP	GOODBYE		;				168H
JMP$INITMOD:	JMP	INITMOD		; go to user written routine	16BH
		RET  !	NOP  !	NOP	; (by-passes PMMI routine)	16EH
		RET  !	NOP  !	NOP	; (by-passes PMMI routine)	171H
		RET  !	NOP  !	NOP	; (by-passes PMMI routine)	174H
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
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  Last entry must be 0.  Any other 0's act as NOP's.
;
CLREOS:
	CALL	JMP$ILPRT		;				195H
	DB	esc,'Y',eom
SPCLMENU:
	ret
	db	0,0
;
CLRSCRN:
	CALL	JMP$ILPRT		;				19EH
	DB	'Z'-40h,eom
	ret
modem$out$cont:
	jmp	modem$out		
;
;
;
SYSVER:
	CALL	JMP$ILPRT		;				1A7H
	db	'C-128 Ver. for 1650 or 1660',cr,lf,eom
	RET
;.....
;
;
;-----------------------------------------------------------------------
;
; NOTE:  You can change the SYSVER message to be longer or shorter.  The
;	 end of your last routine should terminate by 0400H 
;
;-----------------------------------------------------------------------
;
;
;
in$moddtp$cont:
	res	0,m
	pop	h
	ret
;
;
modem$out:
	pop	psw
	sta	xmit$data
	push	h
	lxi	h,RS232$status
	setb	7,m
	pop	h
	ret
;
;
;
modem$ring$test:
	exx				; save HLDEBC
	lxi	b,data$port$b
	inp	a
	bit	3,a			; ring indicator bit (active low)
	jrnz	ring$cont
recieved$carrier:
	xri	20h			; toggle on/off hook bit
	outp	a			; take off hook
	mvi	a,no			; set phone off hook
	sta	on$hook$flag
	lda	modem$type		; LSB=0 if suports DTR
	ani	1			; =1 if no support
	mov	l,a
carrier$yet:
	dcr	l			; 1st time =0ffh if no support
	jrz	ring$cont
	inp	a
	ani	10h			; test if carrier present
	jrz	ring$cont		; 
	call	delay			; delay .16 seconds
	jr	carrier$yet		; will wait .16*255 = 40.8 seconds
;
;
;
read$status:
	lda	modem$type		; LSB=0 if suports DTR
	ani	1
	jrnz	read$status$cont
	exx				; save HLDEBC
	lxi	b,data$port$B
	inp	a
	ani	10h			; test if carrier present
	cnz	phone$on$hook		; lost carrier, hang up the phone
ring$cont:
	exx				; restore HLDEBC
read$status$cont:
	lda	RS232$status
	ret

;
;
intersept$inmodem:
	mvi	a,00
	ora	a
exit$intersept:
	jz	0000			; address filled in by INIT
	exx				; save HLDEBC
	lxi	h,RS232$status
	setb	0,m			; set data advaliable flag
	mvi	l,low(recv$data)	; point to recv$data
	mov	m,a
	exx				; restore HLDEBC
	xra	a
	sta	intersept$inmodem+1	; set no intersept
	stc				; tell caller 'no input data'
	ret
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBYE:  				; TURN OFF DTR
	push	b
	call	phone$on$hook		; hang-up the phone
	ani	not(6)			; clear DTR bit
	outp	a
	call	sendbrk			; send 300ms break
	inp	a
	ori	6
	outp	a			; set DTR
	pop	b
	ret
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SENDBRK: 
	di
	push	b
	lxi	b,data$port$a
	inp	a
	ani	0FBh			; send a break tone will be cleared
	outp	a			; ..when interrupts turned on
	pop	b
	mvi	a,30			; WAIT FOR 300 MS.
	jmp	delay			; re-enables interrupts and returns
;
; Setup routine to allow changing modem speed with the SET command.
;
SETUPR:
	CALL	JMP$ILPRT
	DB	'Modem (1650,1660) ',0
	call	read$buffer
	CALL	JMP$INLNCOMP		; compare to  BAUDBUF+2
	DB	'1650',0
	mvi	l,0
	jrnc	set$type		; Cy=0 if match
	CALL	JMP$INLNCOMP		; compare to BAUDBUF+2 
	DB	'1660',0
	jrc	setupr
test$carrier:
	CALL	JMP$ILPRT
	DB	'Support carrier detect (Y,N) ',eom
	call	read$buffer
	ldax	d
	dcr	l			; L=0FFh=1660 modem without
	cpi	'N'
	jrz	set$type		; ..carrier detect
	cpi	'Y'
	jrnz	test$carrier
	dcr	l			; L=0FEh=1660 modem with
set$type:				; ..carrier detect
	mov	a,l
	sta	modem$type
	lda	on$hook$flag		; =FF if on hook
	ora	a
	rz				; hang-up the phone (only if on hook)
;
;
;
phone$on$hook:
	mvi	a,yes
	sta	on$hook$flag
	lxi	b,data$port$b
	lda	modem$type		; 0fxh=1660, 000h=1650
	ora	a
	jrz	type$1650
;	
type$1660:
	inp	a
	ori	20h			; set, phone on hook (1660)
	jr	on$hook$cont
;
type$1650:
	inp	a
	ani	not(20h)		; set, phone on hook (1650)
on$hook$cont:
	outp	a
	ret

;	
; C128 initialization -- set baudrate.
;
INITMOD:
	lda	data$format		; set number bits and parity
	sta	XxD$config

	mvi	e,3ch			; offset to jmp devtbl
	call	vector$1		; rets HL=char device table start
	lxi	d,dev$no*8+7		; offset to RS232 baud rate
	dad	d			; point to RS232 baud rate byte
	mvi	m,6			; change baud rate to 300
	mvi	c,dev$no		; init RS232 baud rate
	mvi	e,3fh			; offset to jmp ?cinit (change
	call	vector$1		; ..the rate)

	lxi	b,data$port$b$dir
	mvi	a,26h			; set data dir to output
	outp	a
	call	phone$on$hook
	ori	6			; set DTR and CTS (active hi)
	outp	a

	lhld	jmp$inmodem+1
	shld	exit$intersept+1
	lxi	h,intersept$inmodem
	shld	jmp$inmodem+1
	mvi	a,(RET)
	sta	initmod
	ret

vector$1:
	lhld	01
	mov	l,e
	pchl


;
;
;
read$buffer:
	LXI	D,BAUDBUF		; POINT TO INPUT BUFFER
	CALL	JMP$INBUF
	inx	d
	inx	d
	ret
;
;
;
BAUDBUF:
	DB	6,0
	DS	6
;
;
;
modem$cmd:
	pop	psw
	exx				; save HLDEBC
next$dial$state	equ	$+1
	call	dial$state$A
	exx				; restore HLDEBC
	ret

dial$state$A:
	cpi	'A'
	call	set$next$state$test
	cpi	'T'
	call	set$next$state$test
	cpi	'D'
	call	set$next$state$test
	cpi	'P'
	call	set$next$state$test

; 'A' will be a space at this point "ATDP 1234567"
	lxi	b,data$port$b
	inp	a
	xri	20h			; take phone off the hook
	outp	a			; take phone off hook
	mvi	a,200
	call	delay			; delay 2 seconds
	call	set$next$state

	cpi	cr
	jrz	done$dialing
	cpi	','
	jrz	delay$1$sec
not$comma:
	sui	'0'
	jrc	abort$dial
	jrnz	not$10
	mvi	a,10
not$10:
	cpi	10+1
	jrnc	abort$dial
	mov	d,a
;
;	dial number in D
;
dial$digit:
	lxi	b,data$port$b		; point to CIA
	di
	inp	a			; get phone off hook value
	mov	e,a
dial$digit$cont:
	xri	20h			; toggle dial port bit
	outp	a			; output phone on hook value
	mvi	a,6
	call	delay			; delay 0.06 seconds
	outp	e			; phone back off hook
	mvi	a,4
	call	delay			; delay 0.04 seconds
	mov	a,e
	dcr	d
	jrnz	dial$digit$cont
delay$1$sec:
	mvi	a,100			; delay 1 second
;
;	delay for the number of 0.01 seconds in A
;		20,455 T states per 10 mSecond
; 4+10+7ah+7ahl+4ahl+12ahl-5ah+4ah+12ah-5a+4a+12a-5+10+4+10=23ahl+18ah+11a+29
;	if H=19, L=46 then
;		# T states = 20455a+33
delay:
	di				;4
	push	h			;10
delay$more:
	mvi	h,19			;7ah
outer$delay:
	mvi	l,46			;7ahl
inter$delay:
	dcr	l			;4ahl
	jrnz	inter$delay		;12ah(l-1)+7ah = 12ahl-5ah
	dcr	h			;4ah
	jrnz	outer$delay		;12a(h-1)+7a = 12ah-5a

	dcr	a			;4a
	jrnz	delay$more		;12(a-1)+7 = 12a-5
	pop	h			;10
	ei				;4
	ret				;10
;
;
;
set$next$state$test:
	jrz	set$next$state
	pop	h
set$start$state:
	lxi	h,dial$state$A
	push	h
set$next$state:
	pop	h
	shld	next$dial$state
	ret
;
;
;
done$dialing:
	lda	modem$type
	ani	1			; lsb=0 if it supports carrier detect
	jrnz	send$C$responce
	lxi	h,45000
wait$carrier:
	lxi	b,data$port$b
	inp	a
	ani	10h
	jrz	send$C$responce
	mvi	c,6			; direct console I/O
	mvi	e,0ffh			; input data/status
	push	h
	call	5
	pop	h
	cpi	'X'-40h			; test for ^X
	jrz	abort$dial
	dcx	h
	mov	a,h
	ora	l
	jrnz	wait$carrier
abort$dial:
	mvi	a,'N'			; send NO CARRIER to MDM7XX
	db	21			; LXI H,(MVI A,'C')
send$C$responce:
	mvi	a,'C'			; send CONNECT message to MDM7XX
send$responce:
	lxi	h,on$hook$flag
	mvi	m,no
send$responce$error:
	sta	intersept$inmodem+1
	jr	set$start$state

;
; You can put in a message at this location which can be called up with
; CTL-L if TRANLOGON has been set TRUE.  You can put in several lines if
; desired.  End with a 0.
;
LOGON:		DB	'C128 running MDM7x0 under CP/M Plus',CR,LF,eom
;
;
;
; NOTE:  MUST TERMINATE PRIOR TO 0400H (with Smartmodem)
;
	  END
;
