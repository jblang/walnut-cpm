TOOLS.ARC	830214:1552 -- Greg Louis
>>> SYSEQU.MAC	820827:0928
>>> MATHEQU.MAC	820827:0928
>>> LINKEQU.MAC	820827:0928
>>> ACOMPR.MAC	820820:1707
>>> ADDA.MAC	820820:1709
>>> ADDAD.MAC	820820:1715
>>> ARGBUF.MAC	820820:1715
>>> BUFBLK.MAC	820820:1716
>>> CLOSE.MAC	820825:1543
>>> CONMSG.MAC	820825:1316
>>> CONPUT.MAC	820825:1655
>>> CRLF.MAC	820820:1716
>>> CRLFF.MAC	820820:1717
>>> CRLFMS.MAC	820820:1717
>>> CTODI.MAC	820830:1219
>>> CTOF.MAC	820820:1717
>>> CTOI.MAC	820820:1717
>>> DCMP.MAC	820820:1718
>>> DPL.MAC	820820:1718
>>> ERROR.MAC	820820:1718
>>> ESC.MAC	830214:1552
>>> EXIT.MAC	820820:1718
>>> FILL.MAC	820820:1718
>>> FILLBF.MAC	820820:1718
>>> FNB.MAC	820820:1718
>>> FNDBUF.MAC	820825:1521
>>> FTOC.MAC	820830:1542
>>> GETARG.MAC	820820:1719
>>> GETC.MAC	820820:1720
>>> GETCF.MAC	820820:1720
>>> GETLIN.MAC	820820:1720
>>> GETLNF.MAC	820902:1032
>>> GETWD.MAC	820820:1720
>>> HCTODI.MAC	820820:1723
>>> HCTOI.MAC	820820:1723
>>> HDCMP.MAC	820820:1723
>>> HLDDE.MAC	820820:1724
>>> HLMDE.MAC	820820:2333
>>> HLXDE.MAC	820820:2333
>>> INDEX.MAC	820821:0955
>>> INIT.MAC	820820:2333
>>> INPORT.MAC	820820:2333
>>> IPTBUF.MAC	820820:2335
>>> ISDIGD.MAC	820820:2335
>>> ISDIGH.MAC	820820:2335
>>> ITOC.MAC	820820:2335
>>> LENGTH.MAC  820927:1317
>>> LSTPUT.MAC	820825:1656
>>> MAKFCB.MAC	820823:1358
>>> MEMRY.MAC	820820:2336
>>> MOVEL.MAC	820820:2336
>>> MOVES.MAC	820820:2337
>>> MOVEU.MAC	820820:2345
>>> MPLD.MAC	820820:2346
>>> MPLS.MAC	820820:2347
>>> MPRD.MAC	820820:2352
>>> MPRS.MAC	820820:2354
>>> MPS0.MAC	820820:2354
>>> MPWAIT.MAC	820820:2354
>>> MTBUF.MAC	820820:2354
>>> NEGH.MAC	820820:2354
>>> OP32.MAC	820820:2354
>>> OPEN.MAC	820820:2355
>>> OUTPT.MAC	820820:2355
>>> PCSTR.MAC	820825:1740
>>> PCMSG.MAC	820825:1741
>>> PLMSG.MAC	820825:1742
>>> PLSTR.MAC	820825:1743
>>> PROMPT.MAC	820901:0957
>>> PUSHBF.MAC	820820:2355
>>> PUSHBK.MAC	820820:2356
>>> PUTC.MAC	820820:2356
>>> PUTCF.MAC	820820:2356
>>> PUTDCF.MAC	820825:1941
>>> PUTDEC.MAC	820825:1942
>>> PUTMSF.MAC	820825:1746
>>> PUTMSG.MAC	820825:1748
>>> PUTSTF.MAC	820825:1749
>>> PUTSTR.MAC	820825:1751
>>> RDCLK.MAC	820820:2356
>>> REMARK.MAC	820820:2356
>>> SELCMD.MAC	820820:2356
>>> SETBF.MAC	820820:2356
>>> SOUNDX.MAC	820820:2357
>>> SPXCH.MAC	820820:2357
>>> STDIO.MAC	820820:2357
>>> TABBER.MAC	820820:2357
>>> TABBRF.MAC	820820:2357
>>> TYPAHD.MAC	820901:1338
>>> UPCASE.MAC	820820:2357
*********************************************************
Insertion macro:
1QAI>>> IA9I.*13I-1LBCXIA@LV0UAS*-1MBGA@0LL
Deletion macro:
1QAUASA0LKUSA0LTLEUS>>>0L#K
Replacement macro:
1QAUASA0LKI*13IUSA0LTLEUS>>>0L#K
I>>> IA9I.*13I-1LBCXIA@LV0UAS*-1MBGKA@0LL
Extraction macro:
1QAUAS*USALTEUS>>>0L#XOA
Printout macro:
1QAUAS*USALIL8;R7213ITEUS>>>0L12QTF#XTF#V0-1K
*********************************************************
>>> SYSEQU.MAC	820827:0928
; General system equates for assembler programs
; 820819:1335
;
	.8080
; CP/M calls
BOOT	EQU	0	; warmboot vector
BDOS	EQU	5	; system call point
WBOOT	EQU	0	; system reset
RDKBD	EQU	1	; console input
PRTCHR	EQU	2	; console output
LSTCHR	EQU	5	; list dev output
DIRIO	EQU	6	; direct console i/o
RDIOB	EQU	7	; read the iobyte
SETIOB	EQU	8	; set the iobyte
PRTSTR	EQU	9	; string console out
RDSTR	EQU	10	; string console in
RDCST	EQU	11	; read console status
RDVERS	EQU	12	; get version number
RSTDSK	EQU	13	; reset disk system
SELDSK	EQU	14	; select disk
OPENF	EQU	15	; open file
CLOSEF	EQU	16	; close file
FND1ST	EQU	17	; find first entry
FNDNXT	EQU	18	; find next entry
ERASEF	EQU	19	; delete file
RDSEQ	EQU	20	; read file sequent.
WRTSEQ	EQU	21	; write file sequent.
MAKEF	EQU	22	; create file
RENAME	EQU	23	; rename file
RDDSK	EQU	25	; return current disk
SETDMA	EQU	26	; set DMA addr
SETFIL	EQU	30	; set file attributes
USER	EQU	32	; get/set user code
RDRND	EQU	33	; read random
WRTRND	EQU	34	; write random
RDSIZE	EQU	35	; compute file size
SETRND	EQU	36	; set random record
RSTDRV	EQU	37	; reset drive(s)
WRTZER	EQU	40	; write random 0 fill
;
; ASCII character set and video control
;
ENDSTR	EQU	0	; end-of-string
BEL	EQU	7	; bell
BKS	EQU	8	; backspace
TAB	EQU	9	; tab-by-8
LF	EQU	10	; linefeed
NEWLIN	EQU	LF
VT	EQU	11	; vertical tab
FF	EQU	12	; formfeed
CR	EQU	13	; return
CEOL	EQU	14	; clear-line
CEOS	EQU	15	; clear-scr
CAN	EQU	24	; cancel line
EOF	EQU	26	; end-of-file
ESCAPE	EQU	27
BLANK	EQU	32	; space
SQUOTE	EQU	39	; '
PLUS	EQU	43	; +
MINUS	EQU	45	; -
PERIOD	EQU	46	; .
DEL	EQU	127
; other printing chars go in ''s
;
; System limitations
;
MAXDRV	EQU	4	; Number of drives
MAXLIN	EQU	120	; Biggest line allowed
SECTRS	EQU	8	; Sectors to buffer per file
;
; Non-CP/M peripherals
;
; 8251
S0DAT	EQU	0	; 8251 data port
S0CMD	EQU	1	; 8251 cmd/stat port
S0BRG	EQU	4	; baud rate gen
S0XRDY	EQU	1	; TxRDY
S0RRDY	EQU	2	; RxRDY
S08NOP	EQU	4EH	; 8 bits, no parity
S07EVN	EQU	7AH	; 7 bits, even par
;
; SS1
SBAS	EQU	50H	; SS1 BASE PORT ADDR
IMAST0	EQU	SBAS	; Interrupt master low
IMAST1	EQU	SBAS+1	; Interrupt master hi
ISLV0	EQU	SBAS+2	; Interrupt slave low
ISLV1	EQU	SBAS+3	; Interrupt slave hi
TIMER0	EQU	SBAS+4	; Timer/counter 0
TIMER1	EQU	SBAS+5
TIMER2	EQU	SBAS+6
TIMCTL	EQU	SBAS+7	; Timer/counter ctrl
MDATA	EQU	SBAS+8	; Math chip data
MCMDS	EQU	SBAS+9	; Math command/status
CSTAT	EQU	SBAS+10	; Clock status
CDATA	EQU	SBAS+11	; Clock data
UDATA	EQU	SBAS+12	; UART data
USTAT	EQU	SBAS+13	; UART status
UMODE	EQU	SBAS+14	; UART mode
UCMD	EQU	SBAS+15	; UART command
MCDLY	EQU	4000H	; Math chip timeout
;
; Message macro
MSG	MACRO	TEXT
	.XLIST
	IRP	N,<TEXT>
	DB	N
	ENDM
	DB	ENDSTR
	.LIST
	ENDM
>>> MATHEQU.MAC	820827:0928
; Math-chip opcode equates and call structure
; 820818:1056
	.8080

	EXT	MPWAIT,OP32
MC	MACRO	OPCODE
	.XLIST
	MVI	A,OPCODE
	CALL	MPWAIT
	.LIST
	ENDM

; 	HL op DE -> HL, Math-chip operations
DMC	MACRO	OPCODE
	.XLIST
	MVI	A,D&OPCODE
	CALL	OP32
	.LIST
	ENDM

; OPCODES:		RESULTS (on stack A B C D)
ACOS	EQU	6	; (ACOS A) U U U
ASIN	EQU	5	; (ASIN A) U U U
ATAN	EQU	7	; (ATAN A) B U U
CHSF	EQU	15H	; -A B C D
COS	EQU	3	; (COS A) B U U
EXP	EQU	0AH	; (e^A) B U U
FADD	EQU	10H	; (A+B) C D U
FDIV	EQU	13H	; (B/A) C D U
FLTD	EQU	1CH	; A B C U
FLTS	EQU	1DH	; A B C U
FMUL	EQU	12H	; (A*B) C D U
FSUB	EQU	11H	; (B-A) C D U
LOG	EQU	8	; (LOG A) B U U
LN	EQU	9	; (LN A) B U U
POPF	EQU	18H	; B C D A
PTOF	EQU	17H	; A A B C
PUPI	EQU	1AH	; 3.14... A B C
PWR	EQU	0BH	; (B^A) C U U
SIN	EQU	2	; (SIN A) B U U
SQRT	EQU	1	; (SQRT A) B U U
XCHF	EQU	19H	; B A C D
CHSD	EQU	34H	; -A B C D
DADD	EQU	2CH	; (A+B) C D A
DDIV	EQU	2FH	; (B/A) C D U
DMUL	EQU	2EH	; (A*B) C D U
DMUU	EQU	36H	; (A*B) C D U (Up.32)
DSUB	EQU	2DH	; (B-A) C D A
FIXD	EQU	1EH	; A B C U
POPD	EQU	38H	; B C D A
PTOD	EQU	37H	; A A B C
XCHD	EQU	39H	; B A C D
CHSS	EQU	74H	; -AU AL BU BL CU CL DU DL
FIXS	EQU	1FH	; A BU BL CU CL U U U
POPS	EQU	78H	; AL BU BL CU CL DU DL AU
PTOS	EQU	77H	; AU AU AL BU BL CU CL DU
SADD	EQU	6CH	; (AU+AL) BU BL CU CL DU DL AU
SDIV	EQU	6FH	; (AL/AU) BU BL CU CL DU DL U
SMUL	EQU	6EH	; (AU*AL) BU BL CU CL DU DL U
SMUU	EQU	76H	; (AU*AL) etc as above - up.16
SSUB	EQU	6DH	; (AL-AU) BU BL CU CL DU DL AU
XCHS	EQU	79H	; AL AU BU BL CU CL DU DL
MNOP	EQU	0	; AU AL BU BL CU CL DU DL
;
>>> LINKEQU.MAC	820827:0928
; FILE:	LINKEQU.MAC
; DATE:	820819:2255
; FOR:	Determining compilation of $MEMRY
LYNX	EQU	0FFFFH	; Lynx linker, use 108H
>>> ACOMPR.MAC	820820:1707
; FILE:	ACOMPR.MAC
; DATE:	820819:2149
; FOR:	See comment
	.8080
