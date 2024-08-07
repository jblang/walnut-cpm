;****************************************
;
;               ISIS II TO CPM
;             DIRECTORY UTILITY
;
;	UPDATE TO GIVE A  W I D E DISPLAY
;
;                VERSION 2.2
;
;	Updated by Rod Whitworth,
;		   Planet 3 Systems
;		   Bankstown,
;		   Australia
;
;****************************************

FALSE	EQU	0
TRUE	EQU	NOT FALSE
LOGICAL	EQU	TRUE	;TRUE IF SECTORS START AT ZERO IN BIOS
			;SET FALSE IF NO TRANSLATION OCCURS AUTOMATICALLY


	ORG	100H
ICOPY:	LXI	SP,STACK	;SET STACK
	LDA	05CH		;FCB DISK #
	ORA	A		;IS IT 0 ?
	JZ	DONE		;CAN'T USE DRIVE A
	SUI	1		; WOULD ALSO BE A:
	JZ	DONE		;SO GO HOME TOO
	STA	DRNUM
	MOV	C,A		;SELECT THE RIGHT ONE
	ADI	'A'
	STA	BMSG		;CORRECT IDENT
	CALL	SDSK
	CALL	VALID		;SEE IF SINGLE DENSITY SS FLOP
	CALL	HOME		;HOME DISK
	LXI	D,DIRLNK	;POINT TO DIR LINK BLOCK LINK
	LXI	H,DBCA		;DIR BCA
	CALL	GLB		;GET LINK BLOCK
ICL0:	LXI	H,DBCA		;DIR BCA
	CALL	GDB		;GET DIR BLOCK
	JC	DONE		;NO MORE DIR BLOCKS, FINISHED
	LXI	H,DBUF		;DIR BUFFER
	SHLD	DENT		;SAVE IN POINTER
	MVI	A,8		;NUMBER OF  ENTRIES/BLOCK
	STA	DCNT		;SAVE
ICL1:	LHLD	DENT		;GET DIR ENTRY PTR
	MOV	A,M		;GET STATUS BYTE
	CPI	00		;ACTIVE?
	JNZ	ILN1		;NO, GET NEXT ENTRY
	INX	H		;POINT TO FN
	PUSH	H		;SAVE HL
	LXI	D,BMSG
	MVI	C,09
	CALL	CPM		;PRINT 'B: ' MESSAGE
	POP	H
	CALL	FPRT		;PRINT FILE ID
ILN1:	LHLD	DENT		;POINTER TO ENTRY
	LXI	D,16		;SIZE OF ENTRY
	DAD	D		;POINT TO NEXT ENTRY
	SHLD	DENT
	LDA	DCNT		;ENTRY COUNTER
	DCR	A		;DECREMENT
	STA	DCNT
	JNZ	ICL1		;LOOP
	JMP	ICL0

DONE:	MVI	C,0
	CALL	SDSK
	JMP	BOOT

IOERR:	LXI	D,MSG2
	MVI	C,09
	CALL	CPM
	JMP	BOOT

;***************************************;
;
;           GLB - GET LINK BLOCK
;
;         DE= A(LINK TO LINK BLOCK)
;         HL= A(BLOCK CONTROL AREA)
;
;***************************************;
GLB:	SHLD	BCAP		;SAVE BCA ADDR
	CALL	SEEKR		;READ LINK BLOCK
	LHLD	BCAP		;GET BCA ADDR
	LXI	D,BCBL		;OFFSET TO LINK BUFFER
	DAD	D
	LXI	D,TBUF
	MVI	B,128
	CALL	MOVE		;COPY TO LINK BUFFER
	LHLD	BCAP		;GET BCA ADDR
	LXI	D,BCBL+4	;OFFSET TO FIRST DATA LINK
	XCHG
	DAD	D		;DE=A(FIRST DATA LINK)
	XCHG
	LXI	B,BCAL		;OFFSET TO LINK PTR
	DAD	B
	MOV	M,E
	INX	H
	MOV	M,D		;SET LINK PTR
	LHLD	BCAP		;BCA ADDR
	LXI	D,BCALC		;LINK COUNT
	DAD	D
	MVI	M,62		;NO OF LINKS
	RET

;****************************************:
;
;            GDB:   GET DATA BLOCK
;
;            HL= A(BLOCK CONTROL AREA)
;
;****************************************;

GDB:	SHLD	BCAP		;SAVE BCA ADDR
	LXI	D,BCAL		;OFFSET TO LINK BUF
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M		;GET LINK ADDR
	PUSH	D		;SAVE LINK ADDR
	LDAX	D		;GET LINK BYTE
	MOV	C,A
	INX	D
	LDAX	D		;GET LINK BYTE
	ORA	C		;TEST FOR ZERO LINK
	POP	D
	JZ	GDBE		;ZERO LINK, EOF
	PUSH	D
	PUSH	H
	CALL	SEEKR		;GET DATA BLOCK
	POP	H
	POP	D
	INX	D
	INX	D
	MOV	M,D
	DCX	H
	MOV	M,E		;UPDATE LINK PRT
	LHLD	BCAP		;GET BCA ADDR
	LXI	D,BCBD		;OFFSET TO DATA BUF
	DAD	D
	LXI	D,TBUF
	MVI	B,128
	CALL	MOVE		;COPY DATA TO BUF
	LHLD	BCAP		;GET BCA ADDR
	LXI	D,BCALC		;LINK COUNT
	DAD	D
	DCR	M		;DECREMENT
	RNZ			;OK, CONTINUE
	LHLD	BCAP		;GET BCA ADDR
	LXI	D,BCBL+2	;POINT TO LINK BUF
	DAD	D
	MOV	E,M		;GET LINK
	INX	H
	MOV	D,M
	DCX	H
	MOV	E,A
	ORA	D		;TEST FOR LINK
	JZ	GDBE		;END, ERROR
	XCHG			;DE = A(NEXT LINK)
	LHLD	BCAP		;BCA ADDR
	CALL	GLB		;GET LINK BLOCK
	RET

