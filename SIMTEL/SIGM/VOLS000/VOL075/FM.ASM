.TITLE	'FM File Directory Map Catalog Utility'

.remark	' ADAPTED FROM FMAP.COM in CP/M Users Group
	Tony Nicholson - initial dissassembly and conversion
	to TDL mnemonics and commenting.
	Modified to look at all user areas on the
	specified drive.
	Last edited 11-Mar-1982
	'
	.XLINK
	.PABS
	.PHEX
	.LOC	0100H

	.INSERT	CPMLIB.ASM
;
CPM	=	00000H
BDOS	=	00005H
FCB1	=	0005CH
PARAM2	=	0006DH
DMAADR	=	00080H
CR	=	0DH
LF	=	0AH
CTRLZ	=	1AH
$getdk	==	25
;
FM:	LXI	H,0	;save stack pointer
	DAD	SP
	SHLD	STACK
	LXI	SP,STACK; and set up program stack
	lxi	d,dmaadr
	mvi	c,$dma
	call	bdos
;	LDA	PARAM2
	mvi	a,'F'	;force write of 'names.sub' file
	STA	SWITCH
	mvi	c,$getdk;get current disk no
	call	bdos
	sta	cdisk
	lda	fcb1	;get specified disk no
	ora	a
	jnz	login
	lda	cdisk
	jmp	logcur
login:	dcr	a
logcur:	mov	e,a	; and login this drive
	mvi	c,$lgin
	call	bdos
	LXI	H,fcb1
	inx	h
	MOV	A,M
	dcx	h
	CPI	' '	;Was a filename specified ?
	JNZ	FNAME	;Yes
	MVI	B,12
FILLQ:	MVI	M,'?'
	INX	H
	DCR	B
	JNZ	FILLQ
FNAME:	MVI	C,$SERCH;Search directory for
	LXI	D,FCB1	; the filename
	CALL	BDOS
	INR	A
	STA	RELPOS
	JNZ	FOUND
NOTFND:	LXI	D,NFMSG
	CALL	PMSG
	JMP	ABORT
;
NFMSG:	.ASCII	'++NOT FOUND$'
;
FOUND:	LDA	RELPOS
	JMP	GETSIZ
;
NEXT:	MVI	C,$NEXT
	LXI	D,FCB1
	CALL	BDOS
	INR	A
	JZ	DONE
GETSIZ:	DCR	A
	ANI	3
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LXI	H,DMAADR
	ADD	L
	MOV	L,A
	mvi	a,0e5h	;check if file has
	cmp	m	; deleted.
	jz	next	;yes, ignore it
	push	h
	lxi	d,12	;check if this is the
	dad	d	; zero extent record
	mov	a,m
	pop	h
	ora	a
	jnz	next	;yes, ignore it
	XCHG
	LHLD	FREEAD
	MVI	B,32	;Copy directory info
COPYD:	LDAX	D	; to memory
	MOV	M,A
	INX	D
	INX	H
	DCR	B
	JNZ	COPYD
	SHLD	FREEAD
	LDA	FREENM
	INR	A
	STA	FREENM
	JMP	NEXT
;
DONE:	lda	cdisk	;reset default disk
	mov	e,a
	mvi	c,$lgin
	call	bdos
	LDA	FREENM
	LXI	H,FREPTR
	LXI	D,FREE
	LXI	B,32
COPYFR:	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	XCHG
	DAD	B
	XCHG
	DCR	A
	JNZ	COPYFR
	LDA	FREENM
	STA	D03F5
	DCR	A
	JZ	OUTPUT
A01DF:	XRA	A
	STA	D03F6
	LDA	D03F5
	DCR	A
	STA	RELPOS
	STA	D03F5
	JZ	OUTPUT
	LXI	H,FREPTR
A01F3:	CALL	COMPARE
	CM	SWAP
	INX	H
	INX	H
	LDA	RELPOS
	DCR	A
	STA	RELPOS
	JNZ	A01F3
	LDA	D03F6
	ORA	A
	JNZ	A01DF
OUTPUT:	LXI	D,HDMSG
	CALL	PMSG
	CALL	CRLF
	LXI	H,FREPTR
	SHLD	FREEAD
	LDA	SWITCH
	CPI	'F'
	JNZ	NOTFSW
	LXI	D,NAMFCB
	MVI	C,$DELET
	CALL	BDOS
	LXI	D,NAMFCB
	MVI	C,$MAKE
	CALL	BDOS
	INR	A
	JNZ	NOTFSW
	CALL	PRINT
;
	.ASCII	'++FILE MAKE ERROR$'
;
NOTFSW:	MVI	C,$CSTS
	CALL	BDOS
	DCR	A
	JZ	CIEXIT
	LHLD	FREEAD
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	SHLD	FREEAD
	XCHG
	inx	h
	MVI	B,8
	CALL	PUTCM		;print filename
	CALL	PUTDOT
	MVI	B,3
	CALL	PUTCM		; type
	CALL	PUTNL
	mov	a,m		; extent
	call	phexbs
	INX	H
	INX	H
	INX	H
	MOV	A,M		;get RC
	DCR	A
	RAR
	RAR
	RAR
	ANI	01FH
	INR	A
	MOV	B,A
	MOV	A,M		;get RC and print it
	CALL	PHEXBS
	INX	H
	MVI	C,0
