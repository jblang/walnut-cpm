TITLE	'LRUNZ  Library Run for ZCPR2 -- a utility for .LBR files'
VERSION EQU	1$0	;82-08-06 Initial source release
	PAGE	60
;
; Requires MAC for assembly.  Due to the complexity of
; the relocation macros, this program may take a while
; to assemble.	Be prepared for periods of no disk activity
; on both passes before pressing panic button.	G.P.N.
;

;--------------------------NOTICE------------------------------
;
;   (c) Copyright 1982	Gary P. Novosielski
;	All rights reserved.
;	
;   The following features courtesy of Ron Fowler:
;	1) command line reparsing and repacking (this allows
;	the former load-only program to become a load & run
;	utility).
;	2) code necessary to actually execute the loaded file
;	3) the HELP facility (LRUN with no arguments)
;	4) modified error routines to avoid warm-boot delay
;	   (return to CCP directly instead)
;	
;	Permission to distribute this program in source or
;	object form without prior written aproval is granted
;	only under the following conditions.
;
;		1. No charge is imposed for the program.
;		2. Charges for incidental costs including
;		   but not limited to media, postage, tele-
;		   communications, and data storage do not
;		   exceed those costs actually incurred.
;		3. This Notice and any copright notices in
;		   the object code remain intact 
;
;			(signed)  Gary P. Novosielski
;
;--------------------------------------------------------------
;
; LRUN is intended to be used in conjunction with libraries
; created with LU.COM, a library utility based upon the
; groundwork laid by Michael Rubenstien, with some additional
; inspiration from Leor Zolman's CLIB librarian for .CRL files.
;
; The user can place the less frequently used command (.COM)
; files in a library to save space, and  still be able to run
; them when required, by typing:
; 	LRUN <normal command line>.
; The name of the library can be specified, but the greatest
; utility will be achieved by placing all commands in one
; library called COMMAND.LBR, or some locally defined name,
; and always letting LRUN use that name as the default.
;

;Syntax:
;	LRUN [-<lbrname>] <command> [<parameters>]
;
;where:
;<lbrname>	is the optional library name.  In the
;		distrubution version, this defaults to
;		COMMAND.LBR.  If the user wishes to use a
;		different name for the default, the 8-byte
;		literal at DFLTNAM below may be changed to
;		suit local requirements. The current drive
;		is searched for the .LBR file, and if not
;		found there, the A: drive is searched.
;		**Note that the leading minus sign (not a part
;		of the name) is required to indicate an
;		override library name is being entered.
;
;<command>	is the name of the .COM file in the library
;
;<line>		is the (possibly empty) set of parameters
;		which are to be passed to <command>, as in
;		normal CP/M syntax.  Notice that if the
;		library name is defaulted, the syntax is
;		simply:
;     LRUN <command line>
;		which is just the normal command line with
;		LRUN prefixed to it.
;

;
; MACROS TO PROVIDE Z80 EXTENSIONS
;   MACROS INCLUDE:
;
$-MACRO 		;FIRST TURN OFF THE EXPANSIONS
;
;	JR	- JUMP RELATIVE
;	JRC	- JUMP RELATIVE IF CARRY
;	JRNC	- JUMP RELATIVE IF NO CARRY
;	JRZ	- JUMP RELATIVE IF ZERO
;	JRNZ	- JUMP RELATIVE IF NO ZERO
;	DJNZ	- DECREMENT B AND JUMP RELATIVE IF NO ZERO
;	LDIR	- MOV @HL TO @DE FOR COUNT IN BC
;	LXXD	- LOAD DOUBLE REG DIRECT
;	SXXD	- STORE DOUBLE REG DIRECT
;
;
;
;	@GENDD MACRO USED FOR CHECKING AND GENERATING
;	8-BIT JUMP RELATIVE DISPLACEMENTS
;
@GENDD	MACRO	?DD	;;USED FOR CHECKING RANGE OF 8-BIT DISPLACEMENTS
	IF (?DD GT 7FH) AND (?DD LT 0FF80H)
	DB	100H	;Displacement Range Error on Jump Relative
	ELSE
	DB	?DD
	ENDIF
	ENDM
;
;
; Z80 MACRO EXTENSIONS
;
JR	MACRO	?N	;;JUMP RELATIVE
	DB	18H
	@GENDD	?N-$-1
	ENDM
;
JRC	MACRO	?N	;;JUMP RELATIVE ON CARRY
	DB	38H
	@GENDD	?N-$-1
	ENDM
