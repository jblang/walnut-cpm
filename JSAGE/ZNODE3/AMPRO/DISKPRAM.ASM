; DISKPRAM.ASM
; 
; 
; DISKPRAM intended use is to determine the the values of the DISK
; PARAMETER BLOCK and the SKEW TRANSLATION TABLE of a system alien
; to Ampro MULTIDSK program.  After the host system parameters are
; are determined ESET may be used to set up the E: drive on the 
; AMPRO system
;
; DISKPRAM displays the disk parameter block and the skew translation
; table maintained in the target cp/m 2.2 bios in any selected system
;
; DISKPRAM is the conbination of DPB.ASM and SKEW.ASM by 
; Robert C. Kuhman, Sysop of the Cro's Nest RCP/M. 
;
;****************************************************************
; Revisions:
;		V1.00 as of 27/10/84  Fred Willink
;****************************************************************
;
BOOT	EQU	0		;
BDOS	EQU	05H		;
FCB1	EQU	5CH		;
;
;  other equates
;
ACROSS	EQU	8
;
; ampro bios disk id save area
;
; ascii equates
;
BELL	EQU	07H		; bell
TAB	EQU	09H		; horz tab
LF	EQU	0AH		; line feed
CR	EQU	0DH		; carriage return
SPC	EQU	20H		; space
;
	ORG	100H
;
START:	LXI	H,0
	DAD	SP		; hl=ccp stack pointer
	LXI	SP,STACK	; set up local stack
	PUSH	H		; save the ccp pointer for return
TEST:	LDA	FCB1+1
	CPI	'/'
	JZ	HELP		; help
	CPI	'?'
	JZ	HELP
	CALL	DPB
	CALL	SKEW
	JMP	EXIT
;
HELP:	LXI	H,HLPMSG	; point to help message
	CALL	COSTR		; display help
;
; exit no warm boot
;
EXIT:	POP	H		; recover ccp"s stack ptr
	SPHL
	RET
;
DPB:	LDA	FCB1		; drive code given ?
	DCR	A		; convert a=1 to 0
	JP	DPB2
	CALL	FCN25
DPB2:	MOV	E,A		; save for select
	ADI	'A'		; make drive code printable
	STA	DRIVE
	CALL	FCN14
	CALL	FCN31
	PUSH	H		; save it for dump
;
	LXI	D,SPT		; make dph values printable
	CALL	CVT2
	LXI	D,BSH
	CALL	CVT1
	LXI	D,BLM
	CALL	CVT1
	LXI	D,EXM
	CALL	CVT1
	LXI	D,DSM
	CALL	CVT2
	LXI	D,DRM
	CALL	CVT2
	LXI	D,ALV0
	CALL	CVT1
	LXI	D,ALV1
	CALL	CVT1
	LXI	D,CKS
	CALL	CVT2
	LXI	D,OFF
	CALL	CVT2
;
	LXI	H,DSPLAY	; dph table
	CALL	COSTR		; print it all
	POP	H
	MVI	B,15
	CALL	HEXDMP		; print hexdump of dpb
	CALL	COCRLF
	CALL	COCRLF
	RET
;
SKEW:	MVI	A,ACROSS	; number of records to display across screen
	STA	NPRINT		; save
	LDA	FCB1		; see if drive was specified
	DCR	A		; test ff=no
	JP	REC2		; yes, select drive
	CALL	FCN25		; no, get current drive
REC2:	MOV	E,A
	MOV	C,A
	CALL	FCN14		; select drive
	CALL	FCN31		; get address of dph
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	SHLD	NRECS		; save dph address for records per track
	MVI	A,24		; offset for seldsk:
	CALL	BIOS		; hl=dph, de=xlate table
	MOV	E,M
	INX	H
	MOV	D,M		; de=dph
	PUSH	H
	PUSH	D
	PUSH	B
	XCHG			; dph in hl
	SHLD	DPHADR		; and save
	CALL	HEXADR		; display dph address
	LXI	H,DPH		; trailer message for address
	CALL	COSTR		; display
	POP	B
	POP	D
	POP	H
	MOV	A,E		; get low byte
	ORA	D		; or with high
	JNZ	REC3		; if zero no translate done
	LXI	H,NXLATE	; no translate message
	CALL	COSTR
	RET
;
REC3:	LXI	B,0		; clear record number
	XRA	A		; clear a
	STA	POSIT		; initialize counter
;
RECLOP:	MVI	A,45		; offset to sectran
	CALL	BIOS		; hl=xlate (bc)
	CALL	PRINT		; display results
	LHLD	NRECS		; 
	DCX	H
	MOV	A,L
	ORA	H
	JZ	SHOWD
	SHLD	NRECS
	INX	B
	JMP	RECLOP		; till through
;
SHOWD:	LXI	H,TBLMSG	; for skew table
	CALL	COSTR		; display
	MVI	A,20		; number of entries
	STA	POSIT		; set counter
	LHLD	DPHADR		; get dph address
	SHLD	LAST		; save it
	JMP	ENTRY
