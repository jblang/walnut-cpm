
; w o r k h o r s e   r o u t i n e s   (comm725b.asm)

; inline print-string to console

ILPRT	XTHL			;exchange top of stack and hl-pair and..
ILPLP	MOV	A,M		;..get text.
	CALL	TYPE		;show (unless quiet mode)
	INX	H		;get next char and test..
	MOV	A,M
	ORA	A		;..for end of text.
	JNZ	ILPLP
	XTHL			;set hl-pair
	RET

; print routine to show softkey strings on console using <cmd> d while
; in terminal mode.  also entry at 'textout' used for general string
; typing terminated with '@'.  enter with string-address in hl-pair.

	 IF	SOFTKEY
REVIEW  LXI	H,SOFTMSG	;address of string table
	 ENDIF			;softkey

TEXTOUT	MOV	A,M
	CPI	'@'		;table-end terminator signals..
	RZ			;..return.
	ORA	A		;single-string null (zero) terminator..
	JZ	SKIP$IT		;..means add newline/skip other nulls.
  	CALL	TYPE
	INX	H		;bump to next character and..
	JMP	TEXTOUT		;..loop till '@'.

SKIP$IT	CALL	CRLF		;print newline
SKIP1	INX	H
	MOV	A,M		;skip..
	ORA	A		;..the..
	JZ	SKIP1		;..nulls.
	JMP	TEXTOUT

; cursor return/line feed to console

CRLF	PUSH	PSW
	MVI	A,CR
	CALL	TYPE
	POP	PSW
LFONLY	PUSH	PSW		;entry for 'lf' only
	MVI	A,LF
	CALL	TYPE
	POP	PSW
	RET

; cursor return to console

CRONLY	PUSH	PSW
	MVI	A,CR
	CALL	TYPE
	POP	PSW
	RET

; constat routine

STAT	PUSH	B
	PUSH	D
	PUSH	H
VSTAT	CALL	$-$		;constat address from initadr
	POP	H
	POP	D
	POP	B
	ORA	A		; 00h --> not ready
	RET

; conin routine
 
KEYIN	PUSH	B
	PUSH	D
	PUSH	H
VKEYIN	CALL	$-$		;conin address from initadr
	POP	H   
	POP	D
	POP	B
	RET

; wait for keyboard response and display character

RESPOND	CALL	KEYIN
	CALL	UCASE		;fall-thru to 'type'

; type to console with optional list to printer

TYPE	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	MOV	C,A		;save char to type/list
	LDA	LISTFLG		;char to printer?
	ORA	A
	CZ	LISTOUT		;yes, out to printer ring-buffer..
	MOV	E,C
	MVI	C,WRCON		;..then type to console unless..
	LDA	QFLG		;..quiet mode requested.
	ORA	A
	CNZ	BDOS		;write to console if not quiet mode
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET			;simply return if 'quiet'

; case conversion -- call with character in a-register

UCASE	CPI	61H		; < small a?
	RC			;return if so
	CPI	7AH+1		; > small z?
	RNC			;if so, ignore.
	ANI	5FH		;otherwise capitalize
	RET

; universal delay loop -- call with # of 100 msec in b-reg

TIMER	PUSH	PSW
	PUSH	D
TIMER0	LXI	D,222*MHZ	; (dcx loop = .1 sec)
TIMERLP	PUSH	D		;add some..
	POP	D		;..inner loop delay.
	DCX	D
	MOV	A,D
	ORA	E
	JNZ	TIMERLP
	DCR	B		; # of 100 milliseconds (255 max)
	JNZ	TIMER0
	POP	D
	POP	PSW
	RET

; decimal pretty print (h must contain msb; l, the lsb.)

DECOUT	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	B,-10		;conversion radix
	LXI	D,-1		;divide by radix
DECOU2	DAD	B		; (subtract ten)
	INX	D
	JC	DECOU2
	LXI	B,10
	DAD	B		;add radix back in once
	XCHG
	MOV	A,H
	ORA	L		;test for zero
	CNZ	DECOUT		; (recursive call)
	MOV	A,E
	ADI	'0'		;convert from 'bcd' to 'hex'
	CALL	TYPE
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

; 16-bit hex output routine

DHXOUT	PUSH	H
	PUSH	PSW
	MOV	A,H		;get ms byte
	CALL	HEXO		;output high order byte
	MOV	A,L		;get ls byte
	CALL	HEXO		;output low order byte
	POP	PSW
	POP	H
	RET

; 8-bit hex output (left nibble processed, then right)

