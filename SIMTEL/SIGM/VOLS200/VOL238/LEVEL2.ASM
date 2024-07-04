title 'LEVEL2.ASM'
;************************************************
;*						*
;*		LEVEL2.ASM			*
;*						*
;*  X.25 level 2 (HDLC) protocol handler	*
;*  (note that some level2 real time tasks, 	*
;*   such as flag generation/detection, bit	*
;*   stuffing/stripping and CRC generation/	*
;*   checking are handled by the Level 1 	*
;*   hardware (SIO))				*
;*						*
;*  rev 1.52	08/08/84	E. Elizondo	*
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
	maclib	Z80	;DR Z80 macro library

;	assembly time options
false	equ	0
true	equ	not false
debug	equ	true		;display V(s) of tx I frames



;	design parameters
kconst	equ	4		;max # of unack. frames
n2	equ	10		;max # of re-transmissions
kack	equ	10		;acknowledgement delay count

;	X.25 standard parameters:

;	frame addresses (X.25 para 2.4.1)
;	bit #   8765$4321
addra	equ	0000$0011b	;address A
addrb	equ	0000$0001b	;address B

;	frame control (id) bytes (table 3/X.25)
;	bit #   8765$4321
ifid	equ	0000$0000b	;I
rrfid	equ	0000$0001b	;RR
rnrfid	equ	0000$0101b	;RNR
rejfid	equ	0000$1001b	;REJ
sarmfid	equ	0000$1111b	;SARM (not used in LAPB)
dmfid	equ	0000$1111b	;DM
sabmfid	equ	0010$1111b	;SABM
discfid	equ	0100$0011b	;DISC
uafid	equ	0110$0011b	;UA
cmdrfid	equ	1000$0111b	;CMDR
frmrfid	equ	1000$0111b	;FRMR
badfid	equ	1111$1111b	;bad frame for testing

;	misc constants
cr	equ	0dh		;carriage ret
lf	equ	0ah		;line feed
tab	equ	09h		;horizontal tab

;	hooks for other modules

;	subroutines
	public	initl2		;initialize level 2 parameters
	public	rxfrm		;process a received frame
	public	txifrm		;transmit I frame if avail
	public	conlk		;connect link
	public	disclk		;disconnect link
	public	qlksta		;query link status
	public	gettxb		;get address of free tx bcb
	public	txbadf		;transmit bad frame

;	addresses
	public	lkstat		;level 2 link status bits
	public	l2stat		;level 2 status bits
	public	dtemod		;DTE/DCE mode flag

;	level 2 parameters
	public	vs		;V(s)
	public	vr		;V(r)
	public	lastnr		;last received N(r)
	public	lastvr		;last transmitted V(r)
	public	lastvs		;last transmitted V(s)
	public	maxvs		;highest tx V(s)
	public	pfbit		;P/F bit

;	diagnostic counters
	public	rxifct		;received I frame count
	public	rxcfct		;received cmd frames
	public	rxrfct		;received resp frames
	public	rbafct		;received bad addr frames
	public	rxbcct		;received bad cmd frames
	public	rxbrct		;received bad rsp frames
	public	txfct		;transmitted frame count
	public	txifct		;transmitted I frame count
	public	txirct		;tx I retransmission log

;	definition of lkstat status bits
;	(note DTE busy comes from level1)
;	bit	set condition
;	0	link connect in process
;	1	link disconnect in process
;	2	link connected
;	3	DCE busy
;	4	DTE busy
;	5	unassigned
;	6	DTE REJ condition
;	7	DCE REJ condition


;	definition of l2stat status bits
;	bit	set condition
;	0	link query in process
;	1	DTE FRMR condition
;	2	DCE FRMR condition
;	3	unassigned
;	4	unassigned
;	5	unassigned
;	6	retransmit old I frame
;	7	timer recovery condition

;	external subroutines

;	from buffers module:
	extrn	inibuf		;initialize all buffers
	extrn	putbuf		;put char in buffer
	extrn	getbuf		;get char from buffer
	extrn	dcrbuf		;delete last char in buffer
	extrn	bpoint		;point to selected bcb
	extrn	rlsrxb		;release rx buffer
	extrn	clrbuf		;clear buffer for new use
	extrn	clrtxb		;clear all tx buffers
	extrn	savbcb		;save bcb pointers
	extrn	getbct		;get buffer count
	extrn	getrdy		;get state of buffer ready flag

;	from level1 module:
	extrn	txwake		;wake up transmitter
	extrn	t1on		;turn on timer T1
	extrn	t1off		;turn off timer T1

;	from level 3 module:
	extrn	initl3		;initialize level 3
	extrn	txstar		;transmit restart packet
;
;	from xutil module:
	extrn	ilprt		;in line print routine
	extrn	pdec		;print <hl> in decimal
	extrn	phex		;print <a> in hex
	extrn	pbin		;print <a> in binary
	extrn	ctype		;print ASCII char in <a>
	extrn	poll		;poll non-interrupt hardware

;	from files module
	extrn	fstat		;file status flags
	extrn	ctxfil		;close transmit file
	extrn	crxfil		;close receive file
	extrn	logdat		;write byte to log file

;	external addresses
	
;	from level 1 module
	extrn	tistat	;timer status flags
	extrn	txstat	;transmit status flags
	extrn	txaddr	;transmit address byte
	extrn	txctrl	;transmit control byte

