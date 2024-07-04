


	TITLE	'Commodore Modem Overlay V1.0    19 Nov 85'
;
$*MACRO		; have MAC only display CODE not MACRO expansion
;
;	This overlay was created for the C128
;	by  Von Ertwine    19 Nov 85
;
; SYSTEM CONSTANTS
;
mdm$tp	equ	0104h		; 7	(1670 if set)
				; 6	(1650 or 1660 if set)
				; 5	(1660 if set)
				; 4	(supports CD if clear)
				; 3	(set if 1200 baud is supported)
				; 2	(set if  600 baud is supported)
				; 1	(set if  300 baud is supported)
				; 0	(set if  110 baud is supported)
TPULSE	EQU	0105h		;TONE/PULSE FLAG IN MODEM OVERLAY
MSPEED	EQU	0107h		; current baud rate
MDM$ST	EQU	012Ah		; normal status call
SHOWBD	EQU	012Eh		; show current baud rate
out$mdm	equ	0134h
mask$s	equ	014eh
test$s	equ	0151h


DIALV	EQU	0162h		;LOCATION OF DIAL VECTOR IN OVERLAY
DISCV	EQU	0165h		;LOCATION OF DISCONNECT VECTOR IN OVERLAY
NEWBDV	EQU	016Eh		;change baud rate (value in A)

DIALOC	EQU	0800h		;DIALING CODE GOES HERE
MEX	EQU	0D00h		;"CALL MEX"
SMINIT	equ	0d55h		; modem init vector
ssetv	equ	0d57h		; sset cmd vector
smexit	equ	0d59h		; modem exit vector

	page
;
; FOLLOWING ARE FUNCTION CODES FOR THE MEX SERVICE CALL PROCESSOR
;
INMDM	EQU	255		;RETURN CHAR FROM MDM IN A, CY=NO CHR IN 100MS
TIMER	EQU	254		;DELAY 100MS * REG B
TMDINP	EQU	253		;B=# SECS TO WAIT FOR CHAR, CY=NO CHAR
CHEKCC	EQU	252		;CHECK FOR ^C FROM KBD, Z=PRESENT
SNDRDY	EQU	251		;TEST FOR MODEM-SEND READY
RCVRDY	EQU	250		;TEST FOR MODEM-RECEIVE READY
SNDCHR	EQU	249		;SEND A CHARACTER TO THE MODEM (AFTER SNDRDY)
RCVCHR	EQU	248		;RECV A CHAR FROM MODEM (AFTER RCVRDY)
lookup	equ	247		; table search
parsfn	equ	246		; parse filename from input stream
bdpars	equ	245		; parse baud-rate from input stream
sblank	equ	244		; scan input stream to next non-blank
evala	equ	243		; evaluate numeric from input stream
lkahed	equ	242		; get nxt char w/o removing from input
gnc	equ	241		; get char from input, cy=1 if none
ilp	equ	240		; inline print
decout	equ	239		; decimal output
prbaud	equ	238		; print baud rate
;
;

eom		equ	00H
bell		equ	07H		;bell
lf		equ	0AH		;linefeed
cr		equ	0DH		;carriage return
esc		equ	1BH		;escape
;
no		equ	0
yes		equ	not(no)

	page

XxD$config:	equ	0fd4Eh
;		bit 7	0=no parity	1=parity
;		bit 6	0=mark/space	1=odd/even
;		bit 5	0=space/even	1=mark/odd
;		bit 1	0=1 stop bit	1=2 stop bits
;		bit 0	0=7 data bits	1=8 data bits

RS232$status:	equ	XxD$config+1
;		bit 7	0=no data	1=send data
;		bit 6	1=sending data now
;		bit 5	1=recv queue active
;		bit 4	1=parity error
;		bit 3	1=framing error
;		bit 2	not used
;		bit 1	receiving data now
;		bit 0	data byte ready

xmit$data:	equ	RS232$status+1
recv$data:	equ	xmit$data+1
modrcvb		equ	01H		; bit to test for receive
modrcvr		equ	01H		; value when receive ready
modsndb:	equ	80H		; bit to test for send
modsndr:	equ	00H		; value when send ready		

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

