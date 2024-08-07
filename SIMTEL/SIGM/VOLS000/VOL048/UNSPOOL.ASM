 TITLE 'UNSPOOL Disk to device background process'
;
;	Gary P. Novosielski
;
;NOTE:	This source file requires MAC for assembly.
; Due to the complexity of operations performed by
; the macros which generate the relocation table, the
; assembly process will be significantly longer than
; normal for a program of this size.  Be prepared for
; a long period of no disk activity on each pass before
; pressing the panic button.
;
;Revisions:		(in LIFO order)
;
;2.3	81-11-07
;	Tab expansion for printers which don't
;		respond to the TAB character.
;		Include MACLIB code in source file.
;2.2	81-10-15
;	Add message to inform operator when the spool
;		writer de-installs itself.
;2.1	81-10-05
;	Add disk reset at BOOTREQ to more closely
;		simulate true warm boot.
;
;Version 2
;	Copy BIOS table so application programs will
;	still have BIOS access by using word at BOOT+1.
;	Preserve USER and IOBYTE values as of startup.
;
; BDOS Functions:
;
@SYS	SET	0
@KEY	SET	1
@CON	SET	2
@RDR	SET	3
@PUN	SET	4
@LST	SET	5
@DIO	SET	6
@RIO	SET	7
@SIO	SET	8
@MSG	SET	9
@INP	SET	10
@RDY	SET	11
@VER	SET	12
@LOG	SET	13
@DSK	SET	14
@OPN	SET	15
@CLS	SET	16
@DIR	SET	17
@NXT	SET	18
@DEL	SET	19
@FRD	SET	20
@FWR	SET	21
@MAK	SET	22
@REN	SET	23
@CUR	SET	25
@DMA	SET	26
@CHG	SET	30
@USR	SET	32
@RRD	SET	33
@RWR	SET	34
@SIZ	SET	35
@REC	SET	36
;
;System equates:
CPMBASE	EQU	0
BOOT	SET	CPMBASE
BDOS	SET	BOOT+5
TFCB	EQU	BOOT+5CH
TFCB1	EQU	TFCB
TFCB2	EQU	TFCB+16
TBUFF	EQU	BOOT+80H
TPA	EQU	BOOT+100H
CTRL	EQU	' '-1		;CTRL CHAR MASK
CR	SET	CTRL AND 'M'
LF	SET	CTRL AND 'J'
TAB	SET	CTRL AND 'I'
FF	SET	CTRL AND 'L'
BS	SET	CTRL AND 'H'
EOF	SET	CTRL AND 'Z'
FALSE	EQU	0
TRUE	EQU	NOT FALSE
?	EQU	-1
NVECTS	EQU	16		;NUMBER OF BIOS VECTORS
;
; Assembly options
EXPAND	SET	TRUE	;True to expand tabs
	IF	EXPAND
PHYSBS	SET	TRUE	;True to recognize backspace
	ENDIF
;The flag SAVECCP should be made true if
;the program segment should load below the CCP.
;If false the segment will load in the extreme
;top of the Transient Program Area, overlaying
;the Console Command Processor.
;
SAVECCP	SET	TRUE	;MUST remain true for UNSPOOL
OVERLAY	SET	FALSE	;(initially)
; Macro Definitions
;
; 	Perform a standard BIOS function:
CPM	MACRO	FUNC,OPERAND
	IF	NOT NUL OPERAND
	LXI	D,OPERAND
	ENDIF	;not nul operand
	IF	NOT NUL FUNC
	MVI	C,@&FUNC
	ENDIF	;not nul func
	CALL	BDOS
	ENDM
;
;	Generate a label of the form ??Rnn to tag an
;	address requiring relocation:
RTAG	MACRO	LBL,VAL
??R&LBL EQU	VAL
	ENDM
;
;	Flag <INST> as a relocatable instruction
;	<INST> is of the form: <MNE	OP1[,OP2]>
R	MACRO	INST
@RLBL	SET	@RLBL+1
	RTAG	%@RLBL,%2+$-@BASE
	INST-@BASE
	ENDM