;	from buffers module
	extrn	rxfree	;A(list of free rx buffer #'s)
	extrn	rxflst	;A(list of rx frame buffer #'s)
	extrn	rxplst	;A(list of rx packt buffer #'s)
	extrn	rxbtab	;A(table of rx bcb pointers)
	extrn	txbtab	;A(table of tx bcb pointers)
	extrn	txbcbp	;A(active tx bcb for I frames)
	extrn	txubcb	;A(tx bcb for CMDR frames)

;	from files module
	extrn	fstat	;file status



;	*********************************
;	*  initialization section	*
;	*********************************

	cseg		;code section

;	initialize level 2 parameters
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, regs clobbered

initl2:	lda	dtemod		;get mode flag
	cpi	1		;DTE mode?
	jnz	init1		;no, keep going
;
;	initialize in DTE mode
	mvi	a,addra		;yes, set up address=A 
	sta	rxcaddr		;for incoming commands
	sta	txraddr		;and outgoing responses
	mvi	a,addrb		;set up address=B
	sta	txcaddr		;for outgoing commands
	sta	rxraddr		;and incoming responses
	jmp	init3		;and continue
;
init1:	cpi	2		;DCE mode?
	jnz	init2		;no, keep going
;
;	initialize as DCE
	mvi	a,addrb		;set up address=B
	sta	rxcaddr		;for incoming commands
	sta	txraddr		;and outgoing responses
	mvi	a,addra		;set up address=A
	sta	txcaddr		;for outgoing commands
	sta	rxraddr		;and incoming responses
	jmp	init3		;and conitnue
;
;	initialize for self test (with loopback connector)
init2:	mvi	a,addra		;set up address=A
	sta	rxcaddr		;for incoming commands
	sta	txcaddr		;and outgoing commands
	mvi	a,addrb		;set up address=B
	sta	txraddr		;for outgoing responses
	sta	rxraddr		;and incoming responses
;
init3:	call	reset		;reset all variables
	xra	a		;reset p/f bit
	sta	pfbit		;p/f=0
	ret


;	reset all flow control variables
;	(internally called)
;	on entry:	no parameters
;	on exit:	<a>,flags clobbered

reset:	xra	a		;initialize variables
	sta 	vs		;V(s)=0
	sta	vr		;V(r)=0
	sta	l2stat		;clear level 2 status flags
	sta	lkstat		;clear link status word
	sta	tistat		;clear all timeouts
	sta	lastnr		;last received N(r)
	sta	lastvr		;last transmitted V(r)
	mvi	a,7		;initialize...
	sta	lastvs		;last transmitted V(s)
	sta	maxvs		;max transmitted V(s)
	call	clrtxb		;clear all tx buffers
	ret




;	*************************
;	*  link control section	*
;	*************************

;	connect level 2 link
;	(externally called)
;	on entry:	no paramters
;	on exit:	all regs, flags clobbered
	
conlk:
	call	reset		;reset all flow control variables
	call	initl3		;initialize level 3
	lxi	h,lkstat	;point to link status word
	setb	0,m		;set link connect in process
	mvi	a,n2		;set retry counter=n2
	sta	rtryct		;	/
	call	ilprt		;tell what's doing
	db	cr,lf,'L2: attempting link connect...',cr,lf,0
	jmp	txsabm		;and transmit SABM command



;	disconnect level 2 link
;	(externally called)
;	on entry:	no paramters
;	on exit:	all regs, flags clobbered

disclk:
	call	crxfil		;close receive file if open
	call	ctxfil		;close receive file if open
	call	clrtxb		;clear all tx I buffers
	lxi	h,lkstat	;point to link status
	res	1,m		;clear disc in process
	bit	2,m		;is link connected?
	jnz	disc1		;yes, keep going
;
	call	ilprt		;else tell operator
	db	'L2: link is already disconnected',cr,lf,0
	ret
;
disc1:	setb	1,m		;signal disc in process
	mvi	a,n2		;set retry count= n2
	sta	rtryct		;	/
	call	ilprt		;and tell operator
	db	cr,lf,'L2: attempting link disconnect...',cr,lf,0
	jmp	txdisc		;and transmit disconnect command


;	query link status
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags clobbered

qlksta:	lxi	h,lkstat	;point to link status word
	bit	2,m		;link connected?
	jnz	qlk1		;yes, keep going
;
	call	ilprt		;else tell operator
	db	'L2: dte link is disconnected',cr,lf,0
	ret
;
;	determine dte status
qlk1:	push	h		;save <hl>
	lxi	h,l2stat	;point to flow status word
	bit	1,m		;DTE FRMR/CMDR condition?
	pop	h		;restore <hl>
	jz	qlk2		;no, keep going
;
	call	ilprt		;else tell operator
	db	'L2: dte in FRMR/CMDR condition',cr,lf,0
	jmp	qlk5		;and get dce status
;	
qlk2:	bit	4,m		;dte busy?
	jz	qlk3		;no, keep going
;
	call	ilprt		;else tell operator
	db	'L2: dte busy',cr,lf,0
	jmp	qlk5		;and get dce status
;
qlk3:	bit	6,m		;dte reject condition?
	jz	qlk4		;no, keep going
;
	call	ilprt		;else tell operator
	db	'L2: dte in REJ condition',cr,lf,0
	jmp	qlk5		;and get dce status
;
qlk4:	call	ilprt		;tell operator we are ready
	db	'L2: dte ready',cr,lf,0

;	interogate DCE status
qlk5:	lxi	h,l2stat	;point to level 2 status
	setb	0,m		;signal query in process
	mvi	a,n2		;set retry count =n2
	sta	rtryct		;	/
	call	ilprt		;tell operator
	db	'L2: interrogating dce status...',cr,lf,0
;
;	return here for retries
qdce:
	lxi	h,pfbit		;set p=1
	setb	4,m		;	/
	lxi	h,lkstat	;point to link status
	bit	4,m		;dte busy?
	jnz	txrnrc		;yes, transmit RNR command
;
	bit	6,m		;dte rej condition?
	jnz	txrejc		;yes, transmit REJ command
;
	jmp	txrrc		;else transmit RR command



;	*************************
;	*  transmit section	*
;	*************************

;	*** miscellaneous ***

;	get address of free tx buffer bcb
;	(externally called)
;	on entry:	no parameters
;	on exit:	carry set if no free buffer avail
;			<hl>= bcb address if buffer avail
;			<a>, other flags clobbered

gettxb:	push	b		;save regs
	push	d		;	/
	lda	lastnr		;get last acknowledged N(r)
	dcr	a		;back up two, mod 7
	dcr	a		;	/
	ani	7		;      /
	mov	b,a		;<b> is last possible bcb #
	lda	maxvs		;<a> is first possible bcb #
	inr	a		;	/
	ani	7		;      /
gettx1:	cmp	b		;are they equal?
	stc			;yes, return with carry set
	jz	getxit		;	/
;
	lxi	h,txbtab	;else, get bcb address
	call	bpoint		;	/
	call	getrdy		;is buffer empty?
	jz	getxok		;yes, got one
;
	inr	a		;else, look at next one
	ani	7		;mod 7, of course
	jmp	gettx1		;	/
;
getxok:	stc			;clear carry flag
	cmc			;	/
getxit:	pop	d		;restore regs
	pop	b		;	/
	ret


;	*** outgoing commands ***


;	check for timeout condition and 
;	transmit I frame if available and
;		a) link connected
;		b) DCE not busy
;		c) level 1 (SIO) not already transmitting
;		d) not in FRMR condition
;		e) new frame within window
;		f) frame ready flag <>0
;	if I frame can't be transmitted, transmit
;	RR or RNR frame to acknowledge received I frames
;
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags clobbered


txifrm:	
;	check for level 1 ready
	lxi	h,txstat	;point to level 1 (SIO) status
	bit	0,m		;tx busy?
	rnz			;yes, try again later
;
;	check for timeout
	lxi	h,tistat	;point to timer status
	bit	0,m		;timer T1 timed out?
	jnz	t1to		;yes, service it
;
;	check for level 2 ready
	lxi	h,lkstat	;point to link status
	bit	2,m		;link connected?
	rz			;no, return
;
;	check if in timer recovery condition
	lxi	h,l2stat	;point to flow status
	bit	7,m		;timer recovery condition?
	jz	txi1		;no, keep going
;	
;	timer recovery condition
	push	h		;save flow status word
	lxi	h,pfbit		;set P=1
	setb	4,m		;   /
	pop	h		;restore flow status word
	bit	6,m		;time to transmit again?
	jz	txack		;no, see if we want to acknowledge
