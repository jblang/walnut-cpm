; ============================================================================
; *                 CP/M 2.2 BIOS EMULATOR FOR CP/M 3.x                      *
; ============================================================================
;  This program, by Mike Griswold, is a Resident System Extension (RSX) which
;  runs under CP/M-Plus.  This RSX intercepts certain BIOS function calls,
;  and resolves differences between CP/M 2.2 and CP/M 3.x.  It allows many
;  programs that do not normally work with CP/M-Plus to work correctly.
;  So far, I have installed this RSX on DU2, which normally does not work
;  at all, and with the RSX, it works perfectly.
;  Installation instructions:
;      1. RMAC CPM22 $pz $sz
;      2. LINK CPM22[OP]
;      3. REN CPM22.RSX=CPM22.PRL
;      4. GENCOM <program name> CPM22
;        NOTE:  <program name> is a .COM file which is the CP/M 2.2 command
;             file.  
;
;  Program typed from Doctor Dobbs Journal #93, July 1984.
;     Typed & Instructions written by Charles Foreman.
;     Uploaded to CURA RCP/M - (212) 625-5931 - by Charles Foreman.
;
;
	title	'CP/M 2.2 BIOS RSX'
;
;	18Jan84			By Mike Griswold
;
;	This RSX will provide CP/M 2.2 compatible BIOS support
;	for CP/M 3.x.  Primarily it performs logical sector
;	blocking and deblocking needed for some programs.
;	All actual I/O is done by the CP/M 3.0 BIOS.
;
	maclib	z80		; Z80 opcode equates
	cseg
;
;	This equate is the only hardware dependant value.
;	It should be set to the largest sector size that 
;   	will be used.
;
max$sector$size:	equ	512
;
;
;	RSX prefix structure
;
	db	0,0,0,0,0,0
entry:	jmp	boot
next:	db	jmp		; jump
	dw	0		; next module in line
prev:	db	0		; previous module
remove:	db	00fh		; remove flag
nonbnk:	db	0
	db	'BIOS2.21'
	db	0,0,0
;
;	Align jump table on next page boundary.  This is needed
;	for programs that cheat when getting the addresses of
;	BIOS jump table entries.  Optimization freaks could move
;	some code up here.  With a 60k TPA though its hard to
;	get excited.
;
	ds	229
;
;	BIOS Jump Table
;
cbt:	jmp	wboot		; cold boot entry
wbt:	jmp	wboot		; warm boot entry
	jmp	xconst		; console status
	jmp	xconin		; console input
	jmp	xconout		; console output
	jmp	xlist		; list output
	jmp	xauxout		; aux device output
	jmp	xauxin		; aux device input
	jmp	home		; home disk head
	jmp	seldsk		; select drive
	jmp	settrk		; select track
	jmp	setsec		; select sector
	jmp	setdma		; set dma address
	jmp	read		; read a sector
	jmp	write		; write a sector
	jmp	xlistst		; list status
	jmp	sectran		; sector translation
;
;	The CP/M 3.0 BIOS jump table is copied here
;	to allow easy access to its routines.  The disk
;	I/O routines are potentially in banked memory
;	so they cannot be called directly.
;
xwboot:	jmp	0		; warm boot
xconst:	jmp	0
xconin:	jmp	0
xconout:jmp	0
xlist:	jmp	0
xauxout:jmp	0
xauxin:	jmp	0
	jmp	0
	jmp	0
	jmp	0
	jmp	0
	jmp	0
	jmp	0
	jmp	0
xlistst:jmp	0
;
;	Signon message
;
signon:	db	0dh,0ah,'BIOS ver 2.21 ACTIVE',0dh,0ah,0
;
;	Cold boot
;
boot:	push	psw		; a BDOS call is in progress
	push	h		; so save CPU state
	push	d
	push	b
	lxi	h,next		; now bypass this RSX on
	shld	entry+1		; all subsequent BDOS calls
	call	init		; initialize BIOS variables
	lhld	1		; save the CP/M 3.0 BIOS jump
	shld	old$addr	; at location 0
	lxi	d,xwboot	; set up to move jump table
	lxi	b,15*3		; byte count
	ldir
	lxi	h,wbt		; substitute new jump address
	shld	1
	lxi	h,signon	; sound off
	call	prmsg
	pop	b		; restore BDOS call state
	pop	d
	pop	h
	pop	psw
	jmp	next		; carry on
;
;	Warm boot
;
wboot:	lhld	old$addr
	shld	1		; restore normal BIOS address
	jmp	0		; jump to CP/M 3.0 warm boot
;
;	Initialize BIOS internal variables for cold boot
;
init:	xra	a
	sta	hstwrt		; host buffer written
	sta	hstact		; host buffer inactive
	lxi	h,80h
	shld	dmaadr
	ret
;
;	Routine to call banked BIOS routines via BDOS
;	function 50.  All disk I/O calls are made through
;	here.
;
xbios:	sta	biospb		; set BIOS function
	mvi	c,50		; direct BIOS call function
	lxi	d,biospb	; BIOS parameter block
	jmp	next		; jump to BDOS