;
JRNC	MACRO	?N	;;JUMP RELATIVE ON NO CARRY
	DB	30H
	@GENDD	?N-$-1
	ENDM
;
JRZ	MACRO	?N	;;JUMP RELATIVE ON ZERO
	DB	28H
	@GENDD	?N-$-1
	ENDM
;
JRNZ	MACRO	?N	;;JUMP RELATIVE ON NO ZERO
	DB	20H
	@GENDD	?N-$-1
	ENDM
;
DJNZ	MACRO	?N	;;DECREMENT B AND JUMP RELATIVE ON NO ZERO
	DB	10H
	@GENDD	?N-$-1
	ENDM
;
LDIR	MACRO		;;LDIR
	DB	0EDH,0B0H
	ENDM
;
LDED	MACRO	?N	;;LOAD DE DIRECT
	DB	0EDH,05BH
	DW	?N
	ENDM
;
LBCD	MACRO	?N	;;LOAD BC DIRECT
	DB	0EDH,4BH
	DW	?N
	ENDM
;
SDED	MACRO	?N	;;STORE DE DIRECT
	DB	0EDH,53H
	DW	?N
	ENDM
;
SBCD	MACRO	?N	;;STORE BC DIRECT
	DB	0EDH,43H
	DW	?N
	ENDM
;
; END OF Z80 MACRO EXTENSIONS
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
@LOGV	SET	37	;2.2 only
@RWR0	SET	40	;2.2 only
;
CPMBASE EQU	0
BOOT	SET	CPMBASE
BDOS	SET	BOOT+5
TFCB	EQU	BOOT+5CH
TFCB1	EQU	TFCB
TFCB2	EQU	TFCB+16
TBUFF	EQU	BOOT+80H
TPA	EQU	BOOT+100H
CTRL	EQU	' '-1		;Ctrl char mask
CR	SET	CTRL AND 'M'
LF	SET	CTRL AND 'J'
TAB	SET	CTRL AND 'I'
FF	SET	CTRL AND 'L'
BS	SET	CTRL AND 'H'
FALSE	SET	0
TRUE	SET	NOT FALSE
;
CPM	MACRO	FUNC,OPERAND,CONDTN
	LOCAL	PAST
	IF	NOT NUL CONDTN
	DB	( J&CONDTN ) XOR 8
	DW	PAST
	ENDIF		;;of not nul condtn
	IF	NOT NUL OPERAND
	LXI	D,OPERAND
	ENDIF		;;of not nul operand
	IF	NOT NUL FUNC
	MVI	C,@&FUNC
	ENDIF
	CALL	BDOS
PAST:
	ENDM
;
BLKMOV	MACRO	DEST,SRCE,LEN,COND
	LOCAL	PAST
	JMP	PAST
@BMVSBR:
	MOV	A,B
	ORA	C
	RZ
	DCX	B
	MOV	A,M
	INX	H
	STAX	D
	INX	D
	JMP	@BMVSBR
BLKMOV	MACRO	DST,SRC,LN,CC
	LOCAL	PST
	IF	NOT NUL CC
	DB	( J&CC ) XOR 8
	DW	PST
	ENDIF
	IF	NOT NUL DST
	LXI	D,DST
	ENDIF
	IF	NOT NUL SRC
	LXI	H,SRC
	ENDIF
	IF	NOT NUL LN
	LXI	B,LN
	ENDIF
	CALL	@BMVSBR
	IF	NOT NUL CC
PST:
	ENDIF
	ENDM
PAST:	BLKMOV	DEST,SRCE,LEN,COND
	ENDM

;
OVERLAY SET	0
; Macro Definitions
;
RTAG	MACRO	LBL
??R&LBL EQU	$+2-@BASE
	ENDM
;
RGRND	MACRO	LBL
??R&LBL EQU	0FFFFH
	ENDM
;
R	MACRO	INST
@RLBL	SET	@RLBL+1
	RTAG	%@RLBL
	INST-@BASE
	ENDM
;
NXTRLD	MACRO	NN
@RLD	SET	??R&NN
@NXTRLD SET	@NXTRLD + 1
	ENDM
;
;
; Enter here from Console Command Processor (CCP)
;
	ORG	TPA
CCPIN:
;
;  Branch to Start of Program
;
	jmp	start

;
;******************************************************************
;
;  SINSFORM -- ZCPR2 Utility Standard General Purpose Initialization Format
;
;	This data block precisely defines the data format for
; initial features of a ZCPR2 system which are required for proper
; initialization of the ZCPR2-Specific Routines in SYSLIB.
;