;
	bit	2,m		;DCE FRMR/CMDR condition?
	jnz	qlksta		;yes, verify again & restart
;
	lxi	h,lkstat	;point to link status
	bit	3,m		;DCE busy?
	jnz	txack		;yes, don't transmit I frame
;
	lxi	h,l2stat	;point to level 2 status
	res	6,m		;else reset restransmission flag
	jmp	txi2		;and retransmit I frame
;
;	not in timer recovery condition
txi1:	bit	2,m		;DCE FRMR/CMDR condition?
	rnz			;yes, don't transmit I frames
;
	bit	0,m		;link query in process?
	rnz			;yes, dont transmit yet
;
	lxi	h,lkstat	;point to link status
	bit	3,m		;DCE busy?
	jnz	txack		;yes, don't transmit I frame
;
;	did we transmit new frame already?
	lda	lastvs		;get last transmitted V(s)
	mov	b,a		;save in <b>
	lda	vs		;get present vs
	cmp	b		;same?
	jz	txack		;yes, don't transmit I frame
;
;	else set up retry counter for new frame
	mvi	a,n2		;else initialize retry count
	sta	rtryct		;	/
	lxi	h,pfbit		;and set p=0
	res	4,m		;	/
;
;	check that V(s) is within window
txi2:	lda	lastnr		;get last valid N(r)
	adi	kconst+1	;calculate just past top of window
	ani	7		;mod 7
	mov	e,a		;save in <e>
	lda	vs		;get V(s)
	cmp	e		;is V(s) past top of window?
	jz	txack		;yes, don't transmit it yet
;
;	is tx buffer ready?
txi2a	lxi	h,txbtab	;point to tx bcb table
	lda	vs		;get V(s)
	call	bpoint		;get address of bcb
	call	getrdy		;is buffer ready to tx?
	jz	txack		;no, some other time
;
;	transmit frame if not empty and ready
	shld	txbcbp		;make buffer active
	call	savbcb		;and save bcb pointers
	lda	txcaddr		;<d>=outgoing command address
	mov	d,a		;	/
;
	lda	vs		;get V(s)
	sta	lastvs		;update last tx V(s)
;
	if	debug		;if debug mode
	push	psw		;save V(s)
	adi	'0'		;convert to ASCII
	call	ctype		;display it
	pop	psw		;restore V(s)
	endif			;end of debug mode
;
	mvi	b,ifid		;<b>=I control byte
	rlc			;rotate V(s) into bits 1-3
	ora	b		;merge with control byte
	mov	b,a		;save result in <b>
	lda	vr		;get V(r) (outgoing N(r))
	sta	lastvr		;update last tx V(r)
	mov	c,a		;save in <c>
	call	txframe		;transmit frame
	call	t1on		;turn on timer T1
	lhld	txifct		;increment tx I frame count
	inx	h		;	/
	shld	txifct		;      /
	mvi	a,kack		;reset acknowledgement delay counter
	sta	ackcnt		;	/
;
;	timer recovery condition?
	lxi	h,l2stat	;point to level 2 status
	bit	7,m		;timer recovery condition?
	rnz			;yes, don't update V(s)
;
;	update V(s) to send next frame
	lda	vs		;get V(s)
	mov	b,a		;and save in <b>
	inr	a		;V(s)=V(s)+1 mod 7
	ani	7		;	/
	sta	vs		;update V(s) for next frame
;
;	update max V(s) for acknowledge routine
	lda	maxvs		;get current max V(s)
txi4:	cmp	b		;is max V(s)= last tx V(s)
	jz	txi5		;yes, exit
;	
	cmp	e		;past top of window?
	rz			;yes, maxvs was max
;
	inr	a		;else bump max V(s) mod(7)
	ani	7		;	/
	jmp	txi4		;and keep looping
;
txi5:	sta	maxvs		;update max V(s)
	ret			;and exit
;
;	transmit acknowledgement instead of I frame
txack:	lda	lastvr		;get last transmitted V(r)
	mov	b,a		;save in <b>
	lda	vr		;get V(r)
	cmp	b		;same?
	rz			;yes, nothing to acknowledge
;
;	wait a few tries to see if any I frames are coming
	lda	ackcnt		;get delay count
	dcr	a		;decrement count
	sta	ackcnt		;and update count
	rnz			;wait a little longer until 0
;
;	delay count is 0, transmit acknowledge frame
	mvi	a,kack		;reset delay count
	sta	ackcnt		;	/
	lxi	h,lkstat	;else point to link status
	bit	4,m		;DTE busy?
	jnz	txrnrr		;yes, transmit RNR frame
;
	jmp	txrrr		;else transmit RR frame




;	process timer T1 timeout condition
;	(internally called)
;	on entry:	no parameters
;	on exit:	all regs, flags clobbered

t1to:	
	call	t1off		;stop timer T1
	lxi	h,rtryct	;get retry count
	dcr	m		;last retry?
	jz	t1to9		;yes, other end is dead
;
	lxi	h,lkstat	;point to link status
	bit	0,m		;link connect in process?
	jz	t1to1		;no, keep going
;
;	link connect is in process
	call	ilprt		;print countdown
	db	tab,'SABM tries to go =',0
	lda	rtryct		;print countdown
	mov	l,a		;	/
	mvi	h,0		;      /
	call	pdec		;     /
	call	ilprt		;    /
	db	cr,lf,0		;   /
	jmp	txsabm		;and transmit SABM
;
t1to1:	bit	1,m		;disconnect in process?
	jz	t1to2		;no, keep going
;
;	link disconnect is in process
	call	ilprt		;print countdown
	db	tab,'DISC tries to go =',0
	lda	rtryct		;print countdown
	mov	l,a		;	/
	mvi	h,0		;      /
	call	pdec		;     /
	call	ilprt		;    /
	db	cr,lf,0		;   /
	jmp	txdisc		;and transmit DISC
;
t1to2:	lxi	h,l2stat	;point to level 2 status
	bit	0,m		;link query in process
	jz	t1to3		;no, keep going
;
;	link query is in process
	call	ilprt		;print countdown
	db	tab,'query tries to go =',0
	lda	rtryct		;print countdown
	mov	l,a		;	/
	mvi	h,0		;      /
	call	pdec		;     /
	call	ilprt		;    /
	db	cr,lf,0		;   /
	jmp	qdce		;and query dce
;
;	check that link is connected
t1to3:	lxi	h,lkstat	;point to link status flags
	bit	2,m		;link connected?
	rz			;no, just return

;	information flow is in process
;	timeout recovery (x.25 para 2.4.6.8)
	lxi	h,l2stat	;point to level 2 status
	setb	7,m		;indicate timer recovery condition
	setb	6,m		;set flag for retransmission
	call	ilprt		;tell what we're doing
	db	cr,lf,'L2: T1 timed out - '
	db	'retransmitting I frame',0
	lda	lastnr		;make V(s)=last received N(r)
	sta	vs		;	/
	mov	l,a		;print V(s)
	mvi	h,0		;	/
	call	pdec		;      /
	call	ilprt		;and try number
	db	' - tries to go =',0
	lda	rtryct		;      /
	mov	l,a		;     /
	mvi	h,0		;    /
	call	pdec		;   /
	call	ilprt		;terminate line
	db	cr,lf,0		;	/
	lxi	h,pfbit		;set p=1
	setb	4,m		;	/
	lhld	txirct		;increment retransmission log
	inx	h		;	/
	shld	txirct		;      /
	ret