;
biospb:	db	0		; BIOS function
areg:	db	0		; A reguster
bcreg:	dw	0		; BC register
dereg:	dw	0		; DE register
hlreg:	dw	0		; HL register
;
;	Home disk.
;
home:	lda	hstwrt		; check if pending write
	ora	a
	cnz	writehst	; dump buffer to disk
	xra	a
	sta	hstwrt		; buffer written
	sta	hstact		; buffer inactive
	sta	unacnt		; zero alloc count
	sta	sektrk		; zero track count
	sta	sektrk+1
	ret
;
;	Select disk.  Create a fake DPH for programs
;	that might use it.
;
seldsk:	mov	a,c		; requested drive number
	sta	sekdsk
	sta	bcreg		; set C reg in BIOSPB
	mvi	a,9		; BIOS function number
	call	xbios		; CP/M 3.0 select
	mov	a,h
	ora	l		; check for HL=0
	rz			; select error
	mov	e,m		; get address of xlat table
	inx	h
	mov	d,m
	xchg
	shld	xlat		; save xlat address
	lxi	h,11		; offset to dpb address
	dad	d
	mov	e,m		; fetch address to dpb
	inx	h
	mov	d,m
	xchg
	shld	dpb		; address of dpb
	mov	a,m		; cpm sectors per track
	sta	spt
	inx	h
	inx	h		; point to block shift mask
	inx	h
	mov	a,m
	sta	bsm		; save block shift mask
	lxi	d,12		; offset to psh
	dad	d
	mov	a,m
	sta	psh		; save physical shift factor
	lxi	h,dph		; return DPH address
	ret
;
;	This fake DPH holds the addresses of the actual
;	DPB.  The CP/M 3.0 DPH is *not* understood
;	by CP/M 2.2 programs.
;
dph:	equ	$
	dw	0		; no translation
	ds	6		; scratch words
	ds	2		; directory buffer
dpb:	ds	2		; DPB
	ds	2		; CSV
	ds	2		; ALV
;
;	Set track.
;
settrk:	sbcd	sektrk
	ret
;
;	Set dma.
;
setdma:	sbcd	dmaadr
	ret
;
;	Translate sectors.  Sectors are not translated yet.
;	Wait until we know the physical sector number.
;	This works fine as long as the program trusts
;	the BIOS to do the translation.  Some programs
;	access the XLAT table directly to do their own
;	translation.  These programs will get the wrong
;	idea about disk skew but it should cause no
;	harm.
;
sectran:mov	l,c		; return sector in HL
	mov	h,b
	ret
;
;	Set sector number.
;
setsec:	mov	a,c
	sta	seksec
	ret
;
;	Read the selected CP/M sector.
;
read:	mvi	a,1
	sta	readop		; read operation
	inr	a		; a=2 (wrual)
	sta	wrtype		; treat as unalloc
	jmp	alloc		; perform read
;
;	Write the selected CP/M sector.
;
write:	xra	a
	sta	readop		; not a read operation
	mov	a,c
	sta	wrtype		; save write type
	cpi	2		; unalloc block?
	jrnz	chkuna
;
;	Write to first sector of unallocated block.
;
	lda	bsm		; get block shift mask
	inr	a		; adjust value
	sta	unacnt		; unalloc record count
	lda	sekdsk		; set up values for
	sta	unadsk		; writing to an unallocated
	lda	sektrk		; block
	sta	unatrk
	lda	seksec
	sta	unasec
;
chkuna:	lda	unacnt		; any unalloc sectors
	ora	a		; in this block
	jrz	alloc		; skip if not
	dcr	a		; --unacnt
	sta	unacnt
	lda	sekdsk
	lxi	h,unadsk
	cmp	m		; sekdsk = unadsk ?
	jrnz	alloc		; skip if not
	lda	sektrk
	cmp	m		; sektrk = unatrk ?
	jrnz 	alloc		; skip if not
	lda	seksec
	lxi	h,unasec
	cmp	m		; sektrk = unasec ?
	jrnz	alloc		; skip if not
	inr	m		; move to next sector
	mov	a,m
	lxi	h,spt		; addr of spt
	cmp	m		; sector > spt ?
	jrc	noovf		; skip if no overflow
	lhld	unatrk
	inx	h
	shld	unatrk		; bump track
	xra	a
	sta	unasec		; reset sector count
noovf:	xra 	a
	sta	rsflag		; don't pre-read
	jr	rwoper		; perform write
;
alloc:	xra	a		; requires pre-read
	sta	unacnt
	inr	a
	sta	rsflag		; force pre-read
;
rwoper:	xra	a
	sta	erflag		; no errors yet
	lda	psh		; get physical shift factor
	ora 	a		; set flags
	mov	b,a
	lda	seksec		; logical sector
	lxi	h,hstbuf	; addr of buffer
	lxi	d,128
	jrz	noblk		; no blocking
	xchg			; shuffle registers
shift:	xchg
	rrc
	jrnc	sh1
	dad	d		; bump buffer address
