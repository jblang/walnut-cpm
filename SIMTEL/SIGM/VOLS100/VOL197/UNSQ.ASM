
;	------------------------------------------------------------
;	UNSQ.ASM is similar to the program USQ.COM (SIG/M 58.27).
;	The latter appears to have been compiled from BDS "C" source
;	code, which is known to be from ten to twenty times more
;	voluminous than code derived from assembly language source.
;	UNSQ.ASM was written on the basis of information concerning
;	Huffman codes found in the literature, an inspection of a
;	disassembly of USQ.COM, and several experiments in which
;	test files were squeezed and the squeezed files then dumped.
;	It reads a squeezed file, recovering the original unsqueezed
;	file as its output.
;
;			 UNSQ.ASM  Copyright (C) 1984
;			Universidad Autonoma de Puebla
;				July 16, 1984
;
;	[Harold V. McIntosh, 16 July 1984]
;	------------------------------------------------------------

BDOS	equ	0005H
qfcb	equ	005CH		;squeezed FCB
tsiz	equ	0080H
usiz	equ	0080H		;size of .UNS buffer
qsiz	equ	0080H		;size of squeezed file buffer
qbuf	equ	0080H		;squeezed buffer
csiz	equ	512		;max chars in Huffman code

;	Nongraphic characters.

LF	equ	0AH
CR	equ	0DH

;	-------------
	org	0100H
;	-------------

begn:	lxi	h,0000
	dad	sp
	shld	stak		;save sp
	lxi	sp,stak		;stackend
	lda	qfcb+1		;squeezed FCB
	cpi	' '
	jnz	notu
	lxi	d,tuto
ferm:	call	mssg
exit:	jmp	0000

notu:	lxi	h,ubuf		;unsqueezed buffer
	shld	uptr		;pointer to .UNS buffer
	lxi	h,qbuf		;squeezed buffer
	shld	qptr		;squeezed file index

	lxi	b,0021H		;33 00's
	lxi	h,ufcb		;unsqueezed FCB
	call	fiuc		;block fill

	lxi	b,200BH		;11 blanks
	lxi	h,ufcb+1	;unsqueezed FCB
	call	fiuc		;block fill

	call	opef		;open squeezed file

	lxi	h,0000
	shld	qctr
	lxi	h,uctr		;occupancy of .UNS buffer
	mvi	m,usiz+1	;size of .UNS buffer
	lxi	h,roco
	mvi	m,1

cota:	call	rbyt		;fetch one byte from input stream
	cpi	076H
	jnz	cote		;'not squeezed file'
	call	rbyt		;fetch one byte from input stream
	cpi	0FFH
	jz	rchk		;read checksum
cote:	lxi	d,nsqz		;'not a squeezed file'
	jmp	ferm		;final (error) message

;	The "squeezed" marker is followed by a two-byte checksum,
;	which is the simple sum of all the one-byte characters in
;	the source file, carried as a two byte sum modulo 2**16.

rchk:	call	rwor		;fetch two bytes from input stream
	shld	cksm		;checksum

;	Unsqueezed file name. It is an ASCII sequence, may be lower
;	case if SQ.UNS received it in response to a prompt, ending
;	with a zero byte. Some trash may be present if SQ.UNS wasn't
;	used correctly.

	mvi	b,8
	lxi	h,ufcb+1	;unsqueezed FCB
luup:	call	rbyt		;fetch one byte from input stream
	ora	a
	jz	luuw		;load code dictionary
	cpi	'.'
	jz	luuw
	call	ucfo
	mov	m,a
	inx	h
	call	cona
	dcr	b
	jnz	luup
luuz:	call	rbyt
	ora	a
	jz	ldic
	cpi	'.'
	jnz	luuz
luuw:	call	cona
	mvi	b,3
	lxi	h,ufcb+9	;unsqueezed FCB
luur:	call	rbyt
	ora	a
	jz	ldic
	call	ucfo
	mov	m,a
	inx	h
	call	cona
	dcr	b
	jnz	luur
luus:	call	rbyt
	ora	a
	jnz	luus

;	Load code dictionary. It is preceded by its two-byte length,
;	and consists of a series of pairs of two-byte addresses. For
;	each bit in the code, select the first element (0) or the
;	second (1) element of the pair. If the pair is positive, it
;	is the table entry (code + 4*index) at which to continue with
;	the next bit. If the pair is negative, it is the complement
;	of the coded ASCII character (low order byte except for [end]).

ldic:	call	rwor		;fetch two bytes from input stream
	lxi	b,csiz
	mov	a,c
	sub	l
	mov	a,b
	sbb	h
	jnc	ldii
	lxi	d,ntab		;'insufficient dictionary space'
	jmp	ferm		;final (error) message

ldii:	dad	h
	dad	h
	mov	c,l
	mov	b,h
	lxi	d,code		;decoding table
