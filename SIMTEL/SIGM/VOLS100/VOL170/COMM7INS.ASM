;		comm7 installation program
;			    by
;			pavel breder
;			    and
;			paul traina
;
; changes telephone library text and numbers in program comm7
; and also sets configuration flags

; latest changes

;11/26/83  streamlined the help menu so it fits on one screen of
;the crt.  fg

;8/8/83  added full support of comm7 options, renamed file from
;comm7cal to comm7ins to reflect that this is now a total instalation
;program, not just a program to change library phone numbers
;NOTE: this program will not work on versions of comm7 eariler than 724
;							paul traina

;1/15/83  added close-file after read as suggested by
;pavel.  fg

;7/18/82  changed to work with comm7 and its 34-column,
;'a ', (not 30-column, 'a='), telephone library.  source code
;changed to comm7 style.  ret to cp/m stack pointer instead of
;warm boot.  frank gaude'

;06/13/82  pavel
;corrected bug in 'fill' new name that passed garbage from fcb
;or from old entry in to new name if the user did not fill the
;rest of name with spaces.

;06/10/82  originally written by pavel breder

SOURCE	ORG	100h

; cp/m equates

BASE	EQU	0		;cp/m base
BDOS	EQU	BASE+5h		;cp/m function entry address
RDCON	EQU	1		;wait for a character from console
WRCON	EQU	2		;char to console
DIRECT	EQU	6		;direct i/o
PRINT	EQU	9		;print string (de)
RDCONBF	EQU	10		;read kbd input string
OPEN	EQU	15		;open file
CLOSE	EQU	16		;close file
ERASE	EQU	19		;delete file
READ	EQU	20		;read file
WRITE	EQU	21		;write file
MAKE	EQU	22		;make file
SETDMA	EQU	26		;set dma
FCB	EQU	BASE+5Ch	;cp/m default file control block..
CMDBUF	EQU	BASE+80h	;..and buffer.

; other equates and a set

CR	EQU	13			;ascii carriage return
LF	EQU	10			;ascii line feed
BOTTRAM	SET	LAST + 80h AND 0FF80h	;file extension pointer

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
;
	INX	H		;skip over initial jump
	INX	H
	INX	H
	PUSH	D		;save DE

BACK	LXI	D,YBAKUP	;ask question
	CALL	XMESG
	CALL	KEYIN		;get key
	CALL	YESNO		;make Y-y/N-n into 255/0
	CPI	1		;error?
	JZ	BACK
	MOV	M,A		;store new value

	INX	H		;point to expert flag
XPERT	LXI	D,YXPRT		;ask question
	CALL	XMESG
	CALL	KEYIN		;get response
	CALL	YESNO		;convert it
	CPI	1		;error?
	JZ	XPERT
	CMA			;flip it
	MOV	M,A		;store new value

	INX	H		;point to saveccp flag
SAVECCP	LXI	D,YSAVE		;ask question
	CALL	XMESG
	CALL	KEYIN		;get response
	CALL	YESNO		;convert it
	CPI	1		;error?
	JZ	SAVECCP
	CMA			;it's backwards...
	MOV	M,A

	INX	H		;point to command character
CMDCHR	LXI	D,YCMDCHR	;ask question
	CALL	XMESG
	CALL	DKEYIN		;get response
	PUSH	PSW		;save it
	CPI	' '		;is it => space?
	JNC	NORMAL		;yes, so just print it
	CPI	27		;no, ok, is it escape?
	CZ	PESC		;yes, so print "<escape>"
	JZ	BELL		;...  and then go on to next question
	CPI	30		;no, ok, is it home?
	CZ	PHOME		;yes, so print "<home>"
	JZ	BELL		;...  and then go on to next question
	ADI	'@'		;turn the control character into printing char.
	PUSH	PSW		;save it
	MVI	E,'^'		;print carret
	CALL	COUT
	POP	PSW		;restore the now-ascii character
NORMAL	MOV	E,A		;put character in right register
	CALL	COUT		;print response
BELL	POP	PSW		;get back original response
	MOV	M,A

	INX	H		;point to bell flag
