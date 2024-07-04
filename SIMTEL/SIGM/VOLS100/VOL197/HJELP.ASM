
;	--------------------------------------------------------------
;	HJELP.ASM is a derivative of HELP8080.ASM (SIG/M 122.03),
;	which was gotten by disassembling HELP8080.COM (SIG/M 122.04),
;	inserting UNSQ.LIB (this disk), and making all the adjustments
;	required to ensure the compatibility of the two. The objective
;	of this procedure was to obtain a version of HELP which would
;	work with squeezed HELP files, and to correct minor errors in
;	the original program.
;
;	HELP8080.ASM in turn has a history, of having been derived from
;	a Z80 version which forms part of Richard Conn's ZCPR2 package
;	(SIG/M 98-107 and others). In the documentation for these
;	programs he makes the requirement that their contents not be
;	propagated for commercial purposes without his express written
;	consent, but permitting their non-commercial usage or their
;	incorporation as a necessary part of a new program. HJELP.ASM
;	contains about 50% new or revised code, and in time may evolve
;	into still less dependence. In the meantime we feel that it
;	should continue to carry the requirements of the original author.
;
;	Besides incorporating a pipeline through which the Huffman code
;	of a squeezed file can be decoded, the principal changes made
;	to HELP8080 consist in establishing a directory and pushdown
;	list to locate the beginnings of information sections and of
;	individual panels. Besides speeding up the program, they are
;	required by the Huffman code because the sign bit can no longer
;	be used to flag these locations.
;
;	Minor errors in HELP8080 which were corrected include: 1) The
;	option "L" did not always back up to panel 1 properly. 2) The
;	option to list a single panel on the printer did not always
;	work if the panels were not separated by form feeds.
;
;	For consistency with its acceptance of squeezed HELP files,
;	HJELP will search for HQP as well as HLP files when summoned
;	with a null command line.
;
;	[Harold V. McIntosh, July 20, 1984]
;	--------------------------------------------------------------

CR	equ	0DH
VT	equ	0CH
LF	equ	0AH
HT	equ	09H

X0004	equ	0004H		;CP/M Disk Byte
X0005	equ	0005H		;call point to BDOS

NH	equ	6	;number of HELP file names to print per line
ND	equ	10	;maximum node depth
NS	equ	9	;bytes to save for panel markers

csiz	equ	256
psiz	equ	50*NS	;textpointer pushdown size

;	-------------
	org	0100H
;	-------------

X0100:	jmp	X017B

;	A data area which is specific to ZCPR2 and which
;	defines the parameters needed for HELP.COM to
;	interact with ZCPR2.

X0103:	db	000H		;00/FF = no/external path available
X0104:	dw	0040H		;address of external path if used
X0106:	db	00,00		;disk, user for first path
	db	00,00		;second path
	db	00,00
	db	00,00
	db	00,00
	db	00,00
	db	00,00
	db	00,00		;eighth path
	db	00		;end of path
	db	0FFH		;00/FF = multiple command line buffer
	dw	0FF00H		;its address if present
	db	04		;max number of disks
	db	31		;max user number
	db	0FFH		;00/FF = can/'t change disk
	db	0FFH		;00/FF = can/'t change user
	db	10		;begnning of privleged user area
	db	'chdir'		;password for privleged area
	ds	36		;remainder of 41 char buffer
X0148:	db	'$'		;usual value for path expressions
	dw	0080H		;DMA for disk = tbuf
	dw	0000		;address of named directory
	db	64		;maximum number of directory names
	db	'NAMES   DIR'	;name.ext of disk name file
	db	0FFH		;00/FF = y/n external path
	db	00		;multiple command line
	db	00		;max user/disk
	db	00		;user/disk change
	db	00		;privileged user
	db	00		;current indic and dma
	db	00		;named directories
	db	05		;class 5
	db	'ZCPR2'
	ds	10		;reserved spaces

;	Default file name.

X0170:	db	'HELP    '
X0178:	db	'HLP'		;default ext
X0179:	db	'HQP'	;default squeezed file

;	Program begins here.

X017B:	lxi	h,0000
	dad	sp
	shld	X0D31		;save stack
	lxi	sp,X0D31	;stack
	mvi	e,0FFH
	mvi	c,32		;(20) Set/Get User Code
	call	X0005		; B D O S
	sta	X0C62		;user code
	lda	X0005+2
	sui	0AH
	sta	X0C63		;memory pages
	xra	a
	sta	X0C6D		;nz/z = y/n default file
	sta	X0C71		;level #
	lxi	d,X08BE		;'signon'
	call	mssg		;message to console
	lxi	h,005CH+1	;TFCB+1
	mov	a,m
	cpi	' '
	jnz	X01BB		;loop
	lxi	d,X0170		;'HELP    HLP'
	mvi	b,11		;bytes in disk name
	call	miuc
	mvi	a,001H
	sta	X0C6D		;nz/z = y/n default file

;	Loop.

X01BB:	lxi	sp,X0D31	;stack
	lxi	h,005CH		;TFCB
	mvi	m,000H
	lxi	d,000CH
	dad	d

	mvi	b,018H		;24
