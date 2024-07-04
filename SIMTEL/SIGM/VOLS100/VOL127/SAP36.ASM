; v3.6 sort and pack cp/m disk directory - 04/27/83
;
; this program reads the disk directory tracks, sorts them alphabetically
; then replaces them on the disk.  all unused or erased areas on the dir-
; ectory track are reformatted with continuous 'e5' characters.  (this
; erases previous file names which have been deactivated.)  sorting the
; directory in this manner offers many advantages.  some of them are:
;
;	1)  allows 'dir' to show an alphabetized listing
;	2)  eliminates potential problems with "unerase" programs
;	3)  speeds up access via 'sd' and other special programs
;	4)  assists on working directly on the disk with 'duu', etc.
;	5)  removes files from the disk somebody else could recover
;
;				- notes by irv hoff w6ffc
;
; 04/27/83 eliminated unused equates in 'bios' jump table, shifted to end
;    3.6   of program, and changed a few calls to in-line to save code.
;	   'com' file now less than 1k.  fg
;
;   1977 - written by l. e. hughes.  modified extensively since by bruce
;	   ratoff, keith petersen, james prest, ron fowler, frank gaude',
;	   irv hoff, and likely others.
;
;=======================================================================
;
;
TRUE:	EQU	0FFH
FALSE:	EQU	0
;
BDOS:	EQU	5
BELL:	EQU	7
CR:	EQU	0DH
DPBLEN:	EQU	15		;size of cp/m2 disk parameter block
FCB:	EQU	5CH
GETDSK:	EQU	25		;bdos "get disk #" function
LF:	EQU	0AH
SELDRV: EQU	14		;select drive
VERNO:	EQU	12		;provides cp/m version number
;
	ORG	100H		;load address
;
GETVEC: LXI	D,WBOOT		;set up to copy 'bios' jump table
	LHLD	1		;jump table entry address
	MVI	B,53
	CALL	MOVE
;
;=======================================================================
;
;			program starts here
;
;=======================================================================
;
;
START:	POP	H		;get 'ccp' return..
	SHLD	EXIT1+1		;..if already sorted.
	LXI	SP,STACK
   	CALL	ILPRT
	DB	CR,LF,'SORT AND PACK DIRECTORY v3.6 04/27/83',CR,LF,0
	MVI	C,VERNO		;check for cp/m ver 2.0
	CALL	BDOS
	MOV	A,H		;hl = 0020h if cp/m ver 2.0
	ORA	A		;check for mpm
	JNZ	MPMYES		;exit if mpm, we can't use it
	ORA	L		;test for hl-pair = 0 --> cp/m ver 1.0
	STA	VERFLG
;
;
;=======================================================================
;
;			main program routine
;
;=======================================================================
;
;
SAP:	CALL	SETUP
	CALL	RDDIR		;read requested drive directory
	CALL	CLEAN
	CALL	SORT
	CALL	PACK
	CALL	WRDIR		;write back sap'd directory
	CALL	ILPRT		;rewritten directory..
	DB	'-- DONE',CR,LF,0
EXIT:	JMP	0000H		;..requires warm boot.
;.....
;
;
;=======================================================================
;
;			subroutines
;
;=======================================================================
;
;
CLEAN:	LXI	H,0		;i = 0
;
CLNLOP: SHLD	I
	CALL	INDEX		;hl = buf + 16 * i
	MOV	A,M		;jump if this is a deleted file
	CPI	0E5H
	JZ	FILL$E5
	LXI	D,12
	DAD	D		;hl = hl + 12
	MOV	A,M		;check extent field
	ORA	A
	JNZ	CLBUMP		;skip if not extent zero
	INX	H		;point to record count field
	INX	H
	MOV	A,M		;get s2 byte (extended rc)
	ANI	0FH		;  for cpm2, 0 for cpm1
	MOV	E,A
	INX	H
	MOV	A,M		;check record count field
	ORA	E
	JNZ	CLBUMP		;jump if non-zero
	LHLD	I		;clear all 32 bytes of
	CALL	INDEX		;  directory entry to e5
	INX	H
	MOV	A,M		;get first char of filename
	DCX	H		;  ward christensons cat pgms
	CPI	'-'		;  have diskname of zero length
	JZ	CLBUMP		;  that start with '-', don't delete