luuq:	call	rbyt		;fetch one byte from input stream
	stax	d
	inx	d
	dcx	b
	mov	a,c
	ora	b
	jnz	luuq

	call	crlf		;type CR,LF

	mvi	c,26		;(1A) set DMA address
	lxi	d,ubuf		;unsqueezed buffer
	call	BDOS

	lxi	d,ufcb		;unsqueezed FCB
	mvi	c,17		;(11) search for file
	call	BDOS
	inr	a
	jz	nexi
	lxi	d,yexi		;'file already exists'
	jmp	ferm		;final (error) message

nexi:	lxi	d,ufcb		;unsqueezed FCB
	mvi	c,22		;(16) create file
	call	BDOS

	lxi	d,ufcb		;unsqueezed FCB
	mvi	c,15		;(0F) open file
	call	BDOS
	cpi	0FFH
	lxi	d,nodi		;'no more directory'
	jz	ferm		;final (error) message

	call	cbuz		;clear output buffer to zeroes

;	Type unsqueezed code. Beware of the [end] marker,
;	and also the repeat marker 90H which occurs in the
;	combination <char><90H><count>. When count is zero,
;	90H itself is intended; otherwise <char> is to be
;	repeated <count> times, including the occurrence just
;	before 90H was seen.

tusq:	call	dnch		;decode next character
	jc	chek		;verify the checksum
	cpi	090H		;repeat last character
	jnz	tusu		;normal character
	call	dnch		;decode next character
	ora	a
	jnz	tusr
	mvi	a,090H
	call	type
	jmp	tusq

tusr:	dcr	a		;get count, adjust it
	mov	b,a		;set count aside
tust:	lda	lach		;last character typed
	call	type		;type char & add to checksum
	dcr	b		;update count
	jnz	tust		;repeat until exhausted
	jmp	tusq		;type unsqueezed code

tusu:	sta	lach		;last character typed
	call	type		;type char & add to checksum
	jmp	tusq		;type unsqueezed code

;	Decode next character.

dnch:	lxi	h,code		;decoding table
dncr:	call	rbit		;read next bit
	jnc	dncs		;skip for 1, stay for 0
	inx	h
	inx	h
dncs:	mov	e,m		;get next offset
	inx	h
	mov	d,m
	mov	a,d
	cpi	0FEH		;FEFF means [end]
	jz	dnct
	ora	a
	jp	dncu		;p means new offset
	mov	a,e		;m means complemented char
	cma
	stc
	cmc
	ret

dnct:	stc			;flag [end] with carry bit
	ret

;	Calculate <code>+4*<offset>.

dncu:	lxi	h,code		;decoding table
	dad	d
	dad	d
	dad	d
	dad	d
	jmp	dncr

;	Type CR, LF.

crlf:	mvi	a,CR
	call	cona		;type character at console
	mvi	a,LF
	jmp	cona		;type character at console

;	Type unsqueezed text and accumulate checksum.

type:	push	h
	push	d
	push	b
	push	psw
	lxi	h,cksm		;checksum
	mov	b,a
	mov	a,m
	sub	b
	mov	m,a
	inx	h
	mov	a,m
	sbi	0
	mov	m,a
	mov	a,b
	call	wbyt		;send character to .COM file
	pop	psw
	pop	b
	pop	d
	pop	h
	ret

;	Upper case fold.

ucfo:	cpi	'a'
	rc
	cpi	'{'
	rnc
	ani	5FH
	ret

;	Send character in accumulator to console.

cona:	push	h
	push	d
	push	b
	mvi	c,2		;(02) char to console
	mov	e,a
	call	BDOS
	pop	b
	pop	d
	pop	h
	ret

;	Send message to the console.

mssg:	mvi	c,9		;(09) print buffer
	jmp	BDOS

;	Verify the checksum.

chek:	lhld	cksm		;checksum
	mov	a,h
	ora	l
	jz	clof		;close the file

	mvi	c,19		;(13) delete file
	lxi	d,ufcb		;unsqueezed FCB
	call	BDOS

	lxi	d,chno		;'Checksum failure.'
	call	ferm		;final (error) message

;	Open squeezed file.

opef:	xra	a
	sta	qfcb+32		;squeezed FCB
	lxi	d,qfcb		;squeezed FCB
	mvi	c,15		;(0F) open file
	call	BDOS
	inr	a
	rnz
	lxi	d,nfil		;'requested file not found'
	jmp	ferm		;final (error) message

;	Close unsqueezed file.

clof:	lda	uctr		;occupancy of .UNS buffer
	cpi	usiz		;size of .UNS buffer
	cnz	wrdi
	mvi	c,16		;(10) close file
	lxi	d,ufcb		;unsqueezed FCB
	call	BDOS
	cpi	0FFH
	lxi	d,nclo		;'cannot close file'
	jz	ferm		;final (error) message
	jmp	exit

;	Read one bit at a time.

