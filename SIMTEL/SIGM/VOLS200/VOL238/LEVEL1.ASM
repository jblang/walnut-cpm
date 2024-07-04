title 'LEVEL1.ASM'
;************************************************
;*						*
;*		LEVEL1.ASM			*
;*						*
;*  Hardware level initialization and interrupt	*
;*  service routines for X.25 protocol.		*
;*  Implemented for Digital Research Computers	*	
;*  'Big Board' single board computer.		*
;*  (Z80+SIO+CTC using mode 2 interrupts)	*
;*						*
;*  rev 1.39	08/21/84	E. Elizondo	*
;*						*
;*  (c) 1984 E. Elizondo - all rights reserved. *
;*						*
;*    This program may be used freely for non-  *
;*  commercial applications. It may not be sold *
;*  or used for commercial applications without *
;*  written permission of the author.           *
;* 						*
;************************************************
;	
	maclib	Z80		;DR Z80 macro library


;	design parameters

;	timer periods (seconds)
t1:	equ	10		;level 2 timer T1
t20:	equ	180		;level 3 timer T20
t21:	equ	200		;level 3 timer T21
t22:	equ	180		;level 3 timer T22
t23:	equ	180		;level 3 timer T23

;	BIG BOARD equates

;	I/O port assignments
BAUDA:	equ	00h	;channel A baud generator
SIO:	equ	04h	;dual serial I/O
SIODPA:	equ	SIO+0	;SIO data port A
SIOCPA:	equ	SIO+2	;SIO control/status port A
CTC:	equ	18h	;quad counter/timer circuit
CTC0:	equ	CTC+0	;CTC channel 0
CTC1:	equ	CTC+1	;CTC channel 1

;	interrupt vector locations
SIOV4:	equ	0FF08h	;SIO port A xmit buffer empty int vector
SIOV5:	equ	0FF0Ah	;SIO port A external status change
SIOV6:	equ	0FF0Ch	;SIO port A receive data available
SIOV7:	equ	0FF0Eh	;SIO port A special receive condition
CTCV1:	equ	0FF12h	;CTC channel 1 interrupt

;	SIO commands
srcres	equ	0011$0000b	;reset special rx cond errors
eomres	equ	1100$0000b	;reset tx eom latch
crcres	equ	1000$0000b	;reset tx crc
escres	equ	0001$0000b	;reset external status interrupt
intpres	equ	0010$1000b	;reset tx interupt pending
abort	equ	0000$1000b	;HDLC abort command

;	special Level 2 frame identifiers

cmdrfid	equ	1000$0111b	;X.25 CMDR frame identifier


;	hooks for main program

;	subroutine entry points
	public	inisio		;initialize SIO channel A
	public	sbaud		;set baud rate
	public	txwake		;start frame transmission
	public	txabo		;transmit immediate abort
	public	t1on		;start level 2 timer T1
	public	t1off		;stop level 2 timer T1
	public	t20on		;start level 3 timer T20
	public	t20off		;stop level 3 timer T20
	public	t21on		;start level 3 timer T21
	public	t21off		;stop level 3 timer T21
	public	t22on		;start level 3 timer T22
	public	t22off		;stop level 3 timer T22
	public	t23on		;start level 3 timer T23
	public	t23off		;stop level 3 timer T23


;	addresses
	public	baudop		;default baud rate option
	public	rxgfct		;count of good received frames
	public	rxbfct		;count of bad received frames
	public	rxbbct		;count of buffer busy
	public	rxboct		;count of buffer overrun
	public	rxcect		;count of crc errors
	public	rxoect		;count of received frame overruns
	public	rxabct		;count of received aborts
	public	txefct		;count of tx end of frames
	public	txuect		;count of tx underrun errors
	public	txabct		;count of transmitted aborts
	public	txaddr		;tx address byte
	public	txctrl		;tx control byte
	public	rxstat		;receive status flags
	public	txstat		;transmit status flags
	public	tistat		;timer status flags

;	definition of rxstat flag byte:
;	bit	set condition
;	0	rx active
;	1	undefined
;	2	undefined
;	3	undefined
;	4	undefined
;	5	receiver buffers unavailable
;	6	undefined
;	7	undefined

;	definition of txstat flag byte:
;	bit	set condition
;	0	tx active
;	1	tx message complete
;	2	tx frame underrun
;	3	next tx character is control
;	4	undefined
;	5	undefined
;	6	undefined
;	7	undefined