BELL1	LXI	D,YBELL
	CALL	XMESG
	CALL	KEYIN
	CALL	YESNO
	CPI	1		;error?
	JZ	BELL1
	MOV	M,A		;save bell flag
	POP	D		;restore de

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

; get 1 character response from console

KEYIN	PUSH	H		;save all registers
	PUSH	D
	PUSH	B
	MVI	C,RDCON		;tell bdos to give us a character
	CALL	BDOS
KEYIN1	POP	B
	POP	D
	POP	H
	RET			;return with character in a

DKEYIN	PUSH	H		;save all registers
	PUSH	D
	PUSH	B
DKEYIN1	MVI	C,DIRECT	;tell bdos to give us a character
	MVI	E,255		;tell bdos we want one
	CALL	BDOS
	ORA	A		;if no character, loop
	JZ	DKEYIN1
	JMP	KEYIN1

; convert yes/no into 255 (for yes) and 0 for no (and 1=error)

YESNO	ANI	5Fh
	MOV	B,A		;save it in B
	CPI	'Y'		;is it a yes?
	MVI	A,255		;assume that it was
	RZ			;yes, return
	MOV	A,B		;get it back again
	CPI	'N'		;is it a no?
	MVI	A,0		;assume that it was
	RZ			;yes, return
	MVI	A,1		;it was neither, so return an error
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

; utility message routines

PESC	PUSH	PSW
	LXI	D,YESC
	CALL	XMESG
	POP	PSW
	RET

PHOME	PUSH	PSW
	LXI	D,YHOME
	CALL	XMESG
	POP	PSW
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

YBAKUP	DB CR,LF,'Do you wish to make .BAK files? $'
YXPRT	DB CR,LF,'Should the menu be printed the first time? $'
YSAVE	DB CR,LF,'Is it ok to overwrite the CCP? $'
YCMDCHR	DB CR,LF,'What character do you want as attention character? $'
YBELL	DB CR,LF,'Should Comm7 beep every time you toggle the printer? $'
YESC	DB '<escape>$'
YHOME	DB '<home>$'
YLONG	DB CR,LF,'  ^^^^^ too l-o-n-g, retype ^^^^^$'
YRRFCB	DB CR,LF,'++ Cannot find file ++',CR,LF,'$'
YNONAM	DB CR,LF,'++ No destination file, or illegal name '
	DB 'specified ++',CR,LF,'$'
YRRWR	DB CR,LF,'++ Error extending file, or disk full ++'
	DB CR,LF,'$'
YRFILE	DB CR,LF,'++ Unable to find telephone library ++'
	DB CR,LF,'$'
YHELLO
DB 9,9,'COMM7INS as of 11/12/83'
DB CR,LF,LF,'This program allows changes to Comm7 to suit your tastes.'
DB '  Although major '
DB CR,LF,'options must be changed by modifying equates and re-assembling '
DB 'program, '
DB CR,LF,'the following values may be changed by this install '
DB 'program:',LF
	DB CR,LF,9,'Whether Comm7 should make .BAK files in batch mode.'
	DB CR,LF,9,'Should the main menu be printed on startup.'
	DB CR,LF,9,'Should the CCP be overwritten during memory saves.'
	DB CR,LF,9,'The "command" character Comm7 uses in terminal mode.'
	DB CR,LF,9,'Whether crt terminal beeps when the printer is '
	DB	   'toggled.',LF
DB CR,LF,'Also, the telephone numbers may be changed in the library:'
DB CR,LF,'Just enter text and numbers when at prompt A-to-Z.  If change'
DB CR,LF,'not desired, press <RETURN> for next library letter.  '
DB '^C aborts.'
DB CR,LF,LF,'Two forms are available:',LF
	DB CR,LF,9,'  A>comm7ins oldname.com newname.com'
	DB CR,LF,'or',9,'  A>comm7ins oldname.com oldname.com',LF
DB CR,LF,'Example:  A>comm7ins comm725.com comm7.com'
	DB CR,LF,'$'

; unitialized storage

FCB2	DS	33	; 2nd argument (destination file) fcb
	DS	30	;new stack area
STACK	DS	2	;cp/m stack pointer here

LAST	END	SOURCE
