; modemcal by pavel breder

; changes telephone library text and numbers in program comm7.

; 1/15/83  added close-file after read as suggested by
; pavel.  fg

; 7/18/82  changed to work with comm7 and its 34-column,
; 'a ', (not 30-column, 'a='), telephone library.  source code
; changed to comm7 style.  ret to cp/m stack pointer instead of
; warm boot.  frank gaude'

; 06/13/82  pavel
; corrected bug in 'fill' new name that passed garbage from fcb
; or from old entry in to new name if the user did not fill the
; rest of name with spaces.

; 06/10/82  originally written by pavel breder

SOURCE	ORG	100H

; cp/m equates

BASE	EQU	0		;cp/m base
BDOS	EQU	BASE+5H		;cp/m function entry address
WRCON	EQU	2		;char to console
PRINT	EQU	9		;print string (de)
RDCONBF	EQU	10		;read kbd input string
OPEN	EQU	15		;open file
CLOSE	EQU	16		;close file
ERASE	EQU	19		;delete file
READ	EQU	20		;read file
WRITE	EQU	21		;write file
MAKE	EQU	22		;make file
SETDMA	EQU	26		;set dma
FCB	EQU	BASE+5CH	;cp/m default file control block..
CMDBUF	EQU	BASE+80H	;..and buffer.

; other equates and a set

CR	EQU	13		;ascii cr and..
LF	EQU	10		;..lf.
BOTTRAM	SET	LAST + 80H AND 0FF80H ;file extension pointer

; program begins

START	LXI	H,0		;let's save cp/m stack pointer
	DAD	SP
	SHLD	STACK
	LXI	SP,STACK	;set new stack, 15 levels deep.
	LDA	FCB+1		;file name from user?
	CPI	' '		;space means no..
	JZ	HELLOMS		;..name, so say hello.
 	LDA	FCB+17		;destination file present?
	CPI	' '
	JZ	ERRFC1		;space means no file
	CPI	'?'		;let's not use wild cards
	JZ	ERRFC1

; get ready for work to be done

	LXI	H,BOTTRAM-80H	;point to buffer where original..
	SHLD	TBUF		;..file goes (-80h fixed later).
	MVI	A,33		;set limit to command-line..
	STA	CMDBUF		;..buffer and store here.

; store destination file in safe location

	LXI	H,FCB+16	;get destination filename pointer
	LXI	D,FCB2		;this is where we store it
	MVI	B,16		; 16 bytes to move
MOVEFCB	MOV	A,M		;move the filename (fcb2 to fcb2)
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	MOVEFCB

; read original file into memory

	LXI	D,FCB		; 1st argument
	MVI	C,OPEN		;open it
	CALL	BDOS
	INR	A		;ffh --> 0 if no file..
	JZ	ERRFCB		;..error.
READMR	LHLD	TBUF		;contains address where..
	LXI	D,80H		;..file is to be loaded.
	DAD	D		;add one 128-byte block and..
	SHLD	TBUF		;..save for next time.
	XCHG			;address into de so we can..
	MVI	C,SETDMA	;..set the dma.
	CALL	BDOS
	LXI	D,FCB		;now read block
	MVI	C,READ
	CALL	BDOS
	ORA	A
	JNZ	READLS		;end read if end of file
	LDA	SECTCTR		;count blocks
	INR	A
	STA	SECTCTR
	JMP	READMR		;read more

; store last address and get ready to search for library

READLS	LXI	D,FCB
	MVI	C,CLOSE
	CALL	BDOS
	LDA	TBUF+1		;get end of file
	INR	A
	MOV	D,A		;only msb needed
	LXI	H,BOTTRAM	;start of file is here

; now look for the telephone numbers (searches for 'a ' and 'b ')

SEARCH	MOV	A,H		;let's not search too far
	CMP	D		;at end of file?
	JZ	WRFILE		;yes, must be the wrong file.
	MOV	A,M		;get char
	INX	H		;increment file pointer
	CPI	'A'		; 'a' ?
	JNZ	SEARCH		;no, search next.
	MOV	A,M		;have 'a', see if next is ' '.
	CPI	' '
	JNZ	SEARCH		;no, wrong 'a'.
	DCX	H		;adjust address
	SHLD	NUMBLIB		;save where 'a' is
	LXI	D,34		;the 'b' should be here + 34..
	DAD	D		;..so 34 is added.
	MOV	A,M		;see what's there
	CPI	'B'		;is it 'b'?
	JNZ	NOTB		;not this one
	INX	H		;got 'b'
	MOV	A,M		;is the next char ' '?
	CPI	' '
	JZ	LOOP0		;yes, have right file and pointer
NOTB	LHLD	NUMBLIB		;get back pointer to 'a'
	INX	H		;increment address..
	JMP	SEARCH		;..and continue search.

; we now have pointer to library, let's print each number and
; ask user for new text and numbers.

LOOP0	CALL	CRLF		;start with a fresh line
LOOPLP	LHLD	NUMBLIB		;here we should be
	MVI	B,34		; 34 characters to print
LOPPRT	MOV	E,M		;one at a time
	CALL	COUT		;to console
	INX	H
	DCR	B
	JNZ	LOPPRT		;not done, print next
	MVI	E,'*'		;show where last character is
	CALL	COUT
	LDA	NUMBCTR		;count entry (a-z)
	INR	A
	STA	NUMBCTR
