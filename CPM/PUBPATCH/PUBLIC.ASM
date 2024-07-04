	title 'PUBLIC.ASM v 1.1 11-14-84 (c) 1984 Plu*Perfect Systems'
	PAGE 55
;
vers	equ	1$1
;
;Utility to set/clear attribute bit 2  of filename.
;For use with Plu*Perfect Systems' PUBlic-file BDOS patch.
;
;usage: PUBLIC [d:]			-- lists PUBlic files (on d:)
;	PUBLIC [d:]filename.typ 	-- makes filename.typ PUBlic
;	PUBLIC [d:]filename.typ [X] 	-- makes filename.typ private
;	filename,type must be unambiguous - no wildcards
;
;prints drive/user number of all files of specified name,
;  with attribute bits displayed as lower-case characters
;
;if just one such file found:
;	if X, clears attribute bit - making file private in orig user #
;	else,   sets attribute bit - making file PUBlic
;
;
; v 1.1	Fixed extent match on overflow to S2 byte (11-14-84)
;
	maclib z80

FALSE	EQU	0    
TRUE	EQU	NOT FALSE
;
LISTPUBBIT	equ	0
MAKPUBBIT	equ	1
fence		equ	'|'
;
NULL	equ	0
BELL	equ	'G'-'@'
CR	equ	0dh
LF	equ	0ah
ESC	equ	1bh
SPACE	EQU	' '
DEL	EQU	7FH

drivefn	equ	14
openfn	equ	15
closefn	equ	16
srchfstfn equ	17
srchnxtfn equ	18
deletefn equ	19
readfn	equ	20
writefn	equ	21
makefn	equ	22
renamefn equ	23
logvecfn equ	24
curdskfn equ	25
dmafn	equ	26
setattrfn equ	30
getaddrfn equ	31
userfn	equ	32
readrfn	equ	33
writerfn equ	34
sizefn	equ	35
;
reccnt	equ	15
currec	equ	32
r0	equ	33
tbuff	equ	80h
fcb	equ	5ch
fcb2	equ	fcb+16
;
BOOT equ	0000h
BDOS equ	0005h
ADDRESS equ	0FFFFh	;filled in by loader
bdoslen		equ	0e00h

dobdos	macro	num,arg
	if not nul arg
	lxi	de,arg
	endif
	mvi	c,num
	call	5
	endm
;
print	macro	msg
	if not nul msg
	lxi	d,msg
	endif
	call	printde
	endm
;
$-MACRO
	PAGE
	aseg
	org 100h
;
top:	jmp	start
;
banner:	db	CR,LF,'PUBLIC v '
	db	vers/10+'0','.',(vers mod 10)+'0'
	db	' (c) 1984 Plu*Perfect Systems$'
;
usage:	db	CR,LF,LF,'Usage:  '
	db	'PUBLIC [d:]           -- list PUBlic files (on d:)'
	db	CR,LF,'        '
	db	'PUBLIC [d:]file.ext   -- make file PUBlic'
	db	CR,LF,'        '
	db	'PUBLIC [d:]file.ext X -- make file private'
	db	CR,LF,LF,'$'
;
header:	db	CR,LF,LF,'The currently PUBlic files are:',CR,LF,'$'
;	
tomsg:	db	' set to ==> $'
pubnam:	db	'PUBLIC   $'
privnam:db	'PRIVATE  $'
ismsg:	db	'  ==> is already $'
;
multimsg:db	CR,LF,BELL,'*** Multiple copies, can''t change!$'
nonemsg:db	CR,LF,BELL,'*** No file!$'
cantmsg:db	CR,LF,BELL,'*** Can''t make file $'
nopubs:	db	CR,LF,'(None.)$'
;
;
start:	sspd	ustack
	lxi	sp,stack
	print	banner
	lxi	h,fcb+1
	mov	a,m
	cpi	SPACE
	lxi	h,flags
	res	LISTPUBBIT,m
	jrnz	setup
	setb	LISTPUBBIT,m
	print	header
;
setup:	dobdos	dmafn,buf	;set directory buffer
	dobdos	curdskfn	;save user's drive
	sta	drive
	sta	udrive
	lda	fcb		;check for specified drive
	ora	a
	jrz	savusr
	dcr	a
	sta	drive		;login specified drive
	mov	e,a
	dobdos	drivefn,