bit	macro	?N,?R
	db	0cbh,?N*8+?R+40h
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

exx	macro
	db	0d9h
	endm

	page
;
;
;
	org	mdm$st
	jmp	mdm$stat		; default as 1670 and 1011A status
;	
	org	dialv
	jmp	dial			; point system to dialer routine
;
	org	discv
	jmp	discon			; point disconect to modem disconect
;
	org	SMINIT
	dw	init$mod		; install modem init vector
;
	org	ssetv
	dw	do$sset			; install SSET comand vector
;
;
;
	org	dialoc
do$sset:
	mvi	c,sblank
	call	mex			; any arguments?
	jrc	disp$options
	lxi	d,opt$tbl
	mvi	c,lookup
	call	mex
	jrnc	ipchl
disp$options:
	call	initmod
	mvi	c,ilp
	call	mex
	db	cr,lf,'Select 1011A, 1650, 1670, 1660 or'
	db	' 1660CD (if Carrier Detect is supported)'
	db	cr,lf,eom
	ret

ipchl:
	pchl

	page

opt$tbl:
	db	'1011','A'+80h
	dw	set$1011
	db	'165','0'+80h
	dw	set$1650
	db	'1660C','D'+80h
	dw	set$1660cd
	db	'166','0'+80h
	dw	set$1660
	db	'167','0'+80h
	dw	set$1670
	db	0


set$1670:
	mvi	a,10001010b
	db	21h			; lxi h,(mvi a,0Fh)
set$1011:
	mvi	a,00001111b
	db	21h			; lxi h,(mvi a,42h)
set$1650:
	mvi	a,01000010b
	db	21h			; lxi h,(mvi a,72h)
set$1660:
	mvi	a,01110010b
	db	21h			; lxi h,(mvi a,62h)
set$1660cd:
	mvi	a,01100010b
	sta	mdm$tp

	page

	mvi	c,sblank
	call	mex			; any arguments?
	jrc	no$parm
	ani	01011111b		; make upper case
	cpi	'T'			; user select Tone?
	jrz	save$T$P		; yes, go set it
	cpi	'P'			; no, user select Pluse
	jrnz	no$parm			; no, use old parameter
save$T$P:				; yes, select Pluse
	sta	TPULSE			; change to PLUSE or TONE
no$parm:
	lda	mspeed
	cpi	0			; 110 baud
	jrz	ck$110
	cpi	1			; 300 baud
	jrz	ck$300
	cpi	3			; 600 baud
	jrz	ck$600
	cpi	5			; 1200 baud
	jrnz	change$baud

	mvi	a,00001000b
	db	21h			; lxi h,mvi a,4
ck$600:
	mvi	a,00000100b
	db	21h			; lxi h,mvi a,2
ck$300:
	mvi	a,00000010b
	db	21h			; lxi h,mvi a,1
ck$110:
	mvi	a,00000001b

	lxi	h,mdm$tp		; point to allowed rates
	ana	m			; is baud rate allowed for
	jrnz	initmod			; ..this modem ? yes, go do it

	page
;
;
;
change$baud:				; no, adjust to lowest allowed rate
	mvi	a,-1
try$next:
	inr	a
	sta	mspeed
	call	NEWBDV			; change the baud rate 
	lda	mspeed			; ..(Cy set if bad rate)
	jrc	try$next
	lxi	h,showbd		; tell user the new baud rate
	push	h			; ..after we are done
;
; C128 initialization -- set baudrate.
;
INITMOD:
	mvi	c,ilp
	call	mex
	db	cr,lf,'Current Device type is: ',eom
	call	show$device
	shld	MDM$ST+1
	mvi	c,ilp
	call	mex
	db	cr,lf,eom

	lxi	b,data$port$b$dir
	lda	mdm$tp			; get current modem type
	ani	40h			; 1650, 1660 modem?
	jrz	init$no$dial
	mvi	a,26h			; set data dir to output
	outp	a

	lda	on$hook$flag		; =FF if on hook
	ora	a
	cnz	phone$on$hook		; hang-up the phone (only if on hook)
	mvi	c,low(data$port$b)
	inp	a
