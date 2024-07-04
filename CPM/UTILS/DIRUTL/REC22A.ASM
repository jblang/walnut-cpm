;Recovery program to reinstate deleted disk files
;Copyright (C) David R Back 1982
;requires CP/M2.2
;SYNTAX: rec22 [ambiguous]filename.ext
;
;REC22A.ASM created 11/15/84 by Keith Petersen, W8SDZ.  No
;changes made other than reformatting file to make reading
;code easier.  The original had only a single space between
;columns and was all lower case.
;
BDOS	EQU	5
CR	EQU	0DH
LF	EQU	0AH
;
	ORG	100H
;
BEGIN:	JMP	START
	DB	'COPYRIGHT (C) DAVID R BACK 1982'
;
START:	LXI	H,0
	DAD	SP
	SHLD	USERSP
	LXI	SP,USERSP
	LDA	5DH		;test for blank filename
	CPI	' '
	LXI	D,BLKFIL
	JZ	BLKER
	MVI	C,9
	LXI	D,SIGNON
	CALL	BDOS		;signon message
	MVI	C,12
	CALL	BDOS		;get version
	MOV	A,L
	CPI	20H
	LXI	D,BDSEL
	JC	BLKER
	MVI	C,25		;get current disk
	CALL	BDOS
	STA	DISK		;save default
	MOV	C,A
	LXI	D,5CH
	LDAX	D		;required drive
	ORA	A
	MOV	E,C
	JZ	SETALL
	DCR	A
	MOV	E,A
;
SETALL:	PUSH	D
	MVI	C,14		;select disk
	CALL	BDOS		;make sure drive has been selected
	POP	B
	LXI	D,1		;already selected
	CALL	SELDSK		;get .dphd
	LXI	D,8
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M		;DE=.DIRBUF
	MOV	L,E
	MOV	H,D
	SHLD	DBUF		;save .DIRBUF
	MVI	C,26		;setdma
	CALL	BDOS
	MVI	C,32
	MVI	E,0FFH		;get user
	CALL	BDOS
	STA	US		;save current user
	MVI	C,32		;set user
	MVI	E,5		;user 5
	CALL	BDOS
	LXI	D,5CH
	MVI	A,'?'
	STAX	D
	MVI	C,17		;sfirst
;
LOOP:	CALL	BDOS
	CPI	0FFH
	JZ	EXIT
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	MOV	C,A
	MVI	B,0
	LHLD	DBUF		;dirbuf
	DAD	B
	PUSH	H
	MVI	C,11		;ignore ext
	LXI	D,5CH
	CALL	COMP		;compare with fcb
	POP	H
	RAR
	JC	NXT
	MOV	A,M
	CPI	0E5H		;recover only deleted files
	JNZ	NXT
	PUSH	H
	PUSH	H
	MOV	A,M
	MVI	B,11
	INX	H
;
NAMOUT:	MOV	A,M
	CALL	CNVRT		;convert to printing chars
	CALL	OPCHR		;o/p char to co
	DCR	B
	INX	H
	JNZ	NAMOUT
	CALL	CRLF
	MVI	B,32
	POP	H
;
FCBOUT:	MOV	A,B
	ANI	3
	CZ	WRSPC		;o/p space to co
	MOV	A,M
	CALL	BINASC		;binary to hex ascii
	INX	H
	DCR	B
	JNZ	FCBOUT
	CALL	CRLF
	LXI	D,RECO
	CALL	PSTR		;printstring
	CALL	CI
	POP	H
	CPI	3		;^C exit
	JZ	EXIT
	CPI	'Y'
	JZ	REC
	CPI	'y'
	JNZ	NXT
;
REC:	MVI	M,0		;recover file to user 0
	MVI	C,12
	CALL	RESET		;reset attributes of recovered file
	MVI	C,1		;directory write
	CALL	WRITE		;write dir sector to disk
	ORA	A
	JNZ	WRERR
;
NXT:	LXI	D,5CH
	MVI	A,0E0H
	STAX	D
	MVI	C,18		;snext
	JMP	LOOP
;
BLKER:	MVI	C,9
	CALL	BDOS
	JMP	EXIT1
;
WRERR:	LXI	D,ERMSG
;
WRERR1:	MVI	C,9
	CALL	BDOS
;
EXIT:	MVI	C,13		;reset system
	CALL	BDOS
	LDA	DISK
	MOV	E,A
	MVI	C,14
	CALL	BDOS		;reset original drive
	MVI	C,32		;reselect original user
	LDA	US
	MOV	E,A
	CALL	BDOS
;
EXIT1:	LHLD	USERSP
	SPHL
	RET			;to ccp
;
COMP:	INX	D
	INX	H		;dont compare drives
;
COMPR1:	LDAX	D
	ANI	7FH
	CPI	'?'
	JZ	COMPR2
	MOV	B,A
	MOV	A,M
	ANI	7FH
	CMP	B
	JNZ	COMPF
;
COMPR2:	INX	H
	INX	D
	DCR	C
	JNZ	COMPR1
	XRA	A
	RET
;
COMPF:	XRA	A
	CMA
	RET
;
RESET:	MOV	A,M
	ANI	7FH
	MOV	M,A
	INX	H
	DCR	C
	JNZ	RESET
	RET
;
PSTR:	LDAX	D
	CPI	'$'
	RZ
	CALL	OPCHR
	INX	D
	JMP	PSTR
;
OPCHR:	PUSH	B
	PUSH	D
	PUSH	H
	MOV	C,A
	CALL	CO
	POP	H
	POP	D
	POP	B
	RET
;
CRLF:	MVI	A,CR
	CALL	OPCHR
	MVI	A,LF
	CALL	OPCHR
	RET
;
WRSPC:	MVI	A,' '
	CALL	OPCHR
	RET
;
HASC:	CPI	10
	JC	HASC1
	ADI	'7'
	CALL	OPCHR
	RET
;
HASC1:	ADI	'0'
	CALL	OPCHR
	RET
;
BINASC:	PUSH	PSW
	RAR
	RAR
	RAR
	RAR
	ANI	0FH
	CALL	HASC
	POP	PSW
	ANI	0FH
	CALL	HASC
	RET
;
CNVRT:	CPI	' '
	JC	CNVRT1
	CPI	61H
	JNC	CNVRT1
	RET
;
CNVRT1:	MVI	A,'-'
	RET
;
CI:	LHLD	1
	LXI	D,6		;bios ci
	DAD	D
	PCHL
;
CO:	LHLD	1
	LXI	D,9		;bios co
	DAD	D
	PCHL
;
;req C=drive 0,1...  lsb E=1
SELDSK:	LHLD	1
	LXI	D,24		;bios seldsk
	DAD	D
	PCHL
;
WRITE:	LHLD	1
	LXI	D,39
	DAD	D		;bios write
	PCHL
;
BLKFIL:	DB	CR,LF,'NO FILE SPECIFIED',CR,LF,'$'
BDSEL:	DB	CR,LF,'CP/M 2.0 or later is required.',CR,LF,'$'
RECO:	DB	'RECOVER ?',CR,LF,'$'
ERMSG:	DB	CR,LF,'DIRECTORY WRITE ERROR',CR,LF,'$'
SIGNON:	DB	CR,LF,'Disk File Recover D.R.Back V2.2',CR,LF,'$'
;
	DS	32		;stack
USERSP:	DS	2
DISK:	DS	1		;original default drive
US:	DS	1		;original user
DBUF:	DS	2		;dirbuf
;
END	BEGIN
