;TVBIOS v1.0--add terminal emulation to C64 CP/M
;
;  28 September 1984
;
;  Author:  Ross A.Alford
;           ...{decvax, akgua, ihnp4}!mcnc!ecsvax!alford
;           Compuserve 75475,1404
;
;           Department of Zoology
;           Duke University
;           Durham, NC 27706
;
;  This program is copyrighted 1984 by
;  Ross A. Alford.  Permission is
;  hereby granted for unlimited nonprofit
;  distribution, provided this notice is
;  included.  Permission for any
;  commercial use must be obtained from
;  the author.
;
;  Adds to the C64 BIOS an emulation of
;  the Televideo 920 terminal (in
;  40 columns).
;
;  Takes up the space reserved for 6502
;  BIOS functions 7,8, and 9 at Z80
;  addresses 0fe00h through 0ffffh.
;
;  Also adds auto key repeat after
;  a short delay.
;
;  Using the insert and delete line
;  functions sometimes makes a few
;  characters turn odd colors after they
;  move.  This appears to be due to
;  some sort of a timing problem with
;  the 2114 used for color RAM, and I
;  haven't been able to get around it.
;  I'd like to hear of any solution
;  anyone comes up with.
;
;  This program works with the version
;  of C64 CP/M that I own.  There may
;  be other versions in existance.  If
;  it doesn't work on your system,
;  look up the BIOS locations in your
;  manual and see if they match.
;
;  I make no warranty of this program's
;  usefulness, and assume no liability
;  for any damages it may cause
;  directly or indirectly.
;
;
;  Supports the following commands:
;
;  decimal sequence	function
;
;  26			home and clear
;  27,82		delete line
;  27,69		insert line
;  27,84		erase to end of line
;  27,85		erase to end of screen
;  27,41		inverse video on
;  27,40		inverse video off
;  27,61,row+32,col+32	position cursor
;                     	at row, col
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
;conditional equates
;
	if	forty8
lastky	equ	0ba63h
j9	equ	0bbd5h
const1	equ	0bbd7h
const2	equ	0bbdch
conout	equ	0bc76h
j20	equ	0bc7ch
cout1	equ	0bc89h
cout5	equ	0bcaah
	endif
;
	if	forty4
lastky	equ	0aa63h
j9	equ	0abd5h
const1	equ	0abd7h
const2	equ	0abdch
conout	equ	0ac76h
j20	equ	0ac7ch
cout1	equ	0ac89h
cout5	equ	0acaah
	endif
;
;global equates
;
cr	equ	00dh
lf	equ	00ah
offset	equ	0fb00h	
iotype	equ	0fcffh
chrst	equ	0f400h
colst	equ	0c800h
chrend	equ	0f7bfh
colend	equ	0cbbfh
color	equ	0f286h
row6502	equ	0f0d6h
col6502	equ	0f0d3h
bdos	equ	0005h
prtstr	equ	009h
data6502 equ	0f901h
rvs6502	equ	0f0c7h;
jrnz	equ	020h
;
;routine that relocates the
;  tvbios routines into the
;  extra 512 bytes at 0fe00h
;  and patches conout in the
;  bios to jump to tvbios
;
	org	0100h
	lxi	d,msg1
	mvi	c,prtstr
	call	bdos
	lxi	b,tvbios
	lxi	h,scend-tvbios
	lxi	d,0fe00h
	call	movup
	lxi	b,bpatch
	lxi	d,conout
	lxi	h,0003h
	call	movup
	lxi	b,bpatch2
	lxi	d,j9-1
	lxi	h,0003h
	call	movup
	lxi	b,bpatch3
	lxi	d,cout5
	lxi	h,0003h
	call	movup
	ret
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
;jump to tvbios to patch into
;  bios80 at conout start
;
;
bpatch	jmp	0fe00h
;
;
;patch to jump for keyboard
;  auto repeat.  inserted into
;  BIOS80 at j9-1, which should
;  be CMP M
;
;
bpatch2: jmp	rptpat+offset
;
;
;jump to routine to check and
;  correct inverse/normal video
;  status.   inserted into the
;  BIOS at location cout5
;
;
bpatch3: jmp	invpat+offset
;
;
;startup messages
;
msg1	db	cr,lf,'TVBIOS v1.0 for C64 CP/M',cr,lf
	db	'Emulates the TVI 920 in 40 columns',cr,lf,cr,lf
	db	'Copyright 1984 by Ross A. Alford',cr,lf
	db	'All commercial rights reserved',cr,lf,cr,lf,'$'