; Routine ACOMPR does lexical comparison
; between strings pointed to by HL & DE
; for length in register C, returning
; Z set if equal, C set if the DE string
; is less than the HL string, and both
; clear if the DE string is greater than
; the HL string.  Register A is preserved.
ACOMPR:: PUSH	H
	PUSH	D
	PUSH	B
	MOV	B,A
COMPLP:	LDAX	D
	CMP	M
	JNZ	COMPEX
	INX	H
	INX	D
	DCR	C
	JNZ	COMPLP
COMPEX:	MOV	A,B
	POP	B
	POP	D
	POP	H
	RET
	END
>>> ADDA.MAC	820820:1709
; FILE:	ADDA.MAC
; DATE: 820818:1310
; FOR:	A + HL -> HL

	TITLE	ADDA - A + HL -> HL
	.8080
ADDA::	ADD	L
	MOV	L,A
	RNC
	INR	H
	RET
	END
>>> ADDAD.MAC	820820:1715
; FILE:	ADDAD.MAC
; DATE: 820818:1312
; FOR:	Add A to 32-bit number on 9511 stack

	TITLE	ADDAD - Add A to 9511 D number
	.8080
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	MPLS,MPS0
ADDAD::	PUSH	H
	MOV	L,A
	MVI	H,0
	CALL	MPLS
	CALL	MPS0
	POP	H
	MC	DADD
	RET
	END
>>> ARGBUF.MAC	820820:1715
; FILE:	ARGBUF.MAC
; DATE:	820819:1532
; FOR:	Command-line buffer
	.8080
	CSEG
ARGBUF:: DS	100
NARGS::	DS	1
	DB	0
	END
>>> BUFBLK.MAC	820820:1716
; FILE:	BUFBLK.MAC
; DATE:	820819:1211
; FOR:	Channel allocation and buffer defs.
	.8080
	CSEG
CHANLS:: REPT	16
	DW	0
	ENDM
BUFBLS::
	REPT	15
	DW	0	;; End of buffer
	DS	2	;; Buffer pointer (-len to 0)
	DS	2	;; Buffer size (-len)
	DS	2	;; FCB address
	DB	0FFH	;; Buffer size in sectors
	DS	1	;; Read-write flag (w=0ffh)
	ENDM
	END
>>> CLOSE.MAC	820825:1543
; FILE:	CLOSE.MAC
; DATE:	820825:1538
; FOR:	Close file and free channel C

	TITLE	CLOSE - close and free channel
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	FNDBUF,NEGH,SETBF,MTBUF
	EXT	ADDA,CHANLS,ERROR
CLOSE::	PUSH	H
	PUSH	D
	PUSH	B
	MOV	A,C
	ANI	15
	JZ	CLOSED
	CALL	FNDBUF
	STA	RWFLG
	MOV	A,H
	ORA	L
	JZ	CLOSED
	LDA	RWFLG
	INR	A
	JNZ	RLEASE
	PUSH	H
	INX	H
	INX	H	; Bufptr
	MOV	E,M
	INX	H	; +1
	MOV	D,M
	XCHG
	CALL	NEGH	; Space left
	XCHG
	MOV	A,E
	ORA	A
	RAL
	MOV	A,D
	RAL		; Sectors left
	INX	H	; Buflen
	PUSH	H	; Save for SETBF
	INX	H
	INX	H
	INX	H
	INX	H
	SUB	M	; Sectors in buffer
	POP	H	; Buflen
	CMA
	INR	A	; Sectors to write
	JZ	READY
	PUSH	PSW
	CALL	SETBF
	POP	PSW
	MOV	C,A
	CALL	MTBUF
READY:	POP	H
	PUSH	H
	MVI	A,6
	CALL	ADDA
	MOV	E,M
	INX	H
	MOV	D,M	; FCB
	MVI	C,CLOSEF
	CALL	BDOS
	INR	A	; 0 if failure to close
	JNZ	RLEASE-1
	CALL	ERROR
	MSG	<'CLOSE: Directory entry gone!'>
	POP	H
RLEASE:	MVI	M,0
	INX	H
	MVI	M,0
	POP	B
	PUSH	B
	MOV	A,C
	ADD	A
	LXI	H,CHANLS
	CALL	ADDA
	MVI	M,0
	INX	H
	MVI	M,0
CLOSED:	POP	B
	MOV	A,C
	ORA	A
	POP	D
	POP	H
	RET
RWFLG:	DS	1
	END
>>> CONMSG.MAC	820825:1316
; FILE:	CONMSG.MAC
; DATE: 820825:1312
; FOR:	Print string in <HL> with ENDSTR delim

	TITLE	CONMSG - Put string on CON:
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
CONMSG:: PUSH	D	; Save all but HL
	PUSH	B	; ..which will point
	PUSH	PSW	; ..past the ENDSTR
CM0:	MOV	A,M	; ..on exit.
	INX	H
	CPI	ENDSTR
	JZ	MSGEND
	PUSH	H
	MOV	E,A
	MVI	C,PRTCHR
	CALL	BDOS
	POP	H
	JMP	CM0
MSGEND:	POP	PSW
	POP	B
	POP	D
	RET
	END
>>> CONPUT.MAC	820825:1655
; FILE:	CONPUT.MAC
; DATE:	820825:1646
; FOR:	Put single char on CON: via PUTCF
	.8080
	TITLE	CONPUT - Put char on CON:
	EXT	PUTCF
CONPUT:: PUSH	B
	MVI	C,0
	CALL	PUTCF
	POP	B
	RET
	END
>>> CRLF.MAC	820820:1716
; FILE:	CRLF.MAC
; DATE: 820820:1352
; FOR:	Write CRLF to std output

	TITLE	CRLF - Write CRLF - std output
	.8080
	EXT	STDOUT,CRLFF
CRLF::	PUSH	B
	MOV	B,A
	LDA	STDOUT
	MOV	C,A
	CALL	CRLFF
	MOV	A,B
	POP	B
	RET
	END
>>> CRLFF.MAC	820820:1717
; FILE:	CRLFF.MAC
; DATE: 820820:1505
; FOR:	Write CR then LF to channel C

	TITLE	CRLFF - CRLF to channel C
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	PUTCF
CRLFF::	PUSH	PSW
	MVI	A,CR
	CALL	PUTCF
	MVI	A,LF
	CALL	PUTCF
	POP	PSW
	RET
	END
>>> CRLFMS.MAC	820820:1717
; FILE:	CRLFMS.MAC
; DATE: 820818:1350
; FOR:	CRLF string

	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	CSEG
CRLFMS::
	MSG	<CR,LF>
	END
>>> CTODI.MAC	820830:1219
; FILE:	CTODI.MAC
; DATE: 820818:1213
; MOD:	820820:1612	; Complete externals
; FOR:	Convert string at <HL> to 32bit in <DE>

	TITLE	CTODI - Convert chars to 32bit
	.8080
	.COMMENT "
This routine returns a 32-bit integer in
<DE> to <DE+3> and advances HL to point to
the first non-digit character in the string,
which serves as the terminator and is returned
in A.
"
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	ADDA,NEGH,ISDIGD,FNB
	EXT	MPLS,MPS0,MPRD,DPL
CTODI::	PUSH	B
	MOV	B,H
	MOV	C,L
	MVI	A,0FFH
	STA	DPL
	CALL	FNB
	LXI	H,0
	CPI	MINUS
	JNZ	CT0
	DCX	H
	JMP	CT1
CT0:	CPI	PLUS
	JNZ	CT2
CT1:	INX	B
	LDAX	B
CT2:	PUSH	H
	CALL	MPS0
	CALL	MPS0
CT3:	CALL	ISDIGD
	JC	CT4
	PUSH	PSW
	LXI	H,10
	CALL	MPLS
	CALL	MPS0
	MC	DMUL
	POP	PSW
	MOV	L,A
	MVI	H,0
	CALL	MPLS
	CALL	MPS0
	MC	DADD
	LDA	DPL
	ORA	A
	JM	CT3A
	INR	A
	STA	DPL
CT3A:	INX	B
	LDAX	B
	JMP	CT3
CT4:	CPI	PERIOD
	JNZ	CT5
	LDA	DPL
	ORA	A
	JP	CT5
	INR	A
	STA	DPL
	JMP	CT3A
CT5:	POP	H
	MOV	A,H
	ORA	L
	JZ	CT6
	MC	CHSD
CT6:	XCHG
	CALL	MPRD
	XCHG
	MOV	H,B
	MOV	L,C
	LDA	DPL
	ORA	A
	JP	CT7
	INR	A
	STA	DPL
CT7:	MOV	A,M
	POP	B
	RET
	END
>>> CTOF.MAC	820820:1717
; FILE:	CTOF.MAC
; DATE: 820818:1353
; FOR:	Convert string at <HL> to floating

	TITLE	CTOF - Convert chars to float
	.8080
	.COMMENT "
This routine returns a floating point number
on the 9511 stack and advances HL to point to
the first non-digit character in the string,
which serves as the terminator and is returned
in A.
"
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	CTODI,CTOI,ERROR
	EXT	MPLS,MPS0,MPLD,DPL
CTOF::	PUSH	D
	LXI	D,MANTIS
	CALL	CTODI
	ORI	20H	; force lower case
	CPI	'e'
	LDA	DPL
	STA	EXPOFF
	LXI	D,0
	JNZ	NOEXP
	INX	H
	CALL	CTOI	; exponent in DE
NOEXP:	PUSH	H
	LXI	H,10	; Base
	CALL	MPLS
	MC	FLTS
	LXI	H,EXPOFF
	MOV	A,E	; Subtract offset
	SUB	M
	MOV	E,A
	JNC	$+4
	DCR	D
	XCHG
	CALL	MPLS
	MC	FLTS
	MC	PWR	; Base^exponent
	ANI	1EH	; All 4 error flags
	JZ	CTF0	; If no errors
	CPI	8	; Only over/under?
	JC	CTF1	; if over/under error
	CALL	ERROR
	MSG	<'CTOF: Exponent out of range'>
CTF0:	LXI	H,MANTIS
	CALL	MPLD
	MC	FLTD
	ANI	2
	JNZ	CTF2	; Overflow error
	MC	FMUL
	ANI	6
	JZ	CTF3
CTF1:	ANI	2
	JNZ	CTF2	; Overflow error
	MC	POPF	; Junk exp or result
	CALL	MPS0
	CALL	MPS0	; Load 0
	JMP	CTF3
CTF2:	CALL	ERROR
	MSG	<'CTOF: Floating-point overflow'>
CTF3:	POP	H
	POP	D
	MOV	A,M
	RET
MANTIS:	DS	4
EXPOFF:	DS	1
	END
>>> CTOI.MAC	820820:1717
; FILE:	CTOI.MAC
; DATE: 820818:1137
; MOD:	820820:1616	; Complete externals
; FOR:	Convert string at <HL> to 16bit in DE

	TITLE	CTOI - Convert chars to 16bit
	.8080
	.COMMENT "
