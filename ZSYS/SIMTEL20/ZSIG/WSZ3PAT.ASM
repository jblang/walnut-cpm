;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						;
;	WSPATCH.ASM				;
;						;
;	Patch for Wordstar 3.0 running under	;
;	The Echelon 'Z' System.  Modifies	;
;	Wordstar to use the current terminal	;
;	characteristics defined in Z3TCAP.	;
;						;
;	Copyright (c) 1985 by Dennis Wright	;
;	and Echelon, Inc.			;
;						;
;	Contains selected routines from 	;
;	ZCPR3's VLIB.				;
;						;
;	VLIB is Copyrighted by Richard Conn	;
;	and Echelon Inc.			;
;						;
;	Note: It may be possable to install	;
;	this patch on other versions of Word-	;
;	Star if the equates below are changed	;
;	to agree with versions' addresses.	;
;						;
;	    WordStar is a trademark of		;
;	MicroPro International Corporation	;
;						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	MACLIB	Z3BASE
;
;	WordStar 3.0 USER1 Patch Addresses from Installation manual.
;
TNAME	EQU	0190H		; Terminal name (not documented in manual).
HITE	EQU	0248H		; Number of lines.
WID	EQU	0249H		; Number of columns.
ERAEOL	EQU	026DH		; Erase to end of line.
LINDEL	EQU	0274H		; Delete line.
LININS	EQU	027BH		; Insert line.
IVON	EQU	0284H		; Highlighting on.
IVOFF	EQU	028BH		; Highlighting off.
DELMIS	EQU	02AFH		; Delay for non-cursor set functions.
TRMINI	EQU	0292H		; Terminal init string.
TRMUNI	EQU	029BH		; Terminal de-init string.
UCRPOS	EQU	0264H		; User cursor positioning routine.
INISUB	EQU	02A4H		; User init routine.
MORPAT	EQU	02E0H		; WordStar user patch area.
PBGMEM	EQU	035CH		; Contains beginning of text buffer address.
OCHAR	EQU	0267H		; Contains address of WordStar outchr routine.
;
;	The following equate is the base address of the patch routines.
;
PATCH	EQU	7849H		; Get this address from original PBGMEM.
;
	ORG	UCRPOS		; User-patchable cursor positioning routine.
	JMP	XYPOS		; Use VLIB cursor positioning routine.
;
	ORG	INISUB		; User-patchable init subroutine.
	JMP	INIT		; Use patch init routine.
;
	ORG	MORPAT		; WordStar user patch area.
INIT:	LXI	H,Z3ENV		; Point to 'Z' System environment descriptors.
	LXI	D,80H
	SHLD	ENVPTR		; Save pointer.
	PUSH	H		; Save for later.
	DAD	D		; Displace to Z3TCAP.
	SHLD	VIDPTR		; Save pointer.
	LHLD	OCHAR		; Address of WS outchr routine is kept here.
	SHLD	COUT1+1		; Inline modify patch cout to use WS outchr.
	POP	H		; Restore env pointer.
	LXI	D,47		; Offset to Z3TCAP crt select byte.
	DAD	D
	MOV	A,M		; Get it.
	LXI	D,2		; Set offset to crt 0 data area.
	ORA	A		; Crt 0?
	JZ	GETCRT		; Yes move crt 0 data to WS patch area.
	LXI	D,5		; No, move crt 1 data.
GETCRT:	DAD	D		; Offset to selected Z3TCAP crt data area.
	MOV	A,M		; Get Z3TCAPs terminal width.
	STA	WID		; Patch WS width.
	INX	H		; Bump to Z3TCAPs number of lines.
	MOV	A,M		; Get number of lines.
	STA	HITE		; Patch WS hite.
	XRA	A		; Clear following WS patchs.
	STA	LINDEL		; Line delete
	STA	LININS		; ..and line insert (we don't support these).
	LHLD	VIDPTR		; Get Z3TCAP pointer.
	LXI	D,22		; Offset to CE delay.
	DAD	D
	MOV	A,M		; Get CE delay.
	STA	DELMIS		; Patch WS misc delay.
	INX	H
	CALL	VIDSKP		; Skip past CL string.
	CALL	VIDSKP		; Skip past CM string.
	LXI	D,ERAEOL	; Point to WS eol string.
	CALL	FILL		; Replace with Z3TCAPs eol string.
	LXI	D,IVON		; Point to WS turn on highlighting.
	CALL	FILL		; Replace with Z3TCAPs string.
	LXI	D,IVOFF		; Point to WS turn off highlighting.
	CALL	FILL		; Replace with Z3TCAPs string.
	LXI	D,TRMINI	; Point to WS terminal init string.
	CALL	FILL		; Replace with Z3TCAPs string.
	LXI	D,TRMUNI	; Point to WS terminal de-init string.
	CALL	FILL		; Replace with Z3TCAPs string.
	CALL	NAMIT		; Replace WS terminal name with Z3TCAPs.
	RET			; We're done.
;
	ORG	PBGMEM		; The beginning of the text memory is
	DW	BEGMEM		; ..moved up to accommidate our patch.
;
	ORG	PATCH		; Extended patch area.
NAMIT:	LHLD	VIDPTR		; Point to Z3TCAPs terminal name
	LXI	D,TNAME		; ..and WS terminal name.
	MVI	C,16		; Move our 16 bytes.
NFILL:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	C
	JNZ	NFILL
	XCHG
NFILL2:	MOV	A,M		; Pad out the remainder with spaces.
	CPI	0FH		; Till this.
	RZ
	ORA	A		; Or zero.
	RZ
	MVI	A,20H
	MOV	M,A
	INX	H
	JMP	NFILL2
;
;	This routine moves Z3TCAP data into the WordStar patch area.
;	Because WordStar requires the number of bytes for each entry
;	we must count the bytes we patch and place the number at the
;	beginning of the patch.
;
FILL:	PUSH	D
	MVI	C,-1		; Set byte counter.
FIL1:	INX	D
	MOV	A,M		; Replace WS data with Z3TCAPs.
	STAX	D
	INX	H
	INR	C
	ORA	A		; Reached end?
	JNZ	FIL1
	POP	D		; Yes, restore pointer to first byte.
	MOV	A,C		; Insert number of bytes in string.
	STAX	D
	RET
;
COUT:	PUSH	H
	PUSH	D
COUT1:	CALL	0000H		; This is inline modified by the INIT.
	POP	D		; Routine to call WordStars outchr
	POP	H		; ..routine.
	RET
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	The following routines are from VLIB by Richard Conn.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GOTO XY	(From VLIB)
;	HL = Row/Col, with Home=0/0
;	Return with A=0 and Zero Flag Set if not done
;
XYPOS:	MOV	D,L		; Swap row & column
	MOV	E,H		; ..for vlib
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
;   On input, H=Row and L=Column to Position To (0,0 is Home)
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
; Set row/col home to 0,0
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
ENVPTR:	DS	2		; 'Z' System environment package.
;
BEGMEM	EQU	$
;
	END