;
;	retry count exhausted
t1to9:	call	ilprt
	db	'L2: tx retry count exhausted - '
	db	'no reply from DCE',cr,lf,0
	lxi	h,lkstat	;point to link status
	bit	1,m		;was disconnect in process?
	jz	t1to10		;no, keep going
;
;	disconnect was already in process
	res	1,m		;clear disconnect in process
	res	2,m		;and clear link connect flag
;
t1to10:	bit	2,m		;link connected?
	rz			;no, return
;
;	link was connected (?)
	call	ilprt
	db	'L2; disconnecting link',cr,lf,0
	jmp	disclk		;and disconnect



;	transmit SABM command frame
;	(internally called)
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txsabm:	lxi	h,lkstat	;point to link status
	setb	0,m		;signal connect in process
	lda	txcaddr		;<d>=outgoing command address
	mov	d,a		;	/
	mvi	b,sabmfid	;<b>=SABM control byte
	mvi	c,0		;SABM is unnumbered
	call	txframe		;transmit frame
	call	t1on		;and turn on timer T1
	ret

;	transmit DISC command frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txdisc:	lda	txcaddr		;<d>=outgoing command address
	mov	d,a		;	/
	mvi	b,discfid	;<b>=DISC control byte
	mvi	c,0		;DISC is unnumbered
	call	txframe		;transmit frame
	call	t1on		;and turn on timer T1
	ret

;	transmit bad command frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txbadf:	lda	txcaddr		;<d>=outgoing command address
	mov	d,a		;	/
	mvi	b,badfid	;<b>=bad control byte
	mvi	c,0		;make it unnumbered
	call	txframe		;transmit frame
	ret

;	transmit RR command frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txrrc:	lda	txcaddr		;<d>=outgoing command address
	mov	d,a		;	/
	mvi	b,rrfid		;<b>=RR control byte
	lda	vr		;get V(r)
	sta	lastvr		;update last tx V(r)
	mov	c,a		;save in <c>
	call	txframe		;transmit frame
	call	t1on		;turn on timer T1
	ret

;	transmit RNR command frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txrnrc:	lda	txcaddr		;<d>=outgoing command address
	mov	d,a		;	/
	mvi	b,rnrfid	;<b>=RNR control byte
	lda	vr		;get V(r)
	sta	lastvr		;update last tx V(r)
	mov	c,a		;save in <c>
	call	txframe		;transmit frame
	call	t1on		;and turn on timer T1
	ret

;	transmit REJ command frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txrejc:	lda	txcaddr		;<d>=outgoing command address
	mov	d,a		;	/
	mvi	b,rejfid	;<b>=REJ control byte
	lda	vr		;get V(r)
	sta	lastvr		;update last tx V(r)
	mov	c,a		;save in <c>
	call	txframe		;transmit frame
	call	t1on		;and turn on timer T1
	ret


;	*** outgoing responses ***


;	transmit RR response frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txrrr:	lda	txraddr		;<d>=outgoing response address
	mov	d,a		;	/
	mvi	b,rrfid		;<b>=RR control byte
	lda	vr		;get V(r)
	sta	lastvr		;update last tx V(r)
	mov	c,a		;save in <c>
	call	txframe		;transmit frame
	ret

;	transmit RNR response frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txrnrr:	lda	txraddr		;<d>=outgoing response address
	mov	d,a		;	/
	mvi	b,rnrfid	;<b>=RNR control byte
	lda	vr		;get V(r)
	sta	lastvr		;update last tx V(r)
	mov	c,a		;save in <c>
	call	txframe		;transmit frame
	ret

;	transmit REJ response frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txrejr:	lda	txraddr		;<d>=outgoing response address
	mov	d,a		;	/
	mvi	b,rejfid	;<b>=REJ control byte
	lda	vr		;get V(r)
	sta	lastvr		;update last tx V(r)
	mov	c,a		;save in <c>
	call	txframe		;transmit frame
	ret

;	transmit DM response frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txdm:	lda	txraddr		;<d>=outgoing response address
	mov	d,a		;	/
	mvi	b,dmfid		;get DM control byte
	mvi	c,0		;DM is unnumbered
	call	txframe		;transmit frame
	ret

;	transmit UA response frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txua:	lda	txraddr		;<d>=outgoing response address
	mov	d,a		;	/
	mvi	b,uafid		;get UA control byte
	mvi	c,0		;UA is unnumbered
	call	txframe		;transmit frame
	ret


;	transmit CMDR/FRMR response frame
;	on entry:	no paramters
;	on exit:	all flags, regs clobbered

txfrmr:
txcmdr:	lxi	h,txstat	;point to link SIO status
	bit	0,m		;tx busy?
	jnz	txcmdr		;yes, wait
;
	lxi	h,l2stat	;point to flow status word
	setb	1,m		;set DTE FRMR condition flag
	lxi	h,txubcb	;point to CMDR frame buffer
	shld	txbcbp		;and make buffer active
	lda	cmdrf1		;get rejected cmd control byte
	call	putbuf		;put in buffer
	lda	vs		;get V(s)
	rlc			;rotate into bits 1-3
	mov	b,a		;save in <b>
	lda	vr		;get V(r)
	rlc			;rotate into bits 5-7
	rlc			;	/
	rlc			;      /
	rlc			;     /
	rlc			;    /
	ora	b		;merge with V(s)
	call	putbuf		;put in buffer
	lda	cmdrf3		;get error indicator byte
	call	putbuf		;put in buffer
	lda	txraddr		;<d>=outgoing response address
	mov	d,a		;	/
	mvi	b,cmdrfid	;<b>=CMDR control byte
	mvi	c,0		;CMDR is unnumbered
	call	txframe		;transmit frame
	ret

	
;	***  common routines ***


;	transmit frame
;	(internally called)
;	on entry:	<b>=frame control byte
;			<c>=0 if unnumbered, N(r) otherwise
;			<d>=frame address byte
;			pfbit=poll/final bit in pos 4
;	on exit:	flags, registers clobbered
;			txaddr= address byte
;			txctrl= control byte


txframe:
	lhld	txfct		;increment tx frame counter
	inx	h		;	/
	shld	txfct		;      /
	lxi	h,txstat	;point to SIO status
txf1:	bit	0,m		;tx busy?
	jnz	txf1		;yes, wait