X01C9:	mvi	m,000H
	inx	h
	dcr	b
	jnz	X01C9

	lxi	h,005CH+1	;TFCB+1
	mvi	b,11		;bytes in disk name
X01D5:	mov	a,m
	ani	07FH
	cpi	'?'
	jz	X0227
	inx	h
	dcr	b
	jnz	X01D5

	lxi	h,005CH+9
	mov	a,m
	cpi	' '
	jnz	X01EE
	lxi	d,X0178		;default ext
	mvi	b,003H
	call	miuc

X01EE:	lda	X0C6D		;nz/z = y/n default file
	ora	a
	jnz	X0230
	lxi	h,X0106
	lda	X0103
	ora	a
	jz	X0202
	lhld	X0104
X0202:	lxi	d,005CH		;TFCB
	call	X0408		;search through users/disks
	jnz	X0323		;load file
	lda	X0103
	ora	a
	jz	X021E
	lxi	h,X0106
	lxi	d,005CH		;TFCB
	call	X0408		;search through users/disks
	jnz	X0323		;load file
X021E:	lxi	h,005CH+10
	mvi	a,'Q'
	cmp	m
	jz	X021F
	mov	m,a
	jmp	X01EE

X021F:	lxi	d,X0AA1		;'File Not Found'
	call	mssg		;message to console
	jmp	X0362		;return to CP/M

X0227:	lxi	d,X0A6E		;'File Name w/Wildcard'
	call	mssg		;message to console
	jmp	X0362		;return to CP/M

X0230:	lxi	d,X08DC		;'Default HELP'
	call	mssg		;message to console
	call	X02A9		;reset HELP file names/line
	call	X03F3		;restore user/disk
	call	X02AF		;locate available HLP files
	lda	X0103
	lhld	X0104
	ora	a
	cnz	X0275
	call	X03F3		;restore user/disk
	lxi	h,X0106
	call	X0275
	call	X03F3		;restore user/disk
	lxi	d,X091C		;'Type Any Char for Default Info'
	call	mssg		;message to console
	call	X046B		;read char from console
	cpi	003H		;^Z
	jz	X0362		;return to CP/M
	xra	a
	sta	X0C6D		;nz/z = y/n default file
	lxi	d,X0170		;'HELP    HLP'
	lxi	h,005CH+1	;TFCB+1
	mvi	b,11		;bytes in disk name
	call	miuc
	jmp	X01EE

X0275:	lda	X0148
	mov	b,a
	mov	a,m
	ani	07FH
	ora	a
	rz
	cmp	b
	jnz	X0288
	lda	X0004		;Disk Byte
	ani	00FH
	inr	a
X0288:	dcr	a
	mov	e,a
	mvi	c,14		;(0E) select disk
	call	X045D		;generic BDOS call
	inx	h
	mov	a,m
	inx	h
	ani	07FH
	cmp	b
	jnz	X029B
	lda	X0C62		;user code
X029B:	mov	e,a
	mvi	c,32		;(20) Get/Set User Code
	call	X045D		;generic BDOS call
	push	h
	call	X02AF		;locate available HLP files
	pop	h
	jmp	X0275

;	Set number of HELP file names to be typed per line.

X02A9:	mvi	a,NH
	sta	X0C6C		;HELP file names/line
	ret

;	Search out the available HLP files

X02AF:	lxi	h,005CH		;TFCB
	mvi	m,000H
	mvi	b,008H
	inx	h
X02B7:	mvi	m,'?'
	inx	h
	dcr	b
	jnz	X02B7

	push	h
	lxi	d,X0178		;default ext
	mvi	b,003H
	call	miuc

	call	X02C0
	lxi	d,shlp		;'squeezed HELP files'
	call	mssg

	pop	h
	lxi	d,X0179		;default squeezed extension
	mvi	b,003H
	call	miuc

X02C0:	mvi	b,018H
X02CA:	mvi	m,000H
	inx	h
	dcr	b
	jnz	X02CA
	lxi	d,005CH		;TFCB
	mvi	c,17		;(11) search for first
	call	X0005		; B D O S
	cpi	0FFH
	rz
X02DC:	call	X02ED		;pick up file name, type it
	lxi	d,005CH		;TFCB
	mvi	c,18		;(12) search for next
	call	X0005		; B D O S
	cpi	0FFH
	jnz	X02DC
	ret

;	Pick file name out of directory, type it.

X02ED:	rrc
	rrc
	rrc
	ani	060H
	lxi	h,0080H
	add	l
	mov	l,a
	mov	a,h
	aci	000H
	mov	h,a
	inx	h
	mvi	b,008H
X02FE:	mov	a,m
	ani	07FH
	inx	h
	call	cona		;char to console
	dcr	b
	jnz	X02FE
	mvi	a,' '
	call	cona		;char to console
	call	cona		;char to console
	call	cona		;char to console
	lda	X0C6C		;HELP file names/line
	dcr	a
	sta	X0C6C		;HELP file names/line
	rnz
	call	X02A9		;reset HELP file names/line
	call	X04F4		;type options at bottom of panel
	ret

;	Open file, load it, close it.