;
FILLE5: MVI	C,32		;number of bytes to clear
;
FILLOP: MVI	M,0E5H		;make it all e5's
	INX	H
	DCR	C
	JNZ	FILLOP
;
CLBUMP: LHLD	DRM		;get count of filenames
	INX	H
	XCHG
	LHLD	I		;our current count
	INX	H
	PUSH	H
	CALL	SUBDE		;subtract
	POP	H
	JC	CLNLOP		;loop till all cleaned
	RET
;.....
;
;
COMP:	LHLD	I		;hl = buf + 16 * i
	CALL	INDEX
	PUSH	H
	LHLD	J		;hl = buf + 16 * j
	CALL	INDEX
	XCHG
	POP	H
	MVI	C,13		;number of bytes to compare
;
COMP1:	MOV	A,M		;get next byte
	ANI	7FH		;remove attributes
	MOV	B,A		;save in b
	LDAX	D
	ANI	7FH		;remove attributes
	CMP	B		;compare character
	RNZ			;return if not equal
	INX	D
	INX	H
	DCR	C		;loop thru first 13 bytes
	JNZ	COMP1
	XRA	A		;clear flags and exit
	RET
;.....
;
;
; cp/m 1.4 routine
;
CPM14:	LHLD	BDOS+1
	MVI	L,0
	MVI	A,(JMP)
	STA	SECTRN
	PUSH	H
	LXI	D,15		;sectran offset from bdos in cpm 1.4
	DAD	D
	SHLD	SECTRN+1
	POP	H
	LXI	D,3AH		;offset from bdos to 1.4 dpb
	DAD	D
	MVI	D,0
	MOV	E,M
	INX	H
	XCHG
	SHLD	SPT
	XCHG
	MOV	E,M
	INX	H
	XCHG
	SHLD	DRM
	XCHG
	MOV	A,M
	INX	H
	STA	BSH
	MOV	A,M
	INX	H
	STA	BLM
	MOV	E,M
	INX	H
	XCHG
	SHLD	DSM
	XCHG
	MOV	E,M
	INX	H
	XCHG
	SHLD	AL0
	XCHG
	MOV	E,M
	XCHG
	SHLD	SYSTRK
	RET
;.....
;
;
; cp/m 2.2 routine
;
CPM22:	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	XCHG
	SHLD	SECTBL
	XCHG
	LXI	D,8		;offset to dpb within header
	DAD	D		;returned by seldsk in cpm2
	MOV	A,M		;get adrs of dpb
	INX	H
	MOV	H,M
	MOV	L,A
	LXI	D,DPB		;point to dest: our dpb
	MVI	B,DPBLEN
	CALL	MOVE
	RET
;.....
;
;
; track and sector update routines
;
DOTRAK: SHLD	TRACK
	MOV	B,H
	MOV	C,L
	CALL	SETTRK
	RET
DOSEC:	SHLD	SECTOR
	MOV	B,H
	MOV	C,L
	LHLD	SECTBL
	XCHG
	DCX	B
	CALL	SECTRN
	MOV	B,H
	MOV	C,L
	LDA	VERFLG
	ORA	A
	RZ
	CALL	SETSEC
	RET
;.....
;
;
; write
;
DWRT:	MVI	C,1		;for cpm/2 deblocking bios's
	CALL	WRITE
	ORA	A		;test flags on write
	JNZ	WERROR		;nz=bad directory write
	JMP	MORE
;.....
;
;
; cp/m ccp return address stored here
;
EXIT1:	JMP	0000H		;overwritten by 'start' for no dir change
;.....
;
;
; print a string (address is on top of stack)
;
ILPRT:	XTHL			;get adr from stack
	MOV	A,M		;get character
	INX	H		;point to next adr
	XTHL			;restore to stack
	ORA	A		;are we done?
	RZ			;yes, return past string
	PUSH	H		;in case cbios clubbers it
	MOV	C,A		;character to c for cp/m
	CALL	CO		;print character
	POP	H
	JMP	ILPRT		;continue
