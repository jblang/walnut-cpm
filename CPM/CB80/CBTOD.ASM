; CB80 CBTOD routine, fixed for seconds and for CP/M plus
;
; The original CBTOD routine in CB80 version 2.0 has a number of
; bugs:
; 1. BDOS function 155 is used instead of 105. 155 does not exist.
; 2. The routine, after changing to BDOS call 105, will only work
;    with MP/M, not with CP/M plus.
; 3. the TIME$ function returns HHMM00 instead of HHMMSS.
;
; This file CBTOD.ASM fixes all of the above problems. It has not been
; officially blessed by DRI and application of this file to your copy
; of CB80 is at your own risk!
;
; HOW TO:
; 1. Use RMAC or M80 to assemble CBTOD.ASM into CBTOD.REL
; 2. rename your existing CB80.IRL library to something different,
;    such as OLIB.IRL (preserve the .IRL type)
; 3. Use LIB as follows: LIB CB80[I]=OLIB.IRL<CBTOD>
; 4. Enjoy the DATE$ and TIME$ functions in CP/M plus.
;
; NOTE NOTE NOTE
; TO STRESS AGAIN, THIS CODE HAS NOT BEEN AUTHORIZED BY DRI AND WILL
; WORK WITH CB80 VERSION 2.0 ONLY!!!
;
; The original code below has been reconstructed with LIB.COM
;
	public	?time,?date
	extrn	?gets
;
?time:	call	p0093
	lxi	b,3003h
	mvi	d,0fh
	lxi	h,d0002
p000b:	mov	a,m
	xthl
	mov	e,a
	rrc
	rrc
	rrc
	rrc
	ana	d
	ora	b
	mov	m,a
	inx	h
	mov	a,e
	ana	d
	ora	b
	mov	m,a
	inx	h
	xthl
	inx	h
	dcr	c
	jnz	p000b
	pop	h
	pop	h
	ret
;
?date:	call	p0093
	mvi	a,44h
	push	psw
	mvi	h,4dh
	push	h
p002d:	pop	d
	pop	psw
	rrc
	push	psw
	mvi	a,1ch
	aci	0
	sta	p0087+1
	inr	d
	push	d
	mvi	c,0ch
	lxi	d,p0087
	lhld	d0000
p0042:	xchg
	mov	a,e
	sub	m
	mov	e,a
	mov	a,d
	sbi	0
	jm	p005d
	mov	d,a
	ora	e
	jz	p005d
	inx	h
	xchg
	shld	d0000
	dcr	c
	jnz	p0042
	jmp	p002d
;
p005d:	pop	d
	pop	psw
	pop	h
	lda	d0000
	push	psw
	mvi	a,13
	sub	c
	push	psw
	push	d
	mvi	b,10
	mvi	c,3
p006d:	pop	psw
	mvi	d,-1
p0070:	sub	b
	inr	d
	jnc	p0070
	add	b
	mov	e,a
	mov	a,d
	ori	'0'
	mov	m,a
	inx	h
	mov	a,e
	ori	'0'
	mov	m,a
	inx	h
	dcr	c
	jnz	p006d
	pop	h
	ret
;
p0087:	db	1fh
	ds	1
;
	db	1fh,1eh,1fh,1eh,1fh
	db	1fh,1eh,1fh,1eh,1fh
;
p0093:	lxi	h,8
	call	?gets
	pop	d
	push	h
	mvi	m,80h
	inx	h
	mvi	m,6
	inx	h
	push	h
	push	d
	mvi	c,12
	call	5
	mov	a,h
	ani	5
	jnz	dotim
	mov	a,l
	cpi	30h		;cp/m plus?
	jc	p00b6		;no, skip
dotim:	mvi	c,69h		;mp/m time/date call
	lxi	d,d0000
	call	5
	sta	d0004
	ret
;
p00b6:	pop	psw
	pop	d
	mvi	c,6
	mvi	a,' '		;filler for no time call
p00bc:	stax	d
	inx	d
	dcr	c
	jnz	p00bc
	pop	h
	ret
;
	dseg
;
d0000:	ds	2
d0002:	ds	1
d0003:	ds	1
d0004:	ds	1
	end
ov	a,e
	sub	m
	mov	e,a
	mov	a,d
	sbi	0
	jm	p005d
	mov	d,a
	ora	e
	jz	p005d
	inx	h
	xchg
	shld	d0000
	dcr	c