init$no$dial:
	ori	6			; set DTR and CTS (active hi)
	outp	a
	ret

	page
;
;
;
show$device:
	mvi	c,ilp
	lxi	h,mdm$stat
	lda	mdm$tp			; get current type
	bit	7,a
	jrz	test$1660$50
	lda	tpulse
	sta	msg$tpulse
	call	mex
	db	'1670 '
msg$tpulse:
	db	'x',eom
	ret
;
test$1660$50:
	bit	6,a
	jrnz	test$1650
	call	mex
	db	'1011A - RS232 interface',eom
	ret
;
test$1650:
	lxi	h,mdm$stat$1650$60
	bit	5,a
	jrnz	show$1660
	call	mex
	db	'1650',eom
	ret
;
show$1660:
	bit	4,a
	jrnz	show$1660$no$CD
	call	mex
	db	'1660 with CD',eom
	ret
;
show$1660$no$CD:
	call	mex
	db	'1660 with-out CD',eom
	ret

	page
;
; FOLLOWING ROUTINE DISCONNECTS THE MODEM USING SMARTMODEM
; CODES. ALL REGISTERS ARE AVAILABLE FOR THIS FUNCTION.
; NOTHING RETURNED TO CALLER.
;
DISCON:
	lda	mdm$tp
	ani	80h
	jrz	phone$on$hook		; go place phone on hook if not 1670

	call	wait$2$sec		; 1670,  send hayes disconnect seq.
	call	mdm$snd$msg
	db	'+++',eom
	call	wait$2$sec
	call	mdm$snd$msg
	db	'ATH',cr,eom		; not needed by 1670 but req for hayes
	ret

wait$2$sec:
	mvi	b,20
	mvi	c,timer
	jmp	mex			; delay 2 seconds

	page
;
;	Place phone on hook (This routine is used if 1650 or 1660)
;
phone$on$hook:
	mvi	a,yes
	sta	on$hook$flag
	lxi	b,data$port$b
	lda	mdm$tp
	ani	20h			; bit 5=1 if 1660, =0 if 1650
	jrz	type$1650
	
type$1660:
	inp	a
	ori	20h			; set, phone on hook (1660)
	jr	on$hook$cont

type$1650:
	inp	a
	ani	not(20h)		; set, phone on hook (1650)
on$hook$cont:
	outp	a
	ret

	page
;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (in fact, that's the
; scheme employed here for the Smartmodem).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the dig-
; its, and will send each to the DIAL routine un-inspected (some modems,
; like the Smartmodem, allow special non-numeric characters in the
; phone number, and MEX may make no assumptions about these).
;
; After receiving the end-dial sequence (255) the overlay must take
; whatever end-of-dial actions are necessary *including* waiting for
; carrier at the distant end.  The overlay should monitor the keyboard
; during this wait (using the MEX keystat service call), and return
; an exit code to MEX in the A register, as follows:
;
;	0 - Carrier detected, connection established
;	1 - Far end busy (only for modems that can detect this condition)
;	2 - No answer (or timed out waiting for modem response)
;	3 - Keyboard abort (^C only: all others should be ignored)
;	4 - Error reported by modem
;
; <No other codes should be returned after an end-dial sequence>
;
; The overlay should not loop forever in the carrier-wait routine, but
; instead use either the overlay timer vector, or the INMDMV (timed 100
; ms character wait) service call routine.
;
; The DIAL routine is free to use any of the registers, but must return
; the above code after an end-dial sequence
;
next$dial$state	equ	$+1
dial:
	jmp	dial$idle

	page
;
;
;
dial$idle:
	cpi	-2			; start dial sequence?
	mvi	a,4			; dial error code (valid if last state)
	rnz				; exit if not (this is the start state)
	lda	mdm$tp			; get the modem type byte
	bit	7,a			; is device a Commodore 1670 ?
	jrz	dl$tst$1650$60		; no, go test 1650 and 1660