;
;  EXTERNAL PATH DATA
;
EPAVAIL:
	DB	0FFH	; IS EXTERNAL PATH AVAILABLE? (0=NO, 0FFH=YES)
EPADR:
	DW	40H	; ADDRESS OF EXTERNAL PATH IF AVAILABLE

;
;  INTERNAL PATH DATA
;
INTPATH:
	DB	0,0	; DISK, USER FOR FIRST PATH ELEMENT
			; DISK = 1 FOR A, '$' FOR CURRENT
			; USER = NUMBER, '$' FOR CURRENT
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0	; DISK, USER FOR 8TH PATH ELEMENT
	DB	0	; END OF PATH

;
;  MULTIPLE COMMAND LINE BUFFER DATA
;
MCAVAIL:
	DB	0FFH	; IS MULTIPLE COMMAND LINE BUFFER AVAILABLE?
MCADR:
	DW	0FF00H	; ADDRESS OF MULTIPLE COMMAND LINE BUFFER IF AVAILABLE

;
;  DISK/USER LIMITS
;
MDISK:
	DB	4	; MAXIMUM NUMBER OF DISKS
MUSER:
	DB	31	; MAXIMUM USER NUMBER

;
;  FLAGS TO PERMIT LOG IN FOR DIFFERENT USER AREA OR DISK
;
DOK:
	DB	0FFH	; ALLOW DISK CHANGE? (0=NO, 0FFH=YES)
UOK:
	DB	0FFH	; ALLOW USER CHANGE? (0=NO, 0FFH=YES)

;
;  PRIVILEGED USER DATA
;
PUSER:
	DB	10	; BEGINNING OF PRIVILEGED USER AREAS
PPASS:
	DB	'chdir',0	; PASSWORD FOR MOVING INTO PRIV USER AREAS
	DS	41-($-PPASS)	; 40 CHARS MAX IN BUFFER + 1 for ending NULL

;
;  CURRENT USER/DISK INDICATOR
;
CINDIC:
	DB	'$'	; USUAL VALUE (FOR PATH EXPRESSIONS)

;
;  DMA ADDRESS FOR DISK TRANSFERS
;
DMADR:
	DW	80H	; TBUFF AREA

;
;  NAMED DIRECTORY INFORMATION
;
NDRADR:
	DW	00000H	; ADDRESS OF MEMORY-RESIDENT NAMED DIRECTORY
NDNAMES:
	DB	64	; MAX NUMBER OF DIRECTORY NAMES
DNFILE:
	DB	'NAMES   '	; NAME OF DISK NAME FILE
	DB	'DIR'		; TYPE OF DISK NAME FILE

;
;  REQUIREMENTS FLAGS
;
EPREQD:
	DB	0FFH	; EXTERNAL PATH?
MCREQD:
	DB	000H	; MULTIPLE COMMAND LINE?
MXREQD:
	DB	000H	; MAX USER/DISK?
UDREQD:
	DB	000H	; ALLOW USER/DISK CHANGE?
PUREQD:
	DB	000H	; PRIVILEGED USER?
CDREQD:
	DB	0FFH	; CURRENT INDIC AND DMA?
NDREQD:
	DB	000H	; NAMED DIRECTORIES?
Z2CLASS:
	DB	5	; CLASS 5
	DB	'ZCPR2'
	DS	10	; RESERVED

;
;  END OF SINSFORM -- STANDARD DEFAULT PARAMETER DATA
;
;******************************************************************
;
DFLTNAM:
	DB	'COMMAND ' ; <---change this if you like---
LBRLIT:
	DB	'LBR'
;
SIGNON:
	DB	'LRUNZ  Version '	;Signon message
	DB	VERSION/10+'0'
	DB	'.'
	DB	VERSION MOD 10+'0'
	DB	CR,LF
	DB	'$',CTRL AND 'Z'
	DB	' Copyright (c) 1982  Gary P. Novosielski '
	DB	CR,LF
	DB	' Modified for Use Under ZCPR2 by Richard Conn'
	DB	'$',CTRL AND 'Z'
;
;  START OF PROGRAM
;
START:
	LXI	H,0		;get the CCP entry stackpointer
	DAD	SP		;(used only if HELP request
	SHLD	SPSAVE		; is encountered)
	CPM	MSG,SIGNON;	;Display signon
	CALL	SETUP		;initialize.
	LHLD	BDOS+1		;find top of memory
	MOV	A,H		;page address
				;Form destination...
	SUI	PAGES	 	;...address in
	MOV	D,A		;DE pair.
	MVI	E,0
	PUSH	D		;save on stack