;
	mov	a,d		;get address byte
	sta	txaddr		;store address
	mov	a,c		;get N(r)
	rlc			;rotate into bits 5-7
	rlc			;	/
	rlc			;      /
	rlc			;     /
	rlc			;    /
	ora	b		;merge with control byte
	mov	b,a		;save result in <b>
	lda	pfbit		;get poll/final bit
	ora	b		;merge it into control byte
	sta	txctrl		;store control byte
	call	logtx		;log transmission
	xra	a		;clear p/f bit for next frame
	sta	pfbit		;	/
	call	txwake		;start transmission and T1 timer
	ret


;	log transmitted frame
;	(internally called)
;	on entry:	txaddr= address byte
;			txctrl= control byte
;	on exit:	<a>, flags clobbered
;			all other regs unchanged
logtx:	push	h		;save <hl>
	lxi	h,fstat		;point to file status
	bit	7,m		;log file open?
	pop	h		;restore <hl>
	rz			;no, return with no action
;
	mvi	a,1		;else signal tx frame
	call	logdat		;put in file
	lda	txaddr		;get address
	call	logdat		;put in file
	lda	txctrl		;get control
	call	logdat		;put in file
	xra	a		;and put zeros in rest of block
	call	logdat		;		/
	call	logdat		;              /
	call	logdat		;             /
	call	logdat		;            /
	call	logdat		;           /
	call	logdat		;          /
	call	logdat		;         /
	call	logdat		;        /
	call	logdat		;	/
	call	logdat		;      /
	call	logdat		;     /
	call	logdat		;    /
	call	logdat		;   /
	ret




;	*************************
;	*  receive section	*
;	*************************


;	process a received frame if available
;	(internally and externally called)
;	on entry:	no parameters
;	on exit:	<c>=buffer # if available
;			<hl>=bcb address if available
;			<d>=address byte

rxfrm:
	lxi	h,rxflst	;point to list of rx frames
	call	getbuf		;any waiting?
	rc			;no, return
;
	mov	c,a		;save buffer # in <c>
	lxi	h,rxbtab	;point to table of buffer addresses
	call	bpoint		;get address of bcb
	call	dcrbuf		;discard CRC-1 byte
	call	getbuf		;get address byte
	jnc	rxfrm0		;keep going if there
;
;	empty frame
	mov	a,c		;else release rx buffer
	call	rlsrxb		;	/
	call	ilprt		;and tell operator
	db	'L2: rx empty frame (no control byte)',cr,lf,0
	ret
;
rxfrm0:	mov	d,a		;save in <d>
	lda	rxcaddr		;incoming command?
	cmp	d		;	/
	jz	incmd		;yes, process it
;
	lda	rxraddr		;incoming response?
	cmp	d		;	/
	jz	inresp		;yes, process it
;
;	process bad address
	call	ilprt
	db	cr,lf,'L2: bad rx address: ',0
	mov	a,d		;get bad address byte
	call	phex		;print address in hex
;
;***	dump entire frame in hex for debug
	if	debug
	call	ilprt
	db	cr,lf,'L2: frame contents: ',0
rxfrlp: call	getbuf		;get next octet
	jc	rxfrm1		;exit if no more
	call	phex		;print it in hex
	mvi	a,' '		;and a separator
	call	ctype		;	/
	jmp	rxfrlp		;and go back for more
	endif			;end of debug option
;
rxfrm1:
	call	ilprt		;terminate error msg line
	db	cr,lf,0		;	/
	mov	a,c		;get rx buffer #
	call	rlsrxb		;and release it
	lhld	rbafct		;increment bad address counter
	inx	h		;	/
	shld	rbafct		;      /
	ret


;	process incoming comand frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<c>= rx buffer #
;			<d>=address byte 
;	on exit:	<b>=control byte
;			<c>,<d>,<hl> unchanged

incmd:	call	getbuf		;get control byte
	jnc	incmd1		;if there is one
;
	mov	a,c		;else release rx buffer
	call	rlsrxb		;	/
	lhld	rxbcct		;increment bad command count
	inx	h		;	/
	shld	rxbcct		;      /
	ret
;
incmd1:	mov	b,a		;save control byte in <b>
	sta	cmdrf1		;save it in case of CMDR
	ani	0001$0000b	;extract P bit
	sta	pfbit		;set F bit for reply
	push	h		;save <hl>
	lhld	rxcfct		;increment rx command count
	inx	h		;	/
	shld	rxcfct		;      /
	call	logrx		;log received frame
	lxi	h,lkstat	;point to link status word
	bit	2,m		;link disconnected?
	pop	h		;restore <hl>
	jz	dphase		;yes, process disconnected phase 
;
;	link is connected
;	branch to know frame id's
	mov	a,b		;get control byte
	bit	0,a		;I frame?
	jz	rxi		;yes, process it
;
	ani	1110$1111b	;extract all bits except p/f
	cpi	sabmfid		;SABM frame?
	jz	rxsabm		;yes, process it
;
	cpi	discfid		;DISC frame?
	jz	rxdisc		;yes, process it
;
;	branch to numbered frames
	ani	0000$1111b	;discard N(r) sequence bits
	cpi	rrfid		;RR command frame?
	jz	rxcrr		;yes, process it
;
	cpi	rnrfid		;RNR command frame?
	jz	rxcrnr		;yes, process it
;
	cpi	rejfid		;REJ command frame?
	jz	rxcrej		;yes, process it
;
;	unrecognized frame identifier
	mov	a,c		;else get buffer #
	call	rlsrxb		;discard unknown rx frame
	lhld	rxbcct		;increment bad cmd counter
	inx	h		;	/
	shld	rxbcct		;      /
	lxi	h,cmdrf2	;clear CMDR bit 13 for cmd
	res	4,m		;	/
	lxi	h,cmdrf3	;set CMDR bit W
	setb	0,m		;	/
	res	1,m		;and reset bit X
	res	2,m		;and bit Y
	res	3,m		;and bit Z
	jmp	txcmdr		;and transmit CMDR
;
;	process link disconnected phase
dphase:
	mov	a,c		;get rx buffer #
	call	rlsrxb		;and release buffer
	mov	a,b		;get control byte
	ani	1110$1111b	;strip p bit
	cpi	sabmfid		;SABM frame?
	jz	rxsabm		;yes, process it
;
;	reply DM to any other command frames with P=1
	bit	4,b		;P=1?
	rz			;no, exit
;
	jmp	txdm		;yes, send DM response



;	log incoming frame
;	(internally called)
;	on entry:	<b>=control byte
;			<d>=address byte
;	on exit:	<a>,flags clobbered
;			all other regs unchanged
logrx:	push	h		;save <hl>
	lxi	h,fstat		;point to file status
	bit	7,m		;log file open?
	pop	h		;restore <hl>
	rz			;no, do nothing
;
	mvi	a,0		;else signal rx frame
	call	logdat		;and put in file
	mov	a,d		;get address
	call	logdat		;and put in file
	mov	a,b		;get control byte
	call	logdat		;and put in file
	xra	a		;put zeroes in rest of block
	call	logdat		;		/
	call	logdat		;	       /
	call	logdat		;	      /
	call	logdat		;	     /
	call	logdat		;	    /
	call	logdat		;	   /
	call	logdat		;	  /
	call	logdat		;	 /
	call	logdat		;	/
	call	logdat		;      /
	call	logdat		;     /
	call	logdat		;    /
	call	logdat		;   /
	ret	