;
;
;main TVBIOS interpreter
;
;
	org	0300h
tvbios	lda	flag+offset
	db	0cbh,07fh
;	bit	7,a
 	jnz	esced+offset
	db	0cbh,047h
;	bit	0,a
	jnz	curdo+offset
	mov	a,c
	cpi	01bh	;esc?
	jnz	ccz+offset
	mvi	a,true
	sta	flag+offset
	ret
ccz:	cpi	01ah
	jnz	endscop+offset
	mvi	a,0ch
	mov	c,a
endscop: lda	iotype
	ani	010h
	mov	a,c
	jnz	cout5
	jmp	j20+02h
esced:	xra	a
	sta	flag+offset
	mov	a,c
	cpi	052h
	jz	delrow+offset
	cpi	045h
	jz	insrow+offset
	cpi	054h
	jz	clreol+offset
	cpi	055h
	jz	clreos+offset
	cpi	029h
	jz	invon+offset
	cpi	028h
	jz	invoff+offset
	cpi	03dh
	rnz
	mvi	a,01h
	sta	flag+offset
	ret
curdo:	db	0cbh,04fh
;	bit	1,a
	jnz	curcol+offset
	mov	a,c
	sui	020h
	sta	row+offset
	mvi	a,03h
	sta	flag+offset
	ret
curcol:	xra	a
	sta	flag+offset
	mov	a,c
	sui	020h
	sta	col+offset
	jmp	curpos+offset
;
;subroutine insrow: insert a blank
;  line at the row given by row
;
insrow: call	stindl+offset
	push	h
	lxi	b,chrend
	lxi 	d,chrend+028h
	call	lddr+offset
	pop	h
	lxi	b,colend
	lxi	d,colend+028h
	call	lddr+offset
	mvi	a,028h
	sta	ntoblk+offset
;
;subroutine blank: change 'ntoblk'
;  positions to blank starting at
;  current chradr, coladr
;
blank:	mvi	b,020h
	lda	ntoblk+offset
	lhld	chradr+offset
blank1:	mov	m,b
	inx	h
	dcr	a
	ora	a
	jnz	blank1+offset
	mvi	b,0f6h
	lda	ntoblk+offset
	lhld	coladr+offset
blank2:	mov	m,b
	inx	h
	dcr	a
	ora	a
	jnz	blank2+offset
	ret
;
;
;subroutine saverc: moves row
;  and col numbers from 6502
;  locs to tvbios locs
;
;
saverc:	lda	col6502
	sta	col+offset
	lda	row6502
	sta	row+offset
	ret
;
;subroutine calcstnd:  calculate
;  addresses for start of color
;  and char memory given a row #
;  row passed in 'row', addresses
;  returned in coladr, chradr
;
calcstnd: lda	row+offset
	ani	07fh
	lxi	h,0000h
	lxi	b,0000h
	ora	a
	jz	caend+offset
	lxi	b,0028h
calclp:	ora	a
	jz	caend+offset
	dad	b
	dcr	a
	jmp	calclp+offset
caend:	push	h
	lxi	b,chrst
	dad	b
	shld	chradr+offset
	pop	h
	lxi	b,colst
	dad	b
	shld	coladr+offset
	ret
;
;
;subroutine lddr: simulate the
;  lddr instruction, sort of
;  pass from in bc, to in de,
;  number in hl
;  this is used rather than the
;  real thing because lddr is
;  apparently too fast for
;  the color memory
;
;
lddr:	ldax	b
	push	h	;delay
	pop	h	;delay
	stax	d
	dcx	b
	dcx	d
	dcx	h
	xra	a
	cmp	h