This routine returns a sixteen-bit integer in
DE and advances HL to point to the first
non-digit character in the string, which
serves as the terminator and is returned in A.
"
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	ADDA,NEGH,ISDIGD,FNB
CTOI::	PUSH	B
	MOV	B,H
	MOV	C,L
	CALL	FNB
	LXI	H,0
	CPI	MINUS
	JNZ	CT0
	DCX	H
	JMP	CT1
CT0:	CPI	PLUS
	JNZ	CT2
CT1:	INX	B
	LDAX	B
CT2:	PUSH	H
	LXI	H,0
CT3:	CALL	ISDIGD
	JC	CT4
	MOV	E,L
	MOV	D,H
	DAD	H
	DAD	H
	DAD	D
	DAD	H
	CALL	ADDA
	INX	B
	LDAX	B
	JMP	CT3
CT4:	POP	D
	MOV	A,D
	ORA	E
	CNZ	NEGH
	XCHG
	MOV	H,B
	MOV	L,C
	MOV	A,M
	POP	B
	RET
	END
>>> DCMP.MAC	820820:1718
; FILE:	DCMP.MAC
; DATE: 820818:1449
; FOR:	Compare two 32-bit nos in memory

	TITLE	DCMP - compare 32-bit integers
	.8080
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	MPLD
DCMP::	CALL	MPLD
	XCHG
	CALL	MPLD
	XCHG
	MC	DSUB
	RET
	END
>>> DPL.MAC	820820:1718
; FILE:	DPL.MAC
; DATE:	820818:1248
; FOR:	Decimal-place counter
	.8080
	CSEG
DPL::	DS	1
	END
>>> ERROR.MAC	820820:1718
; FILE:	ERROR.MAC
; DATE: 820818:1347
; MOD:	820820:1618	; Read definition file
; FOR:	Print inline string and quit

	TITLE	ERROR - Complain and quit
	.8080
	.XLIST
	INCLUDE	SYSEQU
	.LIST
	EXT	CONMSG,CRLFMS
ERROR::	LXI	H,CRLFMS
	CALL	CONMSG
	POP	H
	CALL	CONMSG
	JMP	BOOT
	END
>>> ESC.MAC	820820:1718
; FILE:	ESC.MAC
; DATE: 830214:1553
; FOR:	Interpret @ escape char

	TITLE	ESC - get char, interpret @
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	ISDIGD,HCTOI
ESC::	LDA	ESCSW
	CPI	CR
	JNZ	ESC0
	XRA	A
	STA	ESCSW
	MVI	A,LF
	RET
ESC0:	MOV	A,M
	INX	H
	CPI	'@'
	RNZ
	MOV	A,M
	CPI	ENDSTR
	JNZ	ESC00
	MVI	A,'@'
	RET
ESC00:	CPI	'n'
	JZ	ESC02
ESC01:	CPI	'N'
	JNZ	ESC1
ESC02:	MVI	A,CR
	STA	ESCSW
	INX	H
	RET
ESC1:	PUSH	H
	PUSH	B
	LXI	H,ESCTBL
	MVI	C,ESCLEN
ESC11:	CMP	M
	INX	H
	JZ	ESC12
	INX	H
	DCR	C
	JNZ	ESC11
	POP	B
	POP	H
	JMP	ESC2
ESC12:	MOV	A,M
	POP	B
	POP	H
	INX	H
	RET
ESC2:	CALL	ISDIGD
	JC	ESC3
	PUSH	D
	CALL	HCTOI
	MOV	A,E
	POP	D
	RET
ESC3:	MOV	A,M
	INX	H
	RET
ESCSW:	DB	0
ESCTBL:	DB	'T',9
	DB	't',9
	DB	'L',10
	DB	'l',10
	DB	'F',12
	DB	'f',12
	DB	'R',13
	DB	'r',13
ESCLEN	EQU	($-ESCTBL) SHR 1
	END
>>> EXIT.MAC	820820:1718
; FILE:	EXIT.MAC
; DATE: 820819:1550
; FOR:	Close all channels & quit

	TITLE	EXIT - Close channels & stop
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	CLOSE
EXIT::	MVI	C,15
	CALL	CLOSE
	DCR	C
	JNZ	EXIT+2
	JMP	BOOT
	END
>>> FILL.MAC	820820:1718
; FILE:	FILL.MAC
; DATE: 820818:1326
; FOR:	Fill BC bytes from <HL> with A

	TITLE	FILL - <HL> ff with BC of A
	.8080
FILL::	PUSH	D	; E is preserved
	MOV	E,A	; Save A
ML0:	MOV	A,B	; While count <> 0
	ORA	C
	JZ	ML1	; ..do begin
	MOV	M,E	; fill 1 byte
	INX	H	; next to fill
	DCX	B	; count down
	JMP	ML0	; end do
ML1:	MOV	A,E
	POP	D
	RET
	END
>>> FILLBF.MAC	820820:1718
; FILE:	FILLBF.MAC
; DATE: 820818:2055
; FOR:	Read C secs into <HL>, fcb = <DE>

	TITLE	FILLBF - Fill disk buffer
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	ADDA,FILL
FILLBF:: PUSH	B
	PUSH	H
	PUSH	D
	XCHG
	MVI	C,SETDMA
	CALL	BDOS
	POP	D
	PUSH	D
	MVI	C,RDSEQ
	CALL	BDOS
	ORA	A
	POP	D
	POP	H
	POP	B
	JNZ	EOFL
	DCR	C
	RZ
	MVI	A,80H
	CALL	ADDA
	JMP	FILLBF
EOFL:	MOV	A,C	; Nsecs left
	ORA	A	; Clear C
	RAR		; Div 2
	MOV	B,A	; Mod 256
	MVI	A,0	; Get rem
	RAR		; Mul 256
	MOV	C,A	; =Bytes to fill
	MVI	A,EOF
	CALL	FILL
	RET
	END
>>> FNB.MAC	820820:1718
; FILE:	FNB.MAC
; DATE: 820818:1115
; FOR:	Find next blank or tab in string <BC>

	TITLE	FNB - Find next blank or tab
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
FNB::	LDAX	B
	CPI	BLANK
	JZ	FNB0
	CPI	TAB
	JZ	FNB0
	CPI	ENDSTR
	RNZ
FNB0:	INX	B
	JMP	FNB
	END
>>> FNDBUF.MAC	820825:1521
; FILE:	FNDBUF.MAC
; DATE: 820825:1514
; FOR:	Find buffer for channel C

	TITLE	FNDBUF - Find channel C buffer
	.8080
	EXT	CHANLS,ADDA
FNDBUF:: LDA	LSTRD	; Check if current
	CMP	C
	JNZ	FND0
	LHLD	IBUF	; Buffer block addr
	XRA	A	; Input file
	RET
FND0:	LDA	LSTWR
	CMP	C
	JNZ	FND1
	LHLD	OBUF
	XRA	A
	DCR	A	; Output file
	RET
FND1:	LXI	H,CHANLS ; Find buffer block
	MOV	A,C	;  ..in channel table
	ADD	A
	CALL	ADDA
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	ORA	H	; Was channel free?
	RZ		; ..if so, quit
	PUSH	H	; Save block addr
	MVI	A,9
	CALL	ADDA	
	MOV	A,M	; Read/write flag
	POP	H
	PUSH	PSW
	INR	A
	MOV	A,C	; Channel no.
	JZ	FND2
	STA	LSTRD	; Make it current
	SHLD	IBUF	; Save block addr
	JMP	FND3
FND2:	STA	LSTWR	; Current output
	SHLD	OBUF	; Save block addr
FND3:	POP	PSW	; R/W flag
	RET
LSTRD:	DB	0
IBUF:	DW	0
LSTWR:	DB	0
OBUF:	DW	0
	END
>>> FTOC.MAC	820830:1542
; FILE:	FTOC.MAC
; DATE: 820830:1342
; FOR:	Convert floating to buffered string;
;	return addr in HL, length in A

	TITLE	FTOC - Convert floating to string
	.8080
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	MPLS,MPRS,MPRD,DPL
	EXT	ITOC,DITOC,ADDA,MOVES
	EXT	ERROR,MSTAT,HLMDE
FTOC::	PUSH	D
	PUSH	B
	MC	XCHF
	MC	XCHF	; Set flags
	ANI	22H
	JZ	FTC1
	PUSH	PSW
; Top of stack is 0
ZERO:	POP	PSW
	MC	POPF	; Discard
	LXI	H,BUFFER
	MVI	M,ENDSTR
	DCX	H
	LDA	FPL
	ADI	3
FTC0:	MVI	M,BLANK
	DCX	H
	DCR	A
	JNZ	FTC0
	MVI	M,'0'
	DCX	H
	MVI	M,PERIOD
	DCX	H
	MVI	M,'0'
	DCX	H
	MVI	M,BLANK
	JMP	FTC8
FTC1:	LDA	MSTAT
	ANI	40H
	PUSH	PSW
	JZ	FTC2
	MC	CHSF
FTC2:	MC	PTOF
	MC	LOG
	ANI	40H
	PUSH	PSW
	MC	FIXS
	CALL	MPRS
	POP	PSW
	JZ	FTC2A
	DCX	H
	MOV	A,L
	CPI	0F9H
	JC	ZERO
FTC2A:	PUSH	H	; Exponent
	XCHG
	LXI	H,6
	CALL	HLMDE
	XCHG
	LXI	H,10
	CALL	MPLS
	MC	FLTS
	XCHG
	CALL	MPLS
	MC	FLTS
	MC	PWR
	MC	FMUL
	ANI	6
	JZ	FTC3
	CALL	ERROR
	MSG	<'FTOC: Unable to scale'>
FTC3:	MC	PTOF	; Check current exp.
	MC	LOG
	MC	FIXS
	CALL	MPRS
	LXI	D,-6
	DAD	D
	POP	D
	DAD	D
	PUSH	H	; Exponent
	MC	FIXD
	LXI	H,MANTIS
	CALL	MPRD
	XCHG
	MVI	A,0FFH
	STA	DPL
	CALL	DITOC
	DCX	H
	MVI	M,'0'
	INX	H
	XCHG
	LXI	H,FPL
	MOV	B,M
	INR	B
	INR	B
	CMP	B
	JC	NORND
	MOV	H,D
	MOV	L,E
	MOV	A,B
	DCR	A
	CALL	ADDA
	MOV	A,M
	CPI	'5'
	JC	RNDED
FTC4:	DCX	H
	INR	M
	DCR	B
	MOV	A,M
	CPI	'9'+1
	JC	FTC5
	MVI	M,'0'
	JMP	FTC4
FTC5:	MOV	A,B
	ORA	A
RNDED:	JNZ	FTC6
	POP	H
	INX	H
	PUSH	H
	DCX	D
	JMP	FTC6
NORND:	DCR	B
	SUB	B
	MOV	L,A
	MVI	H,0
	JZ	$+4
	DCR	H
	DAD	D
	XCHG
	PUSH	D
	MVI	C,ENDSTR
	MOV	B,A
	PUSH	B
	CALL	MOVES
	POP	B
	DCX	D
	XCHG
	MOV	A,B
	ORA	A
	JZ	FTC6-1
FL:	MVI	M,'0'
	INX	H
	DCR	A
	JNZ	FL
	POP	D
FTC6:	XCHG
	LDA	FPL
	CALL	ADDA
	LXI	D,BUFFER-5
	LDA	FPL
	MOV	C,A
FTC7:	MOV	A,M
	STAX	D
	DCX	H
	DCX	D
	DCR	C
	JNZ	FTC7
	MVI	A,PERIOD
	STAX	D
	DCX	D
	MOV	A,M
	STAX	D
	DCX	D
	XCHG
	POP	D
	PUSH	H
	CALL	ITOC
	MOV	B,A
	MOV	A,M
	CPI	'-'
	JZ	$+4
	DCX	H
	MOV	C,A
	MOV	A,B