;
savusr:	dobdos	userfn,0ffh	;save user #
	sta	uuser
	dobdos	getaddrfn	;get extent mask for this drive
	inx h ! inx h ! inx h ! inx h
	mov	a,m
	sta	EXTMASK
	xra	a
	sta	count
	lda	fcb2+1
	cpi	'X'
	lxi	h,flags
	res	MAKPUBBIT,m
	jrz	find
	setb	MAKPUBBIT,m
;
	PAGE
;	find all filename entries in all user numbers
;
find:	lxi	h,fcb
	mvi	m,'?'		;match ALL dir entries
	xchg
	dobdos	srchfstfn,
	sta	indx		;save position in buffer
	inr	a
	jrz	done		;no entries at all
;
findall:call	chknxt		;is entry PUBlic or specified filename?
	jrnz	findnxt
	call	savefcb		;yes - save it
	call	setcol
	call	printentry	; list it
	lxi	h,count		; and count it
	inr	m
findnxt:dobdos	srchnxtfn,fcb
	sta	indx
	inr	a
	jrnz	findall	
;
nomore:	lxi	h,flags
	bit	LISTPUBBIT,m	
	lda	count
	jrz	nom0
	ora	a
	jrnz	done
	print	nopubs
	jr	done
;
nom0:	sui	1
	jrc	none
	jrnz	nochanges
	lxi	h,flags		;exactly 1 file found
	bit	MAKPUBBIT,m
	jrz	nom1
	call	setpub
	jr	done
nom1:	call	setpriv
	jr	done
;
	PAGE
nochanges:	;can't be PUBlic if > 1 match on drive
	print	multimsg
	jr	done
;
none:	print	nonemsg
	jr	done
;
nopub:	lxi	d,pubnam
	call	cant
;fall thru
;
;	all done, restore drive/user and return
;
done:	lxi	h,flags
	bit	LISTPUBBIT,m
	jrz	done0
	print	usage
done0:	lda	udrive	;relogin user's drive
	mov	e,a
	dobdos	drivefn,
done1:	lda	uuser
	mov	e,a
	dobdos	userfn,
	call	crlf
xit:	lspd	ustack
	ret
;
;	set the PUBlic attribute bit
;
setpub:	lxi	h,pubfcb+2	;test attr bit 2 
	bit	7,m
	jrnz	ispub		;quit if already PUBlic
	setb	7,m		;set attr bit 2
	lda	pubfcb		;save user # for output
	mov	e,a		;set user # of this file
	dobdos	userfn,
	lxi	h,pubfcb
	mvi	m,0		;put default drive into fcb
	xchg
	dobdos	setattrfn,
	inr	a
	jrz	nopub
	print	tomsg
	print	pubnam
setpend:
	lxi	h,pubfcb
	jmp	printent1
;
ispub:	lxi	d,pubnam
	jmp	istype
;
;
;	reset the PUBlic attribute bit
;
setpriv:
	lda	pubfcb		;save file user #
	mov	e,a		;set user # of fcb
	dobdos	userfn,
	lxi	h,pubfcb+2	;reset PUBlic attr bit
	bit	7,m
	jrz	ispriv		;quit if it's already private
	res	7,m	
	lxi	h,pubfcb
	mvi	m,0		;default drive
	xchg
	dobdos	setattrfn
	inr	a
	jrz	nopriv
	print	tomsg
	print	privnam
	jr	setpend
;
	PAGE
nopriv:	lxi	d,privnam
	jmp	cant
;
ispriv:	lxi	d,privnam
;	fall thru
istype:	push	d
	print	ismsg
	pop	d
;	fall thru
;
printde:		;bdos string print function
	mvi	c,9
	jmp	5
;	
cant:	push	d
	print	cantmsg
	pop	d		;print 2nd msg
	jr	printde
;
;	check next directory entry
;	if listing PUBlic files, ret Z if PUBlic and 0th extent
;	if matching a filename,	ret Z if same name,type and extent
;	else ret NZ
chknxt:	call	findentry
	mov	a,m
	cpi	0E5h		;don't match erased entries
	jrnz	chkn0
	ora	a		;set nz
	ret		
