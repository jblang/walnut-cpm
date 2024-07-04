;+----------------------------------------------------------------------+
;|                                                                      |
;|                            ESET.ASM                                  |
;|     Public Domain - 1984   Konrad Roeder, Albuquerque, NM            |
;|                                                                      |
;+----------------------------------------------------------------------+
;
;
; Revision Log:
;
	7/16/84	V1.0	release to AMPRO-1
;
; Purpose:
;
; ESET allows any one of the four possible drives A, B, C, and D,
; to read a foreign format.  The emulated foreign drive is called
; "E" when it is used with the foreign format and by its regular
; name when it is used with the normal format of the machine.
;
; ESET changes the specifications of the "E" drive in four areas:
;	1 - Disk Drive Select Byte
;	2 - Type Byte
;	3 - Disk Parameter Block
;	4 - Skew Table
;
; The following is a description of those data structures:
;
; DISK DRIVE SELECT BYTE
; Tells the system which drive is aliased to the foreign format "E"
;	00 - A	01 - B	02 - C	03 - D
;
; TYPE BYTE
;
;
;	bit 7	  density: 0=single; 1=double
;	bit 6	  double sided media if = 1
;	bit 5	  double sided mode:
;				1 = continuous sector numbers (first
;				    sector on side one = last sector
;				    on side 0 + 1).
;				    both tracks are treated as a 
;				    single track with twice as many
;				    sectors.
;				0 = same sectors on both sides
;				    (normal method)
;	bit 4	  reserved 
;	bits 3-2  00 = 1k allocation blocks
;		  01 = 2k allocation blocks
;		  10 = not used
;		  11 = not used
;	bits 1-0  00 = 128 byte sectors
;		  01 = 256 byte sectors
;		  10 = 512 byte sectors
;		  11 = 1024 byte sectors 
;
;
; DISK PARAMETER BLOCK
; The disk parameter block tells the system about how the data
; is arranged on the disk.  The DPB has ten entries:
;	SPT	Sectors Per Track		(word)
;	BSH	Block SHift			(byte)
;	BLM	BLock Mask			(byte)
;	EXM	EXtent Mask			(byte)
;	DSM	Directory Size Minus one	(word)
;	DRM	DiRectory entries Minus one	(word)
;	AL0	directory group ALlocation 0	(byte)
;	AL1	directory group ALlocation 1	(byte)
;	CKS	ChecK Size			(word)
;	OFF	OFFset (# reserved tracks)	(word)
;
; SKEW TABLE
; The skew table translates between logical and physical sector
; numbers.  On some systems the sectors are not contiguously
; arranged so that access times can be improved.
;
; 
*********************************************************************
CR:	EQU	0DH		;carrige return 
LF:	EQU	0AH		;line feed
ESC:	EQU	01BH		;escape
CAPS:	EQU	05FH		;upper case
FF:	EQU	0CH		;form feed
ETX:	EQU	3		;^c

	ORG	0100H		;base of tpa
BEGIN:	JMP	START		;leave room for copyright
	;
	DB	' MULTIDSK Vers 1.4 Copyright (c) 1984'
	DB	' AMPRO Computers, Inc. '
	;
START:	LXI	H,0		;zero out h&l
	DAD	SP		;add sp to hl
	SHLD	OLDSP		;save it
	LXI	SP,STACK 	;set up new stack	
	;
	;ckdrv loads the default drive and compares it
	;against the e drive which isn't allowed.  prints
	;error message if true.
	;
CKDRV:	LDA	4		;get default drive
	CPI	4		;is it drive "e"?
	JZ	WRGDRV		;get ready to quit if it is
	;
	;eaddr gets the location of eparm in the bios.
	;
EADDR:	LHLD	1		;get warm boot vector
	MVI	L,36H		;getedsk offset
	LXI	D,BIORET 	;point to bios return point
	PUSH	D		;save d
	PCHL			;return with dpb addr
	;
	;bioret returns with the bios location of eparm
	;and saves it for use later.
	;
BIORET: DCX	H		;back up to type byte location
	SHLD	ADDR		;save location
	;
	;print the signon message.
	;
SIGN:	LXI	D,SIGNON 	;point to sign on message
	CALL	OUTPUT		;
	;
	;getdrv checks which drive is selected as the "e" drive.
	;
GETDRV:	CALL	CONIN		;get drive selection
	CPI	ESC		;esc?
	JZ	DONE		;endit
	CPI	ETX		;^c?
	JZ	DONE		;
	ANI	CAPS		;force upper case
	CPI	'A'		;a?
	JZ	PTMAIN		;
	CPI	'B'		;b?
	JZ	PTMAIN		;
	CPI	'C'		;c?
	JZ	PTMAIN		;
	CPI	'D'		;d?
	JZ	PTMAIN		;
	JMP	GETDRV		;do it until you get it right!
	;
	;
	; ptmain is the section that builds the type byte
	;
PTMAIN: STA	DRSEL+7		;store drive in signoff message
	SUI	41H		;ascii -> hex
	STA	DRIVE		;save drive selected
	XRA	A		;clear type byte
	STA	TYPE
	LXI	D,SELFMT
	CALL 	OUTPUT		;print the format selection
GETFMT:	CALL	CONIN		;get the format selection
	CPI	ESC		;esc?
	JZ	PTMAIN		;start over
	CPI	ETX		;ctrl-c?
	JZ	DONE
	ANI	CAPS		;force caps
	CPI	'A'		;a?
	JZ	FMTA
	CPI	'B'		;b?
	JZ	FMTB
	CPI	'C'		;c?
	JZ	FMTC
	CPI	'D'		;d?
	JZ	FMTD
	JMP	GETFMT		;back until its ok
FMTA:	JMP	PTALL		;sssd = 00xxxxxx (no change)
FMTB:	LDA	TYPE		;ssdd = 10xxxxxx
	ORI	80H
	STA	TYPE
	JMP	PTALL
FMTC:	LDA	TYPE		;dssd = 01xxxxxx
	ORI	40H
	STA	TYPE
	JMP     PTSEC
FMTD:	LDA	TYPE		;dsdd = 11xxxxxx
	ORI	0C0H
	STA	TYPE
	JMP	PTSEC
PTSEC:	LXI	D,SELSEC
	CALL	OUTPUT
GETSEC:	CALL	CONIN		;get sector numbering
	CPI	ESC		;esc?
	JZ	PTMAIN
	CPI	ETX		;ctrl-c?
	JZ	DONE
	ANI	CAPS
	CPI	'A'		;a?
	JZ	SECA
	CPI	'B'		;b?
	JZ	SECB
	JMP	GETSEC
	;
SECA:	LDA	TYPE		; continuous xx1xxxxx
	ORI	20H
	STA	TYPE
	JMP	PTALL
SECB:	JMP	PTALL		; same       xx0xxxxx (no change)
	;
PTALL:	LXI	D,SELALL
	CALL	OUTPUT
GETALL:	CALL	CONIN		; get allocation block size
	CPI	ESC		;esc?
	JZ	PTMAIN		; if so -- start over
	CPI	ETX		;ctrl-c?
	JZ	DONE		; if so -- bye
	ANI	CAPS		; convert to caps
	CPI	'A'		;a?
	JZ	ALLA
	CPI	'B'		;b?
	JZ	ALLB
	JMP	GETALL
ALLA:	JMP	PTBPS		; 1k xxxx00xx 
ALLB:	LDA	TYPE		; 2k xxxx01xx
	ORI	04H
	STA	TYPE
PTBPS:	LXI	D,SELBPS	; get bytes per sector memu
	CALL 	OUTPUT
GETBPS:	CALL	CONIN		; get bps
	CPI	ESC		;esc?
	JZ	PTMAIN		; if so -- start over
	CPI	ETX		;ctrl-c?
	JZ	DONE		; if so -- bye
	ANI	CAPS		; caps to caps
	CPI	'A'		;a?
	JZ	BPSA
	CPI	'B'		;b?
	JZ	BPSB
	CPI	'C'		;c?
	JZ	BPSC
	CPI	'D'		;d?
	JZ	BPSD
	JMP	GETBPS
BPSA	JMP	FCMAIN		; 128 bps xxxxxx00
BPSB	LDA	TYPE		; 256 bps xxxxxx01
	ORI	01H
	STA	TYPE
	JMP	FCMAIN
BPSC	LDA	TYPE		; 512 bps xxxxxx10
	ORI	02H
	STA	TYPE
	JMP	FCMAIN
BPSD	LDA	TYPE		;1024 bps xxxxxx11
	ORI	03H
	STA	TYPE
FCMAIN:	LXI	D,SELSPT	;sectors per track   (word)
	CALL	OUTPUT
	CALL	DBIN
	SHLD	DPB		;store in dpb & dpb + 1
	LXI	D,SELBSH	;block shift         (byte)
	CALL	OUTPUT
	CALL	DBIN
	MOV	A,L		;store in dpb+2
	STA	DPB+2
	LXI	D,SELBLM	;block mask          (byte)
	CALL	OUTPUT
	CALL	DBIN
	MOV	A,L		;store in dpb+3
	STA	DPB+3
	LXI	D,SELEXM	;extent mask         (byte)
	CALL	OUTPUT
	CALL	DBIN
	MOV	A,L		;store in dpb+4
	STA	DPB+4
	LXI	D,SELDSM	;disk size - 1       (word)
	CALL	OUTPUT
	CALL	DBIN
	SHLD	DPB+5
	LXI	D,SELDRM	;# directories - 1   (word)
	CALL	OUTPUT
	CALL	DBIN
	SHLD	DPB+7
	LXI	D,SELAL0	;allocation 0        (byte)
	CALL	OUTPUT
	CALL	DBIN
	MOV	A,L
	STA	DPB+9
	LXI	D,SELAL1	;allocation 1        (byte)
	CALL	OUTPUT
	CALL	DBIN
	MOV	A,L
	STA	DPB+10
	LXI	D,SELCKS	;dir check size      (word)
	CALL	OUTPUT
	CALL	DBIN
	SHLD	DPB+11
	LXI	D,SELOFF	;reserved tracks     (word)
	CALL	OUTPUT
	CALL	DBIN
	SHLD	DPB+13
	LXI	D,SELOK
	CALL 	OUTPUT
GETOK:	CALL	CONIN
	CPI	ETX
	JZ	DONE
	ANI	CAPS
	CPI	'Y'
	JZ	PTSKW
	CPI	'N'
	JZ	FCMAIN
	JMP	GETOK
PTSKW:	LXI	D,SELSKW
	CALL	OUTPUT
GETSKW:	CALL	CONIN
	CPI	ESC		;esc?
	JZ	PTSKW
	CPI	ETX		;ctrl-c?
	JZ	DONE
	ANI	CAPS
	CPI	'A'
	JZ	SKWWA
	CPI	'B'
	JZ	SKWWB
	CPI	'C'
	JZ	SKWWC
	CPI	'D'
	JZ	SKWWD
	CPI	'E'
	JZ	SKWWE
	CPI	'F'
	JZ	SKWWF
	CPI	'G'
	JZ	SKWWG
	CPI	'H'
	JZ	SKWWH
	CPI	'I'
	JZ	SKWWI
	CPI	'J'
	JZ	SKWWJ
	CPI	'K'
	JZ	SKWWK
	CPI	'L'
	JZ	SKWWL
	CPI	'M'
	JZ	SKWWM
	CPI	'N'
	JZ	SKWWN
	CPI	'O'
	JZ	SKWWO
	CPI	'P'
	JZ	SKWWP
	CPI	'Z'
	JZ	MKSKW
	JMP	GETSKW
SKWWA:	LXI	D,SKWA
	JMP	SKWFIN
SKWWB:	LXI	D,SKWB
	JMP	SKWFIN
SKWWC:	LXI	D,SKWC
	JMP	SKWFIN
SKWWD:	LXI	D,SKWD
	JMP	SKWFIN
SKWWE:	LXI	D,SKWE
	JMP	SKWFIN
SKWWF:	LXI	D,SKWF
	JMP	SKWFIN
SKWWG:	LXI	D,SKWG
	JMP	SKWFIN
SKWWH:	LXI	D,SKWH
	JMP	SKWFIN
SKWWI:	LXI	D,SKWI
	JMP	SKWFIN
SKWWJ:	LXI	D,SKWJ
	JMP	SKWFIN
SKWWK:	LXI	D,SKWK
	JMP	SKWFIN
SKWWL:	LXI	D,SKWL
	JMP	SKWFIN
SKWWM:	LXI	D,SKWM
	JMP	SKWFIN
SKWWN:	LXI	D,SKWN
	JMP	SKWFIN
SKWWO:	LXI	D,SKWO
	JMP	SKWFIN
SKWWP:	LXI	D,SKWP
	JMP	SKWFIN
MKSKW:	LXI	D,MKMSG		;did not find the skew table,
				;so we will build one!
	CALL	OUTPUT
	LXI	H,SKW		;hl will point at the temp buffer
	MVI	B,20		;b will count out twenty entries
MKSKW1:	PUSH	B		;save b for now
	PUSH	H		;hl too
	LXI	D,PROMPT	;print the prompt
	CALL	OUTPUT
	CALL	DBIN		;get a value in decimal -> hl
	MOV	A,L
	POP	H		;get the address it goes into
	MOV	M,A		;and move it there
	INX	H
	POP	B
	DCR	B		;count down
	JNZ	MKSKW1		;not done yet - go again
	LXI	D,SKWOK		;ask 'em if its ok
	CALL	OUTPUT
GETSOK:	CALL	CONIN		;get their answer
	CPI	ETX		;ctrl-c?
	JZ	DONE		;end it
	ANI	CAPS		;convert to caps
	CPI	'Y'		;y?
	JZ	LDDPB
	CPI	'N'		;n?
	JZ	MKSKW
	JMP	GETSOK		;someday they may type y or n!
	;
SKWFIN:	LXI	H,SKW
	MVI	B,20
	CALL	LOOP	;move the appropriate skew table in the
			;temporary buffer area
	;
	;
	;
	; move the temporary buffer area into bios
	;
LDDPB:	LHLD	ADDR	;get bios pointer back
	MVI	B,37	;number of bytes to move (1+15+1+20)
	LXI	D,TYPE	;point to the temporary dpb
	CALL	LOOP
;
; clean up
;
	LXI	D,SGNOFF
	CALL	OUTPUT
	LHLD	OLDSP
	SPHL		;put the old stack back into use
	JMP	0H	;go to bios reset address
	;
	;
	;

	;conin gets a character from the console through bios and
	;puts it in the accumulator.
	;
CONIN:	MVI	A,9		; bios call avoids echo to console
	LHLD	1
	MOV	L,A
	PCHL
	;
	;
	;conout gets a single character from the accumulator and
	;sends it to the console through bios
	;
CONOUT: MOV	C,A
	MVI	A,12
	LHLD	1
	MOV	L,A
	PCHL
	;
 	;
	;output sends the message pointed to by de to the screen.
	;
OUTPUT:	MVI	C,9		;print string function
	CALL	5		;bdos
	RET			;
	;
	;
	; dbin ascii decimal to 16 bits in hl
	;
DBIN:	PUSH	D		;save registers
	LXI	H,0		;clear hl
DBIN2:	PUSH	H		;save hl
	CALL	CONIN
	POP	H
	CPI	ETX		;ctrl-c?
	JZ	ABORT
	CPI	CR		;return?
	JZ	DBIN3
	PUSH	H
	CALL	CONOUT
	POP	H
	SUI	'0'		;convert this digit to binary
	JC	DBIN4		; <0
	CPI	10
	JNC	ERRDB		; >10
	MOV	D,H		; hl -> de
	MOV	E,L
	DAD	H		; *2
	DAD	H		; *4
	DAD	D		; *5
	DAD	H		; *10
	MOV	E,A		; new byte -> de
	MOV	D,0
	DAD	D		; de + hl -> hl
	JMP	DBIN2		; next
DBIN4:	CPI	(' '-'0') AND 0FFH
	JNZ	ERRDB		;not blank
DBIN3:	POP	D		;restore
	RET
ERRDB:	LXI	D,DBERR
	CALL	OUTPUT
	POP	D
	JMP	DBIN		;try again
ABORT:	POP	D
	JMP	DONE
DBERR:	DB	CR,LF,' unrecognizable digit on input -- try again :$'
	;
	;
	;loop moves data from an address pointed to by de
	;                  to an address pointed to by hl
	;		   for b bytes.
	;
LOOP:	LDAX	D		
	MOV	M,A
	INX	D
	INX	H
	DCR	B
	JNZ	LOOP	;loop until done
	RET
	;
	;
	;
	;
	;the signon message...
	;
SIGNON:	DB	CR,LF
	DB	FF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	LF
	DB	' ESET prepares your AMPRO system to read, write, '
	DB	'diskettes formatted for',CR,LF,' many other'
	DB	' computers not supported by MULTIDSK '
	DB	CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	' Which drive do you wish to use as the "E" drive? '
	DB	'(A,B,C or D) $'
	;
SELFMT:	DB	CR,LF
	DB	FF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	'Defining TYPE byte for drive "E" ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	' A) single sided, single density ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' B) single sided, double density ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' C) double sided, single density ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' D) double sided, double density ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' Select a FORMAT or <ESC> to start over:$'