A027A:	MOV	A,M
	ORA	A
	JZ	pnl
	CALL	PHEXB
	INR	C
A0283:	MOV	A,C
	ANI	3
A0286:	CZ	SPACE
	INX	H
	DCR	B
	JNZ	A027A
pnl:	CALL	CRLF
A028E:	LDA	NFILES
	INR	A
	DAA
	STA	NFILES
	jnz	lt100
	lda	nf100
	inr	a
	sta	nf100
lt100:	LDA	FREENM
	DCR	A
	STA	FREENM
	JNZ	NOTFSW
	lda	nf100
	ora	a
	jz	ptens
	adi	'0'
	call	co
ptens:	LDA	NFILES
	CALL	PHEXBS
	LXI	D,FLMSG
	CALL	PMSG
	LDA	SWITCH
	CPI	'F'
	JNZ	ABORT
	MVI	A,CTRLZ
	CALL	PUTC
	CALL	WRITE
	LXI	D,NAMFCB
	MVI	C,$CLOSE
	CALL	BDOS
	JMP	ABORT
;
FLMSG:	.ASCII	'FILES$'
;
PHEXBS:	CALL	PHEXB
	JMP	SPACE
;
PHEXB:	PUSH	PSW
	RAR
	RAR
	RAR
	RAR
	CALL	PHEXC
	POP	PSW
PHEXC:	ANI	00FH
	CPI	10
	JC	PHEX1
	ADI	7
PHEX1:	ADI	'0'
CO:	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A
	MVI	C,$CO
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET
;
PMSG:	MVI	C,$PRINT
	JMP	BDOS
;
PUTCM:	MOV	A,M
	CALL	PUTC
	CALL	CO
	INX	H
	DCR	B
	JNZ	PUTCM
	RET
;
SPACE:	MVI	A,' '
	JMP	CO
;
CRLF:	MVI	E,CR
	MVI	C,$CO
	CALL	BDOS
	MVI	E,LF
	MVI	C,$CO
	JMP	BDOS
;
RELPOS:	.BYTE	0
;
PRINT:	POP	D
	MVI	C,$PRINT
	JMP	BDOSEX
;
CIEXIT:	MVI	C,$CI
BDOSEX:	CALL	BDOS
ABORT:	lda	cdisk
	mov	e,a
	mvi	c,$lgin
	call	bdos
	LHLD	STACK
	SPHL
	RET
;
PUTC:	CPI	' '
	RZ
	ani	07fh
	PUSH	PSW
	LDA	SWITCH
	CPI	'F'
	JNZ	A034A
	POP	PSW
	PUSH	PSW
	PUSH	H
	LHLD	D03F8
	MOV	M,A
	INX	H
	SHLD	D03F8
	MOV	A,H
	DCR	A
	CZ	WRITE
	POP	H
A034A:	POP	PSW
	RET
;
WRITE:	PUSH	B
	PUSH	D
	LXI	D,NAMFCB
	MVI	C,$WRITE
	CALL	BDOS
	ORA	A
	JZ	WROK
	CALL	PRINT
;
	.ASCII	'++WRITE ERROR$'
;
WROK:	LXI	H,DMAADR
	SHLD	D03F8
	POP	D
	POP	B
	RET
;
PUTDOT:	MVI	A,'.'
	CALL	PUTC
	JMP	SPACE
;
PUTNL:	MVI	A,CR
	CALL	PUTC
	MVI	A,LF
	CALL	PUTC
	JMP	SPACE
;
COMPARE:PUSH	H
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
	XCHG
	inx	h	;don't compare user no
	inx	b
A0392:	LDAX	B
	CMP	M
	INX	H
	INX	B
	JZ	A0392
	POP	H
	RET
;
SWAP:	MVI	A,1
	STA	D03F6
	MOV	C,M
	INX	H
	PUSH	H
	MOV	B,M
	INX	H
	MOV	E,M
	MOV	M,C
	INX	H
	MOV	D,M
	MOV	M,B
	POP	H
A03AB:	MOV	M,D
	DCX	H
	MOV	M,E
	RET
;
HDMSG:	.ASCII	'FILENAME TYP EX RC -----EXTENT-----$'
;
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
;
STACK:	.BLKB	2
NFILES:	.BYTE	0
nf100:	.byte	0
cdisk:	.byte	0
FREEAD:	.WORD	FREE
FREENM:	.BYTE	0
D03F5:	.BYTE	0
D03F6:	.BYTE	0
SWITCH:	.BYTE	0
D03F8:	.WORD	DMAADR
;
NAMFCB:	.ASCII	[0]'NAMES   SUB'
	.BYTE	0,0,0,0,0,0,0,0
	.BYTE	0,0,0,0,0,0,0,0
	.BYTE	0,0,0,0,0
;
FREPTR:	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0
	.WORD	0,0,0,0,0,0,0,0

FREE:
	.END	FM
