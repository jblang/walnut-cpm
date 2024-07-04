;	APPEND.ASM
;	This is a simple program which is sometimes useful. It copies
;	a <file1> to the END of <file2>. If file2 does not exist a simple
;	copy operation is performed. It also does a fixup on a problem
;	sometimes seen, multiple carriage returns are reduced to one.
;	Unfortunately it needs MAC so if you don't have it get the COM
;	file for APPEND if you can.
;					Jack Riley (303) 499-9169 RCPM.

;	Useage: APPEND file1 file2

	maclib seqio22
BSIZE	EQU 4096

	org 100h
	LXI	H,0
	DAD	SP
	SHLD	STACK
	LXI	SP,STACK

	file	infile,inp,,1,,BSIZE
	file	append,outp,,2,,BSIZE

	xra a
	mov b,a

loop:	get inp
	cpi eof
	jz  quit
	cmp b
	mov b,a
	jnz cont
	cpi 0dh
	jz  loop	; don't duplicate any carriage returns

cont:	put outp
	jmp loop

quit:	finis outp

EXIT	LHLD	STACK
	SPHL
	RET

	DS	50	;STACK
STACK	DW	0
buffers	EQU $
	end
