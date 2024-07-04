;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							;
;	WMPATCH.ASM					;
;							;
; 	Patch for Word-Master 1.07 to use with		;
; 	the Echelon 'Z' System. This patch causes	;
; 	WordMaster to use the current terminal		;
; 	characteristics defined in Z3TCAP.		;
;							;
; 	Copyright (c) 1985 by Dennis Wright and		;
;	Echelon, Inc.					;
;							;
; 	Contains selected ZCPR3 VLIB routines.	        ;
;							;
; 	VLIB is copyrighted by Richard Conn and		;
; 	Echelon, Inc.					;
;							;
; 	WordMaster is a trademark of MicroPro		;
; 	International.					;
;							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	MACLIB	Z3BASE
;
;	WordMaster 1.07 Patch Addresses
;
CLRSCRN	EQU	0180H		; Clearscreen routine
HITE	EQU	01B9H		; Number of lines
WID	EQU	01BAH		; Number of columns
EREOL	EQU	01BBH		; Erase to end of line
NOVIO	EQU	01BDH		; No video i/o board
DELCLR	EQU	01C1H		; Delay after clear screen
DELCUS	EQU	01C1H
DELERE	EQU	01C3H		; Delay for non-cursor set functions
TCURSOR	EQU	0196H		; User cursor positioning routine
PBEGMEM	EQU	01B7H		; Contains beginning of text buffer address
SPEC	EQU	29B8H		; Get this address from PBEGMEM
OUTCHR	EQU	01EFH		; Output character routine.
START	EQU	0269H		; Start of Word-Master Version 1.07
;
	ORG	100H
	JMP	INIT		; Goto our init routine
;
	ORG	CLRSCRN
	CALL	CLS
	LXI	H,0
	JMP	XYPOS		; Put cursor at 0, 0
;
	ORG	TCURSOR		; User-patchable cursor positioning routine.
	JMP	XYPOS		; Use our own cursor positioning routine.
;
	ORG	PBEGMEM
	DW	BEGMEM
;
	ORG	SPEC		; Added patch area
INIT:	LXI	H,Z3ENV		; Point to the ZCPR3 environment
	LXI	D,80H
	SHLD	ENVPTR		; Save pointer
	PUSH	H		; Save for later
	DAD	D		; Displace to Z3TCAP
	SHLD	VIDPTR		; Save pointer
	XRA	A
	LXI	H,DELCLR
	MOV	M,A
	INX	H
	MOV	M,A
	INX	H
	MOV	M,A
	POP	H		; Restore env pointer
	LXI	D,47		; Offset to CRT select byte
	DAD	D
	MOV	A,M		; Get it.
	LXI	D,2
	ORA	A		; Crt 0?
	JZ	GETCRT		; Yes move crt 0 data to wm patch area
	LXI	D,5		; No, move crt 1 data
GETCRT:	DAD	D
	MOV	A,M		; Get tcap width
	STA	WID		; Patch wm width
	INX	H
	MOV	A,M		; Get tcap number of lines
	STA	HITE		; Patch wm hite
	LHLD	VIDPTR		; Get tcap pointer
	LXI	D,22		; Offset to ce delay
	DAD	D
	MOV	A,M		; Get ce delay
	STA	DELERE		; Patch wm delay after erase to eol
	INX	H
	CALL	VIDSKP		; Skip past cl string
	CALL	VIDSKP		; Skip past cm string
	LXI	D,EREOL		; Point to wm eol string
	PUSH	H
	MVI	C,-1
CNTEOL:	MOV	A,M		; Get tcap byte count for eol
	INX	H
	INR	C
	ORA	A
	JNZ	CNTEOL
	POP	H
	MOV	A,C
	CPI	3		; More than 2 bytes?
	JNC	INIT1		; If so don't use it
	CALL	FILL		; No, patch with tcaps eol string
	JMP	INIT2
INIT1:	XRA	A		; Tell wm to simulate eol
	STAX	D
INIT2:	MVI	A,0FFH		; Set no video i/o
	STA	NOVIO
	JMP	START		; We're done
;
FILL:	MOV	A,M		; Replace wm data with ours
	ORA	A
	RZ
	STAX	D
	INX	H
	INX	D
	JMP	FILL
;
COUT:	PUSH	H
	PUSH	D
	CALL	OUTCHR
	POP	D
	POP	H
	RET
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	The following routines are from VLIB by Richard Conn.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Clear Screen
;	Return with A=0 and Zero Flag Set if not done
;
CLS:	PUSH	H		; Save regs
	PUSH	D
	LHLD	VIDPTR		; Pt to environment
	MOV	A,M		; No terminal?
	CPI	' '+1
	JC	CLSERR
	LXI	D,14H		; Pt to cls delay
	DAD	D
	MOV	D,M		; Get it
	INX	H		; Pt to cls string
	INX	H
	INX	H
	MOV	A,M		; Get first char of string
	ORA	A		; If no string, error
	JZ	CLSERR
	CALL	VIDOUT		; Output string with delay
	POP	D		; Done
	POP	H
	XRA	A		; Return NZ
	DCR	A
	RET
