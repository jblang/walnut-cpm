title 'BUFFERS.ASM'
;************************************************
;*						*
;* 	   	buffers.asm			*
;*						*
;* data buffers and buffer service routines	*
;* for X.25 protocol interface.			*
;*						*
;* rev 1.44	08/15/84	E. Elizondo	*
;*						*
;*  (c) 1984 E. Elizondo - all rights reserved. *
;*						*
;*    This program may be used freely for non-  *
;*  commercial applications. It may not be sold *
;*  or used for commercial applications without *
;*  written permission of the author.           *
;* 						*
;************************************************

	maclib	Z80		;DR Z80 macro library

;	design parameters

pdsize:	equ	128		;max packet user data field length
numrxb:	equ	16		;number of receive buffers
;	dteclr and dtebus values must be positive and less
;	than numrxb, and dtebus must be less than dteclr
dteclr:	equ	10		;# of free buffers for DTE clear
dtebus:	equ	4		;# of free buffers for DTE busy
;
numtxb:	equ	8		;number of transmit buffers
cbsize:	equ	256		;console buffer size
pbsize:	equ	1024		;printer buffer size

;	do not change this:
fbsize:	equ	pdsize+6	;frame buffer size

;	hooks for other modules

;	suboutine entry points
	public	putbuf		;write byte to end of buffer
	public	topbuf		;write byte to beginning of buffer
	public	getbuf		;read byte from buffer
	public	bpoint		;point to buffer bcb
	public	inibuf		;initialize buffer parameters
	public	rlsrxb		;release rx buffer to pool
	public	newrxb		;get new rx buffer for use
	public	clrbuf		;clear (any) buffer for new use
	public	clrtxb		;clear all tx buffers for new use
	public	getbct		;get buffer count
	public	dcrbuf		;decrement buffer count
	public	getrdy		;get state of buffer ready flag
	public	setrdy		;set buffer ready flag
	public	clrrdy		;clear buffer ready flag
	public	savbcb		;save bcb
	public	resbcb		;restore bcb