LOOP	CALL	CRLF
	LDA	NUMBCTR		;again point to library table
	ADI	64		;make ascii and..
	MOV	E,A		;..send to console.
	CALL	COUT
	MVI	E,' '		;print same as in file: ' '.
	CALL	COUT
	LXI	D,CMDBUF	;point to input buffer
	MVI	C,RDCONBF	;get string from user
	CALL	BDOS
	LDA	CMDBUF+1	;get character count entered
	CPI	33		;at limit?
	JNC	LOONG		;more than 32, too much.
	ORA	A		;else if 0 (cr only)..
	JZ	NOFIL		;..then go to next entry.
	LHLD	NUMBLIB		;current entry in file is here
	INX	H		;skip entry number..
	INX	H		;..and ' ' in file.
	MVI	B,32		;set up count to bytes to move
	MOV	C,A
	LXI	D,CMDBUF+2	;from here
FILL	LDAX	D		;move them
	MOV	M,A		;one at a time
	INX	H
	INX	D
	DCR	B
	JZ	FILLY		;have all 32 bytes
	DCR	C
	JNZ	FILL		;one more to go
FILLS	MVI	M,' '		;fill the rest with spaces
	INX	H
	DCR	B
	JNZ	FILLS
FILLY	CALL	CRLF
NOFIL0	SHLD	NUMBLIB		;save new pointer to the file
	LDA	NUMBCTR		;at last entry?
	CPI	'Z'-64		; 'z' is the last
	JZ	SAVEIT		;yes, go save it
	JMP	LOOPLP		;go do next

NOFIL	LHLD	NUMBLIB
	LXI	D,34
	DAD	D
	JMP	NOFIL0

LOONG	LXI	D,YLONG
	CALL	XMESG
	JMP	LOOP

; produce destination file

SAVEIT	LXI	D,CMDBUF	;reset dma to cp/m default
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,FCB2
	MVI	C,ERASE		;delete the destination..
	CALL	BDOS		;..just in case.
	LXI	D,FCB2
	MVI	C,MAKE		;make the destination file and..
	CALL	BDOS
	LXI	D,FCB2
	MVI	C,OPEN		;..open it.
	CALL	BDOS
	LXI	H,BOTTRAM-80H	;file is here (+80h)
	SHLD	NUMBLIB
SAVE1	LHLD	NUMBLIB		;get dma pointer
	LXI	D,80H		;increment by one 128-byte block
	DAD	D
	SHLD	NUMBLIB		;save for next time
	XCHG			;dma call needs it in de
	MVI	C,SETDMA	;set dma
	CALL	BDOS
	LXI	D,FCB2		;write the current block
	MVI	C,WRITE
	CALL	BDOS
	ORA	A
	JNZ	ERRWR		;ouch!
	LDA	SECTCTR		;count down remaining blocks
	DCR	A
	STA	SECTCTR
	JNZ	SAVE1		;more to go
	LXI	D,CMDBUF	;reset dma to dir
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,FCB2
	MVI	C,CLOSE		;close the file
	CALL	BDOS
EXIT	LHLD	STACK		;all done, go home.
	SPHL
	RET

; print-to-console routines

XMESG	PUSH	H		;string msg pointed to by de
	PUSH	B
	MVI	C,PRINT		;string out, terminated by "$".
	CALL	BDOS
	POP	B
	POP	H
	RET

CRLF	MVI	E,CR
	CALL	COUT
	MVI	E,LF
COUT	PUSH	H		;character is in e, print it.
	PUSH	B
	PUSH	D
	MVI	C,WRCON 	;byte out
	CALL	BDOS
	POP	D
	POP	B
	POP	H
	RET

; error message routines

HELLOMS	LXI	D,YHELLO
	JMP	ERR2

WRFILE	LXI	D,YRFILE
	JMP	ERR2

ERRWR	LXI	D,YRRWR
	JMP	ERR2

ERRFC1	LXI	D,YNONAM
	JMP	ERR2

ERRFCB	LXI	D,YRRFCB
ERR2	CALL	XMESG		;print message
	CALL	EXIT		;go home.

; initialized storage

NUMBCTR	DB 0	; a-to-z modem library letter and..
SECTCTR	DB 0	;..file sector counters.
TBUF	DW 0	;pointers for 1st argument (orig file)..
NUMBLIB	DW 0	;..and for library number table.
YLONG	DB CR,LF,'  ^^^^^ too l-o-n-g, retype ^^^^^$'
YRRFCB	DB CR,LF,'++ UNABLE TO FIND FILE ++',CR,LF,'$'
YNONAM	DB CR,LF,'++ NO DESTINATION FILE OR ILLEGAL NAME '
	DB 'SPECIFIED++',CR,LF,'$'
YRRWR	DB CR,LF,'++ ERROR EXTENDING FILE OR DISK FULL ++'
	DB CR,LF,'$'
YRFILE	DB CR,LF,'++ UNABLE TO FIND TELEPHONE LIBRARY ++'
	DB CR,LF,'$'
YHELLO	DB CR,LF,9,'         COMM7CAL as of 9/4/82'
	DB CR,LF,LF,9,'To change modem telephone library, enter'
	DB CR,LF,9,'text and numbers when at prompt A-to-Z.'
	DB CR,LF,9,'If change not desired, press <RETURN> for'
	DB CR,LF,9,'the next library letter.  <CTRL-C> aborts.'
	DB CR,LF,LF,9,'Two forms available:'
	DB CR,LF,LF,9,'A>comm7cal oldname.com newname.com or'
	DB CR,LF,9,'A>comm7cal oldname.com oldname.com'
	DB CR,LF,LF,9,'Example:'
	DB CR,LF,LF,9,'A>comm7cal comm7.com comm.com'
	DB CR,LF,'$'

; unitialized storage

FCB2	DS	33	; 2nd argument (destination file) fcb
	DS	30	;new stack area
STACK	DS	2	;cp/m stack pointer here

LAST	END	SOURCE