;
; During bit map construction, get the next R-tagged
; address value:
NXTRLD	MACRO	NN
@RLD	SET	??R&NN
@NXTRLD	SET	@NXTRLD + 1
	ENDM
;
;
; Enter here from Console Command Processor (CCP)
;
CCPIN	ORG	TPA
	JMP	INTRO
;
SIGNON:
	DB	'UNSPOOL',TAB,TAB,TAB
	DB	'Ver 2.3'
	IF	EXPAND
	DB	'/T'
	ENDIF	;expand
	DB	'$'
;
INTRO:
	CPM	MSG,SIGNON
	CALL	SETUP		;initialize.
	LXI	H,BDOS+2	;find top of memory
	MOV	A,M		;page address
				;Form destination...
	SUI	PAGES+1		;...address in
	MOV	D,A		;DE pair.
	MVI	E,0
	PUSH	D		;save on stack
	LXI	H,@BASE		;source address
	LXI	B,SEGLEN
;
MOVLOOP:
;Move (HL) to (DE) for (BC) bytes
	MOV	A,B
	ORA	C		;test for (BC) = 0
	JZ	MOVDONE
	DCX	B		;count down
	MOV	A,M		;move a byte
	STAX	D
	INX	D		;bump the pointers
	INX	H
	JMP	MOVLOOP
;
MOVDONE:
;The segment is now moved to high memory, but not
;properly relocated.  The bit table which specifies
;which addresses need to be adjusted is located
;just after the last byte of the source segment,
;so (HL) is now pointing at it.
	POP	D	;beginning of newly moved code.
	LXI	B,SEGLEN;length of segment
	PUSH	H	;save pointer to reloc info
	MOV	H,D	;offset page address
;
FIXLOOP:
;Scan through the newly moved code, and adjust any
;page addresses by adding (H) to them.  The word on
;top of the stack points to the next byte of the
;relocation bit table.  Each bit in the table
;corresponds to one byte in the destination code.
;A value of 1 indicates the byte is to be adjusted.
;A value of 0 indicates the byte is to be unchanged.
;
;Thus one byte of relocation information serves to
;mark 8 bytes of object code.  The bits which have
;not been used yet are saved in L until all 8
;are used.
;
	MOV	A,B
	ORA	C		;test if finished
	JZ	FIXDONE
	DCX	B		;count down
	MOV	A,E
	ANI	07H		;on 8-byte boundry?
	JNZ	NEXTBIT
;
NEXTBYT:
;Get another byte of relocation bits
	XTHL
	MOV	A,M
	INX	H
	XTHL
	MOV	L,A		;save in register L
;
NEXTBIT	MOV	A,L		;remaining bits from L
	RAL			;next bit to CARRY
	MOV	L,A		;save the rest
	JNC	NEXTADR
;
;CARRY was = 1.  Fix this byte.
	LDAX	D
	ADD	H		;(H) is the page offset
	STAX	D
;
NEXTADR	INX	D
	JMP	FIXLOOP
;
FIXDONE:
;Finished.  Jump to the first address in the new
;segment in high memory.
;
;First adjust the stack.  One garbage word was
;left by fixloop.
	INX	SP
	INX	SP
;
;(HL) still has the page address
	MOV	L,A	;move zero to l
	PCHL		;Top-of-stack is CCP return
SETUP:
;First, check environment to see if BIOS vectors
;are accessible.
	LDA	BOOT		;Location BOOT should
	CPI	( JMP )		;have a JMP instruction
	JNZ	VECTERR
	LHLD	BOOT+1		;Location one has a
	MOV	A,L		;low byte of
	CPI	3		; 03H
	JNZ	VECTERR
	MVI	C,NVECTS	;which is the origin
				;of a table of jumps
				;which we move into
				;the code.
	LXI	D,BIOSV
	XCHG
VLOOP:
	LDAX	D
	CMP	M		;another JMP
	JNZ	VECTERR
	INX	D
	INX	H
	LDAX	D
	MOV	M,A
	INX	D
	INX	H
	LDAX	D
	MOV	M,A
	INX	H
	INX	D
	DCR	C
	JNZ	VLOOP
