; u t l   (comm723d.asm)

; disk file manipulation routines based on 'disk7' program.  ten major
; commands control disk file housekeeping.

; show menu and determine drive for processing (c$u$a already set by
; main menu command line)

	 IF	UTL
DISK7 	LDA	ALERTFG		; 'utl' not permitted if..
	ORA	A		;..file-save active.
	JNZ	FILOPEN
	CALL	HELP		;get 'menu'
	CALL	SETFCB
	CALL	MOVEFCB
	LDA	FCB		;default drive?
	DCR	A
	JP	EMBARK		;if not, branch.
 	MVI	C,INQDISK	;else find default..
	CALL	BDOS		;..to make printable.

; show drive free storage and determine if specific file(s) exist(s)

EMBARK	PUSH	PSW		;log-in..
	CALL	SET$DR		;..requested drive.
	POP	PSW
	STA	C$DR		; 0 --> 'a', 1 --> 'b', etc.
	INR	A
	STA	FCB		; 1 --> 'a', 2 --> 'b', etc.
RE$PUT	CALL	FRESTOR		;get bytes remaining on drive
	LDA	FCB+1		;check if a filename was entered
	CPI	' '		;filename a space?
	JNZ	PLUNGE		;no, name was entered.
	LDA	FCB+9		;filetype also space?
	CPI	' '		;if so, then..
	JNZ	PLUNGE
	LXI	H,FCB+1		;..treat..
	CALL	JOKER		;..as '*.*' with 'joker'.

; build 'ring' with filename positioned in default 'fcb' location

PLUNGE	MVI	C,SETDMA	;initialize dma address..
	LXI	D,TBUF		;..to default buffer.
	CALL	BDOS
	LXI	D,FCB		;default 'fcb' for search..
	MVI	C,SRCHF		;..of first occurrance.
	CALL	BDOS
	INR	A		; 0ffh --> 00h if no file found
	JNZ	SETRING		;if found, branch and build ring.
	JMP	REDO		;if none found, say so.

; l o g

; select drive and user area -- drive system reset for disk change on-the-fly 

LOG	CALL	ILPRT		;prompt to get drive/user selection
	DB	'og-in drive/user: ',0
	CALL	DEF$D$U		;define drive/user area
	LDA	R$U$A		;establish requested area..
	STA	C$U$A		;..as current area.
	MVI	C,RESETDK	;reset system for..
	CALL	BDOS		;..disk change.
	LDA	R$DR		;get requested drive
	CALL	SET$DR		;log-in requested drive
	MVI	A,' '		;set default 'fcb' to look like *.*
	STA	FCB+1
	STA	FCB+9
	LXI	H,0		;reset tagged..
	SHLD	TAG$TOT		;..file size accumulator.
	CALL	CRLF		;freshen line and..
	JMP	RE$PUT		;..restart.

; 'def$d$u' determines requested drive and sets requested user area with
; full error trapping.  (first, check validity of user area entry, then
; validity of drive, and finally implement.)

DEF$D$U	LXI	H,CMDBUF+2	; 1st character from keyboard
	MVI	B,3		; # of blanks to..
	CALL	FIL$UTL		;..clear 'cmdbuf'.
	LXI	D,CMDBUF	;get drive/user selection from..
	CALL	INBUF		;..console buffer read.
	LDA	CMDBUF+1	;if only a..
	ORA	A		;..carriage return..
	JZ	FORWARD		;..cancel log command.
 	XRA	A		;initialize..
	STA	R$U$A		;..user area to zero.
	LDA	CMDBUF+3	; 1st digit of user area?
	CPI	':'		;allow ':' after drive declaration
	JZ	UETEXIT
	CPI	'0'		;no valid user area request..
	JC	UETEXIT		;..then to new drive and ring list.
	CPI	'9'+1
	JNC	ERRET		;error, not a user area.
	SUI	'0'		;convert to binary and..
	CPI	1		;..test if 10's digit.
	JNZ	UETUSER		;if none, then set user area now.
	LDA	CMDBUF+4	;a second user area digit?
	CPI	':'		;allow ':' here
	JZ	UETUONE
	CPI	'0'		;test for 1's digit
	JC	UETUONE
	CPI	'5'+1		;if user area >15..
	JNC	ERRET		;..go cmd line.
	SUI	'0'-10		;make 1 --> 11, 2 --> 12, etc.
	STA	R$U$A		;save as 'requested user area' here..
	JMP	UETEXIT

UETUONE	MVI	A,1		;set to user area 'one'
UETUSER	MOV	B,A
	LDA	CMDBUF+4
	CPI	':'		;allow ':' here
	JZ	DDPASS
	CPI	'0'		;if >19 user area, go error msg.
	JNC	ERRET
DDPASS	MOV	A,B
	STA	R$U$A		;..and here.
UETEXIT	LDA	CMDBUF+2	;first character entered is drive
	CPI	'A'		;don't permit..
	JC	ERRET		;..drive less than 'a'.
	SUI	'A'		;zero base to check for..
	CPI	(MAXDR)-'A'+1	;..maximum # of drives in system.
	JNC	ERRET		;if input too big, show error msg.
	STA	R$DR		;ready for 'log-in'
	INR	A
	STA	FCB		;drive shows as 1 --> a:
	LDA	R$U$A		;set 'requested user area'..
	JMP	SET$USR		;..to 'current user area'.

; h e l p   (menu)

HELP	CALL	ILPRT		;show menu
	DW	CLS
	DB	ESC,BDIM,LF,LF,LF
	DB	'                  COMM7 Disk File Utility -- '
	DB	MONTH/10+'0',MONTH MOD 10+'0','/'
	DB	DAY/10+'0',DAY MOD 10+'0','/'
	DB	YEAR/10+'0',YEAR MOD 10+'0'
	DB	CR,LF,ESC,EDIM
	DB	'   C - Copy file | D - Delete file | F - File size   | L - Lo'
	DB	'g-in drive',CR,LF
	DB	'   M - Mass copy | P - Print text  | R - Rename file | S - St'
	DB	'at drive',CR,LF
	DB	'   T - Tag file  | U - Untag file  | V - View text   | X - Ex'
	DB	'it to COMM7',CR,LF,ESC,BDIM
	DB	'           <RETURN> or <space> advances cursor -- B backs up'
	DB	ESC,EDIM,CR,LF,0
	RET

; establish ring (circular list) of filenames

SETRING	LXI	H,UTLRING	;initialize ring pointer
	SHLD	RINGPOS		;start --> current position of ring

; put names found into ring (a-reg --> offset into 'tbuf' name storage)