;	definition of tistat flag byte:
;	bit	set condition
;	0	level 2 timer t1 timed out
;	1	level 3 timer t20 timed out
;	2	level 3 timer t21 timed out
;	3	level 3 timer T22 timed out
;	4	level 3 timer T23 timed out
;	5	undefined
;	6	undefined
;	7	undefined


;	external suboutines
	extrn	ilprt		;in line print routine
	extrn	putbuf		;write char to buffer
	extrn	getbuf		;read char from buffer
	extrn	bpoint		;point to bcb address
	extrn	newrxb		;get new rx buffer
	extrn	clrbuf		;clear buffer for new use
	extrn	resbcb		;restore bcb pointers
	extrn	delay		;wait a bit

;	external addresses
	extrn	rxbact		;active rx buffer #
	extrn	rxbtab		;table of rx bcb pointers
	extrn	rxfree		;bcb for list of free rx buffers
	extrn	rxflst		;bcb for list of complete rx buffers
	extrn	rxbcbp		;active rx bcb
	extrn	txbtab		;table of tx bcb pointers
	extrn	txbcbp		;active tx bcb
	extrn	txubcb		;bcb for CMDR/FRMR I data


;	miscellaneous equates
	
cr	equ	0Dh	;carriage ret
lf	equ	0Ah	;line feed


	cseg			;code segment


;	*********************************
;	* initialization section	*
;	*********************************


;	initialize SIO port A
;	(externally called)
;	on entry:	no paramters
;	on exit:	flags, regs clobbered

inisio:	
;	initialize interrupt vectors
	lxi	h,siotbe	;tx interrupt service
	shld	siov4
	lxi	h,sioesc	;ext status change service
	shld	siov5
	lxi	h,siorca	;rx interrupt service
	shld	siov6
	lxi	h,siosrc	;special rx condition service
	shld	siov7
	lxi	h,tick		;1 second timer interrupt
	shld	ctcv1

;	initialize baud rate
	lda	baudop		;get initial baud rate option
	call	sbaud		;set rate

;	initialize programmable I/O devices
	lxi	h,intab		;point to SIO parameter table
inilp:	mov	b,m		;b= loop bytecount
	inx	h
	mov	c,m		;c= device control port #
	inx	h	
	outir			;output byte string 
	mov	a,m		;test for end of table
	inr	a		;	/
	jnz	inilp		;loop again if not at end

;	initialize program status flags
	xra	a	
	sta	rxstat		;clear receive flags
	sta	txstat		;clear transmit flags

;	clear sio rx buffer
	in	siodpa		;clear out SIO data buffer
	in	siodpa		;again for luck
	ret

;	*********************************
;	* interrupt service routines	*
;	*********************************


;	receive character interupt service routine
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, registers unchanged

siorca:
	call	save		;save registers
	in	siodpa		;get received char
	mov	b,a		;save char in <b>
	lxi	h,rxstat	;point to rx status flag
	setb	0,m		;set rx active
	bit	5,m		;rx buffer available?
	jnz	erxbusy		;no, handle error
;
	mov	a,b		;get byte
	lhld	rxbcbp		;<hl>=active bcb pointer
	call	putbuf		;store in buffer	
	rnc			;exit if no buffer overflow
;	
	lhld	rxboct		;else increment buffer overflow
	inx	h		;..error counter
	shld	rxboct		;	/
	ret

;	handle no buffer available error
erxbusy:
	lhld	rxbbct		;get buffer busy error count
	inx	h		;increment it
	shld	rxbbct		;and save updated count
	ret


;	special receive condition interrupt service routine
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, regs unchanged

siosrc:
	call	save		;save registers
	mvi	a,1		;select rr1
	out	siocpa		;	/
	in	siocpa		;read rr1
	mov	b,a		;save status in <b>
	mvi	a,srcres	;reset error command
	out	siocpa		;	/
	in	siodpa		;clear data byte
	lxi	h,rxstat	;clear rx active
	res	0,m
	bit	7,b		;check end of frame bit
	jnz	eof		;yes, service it
;
;	process error conditions
	lhld	rxbfct		;update bad frame count
	inx	h		;	/
	shld	rxbfct		;      /
	bit	6,b		;crc error?
	cnz	crcerr		;yes, service it
;
	bit	5,b		;overrun error?
	cnz	orerr		;yes, service it
;
	call	flush		;clear rx buffer
	ret
;
;	process end of frame
eof:
	lda	rxbact		;get active buffer #
	lxi	h,rxflst	;point to list of rx frames
	call	putbuf		;hand over frame
	call	newrxb		;get new rx buffer if avail
	lhld	rxgfct		;update good frame count
	inx	h		;	/
	shld	rxgfct		;      /
	ret
