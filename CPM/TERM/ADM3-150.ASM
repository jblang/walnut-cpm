;
;			termemu1.asm
;			by charles shoemaker
;			published in 4/81 byte mag.
;
;	the lear siegler adm-3 emulator for the hazeltine
;	1500 terminal.
;
	org	7fb4h	;fix cpm outch routine to jump here
	jmp	entry
;
	org	8000h	;put after bios
;
entry:	lda	mode	;are we in the middle of something?
	ora	a
	mov	a,c	;get character to send, for compares
	jz	norm	;ordinary
	jpe	xy	;if jump taken, norm contains either 3 or 255
	cpi	'='	;middle of xy address sequence
	mvi	a,0	;preset error condition
	sta	mode
	jnz	zap	;something's wrong--print it and give up
	mvi	a,3	;fix up
	sta	mode	;tell us next time
	ret		;and back
;
norm:	cpi	30	;test for home character
	jc	nthome
	jnz	zap	;not a control character--send it
	mvi	c,18	;get hazel's home character
	jmp	specl	;do it
nthome: cpi	11	;is it up-cursor?
	jz	specl-1	;quick trick
	cpi	12	;is it right-cursor?
	jnz	ntrght	;no---
	mvi	a,16	;hazel's right-cursor
	jmp	zap
ntrght:	cpi	27	;is it escape-address cursor?
	jnz	ntesc
	mvi	a,1	;tell us next time through
	sta	mode
	ret
;
ntesc:	cpi	26	;is it clear screen?
	jnz	outch	;no, must be some other control character
	inr	c	;make 28, hazel's clear screen character
	inr	c
specl:	mvi	a,126	;get her attention
	call	zap	;send the first character right away
outch:	mov	a,c	;retrieve original character
	push	psw	;stow it away
	in	10h	;gotta check status
	ani	2
	jz	outch+2
	pop	psw	;get it back
zap:	out	11h	;send it
	ret		;finally, return to caller
;
xy:	jm	final	;we know we have 'esc' '=' sequence
			;see if this is x or y character
			;take the jump if this is x
	mov	a,c	;just get y character
	sta	y	;and save it
	mvi	a,0ffh	;let us know what to do next time
	sta	mode
	ret
;
final:	push	b	;save x character a minute
	mvi	c,17	;get hazel's attention
	call	specl
	pop	b	;get'm back
	mov	a,c	;get x coordinate
	sui	32	;get rid of adm-3 bias
	cpi	31	;fix hazel's bias
	jnc	sendx	;ok as is
	adi	96	;hazel likes this better
sendx:	call	outch+1	;send x
	xra	a	;fix mode up--back to normal
	sta	mode
	lda	y	;adm-3 bias ok for hazel
	jmp	outch+1	;send it and go home
;
mode:	db	0
y:	db	0
;
	end