TO$RING	CALL	GETADDR		;get filename index and 'tbuf+1' offset
	DCX	H		;move back to drive character
	LDA	FCB		;get drive designator and..
	MOV	M,A		;..put into 'fcb' buffer.
	XCHG
	LHLD	RINGPOS		;current load point in ring
	XCHG
	MVI	B,12		;move drive designator and name to ring
	CALL	MOVE
	XCHG			;de-pair contains next move-to address
	MVI	M,' '		;storage for..
	INX	H		;..potential 'tag' character.
	SHLD	RINGPOS		;store and search..
	MVI	C,SRCHN		;..for next occurrence.
	LXI	D,FCB		;filename address field
	CALL	BDOS
	INR	A		;if all done, 0ffh --> 00h.
	JNZ	TO$RING		;if not, put name into ring.

; all filenames in ring -- setup ring size and copy-buffer start point

	LHLD	RINGPOS		;next load point of ring is start of buffer
	SHLD	RINGEND		;set ring end..
	SHLD	BUFSTART	;..and copy-buffer start.
	LXI	D,UTLRING+13	;compare 'ringend' (tab base+13)
	CALL	CMPDEHL
	JZ	CMDLOOP		;go to command loop, if no sort.

; sort ring of filenames

SORT	LXI	H,UTLRING	;initialize 'i' sort variable and..
	SHLD	RINGI
	LXI	D,13		;..also 'j' variable.
	DAD	D
	SHLD	RINGJ
SORTLP	LHLD	RINGJ		;compare names 'i & j'
	XCHG
	LHLD	RINGI
	PUSH	H		;save position pointers..
	PUSH	D		;..for potential swap.
	MVI	B,13		; # of characters to compare

; left to right compare of two strings (de-pair points to 'a' string;
; hl-pair, to 'b'; b-reg contains string length.)

CMPSTR	LDAX	D		;get an 'a' string character and..
	CMP	M		;..check against 'b' string character.
	JNZ	NOCMP		;if not equal, set flag.
	INX	H		;bump compare..
	INX	D		;..pointers and..
	DCR	B		; (if compare, set as equal.)
	JNZ	CMPSTR		;..do next character.
NOCMP	POP	D
	POP	H
	MVI	B,13
	JNC	NOSWAP

; swap if 'j' string larger than 'i'

SWAP	MOV	C,M		;get character from one string..
	LDAX	D		;..and one from other string.
	MOV	M,A		;second into first
	MOV	A,C		;first into second
	STAX	D
	INX	H		;bump swap pointers
	INX	D
	DCR	B		;all bytes swapped yet?
	JNZ	SWAP
NOSWAP	LHLD	RINGJ		;increment 'j' pointer
	LXI	D,13
	DAD	D
	SHLD	RINGJ
	XCHG			;see if end of 'j' loop
	LHLD	RINGEND
	CALL	CMPDEHL
	JNZ	SORTLP		;no, so more 'j' looping.
	LHLD	RINGI		;bump 'i' pointer
	LXI	D,13
	DAD	D
	SHLD	RINGI
	DAD	D		;set start over 'j' pointer
	SHLD	RINGJ
	XCHG			;see if end of 'i' loop
	LHLD	RINGEND
	CALL	CMPDEHL
	JNZ	SORTLP		;must be more 'i' loop to do

; sort done -- calculate copy buffer maximum available record capacity