X0323:	lxi	d,005CH		;TFCB
	mvi	c,15		;(0F) open file
	call	X0005		; B D O S
	lxi	h,X0D33		;free memory
	shld	X0C6E		;ptr end of text
X0331:	call	X04AC		;read record from disk
	jz	X0331
	lxi	d,005CH		;TFCB
X033A:	mvi	c,16		;(10) close file
	call	X0005		; B D O S
	call	X03F3		;restore user/disk

;	Decide whether it is a squeezed file.

	lxi	h,X0D33
	shld	tptr		;text pointer
	shld	xptr		;ptr to bgn of HELP file
	lxi	h,dens		;z/nz = normal/squeezed file
	mvi	m,0
	lxi	h,wflg		;z/nz = no/byte left waiting by abyt
	mvi	m,0
	call	gbyt		;one byte, direct or through onsq
	cpi	076H
	jnz	unjj
	call	gbyt		;one byte, direct or through onsq
	cpi	0FFH
	jz	unii
unjj:	lxi	h,X0D33
	shld	tptr		;text pointer
	jmp	gogo

;	Squeezed, so go through initialization

unii:	lxi	h,rcnt		;repetition count
	mvi	m,0
	lxi	h,roco		;bit rotation counter
	mvi	m,1

;	The "squeezed" marker is followed by a two-byte checksum,
;	which is the simple sum of all the one-byte characters in
;	the source file, carried as a two byte sum modulo 2**16.

rchk:	call	iwor		;fetch two bytes from input stream
	shld	cksm		;checksum

;	Unsqueezed file name. It is an ASCII sequence, may be lower
;	case if SQ.COM received it in response to a prompt, ending
;	with a zero byte.

luup:	call	gbyt		;fetch one byte from input stream
	ora	a
	jnz	luup

;	Load code dictionary. It is preceded by its two-byte length,
;	and consists of a series of pairs of two-byte addresses. For
;	each bit in the code, select the first element (0) or the
;	second (1) element of the pair. If the pair is positive, it
;	is the table entry (code + 4*index) at which to continue with
;	the next bit. If the pair is negative, it is the complement
;	of the coded ASCII character (low order byte except for [end]).

ldic:	call	iwor		;fetch two bytes from input stream
	dad	h
	dad	h
	xchg
	lhld	tptr		;text pointer
	shld	cptr		;Huffman code table
	dad	d
	shld	tptr		;text pointer
	shld	xptr		;ptr to bgn of HELP file
	lxi	h,dens
	mvi	m,0FFH

;	Scan the HELP text to find and record the section headings.

gogo:	lxi	h,pudl
	shld	pptr		;pushdown pointer
	lxi	h,mopt
	mvi	m,'A'		;A, not @, to make <cmp m, jnc> work
	call	abyt		;lookahead one byte
	cpi	':'
	jz	gogu
gugu:	call	rbyt		;fetch one byte
	cpi	LF
	jnz	gigi
	call	rbyt		;fetch one byte
	cpi	':'
	jz	gege
gigi:	cpi	1AH
	jz	gogu
	jmp	gugu

gege:	call	pupu
	lxi	h,mopt		;maximum option
	inr	m
	jmp	gugu

gogu:	lhld	pptr		;pushdown pointer
	shld	zptr		;ptr to bgn of info sect
	lhld	xptr		;ptr to bgn of HELP file
	shld	tptr		;text pointer
	lxi	h,roco		;bit rotation counter
	mvi	m,1
	lxi	h,wflg		;z/nz = no/byte left waiting by abyt
	mvi	m,0

;	Display menu. Here we distinguish between a simple HELP
;	file which begins with a colon and has only one section,
;	and an indexed HELP file, which starts out with a list of
;	section descriptors.

X0342:	lxi	sp,X0D31	;stack
	mvi	a,000H
	sta	X0C72		;panel #
	call	abyt		;lookahead one byte
	cpi	':'
	jnz	X036A		;show menu, request option
	call	rbyt		;fetch one byte
	call	X05E5		;initialize new section
	lda	X0C71		;level #
	ora	a
	jz	X0362		;return to CP/M
	jmp	X07ED		;go up one level

;	Return to CP/M

X0362:	call	X03F3		;restore user/disk
	lhld	X0D31		;save stack
	sphl
	ret

;	Show menu, request option.

X036A:	call	X058D		;run through the menu
	push	b
	call	crlf		;CR,LF
	call	X0859		;type level I.D.
	lxi	d,X0C19		;'Type [^C]'
	call	mssg		;message to console
	lxi	d,X0C27		;'Type [level or root]'
	lda	X0C71		;level #
	ora	a
	jz	X0387
	call	mssg		;message to console
X0387:	lxi	d,X0C37		;'Enter Selection'
	call	mssg		;message to console
	pop	b
	call	X046B		;read char from console
	cpi	003H		;^C
	jz	X0362		;return to CP/M
	cpi	'.'
	jz	X07E1		;back to root
	cpi	'^'
	jz	X07ED		;go up one level
	push	psw
	call	crlf		;CR,LF
	pop	psw
	lxi	h,mopt		;maximum option
	cmp	m
	jnc	X03AE
	sui	'@'
	jc	X03AE
	jz	X03AE
	call	anth		;access nth option
	call	X05E5		;initialize new section
	jmp	X036A		;show menu, request option

