*
*  TEST FOR XLATE -- 8080-TO-Z80 TRANSLATOR
*

;
;  DEFINE SOME USEFUL CONSTANTS
;
V16	EQU	6789H
V8	EQU	45H

;
;  LET'S DO IT --
;
	ORG	100H
;
;  JMPS
;
	JMP	V16
	JNZ	V16
	JZ	V16
	JNC	V16
	JC	V16
	JPO	V16
	JPE	V16
	JP	V16
	JM	V16
	pchl		;this checks for proper case conversion
;
;  CALLS 'AND a proper case conversion' test
;
	CALL	V16
	CNZ	V16
	CZ	V16
	CNC	V16
	CC	V16
	CPO	V16
	CPE	V16
	CP	V16
	CM	V16
;
;  RETS
;
	RET
	RNZ
	RZ
	RNC
	RC
	RPO
	RPE
	RP
	RM
;
;  RESTARTS
;
	RST	0
	RST	1
	RST	2
	RST	3
	RST	4
	RST	5
	RST	6
	RST	7
;
;  ROTATES
;
	RLC
	RRC
	RAL
	RAR
;
;  CONTROLS
;
	NOP
	HLT
	DI
	EI
;
;  MVI
;
	MVI	B,V8
	MVI	C,V8
	MVI	D,V8
	MVI	E,V8
	MVI	H,V8
	MVI	L,V8
	MVI	M,V8
	MVI	A,V8
;
;  ACC IMMEDIATE
;
	ADI	V8
	ACI	V8
	SUI	V8
	SBI	V8
	ANI	V8
	XRI	V8
	ORI	V8
	CPI	V8
;
;  LOAD IMMEDIATE
;
	LXI	B,V16
	LXI	D,V16
	LXI	H,V16
	LXI	SP,V16
;
;  STACK OPS
;
	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
;
	POP	B
	POP	D
	POP	H
	POP	PSW
;
	XTHL
	SPHL
;
;  DOUBLE ADD
;
	DAD	B
	DAD	D
	DAD	H
	DAD	SP
;
;  INCREMENT
;
	INR	B
	INR	C
	INR	D
	INR	E
	INR	H
	INR	L
	INR	M
	INR	A
;
	INX	B
	INX	D
	INX	H
	INX	SP
;
;  DECREMENT
;
	DCR	B
	DCR	C
	DCR	D
	DCR	E
	DCR	H
	DCR	L
	DCR	M
	DCR	A
;
	DCX	B
	DCX	D
	DCX	H
	DCX	SP
;
;  LOAD/STORE
;
	LDAX	B
	LDAX	D
	LHLD	V16
	LDA	V16
;
	STAX	B
	STAX	D
	SHLD	V16
	STA	V16
;
;  INPUT/OUTPUT
;
	OUT	V8
	IN	V8
;
;  SPECIALS
;
	XCHG
	DAA
	CMA
	STC
	CMC
;
;  MOVE
;
	MOV	B,B
	MOV	B,C
	MOV	B,D
	MOV	B,E
	MOV	B,H
	MOV	B,L
	MOV	B,M
	MOV	B,A
;
	MOV	C,B
	MOV	C,C
	MOV	C,D
	MOV	C,E
	MOV	C,H
	MOV	C,L
	MOV	C,M
	MOV	C,A
;
	MOV	D,B
	MOV	D,C
	MOV	D,D
	MOV	D,E
	MOV	D,H
	MOV	D,L
	MOV	D,M
	MOV	D,A
;
	MOV	E,B
	MOV	E,C
	MOV	E,D
	MOV	E,E
	MOV	E,H
	MOV	E,L
	MOV	E,M
	MOV	E,A
;
	MOV	H,B
	MOV	H,C
	MOV	H,D
	MOV	H,E
	MOV	H,H
	MOV	H,L
	MOV	H,M
	MOV	H,A
;
	MOV	L,B
	MOV	L,C
	MOV	L,D
	MOV	L,E
	MOV	L,H
	MOV	L,L
	MOV	L,M
	MOV	L,A
;
	MOV	M,B
	MOV	M,C
	MOV	M,D
	MOV	M,E
	MOV	M,H
	MOV	M,L	;NOTE -- MOVE M,M OMITTED
	MOV	M,A
;
	MOV	A,B
	MOV	A,C
	MOV	A,D
	MOV	A,E
	MOV	A,H
	MOV	A,L
	MOV	A,M
	MOV	A,A
;
;  ACCUMULATOR
;
	ADD	B
	ADD	C
	ADD	D
	ADD	E
	ADD	H
	ADD	L
	ADD	M
	ADD	A
;
	ADC	B
	ADC	C
	ADC	D
	ADC	E
	ADC	H
	ADC	L
	ADC	M
	ADC	A
;
	SUB	B
	SUB	C
	SUB	D
	SUB	E
	SUB	H
	SUB	L
	SUB	M
	SUB	A
;
	SBB	B
	SBB	C
	SBB	D
	SBB	E
	SBB	H
	SBB	L
	SBB	M
	SBB	A
;
	ANA	B
	ANA	C
	ANA	D
	ANA	E
	ANA	H
	ANA	L
	ANA	M
	ANA	A
;
	XRA	B
	XRA	C
	XRA	D
	XRA	E
	XRA	H
	XRA	L
	XRA	M
	XRA	A
;
	ORA	B
	ORA	C
	ORA	D
	ORA	E
	ORA	H
	ORA	L
	ORA	M
	ORA	A
;
	CMP	B
	CMP	C
	CMP	D
	CMP	E
	CMP	H
	CMP	L
	CMP	M
	CMP	A
;
;  PSEUDOS
;
	DS	V8
	DB	V8
	db	'This is another Case-Conversion Test'	;and Let's See
		;if this works
	DW	V16
;
	END
