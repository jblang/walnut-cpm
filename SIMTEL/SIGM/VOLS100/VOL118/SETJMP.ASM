;setjmp/longjmp support for Aztec C
;Mark E. Mallett 830127
;

	public	setjmp_
	public	longjmp_


;
; setjmp			i = setjmp(env)
;
;		returns 0 if setting
;			val if longjmping
;

setjmp_:
	DB	0EDH,073H	; LD (nn),SP
	DW	osp		;   nn..
	pop	h		; Get return address
	shld	raddr		; Save it
	pop	h		; get address of env buffer
	shld	envadr		; Save it

	DB	011H		; ld de,nn   .. Find the end of the jmp buffer
	 DW	10		;       nn
	DB	019H		; ADD HL,DE
	shld	nsp		; Save so I can pick it up...
	DB	0EDH,07BH	; ... here   ( ld sp,(nn)  )
	DW	nsp		;                    ..NN..

	push	b		; save things in jmp buffer
	db	0DDH,0E5H	; push ix
	db	0FDH,0E5H	; push iy
	lhld	raddr		; save return address
	push	h
	lhld	osp		; save original stack pointer
	push	h

	lxi	h,0		; set return value to 0
	shld	val
	jp	ljret		; go return as if from longjump



; longjmp			longjmp (env,val)
;			returns val to where setjmp was called
;

longjmp_:
	lxi	h,2		; Find addr of env
	dad	sp		;     .
	mov	e,m		; get it in de
	inx	h
	mov	d,m
	inx	h
	DB	0EDH,053H	; ld (nn),de
	DW	envadr
	mov	e,m		; get value
	inx	h
	mov	d,m
	DB	0EDH,053H	; LD (nn),de
	DW	val		;   NN

; Here to return from setjmp/longjmp

ljret:
	DB	0EDH,07BH	; LD SP,(NN)... Get jmp buffer address
	DW	envadr		;      ..NN..
	pop	h		; Get old stack pointer value
	shld	osp		; Save it
	pop	d		; Get old return address
	mov	m,e		; Put it on the old stack
	inx	h
	mov	m,d

	db	0FDH,0E1H	; pop iy
	db	0DDH,0E1H	; pop ix
	pop	b

	lhld	val		; Get value to return
	DB	0EDH,07BH	; LD sp,(nn)
	 DW	osp		;       NN

	ret			; Return to setjmp caller



envadr:	ds	2		; Address of jmp buffer
nsp:	ds	2		; New stack pointer
osp:	ds	2		; Old stack pointer
raddr:	ds	2		; Return address
val:	ds	2		; Value to return
	end