X03AE:	lxi	d,X0AC6		;'Invalid Response'
	call	mssg		;message to console
	jmp	X036A		;show menu, request option

;	Restore user/disk.

X03F3:	lda	X0004		;Disk Byte
	ani	00FH
	mov	e,a
	mvi	c,14		;(0E) select disk
	call	X0005		; B D O S
	lda	X0C62		;user code
	mov	e,a
	mvi	c,32		;(20) Get/Set User Code
	call	X0005		; B D O S
	ret

;	Search through users/disks.

X0408:	shld	X0469		;save FCB addr
	mvi	c,17		;(11) search for first
	call	X045D		;generic BDOS call
	inr	a
	jnz	X0459
	xchg
	shld	X0467		;save DE after 'search first'
	lhld	X0469		;save FCB addr
X041B:	lda	X0148
	mov	b,a
	mov	a,m
	ani	07FH
	ora	a
	jnz	X0428
	xra	a
	ret

X0428:	cmp	b
	jnz	X0432
	lda	X0004		;Disk Byte
	ani	00FH
	inr	a
X0432:	dcr	a
	mov	e,a
	mvi	c,14		;(0E) select disk
	call	X045D		;generic BDOS call
	inx	h
	mov	a,m
	ani	07FH
	inx	h
	cmp	b
	jnz	X0445
	lda	X0C62		;user code
X0445:	mov	e,a
	mvi	c,32		;(20) Get/Set User Code
	call	X045D		;generic BDOS call
	xchg
	lhld	X0467		;save DE after 'search first'
	xchg
	mvi	c,17		;(11) search for first
	call	X045D		;generic BDOS call
	inr	a
	jz	X041B
X0459:	mvi	a,0FFH
	ora	a
	ret

;	Generic BDOS call.

X045D:	push	h
	push	d
	push	b
	call	X0005		; B D O S
	pop	b
	pop	d
	pop	h
	ret

X0467:	ds	2		;save DE after 'search first'
X0469:	ds	2		;save FCB addr

;	Read a character from the console.

X046B:	push	b
	push	d
	push	h
	mvi	c,1		;(01) console input
	call	X0005		; B D O S
	pop	h
	pop	d
	pop	b
	push	psw
	call	crlf		;CR,LF
	pop	psw
X047B:	ani	07FH		;upper case fold
	cpi	'a'
	rc
	cpi	'{'
	rnc
	ani	05FH
	ret

;	Character to console.

cona:	push	psw
	push	b
	push	d
	push	h
	mvi	c,2		;(02) console output
	mov	e,a
	call	X0005		; B D O S
	pop	h
	pop	d
	pop	b
	pop	psw
	ret

;	Message to Console.

mssg:	push	b
	push	d
	push	h
	mvi	c,9		;(09) print string to $
	call	X0005		; B D O S
	pop	h
	pop	d
	pop	b
	ret

;	Move B bytes from (DE) to (HL).

miuc:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	b
	jnz	miuc
	ret

;	Move B bytes from (HL) to (DE)

mduc:	dcx	h
	dcx	d
	mov	a,m
	stax	d
	dcr	b
	jnz	mduc
	ret

;	Initialize pudl.

izpu:	mvi	b,NS
	lxi	d,lach
	lhld	zptr		;ptr to bgn of info sect
	call	miuc
	shld	yptr		;zptr+NS
	shld	pptr		;pushdown pointer
	lxi	h,X0C72		;panel #
	mvi	m,1
	ret

;	Restore to the head of pudl.

rspu:	mvi	b,NS
	lhld	yptr		;zptr+NS
	shld	pptr		;pushdown pointer
	lxi	d,lach+NS
	call	mduc
	lxi	h,X0C72		;panel #
	mvi	m,0
	ret

;	Access nth option.

anth:	mov	e,a
	mvi	d,0
	mov	l,e
	mov	h,d
	dad	h
	dad	h
	dad	h
	dad	d
	lxi	d,pudl
	dad	d
	lxi	d,lach+NS
	mvi	b,NS
	call	mduc
	lhld	zptr		;ptr to bgn of info sect
	shld	pptr		;pushdown pointer
	lxi	h,X0C72
	mvi	m,1
	ret

;	Push state onto pudl.

pupu:	lhld	pptr		;pushdown pointer
	lxi	d,pudl+psiz
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	rnc
	mvi	b,NS
	lxi	d,lach
	call	miuc
	shld	pptr		;pushdown pointer
	lxi	h,X0C72		;panel #
	inr	m
	ret

;	Pop state from pudl.

popu:	lhld	zptr
	xchg
	lhld	pptr		;pushdown pointer
	mov	a,e
	sub	l
	mov	a,d
	sbb	h
	rnc
	mvi	b,NS
	lxi	d,lach+NS
	call	mduc
	shld	pptr		;pushdown pointer
	lxi	h,X0C72		;panel #
	mov	a,m
	ora	a
	rz
	dcr	m
	ret

