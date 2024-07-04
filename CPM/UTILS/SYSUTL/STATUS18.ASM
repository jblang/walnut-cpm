; Lauren Guimont	1-25-80		Ver. 1.0
; 			1-28-80		Ver. 1.1
; 			3-20-80		Ver. 1.2
; 			6-26-80		Ver. 1.3

; Benny D. Miller jr WB8LGH	05-Jan-84	ver. 1.8
; 	added MP/M II information.

; This is an assembly language adaption of a program
; written in NorthStar BASIC called `STATUS'.

; This program will determine the location of numerous
; addresses, depending on the system size being run.
; It will also present various pieces of information
; concerning the status of many of the options available
; under CP/M 2.20, besides presenting a map of the memory
; of the host system.

; 26-july-82	added ports(disk destructive read protect)
; 	at locations 103(low port) and 104(high port),
; 	or at 203,204 if PRL file.  Actually bypasses these
; 	ports if set other than 0.

; 21-july-82	Status now gives the console(user's), and
; 	maximun consoles. Xios jump table, checks for
; 	CP/Net active/non-active, system time of day,
; 	displays all memory segments.

; Set up the equates to use

true	equ	0ffffh		; true equate.
false	equ	not true	; false equate.

rmac	equ	true		; if assembled with rmac, and link.
hide	equ	true		; if hide disk ports, to stop destructive
				; reads, also check porta, and portb equates.

	if rmac
extrn	bdos			; I/O call.
	endif

	if not rmac
bdos	equ	5		; bdos equate.
	endif

ff	equ	0ch	; form feed.

CONOUT	EQU	2		; CONSOLE CHAR OUT
giobyte	equ	7		; get the iobyte.
STROUT	EQU	9		; PRINT STRING OUTPUT
version	equ	12		; returns version.
mpmvrs	equ	163		; MP/M 2.x revision.
LOGIN	EQU	24		; RETURNS ON-LINE DRIVES
CURDRV	EQU	25		; RETURNS DEFAULT DRIVE#
ALLOC	EQU	27		; RETURNS ALLOCATION ADDRESS
RONLY	EQU	29		; RETURNS READ ONLY VECTOR
DPARA	EQU	31		; RETURNS DISK PARAMETER BLK
PRUSER	EQU	32		; RETURNS PRESENT USER
console	equ	153		; get console number.
sysdat	equ	154		; get system data address.
systod	equ	155		; get system time of day.

	if not rmac
	org	0100h
	endif

start:
	jmp	astart

; 	port hide, so that a destructive read doesn't happen.

porta	db	0c0h		; disk 1 start port address.
portb	db	0c3h		; disk 1 last port address.

astart:				; Actual program start
	LXI	H,0		; Clear HL
	DAD	SP		; Get SP from CCP
	SHLD	OLDSP		; Save it
	LXI	SP,STACK	; Point to our stack

	mvi	c,version	; get CP/M, MP/M version.
	call	bdos		;
	mov	a,h		; see if MP/M.
	sta	mpmbyte		; save it.
	mov	a,l		; version number CP/M 1.x or 2.x.
	sta	cpmbyte		; save it.

	CALL	CLEAR

	lda	mpmbyte		; see if MP/M or CP/M.
	ora	a		; is MP/M if none zero.
	jz	cpm		; go do CP/M message if not.
	lxi	d,msg24		; do MP/M message.
	mvi	c,strout	; print it command.
	call	bdos		; go print it.
	lda	cpmbyte		; get mpm version.
	ani	0f6h		; if bit 1 set mpm 1. only.
	lda	mpmbyte		; re-get byte just in case.
	jz	contmpm		; do mp/m 1.1
	mvi	c,mpmvrs	; go see which MP/M.
	call	bdos		;
	mov	a,l		; save mp/m 2 revision level.
	sta	cpmbyte		; save it.
	mov	a,h		; get 1 for mpm 2
	sta	mpmbyte		; save new MP/M byte.

contmpm:
	adi	31h		; add ascii offset.
	call	cout		; output first number.
	mvi	a,'.'		; now the seprator.
	call	cout		; out put it.
	lda	cpmbyte		; now the lower version number.
	ani	0fh		; strip upper nibble.
	adi	30h		; add ascii offset.
	call	cout		; go print it.
	lxi	d,msg27		; trailing end of message.
	mvi	c,strout	; print command.
	call	bdos		; go print it.
	call	crlf		; go do cr,lf.
	jmp	bpcpm		; bypass CP/M message.

cpm:
	LXI	D,MSG0
	MVI	C,STROUT
	CALL	BDOS
	lda	cpmbyte		; get cpm version.
	ani	0f0h		; strip upper nibble.
	rar			; rotate right four times.
	rar			; 
	rar			; 
	rar			; 
	adi	30h		; add ascii offset.
	call	cout		; output first number.
	mvi	a,'.'		; now the seprator.
	call	cout		; out put it.
	lda	cpmbyte		; now the lower version number.
	ani	0fh		; strip upper nibble.
	adi	30h		; add ascii offset.
	call	cout		; go print it.
	lxi	d,msg27		; trailing end of message.
	mvi	c,strout	; print command.
	call	bdos		; go print it.
	call	crlf		; go do cr,lf.

bpcpm:
	LXI	D,MSG1
	MVI	C,STROUT
	CALL	BDOS

; This is the start of the memory map

	LXI	H,0000H		; Start memory map

MEMORY:
	MVI	A,0FFH
	CMP	M		; Memory?
	JZ	EMPTY
	MOV	B,M		; Save memory value
	MOV	M,A
	MOV	A,M
	CMP	B		; Same as original?
	JZ	ROM

RAM:
	MOV	M,B		; Replace original byte
	MVI	B,4DH
	JMP	SHWBY

ROM:
	MVI	B,52H
	JMP	SHWBY

EMPTY:
	MVI	A,80H		; Double check W/new value
	MOV	B,M
	MOV	M,A
	MOV	A,M
	CMP	B		; Is it ram?
	JNZ	RAM
	MVI	B,2EH

SHWBY:
	MOV	A,B
	CALL	COUT		; Output ROM, RAM, or empty
	INR	H
	INR	H
	INR	H
	INR	H
	JNZ	MEMORY		; Loop till done
	CALL	CRLF

; Now we fill in the storage bytes with the proper
; values which are dependent on each particular system.

	lda	mpmbyte
	ora	a		; will be none zero for MP/M.
	jnz	alocxios	; do acllocation vectors.

	LHLD	BDOS+1		; Get start of BDOS
	MOV	A,L
	SUI	6
	MOV	L,A
	SHLD	BEDOS		; Store it
	LXI	D,0F700H
	LHLD	BEDOS
	DAD	D		; Add wrap around offset
	SHLD	TPA
	LXI	D,100H
	LHLD	TPA
	DAD	D
	SHLD	CCP		; Store CCP=-100H of TPA
	MVI	C,GIOBYTE
	CALL	BDOS
	STA	IOBYT		; Store the I/O byte

alocxios:
	lda	mpmbyte		; see if MP/M.
	ora	a		; if not zero
	jnz	mpmaloc		; do MP/M allocation vectors.

	lda	cpmbyte
	ani	0f0h		; see if 1.x version.
	jz	not2cpm		; go past if now 2.x CP/M.

mpmaloc:
	MVI	C,ALLOC
	CALL	BDOS
	SHLD	ALLOCAD

	lda	mpmbyte		; see if MP/M.
	ora	a		; if not zero
	jnz	conmax		; do maximun number of consoles.

; Now we must output the gathered information
; to the console

; Get the CCP address and print it

not2cpm:
	LXI	D,MSG2
	MVI	C,STROUT
	CALL	BDOS
	LHLD	CCP
	CALL	ADOUT
	CALL	CRLF

; Next get the BDOS address and print it

	LXI	D,MSG3
	MVI	C,STROUT
	CALL	BDOS
	LHLD	BEDOS
	CALL	ADOUT
	CALL	CRLF

; Next get address of BIOS and print it

	LXI	D,MSG15
	MVI	C,STROUT
	CALL	BDOS
	LXI	D,0E00H
	LHLD	BEDOS
	DAD	D
	CALL	ADOUT
	CALL	CRLF

; Compute TPA without killing CCP and print it

	LXI	D,MSG13
	MVI	C,STROUT
	CALL	BDOS
	LHLD	TPA
	CALL	ADOUT
	LXI	D,MSG11
	MVI	C,STROUT
	CALL	BDOS
	CALL	CRLF

	jmp	drvchk


; print the number of consoles supported.

conmax:
	lxi	d,msg28		; go print message for number of consoles.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,1		; increment to number of consoles.
	call	offset		; dad the d wth the h&l.
	sta	maxcon		; store at maximun number of consoles.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

; 	do a system console number output.

syscon:
	lxi	d,msg25		; point to message.
	mvi	c,strout	; print command.
	call	bdos		; print it.
	mvi	c,console	; get console number.
	call	bdos		; comes back in a.
	adi	30h		; add ascii offset.
	call	cout		; go do it.
	call	crlf		; do cr,lf.

;	see if extended information bytes at end of bnkxios jmp table.

extended:
	lxi	d,7		; find xios jmp table address.
	call	offset		; dad the d wth the h&l.
	mov	h,m		; get base address of xios.
	mvi	l,0		; always start at base pge of it.
	lxi	d,75		; go past xios jmp table.
	dad	d		; update pointer.
	mov	a,m		; get the byte.
	ani	0ffh		; see if boolean non zero if MPM II jmp table.
	jz	tod		; go do systems time of day.
	inx	h		; must be 2 bytes set to ffh
	shld	exiospt		; extended xios pointer.
	mov	a,m		; get byte.
	ani	0ffh		; ok?
	jz	tod		; do the systems time of day.

	lxi	d,msg99		; go print the BSR controller is active.
	mvi	c,strout	; string output function.
	call	bdos		; do it.

	lhld	exiospt		; restore just in case.
	lxi	d,24		; see if bsr on/off, it is,
 				; 25 from base inormation bytes.
	dad	d		; add to pointer.
	mov	a,m		; get byte.
	inx	h		; up next byte.
	inx	h		; up next byte.
	shld	exiospt		; extended xios pointer.
	ani	0ffh		; of ff then it is on.
	jnz	bsract		; go do active message.
	lxi	d,msg37		; go print the CP/Net is inactive.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.
	jmp	cnulls		; go to console and nulls.

bsract:
	lxi	d,msg38		; go print the CP/Net is active.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.

cnulls:
	lxi	d,msg44		; go print the console number(0-to-end).
	mvi	c,strout	; string output function.
	call	bdos		; do it.

	lda	csole		; get console number back.
	adi	30h		; make ascii.
	call	cout		; go print console number.

	lxi	d,msg45		; go print the 'has' message.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lhld	exiospt		; get pointer back.
	mov	a,m		; get the current number of nulls.
	adi	30h		; add ascii offset.
	call	cout		; go print it.

	lxi	d,msg46		; go print the 'nulls' message.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; add carriage return, linefeed per message.

	lda	csole		; get console number.
	adi	1		; next console.
	sta	csole		; save it again.
	lhld	exiospt		; just makeing sure it's right.
	inx	h		; next null pointer also.
	shld	exiospt		; resave.
	lda	maxcon		; done 1, now next one,
	sui	1		; one less,
	sta	maxcon		; to do.
	jnz	cnulls		; loop till all consoles are done.

; 	do a TOD, sytem time of day.

tod:
	lxi	d,msg26		; get tod message.
	mvi	c,strout	; print command.
	call	bdos		; print it.
	mvi	c,systod	; time of day command.
	lxi	d,time		; set up for date, hour, minutes, seconds.
	call	bdos		; go do it.

	lxi	h,time1		; do time hours for now.
	call	dobyte		; go do a byte
	mvi	a,':'		; separater.
	call	cout		; go print it.
	inx	h		; minutes.
	call	dobyte		; go do it.
	mvi	a,':'		; separater.
	call	cout		; go print it.
	inx	h		; seconds.
	call	dobyte		; go do it.
	call	crlf		; do cr,lf.

; now do the restart number.

	lxi	d,msg29		; go print the restart message.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,2		; increment to the breakpoint number.
	call	offset		; dad the d wth the h&l.
	adi	30h		; ascii offset.
	call	cout		; go print it.
	call	crlf		; do cr,lf.

; now do CPU type.

	lxi	d,msg30		; go print the CPU message.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,5		; increment to the CPU type.
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; if ff then z-80 else 8080(type).
	jnz	z80		; do z-80 if ff.
	lxi	d,msg31		; go print the 8080 CPU.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.
	jmp	bkbdos		; go to xios jmp table.

z80:
	lxi	d,msg32		; go print the Z-80 CPU.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.

; now do the bank bdos function.

bkbdos:
	lxi	d,4		; increment to banked switched memory
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; see if boolean non zero if banked switched.
	jz	rspage		; go do resident page if not.
	lxi	d,msg33		; go print the bank switched memory indicator.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.


; now do the resident page address.

rspage:
	lxi	d,6		; increment to BDOS RSP page address.
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; see if boolean non zero if banked switched.
	jz	xios		; go do xios jm table.
	lxi	d,msg35		; go print the bdos resident page.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.

resbdos:
	lxi	d,msg43
	mvi	c,strout
	call	bdos

	lxi	d,8		; increment to resident bdos.
	call	offset		; dad the d wth the h&l.
	mov	d,m		; get into d for printing.
	mvi	e,0		; force low order byte to zero.
	xchg			; exchange the de&hl for printing address.
	call	adout		; go print address.
	xchg			; get back hl.
	call	crlf		; then cr,lf.

; 	do XIOS printout, and some other MP/M stuff.
; 	ex: memory segmnts and size, console number, time of day.

xios:
	lxi	d,7		; increment to xios jmp table address.
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; see if boolean non zero if MPM II jmp table.
	jz	xdos		; go do xdos if not.

	lxi	d,msg20
	mvi	c,strout
	call	bdos

	lxi	d,7		; increment to xios jmp table.
	call	offset		; dad the d wth the h&l.
	mov	d,m		; get into d for printing.
	mvi	e,0		; force low order byte to zero.
	xchg			; exchange the de&hl for printing address.
	call	adout		; go print address.
	xchg			; get back hl.
	call	crlf		; then cr,lf.

; now print the address of the xdos.

xdos:
	lxi	d,11		; increment to banked XDOS address.
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; 
	jz	rsp		; 
	lxi	d,msg39		; go print the XDOS address start.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,11		; increment to banked XDOS address.
	call	offset		; dad the d wth the h&l.
	mov	d,m		; get into d for printing.
	mvi	e,0		; force low order byte to zero.
	xchg			; exchange the de&hl for printing address.
	call	adout		; go print address.
	xchg			; get back hl.
	call	crlf		; do cr,lf.

; now do the RSP base page address.

rsp:
	lxi	d,12		; increment to banked RSP base page address.
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; 
	jz	bxios		; 
	lxi	d,msg40		; go print the RSP address start.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,12		; increment to banked RSP base page address.
	call	offset		; dad the d wth the h&l.
	mov	d,m		; get into d for printing.
	mvi	e,0		; force low order byte to zero.
	xchg			; exchange the de&hl for printing address.
	call	adout		; go print address.
	xchg			; get back hl.
	call	crlf		; do cr,lf.

; now do the banked XIOS base pase address.

bxios:
	lxi	d,13		; increment to banked XIOS address.
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; 
	jz	bnkbdos		; 
	lxi	d,msg41		; go print the banked XIOS address start.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,13		; increment to xios jmp table.
	call	offset		; dad the d wth the h&l.
	mov	d,m		; get into d for printing.
	mvi	e,0		; force low order byte to zero.
	xchg			; exchange the de&hl for printing address.
	call	adout		; go print address.
	xchg			; get back hl.
	call	crlf		; then cr,lf.

; now do the banked BDOS base page.

bnkbdos:
	lxi	d,14		; increment to banked BDOS address.
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; 
	jz	cpnet		; go do CP/Net if not.
	lxi	d,msg42		; go print the banked BDOS address start.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,14		; increment to banked BDOS address.
	call	offset		; dad the d wth the h&l.
	mov	d,m		; get into d for printing.
	mvi	e,0		; force low order byte to zero.
	xchg			; exchange the de&hl for printing address.
	call	adout		; go print address.
	xchg			; get back hl.
	call	crlf		; do cr,lf.

; now do CP/Net function.

cpnet:
	lxi	d,msg36		; go print CP/Net.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,09h		; increment to CP/Net active/nonactive.
	call	offset		; dad the d wth the h&l.
	ani	0ffh		; see if boolean non zero if banked switched.
	jnz	active		; go do active message.
	lxi	d,msg37		; go print the CP/Net is inactive.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.
	jmp	memseg		; go to memory segments.

active:
	lxi	d,msg38		; go print the CP/Net is active.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.

memseg:
	lxi	d,msg21
	mvi	c,strout
	call	bdos
	call	crlf
	lxi	d,msg22
	mvi	c,strout
	call	bdos
	call	crlf
	lxi	d,0fh		; offset to memory segments address start.
	call	offset		; hl now pointing to memory seg address.
	adi	1		; make one higher.
	sta	segcnt		; store memory segment count in memory.

memore:
	inx	h		; next byte.
	mov	d,m		; get high order address.
	mvi	e,0		; force low byte to zero.
	lda	segcnt		; put into a.
	sui	1		; if none zero then is memory segment.
	sta	segcnt		; less one on the counter.
	jz	numrecd		; go do number of records check.

mem1time:
	push	h		; save hl.
	xchg			; put de into hl.
	call	adout		; output address.
	xchg			; get bck hl.

	lxi	d,msg23		; output a few spaces.
	mvi	c,strout	; print it.
	call	bdos

	pop	h		; get it back.
	inx	h		; now we are there.
	mov	d,m		; get high address.
				; note high low reversed for memory seg size.
	mvi	e,0		; force to 0.
	xchg			; put de into hl.
	call	adout		; output size.
	xchg			; get back hl.

; add these functions later.
	inx	h		; increment past attrabute.
	inx	h		; increment past segment times.

	push	h		; save it.

	lxi	d,msg23		; output a few spaces.
	mvi	c,strout	; print it.
	call	bdos

	pop	h		; get it back.
	mov	a,m		; get bnk number.
	push	h		; save it again.
	call	heout		; go print hex output.
	call	crlf		; do cr,lf
	pop	h		; restore pointer.

	jmp	memore		; do till done.

dobyte:
	mov	a,m		; note, this uses nibbles for time.
	ani	0f0h		; drop lower nibble.
	rar			; do four.
	rar			; 
	rar			; 
	rar			; now have in lower nibble, time tens.
	adi	30h		; add ascii offset.
	call	cout		; go print it.
	mov	a,m		; get byte again.
	ani	0fh		; drop upper nibble.
	adi	30h		; add ascii offset, time units.
	call	cout		; go print it.
	ret			; done.

offset:
	push	d
	mvi	c,sysdat	; get system data address.
	call	bdos		; comes back in hl.
	pop	d
	dad	d		; hl now pointing area in system data
				; for location pointed to by the d&e.
	mov	a,m		; has how many memory segments their are in
	ret			; done here.

; This section allows for future expantion of the MP/M II info at the
; data page address.

numrecd:
	lxi	d,msg47		; go print MP/M.SYS records.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,79h		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	dcx	h		; one less low-order byte.
	mov	a,m		; get it.
	call	heout		; print it.
	call	crlf		; cr lf printed.

	lxi	d,msg48		; ticks/sec.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,7ah		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	call	crlf		; print cr,lf.

	lxi	d,msg49		; system drive.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,7bh		; increment
	call	offset		; dad the d wth the h&l.
	adi	40h		; add ascii offset for drive indicator.
	call	cout		; go print it.
	call	crlf		; print cr,lf.

	lxi	d,msg50		; go print the Common memory.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,7ch		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	mvi	a,0		; force to zer0.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg51		; #RSP's.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,7dh		; increment
	call	offset		; dad the d wth the h&l.
	adi	30h		; add ascii offset.
	call	cout		; go print it.
	call	crlf		; print cr,lf.

	lxi	d,msg52		; go print the listcp array.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,7fh		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	dcx	h		; decement.
	mov	a,m		; get low-order byte.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg53		; max locked records.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0bbh		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	call	crlf		; print cr,lf.

	lxi	d,msg54		; max opened files.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0bch		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	call	crlf		; print cr,lf.

	lxi	d,msg55		; # list items.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0beh		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	dcx	h		; decement.
	mov	a,m		; get low-order byte.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg56		; system locked records.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0c1h		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	call	crlf		; print cr,lf.

	lxi	d,msg57		; system opened files.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0c2h		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	call	crlf		; print cr,lf.

	lxi	d,msg58		; go print dayfile.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0c3h		; increment to dayfile active/nonactive.
	call	offset		; dad the d wth the h&l.	ani	0ffh		; see if boolean non zero if banked switched.
	jnz	dactive		; go do active message.
	lxi	d,msg59		; go print the dayfile is inactive.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.

dactive:
	lxi	d,msg60		; go print the dayfile is active.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	call	crlf		; do cr,lf.

	lxi	d,msg61		; temporary drive.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0c4h		; increment
	call	offset		; dad the d wth the h&l.
	adi	40h		; add ascii offset for drive indicator.
	call	cout		; go print it.
	call	crlf		; print cr,lf.

	lxi	d,msg62		; # of list devices.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0c5h		; increment
	call	offset		; dad the d wth the h&l.
	adi	30h		; add ascii offset.
	call	cout		; go print it.
	call	crlf		; print cr,lf.

	lxi	d,msg63		; go print the XDOS base page.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0f2h		; increment
	call	offset		; dad the d wth the h&l.
 	call	heout		; go print it in hex format.
	mvi	a,0		; force to zer0.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg64		; go print the TMP base page.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0f3h		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	mvi	a,0		; force to zer0.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg65		; go print the console.dat base.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0f4h		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	mvi	a,0		; force to zer0.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg66		; BDOS / XDOS entry point.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0f6h		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	dcx	h		; decement.
	mov	a,m		; get low-order byte.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg67		; TMP.spr base page.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0f7h		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	mvi	a,0		; force to zer0.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg68		; number of banked RSP's.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0f8h		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	mvi	a,0		; force to zer0.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

	lxi	d,msg69		; XDOS internal data segment address.
	mvi	c,strout	; string output function.
	call	bdos		; do it.
	lxi	d,0fch		; increment
	call	offset		; dad the d wth the h&l.
	call	heout		; go print it in hex format.
	dcx	h		; decement.
	mov	a,m		; get low-order byte.
	call	heout		; go print it in hex format.
	call	crlf		; do cr,lf.

; Determine which drive is the current drive in
; use, and print the result

drvchk:
	LXI	D,MSG18
	MVI	C,STROUT
	CALL	BDOS
	MVI	C,CURDRV
	CALL	BDOS
	ADI	41H
	STA	CDRV
	CALL	COUT
	MVI	A,':'
	CALL	COUT
	CALL	CRLF

; Determine Allocation address of current drive, and print it

	lda	mpmbyte		; see if MP/M.
	ora	a		; none zero if so.
	jnz	mpmcurt		; do MP/M current allocation.

	lda	cpmbyte
	ani	0f0h		; see if 1.x version.
	jz	rport		; go to do the i/o ports, if not 2.x CP/M.

mpmcurt:
	LXI	D,MSG5
	MVI	C,STROUT
	CALL	BDOS
	LDA	CDRV
	CALL	COUT
	LXI	D,MSG6
	MVI	C,STROUT
	CALL	BDOS
	LHLD	ALLOCAD
	CALL	ADOUT
	MVI	A,48H
	CALL	COUT
	CALL	CRLF

; Find out which drives are logged in and print them

	MVI	C,LOGIN
	CALL	BDOS
	ANI	0FH
	STA	VECTOR
	LXI	D,MSG4
	MVI	C,STROUT
	CALL	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG7
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG8
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG9
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	LXI	D,MSG10
	MVI	C,STROUT
	CC	BDOS
	CALL	CRLF

; Find and show the read only vectors

	MVI	C,RONLY
	CALL	BDOS
	ANI	0FH
	STA	VECTOR
	LXI	D,MSG14
	MVI	C,STROUT
	CALL	BDOS
	LDA	VECTOR
	ORA	A
	LXI	D,MSG17
	MVI	C,STROUT
	CZ	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG7
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG8
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG9
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	LXI	D,MSG10
	MVI	C,STROUT
	CC	BDOS
	CALL	CRLF

; Get the disk parameter block and display it

	LXI	D,MSG12
	MVI	C,STROUT
	CALL	BDOS
	MVI	C,DPARA
	CALL	BDOS
	CALL	ADOUT
	MVI	A,48H
	CALL	COUT
	CALL	CRLF

; Determine the present USER, and print the result

	LXI	D,MSG19
	MVI	C,STROUT
	CALL	BDOS
	MVI	E,0FFH
	MVI	C,PRUSER
	CALL	BDOS
	CALL	HEOUT
	MVI	A,48H
	CALL	COUT
	CALL	CRLF

; Check all ports (0-255), and determine if they
; are active. If they are, print the port number
; and then do a warm boot (control C)

; BE ADVISED!!

; The lable PORT1 gets a byte from storage from a
; lable called BYTE. This value is incremented from
; 0-255 and then is written to the second byte from
; the lable PORT2. What I'm saying is that this
; portion of code is SELF MODIFYING!!

rport:
	LXI	D,MSG16
	MVI	C,STROUT
	CALL	BDOS
	lda	porta
	sta	aport+1
	lda	portb
	sta	bport+1

PORT1:
	LDA	BYTE
	STA	PORT3+1

aport:
	cpi	0	; original code had a d0 or something
	jm	port3
bport:
	cpi	0
	jm	port2
	jmp	port3

port2:
	call	portout
	jmp	port4

port3:
	IN	0
	CPI	0FFH
	CNZ	PORTOUT

	lda	byte
	cpi	0ffh
	jz	finish

port4:
	LDA	BYTE
	INR	A
	STA	BYTE
	JMP	PORT1

finish:
	LHLD	OLDSP
	SPHL
	RET

PORTOUT:
	LDA	BYTE
	CALL	HEOUT
	CALL	SPACE
	RET

COUT:				; Character output
	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A
	MVI	C,CONOUT
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET

; The following routine will print the value of
; HL to the console. If entered at HEOUT, it will
; only print the value of the A register

ADOUT:				; Output HL to console
	MOV	A,H		; H is first
	CALL	HEOUT
	MOV	A,L		; L is next
HEOUT:
	MOV	C,A		; Save it
	RRC
	RRC
	RRC
	RRC
	CALL	HEOUT1		; Put it out
	MOV	A,C		; Get it back

HEOUT1:
	ANI	0FH
	ADI	48
	CPI	58		; 0-9?
	JC	OUTCH
	ADI	7		; Make it a letter

OUTCH:
	CALL	COUT
	RET

CLEAR:				; Clear console
	mvi	c,25
	MVI	A,0DH		; C/R
	CALL	COUT

CLEAR1:
	MVI	A,0AH		; Linefeed
	CALL	COUT
	DCR	C
	JNZ	CLEAR1		; Loop for 25 LF
	RET

CRLF:				; Send C/R, LF
	MVI	A,0DH
	CALL	COUT
	MVI	A,0AH
	CALL	COUT
	RET

SPACE:
	MVI	A,20H
	CALL	COUT
	RET

; PROGRAM MESSAGES

MSG0:	db	'Status report CP/M version $'
MSG1	DB	'    M=RAM memory           R=ROM memory'
	DB	'          .=no memory',0DH,0AH
	DB	'0   1   2   3   4   5   6   7   8   9'
	DB	'   A   B   C   D   E   F'
	DB	0DH,0AH,'$'
MSG2	DB	'CCP starts at $'
MSG3	DB	'BDOS starts at $'
MSG4	DB	'Current logged in drives;  $'
MSG5	DB	'The Allocation address of drive $'
MSG6	DB	': is $'
MSG7	DB	'A$'
MSG8	DB	', B$'
MSG9	DB	', C$'
MSG10	DB	', D$'
MSG11	DB	' bytes$'
MSG12	DB	'The address of the disk '
	DB	'parameter block is $'
MSG13	DB	'Available TPA without '
	DB	'killing the CCP is $'
MSG14	DB	'These drives are vectored'
	DB	' as read only;  $'
MSG15	DB	'BIOS starts at $'
MSG16	DB	'Active I/O ports: $'
MSG17	DB	'None$'
MSG18	DB	'Current drive in use is $'
MSG19	DB	'The present USER number is $'
msg20:	db	'XIOS jmp table starts at $'
msg21:	db	'Memory segments are $'
msg22:	db	'base         size        bank $'
msg23:	db	'         $'
msg25:	db	'Your console number is $'
msg26:	db	'The system time of day is $'
MSG24:	db	'Status report for the P.H.O.T.U.S.'
	db	' system - MP/M version $'
msg27:	db	' system',0dh,0ah
	db	'              - Program Version 1.8'
		; version as of (05-Jan-84)
	DB	0DH,0AH,0AH,'$'
msg28:	db	'The number of consoles supported in this system is $'
msg29:	db	'Restart number is #$'
msg30:	db	'CPU is a $'
msg31:	db	'8080$'
msg32:	db	'Z-80$'
msg33:	db	'There is Banked switched memory$'
msg35:	db	'Bdos resident page is active$'
msg36:	db	'CP/Net is $'
msg37:	db	'Inactive$'
msg38:	db	'Active$'
msg39:	db	'Xdos starts at $'
msg40:	db	'RSP base page is at $'
msg41:	db	'The banked Xios base page is at $'
msg42:	db	'The banked Bdos base page is at $'
msg43:	db	'The RESident BDOS base page is at $'
msg44:	db	'Console number $'
msg45:	db	' has $'
msg46:	db	' nulls$'
msg47:	db	'Number of records in MP/M.SYS file: $'
msg48:	db	'System number of ticks/second: $'
msg49:	db	'System drive is $'
msg50:	db	'Common memory base page is at $'
msg51:	db	'Number of RSPs is $'
msg52:	db	'Listcp array address $'
msg53:	db	'Maximun number of locked records per process $'
msg54:	db	'Maximun number of opened files per process $'
msg55:	db	'Number of list items $'
msg56:	db	'Total of system locked records $'
msg57:	db	'Total of system opened files $'
msg58:	db	'Day file logging is $'
msg59:	db	'Inactive$'
msg60:	db	'Active$'
msg61:	db	'Temporary file drive is $'
msg62:	db	'The number of list devices supported in this system is $'
msg63:	db	'Banked XDOS base page starts at $'
msg64:	db	'TMP.spr process discriptor base $'
msg65:	db	'Console.dat base $'
msg66:	db	'BDOS / XDOS entry address is at $'
msg67:	db	'TMP.spr base is $'
msg68:	db	'Number of banked RSPs $'
msg69:	db	'XDOS internal data segment address $'

msg99:	db	'BSR controller is $'

	DS	80h		; Set up a stack area
STACK	EQU	$

BEDOS	DS	2
TPA	DS	2
CCP	DS	2
CONTLR	DS	1
OLDSP	DS	2
BYTE	DB	0
IOBYT	DS	1
VECTOR	DS	2
CDRV	DS	1
ALLOCAD	DS	2
mpmbyte	ds	1
cpmbyte	ds	1
time	ds	2
time1	ds	3
timeend	db	'$'
segcnt	db	0
csole	db	0
maxcon	db	0
exiospt	db	0

last:	db	0	; for MP/M prl file.

	END
  