HEXO	PUSH	PSW		;save to obtain right nibble
	RAR			;rotate 4 bits right to get 'msp'
	RAR
	RAR
	RAR
	CALL	NIBBLE		;print left nibble
	POP	PSW		;get right nibble
NIBBLE	ANI	0FH		;mask to isolate nibble
	ADI	90H		;add offset
	DAA			; 'decimal adjust'
	ACI	40H		;add offset
	DAA
	JMP	TYPE		;ret to caller

; copy contents pointed to by hl-pair to de-pair, count in b-reg.

MOVE128	MVI	B,128
MOVE	MOV	A,M
	STAX	D		;copy char to memory at address in de-pair
	INX	H
	INX	D
	DCR	B
	JNZ	MOVE
	RET

; copy fcb2 to fcb location -- record and extent #'s zero'd

MOVEFCB	LXI	H,FCB+16
	LXI	D,FCB
	MVI	B,16		;copy 16 bytes
	CALL	MOVE
	XRA	A		;zero..
	STA	FCBRNO		;..record and..
	STA	FCBEXT		;..extent numbers.
 	RET
             
; copy fcb to fcb3 location

MOVE2	LXI	H,FCB3
	CALL	INITFCB
	LXI	H,FCB
	LXI	D,FCB3
	MVI	B,12		;copy 1st 12 bytes
	JMP	MOVE		;return to caller from 'move' routine

; initialize file control block
 
INITFCB	MVI	M,0		;entry at +2 will leave drive # intact.
	INX	H		;will initialize an fcb..
	MVI	B,11		;..pointed to by hl-pair.  fills 1st pos