;	Read one record from the disk.

X04AC:	mvi	c,20		;(14) read one record
	lxi	d,005CH		;TFCB
	call	X0005		; B D O S
	push	psw
	lhld	X0C6E		;ptr end of text
	lda	X0C63		;memory pages
	cmp	h
	jz	X04D1
	lxi	d,0080H
	mvi	b,080H
	call	miuc
	mvi	m,01AH		;^Z
	pop	psw
	ora	a
	shld	X0C6E		;ptr end of text
	ret

X04D1:	lxi	d,X0BDC		;'Not Enough Room'
ferm:	call	mssg		;message to console
	jmp	X0362		;return to CP/M

onsq:	lda	rcnt		;repetition count
	ora	a
	jnz	onsr
	call	dnch		;decode next character
	jc	vchk		;verify the checksum
	cpi	090H		;repeat last character
	jnz	onsu		;normal character
	call	dnch		;decode next character
	ora	a
	jz	onss
	dcr	a
onsr:	dcr	a
	sta	rcnt		;repetition count
	lda	lach
	jmp	achk

onss:	mvi	a,090H
	jmp	achk

onsu:	sta	lach		;last character typed
	jmp	achk

;	Decode next character.

dnch:	lhld	cptr		;Huffman code table
dncr:	call	ibit		;read next bit
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

dncu:	lhld	cptr		;Huffman code table
	dad	d
	dad	d
	dad	d
	dad	d
	jmp	dncr

;	Read one bit at a time.

ibit:	push	h
	lxi	h,roco		;bit rotation counter
	dcr	m
	jnz	ibiu
	mvi	m,8
	call	ibyt		;fetch one byte from input stream
	sta	roby		;rotating byte
ibiu:	lda	roby		;rotating byte
	rar
	sta	roby		;rotating byte
	pop	h
	ret

;	Read one word.

iwor:	call	ibyt		;fetch one byte from input stream
	mov	l,a
	push	h
	call	ibyt		;fetch one byte from input stream
	pop	h
	mov	h,a
	ret

;	Accumulate checksum.

achk:	stc
	cmc
	ret

;	Verify the checksum.

vchk:	lhld	cksm		;checksum
	mov	a,l
	ora	h
	stc
	rz			;return to CP/M
	lxi	d,chno		;'Checksum failure.'
	jmp	ferm		;fatal error message

abyt:	push	h
	lxi	h,wflg		;z/nz = no/byte left waiting by abyt
	mov	a,m
	ora	a
	jz	abyy
	lda	wbyt		;byte left waiting by abyt
	jmp	abyr
abyy:	dcr	m
	call	gbyt		;one byte, direct or through onsq
	sta	wbyt		;byte left waiting by abyt
abyr:	pop	h
	ret

rbyt:	lda	wflg		;z/nz = no/byte left waiting by abyt
	ora	a
	jz	gbyt		;one byte, direct or through onsq
	mvi	a,0
	sta	wflg		;z/nz = no/byte left waiting by abyt
	lda	wbyt		;byte left waiting by abyt
	ret

gbyt:	lda	dens		;one byte, direct or through onsq
	ora	a
	jnz	onsq		;one byte from squeezed file
ibyt:	push	h		;fetch byte from the input stream
	lhld	tptr		;text pointer
	mov	a,m
	inx	h
	shld	tptr		;text pointer
	pop	h
	ret

;	Type line, solicit option.

X04DA:	call	rbyt		;fetch one byte
	cpi	CR
	jz	X04F4		;type options at bottom of panel
	cpi	LF
	jz	X04F5		;type options at bottom of panel
	cpi	01AH		;^Z
	jz	X04F5		;type options at bottom of panel
	call	cona		;char to console
	jmp	X04DA		;type line, solicit option

;	Type the options at bottom of panel.
;	Entry point according to how line ended.

X04F4:	call	rbyt		;decomission following LF
X04F5:	call	crlf		;CR,LF
	lxi	h,X0C6B		;console remaining lines
	dcr	m
	rnz

;	Solicit options (without marking or incrementing line).

X0504:	call	X0859		;type level I.D.
	lxi	d,X097A		;'^C = Exit'
	call	mssg		;message to console
X050D:	lxi	d,X0983		;'[level, root]'
	lda	X0C71		;level #
	ora	a
	jz	X0521
	call	mssg		;message to console
X0521:	lxi	d,X0993		;'[option list]'
	call	mssg		;message to console
	call	X046B		;read char from console
	sta	char		;char read from console
	cpi	'M'
	jnz	pnla
	jmp	X0342		;display menu

pnla:	cpi	003H		;^C
	jnz	pnlb
	jmp	X0362		;return to CP/M

pnlb:	cpi	'P'
	jnz	pnlc
	jmp	X06FE		;fulfil PRINT request

pnlc:	cpi	'.'
	jnz	pnld
	jmp	X07E1		;back to root

pnld:	cpi	'^'
	jnz	pnle
	jmp	X07ED		;go up one level

pnle:	cpi	'L'
	jnz	pnlf
	call	popu
	call	popu
	jmp	pnlg