;
MORE:	LHLD	LAST		; get last position
	INX	H		; update and
	SHLD	LAST		; save it
ENTRY:	MOV	E,M		; get byte
	MVI	D,0		; zero d
	MOV	A,E		; value in a
	CPI	27		; largest value
	JNC	ZERFIL		;
	CPI	1		; start of table
	JZ	WHERE		; what position
	CPI	0		;
	JNZ	NOPE		; none of those
WHERE:	LDA	POSIT		; see where in table
	CPI	20		; first position of 20
	JNZ	ZERFIL		; see if need zeros
NOPE:	XCHG			; hl has value
	CALL	DECOUT		; print decimal value
	LDA	POSIT		; get count
	CPI	0		; see if done
	RZ			; yes, return
	MVI	A,','		; insert comma
	CALL	COUT
	CALL	COSPAC		; insert space
	LDA	POSIT		; see if done
	CPI	0
	JZ	ZERFIL		; fill remainder
NOTDON:	DCR	A		; count down
	STA	POSIT		; and save
	JMP	MORE
;
ZERFIL:	LDA	POSIT		; how many zero's
	CPI	0
	RZ			; done if zero
	DCR	A		; count down
	STA	POSIT		; and save
	MVI	A,'0'
	CALL	COUT		; print '0'
	LDA	POSIT
	CPI	0		; see if through now
	RZ
	MVI	A,','
	CALL	COUT		; print ','
	CALL	COSPAC		; print space
	JMP	ZERFIL
;
; convert binary in hl to ascii decimal
;
DECOUT:	MVI	B,0		; leading zero fill
	LXI	D,-100
	CALL	SUBTR		; hundreds
	LXI	D,-10
	CALL	SUBTR		; tens
	MOV	A,L
	ADI	'0'		; ascii bias
	JMP	COUT		; print and return to caller
;
; subtract powers of 10
;
SUBTR:	MVI	C,'0'-1		; ascii count
SUBT2:	INR	C
	DAD	D		; add neg number
	JC	SUBT2
;
; one to many add one back
;
	MOV	A,D		; complement
	CMA			; de
	MOV	D,A
	MOV	A,E
	CMA
	MOV	E,A
	INX	D
	DAD	D
	MOV	A,C		; get count
;
; check for zero
;
	CPI	'1'		; less than 1?
	JNC	NZERO		; no
	MOV	A,B		; check 0 flag
	ORA	A
	MOV	A,C		; restore
	RZ			; skip leading zero
	JMP	COUT		; print character
;
; set flag for non-zero character
;
NZERO:	MVI	B,0FFH		; set to zero
	JMP	COUT		; print
	RET
;
; print record entry
;
PRINT:	CALL	HEXADR		; print hl as hex words
	CALL	COSPAC		; insert space
	LDA	NPRINT		; see if end of line
	DCR	A
	STA	NPRINT		; update
	RNZ
	MVI	A,ACROSS	; how many lines across
	STA	NPRINT		; save
	CALL	COCRLF		; start new line
	RET
;
; select disk, 'e' has drive number
;
FCN14:	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,14
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET
;
; get current disk number, returns current disk in 'a'
;
FCN25:	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,25		; no drive given, get current disk
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET
;
; get disk parameters, returns 'hl'=dpb address
;
FCN31:	PUSH	B
	PUSH	D
	MVI	C,31		; hl = dpb for current disk
	CALL	BDOS
	POP	D
	POP	B
	RET
;
CVT2:	PUSH	H		; display 16 bit integer
	INX	H
	CALL	CVT1
	XTHL
	CALL	CVT1
	POP	H
	RET
;
CVT1:	MOV	A,M		; display byte at 'hl'
	INX	H
CVT1A:	CALL	HEXBYT		; a,c=ascii display
	STAX	D
	INX	D
	MOV	A,C
	STAX	D
	INX	D
	RET
;
; Subroutine to do an addressed dump of one line. HL point to data,
; 'B' has length
;
HEXDMP:	CALL	HEXADR		; display hl contents in hex
	MVI	A,':'
	CALL	COUT
	CALL	COSPAC
;
HEXLIN:	PUSH	B
	PUSH	H
HEXL2:	MOV	A,M
	CALL	COHEX		; display hl in hex
	CALL	COSPAC		; space
	INX	H
	DCR	B
	JNZ	HEXL2
	POP	H
	POP	B
	RET 
;
; Subroutine to print hl as an address in hex
;
HEXADR	MOV	A,H
	CALL	COHEX
	MOV	A,L
	CALL	COHEX
	RET
;
; print the hex byte in 'a'
;
COHEX:	PUSH	PSW		; save byte
	CALL	HEXLFT		; get left half
	CALL	COUT		; and print
	POP	PSW		; restore byte
	CALL	HEXRHT		; right half and
	CALL	COUT		; print
	RET