;
	BLKMOV	,@BASE,SEGLEN	;Move the active segment.
;
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
;Scan through the newly moved code, and adjust any
;page addresses by adding (H) to them.	The word on
;top of the stack points to the next byte of the
;relocation bit table.	Each bit in the table
;corresponds to one byte in the destination code.
;A value of 1 indicates the byte is to be adjusted.
;A value of 0 indicates the byte is to be unchanged.
;
;Thus one byte of relocation information serves to
;mark 8 bytes of object code.  The bits which have
;not been used yet are saved in L until all 8
;are used.
;
FIXLOOP:
	MOV	A,B
	ORA	C		;test if finished
	JRZ	FIXDONE
	DCX	B		;count down
	MOV	A,E
	ANI	07H		;on 8-byte boundry?
	JRNZ	NEXTBIT
;
NEXTBYT:
;Get another byte of relocation bits
	XTHL
	MOV	A,M
	INX	H
	XTHL
	MOV	L,A		;save in register L
;
NEXTBIT:
	MOV	A,L		;remaining bits from L
	RAL			;next bit to CARRY
	MOV	L,A		;save the rest
	JRNC	NEXTADR
;
;CARRY was = 1.  Fix this byte.
	LDAX	D
	ADD	H		;(H) is the page offset
	STAX	D
;
NEXTADR:
	INX	D
	JR	FIXLOOP
;
;Finished.  Jump to the first address in the new
;segment in high memory.
;
;First adjust the stack.  One garbage word was
;left by fixloop.
;
FIXDONE:
	INX	SP
	INX	SP
;
;(HL) still has the page address
;
	MOV	L,A	;move zero to l
;
;  Set User/Disk for Return
;
	LDA	CDISK	;Set Disk
	MOV	B,A
	LDA	CUSER	;Set User
	MOV	C,A
	PCHL		;Stack is valid
;
;Any one-shot initialization code goes here.
;
SETUP:
	LXI	H,NOLOAD
	SHLD	CCPIN+1 	;Prevent reentry
;
	CALL	REPARS		;Re-parse command line
;
	LXI	D,MEMBER+9	;Check member filetype
	LDAX	D
	CPI	' '		;If blank,
	BLKMOV	,COMLIT,3,Z	; default to COM.
;
	LXI	D,LBRFIL+9	;Check library filetype
	LDAX	D
	CPI	' '		;If blank,
	BLKMOV	,LBRLIT,3,Z	; default to LBR
;
	LXI	D,LBRFIL+1	;Check name
	LDAX	D
	CPI	' '		;If blank,
	BLKMOV	,DFLTNAM,8,Z	; use default name.
;
;  Set Current Disk and User and then Search Along ZCPR2 Path for
;    the Library File
;
	CPM	CUR		;Get Current Disk
	STA	CDISK		;Save It
	CPM	USR,0FFH	;Get Current User
	STA	CUSER		;Save It
	CPM	OPN,LBRFIL	;Try to Open Library File Now
	INR	A		;Zero Means Not Found
	JRNZ	DIROK		;Process if Found
	XRA	A		;Set to Select Current Disk
	STA	LBRFIL
	LXI	H,INTPATH	;Point to Internal Path
	LDA	EPAVAIL		;External Path Available?
	ORA	A		;Zero = No
	JRZ	INPATH
	LHLD	EPADR		;Get Address of External Path
INPATH:
	MOV	A,M		;Get Drive
	ORA	A		;0=Command Not Found
	JZ	NODIR		;Not Found
	ANI	7FH		;Mask MSB
	MOV	B,A		;Save in B for a While
	LDA	CINDIC		;Get Current Indicator
	CMP	B		;Compare for Current
	JRNZ	INPATH1		;Good Disk In B
	LDA	CDISK		;Get Current Disk
	INR	A		;Add 1 to be good
	MOV	B,A		;Disk In B
INPATH1:
	DCR	B		;Disk in Range 0-15
	INX	H		;Pt to User Number
	MOV	A,M		;Get User Number
	INX	H		;Pt to Next Disk
	PUSH	H		;Save Ptr
	ANI	7FH		;Mask User Number
	MOV	C,A		;User in C for now
	LDA	CINDIC		;Compare to Current Indicator
	CMP	C		;See if Current User
	JRNZ	INPATH2		;Good User In C
	LDA	CUSER		;User Current User
	MOV	C,A		;User in C