;	process received SABM command frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxsabm:	call	getbuf		;check if any I bits
	jnc	cfmterr		;yes, format error
;
	mov	a,c		;get rx buffer #
	call	rlsrxb		;release buffer
	call	t1off		;turn off timer T1
	call	reset		;clear flow control variables
	lxi	h,lkstat	;point to link status
	setb	2,m		;set link active flag
	call	ilprt		;tell operator link is ok
	db	'L2: rx SABM - link connected by dce',cr,lf,0
	jmp	txua		;and transmit UA


;	process received DISC command frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxdisc:	call	getbuf		;check if any I bits
	jnc	cfmterr		;yes, format error
;
	mov	a,c		;release rx buffer
	call	rlsrxb		;	/
	call	t1off		;turn off timer T1
	lxi	h,lkstat	;point to link status
	mvi	m,0		;clear everything
	setb	2,m		;except link connected
	setb	1,m		;and link disc in process
	call	ilprt		;tell operator link is down
	db	'L2: rx DISC - link disconnected by dce',cr,lf,0
	call	txua		;transmit UA
	lxi	h,lkstat	;point to link status
	res	1,m		;clear disc in process
	res	2,m		;and link connected
	ret


;	process received RR command frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxcrr:	call	ackdge		;acknowledge pending frames
	jc	badnr		;exit if invalid N(r)
;
	call	getbuf		;another byte in buffer?
	jnc	cfmterr		;yes, format errer
;
	lxi	h,lkstat	;point to link status byte
	res	3,m		;clear DCE busy
	res	7,m		;clear DCE reject condition
	jmp	rxsc		;and process supervisory cmd

	
;	process received RNR command frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxcrnr:	call	ackdge		;acknowledge pending frames
	jc	badnr		;exit if invalid N(r)
;
	call	getbuf		;another byte in buffer?
	jnc	cfmterr		;yes, format errer
;
	mvi	a,n2		;reset tx retry counter
	sta	rtryct		;	/
	lxi	h,lkstat	;point to link status byte
	setb	3,m		;set DCE busy
	res	7,m		;clear DCE reject condition
	jmp	rxsc		;and process supervisory cmd

	
;	process received REJ command frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxcrej:	call	ackdge		;acknowledge pending frames
	jc	badnr		;exit if invalid N(r)
;
	call	getbuf		;another byte in buffer?
	jnc	cfmterr		;yes, format errer
;
	lxi	h,lkstat	;point to link status byte
	res	3,m		;clear DCE busy
	setb	7,m		;set DCE reject condition flag
	mvi	a,n2		;initialize retry counter
	sta	rtryct		;	/
	mov	a,b		;get control byte
	call	getnr		;extract valid N(r)
	sta	vs		;set V(s)=N(r) for retransmission
	sta	maxvs		;and update max V(s) for acknowledge
;
rxsc:				;process supervisory cmd
	mov	a,c		;release rx buffer
	call	rlsrxb		;	/
	bit	4,b		;P=1?
	rz			;no, do nothing here
;
	lxi	h,lkstat	;point to link status word
	bit	4,m		;DTE busy?
	jz	txrrr		;no, transmit RR response
	jmp	txrnrr		;yes, transmit RNR response


;	handle invalid received N(r)
;	on entry:	<c>=rx buffer #
badnr:	mov	a,c		;get rx buffer #
	call	rlsrxb		;release it

;*** below message added for diagnostic
	call	ilprt
	db	'L2: bad received N(r)',cr,lf,0

;	set up FRMR information fields
	lxi	h,cmdrf3	;point to CMDR field 3
	res	0,m		;reset bits W, X and Y
	res	1,m		;	/
	res	2,m		;      /
	setb	3,m		;set bit Z for invalid N(r)
	jmp	txfrmr		;and transmit FRMR




;	handle received frame format error
;	(I field in a non I frame)
;	(internally called)
;	on entry:	<hl>=bcb address
;			<c>=buffer #

cfmterr:			;error in command frame
	lxi	h,cmdrf2	;point to CMDR field 2
	res	4,m		;reset bit 4 for commands
	jmp	fmterr		;and continue
;
rfmterr:			;error in response frame
	lxi	h,cmdrf2	;point to CMDR field 2
	setb	4,m		;set bit 4 for responses
fmterr:	mov	a,c		;get rx buffer #
	call	rlsrxb		;release buffer
	lxi	h,cmdrf3	;point to CMDR field 3
	setb	0,m		;set bit W
	setb	1,m		;and bit X
	res	2,m		;reset bit Y
	res	3,m		;and bit Z
	jmp	txcmdr		;and transmit CMDR



;	process received I frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #
;	on exit:	flags, regs clobbered

rxi:	call	ackdge		;acknowledge tx frame
	jc	badnr		;exit if invalid N(r)
;
rxi1:	push	h		;save bcb address
	lxi	h,lkstat	;point to link status
	res	7,m		;clear DCE REJ condition
	pop	h		;restore bcb address
	mov	a,b		;get control byte
	ani	0000$1110b	;extract N(s)
	rrc			;move to bits 0-2
	mov	b,a		;and save in <b>
	lda	vr		;get V(r)
	cmp	b		;is N(s)=V(r)?
	jz	rxi2		;yes, keep going
;
;	process invalid received N(s)
	mov	a,c		;else get rx buffer #
	call	rlsrxb		;release buffer
	lxi	h,lkstat	;point to link status
	setb	6,m		;set REJ condition
	jmp	txrejr		;and transmit REJ response
;
;	process valid N(s) (update receive window
;	and hand over packet to level 3)
rxi2:	inr	a		;V(r)=V(r)+1 mod 7
	ani	7		;	/
	sta	vr		;update V(r)
	push	h		;save bcb address
	lxi	h,lkstat	;point to link status
	res	6,m		;clear DTE REJ condition
	pop	h		;restore bcb address
	call	getbct		;empty frame?
	jnz	rxi3		;no, keep going
;
;	empty frame
	mov	a,c		;release rx buffer
	call	rlsrxb		;	/
	call	ilprt		;and tell operator
	db	'L3: rx empty I frame',cr,lf,0
	ret
;
;	frame is not empty
rxi3:	lxi	h,rxplst	;point to list of rx packets
	mov	a,c		;get buffer #
	call	putbuf		;hand over buffer
	lhld	rxifct		;update rx I frame counter
	inx	h		;	/
	shld	rxifct		;      /
	ret



;	process received N(r) to acknowledge tx I frames
;	(internally called)
;	on entry:	<b>=control byte with N(r)
;			<c>=buffer #
;	on exit:	carry set if invalid N(r)
;			<a>, other flags clobbered
;			all other regs unchanged

ackdge:	push	b		;save regs
	push	d		;	/
	push	h		;      /
	mov	a,b		;get control byte
	call	getnr		;extract N(r)
	mov	d,a		;save N(r) in <d>
	lda	lastnr		;get last rx N(r)
	cmp	d		;same as this one?
	jz	ackexi		;yes, nothing new
