


	title	'MXO-C128.ASM -- Commodore 128 overlay for MEX   19 Nov 85'

$*MACRO		; only show code produced by MAC not MACRO expansion

;
; You will want to look this file over carefully. There are a number of
; options that you can use to configure the program to suit your taste.
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
; Use the "SET" command to change the baudrate when desired.  It starts
; out at 1200 baud when the program is first called up.
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
; 11/13/85 - MEXified overlay - Von Ertwine
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
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
MODRCVB:	equ	01H		; bit to test for receive
MODRCVR:	equ	01H		; value when receive ready
MODSNDB:	equ	80H		; bit to test for send
MODSNDR:	equ	00H		; value when send ready		

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
; MEX service processor stuff
;
MEX	EQU	0D00h		;address of the service processor
ESCCHR	EQU	0D1Fh		;Terminal Mode escape char (1Bh=ESC)
XSIZE	EQU	0D23h		;transfer buffer size
QUEUE	EQU	0D51h		;enable/disable queueing (1/0)
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a character to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
;
PRINT	EQU	9		;MEX/BDOS print-string function call

	page
;
bit	macro	?N,?R
	db	0cbh,?N*8+?R+040h
	endm

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

	org	100h
;
;
; Change the clock speed to suit your system
;
		DS	3	;(for  "JMP   START" instruction)
;
local$config:	db	01h	; default to 8 bit no parity 1 stop	103H
mdm$tp:		db	8Ah	; bit	(default 1670 with 1200 or 300) 104H
				; 7	(1670 if set)
				; 6	(1650 or 1660 if set)
				; 5	(1660 if set)
				; 4	(supports CD if clear {1650,1660})
				; 3	(set if 1200 baud is supported)
				; 2	(set if  600 baud is supported)
				; 1	(set if  300 baud is supported)
				; 0	(set if  110 baud is supported)

TPULSE:		DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	13	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFLG:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES	;Cursor control routine 		10CH
		DB	YES	;yes=resend a record after any non-ACK	10DH
				;no=resend a record after a valid NAK
BAKFLG:		DB	NO	;yes=change any file same name to .BAK	10EH
CRCDFL:		DB	YES	;yes=default to CRC checking		10FH
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	no	;yes=convert backspace to rub		111H
TOGLBK:		DB	yes	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	yes	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
		DB	NO	;yes=allow transmission of logon	115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
		DB	NO	;yes=local command if EXTCHR precedes	117H
				;no=external command if EXTCHR precedes
		DB	YES	;yes=allow toggling of LOCONEXTCHR	118H
LSTTST:		DB	no	;yes=allow toggling of printer on/off	119H
XOFTST:		DB	YES	;yes=chcks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	no	;yes=CTL-chars above ^M not displayed	11DH
EXTRA1:		DB	0	;for future expansion			11EH
EXITCHR:	DB	'E'-40H	;^E = Exit to main menu			11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRNCHR:		DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:		DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
INCTL1:
	lda	RS232$status	;get the status bits			12Ah
	ret
show$baud:			;					12Eh
	jmp	disp$rate	;display current baud rate
	ds	3
;
OTDATA:				;out modem data port			134H
	sta	xmit$data
	push	h
	lxi	h,RS232$status
	jmp	out$c128$cont

INPORT:				;in modem data port			13EH
	lda	recv$data
	push	h
	lxi	h,RS232$status
	jmp	in$c128$cont

MASKR:	ani	modrcvb		;bit to test for receive ready		148H
	ret
TESTR:	cpi	modrcvr		;value of receive bit when rdy		14BH
	ret
MASKS:	ani	modsndb		;bit to test for send ready		14EH
	ret
TESTS:	cpi	modsndr		;value of send bit when ready		151H
	ret

	ds	6		;					154H
OUTMODCT1:
	ret ! nop ! nop		;out modem control port 		15AH
OUTMODCT2:
	ret ! nop ! nop		;out modem status port			15DH
;
;
	DS	2		;Not used by MEX			160H
	DS	6		;					162H
GOODBV:	JMP	GOODBY		;					168H
INMODV:	JMP	NITMOD		;go to user written routine		16BH
NEWBDV:	JMP	NEWBAUD		;Change baudrate			16EH
	RET  !	NOP  !	NOP	;(by-passes PMMI routine)		171H
	RET  !	NOP  !	NOP	;(by-passes PMMI routine)		174H
SETUPV:	JMP	SETCMD		;					177H
	DS	3		;					17AH