lddr1:	db	jrnz,(lddr-lddr1-2) and 0ffh
	cmp	l
lddr2:	db	jrnz,(lddr-lddr2-2) and 0ffh
	ret
;
;subroutine ldir: move byte
;  pointed to by bc to loc
;  pointed to by de, inc bc, de
;  repeat hl times
;
ldir	ldax	b
	push	h	;delay
	pop	h	;delay
	stax	d
	inx	b
	inx	d
	dcx	h
	xra	a
	cmp	h
ldir1:	db	jrnz,(ldir-ldir1-2) and 0ffh
	cmp	l
ldir2:	db	jrnz,(ldir-ldir2-2) and 0ffh
	ret
;
;
;subroutine clreol:clear to end
;  of current screen line
;
;
clreol:	call	saverc+offset
ceol2:	call	calcstnd+offset
	lxi	h,col+offset
	mvi	a,028h
	sub	m
	sta	ntoblk+offset
	mvi	b,0
	lda	col+offset
	mov	c,a
	lhld	chradr+offset
	dad	b
	shld	chradr+offset
	lhld	coladr+offset
	dad	b
	shld	coladr+offset
	call	blank+offset
	ret
;
;
;subroutine clreos:clear from 
;  cursor to end of page
;
;
clreos:	call	clreol+offset
	xra	a
	sta	col+offset
ceop2:	lxi	h,row+offset
	inr	m
	mvi	a,018h
	cmp	m
	jc	ceopnd+offset
	call	ceol2+offset
	jmp	ceop2+offset
ceopnd:	ret
;
;
;subroutine curpos: position
;  cursor on coords passed in
;  locations row and col
;
;
curpos:	lda	row+offset
	ani	07fh
	cpi	019h
	rnc
	dcr	a
	sta	row6502
	mvi	a,0dh
	call	cout5
	lda	col+offset
	ani	07fh
	cpi	028h
	rnc
	sta	col6502
	ret
;
;
;subroutine invon:start inverse
;
;
invon:	mvi	a,01h
	sta	invflg+offset
	ret
;
;
;subroutine invoff: end inverse
;
;
invoff:	xra	a
	sta	invflg+offset
	ret
;
;subroutine delrow: delete the
;  row pointed to by row
;
delrow: call	stindl+offset
	push	h
	push	h
	lxi	h,0028h
	dad	d
	mov	b,h
	mov	c,l
	pop	h
	call	ldir+offset
	lhld	coladr+offset
	mov	d,h
	mov	e,l
	lxi	h,0028h
	dad	d
	mov	b,h
	mov	c,l
	pop	h
	call	ldir+offset
lastrw:	xra	a
	sta	col+offset
	mvi	a,018h
	sta	row+offset
	call	ceol2+offset
	ret
;
;subroutine stindl: startup
;  for insert/delete a row
;  routines.  exit with chradr
;  in d,e and chrend-chradr in
;  hl
;
stindl:	call	saverc+offset
	ani	07fh
	cpi	018h
	jc	stin2+offset
	pop	h	;last return address
	jmp	lastrw+offset
stin2:		call	calcstnd+offset
	xra	a
	lhld	chradr+offset
	mov	d,h
	mov	e,l
	lxi	h,chrend
	db	0edh,052h
;	sbc	hl,de
	inx	h
	ret
;
;
;rptpat routine: a jump to this
;  is inserted at j9-1 in the
;  BIOS.   This repeats any
;  keypress after a delay
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
;routine invpat is jumped to 
;  by the modified BIOS from 
;  location COUT5.  it fixes
;  the inverse/normal status,
;  then continues as normal
;
;
invpat: mov	b,a
	lda	invflg+offset
	sta	rvs6502
	mov	a,b
	sta	data6502
	jmp	cout5+3
;
;storage locations
;
row	db	0
col	db	0
chradr	db	0,0
coladr	db	0,0
ntoblk	db	0
flag	db	0
delay	db	080h
invflg	db	0
;
scend	end