;
;	calculate top of receive window
	lda	maxvs		;max V(s)+1 mod (7)
	inr	a		;(=top edge of window)
	inr	a		;bump just past top
	ani	7		;      /
	mov	e,a		;     /

;	check for valid N(r)
	mvi	b,kconst+1	;<b>=k+1
	lda	lastnr		;<a>=last valid N(r)
ack1:	cmp	d		;<a>=N(r)?
	jz	ack2		;yes, valid N(r)
;
	inr	a		;bump <a> mod 7
	ani	7		;	/
	cmp	e		;<a>=past top of window?
	jz	ackerr		;yes, invalid N(r)
;
	dcr	b		;decrement window count
	jz	ackerr		;error, below lower edge
;
	jmp	ack1		;else keep looping
;
;	valid N(r), acknowledge all tx frames up to N(r)-1
ack2:	call	t1off		;stop timer T1
	lxi	h,txbtab	;point to tx bcb address table
acklp:	lda	lastnr		;get last valid N(r)
	cmp	d		;is N(r)=last valid N(r)?
	jz	allack		;yes, all acknowledged
;
;	acknowledge a new frame
	dcr	a		;calculate last N(r)-1
	ani	7		;mod 7
	call	bpoint		;point to bcb address of last N(r)-1
	call	clrbuf		;clear tx buffer for new use
	lda	lastnr		;get last valid N(r)
	inr	a		;bump last valid N(r)
	ani	7		;	/
	sta	lastnr		;      /
	mvi	a,n2		;reset tx retry counter
	sta	rtryct		;	/
	jmp	acklp		;and keep looping
;
;	no more frames to acknowledge this time
allack:	lda	maxvs		;is N(r)=max V(s)+1?
	inr	a		;	/
	ani	7		;      /
	cmp	d		;     /
	cnz	t1on		;no, some frames still outstanding
	stc			;reset carry flag
	cmc			;	/
	jmp	ackexi		;and exit
;
;	signal invalid N(r)
ackerr:	stc			;set carry flag
;
;	common exit routine
ackexi:	pop	h		;restore regs
	pop	d		;	/
	pop	b		;      /
	ret


;	extract N(r) from control byte
;	(internally called)
;	on entry:	<a>=control byte
;	on exit:	<a>=N(r)

getnr:	ani	1110$0000b	;extract N(r)
	rrc			;move to bits 0-2
	rrc			;	/
	rrc			;      /
	rrc			;     /
	rrc			;    /
	ret	


;	process incoming response frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<c>=rx buffer #
;			<d>=address byte
;	on exit:	<b>=control byte
;			<c>,<d>,<hl> unchanged

inresp:
	call	getbuf		;get control byte
	jnc	inrsp1		;if there is one
;
	mov	a,c		;else release rx buffer
	call	rlsrxb		;	/
	lhld	rxbrct		;incr bad response frame count
	inx	h		;	/
	shld	rxbrct		;      /
	ret
;
inrsp1:	mov	b,a		;save control byte
	sta	cmdrf1		;save it in case of FRMR
	push	h		;save <hl>
	lhld	rxrfct		;increment response count
	inx	h		;	/
	shld	rxrfct		;      /
	call	logrx		;log received frame
	pop	h		;restore <hl>
	mov	a,b		;get control byte
	ani	1110$1111b	;extract all bits except f

;	now branch to known frame id's
	cpi	dmfid		;DM frame?
	jz	rxdm		;yes, process it
;
	cpi	uafid		;UA frame?
	jz	rxua		;yes, process it
;
	cpi	cmdrfid		;CMDR/FRMR frame?
	jz	rxcmdr		;yes, process it
;
;	branch to numbered frames
	ani	0000$1111b	;discard N(r) sequence bits
	cpi	rrfid		;RR response frame?
	jz	rxrrr		;yes, process it
;
	cpi	rnrfid		;RNR response frame?
	jz	rxrrnr		;yes, process it
;
	cpi	rejfid		;REJ response frame?
	jz	rxrrej		;yes, process it
;
;	unknown frame id
badrsp:	mov	a,c		;else get rx buffer #
	call	rlsrxb		;and release buffer
	lhld	rxbrct		;increment bad response counter
	inx	h		;	/
	shld	rxbrct		;      /
	lxi	h,cmdrf2	;set FRMR bit 13
	setb	4,m		;	/
	lxi	h,cmdrf3	;and FRMR bit W
	setb	0,m		;	/
	res	1,m		;reset FRMR bits X,Y,Z
	res	2,m		;	/
	res	3,m		;      /
	jmp	txfrmr		;and transmit FRMR


;	process received RR response frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxrrr:	call	ackdge		;acknowledge pending frames
	jc	badnr		;process invalid N(r)
;
	call	getbuf		;another byte in buffer?
	jnc	rfmterr		;yes, format errer
;
	lxi	h,lkstat	;point to link status byte
	res	3,m		;clear DCE busy
	res	7,m		;clear DCE reject condition
	lxi	h,l2stat	;point to level 2 status
	bit	0,m		;link query in process?
	jz	rxsr		;no, do common stuff
;	
;	link query is in process
	bit	4,b		;is response F=1?
	jz	rxsr		;no, do common stuff
;
;	process reply to query
	res	0,m		;reset link query flag
	call	t1off		;turn off response timer
	call	ilprt
	db	'L2: dce ready',cr,lf,0
	jmp	rxsr		;and do common stuff


	
;	process received RNR response frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxrrnr:	call	ackdge		;acknowledge pending frames
	jc	badnr		;process invalid N(r)
;
	call	getbuf		;another byte in buffer?
	jnc	rfmterr		;yes, format errer
;
	mvi	a,n2		;reset tx retry counter
	sta	rtryct		;	/
	lxi	h,lkstat	;point to link status byte
	setb	3,m		;set DCE busy
	res	7,m		;clear DCE reject condition
	lxi	h,l2stat	;point to level 2 status
	bit	0,m		;link query in process?
	jz	rxsr		;no, do common stuff
;	
;	link query is in process
	bit	4,b		;is response F=1?
	jz	rxsr		;no, do common stuff
;
;	process reply to query
	res	0,m		;reset link query flag
	call	t1off		;turn off response timer
	call	ilprt
	db	'L2: dce busy',cr,lf,0
	jmp	rxsr		;and do common stuff


	
;	process received REJ response frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxrrej:	call	ackdge		;acknowledge pending frames
	jc	badnr		;process invalid N(r)
;
	call	getbuf		;another byte in buffer?
	jnc	rfmterr		;yes, format errer
;
	lxi	h,lkstat	;point to link status byte
	res	3,m		;clear DCE busy
	setb	7,m		;set DCE reject condition flag
	mvi	a,n2		;initialize retry counter
	sta	rtryct		;	/
	mov	a,b		;get control byte
	call	getnr		;extract valid N(r)
	sta	vs		;set V(s)=N(r) for retransmission
	sta	maxvs		;and update max V(s) for acknowledge
	lxi	h,l2stat	;point to level 2 status
	bit	0,m		;link query in process?
	jz	rxsr		;no, do common stuff