; Save old vectors and CCP return address
	LHLD	BOOT+1
	SHLD	OLDBOOT
;
	LXI	H,2
	DAD	SP
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	SHLD	CCPRET+1
;
	LHLD	BDOS+1
	SHLD	GOBDOS+1
SETUPDEV:
	LXI	D,TFCB2+1
	LDAX	D
	CPI	' '
	JZ	SETUPFIL
;
	LXI	H,LSTLIT
	MVI	B,4
	CALL	SCOMP
	JZ	SETUPFIL;	Use default
;
	LXI	D,TFCB2+1
	LXI	H,PUNLIT
	MVI	B,4
	CALL	SCOMP
	JNZ	DEVERR
	MVI	A,@PUN
	STA	DEVICE
SETUPFIL:
	LDA	TFCB1
	ORA	A
	JNZ	OPENIT
;The drive has been defaulted.  Make it explicit
;in case the default drive is changed while the
;file is being unspooled.
	CPM	CUR;	Returns A: as 00
	INR	A;	Open needs A: as 01
	STA	TFCB1
OPENIT:
	CPM	OPN,TFCB1
	INR	A
	JNZ	COPYFCB
;Error.  Can't open input file.
	LXI	H,TBUFF
	MOV	A,M
	ADD	L
	MOV	L,A
	ADC	H
	SUB	L
	MOV	H,A
	INX	H
	MVI	M,'?'
	INX	H
	MVI	M,'$'
	CPM	CON,CR
	CPM	CON,LF
	CPM	MSG,TBUFF+1
	POP	H;	Adjust stack
	RET;		Exit to CCP
;
COPYFCB:
	LXI	H,TFCB1
	LXI	D,FCB
	MVI	C,33
COPY1	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	C
	JNZ	COPY1
;
SETUPUSR:
;	Save user number in effect at time of entry
	CPM	USR,?
	STA	ENTUSR
;
SETUPIOB:
;	Save IOBYTE in effect at time of entry
	CPM	RIO
	STA	ENTIOB
;
	RET
;
SCOMP:
	LDAX	D
	CMP	M
	RNZ
	INX	D
	INX	H
	DCR	B
	JNZ	SCOMP
	RET
;
DEVERR:
	CPM	MSG,DEVERRMSG
	POP	H;	Adjust stack
	RET;		Exit to CCP
VECTERR:
	CPM	MSG,VCTERRMSG
	JMP	BOOT	;try re-booting.
;
LSTLIT:
	DB	'LST '		;Note trailing blank
PUNLIT:
	DB	'PUN '		;Note trailing blank
DEVERRMSG:
	DB	CR,LF,'Invalid device.$'
VCTERRMSG:
	DB	CR,LF,'Error in system table.  '
	DB	'Attempting re-boot.$'
	PAGE
;Align location counter to next page boundry
@BASE	ORG	($ + 0FFH) AND 0FF00H
@RLBL	SET	0
;
; The segment to be relocated goes here.
; Any position dependent (3-byte) instructions
; are handled by the "R" macro.
; For readability, the macro name "R" is placed in
; column 2.  The preceding blank must be present to
; distinguish it from a label.
;*************************************************
BDOSV:
;After the first pass, this location will point
;to INTERCEPT: and is pointed to by BDOS.
;It must be the lowest address
;in the protected segment of code.
 R	<JMP	BOOTREQ>	;complete installation
BIOSV:
	REPT	NVECTS
	JMP	?
	ENDM
LSTSTAT	EQU	BIOSV + (14*3)
;
INTERCEPT:
	MOV	A,C;		Get function
	CPI	@KEY;	Is it single key input?
 R	<JZ	WAITING>
	CPI	@INP;	or buffered input?
 R	<JNZ	CKDMA>
WAITING:
;Wait for actual keypress before honoring input
;request.  Unspool characters in the meantime.
 R	<LDA	ACTIVE>
	ORA	A;	See if finished.
 R	<CNZ	PROCESS>
 R	<JMP	GOBDOS>;	Honor the input request
;
CKDMA	CPI	@DMA;	If the DMA address is being
		;	changed, we have to know.
 R	<JNZ	GOBDOS>
	XCHG
 R	<SHLD	DMAHOLD>
	XCHG