;
;	user has a Hayes compadable modem (1670)
;
	lda	tpulse			; GET OVERLAY'S TOUCH-TONE FLAG
	sta	ATDx			; PUT INTO STRING
	call	mdm$snd$msg		;
	db	'ATD'
ATDx:	db	'T ',eom
	call	set$next$state
;
;	at this point we should recieve numbers to dial or exit code (-1)
;
	cpi	-1
	jnz	mdm$snd$A		; send it (do not change states)

	call	mdm$snd$CR		; send CR to modem to end input
	mvi	b,-1
	call	strip$mdm		; remove any modem input
	call	result			; returns with result is A
	push	psw			; save result
	call	mdm$snd$CR		; send CR to the modem
	pop	psw			; ..will abort if error else
					; ..just send CR to host.
set$start$state:
	lxi	h,dial$idle
	push	h
set$next$state:
	pop	h
	shld	next$dial$state
	ret

	page
;
;	User has selected the 1011A or EQV. device. No dialing.
;
dial$1011a:
	mvi	a,4			; device error code (1011A
	ret				; ..can not dial)
;
;
;
dl$tst$1650$60:
	bit	6,a			; test if commodore 1650 or 1660 modem
	jrz	dial$1011A		; if not 1650 or 1660 must be 1011A
;
;	User has selected Commodore 1650 or 1660 modem
;
	call	phone$on$hook
	xri	20h			; toggle on/off hook bit
	outp	a			; take phone off hook
	call	wait$2$sec
	call	set$next$state
;
;
;
	cpi	-1
	jrz	done$1650$60
	cpi	','
	jrz	delay$1$sec
	cpi	'-'
	rz
	sui	'0'
	jrc	send$responce
	jrnz	not$10
	mvi	a,10
not$10:
	cpi	10+1
	mov	d,a
	jrnc	send$responce

	page
;
;	dial number in D
;
dial$digit:
	lxi	b,data$port$b		; point to CIA
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
; 10+7ah+7ahl+4ahl+12ahl-5ah+4ah+12ah-5a+4a+12a-5+10+4+10=23ahl+18ah+11a+29
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

	page

;
;
;
done$1650$60:
	lda	mdm$tp
	cma
	ani	10h			; bit 4=0 if it supports CD
	jrz	send$responce		; send A=0 (connected)
	lxi	h,45000
wait$carrier:
	lxi	b,data$port$b
	inp	a
	ani	10h			; test carrier detect
	jrz	send$responce		; send A=0 (connected)

	call	test$abort		; user request abort ?
	jrz	send$responce		; yes, send A=3 (abort code)
	dcx	h
	mov	a,h
	ora	l
	jrnz	wait$carrier
	mvi	a,2			; send - NO CARRIER code
send$responce:
	lxi	h,on$hook$flag
	mvi	m,no
	jmp	set$start$state


	page
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 60 SECONDS: YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE).
; NOTE THAT THE SMARTMODEM HAS AN INTERNAL 30 SECOND TIMEOUT WHILE
; FOR A CARRIER ON THE OTHER END.  YOU CAN CHANGE BY PLAYING WITH THE
; S7 VARIABLE (I.E. SEND THE SMARTMODEM "AT S7=20" TO LOWER THE 30 SECOND
; WAIT TO 20 SECONDS).
;
result:
	mvi	c,60			; wait 60 seconds for a responce
result$loop:
	push	b			; save current time
	lxi	b,1*256+tmdinp		; wait for up to 1 second for input
	call	mex			; any modem responce yet?
	pop	b			;  recover current time
	jrnc	test$responce		; yes, go test it
	call	test$abort		; no, user wish to abort
	rz				;  yes, exit (A=3)
	dcr	c			;  no, 60 second over yet?
	jrnz	result$loop		;   no, test again
	mvi	a,2			;   yes, return timeout code
	ret
;
;
;
test$responce:
	call	test$code		; check responce Cy=1 if unknown
	mov	a,b			; place responce code in A
	push	psw			; save responce and Cy flag
	mvi	b,lf			; remove characters from modem until
	call	strip$mdm		; ..none in 100MS or a LF
	pop	psw			; recover responce and Cy flag
	jrc	result			; start over if bad responce
	ret

	page