SELSEC:	DB	CR,LF
	DB	FF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' A) Continuous sector numbers -- ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	'    first sector on side 1 = last sector on side 0 + 1'
	DB	CR,LF,0,0,0,0,0,0,0,0,0
	DB	LF,0,0,0,0,0,0,0,0,0
	DB	' B) Same sector numbers on both sides',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	'    (normal method)',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF,0,0,0,0,0,0,0,0,0
	DB	' Select the way sectors are numbered ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' or <ESC> to start over:$'
SELALL:	DB	CR,LF
	DB	FF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	' A) 1k allocation blocks ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' B) 2k allocation blocks ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	' Select the size of the allocation blocks',CR,LF
	DB	' or type <ESC> to start over:$'
SELBPS:	DB	CR,LF
	DB	FF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	' A)  128 byte sectors ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' B)  256 byte sectors ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' C)  512 byte sectors ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' D) 1024 byte sectors ',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	' Select the sector size or <ESC> to start over:$'
SELSPT:	DB	CR,LF
	DB	FF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	' Defining Disk Parameter Block for drive "E"',CR,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	' # of logical sectors per track (SPT):$'
SELBSH:	DB	CR,LF
	DB	' block shift factor             (BSH):$'
SELBLM:	DB	CR,LF
	DB	' block mask                     (BLM):$'