;.....
;
;
INDEX:	DAD	H
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	LXI	D,BUF
	DAD	D
	RET
;.....
;
;
; good read or write
;
MORE:	LHLD	ADDR		;bump dma adrs for next pass
	LXI	D,80H
	DAD	D
	SHLD	ADDR
	LHLD	DIRCNT		;countdown entries
	DCX	H
	SHLD	DIRCNT
	MOV	A,H		;test for zero left
	ORA	L
	JNZ	DIRLOP		;loop till zero
;
;
; directory i/o done -- reset dma address
;
	LXI	B,80H
	CALL	SETDMA
	RET
;.....
;
;
; move utility subroutine
;
MOVE:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	MOVE
	RET
;.....
;
;
; mpm not allowed with this program
;
MPMYES:	CALL	ILPRT
	DB	CR,LF,'++ SAP not useable with MPM ++',0
	JMP	EXIT
;.....
;
;
OKNOW:	CALL	ILPRT
	DB	'(previously sorted) -- DONE',CR,LF,0
	JMP	EXIT1
;.....
;
PACK:	CALL	ILPRT
	DB	'and packing, ',0
	LXI	H,0		;i = 0
;
PACK1:	SHLD	I
	CALL	INDEX		;hl = buf + 16 * i
	LXI	D,9
	DAD	D		;hl = hl + 9
	MOV	A,M		;jump if filetype not 'x$$'
	SUI	'0'		;  where 0.le.x.le.9
	JC	PACK2
	CPI	10
	JNC	PACK2
	STA	J
	INX	H
	MOV	A,M
	CPI	'$'
	JNZ	PACK2
	INX	H
	MOV	A,M
	CPI	'$'
	JNZ	PACK2
	INX	H		;set extent number to x
	LDA	J
	MOV	M,A
	DCX	H		;set filetype to '$$$'
	MVI	M,'$'
	DCX	H
	MVI	M,'$'
	DCX	H
	MVI	M,'$'
;
PACK2:	LHLD	I		;i = i + 1
	INX	H
	XCHG
	LHLD	DRM
	INX	H
	XCHG
	PUSH	H
	CALL	SUBDE
	POP	H		;loop until i > drm
	JC	PACK1
	RET
;.....
;
;
; read and write directory routines
;
RDDIR:	CALL	ILPRT
	DB	CR,LF,'---> Reading, ',0
	XRA	A
	JMP	DODIR
;.....
;
;
; come here if we get a read error
;
RERROR: CALL	ILPRT		;print:
	DB	'++ READ ERROR - Exiting to CP/M - NO CHANGE made'
	DB	CR,LF,0
	JMP	EXIT
;.....
;
;
; divide hl by 2
;
ROTRHL: ORA	A		;clear carry
	MOV	A,H
	RAR
	MOV	H,A
	MOV	A,L
	RAR
	MOV	L,A
	RET
;.....
;
;
; setup for selecting drive and loading disk parm block
;
SETUP:	LDA	FCB
	DCR	A
	JP	SETUP1		;exit if disk drive mentioned
	MVI	C,GETDSK	;otherwise get current default drive
	CALL	BDOS		;so query 'bdos' for drive
;
SETUP1:	MOV	C,A
	CALL	SELDSK
	LDA	VERFLG		;if cpm 1.4
	ORA	A
	JZ	CPM14		;if 1.4, then do it the 1.4 way
	JMP	CPM22		;must be 2.2 then since not mpm
;.....
;
;
; sort directory
;
SORT:	XRA	A
	STA	NOSWAP		;zero the flag in case already sorted
	CALL	ILPRT
	DB	'sorting ',0
	LXI	H,0		;i = 0
	
	SHLD	I
;
SORT1:	LHLD	I		;j = i + 1
	INX	H
	SHLD	J