;	
;	link query is in process
	bit	4,b		;is response F=1?
	jz	rxsr		;no, do common stuff
;
;	process reply to query
	res	0,m		;reset link query flag
	call	t1off		;turn off response timer
	call	ilprt
	db	'L2: dce in REJ condition',cr,lf,0
	jmp	rxsr		;and do common stuff

;	
;	common stuff for supervisory response frames
rxsr:
	mov	a,c		;release rx buffer
	call	rlsrxb		;	/
	lxi	h,l2stat	;point to level 2 status flags
	bit	7,m		;timer recovery condition?
	rz			;no, exit
;
;	process timer recovery condition
	bit	4,b		;is F=1?
	rz			;no, exit
;
	res	7,m		;else clear timer recovery condition
	ret
	

;	process received DM response frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #
	
rxdm:	call	getbuf		;get next byte
	jnc	rfmterr		;process invalid format
;
	mov	a,c		;get rx buffer #
	call	rlsrxb		;release buffer
	lxi	h,lkstat	;link connect in process?
	bit	0,m		;	/
	jz	rxdm1		;no, keep going
;
	call	ilprt		;yes, tell operator
	db	'L2: rx DM - dce unable to connect',cr,lf,0
	ret
;
rxdm1:	setb	0,m		;set link conn in process
	res	2,m		;clear link connected
	jmp	txsabm		;and transmit SABM


;	process received UA response frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<b>=control byte
;			<c>=rx buffer #

rxua:	call	getbuf		;get next byte
	jnc	rfmterr		;process invalid format
;
	mov	a,c		;release rx buffer
	call	rlsrxb		;	/
	lxi	h,lkstat	;point to link status word
	res	3,m		;clear DCE busy
	bit	0,m		;connect in process?
	jz	rxua1		;no, keep going
;
	res	0,m		;else clear connect in process
	setb	2,m		;and set connect flag
	call	ilprt		;and tell operator
	db	'L2: rx UA - link connected',cr,lf,0
	call	t1off		;turn off timer T1
	call	txstar		;transmit level 3 restart packet
	ret
;
rxua1:	bit	1,m		;disconnect in process?
	rz			;no, do nothing
;
	res	1,m		;else clear disc in process
	res	2,m		;and clear connect flag
	call	ilprt		;and tell operator
	db	'L2: rx UA - link disconnected',cr,lf,0
	call	t1off		;turn off timer T1
	ret


;	process received CMDR/FRMR response frame
;	(internally called)
;	on entry:	<hl>=bcb address
;			<c>=rx buffer #

rxcmdr:	call	ilprt		;display error msg
	db	cr,lf,'L2: rx CMDR/FRMR - frame rejected: ',cr,lf,0
	call	getbuf		;get next byte
	jc	rcmdr3		;error if not there
;
	mov	b,a		;save byte in <b>
	call	ilprt		;print first I field
	db	tab,'rejected frame id = ',0
	mov	a,b		;get back byte
	call	phex		;else display first byte in hex
	call	ilprt		;and terminate line
	db	cr,lf,0		;	/
;
	call	getbuf		;get second error byte
	jc	rcmdr3		;error if not there
;
	mov	b,a		;save byte in <b>
	call	ilprt		;display second field parameters
	db	tab,'rej frame type    = ',0
	bit	4,b		;command frame?
	jz	rcmdr1		;yes, say so
;
	call	ilprt		;else was response
	db	'response',cr,lf,0
	jmp	rcmdr2
;
rcmdr1:	call	ilprt		;command frame
	db	'command',cr,lf,0
;
rcmdr2:	call	ilprt		;display other field paramters
	db	tab,'         dce V(s) = ',0
	push	h		;save <hl>
	mov	a,b		;get back byte
	ani	0000$1110b	;extract V(s)
	rrc			;	/
	mvi	h,0		;print V(s)
	mov	l,a		;	/
	call	pdec		;      /
	call	ilprt		;terminate line
	db	cr,lf
	db	tab,'         dce V(r) = ',0
	mov	a,b		;get back byte
	call	getnr		;extract V(r)
	mov	l,a		;and print it
	call	pdec		;	/
	call	ilprt		;teminate line
	db	cr,lf,0
	pop	h		;restore <hl>
;
	call	getbuf		;get last byte
	jc	rcmdr3		;error if not there
;
	mov	b,a		;save byte in <b>
	call	ilprt		;else print last field
	db	tab,'error bits ----zyxw=',0
	mov	a,b		;get back byte
	call	pbin		;in binary
	call	ilprt		;and terminate line
	db	cr,lf,0		;	/
;
	call	getbuf		;try for one more
	jc	rcmdr4		;ok if not there
;
rcmdr3:	call	ilprt
	db	'L2: format error in rx CMDR/FRMR frame',cr,lf,0
;
rcmdr4:	mov	a,c		;else release rx buffer
	call	rlsrxb		;	/
;	lxi	h,l2stat	;point to flow status
	setb	2,m		;set DCE FRMR condition
	jmp	conlk		;and reconnect link


	
;	*****************
;	*   data area	*
;	*****************

	dseg

;	HDLC frame variables and sequence numbers

vr	db	0	;V(r)=receive state variable (0-7)
vs	db	0	;V(s)=send state variable (0-7)
lastnr	db	7	;last valid received N(r) (0-7)
lastvr	db	0	;last transmitted V(r)
lastvs	db	7	;last transmitted V(s)
maxvs	db	0	;max V(s) transmitted
pfbit	db	0	;poll/final bit (in pos 4)
rxcaddr	db	0	;address of received commands
rxraddr	db	0	;address of received responses
txcaddr	db	0	;address of transmitted commands
txraddr	db	0	;address of transmitted responses

;	outgoing CMDR information field template
;	(table 4/X.25)

cmdrf1	db	0	;rejected command control field
cmdrf2	db	0	;sequence variables & addr indicator
cmdrf3	db	0	;error indicator bits

;	level 2 status indicators & local variables

lkstat	db	0	;level 2 link status flags
l2stat	db	0	;level 2 status flags
dtemod	db	true	;0=DCE mode/0ffh=DTE mode
badadd	db	0	;storage for bad address
ackcnt	db	kack	;acknowledgement delay counter

;	level 2 diagnostic counters

rtryct:	db	n2	;tx retry counter
rbafct:	dw	0000h	;bad rx address frames
rxbrct:	dw	0000h	;bad rx response frames
rxbcct:	dw	0000h	;bad rx command frames
rxcfct:	dw	0000h	;rx command frames
rxrfct:	dw	0000h	;rx response frames
rxifct:	dw	0000h	;rx I frames
txifct:	dw	0000h	;tx I frames
txfct:	dw	0000h	;tx frames
txirct:	dw	0000h	;tx I retransmission count