VERSNV:	JMP	SYSVER		;					17DH
BREAKV:	JMP	SBREAK		;					180H
;
;
; Do not change the following six lines.
;
ILPRTV:	DS	3		;					183H
INBUFV:	DS	3		;					186H
ILCMPV:	DS	3		;					189H
INMDMV:	DS	3		;					18CH
	DS	3		;					18FH
TIMERV:	DS	3		;					192H
;
; Clear sequences -- CLREOS is clear to end of screen, CLRSCRN is clear
; entire screen.  
;
CLREOS:
	mvi	c,ILP
	call	mex
	db	esc,'Y',eom
	RET			
;
CLS:
	mvi	c,ILP
	call	mex
	db	'Z'-40h,eom
	ret			
	nop
;
;
SYSVER:
	mvi	c,ILP		;				1A7H
	call	mex
	db	'Version for Commodore 128'
	db	cr,lf,eom
	ret
;
;
out$c128$cont:
	setb	7,m
	pop	h
	ret
;
;
in$c128$cont:
	res	0,m
	pop	h
	ret

	page
;
;
; This routine allows a 300 ms. break tone to be sent to reset some
; time-shar computers.
;
SBREAK:
	lda	rs232$status
	ani	01000010b		; any RS232 activity now?
	jrnz	SBREAK			; yes, wait until done.
	di				; prevent intterupts from
	push	b			; ..resetting break
	lxi	b,data$port$a
	inp	a
	ani	0FBh			; send a break tone will be cleared
	outp	a			; ..when interrupts turned on
	mvi	b,8			; time flies with-out intterrupts on
	mvi	c,TIMER
	call	mex
	pop	b
	ei
	ret
;
; This routine sends a 300 ms. break tone and sets DTR low for the same
; length of time to disconnect some modems such as the Bell 212A, etc.	
;
GOODBY:  				; TURN OFF DTR
	push	b
	lxi	b,data$port$b
	inp	a
	ani	not(6)			; clear DTR and CTS bits
	outp	a
	call	sbreak			; send 300ms break
	inp	a
	ori	6			; set DTR and CTS bits
	outp	a
	pop	b
	mvi	a,6			; set back to 300 baud
	jmp	reset$baud		; ..so system does not run slow
	; call/ret

	page
;
; C128 initialization -- set baudrate.
;
NITMOD:
	lda	local$config		; set default to 8 bits no parity
	sta	XxD$config
	lda	mspeed
	call	new$baud		; set default BAUD rate
	lxi	b,data$port$b$dir
	mvi	a,6
	outp	a
	mvi	c,low(data$port$b)
	inp	a
	ori	6			; set DTR and CTS bits (active hi)
	outp	a
	ret

	page
;
; Setup routine to allow changing modem speed with the SET command.
;
SETCMD:
	mvi	c,SBLANK		; Any arguments?
	call	mex
	jrc	tell			; If not, go display baud
	lxi	d,cmdtbl
	mvi	c,LOOKUP
	call	mex			; Parse argument
	cnc	ipchl			; If we have one, go set it
;
tell:
	push	psw			; save carry flag
	call	disp$rate
	pop	psw			; recover carry flag 
	jrnc	skip$tell$baud		; ..(prt following if Cy=1)
	mvi	c,ILP
	call	mex			; Print current baud rate
	db	cr,lf,'The following '
	db	'Baud rate(s) are legal: ',eom

	mvi	b,1
	call	prt$rate
	db	'110 ',eom
	mvi	b,2
	call	prt$rate
	db	'300 ',eom
	mvi	b,4
	call	prt$rate
	db	'600 ',eom
	mvi	b,8
	call	prt$rate
	db	'1200 ',eom
skip$tell$baud:
	mvi	c,ILP
	call	mex
	db	cr,lf,eom
	ret
;
;
;
disp$rate:
	mvi	c,ILP
	call	mex			; Print current baud rate
	db	cr,lf,'Baud rate is'
	db	' now: ',eom
	lda	mspeed
	mvi	c,prbaud
	call	mex

	lda	XxD$config
	lxi	b,'7'*256+'1'		; B='7'  C='1'
	bit	0,a			; bit 0=1 if 8 bits
	jrz	dsp$7
	inr	b
dsp$7:
	bit	1,a			; bit 1=1 if 2 stop bits
	jrz	dsp$1
	inr	c
dsp$1:
	lxi	h,byte$type$tbl+1-3
	ani	11100000b		; only test the parity