B$SIZE	LXI	B,0		;count records
	LHLD	BDOS+1		;get 'bdos' entry (fbase)
	LXI	D,-(CCP*100H)	;substract (2's complement) 'ccp'..
	DAD	D		;..from 'bdos' and..
	DCX	H		;..one additional page for border space.
	XCHG			;de-pair --> highest address of buffer
	LHLD	BUFSTART	;start address of buffer (end of ring list)
B$SIZE2	INX	B		;increase record count by one
	PUSH	D
	LXI	D,80H		; 128-byte record
	DAD	D		;buffer address + record size
	POP	D
	CALL	CMPDEHL		;compare for all done
	JNC	B$SIZE2		;more will fit?
	DCX	B		;set maximum record count less one
	MOV	A,B		;memory available for copy?
	ORA	C
	JNZ	B$SIZE3		;yes, buffer memory space available.
	CALL	ILPRT
	DB	CR,LF,BELL,'++ No Memory for Copy Buffer ++',0
	JMP	FORWARD

B$SIZE3	MOV	L,C		;store maximum..
	MOV	H,B		;..available record..
	SHLD	REC$MAX		;..capacity (count).

; buffer size determined -- process file and display loop

CMDLOOP	LXI	H,UTLRING	;sort done, now set..
	SHLD	RINGPOS		;..start point of ring list.
	JMP	LOOP2

; command line loop

LOOP	CALL	CRLF
LOOP2	CALL	ILPRT
	DB	'   ',0
LOOP3	LHLD	RINGPOS		;ring filename location
	MOV	A,M		;move 'fcb' to a-reg and..
	ADI	'A'-1		;..make drive printable (a - p).
	CALL	TYPE
	LDA	C$U$A		;get last requested (current) user area
	ORA	A		;branch if 'user..
	JZ	UAZ		;..area zero'.
	CPI	10		;less then ten?
	JC	LT$TEN		;if yes, branch.
	SUI	10		;if not, suppress leading 10's digit.
	PUSH	PSW
	MVI	A,'1'		;print 10's digit as 'one'
	CALL	TYPE
	POP	PSW
LT$TEN	ADI	'0'		;make 1's digit printable
	CALL	TYPE
UAZ	CALL	ILPRT		;fence between 'drive/user' and..
	DB	': ',0		;..'fn.ft'.
	INX	H		;beginning of 'fn.ft' string
	MVI	B,8		; 8 filename characters
PRT$FN	MOV	A,M
	CALL	TYPE
	INX	H
	DCR	B
	JNZ	PRT$FN
	MVI	A,'.'		;period between 'fn' and 'ft'
	CALL	TYPE
	MVI	B,3		; 3 filename characters
PRT$FT	MOV	A,M
	CALL	TYPE
	INX	H
	DCR	B
	JNZ	PRT$FT
	MOV	A,M		;copy ' ' or '*' to..
	STA	TAG+2		;..position before cursor.
	INX	H
	SHLD	RINGPOS		;save ring position
	CALL	ILPRT		;type..
TAG	DB	' : ',0		;space, colon, space or * before cursor.
	CALL	RESPOND		;wait for character from keyboard
	CPI	' '		;if 'space' or..
	JZ	FORWARD
	CPI	CR		;..'cursor return', advance one position.
	JZ	FORWARD
	CPI	'B'		;if reverse, subtract one ring position.
	JZ	REVERSE
	CPI	'C'		;copy file to another disk?
	JZ	COPY
	CPI	'D'		;delete a file?
	JZ	DEL$UTL
	CPI	'F'		;show file size?
	JZ	FIL$SIZ
	CPI	'L'		;log-in another drive?
	JZ	LOG
	CPI	'M'		;tagged multiple file copy?
	JZ	MASS
	CPI	'P'		;output file to 'list' device?
	JZ	LSTFILE
	CPI	'R'		;if rename, get to work.
	JZ	RENAME
	CPI	'S'		;free bytes on..
	JZ	R$DR$ST		;..requested drive?
	CPI	'T'		;if tag, put '*' in..
	JZ	TAG$EM		;..front of cursor.
	CPI	'U'		;remove '*' from..
	JZ	UNTAG		;..in front of cursor?
	CPI	'V'		; 'view' file at console?
	JZ	VIEW
	CPI	'X'		;return to comm7 command line?
	JZ	COMMRET
	CALL	HELP  		;any other character gets help (menu) and..
	CALL	FRESTOR		;..shows free storage remaining on default.

; n e u t r a l

NEUTRAL	LHLD	RINGPOS		;stay..
	LXI	D,-13		;..in..
	DAD	D		;..the..
	SHLD	RINGPOS		;..same..
	JMP	LOOP2		;..position.

; u n t a g

UNTAG	XRA	A		;set tag/untag..
	STA	T$UN$FG		;..flag to untag.
	LHLD	RINGPOS		;move back one..
	LXI	D,-1		;..character position..
	DAD	D		;..and check tagging status.
	MOV	A,M		;if file previously tagged, remove..
	CPI	'*'		;..size from..
	MVI	M,' '		; (untag character, to next ring position.)
	JZ	FS2		;..summation.
	JMP	FORWARD
 
; t a g

TAG$EM	LHLD	RINGPOS
	LXI	D,-1		;move back one..
	DAD	D		;..position..
	MOV	A,M		; (if file
	CPI	'*'		; already tagged, skip
	JZ	FORWARD		; to next file.)
	MVI	M,'*'		;..and store a '*' tag character.
	MVI	A,TRUE		;set..
	STA	T$UN$FG		;..tag/untag and..
	STA	FS$FLG		;..file size flags to tag.
	JMP	FS2		;get file size

; f i l e   s i z e

; determine and display file size in kilobytes -- round up to next disk
; allocation block -- accumulate tagged file summation

FIL$SIZ	XRA	A		;set file size/tagged..
	STA	FS$FLG		;..file flag to file size.
FS2	MVI	A,BS		;backspace over..
	CALL	TYPE		;..command character.
	LHLD	RINGPOS		;move name to 'fcb'
	LXI	D,-13
	DAD	D
	LXI	D,FCB
	MVI	B,12
	CALL	MOVE

; determine file record count and save in 'rcnt'

	CALL	CNREC

; round up to next disk allocation block

	LDA	B$MASK		;sectors/block - 1
	PUSH	PSW		;save 'blm'
	MOV	L,A
	XCHG
	LHLD	RCNT		;..use here.
	DAD	D		;round up to next block
	MVI	B,3+1		;convert from..
	CALL	SHIFTLP		;..records to kilobytes.
	POP	PSW		;retrieve 'blm'
	RRC			;convert..
	RRC			;..to..
	RRC			;..kilobytes/block.
	ANI	1FH
	CMA			;finish rounding
	ANA	L
	MOV	L,A		;hl-pair contains # of kilobytes
	LDA	FS$FLG
	ORA	A
	JZ	D$F$SIZ		;branch if 'f' function

; tagged file size summation

	XCHG			;file size to de-pair
	LDA	T$UN$FG
	ORA	A
	JZ	TAKE		;if untag, take size from total.
	LHLD	TAG$TOT		;accumulate..
	DAD	D		;..sum of..
	SHLD	TAG$TOT		;..tagged file sizes.
	XCHG			;file size to hl-pair
	JMP	D$F$SIZ		;branch to display sizes

TAKE	LHLD	TAG$TOT		;subtract..
	MOV	A,L		;..file..
	SUB	E		;..size..
	MOV	L,A		;..from..
	MOV	A,H		;..summation..
	SBB	D		;..total.
	MOV	H,A		;then put..
	SHLD	TAG$TOT		; (save total)
	XCHG			;..file size in hl-pair.

; display file size in kilobytes -- right justify tagged file total

D$F$SIZ	CALL	DET$BCD		;determine # of bcd digits in hl-pair
	MVI	A,9		;limit of right margin (good for max cp/m 2.2)
	SUB	B		; # of digits returned in b-reg from det$bcd
	STA	TEST$RT		;save intermediate right-justify data
	CALL	DECOUT          ;print individual file size
	CALL	ILPRT
	DB	'k',0
	LDA	FS$FLG
	ORA	A
	JZ	FORWARD         ;show next file if not tagging

; determine # of digits in tagged summation

	LHLD	TAG$TOT		;get present summation
	CALL	DET$BCD

; insert necessary spaces (blanks) to right justify display

	LDA	TEST$RT		;get intermediate right-justify data
	SUB	B
	MOV	B,A
	MVI	A,' '		;adjust..
ADD$SP	CALL	TYPE		;..to..
	DCR	B		;..achieve..
	JNZ	ADD$SP		;..right justification.
	MVI	A,'('
	CALL	TYPE
	CALL	DECOUT          ;print tagged file summation
	CALL	ILPRT
	DB	'k)',0          ;fall-thru to next file cursor line

; f o r w a r d

FORWARD	LHLD	RINGPOS		;at end of loop yet?
	XCHG
	LHLD	RINGEND
	CALL	CMPDEHL		;compare 'present' to 'end'
	JNZ	LOOP		;to next print position
	CALL	CRLF		;end-of-directory shows with fresh line
	LXI	H,UTLRING  	;set position pointer to beginning and..
	SHLD	RINGPOS
	JMP	LOOP		;..redisplay start entry.

; r e v e r s e

REVERSE	LHLD	RINGPOS		;see if at beginning of ring
	LXI	D,UTLRING+13
	CALL	CMPDEHL
	JNZ	REV1		;skip position pointer reset if not..
	CALL	CRLF		;..at beginning.  skip line at junction.
	LHLD	RINGEND		;set to end +1 to backup to end
	LXI	D,13
	DAD	D
	SHLD	RINGPOS
REV1	CALL	ILPRT		;indicate reverse
	DB	CR,LF,'<- ',0
	LHLD	RINGPOS
	LXI	D,-(13*2)	;one ring position..
	DAD	D		;..backwards.
	SHLD	RINGPOS
 	JMP	LOOP3		;display without 'crlf'

; s t a t

; determine and display remaining storage on requested drive

R$DR$ST	CALL	ILPRT
	DB	'tat of drive: ',0
	CALL	DEF$D$U		;determine drive requested and..
	CALL	CRLF		;..turn up an extra line.  then..
	CALL	RESET		; (reset system for disk change)
	CALL	FRESTOR		;..determine free space remaining.
	LDA	C$DR		;login original as..
	PUSH	PSW
	CALL	SET$DR		;..current drive.
	POP	PSW
	INR	A		;re-establish..
	STA	FCB		;..drive at 'fcb'.
	JMP	NEUTRAL		;retain position

; r e n a m e

; set-up to rename file at cursor position -- scan keyboard buffer and
; move filename to 'rename' destination 'fcb' (fcb4)

RENAME	CALL	ILPRT		;new name prompt
	DB	'ename file to: ',0
	LXI	D,CMDBUF	;command line location
	CALL	INBUF		;console read-buffer function
	LDA	CMDBUF+1	;if simply cursor..
	ORA	A		;..return, go..
	JZ	FORWARD		;..to next position.
	CALL	RINGFCB4	;move name from ring to rename 'fcb'
	LXI	H,FCB4+16
	PUSH	H
	CALL	INITFCB		;initialize fcb of new filename
	POP	H
	INX	H		;to 1st character
	XCHG
	LXI	H,CMDBUF+1	;put length..
	MOV	C,M		;..in c-reg.
	INX	H
	XCHG

; extend buffer to spaces beyond command length.  de-pair --> buffer pointer
; and hl-pair --> 'fcb' pointer.

EXTEND	PUSH	H
	MOV	L,C		;double-byte remaining length
	MVI	H,0
	DAD	D		;to buffer end +1
	MVI	M,' '		;force illegal character end
	POP	H

; start filename scan

SCAN	MVI	B,8		;max of 8 character in filename
SCAN1	CALL	CKLEGAL		;get and see if legal character
	JC	COMCAN		;check if all of command line
	CPI	' '		;see if end of parameter field
	JZ	CPYBITS		;rename file
	CPI	'.'		;at end of filename
	JZ	SCAN2		;process filetype field
	MOV	M,A		;put character into destination 'fcb'
	INX	H
	DCR	B		;check name character count
	JNZ	SCAN1

; entry if eight characters without a 'period'

SCAN1A	CALL	CKLEGAL		;scan buffer up to period or end
	JC	CPYBITS		;no extent if not legal
	CPI	' '		;end of parameter field?
	JZ	CPYBITS
	CPI	'.'
	JNZ	SCAN1A		;do till end or period

; build filetype field

SCAN2	MVI	B,3		;length of filetype field
	LXI	H,FCB4+25	;destination 'rename' filetype start
SCAN3	CALL	CKLEGAL		;get and check character for cp/m convention
	JC	CPYBITS		;if illegal, done.
	CPI	' '		;end of parameter field?
	JZ	CPYBITS
	CPI	'.'		;check if another period
	JZ	CPYBITS
	MOV	M,A
	INX	H
	DCR	B
	JNZ	SCAN3		;get next character

; copy old file status bit ($r/o or $sys) to new filename

CPYBITS	LXI	D,FCB4+1	;first character of old name..
	LXI	H,FCB4+17	;..and of new name.
	MVI	C,11		; # of bytes with tag bits
CBITS1	LDAX	D		;fetch bit of old name character
	ANI	80H		;strip upper bit and..
	MOV	B,A		;..save in b-reg.
	MVI	A,7FH		;mask for character only
	ANA	M		;put masked character into a-reg
	ORA	B		;add old bit
	MOV	M,A		;copy new byte back
	INX	H		;bump copy pointers
	INX	D
	DCR	C		;bump copy counter
	JNZ	CBITS1

; check if new filename already exists.  if so, say so.  then go
; to command loop without moving ring position

	LXI	H,FCB3		;initialize source..
	CALL	INITFCB		;..fcb.
	LDA	FCB4		;move drive from destination to..
	STA	FCB3		;..source.
	MVI	B,11
	LXI	H,FCB4+17	;copy new name to..
	LXI	D,FCB3+1	;..source 'fcb' for existence check.
	CALL	MOVE
	LXI	D,FCB3		;new file already exists?
	MVI	C,SRCHF		;search first function
	CALL	BDOS
	INR	A		; 0ffH --> 00h if file not found
	JZ	RENFILE		;to rename, if duplicate doesn't exists.
	CALL	ILPRT		;announce the situation
	DB	CR,LF,'++ File already exists ++',BELL,0
	JMP	COMCAN		;try again?

; copy new name into ring position

RENFILE	LHLD	RINGPOS		;get ring position pointer
	LXI	D,-12		;backup 12 leaves drive designation intact
	DAD	D
	XCHG
	LXI	H,FCB4+17	;point at new name and..
	MVI	B,11
	CALL	MOVE		;..move.
	LXI	D,FCB4		;rename 'fcb' location
	MVI	C,REN		;rename function code
	CALL	BDOS
	INR	A		; 0ffh --> 00h if rename error
	JNZ	COMCAN		;if okay, proceed.  else..
	JMP	FNF$MSG		;..show no-file msg.

; d e l e t e

; ready to delete filename at cursor position

DEL$UTL	CALL	RINGFCB4	;move name from ring to 'rename fcb'
	CALL	ILPRT
	DB	'elete? (Y/N): ',0
	CALL	RESPOND
	CPI	'Y'
	JNZ	COMCAN		;if no, stay in position.
	LXI	D,FCB4		;point at delete 'fcb'
	MVI	C,ERASE		;erase function
	CALL	BDOS
	INR	A
	JNZ	DEL2		;file deleted okay
FNF$MSG	CALL	ILPRT		;show error message
	DB	CR,LF,'++ File Not Found ++',0
	JMP	FORWARD

; reverse ring to close up erased position

DEL2	LHLD	RINGPOS		;prepare move up pointers
	PUSH	H
	LXI	D,-13
	DAD	D
	SHLD	RINGPOS		;reset current position for move
	XCHG			;de-pair = 'to' location
	POP	H		;hl-pair = 'from' location
MOVUP	XCHG
	PUSH	H		;check if at end
	LHLD	RINGEND		;get old end pointer
	CALL	CMPDEHL		;check against current end location
	POP	H
	XCHG
	JZ	MOVDONE		;must be at end of ring
	MVI	B,13		;one name size
	CALL	MOVE		;move one name up
	JMP	MOVUP		;go check end parameters

MOVDONE	XCHG
	SHLD	RINGEND		;set new ring end if all moved
	LXI	D,UTLRING	;see if ring is empty..
	CALL	CMPDEHL		;..(listend --> listpos --> ring)
	JNZ	FORWARD
	LHLD	RINGPOS
	CALL	CMPDEHL
	JNZ	FORWARD		;neither equal so not empty
	CALL	ILPRT		;show msg and return to comm7 command line
	DB	CR,LF,LF,'    ++ List Empty ++',0

; e x i t

; return to comm7 command line

COMMRET	CALL	ILPRT
	DB	CR,LF,LF,0
	LDA	CMD$DR		;login prevailing..
	CALL	SET$DR		;..drive before entering 'utl'.
	JMP	MENU		;return to comm7 cmd line

; v i e w

; type file to console with pagination set to 'lps' -- single-line scroll
; using <space> bar , <ctrl-x> to cancel, any other key to page screen.

VIEW	CALL	ILPRT
	DB	ESC,BDIM,CR,LF,'<CTRL-X> cancels, <space> turns up one '
	DB	'line, other keys page screen.',ESC,EDIM,CR,LF,LF,0
	MVI	A,1		;initialize..
	STA	LPSCNT		;..lines-per-screen counter.
	MVI	A,WRCON		;write console function
	STA	VIEWFLG		;any non-zero --> 'view' paginate
	JMP	CURRENT		;to common function processing

; p r i n t

; send file to ring device -- any keypress cancels

LSTFILE	XRA	A		;zero for..
	STA	VIEWFLG		;..output to printer.
	MVI	A,LIST		;out to 'list' device function

; output character for console/list processing

CURRENT	STA	CON$LST		;save bdos function

; output file to console/printer

	LXI	H,FCB3		;initialize..
	CALL	INITFCB		;..fcb3.
	CALL	RINGFCB3	;position name to 'fcb3'
	LXI	D,TBUF		;set to use default cp/m..
	MVI	C,SETDMA	;..dma buffer.
	CALL	BDOS
	LXI	D,FCB3		;open file for reading
	MVI	C,OPEN		;file open function code
	CALL	BDOS
	INR	A		; 0ffh --> 00h if open okay
	JNZ	RDMORE		;if not okay, show error message.
	CALL	ILPRT
	DB	' ++ Unable to Open File ++',0
	JMP	FORWARD

RDMORE	LXI	D,FCB3		;point at file 'fcb' for reading
	MVI	C,READ		;record read function
	CALL	BDOS
	ORA	A		;check if read okay
	JNZ	FORWARD		;eof?  go to next ring position.
	LXI	H,TBUF		;point at record just read
	MVI	B,80H		;set record character counter to output
READLP	MOV	A,M		;get a character
	CPI	EOFCHAR		;see if end-of-file
	JZ	FORWARD		;back to ring loop if 'eof'
	MOV	E,A		;put character for 'bdos' call
	PUSH	B
	PUSH	H
	PUSH	D		; (character in e-reg)
	LDA	CON$LST		;get function for ring/console output
	MOV	C,A
	CALL	BDOS
	LDA	VIEWFLG		;if 'view'..
	ORA	A
	POP	D
	POP	H
	POP	B
	CNZ	PAGER		;..check for 'lf'.
	CALL	STAT		;console status?
	ORA	A		;if character there, then abort..
	JNZ	COMCAN	 	;..to same ring position.
	INX	H		;if not, bump buffer pointer.
	DCR	B		;all bytes of record sent yet?
	JNZ	READLP		;no, more in present record.
	JMP	RDMORE		;yes, get next record.

PAGER	MOV	A,E		; (character in e-reg)
	CPI	LF
	RNZ
	LDA	LPSCNT		;is counter..
	INR	A		;..at..
	STA	LPSCNT		;..limit..
	CPI	LPS		;..of lines-per-screen?
	RC			;no, return.
	XRA	A		;yes, initialize..
	STA	LPSCNT		;..for next screen full.
	CALL	ILPRT
	DB	ESC,BDIM,'  [more...]',CR,0	;show msg line
	CALL	KEYIN		;wait for keyboard input
	CPI	' '		;if not <space> bar, see..
	PUSH	PSW
	CALL	ILPRT
	DB	ESC,ETEOP,ESC,EDIM,0	;clear above msg line
	POP	PSW
	JNZ	CANVIEW		;..if 'cancel'.
	MVI	A,LPS-1 		;if so, set up for single-line..
	STA	LPSCNT		;..scroll and..
	RET			;..return for one more line.

CANVIEW	CPI	ESC		;escape?
	JZ	COMCAN
	CPI	CAN		;cancel?
	RNZ			;return for another page
	JMP	COMCAN		;exit at same ring position

; m a s s   c o p y

; copy files tagged using the 't' command.  auto-erase if file exists
; on requested destination drive or in user area.

MASS	LXI	H,UTLRING+12	;get 1st possible tag location
	SHLD	RINGPOS
MASS$LP	MVI	A,'*'
	CMP	M
	INX	H		;get in 'filename' synchronization
	SHLD	RINGPOS
	JZ	MCOPY		;copy filename with tag character (*)
M$LP	LHLD	RINGPOS		;re-entry point for next file mass-copy
	XCHG			;at ring..
	LHLD	RINGEND		;..end yet?
	CALL	CMPDEHL		; (compare present position with end)
	JZ	MF$EXIT		;yes, jump to beginning of ring.
	LHLD	RINGPOS		;re-establish position pointer
	JMP	MASS$LP		;no, loop 'till thru ring list.

MF$EXIT	XRA	A		;reset flags..
	STA	FIRST$M		;..for..
	CMA			;..next..
	STA	MFLAG		;..mass-copy request.
	CALL	CRLF		;start with fresh line at..
	JMP	CMDLOOP		;..ring beginning.

; c o p y

; copy source file at current 'ring' position to another drive.  set-up
; fcb's and buffer area and check for correct keyboard inputs.  contains
; auto-crc file copy verification.

MCOPY	XRA	A		;zero flag to..
	STA	MFLAG		;..mass copy.
COPY	LXI	H,FCB3		;initialize..
	CALL	INITFCB		;..fcb3 for processing.
	CALL	RINGFCB3	;move from 'ring' to 'fcb3'
	MVI	B,33		;copy source 'fcb3' to destination 'fcb4'
	LXI	H,FCB3		;from point..
	LXI	D,FCB4		;..to point..
	CALL	MOVE		;..move across.
	LXI	D,FCB3		;open file for reading
	MVI	C,OPEN		;open function
	CALL	BDOS
	INR	A		; 0ffh --> 00h if bad open
	JNZ	COPY2		;if okay, skip error message.
	CALL	ILPRT
	DB	CR,LF,'++ Unable to Open Source ++',0
	JMP	FORWARD

COPY2	LDA	FIRST$M		;by-pass prompt, drive/user compatibility..
	ORA	A		;..test, and disk reset after..
	JNZ	COPY3M		;..1st time thru in mass-copy mode.
	CALL	ILPRT		;prompt for drive selection
	DB	BS,'Copy to drive/user: ',0
	CALL	DEF$D$U		;get drive and user area requested..

; either drives or user areas must be different

	LDA	FCB		;..and set for compare.
	MOV	B,A
	LDA	FCB3
	CMP	B
	JNZ	COPY3		;branch if different
	LDA	R$U$A		;requested user area --> rua
	MOV	B,A
	LDA	C$U$A		;current user area --> cua
	CMP	B
	JNZ	COPY3
	CALL	ILPRT		;if not, show error condition:
	DB	CR,LF,BELL
	DB	'++ Drives or User Areas must be different ++',0
	JMP	COMCAN		;try again?

COPY3	CALL	RESET		;reset system for disk change
COPY3M	LDA	FCB		;put requested drive into..
	STA	FCB4		;..place in destination fcb.
	LDA	R$U$A		;toggle to..
	CALL	SET$USR		;..requested user area.
	LDA	MFLAG		;auto-erase..
	ORA	A		;..if..
	JZ	COPY4M		;..in mass-copy mode.
	LXI	D,FCB4		;search for duplicate
	MVI	C,SRCHF		; 'search first' function
	CALL	BDOS
	INR	A		;if none found, 0ffh --> 00h.
	JZ	COPY5		;to 'make' function for new file
	CALL	ILPRT		;ask to replace
	DB	CR,LF,' ---> Copy exists, erase? (Y/N): ',0
	CALL	RESPOND		;get answer
	CPI	'Y'		;if yes, then..
	JZ	COPY4M		;..delete and overlay.
	LDA	C$U$A		;reset to..
	CALL	SET$USR		;..current user area.
	JMP	FORWARD		;if copy not wanted, to next position.

COPY4M	LXI	D,FCB4		;delete file already existing
	MVI	C,ERASE		;erase function
	CALL	BDOS
COPY5	LXI	D,FCB4		;make new file and open for writing
	MVI	C,MAKE		;make function
	CALL	BDOS
	INR	A		;if directory full, 0ffh --> 00h.
	JNZ	COPY6		;if not, branch.
	CALL	ILPRT
	DB	CR,LF,'++ Copy Directory Full ++',0
	JMP	FORWARD		;if error, back to ring processor.

COPY6	MVI	B,8		;show filename and..
	LXI	H,FCB4+1
	LXI	D,COPYMFN
	CALL	MOVE
	INX	D
	MVI	B,3		;..filetype during copy.
	CALL	MOVE
	LDA	FIRST$M		;if 1st time thru mass-copy..
	ORA	A		;..mode, add..
	MVI	A,LF		;..a line feed.
	CZ	TYPE
	CALL	ILPRT
	DB	CR,'                                 '	;clear line
	DB	CR,' ---> Copying file '
COPYMFN	DB	'        .    ',0
	CALL	CLRCRC		;clear storage for 'crc' working value
	XRA	A		;clear 'eof'..
	STA	EOFLAG		;..flag.
COPY6A	LDA	C$U$A
	CALL	SET$USR
	LXI	H,0		;clear current-record..
	SHLD	REC$CNT		;..counter.
	LHLD	BUFSTART	;set buffer start pointer..
	SHLD	BUF$PT		;..to begin pointer.

; read source file -- fill buffer memory or stop on 'eof' -- update 'crc'
; on-the-fly

COPY7	LHLD	BUF$PT		;set dma address to buffer pointer
	XCHG			; de-pair --> dma address
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,FCB3		;source 'fcb' for reading
	MVI	C,READ		;record read function
	CALL	BDOS
	ORA	A		; 00h --> read okay
	JZ	SRDOK
	DCR	A		;eof?
	JZ	COPY8		;end-of-file, set 'eof' flag.
	CALL	ILPRT
	DB	CR,LF,'++ Source Read Error ++',BELL,0
	JMP	FORWARD

SRDOK	LHLD	BUF$PT
	MVI	B,80H
COPY7A	MOV	A,M		;get character and..
	CALL	UPDCRC		;..add to 'crc' value.
	INX	H
	DCR	B
	JNZ	COPY7A		;loop 'till record read finished
	LHLD	BUF$PT		;bump buffer pointer..
	LXI	D,80H		;..by..
	DAD	D		;..one..
	SHLD	BUF$PT		;..record.
	LHLD	REC$CNT		;bump buffer..
	INX	H		;..record count and..
	SHLD	REC$CNT		;..store.
	XCHG			;ready to compare to..
	LHLD	REC$MAX		;..maximum record count (full-buffer).
	CALL	CMPDEHL		;compare
	JNZ	COPY7    	;if not full, get next record.
	JMP	COPY9		;full, start first write session.

; indicate end-of-file read

COPY8	MVI	A,TRUE		;set 'eof' flag
	STA	EOFLAG

; write 'read-file' from memory buffer to destination 'written-file'

COPY9	LDA	R$U$A
	CALL	SET$USR
	LHLD	BUFSTART	;adjust buffer pointer..
	SHLD	BUF$PT		;..to start address.
COPY10	LHLD	REC$CNT		;buffer empty?
	MOV	A,H
	ORA	L
	JZ	COPY11		;buffer empty, check 'eof' flag.
	DCX	H		;dec buffer record count for each write
	SHLD	REC$CNT
	LHLD	BUF$PT		;set up dma address
	PUSH	H		;save for size bump
	XCHG			;pointer in de-pair
	MVI	C,SETDMA
	CALL	BDOS
	POP	H
	LXI	D,80H		;bump pointer one record length
	DAD	D
	SHLD	BUF$PT
	LXI	D,FCB4		;destination file 'fcb'
	MVI	C,WRITE		;write record function
	CALL	BDOS
	ORA	A   		; 00h --> write okay
	JZ	COPY10		;okay, do next record.  else..
	CALL	ILPRT		;..say disk write error
	DB	CR,LF,'++ Copy Disk Full ++',BELL,0
C$ERA	LXI	D,FCB4		;delete..
	MVI	C,ERASE		;..partial..
	CALL	BDOS		;..from directory.
	XRA	A		;reset 1st-time-thru flag..
        STA	FIRST$M		;..for continuation of mass copying.
	JMP	FORWARD		;back to ring

COPY11	LDA	EOFLAG		;buffer all written, go check 'eof'.
	ORA	A
	JZ	COPY6A		;read next buffer full
	LXI	D,FCB4		;point at 'fcb' for file close
	MVI	C,CLOSE
	CALL	BDOS
	INR	A		;if no-close-error then..
	JNZ	CRC$CMP		;..compare file crc's.
	CALL	ILPRT
	DB	CR,LF,'++ Copy Close Error ++',0
	JMP	C$ERA

; read destination 'written-file' and compare crc's

CRC$CMP	LHLD	CRCVAL		;transfer 'crc' value to..
	SHLD	CRCVAL2		;..holding storage area and..
	CALL	CLRCRC		;..clear working storage to continue.
	LXI	D,TBUF
	MVI	C,SETDMA
	CALL	BDOS
	XRA	A
	STA	FCB4+12		;zero current extent and..
	STA	FCB4+32		;..record counter.
	LXI	D,FCB4
	MVI	C,OPEN
	CALL	BDOS
	INR	A		; 0ffh --> 00h if bad open
	JZ	BADCRC		;if bad open, just say 'bad-crc'.
CRCWF1	LXI	D,FCB4
	MVI	C,READ
	CALL	BDOS
	ORA	A		;read okay?
	JZ	DRDOK		;yes, get more.
	DCR	A		; 'eof'?
	JZ	UFINCRC		;yes, finish up and make 'crc' comparison.
	CALL	ILPRT
	DB	CR,LF,'++ Copy Read Error ++',BELL,0
	JMP	FORWARD

DRDOK	LXI	H,TBUF
	MVI	B,80H
CRCWF2	MOV	A,M		;get character to..
	CALL	UPDCRC		;..add to 'crc' value. 
	INX	H
	DCR	B
	JNZ	CRCWF2
	JMP	CRCWF1

; crc subroutines

UFINCRC	LDA	C$U$A		;set to (back to) current user area
	CALL	SET$USR
	LHLD	CRCVAL		;copy written-file 'crc' into..
	XCHG			;..de-pair.
	LHLD	CRCVAL2		;copy read-file 'crc' and..
	CALL	CMPDEHL		;..compare de/hl-pairs for equality.
	JNZ	BADCRC		;if not zero, show copy-error message.
	CALL	ILPRT		;if zero, show 'verified' message and..
	DB	CR,' ---> Copy CRC verified         ',0
	LDA	MFLAG		;..if not mass-copy mode, return..
	ORA	A		;..to next 'ring' position.
	JNZ	FORWARD		;else..
	MVI	A,TRUE		;..set 1st time-time-thru flag..
	STA	FIRST$M		;..and..
	JMP	M$LP		;..get next file to copy, if one.
 
BADCRC	CALL	ILPRT
	DB	CR,LF,BELL,'++ Error on CRC compare ++',0
	JMP	COMCAN		;retain 'ring' position

; 'utl' subroutines

; error return and recovery from command cancellation

ERRET	CALL	ILPRT
	DB	CR,LF,'++ Drive/User Entry Error ++',BELL,0
COMCAN	LXI	SP,STACK	;reset stack
	CALL	CRLF		;return to same line after..
	JMP	NEUTRAL		;..error/command abort.

; fill buffer with 'spaces' with count in b-reg

FIL$UTL	MVI	M,' '		;put in space character
	INX	H
	DCR	B		;count done?
	JNZ	FIL$UTL		;no, branch.
	RET

; check for legal cp/m filename character

CKLEGAL	LDAX	D		;get character from de-pair
	INX	D		;point at next character
	CPI	' '		;less than space?
	RC			;return carry if unpermitted character
	PUSH	H		;protect active..
        PUSH	B		;..registers.
	CPI	'['		;if greater than 'z', exit with..
	JNC	CKERR		;..carry set.
	MVI	B,8		; # of characters in table..
	LXI	H,CHR$TBL	;..pointed to by hl-pair.
CHR$LP	CMP	M		;check..
	JZ	CKERR		;..each..
	INX	H		;..against characters..
	DCR	B		;..in table.
	JNZ	CHR$LP
	ORA	A		;clear carry..
	POP	B		;..for..
	POP	H		;..good character..
	RET			;..return.

CKERR	POP	B
	POP	H
	STC			;error exit with..
	RET			;..carry set.

CHR$TBL	DB	'*',',',':',';','<','=','>','?'	;invalid character table

; filename from 'ring' to 'fcb3' (source fcb)

RINGFCB3 LHLD	RINGPOS		;move name from ring to source 'fcb'
	 LXI	D,-13		;substract 13 to..
	 DAD	D		;..point to name position.
	 LXI	D,FCB3		;place to move filename and..
	 MVI	B,12		;..amount to move.
	 JMP	MOVE		;return to caller

; filename from 'ring' to 'fcb4' (destination fcb)

RINGFCB4 LHLD	RINGPOS
	 LXI	D,-13
	 DAD	D
	 LXI	D,FCB4
	 MVI	B,12
	 JMP	MOVE

; determine # of bcd digits in hl-pair -- place # in b-reg

DET$BCD	LXI	D,9		;test for less than 10
	CALL	CMPDEHL		;compare and..
	MVI	B,1		; (one bcd digit)
	RNC    			;..return if not carry.
	MVI	E,99		;less than 100?
	CALL	CMPDEHL
	MVI	B,2
	RNC
	LXI	D,999		; <1000?
	CALL	CMPDEHL
	MVI	B,3
	RNC
	MVI	B,4		;assume >999  (4 digits)
	RET

; get free storage remaining on selected drive

FRESTOR	LDA	FCB		;put drive into..
	STA	FCB4		;..'fcb4' for..
	JMP	STORAGE		;..free-bytes calculation.

; 'utl' initialized storage

FIRST$M	 DB	FALSE		; 1st time thru in mass-copy mode
MFLAG	 DB	TRUE		;multiple file copy flag --> 0 for mass copy
TAG$TOT	 DW	0		;summation of tagged file sizes
	 ENDIF			; 'utl'

; s t o r a g e

; operating mode table

OPTBL	 EQU	$	;table start and..
ANSWFLG	 DB	'A'	;answer mode in response to originating call flag
DISCFLG	 DB	'D'	;disconnect after primary mode complete flag
EXITFLG	 DB	'E'	;exit-to-cp/m-with-disconnect-and-reboot flag
ORIGFLG	 DB	'O'	;originate mode flag
QFLG	 DB	'Q'	;suppress most send/receive status/text from crt
RSEEFLG	 DB	'R'	;view receive status and text on crt
SSEEFLG	 DB	'S'	;view send status and text on crt
VSEEFLG	 DB	'V'	;view either send/receive ascii text (no status msg)
TERMFLG	 DB	'T'	;return to terminal mode after file transfer(s)
BATCHFLG DB	TRUE	; 'batch' permits multi-file (*.*) transfers
OPTBE	 EQU	$	;..end address.

RESTROPT DB	'A','D','E','O','Q','R','S','V','T','B'
			;reset secondary options, same order as above.

; send/receive file control table

RECDNOB	 EQU	$	;record table address start..
RCVRNO	 DB	0
RECDNO	 DW	0
ERRCT	 DB	0
ERRCDE	 DB	0
EOFLG	 DB	0
RECPTR	 DW	DBUF
RECINBF	 DB	0
MAXEXT	 DB	0
RCNT	 DW	0
DATAFLG	 DB	0
RECDNOE	 EQU	$	;..and ending.

RESTRN	 DB	0,0,0,0,0,0	; 13 bytes to..
	 DW	DBUF		;..match table..
	 DB	0,0,0,0,0	;..markers above.

; other initialized storage

ABORTFLG DB	0	;determines if an abort returns to cmd mode
ALERTFG	 DB	FALSE	;true announces file-save was established
BAUDRATE DB	52	; 300 baud default divisor
BUFBEG	 DW	0	;printer ring-buffer beginning (from 'initadr')
BUFEND	 DB	1,0	;printer ring-buffer end address (+1)
BUFRIN	 DW	0	;pointer to last character into ring-buffer..
BUFROUT	 DW	0	;..and last character out from buffer.
CMDFLG	 DB	FALSE	;flag next
CRCVAL	 DW	0	;store 2-byte crc value
CRCFLG	 DB 	'C'	;use crc instead of cksum if zeroed
CRFLAG	 DB	0	;continuous redial flag
C$U$A	 DB	0	; 'current user area' storage
DIRECTB	 DB	FALSE	;main and..
DTYPE	 DB	FALSE	;..temporary direct console flag.
FILBYTE	 DB	FALSE	;default filters not control characters
FIRSTME	 DB	TRUE	;false after 1st soh received
FSTFLG	 DB	TRUE	; 1st time thru batch
HALFDUP	 DB	FALSE	;default is full-duplex
LINEFLG	 DB	FALSE	;true shows telephone line connected
LISTFLG	 DB	TRUE	;set false --> char to printer
LNEDFLG	 DB 	TRUE	;normally set default true for line editor
LSTRETF	 DB	FALSE	;true --> printer-on returning to terminal mode
MFFLG1	 DB	FALSE	;multi-file 1st time switch
MODCTLB	 DB	7FH	;default modem filter (dtr) value
NFILFLG	 DB	TRUE	;set false by write to memory in 't' mode
OPTION	 DB	0	;primary option stored here
R$U$A	 DB	0	; 'requested (temporary) user area' storage
SAVEFLG	 DB	FALSE	;toggled by savechr (^y)
UARTCTLB DB	1EH	; 8 data, no parity, 1 stop bit as 'answer' default
WRT$FLG	 DB	TRUE	;colon-save multi-buffer write flag
CMDBUF	 DB	128,0	;cp/m buffer max length, used, and..

; uninitialized storage

	 DS	228	;..storage for buffer and local stack.
STACK	 DS	2	;cp/m stack pointer stored here
ACKFLG	 DS	1	; 'ack' or 'nak' character storage
BITTEMP	 DS	1	;temporary storage byte
BGNMS	 DS	2
BMAX	 DS	2	;highest block number on drive
BMASK	 DS	1	;sec/blk - 1
BSHIFTF	 DS	1	;number of shifts to multiply by sec/blk
C$DR	 DS	1	;currently selected drive designator
CHARCNT	 DS	1	;transfer character counter
CMD$DR	 DS	1	;last comm7 command line drive
CRCTBL	 DS	512	;storage for crc 'word' calculation
DIALCNT	 DS	2	;re-dial # of times counter
DISKNO	 DS	1
O$USR	 DS	1	;initial user area
FCB3	 DS	33
FCB4	 DS	33
FCBBUF	 DS	15
FILECT	 DS	1
FTYCNT	 DS	1	; filetype and..
HLSAVE	 DS	2	;top of 'colon-save' ram file
LASTBYTE DS	RBUF	;buffer for characters received during disk write
LPSCNT	 DS	1	; 'lines per screen' counter for 'vue' pagination
LSPFLG	 DS	1	; 'inbuf' reject leading-spaces flag
MFNAME4	 DS	12	;batch requested and..
MFNAME5	 DS	12	;..current filename.
NBSAVE	 DS	2	;batch multi-filenames buffer pointer
NAMECT	 DS	1	; ..filename character counter.
RBFLAG	 DS	1	;ringback type ('r') of dialing
R$DR	 DS	1	; 'requested drive'
SENDFLG	 DS	1	;true = batch send mode

; 'sap' bios jump table storage

BIOSV	DS	53		;storage for jump vectors
S$WBOOT	EQU	BIOSV+3
SELDSK	EQU	BIOSV+27	;these equates..
SETTRK	EQU	BIOSV+30
SETSEC	EQU	BIOSV+33
SSETDMA	EQU	BIOSV+36	;..must remain..
SREAD	EQU	BIOSV+39
SWRITE	EQU	BIOSV+42
SECTRN	EQU	BIOSV+48	;..unchanged.

; 'sap' uninitialized storage

ADDR	DS	2		;used..
DIRCNT	DS	2		;..by..
I	DS	2		;..sap..
J	DS	2		;sort.
MAPPTR	DS	2
NOSSWAP	DS	1
RECTBL	DS	2
SECTOR	DS	2
TRACK	DS	2
VERFLG	DS	1
WR$FLAG	DS	1

; disk parameter block storage

DPB				; (used by 'sap')
SPT	DS	2
BSH	DS	1
BLM	DS	1
EXM	DS	1
DSM	DS	2
DRM	DS	2
AL0	DS	1
AL1	DS	1
CKS	DS	2
SYSTRK	DS	2

; 'utl' uninitialized storage

	  IF	UTL
BUF$PT	 DS	2	;copy buffer current pointer..
BUFSTART DS	2	;..and begin pointer.
CON$LST	 DS	1	;bdos function storage
CRCVAL2	 DS	2	; 'crc' of finished source read-file
EOFLAG	 DS	1	;file copy loop 'eof' flag
FS$FLG	 DS	1	;tag total versus file size flag
REC$CNT	 DS	2	; # of records currently in ram buffer
REC$MAX	 DS	2	;maximum 128-byte record capacity of buffer
RINGI	 DS	2	;ring sort..
RINGJ	 DS	2	;..pointer.
RINGEND	 DS	2	;ring end pointer
RINGPOS	 DS	2	;current ring position
TEST$RT	 DS	1	;intermediate right-justify data
T$UN$FG	 DS	1	;tag/untag file summation switch
VIEWFLG	 DS	1	; 00h --> to printer list, else type to console.
UTLRING	 EQU	$	;base of filename 'ring' storage
	  ENDIF		; 'utl'

; file and directory buffers

DBUF	 EQU	$	;ram buffer begin for send/receive file with protocol
BOTTRAM  EQU	DBUF+100H AND 0FF00H	;base for 'colon-save' & 'sap' files
NAMEBUF	 EQU	DBUF+(1024*DBUFSIZ)	;batch-mode filenames buffer

; cp/m bdos function equates

RDCON	 EQU	1	;console input with keyin-wait and echo
WRCON	 EQU	2	;byte out to console..
LIST	 EQU	5	;..and printer.
GETVERS	 EQU	12	;determine cp/m version or mp/m
RESETDK	 EQU	13	;reset disk system
LOGIN	 EQU	14	;log-in drive as current
OPEN	 EQU	15
CLOSE	 EQU	16
SRCHF	 EQU	17
SRCHN	 EQU	18
ERASE	 EQU	19
READ	 EQU	20
WRITE	 EQU	21
MAKE	 EQU	22
REN	 EQU	23
INQDISK	 EQU	25	;get current (default) drive
SETDMA	 EQU	26
INQALC	 EQU	27	;cp/m bdos function for allocation vector and..
GETPARM	 EQU	31	;..current disk parameters address.
SGUSER	 EQU	32	;set or get user area
COMPSZ	 EQU	35	;compute file size

; system addresses

WBOOT	 EQU	CPM$BASE+00H	;cp/m warm boot entry
BDOS	 EQU	CPM$BASE+05H	;fdos entry vector
FCB	 EQU	CPM$BASE+5CH	;cp/m default fcb location
FCBEXT	 EQU	FCB+12		;extent vector
FCB2	 EQU	FCB+16		;second default fcb
FCBRNO	 EQU	FCB+32		;record (sector) number
TBUF	 EQU	CPM$BASE+80H	;cp/m system default temporary buffer

; assembled 'com' and 'ram-loaded' file size (3c00h = 15k)

COMFILE	 EQU	(CMDBUF+2)-256	;prn listing shows com..
	 END	SOURCE		;..and loaded file size.