SELEXM:	DB	CR,LF
	DB	' extent mask / DB alloc. size   (EXM):$'
SELDSM:	DB	CR,LF
	DB	' maximum data block number - 1  (DSM):$'
SELDRM:	DB	CR,LF
	DB	' maximum directory entries - 1  (DRM):$'
SELAL0:	DB	CR,LF
	DB	' directory group allocation 0   (AL0):$'
SELAL1:	DB	CR,LF
	DB	' directory group allocation 1   (AL1):$'
SELCKS:	DB	CR,LF
	DB	' check size                     (CKS):$'
SELOFF:	DB	CR,LF
	DB	' number of reserved tracks      (OFF):$'
SELOK:	DB	CR,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	' Are all entries in the dpb ok? $'
SELSKW:	DB	CR,LF
	DB	FF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' A) 1,2,3,4,5 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' B) 1,3,5,2,4 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' C) 1,4,2,5,3 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' D) 1,2,3,4,5,6,7,8 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' E) 1,2,3,4,5,6,7,8,9 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' F) 1,3,5,7,9,2,4,6,8 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' G) 1,4,7,2,5,8,3,6,9 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' H) 1,2,3,4,5,6,7,8,9,10 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' I) 1,3,5,7,9,2,4,6,8,10 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' J) 0,1,2,3,4,5,6,7,8,9 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' K) 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0
	DB	' L) 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 '
	DB	LF,CR,0,0,0,0,0,0,0,0,0,0
	DB	' M) 1,3,5,7,9,11,13,15,17,2,4,6,8,10,12,14,16,18 '
	DB	LF,CR,0,0,0,0,0,0,0,0,0,0
	DB	' N) 1,5,9,13,17,3,7,11,15,2,6,10,14,18,4,8,12,16 '
	DB	LF,CR,0,0,0,0,0,0,0,0,0,0
	DB	' O) 1,6,11,16,3,8,13,18,5,10,15,2,7,12,17,4,9,14 '
	DB	LF,CR,0,0,0,0,0,0,0,0,0,0
	DB	' P) 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 '
	DB	LF,CR,0,0,0,0,0,0,0,0,0,0
	DB	' Z) none of the above ',LF,CR
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	LF,CR,0,0,0,0,0,0,0,0,0,0
	DB	' Select a skew table :$'