chkn0:	inx	h
	lda	flags
	bit	LISTPUBBIT,a
	jrz	chkn1
;
;	list all PUBlic files
	inx	h		;point at 2nd char of filename
	mov	a,m
	cma
	ani	80h		;check compl of attr bit
	rnz			;not PUBlic - ret NZ
	lxi	d,12-2		;have a PUBlic file,
	dad	d		;point at its extent byte
	xra	a		;and check for extent 0
	jr	chkn3
;
;	check for match with specified filename/extent 0
;note* doesn't  allow wild cards
chkn1:	lxi	d,fcb+1
	mvi	b,11		;name & type
chkn2:	ldax	d
	sub	m
	ani	7fh		;don't test attr bits
	inx	h
	inx	d
	rnz			;nz if no match
	djnz	chkn2
	xra	a		;check for extent # 0
chkn3:	mov	c,m
;
;	check for same extent in A, C
;
SAMEXT:			;z set if same extent
	push	psw
EXTMASK equ $+1
	mvi	a,00h
	cma
	mov	b,a	;save mask
	mov	a,c	;mask C
	ana	b
	mov	c,a	;save in C
	pop	psw	;now do A
	ana	b
	sub	c
	ani	1Fh	;check only legal bits 0-4
	rnz		; v 1.1 11-14-84
	inx	h	;extent is 0, check overflow (s2) ext.
	inx	h
	mov	a,m
	ani	7fh
	ret
;
;
savefcb:
	call	findentry
	mov	a,m	;save the user #
	sta	fileuserno
	lxi	d,pubfcb
	lxi	b,32
	ldir
	ret
;		
findentry:			;find entry in buf
	lda	indx		;point to fcb found
	add	a		;*32
	add	a
	add	a
	add	a
	add	a
	lxi	h,buf
	add	l
	mov	l,a
	rnc
	inr	h
	ret
;
setcol:	lda	count
	ani	03h
	jz	crlf
	call	twosp
	mvi	c,fence
	call	charout
twosp:	mvi	c,space
	call	charout
	mvi	c,space
	jmp	charout	

printentry:		;print drive/user/filename
	call	findentry
printent1:			;print at (hl)
	push	h
	call	printdrv
fileuserno equ $+1
	mvi	a,00h
	call	printuser
	pop	h
;fall thru
print$fn:		;print filename.ext
	inx	h
	mvi	b,8
	call	prfn
	mvi	c,'.'
	call	charout
	mvi	b,3
;fall thru
prfn:			;print filename char, lowercase if attr bit set
	mov	a,m
	ani	7fh	;kill attr bit when printing
	cmp	m
	jrz	prfn1
	ori	20h	;set lower case
prfn1:	mov	c,a
	call	charout
	inx	h
	djnz	prfn
	ret
;	
printdrv:		;print drive
	lda	drive
	adi	'A'
	mov	c,a
	jr	charout
;
crlf:	mvi	c,CR
	call	charout
	mvi	c,LF
;fall thru
;
charout:		;preserve registers
	push	h
	push	b
	push	d
	mov	e,c
	mvi	c,2
	call	5
	pop	d
	pop	b
	pop	h
	ret
;
printuser:		;print A as user # 
	cpi	10
	jrnc	printu1
	push	psw		;1 space if sgl digit
	mvi	c,' '
	call	charout
	pop	psw
printu1:mov	l,a
	mvi	h,0
	call	printdec
	mvi	c,':'
	jr	charout
;
printdec:
DECOUT:	PUSH	PSW		;prints hl in decimal
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	B,-10
	LXI	D,-1
DECOU2:	DAD	B
	INX	D
	JC	DECOU2
	LXI	B,10
	DAD	B
	XCHG
	MOV	A,H
	ORA	L	
	CNZ	DECOUT	;recursive
	MOV	A,E
	ADI	'0'
	mov	c,a
	call	charout
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET
;
flags:	db	0
indx:	db	0
drive:	db	0
count:	db	0
udrive:	db	0		;user's drive
uuser:	db	0
ustack:	dw	0
pubfcb equ $
stack equ pubfcb +32 + 48
;
buf	equ	stack
	END
