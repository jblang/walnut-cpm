;		BGMEMTST.ASM
;	   Background memory test
;
;Version 1.1 - 5/31/81
;
;From Lifelines pg 18 & 19  May 1981
;
;Program created & written and
;Credit should be given to:  Al Rich
;			     Soft Warehouse
;			     Honolulu, HI
;
;Mods/fixes (in reverse order to minimize reading time)
;
;	5/31/81
;Cleaned up file.  Keith Petersen, W8SDZ
;
;	5/30/81
;All I did was to type this in & make sure that
;I didn't introduce any typing errors.  As of
;5/30/81 I have patched this into my CP/M I/O
;and it seems to run.  I.e. there are no un-explained
;hangups.
;	Henry B. Rothberg
;	1 Laticrete Park North
;	Bethany, CT 06525
;
;
;This is a 'constantly running' memory test that
;is inserted into your CP/M I/O drivers at CONIN
;
;Change the jump table in CP/M to jump to CONIN0
;instead of CONIN.
;
;Whenever your sytem is waiting for a character
;to be input from the terminal, the computer will
;be testing memory.
;
;
CONIN0	CALL	TEST
;
CONIN	IN	CSTAT
	ANI	IMASK
	JZ	CONIN0
	IN	CDATA
	ANI	7FH	;strip parity
	RET		;use this ret many times
;
;
;Test routine to constantly test memory
;
TEST	push	h
	lhld	tstpt
	inx	h
	mov	a,h
	cpi	$/100h
	jnz	test1
	lxi	h,0
;
test1	shld	tstpt
	mov	a,m
	cma
	mov	m,a
	cmp	m
	jz	test2
	xra	m
	push	psw
	call	prtstr
	db	0dh,0ah,'*** ',0
	pop	psw
	push	psw
	call	prthx
	call	prtstr
	db	' Bits BAD at: ',0
	mov	a,h
	call	prthx
	mov	a,l
	call	prthx
	pop	psw
;
test2	cma
	mov	m,a
	pop	h
	ret
;
prthx	push	psw
	rrc
	rrc
	rrc
	rrc
	call	prthx1
	pop	psw
;
prthx1	ani	0fh
	cpi	10
	jc	prthx2
	adi	7
;
prthx2	adi	'0'
;
outpt	push	b
	mov	c,a
	call	conout
	pop	b
	ret
;
prtstr	xthl
	push	psw
	call	prt
	pop	psw
	xthl
	ret
;
prt	mov	a,m
	inx	h
	ana	a
	rz
	call	outpt
	jmp	prt
;
tstpt	dw	0
;
;End of constant memory test