;
;
crcerr:	lhld	rxcect		;update crc error counter
	inx	h		;	/
	shld	rxcect		;      /
	ret
;
orerr:	lhld	rxoect		;update overrun error counter
	inx	h		;	/
	shld	rxoect		;      /
	ret

			
;	tx wake routine (starts transmission of frame)
;	(externally called)
;	on entry:	no paramters
;	on exit:	flags, regs clobbered

txwake:
	lxi	h,txstat	;point to tx status flag
	setb	0,m		;signal tx active
	setb	3,m		;signal next char is control
	mvi	a,crcres	;reset tx crc
	out	siocpa		;	/
	lda	txaddr		;get address byte
	out	siodpa		;transmit it
	mvi	a,eomres	;reset tx eom latch
	out	siocpa		;	/
	ret


;	tx buffer empty interrrupt service routine
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, regs unchanged

siotbe:
	call	save		;save registers
	lxi	h,txstat	;point to tx status flag
	bit	1,m		;message complete?
	jnz	txeof		;yes, process end of frame
;
	lda	txctrl		;get control byte
	bit	3,m		;next char is control?
	jz	txnext		;no, process remainder of frame
;
	res	3,m		;yes, reset flag
	out	siodpa		;transmit control byte
	ret
;	
;	process remainder of frame
txnext:	bit	0,a		;I frame?
	jz	txinfo		;yes, process it
;
	ani	1110$1111b	;CMDR frame?
	cpi	cmdrfid		;	/
	jnz	txeom		;no, process end of message
;
	lxi	h,txubcb	;yes, point to CMDR bcb
	call	getbuf		;byte available?
	jc	txeom		;no, process end of message
;
	out	siodpa		;else output byte
	ret			

;	process I frame
txinfo:	lhld	txbcbp		;point to active bcb
	call	getbuf		;end of buffer?
	cc	resbcb		;yes, restore bcb pointers
	jc	txeom		;and process end of message
;
	out	siodpa		;else output byte
	ret			
;	

;	process end of transmitted message
txeom:	lxi	h,txstat	;point to tx status flag
	setb	1,m		;set message complete semaphore
	lhld	txefct		;increment end of frame count
	inx	h		;	/
	shld	txefct		;      /
	jmp	txexi

;	process end of transmitted frame
txeof:	res	1,m		;clear tx mc flag
	res	0,m		;set tx inactive
txexi:	mvi	a,intpres	;reset tbe int pending
	out	siocpa		;	/
	ret


;	service external status change interrupt
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, regs unchanged

sioesc:
	call	save 		;save registers
	in	siocpa		;read rr0
	mov	b,a		;save status in <b>
	bit	6,b		;tx buffer underrun?
	jnz	txurun		;yes, process it
;
	bit	7,b		;abort received?
	jnz	rxabo		;yes, process it
;
;	else it's only a sync detect
	in	siodpa		;clear extraneous char
	jmp	escexi		;and exit
;
;	process rx abort
rxabo:
	mvi	a,3		;wr3
	out	siocpa		;	/
	mvi	a,1101$0001b	;enter hunt phase
	out	siocpa
	in	siodpa		;clear any extraneous char
	lhld	rxabct		;increment rx abort count
	inx	h		;	/
	shld	rxabct		;      /
	call	flush		;clear rx buffer
	call	delay		;wait a little bit
	jmp	escexi		;and exit
;
;	process tx buffer underrun
txurun:	mvi	a,eomres	;reset eom/underrun latch
	out	siocpa		;	/
	lxi	h,txstat	;point to tx status flag
	bit	1,m		;tx message complete?
	jnz	escexi		;yes, it's normal termination
;
;	process real tx buffer underrun error
	res	0,m		;clear tx busy flag
	lhld	txuect		;increment underrun error count
	inx	h		;	/
	shld	txuect		;      /
	call	txabo		;and abort transmission
	lda	txctrl		;get control byte
	bit	0,a		;I frame?
	jnz	escexi		;no, exit
;
	lhld	txbcbp		;yes, point to active tx bcb
	call	resbcb		;and reset pointers
;
;	common exit
escexi:	mvi	a,escres	;reset esc condition
	out	siocpa		;	/
	ret


;	clear active rx buffer
;	(internally called)
flush:	lhld	rxbcbp		;point to active rx bcb 
	call	clrbuf		;clear buffer
	ret


;	service 1 second timer interrupt from CTC-1
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, regs unchanged

