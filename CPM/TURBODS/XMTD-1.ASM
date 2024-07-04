	TITLE	'XMODEM PATCH FILE FOR TURBODOS'
;
; TDPAT - patch file for TurboDOS / XMODEM
; uses COMM port
;
; EDITED: 07/14/84	SFK
;
BASE	EQU	100H		;start of TPA
;
PORT	EQU	0		;0=modem port, 1=console port
;
;-------------------------------------------------------------------
;
; Jump table: The jump table must be in exactly the same sequence
; as the one in XMODEM. Note the ORG of 103H - This jump table has
; no jump to BEGIN.
;
	ORG	BASE+3	;start after JMP BEGIN
;
CONOUT:	JMP	COUT
PMINIT:	JMP	MINIT	;initialize whatever has to be (or do RET)
PUNINIT:JMP	UNINIT	;undo whatever MINIT did (or RET)
PSENDR:	JMP	SENDR	;send data byte on stack (POP PSW / OUT)
PCAROK:	JMP	CAROK	;test for carrier. RET Z=ok, NZ=no carrier
PMDIN:	JMP	MDIN	;receive data byte
PGETCHR:JMP	GETCHR	;must point to a RET
PRCVRDY:JMP	RCVRDY	;check receive ready RET Z=ready
PSNDRDY:JMP	SNDRDY	;check send ready RET Z=ready
PSPEED:	JMP	SPEED	;get speed factor in ACC
PSPARE1:JMP	SPARE	;3 jumps for custom routines
PSPARE2:JMP	SPARE
PSPARE3:JMP	SPARE
;
;-----------------------------------------------------------------------
;
GETCHR:			;no garbage collection done
SPARE:			;for later use
MINIT:  		; No Init
UNINIT: 		; No Init so no Un-init!
	RET
;
; SNDRDY - check if ready to send
;
SNDRDY:	xra	a	;assume always ready
	ret
;
	if	not port
COUT:	push	b
	push	d
	push	h
	mvi	d,1
	jmp	go
	endif
;
; SENDR - send character
;
SENDR:	pop	psw
	push	b
	push	d
	push	h
	mov	e,a
	mvi	d,port
go:	mvi	c,36
	call	50h
	pop	h
	pop	d
	pop	b
	ret
;
; RCVRDY - check receive ready
; RET with Z = character available.
; return error code in A
;
RCVRDY:	push	b
	push	d
	push	h
	mvi	c,34
	mvi	d,port
	call	50h
	pop	h
	pop	d
	pop	b
	ora	a
	jnz	rdy
	mvi	a,0afh
rdy	equ	$-1
	ora	a
	ret
;
; MDIN - receive a character (GETCHR is identical)
;
MDIN:	push	b
	push	d
	push	h
        mvi	c,34
	mvi	d,0
	call	50h
	ora	a
	jnz     nochar
	mvi	c,35
	mvi	d,port
	call	50h
nochar:
	pop	h
	pop	d
	pop	b
	ret
;
; SPEED - This routine returns the speed code.
; 0=110, 1=300, 2=450, 3=600, 4=710, 5=1200
; Load your speed byte from low memory, or
; simply MVI A,n and RET for default speed only
;
; the following will work correctly for 300 and 1200:
;
SPEED:	push	b
	push	d
	push	h
	mvi	c,38
	mvi	d,port
	call	50h
	lxi	h,table
	ani	0fh
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	a,m
	pop	h
	pop	d
	pop	b
	ret
;
; table for baud rates (110,300,600,1200,2400,4800,9600,19200)
; invalid entries return 110 baud
;
table:	db	0,0,0,0,0,1,3,5,0,0,6,0,7,0,8,9
;
; CAROK - check for presence of carrier.
; RET with Z = carrier on
;
CAROK:	xra	a
	RET
	END