LOOP10	MVI	M,' '		;..with 0, next 11 with..
	INX	H		;..blanks, and last..
	DCR	B		;..21 with nulls (0's).
	JNZ	LOOP10
	MVI	B,21
LOOP11	MVI	M,0
	INX	H
	DCR	B
	JNZ	LOOP11
	RET

; multiply value in h-reg by value in a-reg  (returns with answer
; in hl-pair)

MULHA	MVI	D,0
	MOV	E,H
	MOV	L,H
	MVI	H,0
MULLP	DCR	A
	RZ
	DAD	D
	JMP	MULLP

; divide contents of hl-pair by value in a-reg
; (returns with l-reg containing quotient; h-reg, remainder.)

DIVHLA	PUSH	B
	MVI	B,8		;shift factor to b-reg
	MOV	C,A		;divisor to c-reg
DIV2	XRA	A		;clear carry flag and accumulator
	DAD	H
	MOV	A,H
	SUB	C
	JM	DIV3		;don't borrow on neg results
	MOV	H,A
	MOV	A,L
	ORI	1		;borrow 1
	MOV	L,A
DIV3	DCR	B
	JNZ	DIV2
	POP	B
	RET

; shift hl-pair b-reg bits (-1) to right (divider routine)

SHIFTHL	MVI	B,4+1		;load for four loops
SHIFTLP	DCR	B
	RZ			;return when b-reg zeros
	MOV	A,H
	ORA	A		;clear carry and..
	RAR			;..rotate right thru carry.
	MOV	H,A		;put back
	MOV	A,L		;rotate lsb and..
	RAR	
	MOV	L,A		;..put back.
	JMP	SHIFTLP		;loop back

; subtraction subroutine -- returns hl-pair = hl-pair - de-pair

SUBDE	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	RET

; compare de/hl-pairs -- set carry/zero flags

CMPDEHL	MOV	A,D		;flags set by high bytes?
	CMP	H
	RNZ			;if not equal, return.
	MOV	A,E
	CMP	L		;flags set by low bytes instead?
	RET

; disk-system reset -- allows disk change

RESET	MVI	C,INQDISK	;get current logged-in drive, 25.
	CALL	BDOS
	STA	C$DR		;save current drive designator here..
	PUSH	PSW		;..and here.
	MVI	C,RESETDK	;reset disk system, 13.
	CALL	BDOS
	POP	PSW		;put current for..
SET$DR	MOV	E,A		;..selection..
	MVI	C,LOGIN		;..as default, 14.
	JMP	BDOS		; (returns to caller)

; set/reset (or get) user area (call with binary user area in a-reg)

SET$USR	MOV	E,A
GET$USR	MVI	C,SGUSER
	JMP	BDOS

; set cp/m fcb with command line

SETFCB	LXI	D,CMDBUF
	LXI	H,FCB
	JMP	CMDLINE

; error statement display -- abort to command mode

ERXIT	MVI	A,'Q'		;reset quiet flag (qflg).  (allows all..
	STA	QFLG		;..error msg to show in quiet mode.)
	CALL	CRLF
	POP	H		;address of error msg
	CALL	TEXTOUT
ERXIT1	CALL	CRLF
	MVI	A,TRUE
	STA	ABORTFLG
	LDA	BATCHFLG
	ORA	A
	JNZ	DONETCB
	JMP	ABORT		;abort other computer

; 'listout' -- entry to printer (list device) ring-buffer

LISTOUT	MOV	A,C		;filter out all control..
	CPI	HT		;..codes, except cr, lf, and tab, and..
	JZ	LSTBUFF		;..all graphics characters.
	CPI	CR
	JZ	LSTBUFF
	CPI	LF
	JZ	LSTBUFF
	CPI	7FH
	RNC
	CPI	' '
	RC			;fall-thru to 'lstbuff'

; 'lstbuff' puts c-register byte into next position in printer ring-
; buffer.  if buffer is full, routine returns with character lost.

LSTBUFF	LHLD	BUFEND		;get end of ring-buffer
	XCHG			;store in de-pair
	LHLD	BUFRIN		;get last input position and..
	INX	H		;..point to next character.
	CALL	CMPDEHL		;de/hl-pairs equal?
	JNZ	LBUFF1		;if not equal, not at end.
	LHLD	BUFBEG		;past end, reset to begin.
LBUFF1	XCHG			;save new input position in de-pair
	LHLD	BUFROUT		;get address of last output+1
	CALL	CMPDEHL
	RZ			;ring-buffer full -- return to caller.
LBUFF2	XCHG			;retrieve new position from de-pair
	SHLD	BUFRIN		;update last input position
	MOV	M,C		;put byte from c-reg into buffer
	RET			;return to caller

; 'lst' checks list device (printer) status using a direct bios call.  if
; busy, quickly returns.  pointers are updated before return.

LISTST	CALL	$-$		;get list status (address from initadr)
	ORA	A		;see if it's busy
	RZ			;busy, then return.
	LHLD	BUFRIN		;get last input position
	XCHG			;move to de-pair
	LHLD	BUFROUT
	CALL	CMPDEHL		;de/hl-pairs equal?
	RZ			;buffer is empty, return.
PRTBUF1	INX	H		;update pointer and..
	PUSH	H		;..save.
	LHLD	BUFEND		;get end of ring-buffer..
	XCHG			;..put in de-pair.
	POP	H		;restore pointer and..
	CALL	CMPDEHL
	JNZ	PRTBUF2
	LHLD	BUFBEG		;was past end, reset to ring beginning.
PRTBUF2	SHLD	BUFROUT		;store new pointer
	MOV	E,M		;get character to print
	MVI	C,LIST		;cp/m list output function
	JMP	BDOS		;get work done -- ret to caller

; display send/receive characters plus cr, lf, and tab.  other
; non-printing characters are shown  as ' ^x'.  used with secondary
; options 'r', 's', and 'v'.  ('q' mode is automatically entered with
; the 'v' option by 'procopt' routine.)

SHOW	CPI	LF
	JZ	TYPEQ
	CPI	CR
	JZ	TYPEQ
	CPI	HT		;horizontal tab
	JZ	TYPEQ
	CPI	' '		;display characters..
	JC	SHOWCTL
	CPI	7FH		;..from 20h to 7fh.
	JC	TYPEQ
SHOWCTL	PUSH	PSW		;show rest as ' ^x'
	CALL	ILPRTQ
	DB	' ^',0
	POP	PSW
	ADI	40H		;binary --> alpha
TYPEQ	PUSH	PSW		;type to console during quiet/view modes
	PUSH	B		; (also used to type ':' at line beginning..
	PUSH	D		;..during 'colon-save' of file.)
	PUSH	H
	MOV	E,A
	MVI	C,WRCON
	JMP	BDOSV

; 'ilprtq' is used to console-print selected messages during both quiet
; and reqular modes

ILPRTQ	XTHL
ILPLPQ	MOV	A,M
	CALL	TYPEQ
	INX	H
	MOV	A,M
	ORA	A
	JNZ	ILPLPQ
	XTHL
	RET

; clear noise character(s) from telephone line

CLR$L	CALL	INSTAT
	RNZ
	CALL	INCHAR
	JMP	CLR$L

; display program version number and revision date -- header

CAPTION	CALL	CLEAR$S
	CALL	TO$DIM
	CALL	ILPRTQ
	DB 	'Comm'
	DB	VERS/100+'0','.',VERS MOD 100/10+'0'
	DB	VERS MOD 10+'0',' as of '
	DB	MONTH/10+'0',MONTH MOD 10+'0','/'
	DB	DAY/10+'0',DAY MOD 10+'0','/'
	DB	YEAR/10+'0',YEAR MOD 10+'0',0
	JMP	TO$FULL

; crt screen control routines

; clear screen and home cursor

CLEAR$S	LDA	MCLS
	CALL	TYPE
	LDA	MCLS2
	JMP	TYPE

; clear (from cursor) to-end-of-page
CTEOP	CALL	TO$LEAD
	LDA	METEOP
	JMP	TYPE

; begin half-intensity (go dim)

TO$DIM	 IF	NOT VIEWPOINT
	CALL	TO$LEAD
	 ENDIF				;not viewpoint

	LDA	MBDIM
	JMP	TYPE

; start full-intensity 

TO$FULL	 IF	NOT VIEWPOINT
	CALL	TO$LEAD
	 ENDIF				;not viewpoint

	LDA	MEDIM	
	JMP	TYPE

; send lead-in (escape) character to console

TO$LEAD	LDA	MLEADIN
	JMP	TYPE

;  c m d l i n e

; loads a command line addressed by de-pair (max # characters in line in de,
; number of chars in line in de+1, line starts in de+2) into fcb addressed
; by hl-pair.  the fcb should be at least 33 bytes in length.  the command
; line buffer must have a maximum length at least one more than the greatest
; number of characters that will be needed.

CMDLINE	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	INIT		;fills fcbs with blanks and nulls
	XCHG			;get start of command line in hl-pair
	INX	H		;address # bytes in cmd line
	MOV	E,M		;load de-pair with # bytes
	MVI	D,0
	INX	H
	DAD	D		;point to byte after last char..
	MVI	M,CR		;..in cmd line and store delimiter.
	POP	H		;restore hl- and de-pairs
	POP	D
	PUSH	D
	PUSH	H
	INX	D		;address start of command
	INX	D
	CALL	DRIVE
NAME1	MVI	C,8		;transfer first filename to fcb
	CALL	TRANS
	CPI	CR
	JZ	DONEL
	CPI	' '		;if space, then start of..
	JZ	NAME2		;..second filename.
TYPE1	POP	H		;filetype must be after..
	PUSH	H		;..eighth byte of name.
	LXI	B,9
	DAD	B
	MVI	C,3		;transfer type of first file
	CALL	TRANS
	CPI	CR
	JZ	DONEL
NAME2	LDAX	D		;eat multiple spaces..
	CPI	' '		;..between names.
	JNZ	NAME2C
	INX	D
	JMP	NAME2

NAME2C	POP	H		;second name starts in 16th byte
	PUSH	H		;point hl-pair to this byte
	LXI	B,16
	DAD	B
	CALL	DRIVE
	MVI	C,8
	CALL	TRANS
	CPI	CR
	JZ	DONEL
TYPE2	POP	H		;second type starts in 25th byte
	PUSH	H
	LXI	B,25
	DAD	B
	MVI	C,3
	CALL	TRANS
DONEL	POP	H
	PUSH	H
	INX	H		;point to 1st char of 1st name in fcb..
	CALL	SCANL		;check for * (ambiguous names)
	POP	H
	PUSH	H
	LXI	B,17		;..then to 1st char of second name in fcb.
	DAD	B
	CALL	SCANL
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

; cmdline subroutines:
; initialize fcb with 1 null (for first drive), 11 blanks, and 4 nulls;
; then again fill 1 null (for 2nd drive), 11 blanks, and finally, 4 nulls.

INIT	PUSH	H
	PUSH	B
	MVI	M,0
	INX	H
	MVI	B,11
	MVI	A,' '
	CALL	INITFILL
	MVI	B,5
	XRA	A
	CALL	INITFILL
	MVI	B,11
	MVI	A,' '
	CALL	INITFILL
	MVI	B,4
	XRA	A
	CALL	INITFILL
	POP	B
	POP	H
	RET

INITFILL MOV	M,A
	 INX	H
	 DCR	B
	 JNZ	INITFILL
	 RET

DRIVE	INX	D		;check 2nd byte of filename.  if it..
	LDAX	D		;..is a ":", then drive was specified..
	DCX	D
	CPI	':'
	JNZ	DEFDR		;..else zero for default drive ..
	LDAX	D		;..('init' put zero)
	ANI	5FH
	SUI	40H		;calculate drive (a=1, b=2,...)..
	MOV	M,A		;..and place it in fcb.
	INX	D		;address first byte of..
	INX	D		;..in cmd line,..
DEFDR	INX	H		;..and name field in fcb.
	RET

TRANS	LDAX	D		;transfer from cmd line to fcb..
	INX	D		;..up to number of chars specified..
	CPI	CR		;..by c-reg. keep scanning field..
	RZ			;..without transfer until a delimiting..
	CPI	'.'		;..field char such as '.', blank, or..
	RZ			;..c/r (for end of cmd line).
	CPI	' '
	RZ
	DCR	C
	JM	TRANS		;once c-reg is less than zero, keep..
	MOV	M,A		;..reading cmd line but do not..
	INX	H		;..transfer to fcb.
	JMP	TRANS

SCANL	MVI	B,8		;scan filename addressed by hl-pair
TSTNAM	MOV	A,M
	CPI	'*'		;if '*' found, fill in rest of field..
	JZ	FILL1		;..with '?' for ambiguous name.
	INX	H
	DCR	B
	JNZ	TSTNAM
	JMP	TSTTYP

FILL1	CALL	FILL
TSTTYP	MVI	B,3		;scan and fill type field for name..
TSTTYPL	MOV	A,M		;..specified above.
	CPI	'*'
	JZ	FILL
	INX	H
	DCR	B
	RZ
	JMP	TSTTYPL

FILL	MVI	M,'?'		;routine transfers '?'
	INX	H
	DCR	B
	JNZ	FILL
	RET

;  d i r l i s t

; lists directory, 2 or more column file display with storage
; remaining on requested drive shown.

DIRLIST	CALL	CRLF		;turn up lines..
	CALL	CRLF		;..from command line.
	CALL	SETFCB		;setup cp/m convention cmd line to fcb
	LXI	H,FCB4		;init..
	CALL	INITFCB		;..fcb4.
	LDA	FCB2		;get drive number
	STA	FCB4
	LDA	FCB2+1
	CPI	' '		;if blank get all names
	PUSH	PSW
	CZ	QSTMARK
	POP	PSW
	CNZ	MOVNAME		;else move name into fcb

; set dma to default cp/m buffer (tbuf) -- do filename search

	LXI	D,TBUF		;default 'tbuf'  address
	MVI	C,SETDMA
	CALL	BDOS
	MVI	A,NPL		; 'names per line' into reg-a to indicate..
	STA	NAMECT		;..'crlf' after 'npl' number of columns.
	LXI	D,FCB4
	MVI	C,SRCHF		;do first search
	CALL	BDOS
	INR	A		; 0ffh --> 0 if no file(s) found
	JNZ	DIRLOOP
	CALL	ILPRTQ
	DB	'++ File(s) not found ++',0
	JMP	STORAGE		;still show storage on requested drive

DIRLOOP	CALL	GETADDR		;address returned in hl-pair
	LXI	D,PRTNAME
	MVI	B,8
	CALL	MOVE
	INX	D
	MVI	B,3
	CALL	MOVE
	CALL	ILPRTQ
PRTNAME	DB	'        ','.','   ',0   ;print format
NEXTSR	LXI	D,FCB4
	MVI	C,SRCHN		;do next search
	CALL	BDOS
	INR	A		;if 0ffh --> 0 then..
	JZ	STORAGE		;..directory-read finished.
	MOV	B,A		;save dir index
	LDA	NAMECT
	DCR	A
	STA	NAMECT		;name count updated
	CZ	CRLF		;terminate line of filenames
	JNZ	FENCE
	MVI	A,NPL		;restart names-per-line count
	STA	NAMECT
	JMP	NOFENCE		;fence not needed

FENCE	CALL	TO$DIM
	CALL	ILPRTQ		;fence if not at end-of-line..
	DB	' | ',0		;..if not the last name.
	CALL	TO$FULL
NOFENCE	MOV	A,B		;get dir index back
	JMP	DIRLOOP

; determine storage remaining on default drive

STORAGE	LDA	FCB4		;get 'requested' drive
	ORA	A
	JZ	DEFAULT
	DCR	A
	MOV	E,A
	MVI	C,LOGIN
	CALL	BDOS
DEFAULT	MVI	C,GETPARM	;current disk parameter block
	CALL	BDOS
	INX	H
	INX	H
	MOV	A,M		;get block shift factor
	STA	BSHIFTF
	INX	H		;bump to block mask
	MOV	A,M		;get it
	STA	BMASK
	INX	H
	INX	H
	MOV	E,M		;get max block number
	INX	H
	MOV	D,M
	XCHG
	SHLD	BMAX		;put it away
	MVI	C,GETVERS	;get cp/m version in hl-pair
	CALL	BDOS
	MOV	A,L		;get version #
	CPI	30H		; 3.x?
	JC	FREE20		;use old method if not
	LDA	FCB		;get drive #
	DCR	A
	MOV	E,A		;use new compute free space bdos call
	MVI	C,FRESPC
	CALL	BDOS
	MVI	C,3		;answer is a 24-bit integer..
FRE3L1	LXI	H,CPM$BASE+82H	;..in 1st 3 bytes of dma address.
	MVI	B,3		;convert it from sectors to kilobytes..
	ORA	A		;..by dividing by 8.
FRE3L2	MOV	A,M
	RAR
	MOV	M,A
	DCX	H
	DCR	B
	JNZ	FRE3L2		;loop for 3 bytes
	DCR	C                   
	JNZ	FRE3L1		;shift 3 times
	LHLD	CPM$BASE+80H	;now get result in kilobytes and..
	JMP	PRT$FRE		;..go store it.

FREE20	MVI	C,INQALC	;address of cp/m allocation vector
	CALL	BDOS
	XCHG			;get its length
	LHLD	B$MAX
	INX	H
	LXI	B,0		;initialize block count to zero
GSPBYT	PUSH	D		;save allocation address
	LDAX	D
	MVI	E,8		;set to process 8 bits (blocks)
GSPLUP	RAL			;test bit
	JC	NOT$FRE
	INX	B
NOT$FRE	MOV	D,A		;save bits
	DCX	H
	MOV	A,L
	ORA	H    
	JZ	END$ALC		;quit if out of blocks
	MOV	A,D		;restore bits
	DCR	E		;count down 8 bits
	JNZ	GSPLUP		;branch to do another bit
	POP	D		;bump to next count..
	INX	D		;..of allocation vector.
	JMP	GSPBYT		;process it

END$ALC	POP	D		;clear alloc vector pointer from stack
	MOV	L,C		;copy # blocks to hl-pair
	MOV	H,B
	LDA	BSHIFTF		;get block shift factor
	SUI	3		;convert from sectors to thousands (k)
	JZ	PRT$FRE		;skip shifts if 1k blocks
FREK$LP	DAD	H		;multiply blocks by k-bytes per block
	DCR	A		;multiply by 2, 4, 8, or 16.
	JNZ	FREK$LP
PRT$FRE	PUSH	H
	LDA	FCB4		;if drive is default, get..
	ORA	A
	JNZ	PRNTHD		; (if not, convert 'fcb+0'.)
	MVI	C,INQDISK	;..currently logged-in drive.
	CALL	BDOS
	INR	A		; 0 --> 1 --> 'a'
PRNTHD	ADI	40H		;make printable
	STA	DRNAME
	CALL	CRLF
	CALL	TO$DIM
	POP	H
	CALL 	DECOUT		; # of free 'k' bytes to hl-pair
	CALL	ILPRTQ
	DB	'k bytes free on drive '
DRNAME	DB	' :',CR,LF,LF,0
	CALL	TO$FULL
	LDA	C$DR		;return to..
	MOV	E,A		;..currently..
	MVI	C,LOGIN		;..logged-in drive.
	JMP	BDOS

; subroutines for dirlist section

QSTMARK	LXI	H,FCB4+1
JOKER	MVI	A,'?'		;if 'blank' in fcb, put in 11 ?'s.
	MVI	B,11
QSTLP	MOV	M,A
	INX	H
	DCR	B
	JNZ	QSTLP
	RET

MOVNAME	LXI	H,FCB2+1
	LXI	D,FCB4+1
	MVI	B,11
	JMP	MOVE

GETADDR	DCR	A		;un-do the 'inr' above
	ADD	A		;times 32
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADI	TBUF+1		;add dma (tbuf) offset
	MOV	L,A
	MVI	H,CPM$BASE SHR 8	;base page address
	RET

;  i n b u f

; duplicates cp/m function 10 'read buffer' routine, but does not recognize
; <ctrl-c> (reason for routine).  does allow controls u, r, e, and h (back-
; space).  outputs bell if input greater than buffer.  ignores leading spaces
; entered.

INBUF	PUSH	PSW
	PUSH	H
	PUSH	B 
	PUSH	D		;de-pair must be pushed last
DOIT	CALL	CLEARA		;clear the buffer area
	POP	D		;get address of buffer on retries
	PUSH	D		;restore stack
	XRA	A		;clear a-reg and..
	STA	LSPFLG		;..set ignore-leading-spaces flag.
	INX	D		;go to address count location (buf+1)
	STAX	D		;initialize with a zero in count byte, then..
	INX	D		;..get 1st typed, entered character (buf+2).
	XCHG			;address first buffer byte with hl-pair
INBUFA	CALL	KEYIN		; (waits for char)
	CALL	UCASE
	CPI	CR		;is it <return> --> enter command?
	JZ	INBUFR		;if so, then return.
	CPI	' '		;ignore..
	JNZ	INBUFLP		;..leading-spaces test.
	MOV	B,A		;save entry character
	LDA	LSPFLG
	ORA	A
	MOV	A,B		;restore it
	JZ	INBUFA		;branch if a leading space
INBUFLP	CPI	7FH		;is it a delete?
	JZ	DELETE
	CPI	08H		; <ctrl-h> backspaces..
	JZ	DELETE		;..over deleted char.
	CPI	'U'-40H		;is it <ctrl-u>?
	JZ	INBUFO		;output #, cr, lf, and start over
	CPI	'R'-40H		; <ctrl-r> retypes line
	JZ	RETYPE
	CPI	'E'-40H		; <ctrl-e> outputs..
	CZ	CRLF		;..a cr and a lf.
	JZ	INBUFA
	CPI	' '		;only above control characters allowed
	JC	INBUFA
	MOV	B,A		;save keyboard entered character
	STA	LSPFLG		; <space> processed if other char entered 1st
	XCHG			;save hl-pair in de-pair
	POP	H		;get address of buffer in hl-pair
	PUSH	H		;restore stack
	INX	H		;address count byte
	INR	M		;increase count byte
	DCX	H		;address maximum
	MOV	A,M		;put maximum in a
	INX	H		;address count
	CMP	M		;compare count to maximum
	JC	ALERTL		;if maximum, ring bell and wait for cr.
	XCHG			;restore buffer pointer to hl-pair
	MOV	M,B		;put inputted character in buffer
	MOV	A,B		;output it
	CALL	TYPE
	INX	H		;bump pointer
	JMP	INBUFA		;get next character

DELETE	XCHG			;save buffer pointer in de-pair
	POP	H		;address beginning of buffer
	PUSH	H		;restore stack
	INX	H		;address count field
	MOV	B,A		;save delete char, 7fh or 08h.
	MOV	A,M
	SUI	1		;decrease count ('sui' sets carry)
	MOV	M,A
	JC	NODEL		;don't delete past begining of buffer
	XCHG			;restore buffer pointer to hl-pair
	DCX	H		;point to last byte inputted
	MOV	A,B		;get back 7fh or 08h
	MOV	B,M		;get character being deleted
	MVI	M,' '		;restore blank
	CPI	08H
	JZ	BKSPC
	CPI	7FH
	JNZ	INBUFA		;get next character
	MVI	A,08H
BKSPC	CALL	TYPE		;true erase if 08h
	MVI	A,' '
	CALL	TYPE
	MVI	A,08H
	CALL	TYPE
	JMP	INBUFA

NODEL	INR	M		;don't leave count negative
	XCHG			;restore pointer to hl-pair
	JMP	INBUFA

INBUFO	MVI	A,'#'		;announces line has been removed
	CALL	TYPE
	CALL	CRLF
	JMP	DOIT

RETYPE	POP	D
	PUSH	D
	INX	D		;point to current number..
	LDAX	D		;..of characters.
	MOV	B,A
	MVI	A,'#'
	CALL	TYPE
	CALL	CRLF
	MOV	A,B		;test if zero input
	ORA	A
	JZ	INBUFA
CTLRLP	INX	D		;ctrl-r loop
	LDAX	D
	CALL	TYPE		;repeat line
	DCR	B
	JNZ	CTLRLP		;loop till done, length in b-reg.
	JMP	INBUFA
	
ALERTL	MVI	A,BELL		;alarm for full buffer
	CALL	TYPE
	DCR	M
	XCHG
	JMP	INBUFA

INBUFR	CALL	CRONLY		;no lf here permits overwrite..
	POP	D		;..of command line.
	POP	B
	POP	H
	POP	PSW
	RET

CLEARA	POP	D		;accounts for call
	POP	H		;address buffer in hl-pair
	PUSH	H		;restore..
	PUSH	D		;..stack
	MOV	B,M		;save maximum in b-reg (from 'cmdbuf')
	INX	H		;point to first..
	INX	H		;..buffer byte.
	MVI	A,' '
CLEARL	MOV	M,A
	INX	H
	DCR	B
	JNZ	CLEARL
	RET

;  i n - l i n e   c o m p a r e

; compares string addressed by de-pair to string after call (ends with null).
; return with carry set means strings not the same.  all registers except
; a-reg are unaffected.

ILCOMP	XTHL			;point hl-pair to 1st char
	PUSH	D
ILCOMPL	MOV	A,M		;hl-pair points to in-line string
	ORA	A		;if null, end of string.
	JZ	SAME
	LDAX	D
	CMP	M
	JNZ	NOTSAME
	INX	H
	INX	D
	JMP	ILCOMPL

NOTSAME	XRA	A		;if not same, finish thru..
NSLP	INX	H		;..string so return will..
	CMP	M		;..go to instruction after..
	JNZ	NSLP		;..string and not remainder of string.
	STC
SAME	POP	D
	INX	H		;skip over null terminator
	XTHL
	RET

;  m u l t i - f i l e   a c c e s s

; allows processing of multiple files (i.e. *.asm) from disk.  builds the
; correct name in the fcb each time it is called.  the command is used in
; programs to process single or multiple files.  the fcb is set up with the
; next name, ready to do normal processing (open, read, etc.) when routine
; is called.  carry is set if no more names are found.
                
MFNAME	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,SETDMA
	LXI	D,TBUF
	CALL	BDOS
	XRA	A
	STA	FCBEXT

; if first time

	LDA	MFFLG1
	ORA	A
	JNZ	MFNAME1
	MVI	A,1
	STA	MFFLG1

; save requested name -- save original request

	LXI	H,FCB
	LXI	D,MFNAME4
	MVI	B,12
	CALL	MOVE
	LDA	FCB
	STA	MFNAME5		;save disk in curr fcb

; search for first requested name

 	LXI	H,MFNAME4
	LXI	D,FCB
	MVI	B,12
 	CALL	MOVE
	MVI	C,SRCHF
	LXI	D,FCB
	CALL	BDOS

; else

	JMP	MFNAME2

MFNAME1	LXI	H,MFNAME5
	LXI	D,FCB
	MVI	B,12
	CALL	MOVE
	MVI	C,SRCHF		;search for first
	LXI	D,FCB
	CALL	BDOS

; search for next name

	LXI	H,MFNAME4
	LXI	D,FCB
	MVI	B,12
	CALL	MOVE
	MVI	C,SRCHN
	LXI	D,FCB
	CALL	BDOS

; endif

MFNAME2	INR	A
	STC			; ret with carry set..
	JNZ	MFNAME3
	STA	MFFLG1		;reset multi-filename flag
	POP	H
	POP	D
	POP	B
	RET			; ..if name not found.

; move name found to current name
	
MFNAME3	CALL	GETADDR
	PUSH	H		;save name pointer
	LXI	D,MFNAME5+1
	MVI	B,11
	CALL	MOVE
	POP	H

; move name found to fcb

	LXI	D,FCB+1
	MVI	B,11
	CALL	MOVE

; initialize fcb counter fields

	XRA	A
	STA	FCBEXT
	STA	FCBRNO
	POP	H
	POP	D
	POP	B
	RET

; c o m m o n   c r c   s u b r o u t i n e s

; clear crc register

CLRCRC	PUSH	H		;reset crc accumulator for new message
	LXI	H,0
	SHLD	CRCVAL
	POP	H
	RET

; generate tables for fast crc calculations

INITCRC	LXI	H,CRCTBL
	MVI	C,0		;table index
GLOOP	XCHG
	LXI	H,0		;initialize 'crc' register-pair
	MOV	A,C
	PUSH	B
	MVI	B,8
	XRA	H
	MOV	H,A
LLOOP	DAD	H
	JNC	LSKIP
	MVI	A,10H
	XRA	H
	MOV	H,A
	MVI	A,21H
	XRA	L
	MOV	L,A
LSKIP	DCR	B
	JNZ	LLOOP
	POP	B
	XCHG			;de now has crc, hl pointing into table.
	MOV	M,D		;store high byte of crc
	INR	H
	MOV	M,E		;store low byte
	DCR	H
	INX	H		;move to next table entry
	INR	C		;next index
	JNZ	GLOOP
	RET

; update crc value

UPDCRC	PUSH	PSW
	PUSH	B	
	PUSH	D
	PUSH	H
	LHLD	CRCVAL		;get partial remainder and put to..
	XCHG			;..de-pair.
	MVI	B,0		;clear high byte of bc-pair
	XRA	D
	MOV	C,A		;copy data character to c-register
	LXI	H,CRCTBL
	DAD	B
	MOV	A,M
	XRA	E
	MOV	D,A
	INR	H
	MOV	E,M
	XCHG
	SHLD	CRCVAL		;save to use for next update
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

; check crc bytes of received message

CHKCRC	PUSH	H
	LHLD	CRCVAL
	MOV	A,H
	ORA	L
	POP	H
	RZ
	MVI	A,TRUE 
	RET

	LINK	COMM725C	;chains to 'comm725c.asm' using lasm.com