tick:
	call	save		;save registers
	lxi	d,tistat	;<de>=A(timer status word)
	lxi	h,t1ct		;point to first counter
	xra	a		;clear <a>
	cmp	m		;count=0?
	jz	tick1		;yes, keep going
	dcr	m		;else decrement count
	jnz	tick1		;keep going if not 0
	xchg			;else set timeout flag
	setb	0,m		;	/
	xchg			;      /
tick1:	inx	h		;point to next counter
	cmp	m		;count=0?
	jz	tick2		;yes, keep going
	dcr	m		;else decrement count
	jnz	tick2		;keep going if not 0
	xchg			;else set timeout flag
	setb	1,m		;	/
	xchg			;      /
tick2:	inx	h		;point to next counter
	cmp	m		;count=0?
	jz	tick3		;yes, keep going
	dcr	m		;else decrement count
	jnz	tick3		;keep going if not 0
	xchg			;else set timeout flag
	setb	2,m		;	/
	xchg			;      /
tick3:	inx	h		;point to next counter
	cmp	m		;count=0?
	jz	tick4		;yes, keep going
	dcr	m		;else decrement count
	jnz	tick4		;keep going if not 0
	xchg			;else set timeout flag
	setb	3,m		;	/
	xchg			;      /
tick4:	inx	h		;point to next counter
	cmp	m		;count=0?
	jz	tick5		;yes, keep going
	dcr	m		;else decrement count
	jnz	tick5		;keep going if not 0
	xchg			;else set timeout flag
	setb	4,m		;	/
	xchg			;      /
tick5:				;room for expansion
	ret


;	save register routine for interrrupt service

save:	xthl			;save <hl> & point to service routine
	push	d		;save the other regs
	push	b		;	/
	push	psw		;      /
	call	go		;go and return here from service routine
	pop	psw		;restore registers
	pop	b		;	/
	pop	d		;      /
	pop	h		;and get <hl> back from stack
	ei			;enable interupts
	reti			;restore interrupt chain
;
go:	pchl			;dispatch to <hl>


;	*********************************
;	* level 1 control subroutines	*
;	*********************************


;	transmit abort signal
;	(externally and internally called)
;	on entry:	no parameters
;	on exit:	flags, regs clobbered

txabo:
	mvi	a,abort		;send immediate abort
	out	siocpa		;	/
	lhld	txabct		;increment transmitted abort count
	inx	h		;	/
	shld	txabct		;      /
	ret


;	stop level 2 timer T1
;	(externally and internally called)
;	on entry:	no paramters
;	on exit:	all flas, regs unchanged

t1off:
	push	psw		;save regs and flags
	push	h		;	/
	xra	a		;set count to 0
	sta	t1ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	0,m		;	/
	pop	h		;restore regs and flags
	pop	psw		;	/
	ret


;	stop level 3 timer T20
;	(externally and internally called)
;	on entry:	no paramters
;	on exit:	all flas, regs unchanged

t20off:
	push	psw		;save regs and flags
	push	h		;	/
	xra	a		;set count to 0
	sta	t20ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	1,m		;	/
	pop	h		;restore regs and flags
	pop	psw		;	/
	ret


;	stop level 3 timer T21
;	(externally and internally called)
;	on entry:	no paramters
;	on exit:	all flas, regs unchanged

t21off:
	push	psw		;save regs and flags
	push	h		;	/
	xra	a		;set count to 0
	sta	t21ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	2,m		;	/
	pop	h		;restore regs and flags
	pop	psw		;	/
	ret


;	stop level 3 timer T22
;	(externally and internally called)
;	on entry:	no paramters
;	on exit:	all flas, regs unchanged

t22off:
	push	psw		;save regs and flags
	push	h		;	/
	xra	a		;set count to 0
	sta	t22ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	3,m		;	/
	pop	h		;restore regs and flags
	pop	psw		;	/
	ret


;	stop level 3 timer T23
;	(externally and internally called)
;	on entry:	no paramters
;	on exit:	all flas, regs unchanged

t23off:
	push	psw		;save regs and flags
	push	h		;	/
	xra	a		;set count to 0
	sta	t23ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	4,m		;	/
	pop	h		;restore regs and flags
	pop	psw		;	/
	ret


;	start level 2 timer T1
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags unchanged

t1on:
	push	psw		;save regs and flags
	push	h		;	/
	mvi	a,t1		;intitialize count
	sta	t1ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	0,m		;	/
	pop	h		;restore flags, regs
	pop	psw		;	/
	ret


;	start level 3 timer T20
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags unchanged

t20on:
	push	psw		;save regs and flags
	push	h		;	/
	mvi	a,t20		;intitialize count
	sta	t20ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	1,m		;	/
	pop	h		;restore flags, regs
	pop	psw		;	/
	ret