pnlf:	cpi	'S'
	jnz	pnlg
	call	rspu		;restore start of info section
pnlg:	call	pupu		;save reference to section head
	call	X0587		;reset line count
	jmp	crlf		;CR,LF

;	CR, LF.

crlf:	mvi	a,CR
	call	cona		;char to console
	mvi	a,LF
	jmp	cona		;char to console

;	Reset line count.

X0587:	mvi	a,23		;lines per screen panel
	sta	X0C6B		;console remaining lines
	ret

;	Run through the menu.

X058D:	mvi	a,000H
	sta	X0C72		;panel #
	lhld	xptr		;ptr to bgn of HELP file
	shld	tptr		;text pointer
	lxi	h,roco		;bit rotation counter
	mvi	m,1
	lxi	h,wflg		;z/nz = no/byte left waiting by abyt
	mvi	m,0
	call	X0587		;reset line count
	lxi	h,X0C6B		;console remaining lines
	dcr	m
	mvi	a,'A'
	sta	X0C68		;option letter
	lxi	d,X0954		;'Selections are ...'
	call	mssg		;message to console
	mvi	c,000H
X05AC:	call	abyt		;lookahead one byte
	cpi	':'
	jz	X05D4		;finish panel w/CR,LF's
	cpi	01AH		;^Z
	jz	X0362		;return to CP/M
	inr	c
	lda	X0C68		;option letter
	call	cona		;char to console
	inr	a
	sta	X0C68		;option letter
	mvi	a,'.'
	call	cona		;char to console
	mvi	a,' '
	call	cona		;char to console
	call	X04DA		;type line, solicit option
	jmp	X05AC

;	Finish out panel with CR, LF's.

X05D4:	lda	X0C6B		;console remaining lines
	mov	b,a
	ora	a
	rz
X05DD:	call	crlf		;CR,LF
	dcr	b
	jnz	X05DD
	ret

;	A loop which will print out an information section. It calls
;	X04DA, which will count out lines as it types them. If the
;	line it has just typed is the last one of the panel, it
;	will pause for the panel to be read, having solicited some
;	indication of whether it should procede, repeat the last panel,
;	go back to the beginning, or go back to the menu.


X05E5:	call	X075D		;is section disk file?
	call	izpu
	call	X0587		;reset line count
X05FA:	call	abyt		;lookahead one byte
	cpi	01AH		;^Z
	jz	X0624		;mark panel, type legend, read option
	cpi	':'
	jz	X0624		;mark panel, type legend, read option
	cpi	VT		;form feed
	jz	X05FB
	call	X04DA
	jmp	X05FA

X05FB:	call	rbyt		;fetch one byte
	lda	X0C6B		;console remaining lines
X061A:	push	psw
	call	X04F5		;type options at bottom of panel
	pop	psw
	dcr	a
	jnz	X061A
	jmp	X05FA

;	Mark panel, type legend, select option.

X0624:	call	rbyt		;fetch one byte
X0628:	call	crlf		;CR,LF
	lxi	h,X0C6B		;console remaining lines
	dcr	m
	jnz	X0628
X0635:	call	X0859		;type level I.D.
	lxi	d,X0976		;'EOI & ^C'
	call	mssg		;message to console
	call	X050D
	lda	char		;char read from console
	cpi	'L'
	jz	X05FA
	cpi	'S'
	jz	X05FA
	cpi	'P'
	jz	X05FA
	ret

;	Send line to LST:, check for interrupt request.

X06B3:	call	rbyt		;fetch one byte
	cpi	CR
	jz	X06CE		;list CR, LF's at end of line
	cpi	LF
	jz	X06CF		;list CR, LF's at end of line
	cpi	01AH		;^Z
	jz	X06CF		;list CR, LF's at end of line
	call	X06E4		;list output, read status
	jnz	X06B3		;line to LST:
	ret

;	Type CR, LF at end of line. Entry point according
;	to whether CR, LF, or ^Z was encountered.

X06CE:	call	rbyt		;decomission following LF
X06CF:	mvi	a,CR
	call	X06E4		;list output, read status
	rz			;to catch a ^C between CR, LF
	mvi	a,LF
X06E4:	push	h
	push	d
	push	b
	mov	e,a
	mvi	c,5		;(05) list output
	call	X0005		; B D O S
	mvi	e,0FFH
	mvi	c,6		;(06) direct console I/O
	call	X0005		; B D O S
	pop	b
	pop	d
	pop	h
	cpi	003H
	ret

;	Respond to PRINT request.

X06FE:	lxi	d,X09DE		;'Set Top-of-Form'
	call	mssg		;message to console
	xra	a
	sta	X0C61		;z/nz = panel/section (P)
	call	popu
	call	pupu
	call	X046B		;read char from console
	cpi	003H		;^Z
	jz	X071B
	cpi	'S'
	jz	X0718
	call	rspu
	call	pupu
	mvi	a,0FFH
	sta	X0C61		;z/nz = panel/section (P)
X0718:	call	X0730
X071B:	call	popu
	jmp	pnlg