GDBE:	STC			;INDICATE EOF
	RET
;***************************************;
;
;         SEEKR:   SEEK DISK BLOCK
;
;         DE = A(LINK)
;
;***************************************;

SEEKR:	PUSH	D		;SAVE DE
	LDA	DRNUM		;THE REQD DRIVE
	MOV	C,A
	LXI	D,1		;WE'VE BEEN HERE BEFORE
	CALL	SDSK
	POP	D
	PUSH	D
	LDAX	D		;GET SECTOR
	MOV	C,A
	CALL	SSEC		;SET SECTOR
	POP	D
	PUSH	D
	INX	D
	LDAX	D		;GET TRACK
	MOV	C,A
	CALL	STRK
	CALL	READ		;READ BLOCK
	POP	D
	RET

;*****************************************;
;
;	FPRT:   PRINT FILE ID
;
;	HL = A(FILE ID)
;
;*****************************************;
FPRT:	MVI	B,9		;ID SIZE
FPRT2:	MOV	A,M		;GET BYTE
	CPI	00		;IF ZERO,SKIP
	JNZ	FPRT3
	MVI	A,' '
FPRT3:	MOV	E,A		;PUT IN E
	PUSH	H		;SAVE HL
	PUSH	B		;SAVE BC
	MVI	C,02		;WRITE CONSOLE
	CALL	CPM		;PRINT CHAR
	POP	B		;RESTORE BC
	POP	H		;RESTORE HL
	INX	H		;BUMP POINTER
	MOV	A,B
	CPI	04		;FILE TYPE?
	JNZ	FPRT4
	MVI	E,' '
	MVI	C,02
	PUSH	H
	PUSH	B
	CALL	CPM
	POP	B
	POP	H
FPRT4:	DCR	B
	JNZ	FPRT2
	lda	cols
	dcr	a
	jz	endcol
	sta	cols
	mvi	c,2
	mvi	e,' '
	call	cpm
	mvi	c,2
	mvi	e,' '
	call	cpm
	mvi	c,2
	mvi	e,' '
	call	cpm
	ret
endcol:
	mvi	a,4
	sta	cols
	MVI	C,02
	MVI	E,0DH
	CALL	CPM
	MVI	C,02
	MVI	E,0AH
	CALL	CPM
	RET
cols:	db	4

;*****************************************;
;
;       MOVE:   MOVE DATA
;
;	DE = A (SOURCE)
;	HL = A(DEST)
;	B = COUNT
;
;******************************************;

MOVE:	LDAX	D		;GET BYTE
	MOV	M,A		;STORE BYTE
	INX	H
	INX	D		;BUMP PTRS
	DCR	B		;DECREMENT COUNT
	JNZ	MOVE
	RET

;*******************************************;
;
;	CPM INTERFACE ROUTINES
;
;*******************************************;

VALID:	;CHECKS DPB TO SEE IF SS/SD FLOPPY AND EXIT IF NOT
	;HL = 0 IF NOT SELECTABLE ELSE DPH ADDR
	MOV	A,H
	ORA	L
	JZ	DONE		;GO TO CPM
	LXI	D,10
	DAD	D
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A		;HL -> DPB
	MOV	A,M
	CPI	26
	JNZ	DONE		;IF NOT 26 SPT
	INX	H
	MOV	A,M
	ORA	A
	JNZ	DONE		;HIGH BYTE OF SPT
	LXI	D,4
	DAD	D
	MOV	A,M
	CPI	242		;SINGLE DENSITY DSM
	JNZ	DONE
	RET			;PRETTY GOOD CHANCE IT'S OK NOW

SDSK:	LHLD	0001H		;GET BIOS ADDR
	MVI	L,1BH
	PCHL
SSEC:	LHLD	0001H
	MVI	L,21H
	IF	LOGICAL		;PASSED SECTOR IS INCREMENTED
	DCR	C		;IN THE BIOS - SO REDUCE IT HERE
	ENDIF			; BEFORE IT GETS 'CORRECTED'...
	PCHL
STRK:	LHLD	0001H
	MVI	L,1EH
	PCHL
READ:	LHLD	0001H
	MVI	L,27H
	PCHL
HOME:	LHLD	0001H
	MVI	L,18H
	PCHL

;******************************************;
;
;	BLOCK CONTROL AREA DEFINITIONS
;
;******************************************;

BCA	EQU	0
BCAL	EQU	0
BCALC	EQU	BCAL+2
BCBL	EQU	BCALC+1
BCBD	EQU	BCBL+128

;******************************************;
;
;		    DATA
;
;******************************************;
DRNUM:	DB	5			;OUT OF THE WAY
BMSG:	DB	'X: $'
MSG2:	DB	'I/O ERROR',0DH,0AH,'$'

DIRLNK:	DB	01,01
DENT:	DS	2
DCNT:	DS	1
BCNT:	DS	2
BCAP:	DS	2
	DS	64
STACK	EQU	$

DBCA:	DS	2
	DS	1
	DS	128
DBUF:	DS	128

FBCA:	DS	2
	DS	1
	DS	128
FBUF:	DS	128

TBUF	EQU	0080H
TFCB	EQU	005CH
CPM	EQU	0005H
BOOT	EQU	0000H
CREATE	EQU	22
WRITE	EQU	21
CLOSE	EQU	16
	END