EXP0:	CPI	3
	JNC	EXP1
	MVI	M,'0'
	DCX	H
	INR	A
	JMP	EXP0
EXP1:	MOV	A,C
	CPI	'-'
	JNZ	EXP2
	MOV	M,A
	DCX	H
EXP2:	MVI	M,'e'
	LXI	D,BUFFER-4
	MVI	C,ENDSTR
	CALL	MOVES
	POP	H
	MVI	M,BLANK
	POP	PSW
	JZ	FTC8
	MVI	M,MINUS
FTC8:	LDA	FPL
	ADI	7
	POP	B
	POP	D
	RET
FPL::	DB	3	; Default=sn.nnnesnn
MANTIS:	DS	4	; Conversion buffer
	DS	20
BUFFER	EQU	$-1
	END
>>> GETARG.MAC	820820:1719
; FILE:	GETARG.MAC
; DATE: 820819:1533
; FOR:	Return argument # A

	TITLE	GETARG - Return argument #A
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	NARGS, ARGBUF
GETARG:: ORA	A
	JZ	NULL
	LXI	H,NARGS
	CMP	M
	JZ	$+6
	JNC	NULL
	PUSH	B
	MOV	C,A
	LXI	H,ARGBUF
	XRA	A
GTARG0:	DCR	C
	JZ	GTARG2
GTARG1:	CMP	M
	INX	H
	JNZ	GTARG1
	JMP	GTARG0
NULL:	LXI	H,NULBUF
GTARG2:	POP	B
	RET
NULBUF:	DB	ENDSTR
	END
>>> GETC.MAC	820820:1720
; FILE:	GETC.MAC
; DATE: 820820:1352
; FOR:	Get char from std input

	TITLE	GETC - get char from std input
	.8080
	EXT	STDIN,GETCF
GETC::	PUSH	B
	LDA	STDIN
	MOV	C,A
	CALL	GETCF
	POP	B
	RET
	END
>>> GETCF.MAC	820820:1720
; FILE:	GETCF.MAC
; DATE: 820819:1250
; MOD:	820820:1629	; Complete externals
; FOR:	Read 1 char from channel C into A

	TITLE	GETCF - Get char from file
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	FNDBUF,ERROR,SETBF,FILLBF
	EXT	ADDA
GETCF::	PUSH	H
	PUSH	D
	PUSH	B
	MOV	A,C
	ANI	15
	JZ	CONIN
	CALL	FNDBUF
	INR	A
	JNZ	GCF0
	CALL	ERROR
	MSG	<'GETCF: Reading from output file'>
GCF0:	MOV	E,M
	INX	H
	MOV	D,M
	CALL	PBCHEK
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
	XCHG
	DAD	B
	MOV	A,M
	PUSH	PSW
	XCHG
	INX	B
	MOV	A,B
	ORA	C
	JNZ	GCF1
; If we fall through here, buffer is used up
	INX	H
	CALL	SETBF
	CALL	FILLBF
	JMP	GCF2
GCF1:	MOV	M,B
	DCX	H
	MOV	M,C
GCF2:	POP	PSW
	JMP	GCF3
CONIN:	LXI	D,CONBUF
	CALL	PBCHEK
	MVI	E,0FFH
	MVI	C,6
	CALL	5
	ORA	A
	JZ	CONIN+6
GCF3:	POP	B
	POP	D
	POP	H
	RET
PBCHEK:	LDAX	D	; Buffer counter
	ORA	A	; Empty?
	RZ		; If so
	POP	H	; Not going back, so
	XCHG		; ..discard RET addr
	DCR	M	; One fewer char left
	CALL	ADDA	; Get the char
	MOV	A,M
	POP	B
	POP	D
	POP	H
	RET		; To fn calling GETCF
CONBUF:: DB	0
	DS	91
	END
>>> GETLIN.MAC	820820:1720
; FILE:	GETLIN.MAC
; DATE: 820820:1458
; FOR:	Get line from std input

	TITLE	GETLIN - get line - std input
	.8080
	EXT	STDIN,GETLNF
GETLIN:: PUSH	B
	LDA	STDIN
	MOV	C,A
	CALL	GETLNF
	POP	B
	RET
	END
>>> GETLNF.MAC	820902:1032
; FILE:	GETLNF.MAC
; DATE: 820901:2207
; FOR:	Get line from channel C
;	return addr in HL, length in A

	TITLE	GETLNF - Read in line
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	GETCF,IPTBUF,PUSHBF
GETLNF:: PUSH	B
	MVI	B,MAXLIN
	LXI	H,IPTBUF
	XRA	A
GLF0:	CPI	EOF
	JZ	ENDIN
	CALL	GETCF
	CPI	NEWLIN
	JZ	ENDIN
	MOV	M,A
	INX	H
	DCR	B
	JNZ	GLF0
ENDIN:	DCX	H
	INR	B
	MOV	A,M
	CPI	CR
	JZ	$+5
	INX	H
	DCR	B
	MVI	M,ENDSTR
	LXI	H,IPTBUF
	MVI	A,MAXLIN
	SUB	B	; Return str len in A
	POP	B
	RET
	END
>>> GETWD.MAC	820820:1720
; FILE:	GETWD.MAC
; DATE: 820819:1510
; FOR:	Isolate word with delim table

	TITLE	GETWD - Isolate next word
; Source at <HL>, dest at <DE>
; <BC> is table of legal delims ending with @
; @ provides for inclusion of delims in word
; doublequotes allowed as well
; ENDSTR overrides @ and "
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	ERROR
GETWD::	LDAX	B
	CPI	'@'
	JNZ	SETFL
	CALL	ERROR
	MSG	<'GETWD: Delim table empty'>
SETFL:	XRA	A
	STA	ESCFL
	PUSH	D
FNOND:	PUSH	B
	LDAX	B
	CMP	M
	JZ	DONE
FNON1:	INX	B
	LDAX	B
	CPI	'@'
	JZ	NOND
	CMP	M
	JNZ	FNON1
	INX	H
	POP	B
	JMP	FNOND
NOND:	POP	B
	MOV	A,M
	CPI	'"'
	JNZ	GTW0
	INX	H
QUOTE:	LDAX	B
	CMP	M
	JZ	DONEQ
	MOV	A,M
	INX	H
	CPI	'"'
	JNZ	QUOT0
	MOV	A,M
	CPI	'"'
	JNZ	GTW0
	INX	H
QUOT0:	STAX	D
	INX	D
	JMP	QUOTE
DONEQ:	PUSH	B
	JMP	DONE
GTW0:	PUSH	B
	LDAX	B
	CMP	M
	JZ	DONE
GTW1:	INX	B
	LDAX	B
	CPI	'@'
	JZ	INCL
	CMP	M
	JNZ	GTW1
	LDA	ESCFL
	CPI	'@'
	JNZ	DONE
INCL:	MOV	A,M
	STAX	D
	STA	ESCFL
	INX	H
	INX	D
	POP	B
	JMP	GTW0
DONE:	MVI	A,ENDSTR
	STAX	D
	MOV	A,M
	INX	H
	POP	B
	POP	D
	RET
ESCFL:	DS	1
	END
>>> HCTODI.MAC	820820:1723
; FILE:	HCTODI.MAC
; DATE: 820818:1236
; MOD:	820820:1631	; Complete externals
; FOR:	Convert string at <HL> to 32bit in <DE>

	TITLE	CTODI - Convert hex to 32bit
	.8080
	.COMMENT "
This routine returns a 32-bit integer in
<DE> to <DE+3> and advances HL to point to
the first non-digit character in the string,
which serves as the terminator and is returned
in A.
"
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	ADDA,NEGH,ISDIGH
	EXT	MPLS,MPS0,MPRD
	EXT	DPL,FNB
CTODI::	PUSH	B
	MOV	B,H
	MOV	C,L
	MVI	A,0FFH
	STA	DPL
	CALL	FNB
	LXI	H,0
	CPI	MINUS
	JNZ	CT0
	DCX	H
	JMP	CT1
CT0:	CPI	PLUS
	JNZ	CT2
CT1:	INX	B
	LDAX	B
CT2:	PUSH	H
	CALL	MPS0
	CALL	MPS0
CT3:	CALL	ISDIGH
	JC	CT4
	LXI	H,16
	CALL	MPLS
	CALL	MPS0
	PUSH	PSW
	MC	DMUL
	POP	PSW
	MOV	L,A
	MVI	H,0
	CALL	MPLS
	CALL	MPS0
	MC	DADD
	LDA	DPL
	ORA	A
	JM	CT3A
	INR	A
	STA	DPL
CT3A:	INX	B
	LDAX	B
	JMP	CT3
CT4:	CPI	PERIOD
	JNZ	CT5
	LDA	DPL
	ORA	A
	JP	CT5
	INR	A
	STA	DPL
	JMP	CT3
CT5:	POP	H
	MOV	A,H
	ORA	L
	JZ	CT6
	MC	CHSD
CT6:	XCHG
	CALL	MPRD
	XCHG
	MOV	H,B
	MOV	L,C
	LDA	DPL
	ORA	A
	JP	CT7
	INR	A
	STA	DPL
CT7:	MOV	A,M
	POP	B
	RET
	END
>>> HCTOI.MAC	820820:1723
; FILE:	HCTOI.MAC
; DATE: 820818:1146
; MOD:	820820:1632	; Complete externals
; FOR:	Convert string at <HL> to 16bit in DE

	TITLE	HCTOI - Convert hex to 16bit
	.8080
	.COMMENT "
This routine returns a sixteen-bit integer in
DE and advances HL to point to the first
non-digit character in the string, which
serves as the terminator and is returned in A.
"
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	ADDA,NEGH,ISDIGH,FNB
HCTOI::	PUSH	B
	MOV	B,H
	MOV	C,L
	CALL	FNB
	LXI	H,0
	CPI	MINUS
	JNZ	CT0
	DCX	H
	JMP	CT1
CT0:	CPI	PLUS
	JNZ	CT2
CT1:	INX	B
	LDAX	B
CT2:	PUSH	H
	LXI	H,0
CT3:	CALL	ISDIGH
	JC	CT4
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	CALL	ADDA
	INX	B
	LDAX	B
	JMP	CT3
CT4:	POP	D
	MOV	A,D
	ORA	E
	CNZ	NEGH
	XCHG
	MOV	H,B
	MOV	L,C
	MOV	A,M
	POP	B
	RET
	END
>>> HDCMP.MAC	820820:1723
; FILE:	HDCMP.MAC
; DATE:	820819:2146
; FOR:	Compare HL-DE, set flags just like CMP
	.8080
HDCMP::	MOV	A,H
	CMP	D
	RNZ
	MOV	A,L
	SUB	E
	RZ
	RAR
	ORA	A
	RAL
	RM
	XRA	A
	INR	A
	RET
	END
>>> HLDDE.MAC	820820:1724
; FILE:	HLDDE.MAC
; DATE: 820818:1444
; FOR:	HL / DE -> HL

	TITLE	HLDDE : HL / DE -> HL
	.8080
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	MPLS,MPRS
HLDDE::	CALL	MPLS
	XCHG
	CALL	MPLS
	XCHG
	MC	SDIV
	CALL	MPRS
	RET
	END
>>> HLMDE.MAC	820820:2333
; FILE:	HLMDE.MAC
; DATE: 820818:1442
; FOR:	HL - DE -> HL

	TITLE	HLMDE : HL - DE -> HL
	.8080
HLMDE::	PUSH	B
	MOV	B,A
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	MOV	A,B
	POP	B
	RET
	END
>>> HLXDE.MAC	820820:2333
; FILE:	HLXDE.MAC
; DATE: 820818:1444
; FOR:	HL * DE -> HL

	TITLE	HLXDE : HL * DE -> HL
	.8080
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	MPLS,MPRS
HLXDE::	CALL	MPLS
	XCHG
	CALL	MPLS
	XCHG
	MC	SMUL
	CALL	MPRS
	RET
	END