;
HEXLFT:	RAR			; make left nibble
	RAR
	RAR
	RAR
;
HEXRHT:	ANI	0FH		; make right nibble
	CPI	0AH
	JC	HEXLR
	ADI	'A'-3AH
;
HEXLR:	ADI	'0'
	RET
;
; suboutrine to return the hex value of 'a',
; least significant half in 'c', most significant in 'a'.
; used when ascii-hex is to be stored.
;
HEXBYT:	PUSH	PSW		; save
	CALL	HEXRHT		; get right nibble
	MOV	C,A		; save in c
	POP	PSW		; restore and get
	CALL	HEXLFT		; left nibble
	RET
;
; subroutine to write 'a' to console
;
COUT:	PUSH	B
	PUSH	D
	PUSH	H
	ANI	7FH		; strip bit 7
	MOV	E,A
	MVI	C,2		; cp/m fcn 2
	CALL	BDOS		; 
	POP	H
	POP	D
	POP	B
	RET
;
; print cr,lf to the console
;
COCRLF:	PUSH	PSW
	MVI	A,CR		; carriage return
	CALL	COUT		; print it
	MVI	A,LF		; line feed
	CALL	COUT		; and print it
	POP	A
	RET
;
; subroutine to write a space to the console
;
COSPAC:	PUSH	PSW
	MVI	A,SPC		; space
	CALL	COUT		; and print it
	POP	PSW
	RET
;
; subroutine to write bytes addressed by hl, terminated by last byte with
; 80 bit set.
;
COSTR	MOV	A,M		; get byte
	CALL	COUT		; print
	MOV	A,M		; again and test
	RLC			; for bit 7 set
	RC			; yes, return
	INX	H		; next byte
	JMP	COSTR		; and continue
;
; bios service, offset in 'a'
;
BIOS:	PUSH	B
	PUSH	D
	LHLD	BOOT+1		; get warm boot address
	ADD	L		; add offset to wboot
	MOV	L,A		; to address of service
	PUSH	H		; save it
	LXI	H,BIORET	; return address
	XTHL
	PCHL
;
BIORET:	POP	D
	POP	B
	RET
;
;  message strings
;
DSPLAY:	
	DB	'DPB table for drive '
DRIVE:	DS	1
	DB	':',CR,LF
	DB	'SPT:  '
SPT:	DS	4
	DB	'H',TAB,'Sectors per track.',cr,lf
	DB	'BSH:  '
BSH:	DS	2
	DB	'H',TAB,'Block shift.',cr,lf
	DB	'BLM:  '
BLM:	DS	2
	DB	'H',TAB,'Block mask.',cr,lf
	DB	'EXM:  '
EXM:	DS	2
	DB	'H',TAB,'Extent mask.',cr,lf
	DB	'DSM:  '
DSM:	DS	4
	DB	'H',TAB,'Disk size-1.',cr,lf
	DB	'DRM:  '
DRM:	DS	4
	DB	'H',TAB,'Directory entries-1.',cr,lf
	DB	'ASV0: '
ALV0:	DS	2
	DB	'H',TAB,'Directory group allocation 0.',cr,lf
	DB	'ALV1: '
ALV1:	DS	2
	DB	'H',TAB,'Directory group allocation 1.',cr,lf
	DB	'CKS:  '
CKS:	DS	4
	DB	'H',TAB,'Check size.',cr,lf
	DB	'OFF:  '
OFF:	DS	4
	DB	'H',TAB,'Offset (number of reserve tracks).',cr,lf,lf
;
DMPMSG:	DB	'"DPB address and hex dump of table."'
	DB	CR,LF+80H
;
NXLATE:	DB	BELL,'Diskette needs no translation.',cr,lf+80h
;
TBLMSG:	DB	'Skew table decimal values.',cr,lf+80h
;
DPH:	DB	': (DPH address)',CR,LF+80H
; User help
;
HLPMSG:	DB	'DISKPRAM.COM - <H E L P>',CR,LF,LF
	DB	'Syntax:',CR,LF
	DB	'A0>DISKPRAM <cr>    - DPB and SKEW table for defalt drive',CR,LF
	DB	'A0>DISKPRAM d:      - Tables for selected drive',CR,LF
	DB	'A0>DISKPRAM ? or /  - Displays this message',CR,LF
;
	DB	CR,LF,'This program is designed to provide the user with a tool'
	DB	CR,LF,'that is able to display the DPB and SKEW table of a CP/M'
	DB	CR,LF,'2.2 system.  This information can be used as the decimal'
	DB	CR,LF,'input for a program such as ESET.COM written for the AMPRO'
	DB	CR,LF,'system.  With ESET the AMPRO''s E: drive may be used to read'
	DB	CR,LF,'and write alien 5" diskette formats',CR,LF,LF+80H
;
NRECS:	DS	2
NPRINT:	DS	1
DPHADR:	DS	2
POSIT:	DS	1
LAST:	DS	2
;
	DS	30
STACK:	EQU	$
;
	END