INPATH2:
	MOV	E,B		;Select Disk
	PUSH	B		;Save User in C
	CPM	DSK		;Set Disk
	POP	D		;Get User in E
	CPM	USR		;Set User
	CPM	DIR,LBRFIL	;See if File Exists in this Directory
	POP	H		;Restore Path Pointer
	INR	A		;Error Code (Not Found) is Zero
	JRZ	INPATH		;Continue Thru Path
DIROPN:
	CPM	OPN,LBRFIL	;Open for directory read.
DIROK:
	CPM	DMA,TBUFF	;Set DMA for Block Read
FINDMBR:
	CPM	FRD,LBRFIL	;Read the directory
	ORA	A
	JNZ	FISHY		;Empty file, Give up.
	LXI	H,TBUFF
	MOV	A,M
	ORA	A
	JNZ	FISHY		;Directory not active??
	MVI	B,8+3		;Check for blanks
	MVI	A,' '
VALIDLOOP:
	INX	H
	CMP	M
	JNZ	FISHY
	DCR	B
	JRNZ	VALIDLOOP
;
	LHLD	TBUFF+1+8+3	;Index must be 0000
	MOV	A,H
	ORA	L
	JNZ	FISHY
;
	LHLD	TBUFF+1+8+3+2	;Get directory size
	DCX	H		;We already read one.
	PUSH	H		;Save on stack
	JR	FINDMBRN	;Jump into loop
FINDMBRL:
	POP	H		;Read sector count from TOS
	MOV	A,H
	ORA	L		;0 ?
	JZ	NOMEMB		;Member not found in library
	DCX	H		;Count down
	PUSH	H		;and put it back.
	CPM	FRD,LBRFIL	;Get next directory sector
	ORA	A
	JNZ	FISHY


FINDMBRN:
	LXI	H,TBUFF   	;Point to buffer.
	MVI	C,128/32	;Number of directory entries
;
FINDMBR1:
	CALL	COMPARE 	;Check if found yet.
	JZ	GETLOC		;Found member in .DIR
	DCR	C
	JRZ	FINDMBRL
;
	LXI	D,32		;No match, point to next one.
	DAD	D
	JR	FINDMBR1
;
GETLOC: 	;The name was found now get index and length
	POP	B	;Clear stack garbage
	XCHG		;Pointer to sector address.
	MOV	E,M	;Get First
	INX	H
	MOV	D,M
	XCHG
	SHLD	INDEX	;Save it
	XCHG
	INX	H	;Get Size to DE
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG		; Size to HL
	SHLD	LENX
	CALL	PACKUP	;Repack command line arguments
	CPM	CON,CR	;do <cr> only (look like CCP)
	RET
;		End of setup.
;
;	Utility subroutines
NEGDE:			;DE = -DE
	MOV	A,D
	CMA
	MOV	D,A
;
	MOV	A,E
	CMA
	MOV	E,A
	INX	D
	RET