>>> INDEX.MAC	820821:0955
; FILE:	INDEX.MAC
; DATE:	820821:0939
; FOR:	Find position of string B in string A
	TITLE	INDEX
	SUBTTL	Index function like PL/I's INDEX
	.Z80	; but rewritten to run on 8080

;1	FUNCTION INDEX(KA,KB,LB,LA)
;2	INTEGER*1 KA,KB
;3	C Must pass string lengths explicitly in F66
;4	DIMENSION KA(LA),KB(LB)
	ENTRY	INDEX
INDEX:	LD	(KA),HL	; Addr of string searched
	LD	HL,KB
	LD	(HL),E
	INC	HL
	LD	(HL),D	; Addr of string sought
; these 4 lines are for the FORTRAN version
;	EXT	$AT
;	LD	A,02
;	LD	HL,LB
;	CALL	$AT
; these 8 lines are for LA in B, LB in C
	LD	HL,LB
	LD	(HL),C
	INC	HL
	LD	(HL),0
	INC	HL
	LD	(HL),B
	INC	HL
	LD	(HL),0
;7	NS=LA-LB+1
;8	DO 100 INDEX=1,NS
	LD	HL,(LB)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	DEC	DE
;	LD	(LB1),DE
	PUSH	HL
	LD	HL,LB1
	LD	(HL),E
	INC	HL
	LD	(HL),D
	POP	HL
	LD	HL,(LA)
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
;	SBC	HL,DE
	SUB	E
	LD	L,A
	LD	A,H
	SBC	A,D
	LD	H,A
	PUSH	HL	;Number of start positions
;9	C Try each possible start position until KB found
;10	DO 10 I=1,LB
;11	IA=I+INDEX-1
;12	10	IF(KA(IA).NE.KB(I))GO TO 100
	LD	HL,(KA)
	POP	BC
DO100:	;LD	DE,(KB)
	PUSH	HL
	LD	HL,KB
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL
	LD	A,(DE)
;	CPIR	;search for 1st character
FND001:	CP	(HL)
	JP	NZ,FND002
	INC	HL
	DEC	BC
	JP	FND004
FND002:	PUSH	AF
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JP	Z,FND003
	POP	AF
	JP	FND001
FND003:	POP	AF
	JP	NFND
FND004:	PUSH	BC
;	LD	BC,(LB1)	;number chars yet to find
	PUSH	HL
	LD	HL,LB1
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	POP	HL
	LD	A,C
	OR	B
	JP	Z,FOUND
	PUSH	HL
DO10:	INC	DE
	LD	A,(DE)
;	CPI	;Compare rest of string
	CP	(HL)
	PUSH	AF
	INC	HL
	DEC	BC
	POP	AF
	JP	NZ,NXT
;	JP	PE,DO10	;if any left to find
	LD	A,B
	OR	C
	JP	NZ,DO10	
;String found starting at INDEX
	POP	HL
FOUND:	POP	BC
;	LD	DE,(KA)	;Calculate INDEX
	PUSH	HL
	LD	HL,KA
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL
;	SBC	HL,DE
	LD	A,L
	SUB	E
	LD	L,A
	LD	A,H
	SBC	A,D
	LD	H,A
	RET
NXT:	POP	HL
	POP	BC
	LD	A,B	;repeat if INDEX<NS
	OR	C
	JP	NZ,DO100
NFND:	LD	HL,0
	RET
KA:	DS	2
KB:	DS	2
LB:	DS	2
LA:	DS	2
LB1:	DS	2
	END
>>> INIT.MAC	820820:2333
; FILE:	INIT.MAC
; DATE: 820819:1541
; FOR:	Pick up command line, redirect if < >

	TITLE	INIT - set up args & stdio
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	NARGS,ARGBUF,ESC
	EXT	GETWD,OPEN,STDIN,STDOUT
INIT::	LXI	H,80H
	LXI	D,ARGBUF
	MVI	A,ENDSTR
	STAX	D
	XRA	A
	STA	NARGS
	CMP	M
	RZ
	INX	H
	INX	H
INIT0:	DCX	H
	MOV	A,M
	INX	H
	ORA	A
	RZ
	LXI	B,DELIMS
	CALL	GETWD
	XCHG
	MOV	A,M
	CPI	'<'
	JNZ	INIT1
	PUSH	H
	PUSH	D
	INX	H
	MVI	B,0
	MVI	C,SECTRS
	CALL	OPEN
	STA	STDIN
	POP	D
	POP	H
	XCHG
	JMP	INIT0
INIT1:	CPI	'>'
	JNZ	INIT2
	PUSH	H
	PUSH	D
	INX	H
	MVI	B,0FFH
	MVI	C,SECTRS
	CALL	OPEN
	STA	STDOUT
	POP	D
	POP	H
	XCHG
	JMP	INIT0
INIT2:	PUSH	D
	MOV	D,H
	MOV	E,L
INIT3:	CALL	ESC
	CPI	ENDSTR
	JZ	INIT4
	STAX	D
	INX	D
	JMP	INIT3
INIT4:	XRA	A
	STAX	D
	INX	D
	LXI	H,NARGS
	INR	M
	POP	H
	JMP	INIT0
DELIMS:	DB	0
	DB	' '
	DB	'@'
	END
>>> INPORT.MAC	820820:2333
; FILE:	INPORT.MAC
; DATE: 820818:2049
; FOR:	Read port in A

	TITLE	INPORT - read port in A
	.8080
INPORT:: PUSH	H
	MOV	L,A
	MVI	H,RET
	PUSH	H
	MVI	H,IN
	MVI	L,0
	PUSH	H
	LXI	H,GOTIN
	PUSH	H
	LXI	H,3
	DAD	SP
	PCHL
GOTIN:	POP	H
	POP	H
	POP	H
	RET
	END
>>> IPTBUF.MAC	820820:2335
; FILE:	IPTBUF.MAC
; DATE:	820820:1454
; FOR:	Line buffer
	.8080
	CSEG
	.XLIST
	INCLUDE	SYSEQU
	.LIST
IPTBUF:: DS	MAXLIN+1
	END
>>> ISDIGD.MAC	820820:2335
; FILE:	ISDIGD.MAC
; DATE: 820818:1123
; FOR:	Check whether A is in range '0' to '9'
;	Strip ASCII bias if so

	TITLE	ISDIGD - Check decimal digit
	.8080
ISDIGD:: CPI	'0'
	RC
	CPI	'9'+1
	CMC
	RC
	SUI	'0'
	RET
	END
>>> ISDIGH.MAC	820820:2335
; FILE:	ISDIGH.MAC
; DATE: 820818:1125
; FOR:	Check whether A is in range '0' to '9'
;	or 'A' to 'F'; strip ASCII bias if so

	TITLE	ISDIGH - Check hexadecimal digit
	.8080
ISDIGH:: PUSH	PSW
	SUI	'0'
	JC	NODIG
	CPI	10
	JC	ISDIG
	ANI	0DFH	; Make sure uppercase
	SUI	7
	CPI	10
	JC	NODIG
	CPI	16
	JNC	NODIG
ISDIG:	XTHL
	POP	H
	ORA	A	; Clear C
	RET
NODIG:	POP	PSW
	STC
	RET
	END
>>> ITOC.MAC	820820:2335
; FILE:	ITOC.MAC
; DATE: 820818:1213
; FOR:	Convert integers to buffered string;
;	return addr in HL, length in A

	TITLE	ITOC - Convert integer to string
	.8080
	.XLIST
	INCLUDE SYSEQU
	INCLUDE MATHEQU
	.LIST
	EXT	MPLS,MPS0,MPLD,DPL
; ITOC for 16bit in DE; DITOC for 32bit at <DE>
ITOC::	XCHG
	CALL	MPLS
	XCHG
	MOV	A,D
	ORA	A
	JP	ITOC0
	LXI	H,-1
	CALL	MPLS
	JMP	ITOC0+3
ITOC0:	CALL	MPS0
	MVI	A,0FFH
	STA	DPL
	MVI	A,10
	JMP	ITOCC
DITOC::	XCHG
	CALL	MPLD
	XCHG
	MVI	A,10
	JMP	ITOCC
ITOHC::	XCHG
	CALL	MPLS
	XCHG
	CALL	MPS0
	MVI	A,0FFH
	STA	DPL
	MVI	A,16
	JMP	ITOCC
DITOHC:: XCHG
	CALL	MPLD
	XCHG
	MVI	A,10
;
; Common conversion routine
; num in or at DE, base in A
ITOCC:	PUSH	B
	LXI	B,NUMBUF
	MOV	L,A
	MVI	H,0
	MVI	A,ENDSTR
	STAX	B
	MC	XCHD	; Set flags
	MC	XCHD
	ANI	40H
	PUSH	PSW	; Save minus bit
	JZ	ITC0
	MC	CHSD
ITC0:	MC	PTOD	; n n
	CALL	MPLS
	CALL	MPS0	; n n base
	MC	DDIV	; n n'
	MC	PTOD	; n n' n'
	CALL	MPLS
	CALL	MPS0	; n n' n' base
	MC	DMUL	; n n' n'*base
	MC	XCHD	; n n'b n'
	MC	POPD	; n' u n n'b
	MC	DSUB	; n'b n' u d
	IN	MDATA
	IN	MDATA
	IN	MDATA
	IN	MDATA	; n'b n' u with d in A
	ADI	'0'
	CPI	'9'+1
	JC	$+5
	ADI	7
	DCX	B
	STAX	B
	LDA	DPL
	DCR	A
	STA	DPL
	JNZ	ITC1
	MVI	A,PERIOD
	DCX	B
	STAX	B
ITC1:	MC	POPD	; n'b n'
	ANI	32	; Check for n' = 0
	JZ	ITC0	; mcZ flag clear means
; ..more to do, set means string ready
; Set up params and quit
	POP	PSW	; Sign
	JZ	ITC2
	MVI	A,MINUS
	DCX	B
	STAX	B
ITC2:	LXI	H,NUMBUF
	MOV	A,L
	SUB	C
	MOV	H,B
	MOV	L,C
	POP	B
	RET
	DS	20
NUMBUF	EQU	$-1
	END
>>> LENGTH.MAC  820927:1304
; FILE: LENGTH.MAC
; DATE: 820927:1305
; FOR:  Return length of string at <HL> in DE
	.8080
	TITLE	LENGTH - get length of string
	.XLIST
	INCLUDE	SYSEQU
	.LIST
LENGTH:: PUSH	H
	PUSH	PSW
	LXI	D,0
LEN0:	MOV	A,M
	INX	H
	CPI	ENDSTR
	JZ	LEN1
	INX	D
	JMP	LEN0
LEN1:	POP	PSW
	POP	H
	RET
	END
>>> LSTPUT.MAC	820825:1656
; FILE:	LSTPUT.MAC
; DATE:	820825:1646
; FOR:	Put single char on LST: via PUTCF
	.8080
	TITLE	LSTPUT - Put char on LST:
	EXT	PUTCF
LSTPUT:: PUSH	B
	MVI	C,16
	CALL	PUTCF
	POP	B
	RET
	END
>>> MAKFCB.MAC	820823:1358
; FILE:	MAKFCB.MAC
; DATE: 820823:1350
; FOR:	Create FCB at <DE> from file at <HL>

	TITLE	MAKFCB - Make FCB from name
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	FNB,ERROR,UPCASE,FILL
MAKFCB:: PUSH	D
	PUSH	B
	PUSH	B
	XTHL
	POP	B
	CALL	FNB
	PUSH	B
	XTHL
	POP	B
	INX	H
	MOV	A,M
	DCX	H
	CPI	':'
	JNZ	MKF1
	MOV	A,M
	INX	H
	INX	H
	CALL	UPCASE
	SUI	'@'
	JC	MKF0
	CPI	MAXDRV+1
	JC	MKF2