X0730:	lxi	d,X09B2		;'Printing in Progress ...'
	call	mssg		;message to console
	call	X0587		;reset line count
X0739:	call	X06B3		;line to LST:
	cpi	003H		;^C
	rz
	call	abyt		;lookahead one byte
	cpi	01AH		;^Z
	rz
	cpi	':'
	rz
	cpi	VT		;Form Feed
	cz	X06CF		;list CR, LF's at end of line
	lda	X0C61		;z/nz = panel/section (P)
	ora	a
	jnz	X0739
	lxi	h,X0C6B		;console remaining lines
	dcr	m
	jnz	X0739
	ret

;	Check whether section is a disk file.

X075D:	call	abyt		;lookahead one byte
	cpi	':'
	rnz
	lda	X0C71		;level #
	cpi	ND		;maximum node depth
	jnz	X0776		;read file, type name
	lxi	d,X0B4A		;'Node Limit'
	call	mssg		;message to console
	jmp	X0362		;return to CP/M

;	Read file, type name.

X0776:	call	X0845		;locate file name on stack
	lxi	d,005CH+1	;TFCB+1
	mvi	b,11		;bytes in file name
	call	miuc
	lxi	h,X0C71		;level #
	inr	m
	lxi	d,X0C4C		;'Loading HELP File'
	call	mssg		;message to console
	call	rbyt		;fetch one byte
	lxi	h,005CH+1	;TFCB+1
	mvi	b,008H
	call	X07AB		;parse field
	mvi	a,'.'
	call	cona		;char to console
	mvi	b,003H
	call	X07AB		;parse field
	call	crlf		;CR,LF
	jmp	X01BB		;loop

;	Read and parse field in file name.
;	B is field length, HL beginning of field.

X07AB:	push	h
	push	b
	call	rbyt		;fetch one byte
	pop	b
	pop	h
	cpi	'.'
	jz	X07D6		;end field w/blanks
	cpi	'!'
	jc	X07D6		;end field w/blanks
	call	X047B		;upper case fold
	call	cona		;char to console
	mov	m,a
	inx	h
	dcr	b
	jnz	X07AB		;parse field
	call	rbyt		;fetch one byte
	cpi	'.'
	rz
	cpi	'!'
	rc
	lxi	d,X0B81		;'Invalid File Name'
	call	mssg		;message to console
	jmp	X0362		;return to CP/M

;	Fill out field with blanks

X07D6:	mov	c,a
X07D7:	mvi	m,' '
	inx	h
	dcr	b
	jnz	X07D7		;loop
	mov	a,c
	ret

;	Go back to root.

X07E1:	lda	X0C71		;level #
	ora	a
	jz	X0342		;display menu
	mvi	a,000H
	jmp	X07FE

;	Go up one level.

X07ED:	lda	X0C71		;level #
	ora	a
	jnz	X07FD		;revert to last level
	lxi	d,X0BAD		;'No Higher Level'
	call	mssg		;message to console
	jmp	X0342		;display menu

;	Revert to upper level, type name.

X07FD:	dcr	a
X07FE:	sta	X0C71		;level #
	call	X0845		;locate file name on stack
	push	h
	lxi	d,X0C4C		;'Loading HELP File'
	call	mssg		;message to console
	mvi	b,008H
X080D:	mov	a,m
	cpi	' '
	inx	h
	jz	X081E
	call	cona		;char to console
	dcr	b
	jnz	X080D
	jmp	X0826		;type extension

X081E:	dcr	b
	jz	X0826		;type extension
	inx	h
	jmp	X081E

;	Type extension.

X0826:	mvi	a,'.'
	call	cona		;char to console
	mvi	b,003H
X082D:	mov	a,m
	inx	h
	call	cona		;char to console
	dcr	b
	jnz	X082D
	call	crlf		;CR,LF
	pop	d
	lxi	h,005CH+1	;TFCB+1
	mvi	b,11		;bytes in file name
	call	miuc
	jmp	X01BB		;loop

;	Locate file name on stack.

X0845:	call	X084D		;HL=A*11
	lxi	d,X0C73		;PDL for HELP file names
	dad	d
	ret

;	HL = A*11

X084D:	mov	l,a
	mvi	h,000H
	mov	e,l
	mov	d,h
	dad	h
	dad	h
	dad	h
	dad	d
	dad	d
	dad	d
	ret

;	Type level identification.

X0859:	lda	X0C71		;level #
	ora	a
	jz	X0872
	lxi	d,X0C0C		;'Level 1'
	call	mssg		;message to console
	lda	X0C71		;level #
	call	X0881		;translate level # to ASCII
	lxi	d,X0C13		;'/ '
	call	mssg		;message to console
X0872:	lda	X0C72		;panel #
	ora	a
	rz
	call	X0881		;translate level # to ASCII
	lxi	d,X0C16		;': '
	call	mssg		;message to console
	ret

;	Translate level number to ASCII string.

X0881:	push	psw
	xra	a
	sta	X0C70		;z/nz = 1/2 digit number
	pop	psw
	mvi	b,100		;one hundred
	call	X0896		;type A as decimal number
	mvi	b,10		;ten
	call	X0896		;type A as decimal number
	adi	'0'
	jmp	cona		;char to console

