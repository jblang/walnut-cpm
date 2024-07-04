*******************************************************
* USQ support code				      *
* 10/12/83 by Dave Rand				      *
*******************************************************
;
; Changes made by S. Kluger to allow use under SYSLIB.
; The following SYSLIB routines are used:
;
	extrn	bdos		;BDOS call routine
	extrn	print		;In place of ILPRT
	extrn	cout		;Character out routine
;
; The following labels must be defined in the calling program:
;
	extrn	fcb		;file control block addr
	extrn	buff		;ram buffer start
	extrn	topram		;end of buffer (hi byte only)
	extrn	erext		;error exit routine
	extrn	table		;pointer to 1032 bytes
	extrn	bufull		;called when buffer full
				;(this routine processes the filled
				; buffer and then returns for more.)
;
	public	usq		;unsqueeze entry point
;
eof:	equ	1ah
dle:	equ	090h
;
;this is start of baseline USQ code
;
usq:	xra	a		;force init char read
	sta	numlft
	sta	rcnt		;and zero repeats
	lhld	lastmem
	shld	sob
	shld	eob
	call	getw
usq1:	call	getw		;get cksum, and store
	shld	filecrc
usq2:	call	get1
	jnz	erext
	ora	a
	jnz	usq2
usq3a:	call	getw
	shld	numvals
	lxi	d,258
	call	cmpdehl
	jc	usq3b
	call	errext
	db	13,10,'File has illegal decode size. Aborting.',0
;
usq3b:	lxi	d,table
usq4:	shld	max
	mov	a,h
	ora	l
	jz	usq5
	push	d
	call	getw
	pop	d
	xchg
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	push	h
	call	getw
	xchg
	pop	h
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	xchg
	lhld	max
	dcx	h
	jmp	usq4
;
usq5:	lxi	h,0
usq6:	push	h
	call	getnxt
	pop	h
	jnz	usq8
	mov	e,a
	mvi	d,0
	dad	d
	push	h
	push	psw
	LHLD	nextadr		; PT TO LOAD ADDRESS
	LDA	topram		; CHECK AGAINST END PAGE OF TPA
	CMP	H		; IF AT SAME PAGE, YES
	jnz	nofull		;buffer is not full yet
	call	bufull		;buffer full, process buffer
	lxi	h,buff		;reset buffer pointer
nofull:	pop	psw
	mov	m,a
	inx	h
	shld	nextadr
	pop	h
	jmp	usq6
;
usq8:	xchg
	lhld	filecrc
	call	cmpdehl
usq9:	rz
	call	print
	db	13,10,'ERROR - Checksum error in file ',0
	jmp	erext
;
errext:	pop	h
	mov	a,m
	ora	a
	jz	erext
	inx	h
	push	h
	call	cout
	jmp	errext
;
cmpdehl:
	mov	a,h
	cmp	d
	rnz
	mov	a,l
	cmp	e
	ret
;
get1:	lhld	eob
	xchg
	lhld	sob
	call	cmpdehl
	jz	get1r
	mov	a,m
	inx	h
	shld	sob
	cmp	a
	ret
;
get1r:	lhld	lastmem
	shld	sob
	shld	eob
get1r1:	push	h
	xchg
	mvi	c,26
	call	bdos
	lxi	d,fcb
	mvi	c,20
	call	bdos
	pop	h
	ora	a
	jnz	get1r2
	lxi	d,128
	dad	d
	xchg
	lhld	endmem
	call	cmpdehl
	xchg
	jnc	get1r1
get1r2:	shld	eob
	xchg
	lhld	sob
	call	cmpdehl
	jnz	get1
	mvi	a,255
	ora	a
	ret
;
getw:	call	get1
	jnz	badr
	push	psw
	call	get1
	jnz	badr
	mov	h,a
	pop	psw
	mov	l,a
	ret
;
badr:	call	print
	db	13,10,'Premature EOF on file... aborted.',0
	jmp	0
;
getnxt:	lda	rcnt		;see if in the middle of
	ora	a		;repeat sequence...
	jz	getn7
	dcr	a
	sta	rcnt
	lda	last
	cmp	a
	ret
getn7:	call	getn4
	cpi	dle
	jnz	getn5
	call	getn4
	ora	a
	jnz	getn6
	mvi	a,dle		;dle is encoded as dle,0
	cmp	a
	ret
getn6:	dcr	a
	dcr	a
	sta	rcnt
	lda	last
	cmp	a
	ret
getn5:	sta	last
	cmp	a
	ret
;
getn4:	lxi	d,0		;pointer @ sot
	lda	char
	mov	c,a
getn1:	lda	numlft
	ora	a
	jnz	getn2
	push	d
	call	get1
	jnz	badr
	pop	d
	mov	c,a
	mvi	a,8
getn2:	dcr	a
	sta	numlft
	mov	a,c
	rrc
	mov	c,a
	lxi	h,table
	jnc	getn3
	inx	h
	inx	h		;add 2 to point to right node
getn3:	dad	d
	dad	d
	dad	d
	dad	d		;ok.. pointing close to right plc..
	mov	e,m
	inx	h
	mov	d,m
	mov	a,d
	ani	128
	jz	getn1
	mov	a,c
	sta	char
	mov	a,d
	cpi	254		;is special eof?
	mvi	a,eof
	jz	geteof		;yup
	mov	a,e
	cma
	cmp	a
	ret
;
geteof:	pop	h
	ora	a
	ret
;
;end of baseline USQ code
;
lastmem:dw	80h
endmem:	dw	80h+127
sob:	dw	80h
eob:	dw	80h
;
nextadr:dw	buff
numlft:	ds	1
rcnt:	ds	1
filecrc:ds	2
last:	ds	1
char:	ds	1
numvals:ds	2
max:	ds	2