MKF0:	CALL	ERROR
	MSG	<'MAKFCB: Drive out of range'>
MKF1:	XRA	A
MKF2:	STAX	D
	INX	D
	MVI	B,2
	MVI	C,8
MKF3:	MOV	A,M
	CPI	ENDSTR
	JZ	MKF4
	CPI	BLANK
	JZ	MKF4
	INX	H
	CPI	PERIOD
	JZ	MKF4
	CALL	UPCASE
	STAX	D
	INX	D
	DCR	C
	JNZ	MKF3
	JMP	MKF6
MKF4:	MOV	A,C
	ORA	A
MKF5:	JZ	MKF7
	MVI	A,BLANK
	STAX	D
	INX	D
	DCR	C
	JMP	MKF5
MKF6:	MOV	A,M
	CPI	PERIOD
	JNZ	MKF7
	INX	H
MKF7:	MVI	C,3
	DCR	B
	JNZ	MKF3
	XCHG
	LXI	B,24
	XRA	A
	CALL	FILL
	POP	B
	POP	D
	RET		; HL = buf start addr
	END
>>> MEMRY.MAC	820820:2336
; FILE:	MEMRY.MAC
; DATE:	820819:1404
; FOR:	See comment
	.8080
	.COMMENT "
In files needing to know about $MEMRY,
the following locution should be used:
	IF	LYNX	; ie linking with LYNX
$MEMRY	EQU	108H
	ELSE
	EXT	$MEMRY
	ENDIF
and of course the present file need not be
used in conjunction with LYNX.  If it is used,
MEMRY must be linked last of all and DSEG must
be the last segment of code.
"
	DSEG
$MEMRY:: DW	$+2
	END
>>> MOVEL.MAC	820820:2336
; FILE:	MOVEL.MAC
; DATE: 820818:1317
; FOR:	Move BC bytes from <HL> to <DE>

	TITLE	MOVEL - <HL> to <DE>, len=BC
	.8080
MOVEL::	PUSH	PSW	; A is preserved
ML0:	MOV	A,B	; While count <> 0
	ORA	C
	JZ	ML1	; ..do begin
	MOV	A,M	; move 1 byte
	STAX	D
	INX	H	; next byte
	INX	D	; next space
	DCX	B	; count down
	JMP	ML0	; end do
ML1:	POP	PSW
	RET
	END
>>> MOVES.MAC	820820:2337
; FILE:	MOVES.MAC
; DATE: 820818:1323
; FOR:	Move bytes from <HL> to <DE>, delim=C

	TITLE	MOVES - <HL> to <DE>, delim=C
	.8080
MOVES::	PUSH	PSW	; A is preserved
	MOV	A,M	; move 1 byte
	STAX	D
	INX	H	; next to move
	INX	D	; space to fill
	CMP	C	; was delim?
	JNZ	MOVES+1	; ..if no, continue
	POP	PSW	; ..else quit
	RET
	END
>>> MOVEU.MAC	820820:2343
; FILE:	MOVEU.MAC
; DATE: 820818:1321
; FOR:	Move BC bytes from <HL> to <DE>, down

	TITLE	MOVEU - <HL> to <DE>, len=BC
	.8080
MOVEU::	PUSH	PSW	; A is preserved
	DAD	B	; start at top
	XCHG
	DAD	B	; ..of both areas
	XCHG
ML0:	MOV	A,B	; While count <> 0
	ORA	C
	JZ	ML1	; ..do begin
	DCX	H	; byte to move
	DCX	D	; space to fill
	MOV	A,M	; move 1 byte
	STAX	D
	DCX	B	; count down
	JMP	ML0	; end do
ML1:	POP	PSW
	RET
	END
>>> MPLD.MAC	820820:2346
; FILE:	MPLD.MAC
; DATE: 820818:1102
; FOR:	Load <HL> memory (32 bits) to 9511

	TITLE	MPLD - Load <HL> to math chip
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
MPLD::	PUSH	PSW
	MOV	A,M
	OUT	MDATA
	INX	H
	MOV	A,M
	OUT	MDATA
	INX	H
	MOV	A,M
	OUT	MDATA
	INX	H
	MOV	A,M
	OUT	MDATA
	DCX	H
	DCX	H
	DCX	H
	POP	PSW
	RET
	END
>>> MPLS.MAC	820820:2347
; FILE:	MPLS.MAC
; DATE: 820818:1102
; FOR:	Load HL contents to math chip

	TITLE	MPLS - Load HL to math chip
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
MPLS::	PUSH	PSW
	MOV	A,L
	OUT	MDATA
	MOV	A,H
	OUT	MDATA
	POP	PSW
	RET
	END
>>> MPRD.MAC	820820:2352
; FILE:	MPRD.MAC
; DATE: 820818:1102
; FOR:	Read math chip to <HL> (32 bits)

	TITLE	MPRD - Read <HL> from math chip
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
MPRD::	PUSH	PSW
	INX	H
	INX	H
	INX	H
	IN	MDATA
	MOV	M,A
	DCX	H
	IN	MDATA
	MOV	M,A
	DCX	H
	IN	MDATA
	MOV	M,A
	DCX	H
	IN	MDATA
	MOV	M,A
	POP	PSW
	RET
	END
>>> MPRS.MAC	820820:2354
; FILE:	MPRS.MAC
; DATE: 820818:1102
; FOR:	Read math chip to HL (16 bits)

	TITLE	MPRS - Read HL from math chip
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
MPRS::	PUSH	PSW
	IN	MDATA
	MOV	H,A
	IN	MDATA
	MOV	L,A
	POP	PSW
	RET
	END
>>> MPS0.MAC	820820:2354
; FILE:	MPS0.MAC
; DATE: 820818:1058
; FOR:	Load a 16-bit zero to the math chip

	TITLE	MPS0 - Load a 16-bit zero
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
MPS0::	PUSH	PSW
	XRA	A
	OUT	MDATA
	OUT	MDATA
	POP	PSW
	RET
	END
>>> MPWAIT.MAC	820820:2354
; FILE:	MPWAIT.MAC
; DATE: 820818:1224
	TITLE	MPWAIT - Issue math op command
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
MPWAIT::	; Issue command and get status
	OUT	MCMDS
	PUSH	H
	LXI	H,MCDLY
MPW0:	IN	MCMDS
	ANI	80H
	JZ	MPW1
	DCX	H
	MOV	A,H
	ORA	L
	JNZ	MPW0
MPW1:	POP	H
	IN	MCMDS
	STA	MSTAT
	RET
MSTAT::		; Status "register"
	DS	1
	END
>>> MTBUF.MAC	820820:2354
; FILE:	MTBUF.MAC
; DATE: 820819:1217
; FOR:	Write C secs from <HL>, fcb = <DE>

	TITLE	MTBUF - Empty disk buffer
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	ADDA,ERROR
1656UF:: PUSH	B
	PUSH	H
	PUSH	D
	XCHG
	MVI	C,SETDMA
	CALL	BDOS
	POP	D
	PUSH	D
	MVI	C,WRTSEQ
	CALL	BDOS
	ORA	A
	JNZ	DSKFUL
	POP	D
	POP	H
	POP	B
	DCR	C
	RZ
	MVI	A,80H
	CALL	ADDA
	JMP	MTBUF
DSKFUL:	CALL	ERROR
	MSG	<'MTBUF: Disk full'>
	END
>>> NEGH.MAC	820820:2354
; FILE:	NEGH.MAC
; DATE: 820818:1310
; FOR:	-HL -> HL

	TITLE	NEGH - -HL -> HL
	.8080
NEGH::	PUSH	PSW
	XRA	A
	SUB	L
	MOV	L,A
	SBB	H
	SUB	L
	MOV	H,A
	POP	PSW
	RET
	END
>>> OP32.MAC	820820:2354
; FILE:	OP32.MAC
; DATE:	820818:1226
; FOR:	HL op DE -> HL - math-chip operations

	TITLE	OP32 - HL op DE -> HL
	.8080
	EXT	MPLD,MPRD,MPWAIT

OP32::	CALL	MPLD
	XCHG
	CALL	MPLD
	XCHG
	CALL	MPWAIT
	CALL	MPRD
	RET
	END
>>> OPEN.MAC	820820:2355
; FILE:	OPEN.MAC
; DATE: 820819:1416
; FOR:	Open or create file named at <HL>

	TITLE	OPEN - Open or create file
	.8080
	.XLIST
	INCLUDE SYSEQU
	INCLUDE LINKEQU
	.LIST
	EXT	MAKFCB,FILLBF
	EXT	BUFBLS,CHANLS,ADDA,NEGH
	IF	LYNX
$MEMRY	EQU	108H
	ELSE
	EXT	$MEMRY
	ENDIF
OPEN::	CALL	GETCHN
	RZ
	CALL	MAKFCB
	PUSH	H
	PUSH	B
	PUSH	D
	MOV	A,B
	INR	A
	JNZ	OPENRD
	MVI	C,ERASEF
	CALL	BDOS
	POP	D
	PUSH	D
	MVI	C,MAKEF
	JMP	OPENRD+2
OPENRD:	MVI	C,OPENF
	CALL	BDOS
	POP	D
	POP	B
	POP	H
	INR	A
	RZ
	CALL	SETCHN
	MOV	A,B
	INR	A
	CNZ	FILLBF
	LDA	CHNLNO
	ORA	A
	RET
GETCHN:	PUSH	H
	PUSH	B
	LXI	H,CHANLS+2
	MVI	B,2
	CALL	GETBLK
	JZ	GTCHN4
	SHLD	CHANL
	STA	CHNLNO
	LXI	H,BUFBLS
	MVI	B,10
	CALL	GETBLK
GTCHN0:	SHLD	BUFBLK
	MVI	A,8
	CALL	ADDA
	MOV	A,C
	POP	B
	PUSH	B
	MOV	A,M	; 0FF for unassigned
	CMP	C
	JNC	GTCHN1
	LHLD	BUFBLK
	MOV	C,B
	MVI	B,10
	CALL	GTNXT
	JZ	GTCHN4
	JMP	GTCHN0
GTCHN1:	INR	A
	JZ	GTCHN2
	DCX	H
	MOV	D,M
	DCX	H
	MOV	E,M
	JMP	GTCHN3
GTCHN2:	LHLD	$MEMRY
	XCHG
GTCHN3:	LDA	CHNLNO
	ORA	A
GTCHN4:	POP	B
	POP	H
	RET		; DE -> FCB
GETBLK:	MVI	C,1
GTCN0:	INX	H
	MOV	A,M
	DCX	H
	ORA	M
	JZ	GOTONE
GTNXT:	MOV	A,B
	CALL	ADDA
	INR	C
	MOV	A,C
	CPI	16
	JC	GTCN0
	XRA	A
	MOV	C,A
	MOV	L,A
	MOV	H,A
	RET
GOTONE:	MOV	A,C
	ORA	A
	RET
SETCHN:	PUSH	D
	PUSH	H	; Buffer start
	LHLD	BUFBLK
	MVI	A,9
	CALL	ADDA
	MOV	M,B	; RWFLG
	DCX	H
	MOV	M,C	; NSECS
	DCX	H
	MOV	M,D	; FCB
	DCX	H
	MOV	M,E
	MOV	A,C
	ORA	A
	RAR
	MOV	D,A
	MVI	A,0
	RAR
	MOV	E,A
	XCHG
	PUSH	H	; Buflen
	CALL	NEGH
	XCHG
	DCX	H
	MOV	M,D	; -Buflen
	DCX	H
	MOV	M,E
	DCX	H
	MOV	M,D	; Pointer
	DCX	H
	MOV	M,E
	POP	D	; Buflen
	XTHL		; Buffer start
	PUSH	H
	DAD	D	; Bufend
	XCHG
	POP	H	; Buffer start
	XTHL		; Block pointer
	DCX	H
	MOV	M,D	; Bufend
	DCX	H	; Block start
	MOV	M,E
