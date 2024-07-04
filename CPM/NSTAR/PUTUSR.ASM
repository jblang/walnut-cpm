;PUTUSR.ASM v1.00 as of 12-15-83
;Written by S. Kluger and placed into the public domain.
;Please see PUTUSR.DOC for description
;
dcomof	equ	16*3		;offset to BIOS DCOM routine
bios	equ	1		;BIOS vector location
bdos	equ	5		;BDOS entry point
usero	equ	700h		;user offset from BIOS
dbuf	equ	80h		;default buffer
conin	equ	1		;BDOS console in
print	equ	9		;BDOS print string
fopen	equ	15		;BDOS open file
fread	equ	20		;BDOS read sequential
stdma	equ	26		;BDOS set DMA
;
cr	equ	0dh
lf	equ	0ah
;
	org	100h
;
; Program entry point. Set up local stack.
;
start:	lxi	sp,stack
	call	banner		;say who we are
	call	ckcpm		;check CP/M, ret only if ok
	call	getidr		;ask for input drive
	call	loadhx		;load hex file
	call	xlhex		;translate HEX to binary
next:	call	savusr		;write user to disk
	jz	next		;yes, more
	rst	0		;fast way out
;
; BANNER routine. Announce our presence.
;
banner:	lxi	d,baner
string:	mvi	c,print
	jmp	bdos
;
; CKCPM routine. Set up pointers and check for N* CP/M
;
ckcpm:	lhld	bdos+1		;get BDOS pointer
	mvi	l,0		;point to OEM code
	mov	a,m		;get first byte
	cpi	0e3h
	jnz	barfc		;complain if not N*
	inx	h
	mov	a,m
	cpi	16h
	jz	cpmok		;continue if ok
barfc:	lxi	d,mbarfc
	call	string
	rst	0		;warm boot
;
cpmok:	lhld	bios		;get BIOS vector
	lxi	d,dcomof	;DCOM vector offset
	dad	d		;DCOM addr now in HL
	shld	dcom+1		;set address
	mov	a,m		;let's see if the...
	cpi	0c3h		;...BIOS is still ok
	jnz	barfc		;no, complain
	ret
;
; GETIDR routine - get input drive letter A..P
;
getidr:	lxi	d,mindr		;display prompt
	call	getdr		;get A..P
	ani	0fh		;make 1..16
	sta	fcb		;save drive in FCB
	ret
;
; LOADHX routine. Does the following:
; 1. open USER.HEX
; 2. load file into RAM, translate to binary
;
loadhx:	call	ack		;acknowledge
	lxi	d,fcb		;let's open the file
	push	d		;save fcb
	mvi	c,fopen
	call	bdos
	inr	a
	jz	nofile		;complain of error
	lxi	h,hbuf		;set dma buffer
	shld	hptr		;save buffer ptr
	xchg
	mvi	c,stdma
	call	bdos
	pop	d		;get fcb
	push	d
	mvi	c,fread
	call	bdos		;read a sector
	ora	a
	jnz	inerr		;initial read error
lloop:	lxi	d,80h		;increment hex buffer
	lhld	hptr
	dad	d
	shld	hptr
	xchg
	mvi	c,stdma
	call	bdos
	pop	d		;get fcb
	push	d		;save it
	mvi	c,fread
	call	bdos		;read next
	ora	a		;if no error...
	jz	lloop		;...then decode and load next
	pop	d		;clean up stack
	ret			;else done (hopefully)
;
; XLHEX - translate ASCII chars into binary
;
xlhex:	lxi	h,buffer	;hl=binary buffer
	push	h		;save it
	lxi	b,200h		;512 bytes to zero
zerbuf:	mvi	m,0
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jnz	zerbuf
	xchg
	pop	h
newln:	ldax	d		;get next byte
	cpi	':'		;separator?
	inx	d		;point ot next
	jnz	newln		;loop until : found
	push	d
	lxi	d,hbuf
	mov	a,h
	cmp	d
	jnc	toobig
	pop	d
	mvi	c,0		;zero checksum
	call	get2		;get 2 nybbles
	ora	a		;if zero
	rz			;then done.
	mov	b,a		;save count
	push	h		;save buffer
	mvi	h,3		;6 bytes to skip
adsk:	call	get2		;get byte
	dcr	h
	jnz	adsk
	pop	h		;now we get serious...
code:	call	get2		;get next
	mov	m,a
	inx	h
	dcr	b
	jnz	code
	call	get2		;get checksum
	mov	a,c
	ora	a
	jz	newln		;loop if ok
	lxi	d,mcksm		;checksum error
	call	string
	rst	0	