;
;	REPARSE re-parses the fcbs from the command line,
;	to allow the "-" character to prefix the library name
;
REPARS:
	LXI	D,MEMBER	;first reinitialize both fcbs
	CALL	NITF
	LXI	D,LBRFIL
	CALL	NITF
	LXI	H,TBUFF 	;store a null at the end of
	MOV	E,M		; the command line (this is
	MVI	D,0		; done by CP/M usually, except
	XCHG			; in the case of a full com-
	DAD	D		; mand line
	INX	H
	MVI	M,0
	XCHG			;tbuff pointer back in hl
SCANBK:
	INX	H		;bump to next char position
	MOV	A,M		;fetch next char
	ORA	A		;reached a null? (no arguments)
	JZ	HELP		;interpret as a call for help
	CPI	' '		;not null, skip blanks
	JRZ	SCANBK
	CPI	'-'		;library name specifier?
	JRNZ	NOTLBR		;skip if not
	INX	H		;it is, skip over flag character
	LXI	D,LBRFIL	;parse library name into FCB
	CALL	GETFN
NOTLBR:
	LXI	D,MEMBER	;now parse the command name
	CALL	GETFN
	LXI	D,HOLD+1	;pnt to temp storage for rest of cmd line
	MVI	B,-1		;init a counter
CLSAVE:
	INR	B		;bump up counter
	MOV	A,M		;fetch a char
	STAX	D		;move it to hold area
	INX	H		;bump pointers
	INX	D
	ORA	A		;test whether char was a terminator
	JRNZ	CLSAVE		;continue moving line if not
	MOV	A,B		;it was, get count
	STA	HOLD		;save it in hold area
	RET
;
;	PACKUP retrieves the command line stored at
;	HOLD and moves it back to tbuff, then reparses
;	the default file control blocks so the command
;	will never know it was run from a library
;
PACKUP:
	LXI	H,HOLD		;point to length byte of HOLD
	MOV	C,M		;get length in BC
	MVI	B,0
	INX	B		;bump up to because length byte doesn't
	INX	B		;  include itself or null terminator
	BLKMOV	TBUFF		;moving everybody to Tbuff
	LXI	H,TBUFF+1	;point to the command tail
	LXI	D,TFCB1 	;first parse out tfcb1
	CALL	GETFN
	LXI	D,TFCB2 	;then tfcb2
	CALL	GETFN
	RET
;
;	Here when HELP is requested (indicated
;	by LRUN with no arguments)
;
HELP:
	CPM	MSG,HLPMSG	;print the HELP message
EXIT:
	LHLD	SPSAVE		;find CCP re-entry adrs
	SPHL			;fix & return
	RET
;
;	the HELP message
;
HLPMSG:
	DB	CR,LF,'Correct syntax is:'
	DB	CR,LF
	DB	LF,TAB,'LRUN [-<lbrname>] <command line>'
	DB	CR,LF
	DB	LF,'Where <lbrname> is the optional library name'
	DB	CR,LF,'(Note the preceding "-".  ) If omitted,'
	DB	CR,LF,'the default command library is used.'
	DB	LF
	DB	CR,LF,'<command line> is the name and parameters'
	DB	CR,LF,'of the command being run from the library,'
	DB	CR,LF,'just as if a separate .COM file were being run.'
	DB	CR,LF,'$'
;
;
COMPARE:		;Test status, name and type of
	PUSH	H		;a directory entry.
	MVI	B,1+8+3
	XCHG			;with the one we're
	LXI	H,MEMBER	;looking for.
COMPAR1:
	LDAX	D
	CMP	M
	JRNZ	COMPEXIT
	INX	D
	INX	H
	DCR	B
	JRNZ	COMPAR1
COMPEXIT:			;Return with DE pointing to
	POP	H		;last match + 1, and HL still
	RET			;pointing to beginning.
;
;
;	File name parsing subroutines
;
; getfn gets a file name from text pointed to by reg hl into
; an fcb pointed to by reg de.	leading delimeters are 
; ignored.
; entry hl	first character to be scanned
;	de	first byte of fcb
; exit	hl	character following file name
;
;
;
GETFN:
	CALL	NITF	;init 1st half of fcb
	CALL	GSTART	;scan to first character of name
	RZ		;end of line was found - leave fcb blank
	CALL	GETDRV	;get drive spec. if present
	CALL	GETPS	;get primary and secondary name
	RET


;
; nitf fills the fcb with dflt info - 0 in drive field
; all-blank in name field, and 0 in ex,s1,s2 and rc flds
;
NITF:
	PUSH	D	;save fcb loc
	XCHG		;move it to hl
	MVI	M,0	;zap dr field
	INX	H	;bump to name field
	MVI	B,11	;zap all of name fld
NITLP1:
	MVI	M,' '
	INX	H
	DJNZ	NITLP1
	MVI	B,4	;zero others
NITLP2:
	MVI	M,0
	INX	H
	DJNZ	NITLP2
	XCHG		;restore hl
	POP	D	;restore fcb pointer
	RET
;
; gstart advances the text pointer (reg hl) to the first
; non delimiter character (i.e. ignores blanks).  returns a
; flag if end of line (00h or ';') is found while scaning.
; exit	hl	pointing to first non delimiter
;	a	clobbered
;	zero	set if end of line was found
;
GSTART:
	CALL	GETCH	;see if pointing to delim?
	RNZ		;nope - return
	CPI	';'	;end of line?
	RZ		;yup - return w/flag
	ORA	A
	RZ		;yup - return w/flag
	INX	H	;nope - move over it
	JR	GSTART	;and try next char
;
; getdrv checks for the presence of a drive spec at the text
; pointer, and if present formats it into the fcb and
; advances the text pointer over it.
; entry hl	text pointer
;	de	pointer to first byte of fcb
; exit	hl	possibly updated text pointer
;	de	pointer to second (primary name) byte of fcb
;
GETDRV:
	INX	D	;point to name if spec not found
	INX	H	;look ahead to see if ':' present
	MOV	A,M
	DCX	H	;put back in case not present
	CPI	':'	;is a drive spec present?
	RNZ		;nope - return
	MOV	A,M	;yup - get the ascii drive name
	SUI	'A'-1	;convert to fcb drive spec
	DCX	D	;point back to drive spec byte
	STAX	D	;store spec into fcb
	INX	D	;point back to name
	INX	H	;skip over drive name
	INX	H	;and over ':'
	RET
;
; getps gets the primary and secondary names into the fcb.
; entry hl	text pointer
; exit	hl	character following secondary name (if present)
;
GETPS:
	MVI	C,8	;max length of primary name
	CALL	GETNAM	;pack primary name into fcb
	MOV	A,M	;see if terminated by a period
	CPI	'.'
	RNZ		;nope - secondary name not given
			;return default (blanks)
	INX	H	;yup - move text pointer over period
FTPOINT:
	MOV	A,C	;yup - update fcb pointer to secondary
	ORA	A
	JRZ	GETFT
	INX	D
	DCR	C
	JR	FTPOINT
GETFT:
	MVI	C,3	;max length of secondary name
	CALL	GETNAM	;pack secondary name into fcb
	RET
;
; getnam copies a name from the text pointer into the fcb for
; a given maximum length or until a delimiter is found, which
; ever occurs first.  if more than the maximum number of
; characters is present, characters are ignored until a
; a delimiter is found.
; entry hl	first character of name to be scaned
;	de	pointer into fcb name field
;	c	maximum length
; exit	hl	pointing to terminating delimiter
;	de	next empty byte in fcb name field
;	c	max length - number of characters transfered
;
GETNAM:
	CALL	GETCH	;are we pointing to a delimiter yet?
	RZ		;if so, name is transfered
	INX	H	;if not, move over character
	CPI	'*'	;ambigious file reference?
	JRZ	AMBIG	;if so, fill the rest of field with '?'
	STAX	D	;if not, just copy into name field
	INX	D	;increment name field pointer
	DCR	C	;if name field full?
	JRNZ	GETNAM	;nope - keep filling
	JR	GETDEL	;yup - ignore until delimiter
AMBIG:
	MVI	A,'?'	;fill character for wild card match
QFILL:
	STAX	D	;fill until field is full
	INX	D
	DCR	C
	JRNZ	QFILL	;fall thru to ingore rest of name
GETDEL:
	CALL	GETCH	;pointing to a delimiter?
	RZ		;yup - all done
	INX	H	;nope - ignore antoher one
	JR	GETDEL
;
; getch gets the character pointed to by the text pointer
; and sets the zero flag if it is a delimiter.
; entry hl	text pointer
; exit	hl	preserved
;	a	character at text pointer
;	z	set if a delimiter
;
GETCH:
	MOV	A,M	;get the character
	CPI	'.'
	RZ
	CPI	','
	RZ	  
	CPI	';'
	RZ
	CPI	' '
	RZ
	CPI	':'
	RZ
	CPI	'='
	RZ
	CPI	'<'
	RZ
	CPI	'>'
	RZ
	ORA	A	;Set zero flag on end of text
	RET
;
;
; Error routines:
;
NODIR:
	CALL	ABEND
	DB	'Library not found'
	DB	'$'
FISHY:
	CALL	ABEND
	DB	'Name after "-" isn''t a library'
	DB	'$'
NOMEMB:
	LXI	H,MEMBER+1	;Pt to first char of Command Name
	MVI	B,8		;Print 8 Chars
NOMEMBL:
	MOV	E,M		;Print Char
	INX	H		;Pt to Next
	PUSH	H		;Save Ptr and Count
	PUSH	B
	CPM	CON
	POP	B
	POP	H
	DJNZ	NOMEMBL
	CALL	ABEND1		;No Initial New Line
	DB	' -- Command not in directory'
	DB	'$'
NOLOAD:
	CALL	ABEND
	DB	'No program in memory'
	DB	'$'
NOFIT:
	POP	B	;Clear Stack
	CALL	ABEND
	DB	'Program too large to load'
	DB	'$'
;
COMLIT:
	DB	'COM'
;
ABEND:
	CPM	MSG,NEWLIN
ABEND1:
	POP	D
	CPM	MSG
	CPM	DEL,SUBFILE
	CPM	MSG,ABTMSG
	JMP	EXIT
ABTMSG:
	DB	' -- Aborting$'
NEWLIN:
	DB	CR,LF,'$'
CDISK:
	DS	1	;CURRENT DISK BUFFER
CUSER:
	DS	1	;CURRENT USER BUFFER
SPSAVE:
	DS	2		;stack pointer save
;
	PAGE
;Adjust location counter to next 256-byte boundry
@BASE	ORG	($ + 0FFH) AND 0FF00H
@RLBL	SET	0
;
; The segment to be relocated goes here.
; Any position dependent (3-byte) instructions
; are handled by the "R" macro.
;*************************************************
;
	PUSH	B	;Save Original User/Disk
 R	<LHLD	LENX>	;Get length of .COM member to load.
	MVI	A,TPA/128
	ADD	L	;Calculate highest address
	MOV	L,A	;To see if it will fit in
	ADC	H	;available memory
	SUB	L
	MOV	H,A
	REPT	7
	DAD	H
	ENDM
	XCHG	
	CALL	NEGDE	;IT'S STILL IN LOW MEMORY
 R	<LXI	H,PROTECT>
	DAD	D
	JNC	NOFIT	;Haven't overwritten it yet.
;
; The library file is still open.  The open FCB has been
; moved up here into high memory with the loader code.
;
LBROPN:
 R	<LHLD	INDEX>		;Set up for random reads
 R	<SHLD	RANDOM>
	XRA	A
 R	<STA	RANDOM+2>
;
	LXI	H,TPA
 R	<SHLD	LOADDR>

;
; This high memory address and above, including CCP, must be
; protected from being overlaid by loaded program
;
PROTECT:
;
LOADLOOP:			;Load that sucker.
 R	<LHLD	LENX>		;See if done yet.
	MOV	A,L
	ORA	H
	JRZ	LOADED
	DCX	H
 R	<SHLD	LENX>
;
 R	<LHLD	LOADDR> 	;Increment for next time
	MOV	D,H
	MOV	E,L
	LXI	B,80H
	DAD	B
 R	<SHLD	LOADDR>
	CPM	DMA		;but use old value (DE)
;
 R	<LXI	D,LBRFIL>
	CPM	RRD		;Read the sector
	ORA	A		;Ok?
	JRNZ	ERR		;No, bail out.
;
 R	<LHLD	RANDOM> 	;Increment random record field
	INX	H
 R	<SHLD	RANDOM>
;
	JR	LOADLOOP	;Until done.
;
ERR:
	MVI	A,( JMP )	;Prevent execution of bad code
	STA	TPA
	LXI	H,BOOT
	SHLD	TPA+1
;
 R	<LXI	D,LDMSG>
	CPM	MSG
 R	<LXI	D,SUBFILE>	;Abort SUBMIT if in progress
	CPM	DEL
LOADED:
	CPM	DMA,TBUFF	;Restore DMA adrs for user pgm
	CPM	CON,LF		;Turn up a new line on console
	POP	B		;Restore Current User/Disk
	PUSH	B		;Save it again
	MOV	E,B		;Restore Disk
	CPM	DSK		;Log In Disk
	POP	D		;E=USER
	CPM	USR		;Log In User
	JMP	TPA
;
LDMSG:
	DB	CR,LF,'Bad Load$'
INDEX:
	DW	0
LENX:
	DW	0
SUBFILE:
	DB	1,'$$$     SUB',0,0,0,0
	;If used, this FCB will clobber the following one.
	;but it's only used on a fatal error, anyway.
LBRFIL:
	DS	32		;Name placed here at setup
	DB	0		;Normal FCB plus...
OVERLAY SET	$		;(Nothing past here but DS's)
RANDOM:
	DS	3		;...Random access bytes
MAXMEM:
	DS	2
LOADDR:
	DS	2
;*************************************************
;End of segment to be relocated.
	IF	OVERLAY EQ 0
OVERLAY SET	$
	ENDIF
;
PAGES	EQU	($-@BASE+0FFH)/256+8
;
SEGLEN	EQU	OVERLAY-@BASE
	ORG	@BASE+SEGLEN
	PAGE
;	Build the relocation information into a
; bit table immediately following.
;
@X	SET	0
@BITCNT SET	0
@RLD	SET	??R1
@NXTRLD SET	2
	RGRND	%@RLBL+1	;define one more label
;
	REPT	SEGLEN+8
	IF	@BITCNT>@RLD
	NXTRLD	%@NXTRLD	;next value
	ENDIF
	IF	@BITCNT=@RLD
@X	SET	@X OR 1 	;mark a bit
	ENDIF
@BITCNT SET	@BITCNT + 1
	IF	@BITCNT MOD 8 = 0
	DB	@X
@X	SET	0	;clear hold variable for more
	ELSE
@X	SET	@X SHL 1	;not 8 yet. move over.
	ENDIF
	ENDM
;
	DB	0
HOLD:
	DB	0,0		;0 length, null terminator
	DS	128-2		;rest of HOLD area
MEMBER:
	DS	16
;
	END	CCPIN