MKMSG:	DB	FF,'Enter the skew table -- enter zeros for '
	DB	'the extra bytes ',CR,LF
	DB	'$'
PROMPT:	DB	CR,LF,' skw:$'
SKWOK:	DB	CR,LF,LF,' Are the skew table entries ok?$'
	;ending message...
	;
SGNOFF:	DB	CR,LF
	DB	FF
	DB	0,0,0,0,0,0,0,0,0,0
DRSEL:	DB	LF,'Drive # is now the new format drive when you '
	DB	'call it "E" .',CR,LF,'$'
	;
	;
	;wrgdrv loads the wrong drive error message, prints
	;it and exits to cp/m. 
	;
WRGDRV:	LXI	D,ERROR		;load error message
	CALL	OUTPUT		;bdos
DONE:	LHLD	OLDSP		;get stack back
	SPHL			;put it in sp
	RET			;return to zcpr3
	;
ERROR:	DB	7,CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF,'Wrong drive selected.',CR,LF
	DB	'MULTIDSK can only be run from drive A, B, C, or D.'
	DB	CR,LF
	DB	0,0,0,0,0,0,0,0,0,0
	DB	LF,'$'
	;  
	;
SKWA:	DB	 1, 2, 3, 4, 5, 0, 0, 0, 0, 0
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWB:	DB	 1, 3, 5, 2, 4, 0, 0, 0, 0, 0
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWC:	DB	 1, 4, 2, 5, 3, 0, 0, 0, 0, 0
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWD:	DB	 1, 2, 3, 4, 5, 6, 7, 8, 0, 0
	DB       0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWE:	DB	 1, 2, 3, 4, 5, 6, 7, 8, 9, 0
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWF:	DB	 1, 3, 5, 7, 9, 2, 4, 6, 8, 0
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWG:	DB	 1, 4, 7, 2, 5, 8, 3, 6, 9, 0
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWH:	DB	 1, 2, 3, 4, 5, 6, 7, 8, 9,10
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWI	DB	 1, 3, 5, 7, 9, 2, 4, 6, 8,10
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWJ	DB	 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SKWK	DB	 1, 2, 3, 4, 5, 6, 7, 8, 9,10
	DB	11,12,13,14,15,16, 0, 0, 0, 0
SKWL	DB	 1, 2, 3, 4, 5, 6, 7, 8, 9,10
	DB	11,12,13,14,15,16,17,18, 0, 0
SKWM	DB	 1, 3, 5, 7, 9,11,13,15,17, 2
	DB	 4, 6, 8,10,12,14,16,18, 0, 0
SKWN	DB	 1, 5, 9,13,17, 3, 7,11,15, 2
	DB	 6,10,14,18, 4, 8,12,16, 0, 0
SKWO	DB	 1, 6,11,16, 3, 8,13,18, 5,10
	DB	15, 2, 7,12,17, 4, 9,14, 0, 0
SKWP	DB	 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	DB	10,11,12,13,14,15,16,17, 0, 0
	;
	;
TYPE:	DS	1		;type byte
DPB:	DS	15		;disk parameter block
DRIVE:	DS	1		;drive selection
SKW:	DS	32		;skew table
ADDR:	DS	2		;"e" drive parms adr.
OLDSP:	DS	2		;room for old stack pointer
	; 
	DS	010H		;16 level stack
STACK:	
	;
	;
	END	BEGIN