;
GOBDOS	JMP	?;		Patched on entry
		;	points to "real" BDOS routine.
;
;
PROCESS:
;The application program is now waiting for a key
;to be input.  We will use this opportunity to print
;some characters to the device until a key is
;actually pressed.
	LXI	H,0
	DAD	SP
 R	<LXI	SP,LCLSTACK>
	PUSH	H;	Save old SP
	PUSH	B
	PUSH	D;	Save entry parameters
	MVI	C,@RIO;	Save old IOBYTE
 R	<CALL	GOBDOS>
 R	<STA	IOBHOLD>
PROC1:
 R	<CALL	CKKEY>;	Check for keypress.
 R	<JNZ	PROCEXIT>
 R	<LDA	DEVICE>		;Check device being used
	CPI	@LST
 R	<JNZ	PROC2>		;If it is LST:
 R	<CALL	LSTSTAT>
	ORA	A
 R	<JZ	PROC1>		;Loop if not ready
;
PROC2:
	IF	EXPAND
 R	<LDA	TABFLAG>;	In a tab sequence?
 	ORA	A
 R	<JNZ	TABSEQ>
	ENDIF	;EXPAND
;
 R	<LXI	H,BUFFER>
	MOV	A,M
	ORA	A
 R	<CM	FILLBUFF>
 R	<JC	ENDFILE>
	INR	A
	MOV	M,A
	MOV	C,A
	MVI	B,0
	DAD	B;	Point to the buffered char.
	MOV	A,M
	CPI	EOF
 R	<JZ	ENDFILE>
	IF	EXPAND
 R	<LXI	H,LINEPOS>;	Print head position.
;
	CPI	TAB;		Is this a tab?
 R	<JZ	HNDTAB>;	Process it.
;
	IF	PHYSBS
	CPI	BS;		Backspace?
 R	<JNZ	PROC3>
	DCR	M;		Back up 1 column
 R	<JMP	PROC9>
PROC3:
	ENDIF	;PHYSBS
	CPI	CR;		End of line?
 R	<JNZ	PROC4>
	MVI	M,0;		Reset column count.
 R	<JMP	PROC9>
PROC4:
	CPI	' ';		Other ctrl char?
 R	<JC	PROC9>;		Dont change column.
PROC5:
	INR	M;		Increase column.
PROC9:
	ENDIF	;EXPAND
	MOV	E,A
	PUSH	D	;SAVE CHARACTER
;Set the IOBYTE as it was when UNSPOOL was
;started.
 R	<LDA	ENTIOB>
	MOV	E,A
	MVI	C,@SIO
 R	<CALL	GOBDOS>
	POP	D	;RESTORE CHARACTER
	MVI	C,@LST;		Default
DEVICE	EQU	$-1;		Device code patch
 R	<CALL	GOBDOS>
 R	<LDA	IOBHOLD>;	Restore active IOBYTE
	MOV	E,A
	MVI	C,@SIO
 R	<CALL	GOBDOS>
 R	<JMP	PROC1>
;
	IF	EXPAND
HNDTAB:
 R	<STA	TABFLAG>;	Set the flag
SPCOUT:
	MVI	A,' '
 R	<JMP	PROC5>
;
TABSEQ:
 R	<LXI	H,LINEPOS>
	MVI	A,7
	ANA	M;	Check if more blanks needed
 R	<JNZ	SPCOUT>
 R	<STA	TABFLAG>;	Clear the flag
 R	<JMP	PROC1>
	ENDIF	;EXPAND
ENDFILE:
	XRA	A
 R	<STA	ACTIVE>
;
PROCEXIT:
	POP	D
	POP	B
	POP	H;	Restore SP
	SPHL
	RET