; Now reset $MEMRY and set channel entry
	XCHG
	MVI	M,0
	MVI	A,92
	CALL	ADDA
	SHLD	$MEMRY	; Bufend + pushback
	LHLD	CHANL
	MOV	M,E	; Buffer block addr
	INX	H
	MOV	M,D
	POP	H
	POP	D
	RET
BUFBLK:	DS	2
CHANL:	DS	2
CHNLNO:	DS	1	
	END
>>> OUTPT.MAC	820820:2355
; FILE:	OUTPT.MAC
; DATE: 820818:2052
; FOR:	Write A to port in C

	TITLE	OUTPT - Write A to port C
	.8080
OUTPT::	PUSH	H
	MOV	L,C
	MVI	H,RET
	PUSH	H
	MVI	H,OUT
	MVI	L,0
	PUSH	H
	LXI	H,GONOUT
	PUSH	H
	LXI	H,3
	DAD	SP
	PCHL
GONOUT:	POP	H
	POP	H
	POP	H
	RET
	END
>>> PCSTR.MAC	820825:1740
; FILE:	PCSTR.MAC
; DATE:	820825:1719
; FOR:	Output msg from <HL> to CON:
	.8080
	TITLE	PCSTR - Send from <HL>
	EXT	PUTSTF
	.XLIST
	INCLUDE SYSEQU
	.LIST
PCSTR::	PUSH	B
	MVI	C,0
	CALL	PUTSTF
	POP	B
	RET
	END
>>> PCMSG.MAC	820825:1741
; FILE:	PCMSG.MAC
; DATE:	820825:1721
; FOR:	Output inline msg to CON:
	.8080
	TITLE	PCMSG - Send from <PC>
	EXT	PUTSTF
	.XLIST
	INCLUDE SYSEQU
	.LIST
PCMSG::	XTHL
	PUSH	B
	MVI	C,0
	CALL	PUTSTF
	POP	B
	XTHL
	RET
	END
>>> PLMSG.MAC	820825:1742
; FILE:	PLMSG.MAC
; DATE:	820825:1721
; FOR:	Output inline msg to LST:
	.8080
	TITLE	PLMSG - Send from <PC>
	EXT	PUTSTF
	.XLIST
	INCLUDE SYSEQU
	.LIST
PLMSG::	XTHL
	PUSH	B
	MVI	C,16
	CALL	PUTSTF
	POP	B
	XTHL
	RET
	END
>>> PLSTR.MAC	820825:1743
; FILE:	PLSTR.MAC
; DATE:	820825:1719
; FOR:	Output msg from <HL> to LST:
	.8080
	TITLE	PLSTR - Send from <HL>
	EXT	PUTSTF
	.XLIST
	INCLUDE SYSEQU
	.LIST
PLSTR::	PUSH	B
	MVI	C,16
	CALL	PUTSTF
	POP	B
	RET
	END
>>> PROMPT.MAC	820901:0957
; FILE:	PROMPT.MAC
; DATE:	820901:0935
; FOR:	See comment
	.8080
	TITLE	PROMPT - Read line from keyboard
; Call with message inline, max reply length
; in C and "must-reply" flag in A (0=cr ok);
; returns buffer addr in HL and length in A
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	CONMSG,IPTBUF
PROMPT:: POP	H
	PUSH	D
	PUSH	B
	STA	CRFLG
	CALL	CONMSG
	POP	B
	POP	D
	PUSH	H
	PUSH	D
	PUSH	B
	MVI	A,'?'
	CALL	CHOUT
NMPRMP:	MVI	A,' '
	CALL	CHOUT
	LXI	D,IPTBUF
	MOV	B,C
P1:	MVI	A,'_'
	CALL	CHOUT
	DCR	C
	JNZ	P1
	MOV	C,B
P2:	MVI	A,BKS
	CALL	CHOUT
	DCR	C
	JNZ	P2
; Max count now in B, C=0
CHR1:	CALL	KEY
	CPI	' '	; initial space ng
	JZ	PERROR
QCR:	CPI	CR
	JNZ	QESC
	MOV	A,C
	ORA	A
	JNZ	P3
	LDA	CRFLG	; blank field, ok?
	ORA	A
	JNZ	PERROR
P3:	MOV	A,B
	ORA	A
	JZ	DONE
P3A:	MVI	A,' '
	STAX	D
	INX	D
	CALL	CHOUT
	DCR	B
	JNZ	P3A
	JMP	DONE
QESC:	CPI	ESCAPE
	JNZ	QBKS
P4:	MOV	A,C
	ORA	A
	JZ	ESCRET
	MVI	A,BKS
	CALL	CHOUT
	MVI	A,'_'
	CALL	CHOUT
	MVI	A,BKS
	CALL	CHOUT
	DCX	D
	MVI	A,' '
	STAX	D
	INR	B
	DCR	C
	JNZ	P4
	JMP	CHR1
ESCRET:	MVI	A,ESCAPE
	STAX	D
	INX	D
	INR	C
	DCR	B
	JMP	DONE
QBKS:	CPI	BKS
	JZ	BKSP
	CPI	DEL
	JNZ	QERR
BKSP:	MOV	A,C
	ORA	A
	JZ	PERROR
	MVI	A,BKS
	CALL	CHOUT
	MVI	A,'_'
	CALL	CHOUT
	MVI	A,BKS
	CALL	CHOUT
	DCX	D
	MVI	A,' '
	STAX	D
	INR	B
	DCR	C
	JZ	CHR1
	JMP	NCHR
QERR:	CPI	' '
	JC	PERROR
QSIZ:	STAX	D
	MOV	A,B
	ORA	A
	JZ	PERROR
	LDAX	D
	INX	D
	INR	C
	DCR	B
	JMP	CHR2
PERROR:	MVI	A,BEL
CHR2:	CALL	CHOUT
	MOV	A,C
	ORA	A
	JZ	CHR1
NCHR:	CALL	KEY
	JMP	QCR
DONE:	MOV	A,C
	POP	B
	POP	D
	LXI	H,IPTBUF
	RET
CHOUT:	PUSH	H
	PUSH	D
	PUSH	B
	PUSH	PSW
	MOV	E,A
	MVI	C,PRTCHR
	CALL	BDOS
	POP	PSW
	POP	B
	POP	D
	POP	H
	RET
KEY:	PUSH	D
	PUSH	B
	MVI	E,0FFH
	MVI	C,DIRIO
	CALL	BDOS
	ANI	7FH
	JZ	KEY+2
	POP	B
	POP	D
	RET
CRFLG:	DS	1
	END
>>> PUSHBF.MAC	820820:2355
; FILE:	PUSHBF.MAC
; DATE: 820819:1221
; MOD:	820820:1641	; Complete externals
; FOR:	Write A to pushback buf for channel C

	TITLE	PUSHBF - Push A back to file C
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	CONBUF,FNDBUF,ERROR,MOVEU
PUSHBF:: PUSH	H
	PUSH	PSW
	MOV	A,C
	ANI	15
	JNZ	PBF0
	LXI	H,CONBUF
	JMP	PBF2
PBF0:	CALL	FNDBUF
	INR	A
	JNZ	PBF1
	CALL	ERROR
	MSG	<'PUSHBF: Pushback to output file'>
PBF1:	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
PBF2:	MOV	A,M
	INR	M
	CPI	90
	JNC	FULL
	PUSH	D
	PUSH	B
	MOV	C,A
	MVI	B,0
	INX	H
	MOV	D,H
	MOV	E,L
	INX	D
	CALL	MOVEU
	POP	B
	POP	D
	POP	PSW
	MOV	M,A
	POP	H
	RET
FULL:	CALL	ERROR
	MSG	<'PUSHBF: Pushback buffer full'>
	END
>>> PUSHBK.MAC	820820:2356
; FILE:	PUSHBK.MAC
; DATE: 820820:1352
; FOR:	Push char back on std input

	TITLE	PUSHBK - Push char - std input
	.8080
	EXT	STDIN,PUSHBF
PUSHBK:: PUSH	B
	MOV	B,A
	LDA	STDIN
	MOV	C,A
	MOV	A,B
	CALL	PUSHBF
	POP	B
	RET
	END
>>> PUTC.MAC	820820:2356
; FILE:	PUTC.MAC
; DATE: 820820:1352
; FOR:	Write char to std output

	TITLE	PUTC - Write char - std output
	.8080
	EXT	STDOUT,PUTCF
PUTC::	PUSH	B
	MOV	B,A
	LDA	STDOUT
	MOV	C,A
	MOV	A,B
	CALL	PUTCF
	POP	B
	RET
	END
>>> PUTCF.MAC	820820:2356
; FILE:	PUTCF.MAC
; DATE: 820819:1305
; FOR:	Write 1 char from A into channel C

	TITLE	PUTCF - Write char to file
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	FNDBUF,ERROR,SETBF,MTBUF
	EXT	ADDA
PUTCF::	PUSH	H
	PUSH	D
	PUSH	B
	PUSH	PSW
	MOV	A,C
	ANI	31
	JZ	CONOUT
	ANI	15
	JZ	LSTOUT
	CALL	FNDBUF
	INR	A
	JZ	PCF0
	CALL	ERROR
	MSG	<'PUTCF: Writing to input file'>
PCF0:	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
	XCHG
	DAD	B
	POP	PSW
	PUSH	PSW
	MOV	M,A
	XCHG
	INX	B
	MOV	A,B
	ORA	C
	JNZ	PCF1
; If we fall through here, buffer is full
	INX	H
	CALL	SETBF
	CALL	MTBUF
	JMP	PCF2
PCF1:	MOV	M,B
	DCX	H
	MOV	M,C
	JMP	PCF2
CONOUT:	MVI	C,PRTCHR
	JMP	OUTR
LSTOUT:	MVI	C,LSTCHR
OUTR:	POP	PSW
	PUSH	PSW
	MOV	E,A
	CALL	BDOS
PCF2:	POP	PSW
	POP	B
	PUSH	B
	PUSH	PSW
	SUI	9
	JZ	TABR
	DCR	A
	JZ	LINE
	DCR	A
	DCR	A
	JZ	PAGE
	DCR	A
	JZ	CARR
	MVI	A,2
	CALL	FNDCNT
	INR	M
	JMP	PCF3
TABR:	MVI	A,2
	CALL	FNDCNT
	MOV	A,M
	ANI	0F8H
	ADI	8
	MOV	M,A
	JMP	PCF3
LINE:	MVI	A,1
	CALL	FNDCNT
	INR	M
	JMP	PCF3
PAGE:	XRA	A
	CALL	FNDCNT
	INR	M
	INX	H
	MVI	M,0
	JMP	PCF3
CARR:	MVI	A,2
	CALL	FNDCNT
	MVI	M,0
PCF3:	POP	PSW
	POP	B
	POP	D
	POP	H
	RET
FNDCNT::	; Find block of 3 bytes:
; page, line and char counters for PUTCF
; channel no in C, offset of 0, 1 or 2 in A
	LXI	H,CNTRS
	ADD	C
	ADD	C
	ADD	C
	CALL	ADDA	
	RET
CNTRS:	REPT	17
	DB	0	;; Page
	DB	0	;; Line
	DB	0	;; Char
	ENDM
	END
>>> PUTDCF.MAC	820825:1941
; FILE:	PUTDCF.MAC
; DATE:	820825:1925
; FOR:	Put DE out on chan. C as decimal ASCII
	.8080
	TITLE	PUTDCF - Write DE to channel C
	EXT	ITOC,PUTCF,PUTSTF
PUTDCF:: PUSH	H
	PUSH	B
	MOV	B,A
	CALL	ITOC
PDC0:	CMP	B
	JNC	PDC1	
	PUSH	PSW
	MVI	A,' '
	CALL	PUTCF
	POP	PSW
	INR	A
	JMP	PDC0
