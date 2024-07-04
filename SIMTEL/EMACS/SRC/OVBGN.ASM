	public .ovbgn, ovexit_
	ext ovmain_,prctyp
	dseg
ovstkpt: ds	2
saveret: ds	2
	cseg
.ovbgn:
	pop	h
	pop	h
	pop	h
	pop	h
	sphl
	pop	b
;	call	prctyp	;8080 or z80 processor?
;	jnc	ovbgn10	;jump if 8080
	db	253,225,221,225	;pop ix, pop iy for z80 processor
ovbgn10:
	pop	h
	shld	saveret
	pop	d
	lxi	h,ovret
	push	h
	lxi	h,0
	dad	sp
	shld	ovstkpt		;save stack pointer for ovexit
	jmp	ovmain_

ovret:	xchg			;save return value
	lhld	saveret		;get return addr
	push	h		;place dummy overlay name ptr on stack
	push	h		;place return addr on stack
	xchg			;restore return value to hl
	ret			;return to caller
;
ovexit_:
	lxi	h,2			;get return value
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	lhld	ovstkpt		;get original stack pointer
	sphl				;and restore it
	xchg
	ret					;return back to root
	end