;
CLSERR:	POP	D		; Done
	POP	H
	XRA	A		; Return Z
	RET
;
;  VIDOUT - Output video string pted to by HL
;	Output also a delay contained in the D register
;
VIDOUT:	MOV	A,M		; Get next char
	ORA	A		; Done if zero
	JZ	VIDO2
	INX	H		; Pt to next
	CPI	'\'		; Literal value?
	JNZ	VIDO1
	MOV	A,M		; Get literal char
	INX	H		; Pt to after it
VIDO1:	CALL	COUT		; Output char
	JMP	VIDOUT
VIDO2:	MOV	A,D		; Output delay
	JMP	VIDELAY		; Output delay
;
; GOTO XY	(From VLIB)
;	HL = Row/Col, with Home=1/1
;	Return with A=0 and Zero Flag Set if not done
;
XYPOS:	MOV	D,L		; Swap row & column
	MOV	E,H		;  for VLIB
	XCHG
GOTOXY:	PUSH	B		; Save regs
	PUSH	D
	PUSH	H
	LHLD	VIDPTR		; Pt to environment
	MOV	A,M		; No terminal?
	CPI	' '+1
	JC	ERR
	LXI	D,15H		; Pt to CM delay
	DAD	D
	MOV	A,M		; Get it
	STA	CMDELAY		; Save it
	INX	H		; Pt to CL string
	INX	H
	CALL	VIDSKP		; Skip CL string
	MOV	A,M		; Get first char of CM string
	ORA	A		; If no string, error
	JZ	ERR
	XCHG			; DE=address of CM string
	POP	H		; Get coordinates in HL
	PUSH	H
	CALL	GXY		; Output xy string with delay
	LDA	CMDELAY		; Pause
	CALL	VIDELAY
	POP	H		; Done
	POP	D
	POP	B
	XRA	A		; Return NZ
	DCR	A
	RET
ERR:	POP	H		; Done
	POP	D
	POP	B
	XRA	A		; Return Z
	RET
;
; GOTOXY	(From VLIB)
;   On input, H=Row and L=Column to Position To (1,1 is Home)
;   On input, DE=address of CM string
;
GXY:	XRA	A		; Set row/column
	STA	RCORDER		; Row before column
	STA	RCBASE		; Add 0 to base
;
; Cycle thru string
;
GXYLOOP:LDAX	D		; Get next char
	INX	D		; Pt to next
	ORA	A		; Done?
	RZ
	CPI	'%'		; Command?
	JZ	GXYCMD
	CPI	'\'		; Escape?
	JZ	GXYESC
	CALL	COUT		; Send char
	JMP	GXYLOOP

;
; Escape - output following byte literally
;
GXYESC:	LDAX	D		; Get next char
	CALL	COUT		; Output literally
	INX	D		; Pt to next
	JMP	GXYLOOP
;
; Interpret next character as a command character
;
GXYCMD:	LDAX	D		; Get command char
	INX	D		; Pt to next
	CPI	'd'		; %d
	JZ	GXYOUT1
	CPI	'2'		; %2
	JZ	GXYOUT2
	CPI	'3'		; %3
	JZ	GXYOUT3
	CPI	'.'		; %.
	JZ	GXYOUT4
	CPI	'+'		; %+v
	JZ	GXYOUT5
	CPI	'>'		; %>xy
	JZ	GXYGT
	CPI	'r'		; %r
	JZ	GXYREV
	CPI	'i'		; %i
	JZ	GXYINC
	CALL	COUT		; Output char if nothing else
	JMP	GXYLOOP
;
; Set row/col home to 1,1 rather than 0,0
;
GXYINC:	MVI	A,1		; Set rcbase to 1
	STA	RCBASE
	JMP	GXYLOOP
;
; Reverse order of output to column then row (default is row then column)
;
GXYREV:	MVI	A,1		; Set column and row order
	STA	RCORDER
	JMP	GXYLOOP
;
; Command: >xy
;   If value of row/col is greater than x, add y to it
;
GXYGT:	CALL	GETVAL		; Get value
	MOV	C,A		; Save value
	LDAX	D		; Get value to test
	INX	D		; Pt to next
	CMP	C		; If carry, value>x
	JNC	GXYGT1
	LDAX	D		; Get value to add
	ADD	C
	CALL	PUTVAL		; Put value back
GXYGT1:	INX	D		; Pt to next
	JMP	GXYLOOP		; Resume
;
; Command: +n
;   Add n to next value and output
;
GXYOUT5:LDAX	D		; Get value to add
	INX	D		; Pt to next
	MOV	B,A		; Save in B
	CALL	GETVAL		; Get value
	ADD	B		; Add in B
	CALL	COUT		; Output value
RCMARK:	LDA	RCORDER		; Mark output
	ORI	80H
	STA	RCORDER
	JMP	GXYLOOP
;
; Command: .
;   Output next value
;
GXYOUT4:CALL	GETVAL		; Get value
	CALL	COUT		; Output value
	JMP	RCMARK
;
; Command: 3
;   Output next value as 3 decimal digits
;
GXYOUT3:CALL	GETVAL		; Get value
	MVI	B,100		; Output 100's
	MVI	C,1		; Leading zeroes
	CALL	DIGOUT