rbit:	push	h
	lxi	h,roco		;bit rotation counter
	dcr	m
	jnz	rbiu
	mvi	m,8
	call	rbyt		;fetch one byte from input stream
	sta	roby		;rotating byte
rbiu:	lda	roby		;rotating byte
	rar
	sta	roby		;rotating byte
	pop	h
	ret

;	Read one word.

rwor:	call	rbyt		;fetch one byte from input stream
	push	psw
	call	rbyt		;fetch one byte from input stream
	pop	h
	mov	l,h
	mov	h,a
	ret

;	Read one byte, refill buffer as needed.

rbyt:	push	h
	lhld	qctr		;byte counter - input buffer
	mov	a,l
	ora	h
	jnz	rbyu
	call	rdsk
	lxi	h,qbuf		;squeezed buffer
	shld	qptr		;byte pointer - input buffer
	lxi	h,qsiz		;size of squeezed file buffer
rbyu:	dcx	h
	shld	qctr		;byte counter - input buffer
	lhld	qptr		;byte pointer - input buffer
	mov	a,m
	inx	h
	shld	qptr		;byte pointer - input buffer
	pop	h
	ret

;	Insert byte in .UNS buffer.

wbyt:	push	h
	lxi	h,uctr		;occupancy of .UNS buffer
	dcr	m
	jnz	wbyy
	mvi	m,usiz		;size of .UNS buffer
	push	psw
	lxi	h,ubuf		;unsqueezed buffer
	shld	uptr		;pointer to .UNS buffer
	call	wrdi
	call	cbuz		;clear output buffer to zeroes
	pop	psw
wbyy:	lhld	uptr		;pointer to .UNS buffer
	mov	m,a
	inx	h
	shld	uptr		;pointer to .UNS buffer
	pop	h
	ret

;	Send ubuf to disk.

wrdi:	mvi	c,26		;(1A) set DMA address
	lxi	d,ubuf		;unsqueezed buffer
	call	BDOS

	mvi	c,21		;(15) write one record
	lxi	d,ufcb		;unsqueezed DCB
	call	BDOS
	cpi	00H
	lxi	d,werr		;'disk write'
	jnz	ferm		;final (error) message
	ret

rdsk:	push	h
	push	d
	push	b

	mvi	c,26		;(1A) set DMA address
	lxi	d,qbuf		;squeezed buffer
	call	BDOS

	mvi	c,20		;(14) read one record
	lxi	d,qfcb		;squeezed FCB
	call	BDOS

	pop	b
	pop	d
	pop	h
	ret

;	Fill ubuf with zeroes.

cbuz:	xra	a
	mvi	b,1		;one sector in buffer
	lxi	h,ubuf		;unsqueezed buffer
cbuy:	mvi	c,tsiz		;record size
cbux:	mov	m,a
	inx	h
	dcr	c
	jnz	cbux
	dcr	b
	jnz	cbuy
	ret

;	Block fill with C B's starting at (HL).

fiuc:	mov	m,b
	inx	h
	dcr	c
	jnz	fiuc		;block fill
	ret

logo:	db	'          UNSQ/ICUAP',CR,LF
	db	'Universidad Autonoma de Puebla',CR,LF
	db	'        July 16, 1983',CR,LF,'$'

tuto:	db	'UNSQ.ASM will restore files which have been squeezed',CR,LF
	db	'by SQ.COM or some similar program.',CR,LF,CR,LF
	db	'    UNSQ [X:]FILE[.QQQ]',CR,LF
	db	CR,LF
	db	'will read [X:]FILE.SQZ to produce [X:]FILE.UNS.',CR,LF
	db	'$'

werr:	db	CR,LF,'Disk write error.$'
nfil:	db	CR,LF,'Requested file not present.$'
yexi:	db	CR,LF,'Unsqueezed file already exists.$'
ntab:	db	CR,LF,'Insufficient space for dictionary.$'
nsqz:	db	CR,LF,'Not a squeezed file.$'
chno:	db	CR,LF,'Checksum failure.$'
nopn:	db	CR,LF,'Can''t open source.$'
nodi:	db	CR,LF,'Disk or Directory full.$'
nclo:	db	CR,LF,'Cannot close file.$'

ufcb:	ds	21H		;unsqueezed FCB
uctr:	ds	1		;occupancy of .UNS buffer
uptr:	ds	2		;pointer to .UNS buffer
ubuf:	ds	usiz		;unsqueezed buffer
reco:	ds	1		;record counter
rbrk:	ds	2		;record breakpoint
lach:	ds	1		;last character typed
roco:	ds	1		;rotating bit counter
roby:	ds	1		;rotating byte
qctr:	ds	2		;byte counter - input buffer
qptr:	ds	2		;byte pointer - input buffer
cksm:	ds	2		;checksum
code:	ds	4*csiz		;decoding table
	ds	100
stak:	ds	2		;stackend

	end