sh1:	xchg
	dad	h
	ani	07fh		; zero high bit
	djnz	shift
	xchg			; HL=buffer addr
noblk:	sta	sekhst
	shld	sekbuf
	lxi	h,hstact	; buffer active flag
	mov	a,m
	mvi	m,1		; set buffer active
	ora	a		; was it already?
	jrz	filhst		; fill buffer if not
	lda	sekdsk
	lxi	h,hstdsk	; same disk ?
	cmp	m
	jrnz	nomatch
	lda	sektrk
	lxi	h,hsttrk	; same track ?
	cmp	m
	jrnz	nomatch
	lda	sekhst		; same buffer ?
	lxi	h,hstsec
	cmp	m
	jrz	match
;
nomatch:
	lda	hstwrt		; buffer changed?
	ora	a
	cnz	writehst	; clear buffer
;
filhst:	lda	sekdsk
	sta	hstdsk
	lhld	sektrk
	shld	hsttrk
	lda	sekhst
	sta	hstsec
	lda	rsflag		; need to read ?
	ora	a
	cnz	readhst		; yes
	xra	a
	sta	hstwrt		; no pending write
;
match:	lhld	dmaadr
	xchg
	lhld	sekbuf
	lda	readop		; which way to move ?
	ora	a
	jrnz	rwmove		; skip if read
	mvi	a,1
	sta	hstwrt		; mark buffer changed
	xchg			; hl=dma  de=buffer
;
rwmove:	lxi	b,128		; byte count
	ldir			; block move
	lda	wrtype		; write type
	cpi	1		; to directory ?
	jrnz	exit		; done
	lda	erflag		; check for errors
	ora	a
	jrnz	exit		; don't write dir if so
	xra	a
	sta	hstwrt		; show buffer written
	call	writehst	; write buffer
exit:	lda	erflag
	ret
;
;	Disk read.  Call CP/M 3.0 BIOS to fill the buffer
; 	with one physical sector.
;
readhst:
	call	rw$init		; init CP/M 3.0 BIOS
	mvi	a,13		; read function number
	call	xbios		; read sector
	sta	erflag
	ret
;
;	Disk write.  Call CP/M 3.0 BIOS to write one
;	physical sector from buffer.
;
writehst:
	call	rw$init		; init CP/M 3.0 BIOS
	mvi	a,14		; write function number
	call	xbios		; write sector
	sta	erflag
	ret
;
;	Translate sector.  Set CP/M 3.0 track, sector,
;	DMA buffer and DMA bank.
;
rw$init:
	lda	hstsec		; physical sector number
	mov	l,a
	mvi	h,0
	shld	bcreg		; sector number in BC
	lhld	xlat		; address of xlat table
	shld	dereg		; xlat address in DE
	mvi	a,16		; sectrn function number
	call	xbios		; get skewed sector number
	mov	a,l
	sta	actsec		; actual sector
	shld	bcreg		; sector number in BC
	mvi	a,11		; setsec function number
	call	xbios		; set CP/M 3.0 sector
	lhld	hsttrk		; physical track number
	shld	bcreg		; track number in BC
	mvi	a,10		; settrk function number
	call	xbios
	lxi	h,hstbuf	; sector buffer
	shld	bcreg		; buffer address in BC
	mvi	a,12		; setdma function number
	call	xbios
	mvi	a,1		; DMA bank number
	sta	areg		; bank number in A
	mvi	a,28		; setbnk function number
	call	xbios		; set DMA bank
	ret
;
;	Print message at HL until null.
;
prmsg:	mov	a,m
	ora 	a
	rz
	mov	c,m
	push	h
	call	xconout
	pop	h
	inx	h
	jmp	prmsg
;
;	disk i/o buffer
;
hstbuf:	ds	max$sector$size
;
;	variable storage area
;
sekdsk:	ds	1		; logical disk number
sektrk:	ds	2		; logical track number
seksec:	ds	1		; logical sector number
;
hstdsk:	ds	1		; physical disk number
hsttrk:	ds	2		; physical track number
hstsec:	ds	1		; physical sector number
;
actsec:	ds	1		; skewed physical sector
sekhst:	ds	1		; temp physical sector
hstact:	ds	1		; buffer active flag
hstwrt:	ds	1		; buffer changed flag
;
unacnt:	ds	1		; unallocated sector count
unadsk:	ds	1		; unalloc disk number
unatrk:	ds	2		; unalloc track number
unasec:	ds	1		; unalloc sector number
sekbuf:	ds	2		; logical sector address in buffer
;
spt:	ds	1		; cpm sectors per track
xlat:	ds	2		; xlat address
bsm:	ds	1		; block shift mask
psh:	ds	1		; physical shift factor
;
erflag:	ds	1		; error reporting
rsflag:	ds	1		; force sector read
readop:	ds	1		; 1 if read operation
rwflag:	ds	1		; physical read flag
wrtype:	ds	1		; write operation type
dmaadr:	ds	2		; last dma address
oldaddr:ds	2		; address of old BIOS
;
	end