GXYOT3:	MVI	B,10		; Output 10's
	MVI	C,1		; Leading zeroes
GXYOT2:	CALL	DIGOUT
	ADI	'0'		; Output 1's
	CALL	COUT
	JMP	RCMARK
;
; Command: 2
;   Output next value as 2 decimal digits
;
GXYOUT2:CALL	GETVAL		; Get value
	JMP	GXYOT3
;
; Command: d
;   Output next value as n decimal digits with no leading zeroes
;
GXYOUT1:CALL	GETVAL		; Get value
	MVI	B,100		; Output 100's
	MVI	C,0		; No leading zeroes
	CALL	DIGOUT
	MVI	B,10		; Output 10's
	MVI	C,0		; No leading zeroes
	JMP	GXYOT2
;
; Return next value in A
;
GETVAL:	LDA	RCORDER		; Get order flag
	ORA	A		; Already output the first value?
	JM	GETVAL2
	ANI	1		; Look at lsb
	JZ	GETVALR		; If 0, row first
GETVALC:LDA	RCBASE		; Get base offset
	ADD	L		; Get column
	RET
;
GETVALR:LDA	RCBASE		; Get base offset
	ADD	H		; Get row
	RET
;
GETVAL2:ANI	1		; Look at lsb
	JZ	GETVALC
	JMP	GETVALR
;
; Store A as next value
;
PUTVAL:	MOV	C,A		; Save value
	LDA	RCORDER		; Get order flag
	ORA	A		; Already output the first value?
	JM	PUTVAL2
	ANI	1		; Look at lsb
	JZ	PUTVALR		; If 0, row first
PUTVALC:MOV	L,C		; Set column
	RET
;
PUTVALR:MOV	H,C		; Set row
	RET
;
PUTVAL2:ANI	1		; Look at lsb
	JZ	PUTVALC
	JMP	PUTVALR
;
; Output A as decimal digit char
;   B=Quantity to Subtract from A, C=0 if no leading zero
;
DIGOUT:	PUSH	D		; Save DE
	MVI	D,'0'		; Char
DECOT1:	SUB	B		; Subtract
	JC	DECOT2
	INR	D		; Increment char
	JMP	DECOT1
;
DECOT2:	ADD	B		; Add back in
	PUSH	PSW		; Save result
	MOV	A,D		; Get digit
	CPI	'0'		; Zero?
	JNZ	DECOT3
	MOV	A,C		; Get zero flag
	ORA	A		; 0=no zero
	JZ	DECOT4
DECOT3:	MOV	A,D		; Get digit
	CALL	COUT		; Print it
DECOT4:	POP	PSW		; Get A
	POP	D		; Restore DE
	RET
;
; GXY Buffers
;
RCORDER:DS	1		; 0=row/col, else col/row
RCBASE:	DS	1		; 0=org is 0,0, else org is 1,1
CMDELAY:DS	1		; Number of milliseconds to delay for CM
;
;	VIDELAY pauses for the number of milliseconds indicated by the A
; register.  VIDELAY assumes a ZCPR3 environment and uses it to determine
; processor speed.
;
VIDELAY:PUSH	PSW		; Save regs
	PUSH	B
	PUSH	D
	PUSH	H
	MOV	C,A		; Save count in C
	ORA	A		; No delay?
	JZ	DONE
	LHLD	ENVPTR		; Pt to environment
	LXI	D,2BH		; Offset to processor speed
	DAD	D
	MOV	A,M		; Get processor speed
	ORA	A		; Zero?
	JNZ	VID1
	MVI	A,4		; Assume 4 MHz
VID1:	MOV	B,A		; Processor speed in B
VID2:	PUSH	B		; Delay 1 ms
	CALL	DELAY
	POP	B
	DCR	C		; Count down
	JNZ	VID2
DONE:	POP	H		; Restore regs
	POP	D
	POP	B
	POP	PSW
	RET
;
;  Delay 1 ms at Clock speed
;
DELAY:	CALL	DEL1		; Delay 1 ms at 1MHz
	DCR	B		; Count down clock speed
	JNZ	DELAY
	RET
;
;  Delay 1 ms at 1MHz
;
DEL1:	MVI	C,20		; 20 loops of 51 cycles each ~ 1000 cycles
DEL1A:	XTHL			; 18 cycles
	XTHL			; +18 = 36 cycles
	DCR	C		; + 5 = 41 cycles
	JNZ	DEL1A		; +10 = 51 cycles
	RET
;
;  VIDSKP - Skip over video string pted to by HL; pt to byte after string
;
VIDSKP:	MOV	A,M		; Get next char
	INX	H		; Pt to next
	ORA	A		; Done if zero
	RZ
	CPI	'\'		; Literal value?
	JNZ	VIDSKP		; Continue if not
	INX	H		; Pt to after literal value
	JMP	VIDSKP
;
;  ZCPR3 Pointer save area
;
VIDPTR:	DS	2		; First byte of termcap entry
ENVPTR:	DS	2
;
BEGMEM	EQU	$
;
	END