;
;
;
test$abort:
	push	h
	push	b			; save count (in C)
	mvi	c,chekcc
	call	mex			; user type a ^C ?
	pop	b
	pop	h
	mvi	a,3			; return abort code (only
	ret				; ..used if abort)
;
;
;
strip$mdm:
	mvi	c,inmdm			; get modem character (Cy=1 if
	push	b			; ..none in 100Ms)
	call	mex
	pop	b
	rc				; return if Modem is empty
	cmp	b			; test for end character
	rz				; found user char, return
	jr	strip$mdm		; get next character

;
;	check modems responce against legal ones, return carry set if
;	  not a legal responce, else return code for responce
;
test$code:
	ani	7FH			; strip parity bit
	mvi	b,0			; start with connect code
	cpi	'C'			; Connect?
	rz				; yes, ret
	cpi	'1'			; # code for Connect?
	rz				; yes, ret
	cpi	'5'			; # code for Connect 1200?
	rz				; yes, ret
	mvi	b,2			; no connect code
	cpi	'N'			; No Connect?
	rz				; yes, ret
	cpi	'3'			; # code for No Connect?
	rz				; yes, ret
	mvi	b,4			; modem error code
	cpi	'E'			; Error ?
	rz				; yes, ret
	cpi	'4'			; #code for Error?
	rz				; yes, ret
	stc				; set carry if none of above
	ret

	page
;
;	send string following CALL to the modem (to EOM)
;
mdm$snd$msg:
	xthl
	call	mdm$snd$HL
	xthl
	ret
;
;	send string pointed to by HL to modem (ended with a zero (EOM))
;
mdm$snd$HL:
	mov	a,m			; FETCH NEXT CHARACTER
	ora	a			; END?
	rz				; DONE IF SO
	call	mdm$snd$A
	inx	h
	jr	mdm$snd$HL
;
;	send a CR to the modem
;
mdm$snd$CR:
	mvi	a,cr
;
;	send character in A to modem
;
mdm$snd$A:
	push	psw			; save char to send
mdm$snd$bzy:
	mvi	c,snd$rdy		; test if modem is ready for a byte
	call	mex			; 
	jrnz	mdm$snd$bzy		; if not ready loop back
	pop	psw			; recover char to send
	jmp	out$mdm

	page
;	
;
;
mdm$stat$1650$60:
	lda	on$hook$flag
	ora	a
	jrz	read$status		; return modem status if off hook
;
;	test if modem is ringing
;
	exx				; save HLDEBC
	lxi	b,data$port$b
	inp	a
	bit	3,a			; ring indicator bit (active low)
	jrnz	ring$cont		; exit if not ringing
;
;	ringing, take phone off hook and wait for CD (if used)
;
	xri	20h			; toggle on/off hook bit
	outp	a			; take off hook
	mvi	a,no			; set phone off hook
	sta	on$hook$flag
	lda	mdm$tp			; bit 4=0 if supports CD
	ani	10h			; =10h if no support
	jrz	ring$cont
	mvi	l,0
carrier$yet:
	dcr	l
	jrz	ring$cont
	inp	a
	ani	10h			; test if carrier present
	jrz	ring$cont		; 
	call	delay			; delay .16 seconds
	jr	carrier$yet		; will wait .16*255 = 40.8 seconds

	page
;
;
;
read$status:
	lda	mdm$tp			; bit 4=0 if supports CD
	ani	10h
	jrnz	mdm$stat		; exit if CD is not supported
;
;	make sure that the carrier is still present (hang up if not)
;
	exx				; save HLDEBC
	lxi	b,data$port$B
	inp	a
	ani	10h			; test if carrier present
	cnz	phone$on$hook		; lost carrier, hang up the phone
ring$cont:
	exx				; restore HLDEBC
;
;
;
mdm$stat:
	lda	RS232$status
	ret



;
;	data area
;
on$hook$flag:
	db	yes			; yes=0FFh=on hook, no=00=off hook

	end