;	buffer control block (bcb) adresses
	public	cibcb		;A(bcb for console input)
	public	cobcb		;A(bcb for console output)
	public	ctbcb		;A(bcb for console transmit)
	public	crbcb		;A(bcb for consore receive)
	public	pobcb		;A(bcb for printer output)
	public	rxbtab		;A(table of rx bcb pointers)
	public	txbtab		;A(table of tx bcb pointers)
	public	rxfree		;A(bcb for #'s of free rx buffers)
	public	rxflst		;A(bcb for #'s of rx frame buffers)
	public	rxplst		;A(bcb for #'s if rx packet #'s)
	public	txubcb		;A(bcb for rx U type frame)

;	other addresses
	public	rxbact		;active rx buffer #
	public	rxbcbp		;active rx bcb address
	public	txbcbp		;active tx bcb address

;	


;	external addresses
	extrn	l3stat		;level 3 flow status word
	extrn	lkstat		;level 2 status word
	extrn	rxstat		;level 1 rx status word
	extrn	dtemod		;level 2 mode flag

;	*****************
;	*  subroutines	*
;	*****************


;  	write a byte to end of buffer
;	(externally called, re-entrant)
;	on entry:	<hl>=A(buffer control block)
;	 		<a>=byte
;	on exit:	carry set if buffer overflow
;			other flags clobbered
;			all regs unchanged

putbuf:	push	h		;save registers
	push	d		;	/
	push	b		;      /
	mov	b,a		;move byte to <b>
	push	b		;and save byte
	mov	e,m		;<de>= count
	inx	h		;	/
	mov	d,m		;      /
	inx	d		;increment count
	inx	h		;<bc>= max count
	mov	c,m		;	/
	inx	h		;      /
	mov	b,m		;     /
	call	bcmde		;buffer overflow?
	pop	b		;restore byte to <a>
	mov	a,b		;	/
	push	b		;and save byte again
	jc	putexi		;yes, return with carry set
;
	dcx	h		;else point again to count
	dcx	h		;	/
	mov	m,d		;and save new count
	dcx	h		;	/
	mov	m,e		;      /
	lxi	d,4		;<hl>= A(write pointer)
	dad	d		;	/
	push	h		;save A(write pointer)
	mov	e,m		;<de>= write pointer
	inx	h		;	/
	mov	d,m		;      /
	stax	d		;store byte in buffer
	inx	d		;bump pointer
	inx	h		;<hl>=A(pointer max value)
	mov	c,m		;<bc>=pointer max value
	inx	h		;	/
	mov	b,m		;      /
	call	bcmde		;pointer overflow?
	jnc	putptr		;no, save pointer
;
	inx	h		;else, <hl>=A(pointer min value)
	mov	e,m		;<de>=pointer min value
	inx	h		;	/
	mov	d,m		;      /
;
putptr:	pop	h		;<hl>=A(write pointer)
	mov	m,e		;update pointer
	inx	h		;	/
	mov	m,d		;      /
	stc			;and reset carry
	cmc			;	/
;
putexi:	pop	b		;restore byte in <a>
	mov	a,b		;	/
	pop	b		;restore registers and exit
	pop	d		;	/
	pop	h		;      /
	ret			;     /


;  	write a byte to beginning of buffer
;	(externally called)
;	on entry:	<hl>=A(buffer control block)
;	 		<a>=byte
;	on exit:	carry set if buffer overflow
;			a,other flags clobbered
;			all other regs unchanged

topbuf:	push	h		;save registers
	push	d		;	/
	push	b		;      /
	sta	topbyte		;save byte
	mov	e,m		;<de>= count
	inx	h		;	/
	mov	d,m		;      /
	inx	d		;increment count
	inx	h		;<bc>= max count
	mov	c,m		;	/
	inx	h		;      /
	mov	b,m		;     /
	call	bcmde		;buffer overflow?
	jc	topexi		;yes, return with carry set
;
	dcx	h		;else point again to count
	dcx	h		;	/
	mov	m,d		;and save new count
	dcx	h		;	/
	mov	m,e		;      /
	lxi	d,8		;<hl>= A(pointer min value)
	dad	d		;	/
	mov	e,m		;<de>= pointer min value
	inx	h		;	/
	mov	d,m		;      /
	inx	h		;<bc>=read pointer
	mov	c,m		;	/
	inx	h		;      /
	mov	b,m		;     /
	dcx	b		;back up read pointer
	push	b		;save new pointer value
	call	bcmde		;pointer underflow?
	pop	b		;restore new pointer value
	jnc	topptr		;no, keep going
;
	push	h		;save read pointer
	dcx	h		;and point to max value
	dcx	h		;	/
	dcx	h		;      /
	dcx	h		;     /
	mov	b,m		;set <bc>=pointer max value
	dcx	h		;	/
	mov	c,m		;      /
	pop	h		;restore read pointer

topptr:	lda	topbyte		;get back byte
	stax	b		;store byte in buffer
	mov	m,b		;update read pointer
	dcx	h		;	/
	mov	m,c		;      /
	stc			;and reset carry
	cmc			;	/
;
topexi:	pop	b		;restore registers and exit
	pop	d		;	/
	pop	h		;      /
	ret			;     /

topbyte:db	0		;temporary storage for byte



;  	read a byte from buffer
;	(externally called, re-entrant)
;	on entry:	<hl>=A(buffer control block)
;	on exit:	carry set if no byte available
;			<a>= byte (if available)
;			     0 if no byte available
;			other flags clobbered
;			all other regs unchanged

getbuf:	push	h		;save registers
	push	d		;	/
	push	b		;      /
	mov	e,m		;<de>=count
	inx	h		;	/
	mov	d,m		;      /
	mov	a,d		;buffer empty?
	ora	e		;	/
	stc			;yes, set carry flag
	jz 	getexi		;and return
;
	dcx	d		;else decrement count
	mov	m,d		;and save updated count
	dcx	h		;	/
	mov	m,e		;      /
	lxi	d,6		;<hl>=A(pointer max value)
	dad	d		;	/
	mov	c,m		;<bc>=pointer max value
	inx	h		;	/
	mov	b,m		;      /
	lxi	d,3		;<hl>=A(read pointer)
	dad	d		;	/
	push	h		;save A(read pointer)
	mov	e,m		;<de>=read pointer
	inx	h		;	/
	mov	d,m		;      /
	ldax	d		;get byte
	push	psw		;and save it
	inx	d		;bump pointer
	call	bcmde		;pointer overflow?
	jnc	getptr		;no, update pointer
;
	dcx	h		;<hl>=A(pointer min value)
	dcx	h		;	/
	mov	d,m		;<de>=pointer min value
	dcx	h		;	/
	mov	e,m		;      /
;
getptr:	pop	psw		;get byte
	pop	h		;<hl>=A(read pointer)
	mov	m,e		;update pointer	
	inx	h		;	/
	mov	m,d		;      /
	stc			;reset carry flag
	cmc			;	/
;
getexi:	pop	b		;restore registers and return
	pop	d		;	/
	pop	h		;      /
	ret			;     /


;	get buffer count
;	(externally called)
;	on entry:	<hl>=A(bcb)
;	on exit:	<de>=buffer count
;			zero flag set if count=0
;			other flags clobbered
;			all other regs unchanged
getbct:	push	h		;save regs
	push	b		;      /
	mov	b,a		;save <a>
	mov	e,m		;get count lsb
	inx	h		;get count msb
	mov	d,m		;	/
	mov	a,d		;set zero flag if count=0
	ora	e		;	/
	mov	a,b		;restore <a>
	pop	b		;restore regs
	pop	h		;      /
	ret


;  	decrement buffer (discard last written byte)
;	(externally called)
;	on entry:	<hl>=A(buffer control block)
;	on exit:	carry set if no byte available
;			<a>, other flags clobbered
;			all other regs unchanged

dcrbuf:	push	h		;save registers
	push	d		;	/
	push	b		;      /
	mov	e,m		;<de>=count
	inx	h		;	/
	mov	d,m		;      /
	mov	a,d		;buffer empty?
	ora	e		;	/
	stc			;yes, set carry flag
	jz 	dcrexi		;and return
;
	dcx	d		;else decrement count
	mov	m,d		;and save updated count
	dcx	h		;	/
	mov	m,e		;      /
	lxi	d,4		;<hl>=A(write pointer)
	dad	d		;	/
	push	h		;save A(write pointer)
	mov	c,m		;<bc>=write pointer
	inx	h		;	/
	mov	b,m		;      /
	lxi	d,3		;<hl>=A(min value for pointers)
	dad	d		;	/
	mov	e,m		;<de>=min value for pointers
	inx	h		;	/
	mov	d,m		;      /
	pop	h		;restore A(write pointer)
	dcx	b		;decrement write pointer
	mov	m,c		;and update pointer
	inx	h		;	/
	mov	m,b		;      /
	call	bcmde		;pointer underflow?
	jnc	dcrexi		;no, exit
;
	push	h		;else save write pointer
	inx	h		;set <de>=max value for pointers
	mov	e,m		;	/
	inx	h		;      /
	mov	d,m		;     /
	pop	h		;restore write pointer
	mov	m,d		;set write pointer = max value
	dcx	h		;	/
	mov	m,e		;      /
	stc			;reset carry flag
	cmc			;	/
;
dcrexi:	pop	b		;restore registers and return
	pop	d		;	/
	pop	h		;      /
	ret			;     /


;	calculate <bc>=<bc>-<de>
;	(internally and externally called)
;	on entry:	<bc>,<de> input values
;	on exit:	<bc>=result
;			carry set if <de>.gt.<bc>
;			<a>,other flags clobbered
;			all other registers unchanged

bcmde:	mov	a,c
	sub	e
	mov	c,a
	mov	a,b
	sbb	d
	mov	b,a
	ret


;	release rx buffer for new use and clear level 3 DTE
;	busy flag if enough free buffers are avalable
;	(externally called)
;	on entry:	<a>=rx buffer #
;	on exit:	all regs, flags unchanged
;			dte busy flag in level 3 cleared
;			 if # free buffers >= dteclr

rlsrxb:
	push	psw		;save regs & flags
	push	h		;	/
	push	d		;      /
	push	b		;     /
	lxi	h,rxfree	;point to bcb of list of free buffers
	mov	b,a		;save buffer # in <b>
	call	putbuf		;add this buffer # to list
	call	getbct		;<a>= # of free buffers
	mov	a,e		;	/
	cpi	dteclr		;less than dteclr?
	jnc	rls1		;no, keep going
;
	lxi	h,l3stat	;else reset level 3 DTE busy flag
	res	0,m		;	/
;
rls1:	mov	a,b		;restore buffer #
	lxi	h,rxbtab	;now point to its bcb address
	call	bpoint		;	/
	call	clrbuf		;and initialize bcb
	lxi	h,rxstat	;clear no rx buffers avail flag
	res	5,m		;	/
	lxi	h,lkstat	;clear level 2 DTE busy flag
	res	4,m		;	/
	lda	dtemod		;get level 2 mode flag
	cpi	3		;self test mode?
	jnz	rls2		;no, keep going
;
	res	3,m		;else clear level 2 DCE busy flag
;
rls2:	pop	b		;restore regs & flags
	pop	d		;	/
	pop	h		;      /
	pop	psw		;     /
	ret



;	clear (any) buffer for new use
;	(externally and internally called)
;	on entry:	<hl>=address of buffer bcb
;	on exit:	all flags, regs unchanged

clrbuf:
	push	psw		;save regs and flags
	push	b		;	/
	push	d		;      /
	push	h		;     /
	xra	a		;clear buffer count
	mov	m,a		;	/
	inx	h		;      /
	mov	m,a		;     /
	lxi	d,7		;point to min value for pointers
	dad	d		;	/
	mov	c,m		;<bc>=min value for pointers
	inx	h		;	/
	mov	b,m		;      /
	inx	h		;initialize read pointer
	mov	m,c		;	/
	inx	h		;      /
	mov	m,b		;     /
	inx	h		;point to ready flag
	mov	m,a		;and initialize it
	pop	h		;point to write pointer
	push	h		;
	lxi	d,4		;	/
	dad	d		;      /
	mov	m,c		;initialize write pointer
	inx	h		;	/
	mov	m,b		;      /
	pop	h		;restore regs and flags
	pop	d		;	/
	pop	b		;      /
	pop	psw		;     /
	ret


;	get new receive buffer and set level 3 DTE busy
;	flag if we are running out of rx buffers
;	(externally called)
;	on entry:	no parameters
;	on exit:	carry set if no buffer available
;			<a>, flags clobbered
;			all other regs unchanged
;			rxbact has active rx buffer #
;			rxbcbp has address of active rx bcb
;			L1 no rx buff avail flag set if none free
;			L3 DTE busy flag set if # of buffers<dtebus


newrxb:	push	h		;save regs
	push	d		;	/
	push	b		;      /
	lxi	h,rxfree	;point to list of free buffers
	call	getbuf		;get one
	jnc	newb1		;keep going if available
;
;	no buffer available
	lxi	h,rxstat	;set no buffer avail flag
	setb	5,m		;	/
	lxi	h,lkstat	;set level 2 DTE busy flag
	setb	4,m		;	/
	jmp	newexi		;and exit with carry set
;
;	buffer is available
newb1:	sta	rxbact		;make buffer # active
	mov	b,a		;and save buffer # in <b>
	call	getbct		;now get # of free buffers left
	mov	a,e		;	/
	cpi	dtebus+1	;less than dtebus?
	jnc	newb2		;no, keep going
;
;	number of buffers left is below threshold
	lxi	h,l3stat	;set DTE busy flag in level 3
	setb	0,m
;
;	get buffer bcb address
newb2:	mov	a,b		;restore buffer # to a
	lxi	h,rxbtab	;point to address table
	call	bpoint		;get address of new bcb
	shld	rxbcbp		;and make it active
	stc			;and clear carry flag
	cmc			;	/
;
;	common exit
newexi:	pop	b		;restore regs
	pop	d		;	/
	pop	h		;      /
	ret


;	get state of buffer ready flag
;	(externally called)
;	on entry:	<hl>=bcb address
;	on exit:	zero flag set if not ready
;			all regs unchanged

getrdy:	push	h		;save regs
	push	d		;	/
	push	b		;      /
	mov	b,a		;save <a>
	lxi	d,12		;point to ready flag
	dad	d		;	/
	mov	a,m		;get ready flag
	ora	a		;set flags
	mov	a,b		;restore <a>
	pop	b		;restore regs
	pop	d		;	/
	pop	h		;      /
	ret


;	set buffer ready flag
;	(externally called)
;	on entry:	<hl>=bcb address
;	on exit:	all regs unchanged


setrdy:	push	h		;save regs
	push	d		;	/
	lxi	d,12		;point to ready flag
	dad	d		;	/
	mvi	m,0ffh		;set ready flag
	pop	d		;restore regs
	pop	h		;	/
	ret


;	clear buffer ready flag
;	(externally called)
;	on entry:	<hl>=bcb address
;	on exit:	all regs unchanged


clrrdy:	push	h		;save regs
	push	d		;	/
	lxi	d,12		;point to ready flag
	dad	d		;	/
	mvi	m,0		;clear ready flag
	pop	d		;restore regs
	pop	h		;	/
	ret


;	save bcb for reuse in re-transmission
;	(externally called)
;	on entry:	<hl>=bcb address
;	on exit:	all regs, flags unchanged

savbcb:	push	h		;save registers
	push	d		;	/
	push	b		;      /
	lxi	d,tempbcb	;<de>=A(save area)
	lxi	b,13		;# of bytes in bcb
	ldir			;move them
	pop	b		;restore registers
	pop	d		;	/
	pop	h		;      /
	ret



;	restore bcb for reuse in re-transmission
;	(externally called)
;	on entry:	<hl>=bcb address
;	on exit:	all regs, flags unchanged

resbcb:	push	h		;save registers
	push	d		;	/
	push	b		;      /
	xchg			;<de>=A(bcb)
	lxi	h,tempbcb	;<hl>=A(save area)
	lxi	b,13		;# of bytes in bcb
	ldir			;move them
	pop	b		;restore registers
	pop	d		;	/
	pop	h		;      /
	ret



;	initialize buffer pointers
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, registers clobbered

inibuf:
	lxi	h,rxfree	;clear free rx buffer queue
	call	clrbuf		;	/
	lxi	h,rxflst	;clear rx frame buffer # queue
	call	clrbuf		;	/
	lxi	h,rxplst	;clear rx packet buffer # queue
	call	clrbuf		;	/
	lxi	h,ctbcb		;clear console tx buffer
	call	clrbuf		;	/
	lxi	h,crbcb		;clear console rx buffer
	call	clrbuf		;	/
	lxi	h,txubcb	;clear tx FRMR/CMDR I tx buffer
	call	clrbuf
;
	call	clrtxb		;clear all tx I frame buffers
;
;	clear all rx buffers
	mvi	b,numrxb	;<b>=number of rx buffers
	mvi	c,0		;<c>= first buffer #
	lxi	d,rxfree	;<de> points to free buffer list
rxclp:	lxi	h,rxbtab	;point to bcb table
	mov	a,c		;get buffer #
	call	bpoint		;point to buffer
	call	clrbuf		;clear buffer
	xchg			;point to free buffer list
	mov	a,c		;get buffer #
	call	putbuf		;put buffer # on list
	xchg			;now point back to bcb
	inr	c		;bump buffer #
	dcr	b		;last buffer?
	jnz	rxclp		;no, keep going
;
;	now make first buffer active
	call	newrxb		;make new buffer active
	ret	



;	clear all tx buffers
;	(externally and internally called)
;	on entry:	no parameters
;	on exit:	all flags, regs unchanged
;			active tx pointer initialized to buffer 0

clrtxb:
	push	psw		;save <a>,flags
	push	h		;save regs
	push	b		;	/
	mvi	b,numtxb	;<b>= number of tx buffers
	mvi	a,numtxb-1	;<a>= highest tx buffer #
clrtx1:	lxi	h,txbtab	;point to bcb table
	call	bpoint		;point to a buffer
	call	clrbuf		;clear buffer
	dcr	a		;bump buffer #
	dcr	b		;last buffer?
	jnz	clrtx1		;no, keep going
	shld	txbcbp		;initialize active tx pointer
	pop	b		;restore regs
	pop	h		;	/
	pop	psw		;restore <a>,flags
	ret



;	point to buffer control block
;	(externally and internally called)
;	on entry:	<a>=buffer # (1-127)
;			<hl>=bcb address table
;	on exit:	<hl>=buffer bcb address
;			all other registers & flags unchanged

bpoint:	push	psw		;save <a> & flags
	push	d		;save <de>
	ani	07Fh		;allow only up to 127
	rlc			;double buffer #
	mov	e,a		;and put doubled code in <de>
	mvi	d,0	
	dad	d		;now point to address in table
	mov	a,m		;get low byte of address
	inx	h		;point to high byte
	mov	h,m		;high byte into h
	mov	l,a		;and low byte into l
	pop	d		;restore <de>
	pop	psw		;and <a> and flags
	ret


;	*****************
;	*  data area 	*
;	*****************

	dseg			;data area

;	*************************
;	* global variables	*
;	*************************

rxbact	db	0	;number of active rx buffer
rxbcbp	dw	0	;pointer to active rx bcb
txbcbp	dw	0	;pointer to active tx bcb

rxbtab:			;table of addresses for rx bcb's
	dw	rxbcb0	
	dw	rxbcb1
	dw	rxbcb2
	dw	rxbcb3
	dw	rxbcb4
	dw	rxbcb5
	dw	rxbcb6
	dw	rxbcb7
	dw	rxbcb8
	dw	rxbcb9
	dw	rxbcba
	dw	rxbcbb
	dw	rxbcbc
	dw	rxbcbd
	dw	rxbcbe
	dw	rxbcbf

txbtab:			;table of addresses for tx bcb's
	dw	txbcb0	
	dw	txbcb1
	dw	txbcb2
	dw	txbcb3
	dw	txbcb4
	dw	txbcb5
	dw	txbcb6
	dw	txbcb7


;	*************************
;	* buffer control blocks	*
;	*************************

; ---> rx buffer control blocks

rxbcb0:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf0		;write pointer
	dw	rxbuf0+fbsize-1	;max value for pointers
	dw	rxbuf0		;min value for pointers
	dw	rxbuf0		;read pointer
	db	0		;ready flag (not used)

rxbcb1:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf1		;write pointer
	dw	rxbuf1+fbsize-1	;max value for pointers
	dw	rxbuf1		;min value for pointers
	dw	rxbuf1		;read pointer
	db	0		;ready flag (not used)

rxbcb2:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf2		;write pointer
	dw	rxbuf2+fbsize-1	;max value for pointers
	dw	rxbuf2		;min value for pointers
	dw	rxbuf2		;read pointer
	db	0		;ready flag (not used)

rxbcb3:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf3		;write pointer
	dw	rxbuf3+fbsize-1	;max value for pointers
	dw	rxbuf3		;min value for pointers
	dw	rxbuf3		;read pointer
	db	0		;ready flag (not used)

rxbcb4:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf4		;write pointer
	dw	rxbuf4+fbsize-1	;max value for pointers
	dw	rxbuf4		;min value for pointers
	dw	rxbuf4		;read pointer
	db	0		;ready flag (not used)

rxbcb5:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf5		;write pointer
	dw	rxbuf5+fbsize-1	;max value for pointers
	dw	rxbuf5		;min value for pointers
	dw	rxbuf5		;read pointer
	db	0		;ready flag (not used)

rxbcb6:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf6		;write pointer
	dw	rxbuf6+fbsize-1	;max value for pointers
	dw	rxbuf6		;min value for pointers
	dw	rxbuf6		;read pointer
	db	0		;ready flag (not used)

rxbcb7:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf7		;write pointer
	dw	rxbuf7+fbsize-1	;max value for pointers
	dw	rxbuf7		;min value for pointers
	dw	rxbuf7		;read pointer
	db	0		;ready flag (not used)

rxbcb8:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf8		;write pointer
	dw	rxbuf8+fbsize-1	;max value for pointers
	dw	rxbuf8		;min value for pointers
	dw	rxbuf8		;read pointer
	db	0		;ready flag (not used)

rxbcb9:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuf9		;write pointer
	dw	rxbuf9+fbsize-1	;max value for pointers
	dw	rxbuf9		;min value for pointers
	dw	rxbuf9		;read pointer
	db	0		;ready flag (not used)

rxbcba:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbufa		;write pointer
	dw	rxbufa+fbsize-1	;max value for pointers
	dw	rxbufa		;min value for pointers
	dw	rxbufa		;read pointer
	db	0		;ready flag (not used)

rxbcbb:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbufb		;write pointer
	dw	rxbufb+fbsize-1	;max value for pointers
	dw	rxbufb		;min value for pointers
	dw	rxbufb		;read pointer
	db	0		;ready flag (not used)

rxbcbc:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbufc		;write pointer
	dw	rxbufc+fbsize-1	;max value for pointers
	dw	rxbufc		;min value for pointers
	dw	rxbufc		;read pointer
	db	0		;ready flag (not used)

rxbcbd:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbufd		;write pointer
	dw	rxbufd+fbsize-1	;max value for pointers
	dw	rxbufd		;min value for pointers
	dw	rxbufd		;read pointer
	db	0		;ready flag (not used)

rxbcbe:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbufe		;write pointer
	dw	rxbufe+fbsize-1	;max value for pointers
	dw	rxbufe		;min value for pointers
	dw	rxbufe		;read pointer
	db	0		;ready flag (not used)

rxbcbf:	dw	0		;count
	dw	fbsize		;max value for count
	dw	rxbuff		;write pointer
	dw	rxbuff+fbsize-1	;max value for pointers
	dw	rxbuff		;min value for pointers
	dw	rxbuff		;read pointer
	db	0		;ready flag (not used)


;*****************************************************

; ---> tx buffer control blocks

txbcb0:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbuf0		;write pointer
	dw	txbuf0+fbsize-1	;max value for pointers
	dw	txbuf0		;min value for pointers
	dw	txbuf0		;read pointer
	db	0		;ready flag (0=not ready)

txbcb1:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbuf1		;write pointer
	dw	txbuf1+fbsize-1	;max value for pointers
	dw	txbuf1		;min value for pointers
	dw	txbuf1		;read pointer
	db	0		;ready flag (0=not ready)

txbcb2:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbuf2		;write pointer
	dw	txbuf2+fbsize-1	;max value for pointers
	dw	txbuf2		;min value for pointers
	dw	txbuf2		;read pointer
	db	0		;ready flag (0=not ready)

txbcb3:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbuf3		;write pointer
	dw	txbuf3+fbsize-1	;max value for pointers
	dw	txbuf3		;min value for pointers
	dw	txbuf3		;read pointer
	db	0		;ready flag (0=not ready)

txbcb4:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbuf4		;write pointer
	dw	txbuf4+fbsize-1	;max value for pointers
	dw	txbuf4		;min value for pointers
	dw	txbuf4		;read pointer
	db	0		;ready flag (0=not ready)

txbcb5:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbuf5		;write pointer
	dw	txbuf5+fbsize-1	;max value for pointers
	dw	txbuf5		;min value for pointers
	dw	txbuf5		;read pointer
	db	0		;ready flag (0=not ready)

txbcb6:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbuf6		;write pointer
	dw	txbuf6+fbsize-1	;max value for pointers
	dw	txbuf6		;min value for pointers
	dw	txbuf6		;read pointer
	db	0		;ready flag (0=not ready)

txbcb7:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbuf7		;write pointer
	dw	txbuf7+fbsize-1	;max value for pointers
	dw	txbuf7		;min value for pointers
	dw	txbuf7		;read pointer
	db	0		;ready flag (0=not ready)

txubcb:	dw	0		;count
	dw	fbsize		;max value for count
	dw	txbufu		;write pointer
	dw	txbufu+fbsize-1	;max value for pointers
	dw	txbufu		;min value for pointers
	dw	txbufu		;read pointer
	db	0		;ready flag (0=not ready)

tempbcb	ds	13		;save area for bcb

;***********************************************************


; ---> buffer control block for list of free rx buffer #'s

rxfree:	dw	0		;count
	dw	numrxb		;max value for count
	dw	lrxfree		;write pointer
	dw	lrxfree+numrxb-1;max value for pointers
	dw	lrxfree		;min value for pointers
	dw	lrxfree		;read pointer
	db	0		;ready flag (not used)


; ---> buffer control block for list of rx frame buffer #'s

rxflst:	dw	0		;count
	dw	numrxb		;max value for count
	dw	lrxfrm		;write pointer
	dw	lrxfrm+numrxb-1	;max value for pointers
	dw	lrxfrm		;min value for pointers
	dw	lrxfrm		;read pointer
	db	0		;ready flag (not used)


; ---> buffer control block for list of rx packet buffer #'s

rxplst:	dw	0		;count
	dw	numrxb		;max value for count
	dw	lrxpkt		;write pointer
	dw	lrxpkt+numrxb-1	;max value for pointers
	dw	lrxpkt		;min value for pointers
	dw	lrxpkt		;read pointer
	db	0		;ready flag (not used)


;************************************************************

; ---> console input buffer control block

cibcb:	dw	0		;count
	dw	cbsize		;max value for count
	dw	cibuff		;write pointer
	dw	cibuff+cbsize-1	;max value for pointers
	dw	cibuff		;min value for pointers
	dw	cibuff		;read pointer
	db	0		;ready flag (not used)

; ---> console output buffer control block

cobcb:	dw	0		;count
	dw	cbsize		;max value for count
	dw	cobuff		;write pointer
	dw	cobuff+cbsize-1	;max value for pointers
	dw	cobuff		;min value for pointers
	dw	cobuff		;read pointer
	db	0		;ready flag (not used)

; ---> console transmit buffer control block

ctbcb:	dw	0		;count
	dw	cbsize		;max value for count
	dw	ctbuff		;write pointer
	dw	ctbuff+cbsize-1	;max value for pointers
	dw	ctbuff		;min value for pointers
	dw	ctbuff		;read pointer
	db	0		;ready flag (not used)

; ---> console receive buffer control block

crbcb:	dw	0		;count
	dw	cbsize		;max value for count
	dw	crbuff		;write pointer
	dw	crbuff+cbsize-1	;max value for pointers
	dw	crbuff		;min value for pointers
	dw	crbuff		;read pointer
	db	0		;ready flag (not used)

; ---> printer output buffer control block

pobcb:	dw	0		;count
	dw	pbsize		;max value for count
	dw	pobuff		;write pointer
	dw	pobuff+pbsize-1	;max value for pointers
	dw	pobuff		;min value for pointers
	dw	pobuff		;read pointer
	db	0		;ready flag (not used)



;	*****************
;	*  buffers	*
;	*****************
	

;	queues of buffer #'s
lrxfree	ds	numrxb		;free rx buffer #'s
lrxfrm	ds	numrxb		;rx frame buffer #'s
lrxpkt	ds	numrxb		;rx packet buffer #'s
	
;	received frame buffers
rxbuf0:	ds	fbsize
rxbuf1:	ds	fbsize
rxbuf2:	ds	fbsize
rxbuf3:	ds	fbsize
rxbuf4:	ds	fbsize
rxbuf5:	ds	fbsize
rxbuf6:	ds	fbsize
rxbuf7:	ds	fbsize
rxbuf8:	ds	fbsize
rxbuf9:	ds	fbsize
rxbufa:	ds	fbsize
rxbufb:	ds	fbsize
rxbufc:	ds	fbsize
rxbufd:	ds	fbsize
rxbufe:	ds	fbsize
rxbuff:	ds	fbsize

;	transmitted frame buffers
txbuf0:	ds	fbsize
txbuf1:	ds	fbsize
txbuf2:	ds	fbsize
txbuf3:	ds	fbsize
txbuf4:	ds	fbsize
txbuf5:	ds	fbsize
txbuf6:	ds	fbsize
txbuf7:	ds	fbsize
txbufu:	ds	fbsize

;	I/O hardware queue buffers
cibuff:	ds	cbsize	;console input buffer
cobuff:	ds	cbsize	;console output buffer
ctbuff:	ds	cbsize	;console transmit buffer
crbuff:	ds	cbsize	;console receive buffer
pobuff:	ds	pbsize	;printer buffer