tst$nxt:
	inx	h
	inx	h
	inx	h
	cmp	m
	jrnz	tst$nxt
	dcx	h			; byte before is the type
	mov	a,m
	lxi	h,msg$ptr
	mov	m,b			; save the word length
	inx	h
	mov	m,a			; save the parity
	inx	h
	mov	m,c			; save the stop bits

	mvi	c,ilp
	call	mex
	db	'   ('
msg$ptr:
	db	'8'
	db	'N'
	db	'1)',cr,lf,eom
	ret
;
;
;
prt$rate:
	lda	mdm$tp
	ana	b
	mvi	c,ilp
	jnz	mex
	pop	h
scan$prt$rate:
	mov	a,m
	inx	h
	ora	a
	jrnz	scan$prt$rate
ipchl:
	pchl
;
;
cmdtbl:
	db	'11','0'+80h
	dw	ok110
	db	'30','0'+80H
	dw	ok300
	db	'60','0'+80h
	dw	ok600
	db	'120','0'+80H
	dw	ok1200
	db	0

ok110:
	xra	a
	db	21h			; lxi h,mvi a,1
ok300:
	mvi	a,1
	db	21h			; lxi h,mvi a,3
ok600:
	mvi	a,3
	db	21h			; lxi h,mvi a,5
ok1200:
	mvi	a,5

	push	psw
	call	set$nxt$parm
	pop	psw

NEW$BAUD:
	cpi	5+1			; make sure not greater
	cmc				; ..then 1200 baud (5)
	rc				; return with carry set
	mov	b,a			; ..if bad baud rate
	add	b			; 2X
	add	b			; 3X
	mov	e,a
	mvi	d,0			; three bytes per table entry
	lxi	h,baud$table
	dad	d
	lda	mdm$tp			; 4 lsb's tell baud supported
	ana	m			; mask with desired rate
	cmc
	rz				; exit if bad baud rate (with Cy set)
	mov	a,b
	sta	mspeed			; set Modem Speed
	inx	h
	mov	a,m			; get speed byte
	sta	clock
	inx	h
	mov	a,m			; get baud rate byte
reset$baud:
	push	psw
	mvi	e,3ch			; offset to jmp devtbl
	call	vector$1		; returns HL=char device table start
	lxi	d,dev$no*8+7		; offset to RS232 baud rate
	dad	d			; point to RS232 baud rate byte
	pop	psw
	mov	m,a			; change baud rate

	mvi	c,dev$no		; init RS232 baud rate
	mvi	e,3fh			; offset to jmp ?cinit
	call	vector$1
	ana	a			; Cy cleared, baud rate set OK
	ret

vector$1:
	lhld	01
	mov	l,e
	pchl
;
;
;
set$nxt$parm:
	mvi	c,gnc
	call	mex			; any arguments?
	rc
	ori	20h			; make lower case
	lxi	h,byte$type$tbl
chk$next:
	cmp	m			; match table entry?
	inx	h			;   point to the mask
	mov	b,m			;   get OR value (new data)
	inx	h			;   point to the new value (to add in)
	jrz	change$type		; yes, go change type
	inx	h			; no, scan to next entry
	mov	b,m
	inr	b			; next entry a -1?
	jrnz	chk$next		; no, check next table entry
	jr	set$nxt$parm		; yes, skip this entry get the next one.

change$type:
	mov	a,m			; get mask value
	lxi	h,XxD$config		; point to system (RS232) config byte
	ana	m			; mask out old value
	ora	b			; OR in new value
	mov	m,a			; update config byte
	sta	local$config		; update boot value
	jr	set$nxt$parm		; see if any other parameters have changed
;
;
;
byte$type$tbl: 				; or'ed value , MASK
	db	'n',00000000b,00011111b
	db	'o',11100000b,00011111b
	db	'e',11000000b,00011111b
	db	'm',10100000b,00011111b
	db	's',10000000b,00011111b
	db	'7',00000000b,11111110b
	db	'8',00000001b,11111110b
	db	'1',00000000b,11111101b
	db	'2',00000010b,11111101b
	db	-1
;
;
; TABLE OF BAUDRATE PARAMETERS
;
baud$table:
	db	1,20,3			; 0	110
	db	2,19,6			; 1	300
	db	0,0,0			; 2	450	(not used)
	db	4,17,7			; 3	600
	db	0,0,0			; 4	710	(not used)
	db	8,13,8			; 5	1200
;
;
baudbuf:
	db	10,0
	ds	10
;
; NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;				 0D00H (without Smartmodem)
;
	org	escchr			; change the ESC character to ESC
	db	esc

	org	xsize			; reduce buffer size (slow disk drives)
	db	4

	org	queue			; turn off queueing (system
	db	0			; ..has 48 byte buff)

	end