;	Type A as decimal number.

X0896:	mvi	c,000H
X0898:	sub	b
	jc	X08A0
	inr	c
	jmp	X0898

X08A0:	add	b
	mov	b,a
	lda	X0C70		;z/nz = 1/2 digit number
	ora	a
	jnz	X08B6
	mov	a,c
	sta	X0C70		;z/nz = 1/2 digit number
	ora	a
	jnz	X08B6
	mvi	a,' '
	jmp	X08B9

X08B6:	mov	a,c
	adi	'0'
X08B9:	call	cona		;char to console
	mov	a,b
	ret

X08BE:	db	'HELP (from ZCPR) Modified for squeezed HELP files.',CR,LF,'$'
X08DC:	db	CR,LF,'Default HELP Facility Invoked',CR,LF
	db	' - Available HELP Files are -',CR,LF,CR,LF,'$'
shlp:	db	CR,LF,CR,LF,' - Squeezed HELP Files -',CR,LF,CR,LF,'$'
X091C:	db	CR,LF,CR,LF,'  Type Any Character for Default Info'
	db	' (^C to Quit) - $'
X0954:	db	CR,LF,'  HELP File Selections are --',CR,LF,'$'
X0976:	db	'EOI '
X097A:	db	'^C=Exit $'
X0983:	db	'^=Level .=Root $'
X0993:	db	'M=Menu S=Start L=Last P=Print $'
X09B2:	db	'Printing in Progress -- Strike ^C to Quit $'
X09DE:	db	'Please Set Top-of-Form on Printer',CR,LF
	db	'  Strike S to Print this Screen Only,'
	db	' ^C to Quit, or',CR,LF
	db	'  Any Other Char to Print Entire Information Section - $'
X0A6E:	db	CR,LF,'HELP FATAL ERROR -- File Name Contains Wild Card$'
X0AA1:	db	CR,LF,'HELP FATAL ERROR -- File not Found$'
X0AC6:	db	CR,LF,'HELP ERROR -- Invalid Response',CR,LF,'$'
X0AE9:	db	CR,LF,'HELP ERROR -- EOF on HELP File',CR,LF,'$'
X0B4A:	db	CR,LF,'HELP ERROR -- Node Level Limit Reached'
	db	' -- Returning to CP/M',CR,LF,'$'
X0B81:	db	CR,LF,'HELP ERROR -- Invalid File Name in Load',CR,LF,'$'
X0BAD:	db	CR,LF,'HELP ERROR -- No Higher Level to Return to',CR,LF,'$'
X0BDC:	db	CR,LF,'HELP ERROR -- Not Enough Room for HELP File',CR,LF,'$'
X0C0C:	db	'Level $'
X0C13:	db	'/ $'
X0C16:	db	': $'
X0C19:	db	'Type  ^C=Exit$'
X0C27:	db	' ^=Level .=Root$'
X0C37:	db	' or Enter Selection $'
X0C4C:	db	CR,LF,'Loading HELP File $'
chno:	db	CR,LF,'Checksum failure.$'

X0C61:	ds	1		;z/nz = panel/section (P)
X0C62:	ds	1		;user code
X0C63:	ds	1		;memory pages
X0C68:	ds	1		;option letter
X0C6B:	ds	1		;console remaining lines
X0C6C:	ds	1		;HELP file names/line
X0C6D:	ds	1		;nz/z = y/n default file
X0C6E:	ds	2		;ptr end of text
X0C70:	ds	1		;z/nz = 1/2 digit number
X0C71:	ds	1		;level #
X0C72:	ds	1		;panel #
X0C73:	ds	190		;PDL for HELP file names/stack
X0D31:	ds	2		;save stack pointer
cksm:	ds	2		;checksum
lach:	ds	1		;%; last character typed	S
rcnt:	ds	1		;%; repetition count		E
roco:	ds	1		;%; rotating bit counter	Q
roby:	ds	1		;%; rotating byte		U
dens:	ds	1		;%; z/nz=normal/squeezed file	E
wflg:	ds	1		;%; z/nz=no/byte awaiting abyt	N
wbyt:	ds	1		;%; byte left waiting by abyt	C
tptr:	ds	2		;%; text pointer		E
xptr:	ds	2		;ptr to bgn of HELP file
yptr:	ds	2		;zptr+NS
zptr:	ds	2		;ptr to bgn of info sect
cptr:	ds	2		;Huffman code table
pptr:	ds	2		;pushdown pointer
mopt:	ds	1		;maximum option
char:	ds	1		;char read from console
pudl:	ds	NS*50		;pushdown for section heads
X0D33:	ds	0		;free memory

;	Layout of pudl and pointers:
;
;		pudl:	menu
;			...
;			menu
;		zptr->	panel 1
;		yptr->	panel 2
;			...
;		pptr->	panel n
;			x
;			x
;			x
;		X0D33:	x
;			x
;		cptr->	Huffman code
;			x
;			x
;		xptr->	HELPfile text
;			x
;			x
;		tptr->	x
;			x
;			x

	end