PDC1:	CALL	PUTSTF
	POP	B
	POP	H
	RET
	END
>>> PUTDEC.MAC	820825:1942
; FILE:	PUTDEC.MAC
; DATE:	820825:1925
; FOR:	Put DE out on STDOUT as decimal ASCII
	.8080
	TITLE	PUTDEC - Write DE to STDOUT
	EXT	ITOC,PUTC,PUTSTR
PUTDEC:: PUSH	H
	PUSH	B
	MOV	B,A
	CALL	ITOC
PDC0:	CMP	B
	JNC	PDC1	
	PUSH	PSW
	MVI	A,' '
	CALL	PUTC
	POP	PSW
	INR	A
	JMP	PDC0
PDC1:	CALL	PUTSTR
	POP	B
	POP	H
	RET
	END
>>> PUTMSF.MAC	820825:1746
; FILE:	PUTMSF.MAC
; DATE:	820825:1701
; FOR:	Output inline msg to channel C
	.8080
	TITLE	PUTMSF - Send from <PC> to C
	EXT	PUTSTF
	.XLIST
	INCLUDE SYSEQU
	.LIST
PUTMSF:: XTHL
	CALL	PUTSTF
	XTHL
	RET
	END
>>> PUTMSG.MAC	820825:1748
; FILE:	PUTMSG.MAC
; DATE:	820825:1701
; FOR:	Output inline msg to STDOUT
	.8080
	TITLE	PUTMSG - Send from <PC>
	EXT	PUTSTF,STDOUT
	.XLIST
	INCLUDE SYSEQU
	.LIST
PUTMSG:: XTHL
	PUSH	PSW
	PUSH	B
	LDA	STDOUT
	MOV	C,A
	CALL	PUTSTF
	POP	B
	POP	PSW
	XTHL
	RET
	END
>>> PUTSTF.MAC	820825:1749
; FILE:	PUTSTF.MAC
; DATE:	820825:1701
; FOR:	Output msg from <HL> to channel C
	.8080
	TITLE	PUTSTF - Send from <HL> to C
	EXT	PUTCF
	.XLIST
	INCLUDE SYSEQU
	.LIST
PUTSTF:: PUSH	PSW
	MOV	A,M
	INX	H	; Will point past
	CPI	ENDSTR	; ..ENDSTR when done
	JZ	DONE
	CALL	PUTCF
	JMP	PUTSTF+1
DONE:	POP	PSW
	RET
	END
>>> PUTSTR.MAC	820825:1751
; FILE:	PUTSTR.MAC
; DATE:	820825:1701
; FOR:	Output msg from <HL> to STDOUT
	.8080
	TITLE	PUTSTR - Send from <HL>
	EXT	PUTSTF,STDOUT
	.XLIST
	INCLUDE SYSEQU
	.LIST
PUTSTR:: PUSH	PSW
	PUSH	B
	LDA	STDOUT
	MOV	C,A
	CALL	PUTSTF
	POP	B
	POP	PSW
	RET
	END
>>> RDCLK.MAC	820820:2356
; FILE:	RDCLK.MAC
; DATE: 820818:1452
; FOR:	Read clock to buffer

	TITLE	RDCLK - Read clock to buffer
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
RDCLK::	PUSH	B
	LXI	H,BUFFER
	MVI	M,ENDSTR
	MVI	B,2
	MVI	C,4
	CALL	RDMUL
	DCX	H
	MVI	M,':'
	INR	B
	MVI	C,6
	CALL	RDMUL
	POP	B
	MVI	A,11
	RET
RDMUL:	MOV	A,B
	CALL	RDDGT
	ADI	30H
	DCX	H
	MOV	M,A
	INR	B
	DCR	C
	JNZ	RDMUL
	RET
RDDGT:	ORI	10H
	OUT	CSTAT
	CPI	15H
	JZ	RDD0
	CPI	18H
RDD0:	IN	CDATA
	RNZ
	ANI	3	; Strip off flag bits
	RET
	DS	12
BUFFER	EQU	$-1
	END
>>> REMARK.MAC	820820:2356
; FILE:	REMARK.MAC
; DATE: 820818:1337
; FOR:	Print inline string with ENDSTR delim

	TITLE	REMARK - Put string on CON:
	.8080
	EXT	CONMSG,CRLFMS
REMARK:: XTHL
	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	H,CRLFMS
	CALL	CONMSG
	POP	H
	CALL	CONMSG
	POP	D
	POP	B
	POP	PSW
	XTHL
	RET
	END
>>> SELCMD.MAC	820820:2356
; FILE:	SELCMD.MAC
; DATE:	820819:2239
; FOR:	Select command from table
	TITLE	SELCMD - Check A against list
	.COMMENT "
Usage:	CALL	SELCMD
	DB	CMD1
	DW	PROC1
	...
	DB	CMDN
	DW	PROCN
	DB	0	; Table end
	MORE CODE	; for 'none of the above'
"
	.8080
SELCMD:: POP	H	; Table addr
	CMP	M
	JZ	FOUND
	MOV	E,A
	MOV	A,M
	INX	H
	ORA	A	; Table end?
	JZ	GOTOIT
	INX	H
	INX	H	; Next entry
	JMP	SELCMD+1
FOUND:	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
GOTOIT:	PCHL
	END
>>> SETBF.MAC	820820:2356
; FILE:	SETBF.MAC
; DATE: 820819:1244
; FOR:	Get FILLBF or MTBUF info from block

	TITLE	SETBF - Prepare to read or write buffer
	.8080
	EXT	ADDA
SETBF::	MOV	E,M	; Buffer size
	INX	H
	MOV	D,M
	DCX	H
	DCX	H
	MOV	M,D	; Pointer
	DCX	H
	MOV	M,E
	DCX	H
	MOV	B,M	; Buffer end
	DCX	H
	MOV	C,M
	XCHG		; Buffer size
	DAD	B	; Gets buffer start
	PUSH	H
	XCHG
	MVI	A,6
	CALL	ADDA
	MOV	E,M	; FCB addr
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M	; Sector size
	POP	H	; Ready to go
	RET
	END
>>> SOUNDX.MAC	820820:2357
; FILE:	SOUNDX.MAC
; DATE:	820819:2119
; FOR:	Generate Soundex code for <HL> -> <DE>
	TITLE	SOUNDX - Make Soundex code
	.8080
FLEN	EQU	20
BUFFER:	DS	FLEN
	DB	0FFH
TABLE:	DB	0,1,2,3,0,1,2
	DB	0,0,2,2,4,5,5
	DB	0,1,2,6,2,3,0
	DB	1,0,2,0,2
; Call with name to encode at <HL>
; Code is stored as 4 bytes at <DE>
SOUNDX:: PUSH	D
	PUSH	B
	PUSH	PSW
	PUSH	D
	PUSH	H
	LXI	H,BUFFER
	MVI	C,20
SX0:	MVI	M,0
	INX	H
	DCR	C
	JNZ	SX0
	POP	H
	LXI	B,BUFFER
	MOV	A,M
	INX	H
	STAX	B
	INX	B
SX1:	MOV	A,M
	INX	H
	SUI	'A'
	JC	SX3
	CPI	26
	JNC	SX3
	LXI	D,TABLE
	ADD	E
	MOV	E,A
	JNC	SX2
	INR	D
SX2:	LDAX	D
	STAX	B
	INX	B
	LDAX	B
	ORA	A
	JZ	SX1
SX3:	XTHL
	LXI	D,BUFFER
	MVI	C,FLEN-1
	MVI	B,3
	LDAX	D
	MOV	M,A
	INX	D
SX4:	LDAX	D
	INX	D
	ORA	A
	JZ	SX5
	CMP	M
	JZ	SX5
	INX	H
	MOV	M,A
	DCR	B
	JZ	SX7
SX5:	DCR	C
	JNZ	SX4
	XRA	A
SX6:	INX	H
	MOV	M,A
	DCR	B
	JNZ	SX6
SX7:	POP	H
	POP	PSW
	POP	B
	POP	D
	RET
	END
>>> SPXCH.MAC	820820:2357
; FILE:	SPXCH.MAC
; DATE:	820819:2235
; FOR:	Exchange stack pointers
	.8080
	TITLE	SPXCH - exchange stack pointers
; ..with new SP in HL
SPXCH::	XCHG
	LXI	H,2	; skip this call
	DAD	SP	; new AT DE, old IN HL
	XCHG
	MOV	A,M	; new SP.0
	MOV	M,E	; old SP.0
	MOV	E,A
	INX	H
	MOV	A,M	; SP.1
	MOV	M,D
	MOV	D,A
	POP	H	; ret addr
	XCHG
	SPHL
	XCHG
	PCHL
	END
>>> STDIO.MAC	820820:2357
; FILE:	STDIO.MAC
; DATE:	820819:1302
; FOR:	Standard input and output channel nos.
	.8080
	CSEG
STDIN::	DB	0
STDOUT:: DB	0
	END
>>> TABBER.MAC	820820:2357
; FILE:	TABBER.MAC
; DATE: 820820:1520
; FOR:	Write spaces to std output till col. A

	TITLE	TABBER - tab std output
	.8080
	EXT	STDOUT,TABBRF
TABBER:: PUSH	B
	MOV	B,A
	LDA	STDOUT
	MOV	C,A
	MOV	A,B
	CALL	TABBRF
	POP	B
	RET
	END
>>> TABBRF.MAC	820820:2357
; FILE:	TABBRF.MAC
; DATE: 820825:2325
; FOR:	Write blanks to chan. C till col. A

	TITLE	TABBRF - tab to col. A
	.8080
	.XLIST
	INCLUDE SYSEQU
	.LIST
	EXT	PUTCF,FNDCNT,CRLFF
TABBRF:: PUSH	B
	PUSH	H
	MOV	B,A
	MVI	A,2
	CALL	FNDCNT
TB0:	MOV	A,B
	CMP	M
	CC	CRLFF
	JZ	DONE
	MVI	A,BLANK
	CALL	PUTCF
	JMP	TB0
DONE:	MOV	A,B
	POP	H
	POP	B
	RET
	END
>>> TYPAHD.MAC	820901:1338
; FILE:	TYPAHD.MAC
; DATE: 820901:1230
; For:  Disable CONIN, set up typeahead buffer
	.8080
	TITLE	TYPAHD - typeahead buffer
	.XLIST
	INCLUDE LINKEQU
	.LIST
	IF	LYNX
$MEMRY	EQU	108H
	ELSE
	EXT	$MEMRY
	ENDIF
KEYBD	EQU	28H	; Interrupt vector here
KBDPT	EQU	0F8H	; Keyboard port
TYPAHD:: PUSH	H
	PUSH	D
	LHLD	$MEMRY
	INR	H
	MVI	L,0
	SHLD	INPNT
	SHLD	OUTPNT
	INR	H
	SHLD	$MEMRY
	LXI	D,KSR
	LXI	H,KEYBD
	DI
	MVI	M,JMP
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
	EI
	POP	D
	POP	H
	RET
KSR:	PUSH	H
	PUSH	PSW
	LHLD	INPNT
	IN	KBDPT
	ANI	7FH
	MOV	M,A
	INR	L
	SHLD	INPNT
	POP	PSW
	POP	H
	EI
	RET
KEY::	PUSH	H
	LHLD	INPNT
	MOV	A,L
	LHLD	OUTPNT
	SUB	L
	JZ	READ
	MOV	A,M
	INR	L
	SHLD	OUTPNT
READ:	POP	H
	RET
INPNT:	DS	2
OUTPNT:	DS	2
	END
>>> UPCASE.MAC	820820:2357
; FILE:	UPCASE.MAC
; DATE: 820819:1332
; FOR:	Make A uppercase

	TITLE	UPCASE - Make A uppercase
	.8080
UPCASE:: CPI	'a'
	RC
	CPI	'z'+1
	RNC
	ANI	0DFH
	RET
	END
         