;
;
FILLBUFF:
;Fill the buffer from the file
	PUSH	H
	INX	H
	XCHG;		Buffer address to DE
 	MVI	C,@DMA;	Set DMA address
 R	<CALL	GOBDOS>
	MVI	E,?
	MVI	C,@USR
 R	<CALL	GOBDOS>;	Get current user
 R	<STA	USRHOLD>;	Save it
 R	<LDA	ENTUSR>;	Change to user at entry
	MOV	E,A
	MVI	C,@USR
 R	<CALL	GOBDOS>
 R	<LXI	D,FCB>
	MVI	C,@FRD;		Read a sector
 R	<CALL	GOBDOS>
	PUSH	PSW;	Save read return code
 R	<LHLD	DMAHOLD>
	XCHG;		Restore DMA address
	MVI	C,@DMA;	to old value.
 R	<CALL	GOBDOS>
 R	<LDA	USRHOLD>
	MOV	E,A;	Restore User number
	MVI	C,@USR;	to old value
 R	<CALL	GOBDOS>
	POP	PSW;	Read return code
	POP	H;	Buffer pointer
	ORA	A;	How went the read?
	RZ;		Fine
	STC;		No good. Set CARRY for EOF
	RET
;
CKKEY:
;Return zero flag if key not pressed
	MVI	C,@RDY
 R	<CALL	GOBDOS>
	ORA	A
	RET
;
;
BOOTREQ:
;The application process has requested a reboot
;by jumping to location 0.  If we are no longer
;active, we will honor the request by executing
;the address found in the BOOT vector at entry.
;Otherwise return to CCP without rebooting.
	LXI	SP,CCPIN	;set up a valid stack
 R	<LDA	ACTIVE>
	ORA	A
 R	<JNZ	NOTYET>
;Jump to old boot address as read from memory
;word 1 before we changed it.
 R	<LXI	D,DONEMSG>
	MVI	C,@MSG
 R	<CALL	GOBDOS>
 R	<LHLD	OLDBOOT>
	PCHL
;
NOTYET	LXI	H,TBUFF
 R	<SHLD	DMAHOLD>
	MVI	C,@LOG
 R	<CALL	GOBDOS>
 R	<LXI	D,ACTMSG>
	MVI	C,@MSG
 R	<CALL	GOBDOS>
 R	<LXI	H,INTERCEPT>
 R	<SHLD	BDOSV+1>
 R	<LXI	H,BDOSV>
	SHLD	BDOS+1
 R	<LXI	H,BOOTREQ>
 R	<SHLD	BIOSV+1>
 R	<LXI	H,BIOSV>
	SHLD	BOOT+1
CCPRET:
	JMP	?;	Patched on startup
;
ACTMSG:	DB	CR,LF
	DB	'Unspooling in progress.'
	DB	'$'
DONEMSG:
	DB	CR,LF,'UNSPOOL Completed.'
	DB	'$'
OLDBOOT	DW	?
DMAHOLD	DW	TBUFF
ACTIVE	DB	TRUE
	IF	EXPAND
TABFLAG	DB	FALSE
LINEPOS	DB	0
	ENDIF	;EXPAND
USRHOLD	DB	?
ENTUSR	DB	?
IOBHOLD	DB	?
ENTIOB	DB	?
FCB	DS	33
BUFFER	DB	?
OVERLAY	SET	$	;Bit table may start here
	DS	128
	DS	32;	LOCAL STACK AT LEAST 16 WORDS
;			PLUS WHATEVER'S LEFT OVER
LCLSTACK EQU	($+0FFH) AND 0FF00H
;*************************************************
;End of segment to be relocated.
	IF	SAVECCP
PAGES	EQU	($-@BASE)/256+8
	ELSE
PAGES	EQU	($-@BASE)/256
	ENDIF	;saveccp
;
	IF	OVERLAY NE FALSE
	;cause relocation map to slide down into
	;unused DS area:
SEGLEN	EQU	OVERLAY-@BASE
	ORG	@BASE+SEGLEN
	ELSE
	;relocation bit map starts here:
SEGLEN	EQU	$-@BASE
	ENDIF	;overlay
	PAGE
;	Build the relocation information into a
; bit map following the code.
;
@X	SET	0
@BITCNT	SET	0
@RLD	SET	??R1
@NXTRLD SET	2
	RTAG	%@RLBL+1,0FFFFH	;define one more symbol
;
	REPT	SEGLEN+8
	IF	@BITCNT>@RLD
