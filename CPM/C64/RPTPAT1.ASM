;rptpat1-add automatic key repeat to the
;C64 BIOS and change the border, screen,
;and character colors for SOFT80 V.1
;
;  29 September 1984
;
;  Author:  Ross A. Alford
;           ...{decvax, akgua, ihnp4}!mcnc!ecsvax!alford
;           Compuserve 75475,1404
;
;           Department of Zoology
;           Duke University
;           Durham, NC 27706
;
;
;  This program is hereby licensed for
;  unlimited noncommercial distribution,
;  provided this notice remains atached.
;  Any comercial use requires the written
;  consent of the author.
;
;  This program operates correctly with
;  my version of C64 CP/M.  Other
;  versions may exist.  If it appears
;  not to work with your system, check
;  the equates against your BIOS.
;  It occupies the space reserved for
;  BIOS65 function 7, and so conflicts
;  with that function
;
;  I assume no liability for the operation
;  of this program, nor for any direct
;  or consequential damages caused
;  by it.
;
;
;define true and false
;
true	equ	0ffh
false	equ	00h
;
;
;assemble for 44k or 48k?
;
forty8	equ	true
forty4	equ	false
;
;
;conditional equates
;
;
	if	forty8
lastky	equ	0ba63h
j9	equ	0bbd5h
const1	equ	0bbd7h
const2	equ	0bbdch
	endif
;
;
	if	forty4
lastky	equ	0aa63h
j9	equ	0abd5h
const1	equ	0abd7h
const2	equ	0abdch
	endif
;
;
;global equates
;
;
bdos	equ	0005h
esc	equ	01bh
offset	equ	0fc00h
border	equ	0c020h
cr	equ	0dh
lf	equ	0ah
bgcolor	equ	06h	;background color
ccolor	equ	14h	;char color
;
;
;routine that sets colors and
;  relocates the patch 
;  routines into the
;  extra 512 bytes at 0fe00h
;  and patches conout in the
;  bios to jump to patch
;
	org	0100h
;print sign on message, change screen colors
	lxi	d,msg
	mvi	c,09h	;print string
	call	bdos
;change border color
	mvi	a,0bh
	sta	border
;
;
;install BIOS patches
;
	lxi	b,pbegin
	lxi	h,pend-pbegin
	lxi	d,0fe00h
	call	movup
	lxi	b,bpatch
	lxi	d,j9-1
	lxi	h,0003h
	call	movup
	ret
;
;
movup:	ldax	b
	stax	d
	inx	b
	inx	d
	dcx	h
	xra	a
	cmp	h
	jnz	movup
	cmp	l
	jnz	movup
	ret
;
;
msg	db	esc,'K',bgcolor	;set background color
	db	esc,'H',ccolor	;set character color
	db	cr,lf,'RPTPAT v1.0',cr,lf
	db	'Enables auto-repeat keyboard,',cr,lf
	db	'sets character and background colors',cr,lf
	db	cr,lf,'Copyright 1984 by Ross A. Alford',cr,lf
	db	'All commercial rights reserved',cr,lf,'$'
;
;
;patch to jump for keyboard
;  auto repeat.  inserted into
;  BIOS80 at j9-1, which should
;  be CMP M
;
;
bpatch: jmp	rptpat+offset
;
;
;rptpat routine: a jump to this
;  is inserted at j9-1 in the
;  BIOS.   This repeats any
;  keypress after a delay
;
;
	org	0200h
pbegin:		;start of patches
;
;
rptpat:	mov	b,a
	cpi	040h
	jnz	rpp1+offset
	sta	lastky
	jmp	const1
rpp1:	cmp	m
	jz	rpp2+offset
	mvi	a,080h
	sta	delay+offset
	mov	a,b
	jmp	const2
rpp2:	lxi	h,delay+offset
	dcr	m
	jnz	const1
	mvi	a,018h
	mov	m,a
	mov	a,b
	jmp	const2
;
;
;storage locations
;
;
delay:	db	080h
;
;
pend:	end