;
SORT2:	CALL	COMP		;if name(j)<name(i), swap
	CC	SWAP
	LHLD	J		;j = j + 1
	INX	H
	SHLD	J
	XCHG
	LHLD	DRM
	INX	H
	XCHG
	PUSH	H
	CALL	SUBDE		;if j < drm goto sort2
	POP	H
	JC	SORT2
	LHLD	I		;i = i + 1
	INX	H
	SHLD	I
	XCHG
	LHLD	DRM
	XCHG
	CALL	SUBDE		;if i < drm goto sort1
	JC	SORT1
	RET
;.....
;
;
; utility subtraction subroutine -- hl = hl - de
;
SUBDE:	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	RET
;.....
;
;
SWAP:	MVI	A,1
	STA	NOSWAP		;swap used, a rewrite is needed
	LHLD	I
	CALL	INDEX
	PUSH	H
	LHLD	J
	CALL	INDEX
	XCHG
	POP	H
	MVI	C,32
;
SWAP1:	LDAX	D
	MOV	B,A
	MOV	A,M
	STAX	D
	MOV	M,B
	INX	D
	INX	H
	DCR	C
	JNZ	SWAP1
	RET
;.....
;
;
; come here if we get a write error
;
WERROR: CALL	ILPRT		;print:
	DB	'++ WRITE ERROR - Exiting to CP/M - directory left '
	DB	'in UNKNOWN condition ++',BELL,CR,LF,0
	JMP	EXIT
;.....
;
;
WRDIR:	LDA	NOSWAP		;see if rewrite unnecessary
	ORA	A
	JZ	OKNOW
	CALL	ILPRT
	DB	'writing ',0
	MVI	A,1
DODIR:	STA	WRFLAG
	LHLD	SYSTRK
	CALL	DOTRAK		;set the track
	LXI	H,0
	SHLD	SECTOR
	LHLD	DRM		;number of dir entries
	INX	H		;relative to 1
	CALL	ROTRHL		;divide by 4
	CALL	ROTRHL		;  to get sector count
	SHLD	DIRCNT
	LXI	H,BUF
	SHLD	ADDR		;for dma address
;
DIRLOP: LHLD	SECTOR		;get sectors per track
	INX	H
	XCHG
	LHLD	SPT		;current sector
	CALL	SUBDE		;  sector - spt
	XCHG
	JNC	NOTROV		;branch if track overflow
	LHLD	TRACK
	INX	H
	CALL	DOTRAK
	LXI	H,1		;rewind sector number
;
NOTROV: CALL	DOSEC		;set current sector
	LHLD	ADDR
	MOV	B,H		;set up dma address
	MOV	C,L
	CALL	SETDMA
	LDA	WRFLAG		;time to figure out
	ORA	A		;  if we are reading
	JNZ	DWRT		;  or writing
;
;
; read
;
	CALL	READ
	ORA	A		;test flags on read
	JNZ	RERROR		;nz=error
	JMP	MORE		;good read, go do more
;.....
;
;
; data area
;
ADDR:	DS	2
DIRCNT: DS	2
I:	DS	2
J:	DS	2
MAPPTR: DS	2
NOSWAP:	DS	1
SECTBL: DS	2
SECTOR: DS	2
TRACK:	DS	2
VERFLG: DS	1
WRFLAG: DS	1
;.....
;
;
; disk parameter block:
;
DPB:
SPT:	DS	2
BSH:	DS	1
BLM:	DS	1
EXM:	DS	1
DSM:	DS	2
DRM:	DS	2
AL0:	DS	1
AL1:	DS	1
CKS:	DS	2
SYSTRK: DS	2
;.....
;
;
; 'bios' jump table storage
;
VECTRS	DS	53		;room for jump vectors
WBOOT:	EQU	VECTRS+3
CO:	EQU	VECTRS+12
SELDSK:	EQU	VECTRS+27
SETTRK:	EQU	VECTRS+30
SETSEC:	EQU	VECTRS+33
SETDMA:	EQU	VECTRS+36
READ:	EQU	VECTRS+39
WRITE:	EQU	VECTRS+42
SECTRN:	EQU	VECTRS+48	;only in cp/m2
;.....
;
;
	DS	26		;stack never gets this deep
STACK:	DS	0
;
BUF:	EQU	($+255)/256*256	;start buffer on even page
;.....
;
;
	END