;
; SAVUSR routine - save user to disk and
;	 ask for more saves.
;
savusr:	lxi	d,modrv		;display prompt
	call	getdr		;get A..P
	ani	0fh
	ori	80h		;specify double density
	push	psw
	call	ack
	pop	psw
;
; The following is register preparation for the DCOM
; routine. I call it DCOM because it is very similar to
; the N* DOS DCOM routine. the parameters are:
; B=track	C=density/drive
; D=sector	E=command
; A=# of sect	HL=buffer addr
; For more info, read the comments in DIRDUMP.ASM
;
	mov	c,a		;place drive/density in C
	mvi	a,1		;1 (one) N* sector
	mvi	e,0		;write command
	mvi	d,8		;sector
	mvi	b,0		;track
	lxi	h,buffer	;binary code buffer
dcom:	call	0		;filled at startup
	lxi	d,mfcom		;say finished
	call	string
	mvi	c,conin		;get response
	call	bdos
	ani	5fh		;make caps
	cpi	'Y'
	ret
;
; UTILITY SUBROUTINES
;
; GETDR - get drive letter in A, complain if invalid.
;
getdr:	call	string
agn:	mvi	c,conin
	call	bdos		;get response character
	ani	5fh		;make caps
	cpi	'A'
	jc	invdr		;invalid drive
	cpi	'P'
	rc			;return if ok
invdr:	lxi	d,minvdr
	call	string
	jmp	agn
;
; GET2 - get 2 nybbles into A
; DE=pointer, save all reg
; ret with DE advanced and cksum updated
;
get2:	push	b		;save checksum & count
	ldax	d		;get hi nybble
	cpi	'A'
	jc	nhx1
	sui	7
nhx1:	ani	0fh
	ral
	ral
	ral
	ral
	mov	b,a
	inx	d
	ldax	d
	cpi	'A'
	jc	nhx2
	sui	7
nhx2:	ani	0fh
	ora	b
	inx	d
	pop	b
	push	psw
	add	c
	mov	c,a
	pop	psw
	ret
;
; ACK routine - wait for RETURN
;
ack:	lxi	d,mack
	call	string
ackl:	mvi	c,conin
	call	bdos
	cpi	cr
	jnz	ackl
	ret
;
; NOFILE - file not found
;
nofile:	lxi	d,mnofil
	call	string
	rst	0
;
; INERR - empty file maybe?
;
inerr:	lxi	d,minerr
	call	string
	rst	0
;
; TOOBIG - USER area is over 512 bytes
;
toobig:	lxi	d,mbig
	call	string
	rst	0
;
; MESSAGES FOLLOW
;
baner:	db	cr,lf
	db	'PUTUSR v1.00 by S. Kluger',cr,lf
	db	'Any response of CONTROL-C aborts.',cr,lf,lf,'$'
;
mbarfc:	db	cr,lf,7
	db	'ERROR - CP/M cannot be identified as '
	db	'North Star CP/M - ABORTING',cr,lf,lf,'$'
;
mindr:	db	cr,lf
	db	'Please enter drive letter of the drive containing',cr,lf
	db	'the file USER.HEX (A..P)  :$'
;
modrv:	db	cr,lf
	db	'USER file in RAM now, please enter drive letter',cr,lf
	db	'of the output drive (A..P):$'
;
mfcom:	db	cr,lf,lf
	db	'SAVE COMPLETED.',cr,lf
	db	'Do you wish to save USER to another disk (Y/N) ? $'
;
minvdr:	db	cr,lf,lf,7
	db	'Invalid drive. Drive letter must be A..P.',cr,lf
	db	'Please try again (A..P)   :$'
;
mnofil:	db	cr,lf,lf,7
	db	'ERROR - file USER.HEX not found on disk!',cr,lf,lf,'$'
;
minerr:	db	cr,lf,lf,7
	db	'ERROR while reading USER.HEX - file empty?',cr,lf,lf,'$'
;
mcksm:	db	cr,lf,lf,7
	db	'CHECKSUM error in USER.HEX',cr,lf,lf,'$'
;
mbig:	db	cr,lf,lf,7
	db	'ERROR - USER area > 512 bytes!',cr,lf,lf,'$'
;
mack:	db	cr,lf
	db	'MOUNT DISK AND PRESS RETURN WHEN READY$'
;
hptr:	dw	0
;
fcb:	db	0,'USER    HEX',0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0
;
	ds	48		;some stack space
stack	equ	$
buffer	equ	$
hbuf	equ	$+512
	end