;	start level 3 timer T21
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags unchanged

t21on:
	push	psw		;save regs and flags
	push	h		;	/
	mvi	a,t21		;intitialize count
	sta	t21ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	2,m		;	/
	pop	h		;restore flags, regs
	pop	psw		;	/
	ret


;	start level 3 timer T22
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags unchanged

t22on:
	push	psw		;save regs and flags
	push	h		;	/
	mvi	a,t22		;intitialize count
	sta	t22ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	3,m		;	/
	pop	h		;restore flags, regs
	pop	psw		;	/
	ret


;	start level 3 timer T23
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags unchanged

t23on:
	push	psw		;save regs and flags
	push	h		;	/
	mvi	a,t23		;intitialize count
	sta	t23ct		;	/
	lxi	h,tistat	;reset timeout flag
	res	4,m		;	/
	pop	h		;restore flags, regs
	pop	psw		;	/
	ret



;	set baud rate
;	(externally and internally called)
;	on entry:	<a>=baud option (0-7)
;	on exit:	<a>=upper 4 bits=0
;			all other regs unchanged

sbaud:
	ani	07h		;extract lower 3 bits
	sta	baudop		;save option
	push	h		;save registers
	push	d		;	/
	lxi	h,baudtab	;point to baud table
	mov	e,a		;option to <de>
	mvi	d,0
	dad	d		;point to desired baud
	mov	a,m		;get baud rate byte
	sta	baudtab		;save it
	out	bauda		;program the 8116
	pop	d		;restore registers
	pop	h
	ret


;	*****************
;	* data tables	*
;	*****************


	dseg		;data segment
	
baudop	db	1		;default baud rate option

;	table of constants for 8116 baud rate generator
baudtab	db	0000$0000b	;0= current baud rate
	db	0000$0101b	;1=   300 baud
	db	0000$0110b	;2=   600 baud
	db	0000$0111b	;3=  1200 baud
	db	0000$1010b	;4=  2400 baud
	db	0000$1100b	;5=  4800 baud
	db	0000$1110b	;6=  9600 baud
	db	0000$1111b	;7= 19200 baud

;	SIO initialization table
	
intab:	db	t1end-$-2	;byte count
	db	siocpa		;SIO channel a control port
	db	0		;WR0 for sure
	db	0001$1000b	;reset channel a
	db	4		;WR4
	db	0010$0000b	;HDLC mode
	db	7		;WR7
	db	0111$1110b	;HDLC flag
	db	1		;WR1
	db	0001$1111b	;interrupt control
	db	5		;WR5
	db	1110$1011b	;tx parameters + tx enable
t1end:	equ	$


;	initialize CTC0
	db	t2end-$-2	;byte count
	db	CTC0		;CTC0 control port
	db	00100111b	;put CTC0 in timer mode
	db	105		;with period=105*256*0.4 us
t2end:	equ	$		;(=10752 us)


;	initialize CTC1 
	db	t3end-$-2	;byte count
	db	CTC1		;CTC1 control port
	db	11000111b	;put CTC1 in counter mode
	db	93		;with period=93*10752 us
t3end:	equ	$		;(=1sec) & interrupt enabled

	
;	initialize SIO receive section
;	(separated to facilitate initialization in self test mode)
	db	t4end-$-2	;byte count
	db	siocpa		;SIO-A control port
	db	3		;WR3
	db	1101$0001b	;rx parameters + rx enable
t4end:	equ	$


	db	-1		;end of table marker

;	*************************
;	* global variables	*
;	*************************

rxstat	db	0		;rx status flags
txstat	db	0		;tx status flags
tistat	db	0		;timer status flags
txaddr	db	0		;tx address byte
txctrl	db	0FFh		;tx control byte

;	system timers (must be contiguous)
t1ct:	db	0		;level 2 timer T1 count
t20ct:	db	0		;level 3 timer T20 count
t21ct:	db	0		;level 3 timer T21 count
t22ct:	db	0		;level 3 timer T22 count
t23ct:	db	0		;level 3 timer T23 count

;	level 1  diagnostic counters
rxbfct	dw	0000h		;bad received frames
rxgfct	dw	0000h		;good received frames
rxbbct	dw	0000h		;chars lost due to buffers not avail
rxboct	dw	0000h		;chars lost due to buffer overrrun
rxcect	dw	0000h		;received crc errors
rxoect	dw	0000h		;receive overrun errors
rxabct	dw	0000h		;received aborts
txefct	dw	0000h		;tx end of frame count
txuect	dw	0000h		;tx underrun errors
txabct	dw	0000h		;transmitted aborts







