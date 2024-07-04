;COMPARE DISK'S FOR SAME FILE'S AND DELETE THEM FROM DISK 2
; 8-29-83
;
; fixes in reverse order
;	8-29-83
;	Incorectly put file on destination user under default. Now
;	put on default user.
;	^C abort corrected so it won't lock up at abext2:
;
; Portions extracted from
; CRCK.ASM Version 5.1 (Originally by: Keith Petersen, W8SDZ)
; 
;           x^16 + x^15 + x^13 + x^7 + x^4 + x^2 + x + 1
; 
; Commands:   same drive[user]:name.typ drive[user]:name.type [$f,e,n,c,x,w,d]
;	commas are just used here for diferentiating instrusctions
;
;    Options	Descriptionns
;	$	start options
;	F	Write compare text to SAMELIST.PRN and crc data
;		to CRCKLIST.CRC on each disk and default user if
;		no user selected
;	E	Erase files that are equal
;	N	Don't promt operator to erase file
;	C	Display CRCKLIST.CRC files on console
;	X	Use existing CRCKLIST.CRC files from selected
;		user or default user. Uses old crc generation if
;		old CRCKLIST.CRC encounteredss
;	W	Wait and promt operator for disk change
;	D	Default to F,N,X,W options
; 
; Examples:
; 
; same a: b: compare all file's all user's on a: to same on b:
; same a0: b0: compare all file's user 0 on a: to same on b:
; same a:*.asm b:*.asm $fwn
; 
; I found that i had many disks with the same files on them. Long ago
; I had put together a basic program to compare out of sequence CRCKLIST.CRC
; files and list out same files, the basic program took quite a while to
; compare the data so i put this together just for fun. I started thinking
; of all kinds of neet options to put in it, shortly it got out of hand. The
; original file comparison formating does not look the best but it tells
; the operator what he was after to start with.
;
; Any questions or fixes please send then to
; Joe Cutler
; 2340 Alice Ann Rd.
; Newbury Park,CA.
; (805) 498-1141
;
; I'm also periodicaly on Trevors RBBS
; (805) 492-5472
; 
; define true and false
; 
false	equ	0
true	equ	not false
; 
; define write buffer size (presently set for 8k)
; 
bsize	equ	8*1024	; disk write buffer size
; 
; bdos equates
; 
rdcon	equ	1
wrcon	equ	2
dcon	equ	6
cstat	equ	11
open	equ	15
close	equ	16
srchf	equ	17
srchn	equ	18
delet	equ	19
read	equ	20
write	equ	21
make	equ	22
renam	equ	23
stdma	equ	26
;
bdos	equ	5
;
fcb	equ	5ch 
fcbext	equ	fcb+12
fcbrno	equ	fcb+32
fcb2	equ	6ch
;
tbuf	equ	80h; temporary buffer (default) address
buf$siz	equ	80h	; buffer size (128 bytes)
;
sfilesiz	equ	2000h
;
CR	EQU	0DH
LF	EQU	0AH
TAB	EQU	9
eof	equ	'Z'-40h	; end-of-file character
;
; CCIT CRC polynomial mask bytes
;
himsk	equ	0a0h	; high mask byte
lomsk	equ	097h	; low mask byte
FBUFF	EQU	80H
FLEN	EQU	16	;FILE BUFFER LENGTH
;
TRUE	EQU	-1
FALSE	EQU NOT TRUE
;
SIZE	EQU	FALSE
;
	ORG	0100H
START:	LXI	SP,STACK;SET UP NEW STACK
	xra	a
	sta	active
	LDA	FBUFF	;SEE IF ANYTHING SELECTED
	ORA	A
	JZ	HELP	;NO
	lxi	d,signon;tell them we're here
	call	print
	CALL	GLOOK	;GENERATE FAST CRC LOOKUP TABLE
	LXI	D,FBUFF+1;INPUT STRING
	LXI	H,SFCB	;SOURCE FCB
	CALL	MAKFCB
	JC	BADFCB	;ERROR
	MOV	A,B	;GET USER #
	STA	SUSER	;SAVE SOURCE USER
	LXI	H,DFCB	;DESTINATION FCB
	CALL	MAKFCB
	JC	BADFCB	;ERROR
	MOV	A,B	;GET USER #
	STA	DUSER	;DESTINATION USER
	LXI	H,SFCB+1;FILENAME
	LDA	SFCB+9	;TYPE
	ORA	M	;SEE IF NO FILE SELECTED
	CPI	' '
	CZ	FILLFCB	;FILL FCB NAME.TYPE WITH ?
	LXI	H,DFCB+1;FILENAME
	LDA	DFCB+9	;TYPE
	ORA	M	;SEE IF NO FILE SELECTED
	CPI	' '
	CZ	FILLFCB	;FILL FCB NAME.TYPE WITH ?
;
	CALL	DECOPT	;DECODE OPTIONS
;
	LDA	SFCB	;SOURCE DISK
	DCR	A	;DIRECT SELECT
	JP	GETD
	JNZ	GETD
	MVI	C,25	;GET LOGGED IN DISK
	CALL	BDOS
GETD:	STA	SDISK	;SOURCE DISK
	MOV	C,A	;SAVE SOURCE DISK
	LDA	DFCB	;DESTINATION DISK
	DCR	A	;ACTUAL SELECT
	JP	CMPD	;DIRECT SELECTED
	MVI	C,25	;GET LOGGED IN DISK
	CALL	BDOS
CMPD:	STA	DDISK	;SET UP AS DESTINATION ALSO
	CMP	C	;SAME DISK?
	JNZ	GETU	;NO GET USER #
	LDA	SUSER
	LXI	H,DUSER
	CMP	M
	JZ	SAMDSK	;SAME DISK AND USER
GETU:	MVI	E,0FFH	;GET USER #
	MVI	C,32
	CALL	BDOS
	STA	OLDUSR	;OLD USER #
	LDA	SUSER	;SOURCE USER
	STA	SFCB	;SET IN FCB FOR COMPARE
	LDA	DUSER	;DESTINATIN USER
	STA	DFCB	;SET IN FCB FOR COMPARE
;LOGIN IN SELECTED DRIVES
	CALL	LOGIN	;LOG IN DISKS
;GET FILES FROM SOURCE DISK
	LXI	H,NAMBUF
	SHLD	SBUFF	;SOURCE BUFFER
	LDA	SDISK	;SELECT SOURCE DISK
	XCHG
	LXI	H,SFCB	;SOURCE FCB
	CALL	SFILES	;SET UP FILES
	JC	NOFILE	;NO FILES THERE
	LHLD	NAMPTR	;GET POINTER
	SHLD	DBUFF	;SET UP DESTINATION BUFFER
	LHLD	ACT$CRCK;CRCKLIST.CRC FILE FLAGS
	SHLD	S$ACT	;SET SOURCE ACTIVE FLAGS
	CALL	NSORT	;SORT NAMES
	JC	NSAME	;DIFFERENT USER HAS SAME FILE NAME.TYPE
;GET FILES FROM DESTINATION DISK
	LHLD	DBUFF	;DESTINATION BUFFER POINTER
	XCHG
	LXI	H,DFCB	;DESTINATION FCB
	LDA	DDISK	;SELECT DESTINATION DISK
	CALL	SFILES	;SET UP FILES
	JC	NOFILE	;NO DESTINATION FILES
	LHLD	NAMPTR	;END OF DESTINATION BUFFER
	SHLD	EDBUFF
	LHLD	ACT$CRCK;CRCKLIST.CRC FILE FLAGS
	SHLD	D$ACT	;SET DESTINATION ACTIVE FLAGS
	CALL	NSORT	;SORT FILES
	JC	NSAME	;DIFFERENT USER HAS SAME FILE NAME.TYPE
;COMPARE FILES FROM BOTH DISKS
	CALL	CFILES	;COMPARE FILES
;
	LXI	D,WAIT?	;WAIT FOR KEYBOARD
	CALL	PRINT
	MVI	C,1	;GET CHARACTER
	CALL	BDOS
;
	CALL	DFILES	;DISPLAY FILE COMPARES
;
	CALL	ERASE	;ERASE SAME FILES
;
	CALL	DISPCRC	;WRITE CRC DATA
;
	LXI	D,DONE	;THATS ALL FOLKS
	LDA	WFLAG	;WAIT IN PROGRESS
	ORA	A
	JZ	ERROR	;NO ERROR BUT NORMAL RETURN
	LXI	D,FWAIT	;WAIT FOR SYSTEM DISK
	CALL	PRINT
	MVI	C,1	;WAIT FOR RESPONSE
	CALL	BDOS
	JMP	RETURN
;LOGIN IN SELECTED DRIVES
LOGIN:	LDA	SDISK
	ORA	A	;DISK A
	JZ	WLOGIN
	LDA	DDISK
	ORA	A	;DISK A ?
	JZ	WLOGIN
	CALL	RLOGIN	;RE-LOGIN SYSTEM
WLOGIN:	LDA	WFLAG	;WAIT FOR OPERATOR RESPONSE
	ORA	A
	JZ	RLOGIN	;YES
	LXI	D,WAIT	;WAIT MESSAGE
	CALL	PRINT
	MVI	C,1	;ANY CHARACTER
	CALL	BDOS
RLOGIN:	MVI	C,13	;RESET DISK SYSTEM
	CALL	BDOS
	RET
;GET FILES IN BUFFER
;HL=FILE NAME COMPARE BUFFER,A=DISK
SFILES:	SHLD	CMPFCB	;COMPARE FCB POINTER
	XCHG
	SHLD	BUFF	;BUFFER POINTER
	MOV	E,A
	MVI	C,14
	CALL	BDOS	;LOG IN NEW DISK
	LXI	H,0	;RESET FILE COUNT
	SHLD	NAMCNT
	CALL	GETSAME	;GET FILES
	CMC
	RNC		;GOT FROM CRCKLIST.CRC
	MVI	A,'?'	;SET UP USER FCB
	STA	UFCB
	MVI	C,17	;SEARCH FOR FIRST
	LXI	D,UFCB	;ALL USER SEARCH
	CALL	BDOS
	CPI	-1	;NO FILES THERE
	STC		;SET UP FOR NO FILE
	RZ
	JMP	GOTFILE
SNFILE:	MVI	C,18	;NOW NEXT FILE
	CALL	BDOS
	CPI	-1	;NO MORE FILES
	JNZ	GOTFILE	;FILE HERE
	LHLD	NAMCNT	;ANY FILES IN BUFFER
	MOV	A,H
	ORA	L
	RNZ		;YES
	STC		;NO, ERROR RETURN
	RET		;THATS ALL FOLKS
GOTFILE:
	ADD	A	;COMPUTE OFFSET TO NAME
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	MOV	E,A
	MVI	D,0
	LXI	H,FBUFF
	DAD	D
	XCHG
	LDAX	D	;SEE IF NUL FILES
	CPI	0E5H
	JZ	SNFILE	;YES NULL
	PUSH	D	;SAVE NAME POINTER
	LHLD	CMPFCB	;NAME POINTER
	MVI	B,13	;USER #,FILENAME.TYPE,EXTENT
	XCHG
	CALL	NCOMP	;COMPARE NAMES
	POP	D
	JNZ	SNFILE	;NOT SAME FILE NAME
	LHLD	NAMPTR	;GET PRESENT NAME POINTER
	MVI	M,0	;PRESET FILE STATUS FLAG
	INX	H
	MVI	B,12	;GET FILE NAME
	CALL	MOVE
	XRA	A
	MOV	M,A
	INX	H	;FILE LENGTH BUFFER
	MOV	M,A
	INX	H
	MOV	M,A
	INX	H
	SHLD	NAMPTR	;SAVE FOR NEXT NAME
	LHLD	NAMCNT	;NAME COUNTER
	INX	H
	SHLD	NAMCNT
	JMP	SNFILE	;TRY NEXT FILE
;
NCOMP:	LDAX	D	;FROM ADDRESS
	CPI	'?'	;ANY CHARACTER
	JZ	NCOMP0
	CMP	M
	RNZ		;NOT SAME ERROR
NCOMP0:	INX	D	;INCREMENT POINTER
	INX	H
	DCR	B	;COUNTER
	JNZ	NCOMP	;KEEP COMPAREING
	RET
;
;SORT NAMES IN BUFFER
;
NSORT:	XRA	A	;RESET MULTIPLE FILES FLAG
	STA	MFILES
	LXI	D,SORTING
	CALL	PRINT
	MVI	C,-1	;JUST FOR FIRST PASS
NEXTS:	MOV	A,C	;GET SWAPPED FLAG
	ORA	A
	JZ	NSORT$END;DIDN'T SWAP, END OF SORT
	LHLD	NAMCNT	;# OF FILES IN BUFFER
	DCX	H	;DECRIMENT COUNT
	SHLD	NAMCNT
	MOV	A,H	;TEST FOR 0
	ORA	L
	JZ	NSORT$END
	PUSH	H
	MVI	C,0	;INITIALIZE SWAPPED FLAG
;
;PASS THRU THE BUFF, SORTING IT.
;
	LHLD	BUFF	;GET BUFFER POINTER
	XCHG
COMPR:	LXI	H,FLEN	;NAME LENGHT
	DAD	D
	PUSH	D
	PUSH	H
	INX	H	;GET PAST FLAG AND USER
	INX	H
	INX	D
	INX	D
	MVI	B,11	;COMPARE LENGTH
CLCLP:	LDAX	D
	CMP	M
	JC	NEXTC	;first name smaller
	JNZ	DIFF
SAME:	INX	D
	INX	H
	DCR	B
	JNZ	CLCLP
	MVI	A,-1	;SET MULITPLE FILE FLAG
	STA	MFILES
	POP	H
	POP	D
	LDAX	D	;GET PREVIOS FLAG
	ORA	A
	JNZ	NEXTC1	;ALREADY DISPLAYED
	PUSH	D	;SAVE AGAIN
	PUSH	H
	PUSH	B	;SAVE SWAPPED FLAG
	SHLD	SSFCB
	XCHG
	SHLD	SDFCB
	MVI	A,0010$0000B
	ORA	M	;OR IN FLAG
	MOV	M,A
	LDAX	D	;GET EXISTING FLAG
	ORI	0010$0000B
	STAX	D	;SET UP DISPLAYED FLAG
	INX	D	;GET TO USER #
	INX	H
	LDAX	D	;SECOUND USER #
	MOV	L,M	;FIRST USER #
	MOV	H,A
	CALL	DFNAME	;DISPLAY FILE NAME
	POP	B	;GET SWAPPED FLAG BACK
NEXTCº	POÐ	H
	POP	D
NEXTC1:	XCHG
NEXTC2:	POP	H	;FILE COUNT
	DCX	H
	MOV	A,H	;END OF LOOP
	ORA	L
	JZ	NEXTS	;COMPLETED PASS THRU BUFF
	PUSH	H	;SAVE COUNT
	JMP	COMPR	;CHECK NEXT 2
;
;UNEQUAL COMPARE
;
DIFF:	POP	H
	POP	D	;GET POINTERS
;SWAP
	MVI	B,FLEN
SWAP:	MOV	C,M
	LDAX	D
	MOV	M,A
	MOV	A,C
	STAX	D
	INX	D
	INX	H
	DCR	B
	JNZ	SWAP
	MVI	C,-1	;SET SWAPED FLAG
	JMP	NEXTC2
NSORT$END:
	LDA	MFILES	;MULTIPLE FILES
	INR	A	;SET CARRY IF MULTIPLE FILES
	RET
;
;COMPARE SOURCE AND DESTINATION FILE BUFFERS
;
CFILES:	XRA	A	;SET UP PASS COUNT
	STA	CPASS
CMPASS:	LDA	CPASS	;WHICH PASS
	INR	A
	STA	CPASS
	IF	SIZE
	CPI	4	;# OF PASSES
	ELSE
	CPI	3	;# OF PASSES
	ENDIF
	RNC		;ALL DONE
	ANI	1	;TEST FOR WHICH DISK TO SELECT
	LDA	SDISK	;SELECT SOURCE DISK
	JZ	CDISK	;SELECT DISK
	LDA	DDISK	;SELECT DESTINATION DISK
CDISK:	MOV	E,A
	MVI	C,14	;SELECT DISK
	CALL	BDOS
	LHLD	SBUFF	;SOURCE BUFFER
	SHLD	SSBUFF	;SEARCH SOURCE BUFFER
	LHLD	DBUFF	;DESTINATIN BUFFER
	SHLD	SDBUFF	;SEARCH DESTINATION BUFFER
CNFILE:	LHLD	SSBUFF	;SEE IF END
	XCHG
	LHLD	DBUFF	;SEE IF END OF BUFFER
	CALL	SUBDHC
	JNC	CMPASS	;NEXT PASS
	LHLD	SDBUFF	;DESTINION BUFFER
	XCHG
	LHLD	EDBUFF	;END DBUFF
	CALL	SUBDHC
	JNC	CMPASS	;NEXT PASS
	LHLD	SSBUFF	;SOURCE BUFFER
	CALL	CFILE	;COMPARE FILE
	JZ	FEQU	;FILE NAMES EQUAL
	JC	INCD	;INCREMENT DESTINATION
	LXI	D,FLEN	;NAME BUFFER LENGTH
	DAD	D
	SHLD	SSBUFF
	JMP	CNFILE	;LOOP ON COMPARE
INCD:	LXI	H,FLEN	;NAME BUFFER LENGTH
	DAD	D
	SHLD	SDBUFF
	JMP	CNFILE	;LOOP ON COMPARE
FEQU:	SHLD	SSFCB
	XCHG
	SHLD	SDFCB
	PUSH	D
	LXI	D,FLEN	;NAME BUFFER LENGTH
	DAD	D
	SHLD	SDBUFF	;NEW DESTINAITION BUFFER
	POP	H
	DAD	D
	SHLD	SSBUFF	;NEW SOURCE BUFFER
	LHLD	SSFCB	;SEE IF ALREADY NO COMPARE
	MOV	A,M
	ANI	0100$0000B;ALREADY NOT COMPARED
	JNZ	CNFILE	;YES
	LDA	CPASS	;COMPARE PASS
	DCR	A	;FIRST PASS
	JZ	CPASS1
	IF	SIZE
	DCR	A	;SECOUND PASS
	JZ	CPASS2
CPASS3:	LHLD	SDFCB	;SET SOURCE FILE
	SHLD	CRCFCB	;SOURCE NAME POINTER
	CALL	GENCRC	;GENERATE CRC FOR FILE
	JMP	CSIZE
CPASS1:	LHLD	SDFCB	;SOURCE FILE NAME
	CALL	SETSIZE	;SET FILE SIZE
	JMP	CNFILE	;LOOP ON COMPARE
CPASS2:	LHLD	SSFCB	;DESTINATION FILE NAME
	SHLD	CRCFCB	;SET UP POINTER
	CALL	SETSIZE	;SET FILE SIZE
CSIZE:	LXI	B,13	;OFFSET TO SIZE
	LHLD	SDFCB	;DESTINATION NAME
	DAD	B
	XCHG
	LHLD	SSFCB	;SOURCE NAME
	DAD	B
	MVI	B,3	;LENGTH OF COMPARE
CMPSIZE:
	LDAX	D	;DESTINATION
	CMP	M
	JNZ	FNEQU	;NOT EQU
	INX	D	;INCREMENT POINTERS
	INX	H
	DCR	B
	JNZ	CMPSIZE	;STILL SAME
	LDA	CPASS	;ONLY ON PASS 1
	CPI	2
	JNZ	CNFILE	;ONLY GENERATE ON SECOUND PASS
	CALL	GENCRC	;DESTINATION CRC
	JMP	CNFILE	;LOOP ON COMPARE
	ELSE
CPASS2:	LHLD	SSFCB	;DESTINATION FILE NAME
	SHLD	CRCFCB	;SET UP POINTER
	CALL	GENCRC	;GENERATE CRC FOR FILE
	LXI	B,13	;OFFSET TO CRC
	LHLD	SDFCB	;DESTINATION NAME
	DAD	B
	XCHG
	LHLD	SSFCB	;SOURCE NAME
	DAD	B
	MVI	B,3	;LENGTH OF COMPARE
CMPSIZE:
	LDAX	D	;DESTINATION
	CMP	M
	JNZ	FNEQU	;NOT EQU
	INX	D	;INCREMENT POINTERS
	INX	H
	DCR	B
	JNZ	CMPSIZE	;STILL SAME
	JMP	CNFILE	;LOOP ON COMPARE
CPASS1:	LHLD	SDFCB	;SET SOURCE FILE
	SHLD	CRCFCB	;SOURCE NAME POINTER
	CALL	GENCRC	;GENERATE CRC FOR FILE
	JMP	CNFILE
	ENDIF
;
FNEQU:	LHLD	SSFCB	;GET SOURCE FILE POINTER
	MOV	A,M	;GET FLAG
	ANI	0011$1111B;MASK OUT EQU
	ORI	0100$0000B;NOT EQU BIT
	MOV	M,A
	LHLD	SDFCB
	MOV	A,M	;GET FLAG
	ANI	0011$1111B;MASK OUT EQU
	ORI	0100$0000B;NOT EQU BIT
	MOV	M,A
	JMP	CNFILE	;LOOP ON COMPARE
;
CFILE:	PUSH	H	;SOURCE
	PUSH	D	;DESTINATION
	MVI	B,11	;COMPARE LENGTH
	INX	H
	INX	H
	INX	D
	INX	D
COMP:	LDAX	D
	CMP	M
	JNZ	CMPEND
	INX	D
	INX	H
	DCR	B
	JNZ	COMP	;KEEP COMPARING
CMPEND:	POP	D	;DESTINATIN
	POP	H
	RNZ		;NOT SAME FILES
	INX	D	;GET TO USER
	LDAX	D	;GET DESTINATION USER #
	ORI	1000$0000B;SET ACTIVE FLAG
	MOV	B,A
	MOV	A,M	;GET EXISTING FLAG
	ANI	0100$0000B;SEE IF ALREADY NON-ZERO
	JNZ	CMPN
	MOV	A,B
	ORA	M	;OR IN FLAGS
	MOV	M,A
CMPN:	DCX	D
	INX	H	;GET TO USER
	MOV	A,M
	ORI	1000$0000B;SET ACTIVE FLAG
	MOV	B,A
	LDAX	D	;GET EXISTING FLAG
	ANI	0100$0000B;SEE IF ALREADY NON-ZERO
	JNZ	CMPL	;YES
	LDAX	D
	ORA	B
	STAX	D	;SET FLAG
CMPL:	DCX	H
	XRA	A	;RESET CARRY
	RET
	IF	SIZE
;GET FILE SIZE
SETSIZE:
	CALL	SETFCB	;SET UP USER AND LFCB
	PUSH	D	;SAVE SIZE POINTER
	LXI	D,LFCB
	MVI	C,35	;COMPUTE FILE SIZE
	CALL	BDOS
	POP	H	;GET NAME POINTER BACK
	LXI	D,LFCB+33;GET FILE SIZE
	MVI	B,3
	CALL	MOVE	;MOVE TO NAME
	RET
	ENDIF
;
SETFCB:	INX	H	;GET TO USER #
	MOV	A,M
	PUSH	H	;SAVE POINTER
	CALL	SETUSR
	POP	D
	INX	D	;GET TO FILE NAME
	LXI	H,LFCB+1
	MVI	B,11
	CALL	MOVE
	XRA	A
	STA	LFCB+12	;EXTENT
	STA	LFCB+15	;RC
	STA	LFCB+32	;CR
	RET
;
setfile:
	lda	fflag	; get option
	sta	active	;active flag
	ora	a	; file wanted?
	rz		; no, skip file init
	push	h	;save user
	push	d	;save pointer
	lxi	h,fcbfinal+1;file to delete
	mvi	b,11	;move full name
	call	move
	lxi	h,samfcb+1;file name
	pop	d
	mvi	b,8	;just move filename
	call	move
	mov	e,c	;get disk
	mvi	c,14	;select disk
	call	bdos
	pop	psw	;get user #
	cpi	'?'	;default user
	jnz	setf0	;no
	lda	oldusr	;default user
setf0:	call	setusr	;set up for default user
	xra	a
	sta	samfcb+12	; clear extent
	sta	samfcb+32	; clear current record count
	lxi	h,sfilesiz	; set buffer size
	shld	sfilelen
	lxi	h,0		; set next to fill
	shld	sfileptr
	mvi	c,delet		; delete file function
	lxi	d,samfcb	; delete 'old' crcklist file
	call	bdos
	mvi	c,make		; make file function
	lxi	d,samfcb	; make 'new' crcklist file
	call	bdos
	inr	a		; make ok?
	rnz			;yes
	lxi	d,dir$full	; indicate that directory is full
	call	print
	jmp	filerr
;
putsfile:
;
	push	psw		; save output character
	lda	active		;see if active
	ora	a
	jz	noput		;not active
	lhld	sfilelen	; get current buffer length
	xchg			; de has length
	lhld	sfileptr	; load next to get/put to hl
	mov	a,l		; compute current length
	sub	e 	
	mov	a,h
	sbb	d		; carry if next < length
	jc	putcrc4		; carry if length > current
	lxi	h,0		; end of buffer, fill (empty) buffers	
	shld	sfileptr	; clear next to get/put
;
putcrc1:			; process next disk sector
;
	xchg			; file pointer to de
	lhld	sfilelen	; hl is maximum buffer length
	mov	a,e		; compute next length
	sub	l		; to get carry, if more fill
	mov	a,d
	sbb	h		
	jnc	putcrc3
	lhld	sfileadr	; got carry, more to fill yet
	dad	d		; hl is next buffer address
	xchg
	mvi	c,stdma		; set dma address
	call	bdos
	lxi	d,samfcb	; fcb address to de
	mvi	c,write		; file write
	call	bdos
	ora	a		; check return code
	jnz	putcrc2		; end-of-file yet?
	lxi	d,buf$siz	; not eof, increment length by 128
	lhld	sfileptr	; next to fill
	dad	d
	shld	sfileptr	; save new pointer
	jmp	putcrc1		; process another sector
;
putcrc2:			; got end-of-file
;
	lxi	d,dsk$full	; disk is full
	call	print
	pop	psw		; clean stack
	jmp	filerr		; file error, exit
;
putcrc3:			; end of buffer, reset dma and pointer
;
	lxi	d,tbuf		; point to temporary buffer
	mvi	c,stdma		; set dma function
	call	bdos
	lxi	h,0		; reset pointer for next to get
	shld	sfileptr
;
putcrc4:			; process the next character
;
	xchg			; index to get/put in de
	lhld	sfileadr	; base of buffer
	dad	d		; address of character in hl
	xchg			; and swap to de
	pop	psw		; get save character
	stax	d		; character to buffer
	lhld	sfileptr	; index to get/put
	inx	h		; and update for next character
	shld	sfileptr
	ret
;
noput:	pop	psw		;get character back
	ret
; 
; close crcklist.$$$
;
closecrc:
;
	lda	active	;see if file active
	ora	a
	rz		;yes
close0:	lhld	sfileptr
	mov	a,l
 	ani	07fh
	jnz	close1
	shld	sfilelen
close1:	mvi	a,eof
	push	psw
	call	putsfile
	pop	psw
	jnz	close0
	xra	a
	sta	active	;clear active flag
	mvi	c,close
	lxi	d,samfcb
	call	bdos
	inr	a
	jnz	cerase
	lxi	d,no$close
	call	print
; 
; erase any existing old file
;
cerase:	mvi	c,delet
	lxi	d,fcbfinal
	call	bdos
; 
; rename crcklist.$$$ to crcklist.crc
;
	lxi	h,samfcb
	lxi	d,fcbfinal
	push	h
	lxi	b,16
	dad	b
;
mov$name:
;
	ldax	d
	mov	m,a
	inx	d
 	inx	h
	dcr	c
	jnz	mov$name
	pop	d
	mvi	c,renam
	call	bdos
	ret
;
gencrc:
	lhld	crcfcb	;get file name pointer
	mov	a,m	;get flag byte
	ani	0001$0000b;see if crc already generated
	rnz		;yes
; 
; open the file
;
	call	setfcb
	lxi	d,lfcb
	mvi	c,open
	call	bdos
	inr	a
	jnz	rdinit
	call	abexit
	db	'++Open Failed++$'
; 
; initialize crc to zero and set bufad to cause initial read
;
rdinit:	lxi	h,0
 	shld	rem	; init remainder to zero
	lxi	h,100h
	shld	bufad	; init buffer adrs
; 
; this is the read loop
;
readit:	lhld	bufad
	mov	a,h	; time to read?
	ora	a
	jz	nord	; no read
	mvi	e,-1	; get console status/character
	mvi	c,dcon
	call	bdos	; check for operator abort
	cpi	'C'-40h	; control c?
	jz	abext2	; yes exit
; 
read2:	lxi	d,lfcb
	mvi	c,read	; read another sector of file
	call	bdos
	ora	a	; check return code
	jnz	finish	; error or eof
	lxi	h,tbuf	; buffer location
; 
nord:	lda	crctype
	cpi	' '	;delimeter for old crck.com
	mov	a,m	; get file character
	inx	h
	shld	bufad
	lhld	rem	; pick up the partial remainder
	jz	oldcrc
; 
; table lookup method for crc generation
;
	xchg		; de now has the partial
	mvi	b,0
	xra	d
	mov	c,a
	lxi	h,hitab
	dad	b
	mov	a,m
	xra	e
	mov	d,a
	inr	h
	mov	e,m
	xchg
	shld	rem
	jmp	readit	; go read more characters
;old crck.com crc generation
;'a' the character to be crc'd
oldcrc:	mov	c,a	;save new byte
	mov	a,h
	ani	80h
	push	psw
	dad	h
	mov	a,c
	add	l
	mov	l,a
	pop	psw
	jz	ocend
	mov	a,h
	xri	himsk
	mov	h,a
	mov	a,l
	xri	lomsk
	mov	l,a
ocend:	shld	rem
	jmp	readit	; go read more characters
; 
;
finish:	cpi	1	; normal end-of-file?
	jnz	filerr	; no, it was a read error
	lhld	rem	; get crc
	xchg
	lhld	crcfcb	; get name pointer
	mov	a,m	;get atributes
	ori	0001$0000b;set crc generated bit
	mov	m,a
	lxi	b,13	; offset to length
	dad	b
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	mvi	m,0	;set to 0
	ret
; 
filerr:	call	abexit	; abort because of file read error
	db	'++File Read Error++$'
;
; generate the lookup table for fast crc
;
glook:	lxi	h,hitab
	mvi	c,0	; the table index
gloop:	xchg
	lxi	h,0	; init the crc
	mov	a,c
	call	lcrc
	xchg		; de now has the crc, hl pointing into table
	mov	m,d	; store the high byte of crc
	inr	h
	mov	m,e	; store the low byte
	dcr	h
	inx	h	; move to next table entry
	inr	c	; next index
	jnz	gloop
	ret
;
;  hl contains the partial, 'a' the character to be crc'd
; 
lcrc:	push	b
	mvi	b,8
	xra	h
	mov	h,a
loop:	dad	h
	jnc	skip
	mvi	a,himsk
	xra	h
	mov	h,a
	mvi	a,lomsk
	xra	l
	mov	l,a
skip:	dcr	b
	jnz	loop
	pop	b
	ret
;
;
; send carriage return, line feed to output
; 
crlf:	mvi	a,cr	; carriage return
	call	outchr
	mvi	a,lf	; line feed, fall into 'type'
	call	outchr
	xra	a
	ret
; 
; send character in a register to output
; 
outchr:	push	b
	push	d
	push	h
	ani	7fh	; strip parity bit
	mov	e,a
	push	d
	call	putsfile; write to file if requested
	pop	d
	lda	cflag	;console flag
	ora	a
	mvi	c,wrcon	; send character to console
	cnz	bdos
	pop	h
	pop	d
	pop	b
	ret
;
;
; aborted - print reason.  if making output file,
; close the incomplete file to update cp/m's bit map,
; then erase it.
; 
abexit:	pop	d	; get msg adrs
	call	print
; 
abext2:	lda	active	; see if we are making file
	ora	a
	jz	abext5	; no file, skip file stuff
abext3:	lhld	sfileptr
	mov	a,l
	ani	07fh
	jnz	abext4
	shld	sfilelen
abext4:	mvi	a,eof
	push	psw
	call	putsfile
	pop	psw
	jnz	abext3
 	mvi	c,close
	lxi	d,samfcb
	call	bdos
	inr	a
	jnz	era$same
	lxi	d,no$close
	call	print
;
; erase incomplete file
;
era$same:
;
	mvi	c,delet
	lxi	d,samfcb
	call	bdos
; 
abext5:	call	erxit	; print msg, exit
	db	cr,lf,cr,lf,'++Aborted++$'
;
; exit with message
; 
msgexit:equ	$	; exit with "informational" message
erxit:	pop	d	; get msg
	call	print
; 
; exit, restoring stack and return to ccp
; 
exit:	jmp	0
;
;
DFILES:	LDA	SDISK	;PUT ON SOURCE DISK
	MOV	C,A
	LDA	SUSER	;source user
	MOV	H,A
	LXI	D,SAMB	;SAME FILE NAME
	CALL	SETFILE	;SET UP SAME FILE ON SOURCE
	CALL	CCRLF
;SOURCE/DESTINATION FILE MATCH
	LHLD	SBUFF	;SOURCE BUFFER
	SHLD	BUFF	;START OF BUFFER
	LHLD	DBUFF	;DESTINATIN BUFFER
	SHLD	NAMPTR	;END OF BUFFER
	MVI	A,1000$0000B;FILES THAT MATCH
	LXI	D,SDSAME
	CALL	PDFILE	;DISPLAY FILES THAT MATCH FLAG
;SOURCE/DESTINATION FILE NAME MATCH BUT NOT CONTENTS
	LHLD	SBUFF
	SHLD	BUFF
	LHLD	DBUFF
	SHLD	NAMPTR
	MVI	A,0100$0000B;SAME FILE NAME DIFFERENT COMTENTS
	LXI	D,SDNSAME
	CALL	PDFILE
;SOURCE FILES NOT ON DESTINATION DISK
	LHLD	SBUFF
	SHLD	BUFF
	LHLD	DBUFF
	SHLD	NAMPTR
	MVI	A,0	;FILES THAT DON'T MATCH
	LXI	D,SNOTD
	CALL	PDFILE
;DESTINATION FILES NOT ON SOURCE DISK
	LHLD	DBUFF
	SHLD	BUFF
	LHLD	EDBUFF
	SHLD	NAMPTR
	MVI	A,0	;FILES THAT DON'T MATCH
	LXI	D,DNOTS
	CALL	PDFILE	;FILES THAT DON'T MATCH
	CALL	CRLF
	CALL	CLOSECRC;CLOSE FILE
	RET
;
PDFILE:	STA	FLAG	;SET UP FLAG
	CALL	OUTST	;PRINT MESSAGE
DFILE:	LHLD	BUFF	;NEXT POINTER
	XCHG
	LHLD	NAMPTR	;END OF BUFFER
	CALL	SUBDHC
	RNC		;THATS ALL FOLKS
	LXI	H,FLAG
	LDAX	D	;GET FLAG
	ANI	1100$0000B;TEST FOR FLAGS ONLY
	CMP	M	;TEST FOR THIS FLAG
	JNZ	DNFILE	;NO
	LDAX	D	;GET DESTINATION USER AND FLAG
	INX	D	;PAST FLAG
	ANI	0FH	;MASK OUT FLAGS
	MOV	H,A
	LDAX	D	;GET SOURCE USER
	MOV	L,A
	CALL	DFNAME	;DISPLAY FILE NAME
DNFILE:	LHLD	BUFF	;BUFFER POINTER
	LXI	D,FLEN	;NEXT NAME OFFSET
	DAD	D
	SHLD	BUFF
	JMP	DFILE	;DISPLAY NEXT FILE
;DISPLAY FILE NAME FROM BUFFER
;DE=FILE NAME STARTING WITH USER #
;H=DESTINATION USER #, L=SOURCE USER #
DFNAME:	PUSH	H	;SAVE USER'S
	PUSH	H
	INX	D	;PAST USER
	LXI	H,SAMEP+1
	MVI	B,8
	CALL	MOVE
	INX	H	;FILE NAME.TYPE DELIMETER
	MVI	B,3
	CALL	MOVE
	LDA	HCOUNT	;HORIZONTAL COUNT
	ANI	3	;MASK OUT JUNK
	STA	HCOUNT
	CZ	CRLF
	LXI	D,DELIM
	CNZ	OUTSTL
	POP	H	;GET USER #
	MVI	H,0	;ZERO SECOUND USER
	CALL	DECOUT
	MVI	A,' '	;DELIMETER
	CALL	OUTCHR
	POP	H
	MOV	L,H	;SECOUND USER
	MVI	H,0
	CALL	DECOUT
	LXI	D,SAMEP	;PRINT FILE NAME
	CALL	OUTSTL
	LDA	HCOUNT
	INR	A	;INCREMENT TAB COUNTER
	STA	HCOUNT
	RET
;
DECOPT:	LDAX	D	;GET CHARACTER
	ORA	A	;END OF STRING
	RZ		;THATS ALL FOLKS
	CPI	'$'
	JZ	GOT$
	INX	D
	JMP	DECOPT
GOT$:	INX	D
	LDAX	D
	ORA	A	;END OF STRING
	RZ		;NO MORE OPTIONS
	CPI	'F'	;DISK FLAG
	JNZ	GOT1	;NO
	STA	FFLAG
GOT1:	CPI	'E'	;ERASE EQUAL FILES
	JNZ	GOT2
	STA	EFLAG
GOT2:	CPI	'N'	;DON'T PROMT ERASE
	JNZ	GOT3
	STA	EFLAG	;WHY ENABLE DON'T PROMT W/O ERASE
	STA	NFLAG
GOT3:	CPI	'X'	;USER CRCKLIST.CRC FILE
	JNZ	GOT4
	STA	XFLAG
GOT4:	CPI	'C'	;DISPLAY FILE OPTION
	JNZ	GOT5
	STA	OCFLAG
GOT5:	CPI	'W'	;WAIT FOR DISK CHANGE FLAG
	JNZ	GOT6
	STA	WFLAG
GOT6:	CPI	'D'	;DEFAULT OPTION
	JNZ	GOT7
	STA	DFLAG	;DEFAULT FLAG
	STA	FFLAG	;WRITE FILE
	STA	EFLAG	;ERASE FILES
	STA	NFLAG	;DON'T PROMT
	STA	XFLAG	;USER CRCKLIST.CRC FILE
	STA	WFLAG	;WAIT FLAG
GOT7:	JMP	GOT$
;
FILLFCB:
	MVI	B,11	;FILL LENGTH
FILOOP:	MVI	M,'?'	;FILL CHARACTER
	INX	H	;INCREMENT POINTER
	DCR	B	;COUNTER
	JNZ	FILOOP
	RET
;
;MAKE FCB 8-12-83
;INPUT
; HL=FCB ,DE=INPUT STRING
;OUTPUT
; CARRY = FILE NAME ERROR
; NO CARRY, DE=NEXT CHARACTER ON INPUT STRING
;MAKE FCB WITH COMAND LINE
MAKFCB:	MVI	A,'?'	;SET FLAG
	STA	SUSR	;SELECTED USER
	CALL	SCAN	;GET TO NON SPACE
	ORA	A
	JZ	MAKE1	;END OF STRING
	SBI	40H	;TEST FOR DISK SELECT
	MOV	B,A
	INX	D
	LDAX	D
	CPI	':'	;DISK DELIMETER
	JZ	MAKE3	;YES
	ORA	A	;END OF STRING
	JZ	MAKE1	;YES
	CALL	USERIN	;GET USER #
	RC		;OOPS ERROR
	JZ	MAKE2	;GOT USER #
MAKE0:	DCX	D
MAKE1:	XRA	A	;DEFAULT DRIVE
	MOV	M,A	;SAVE IN FCB
	JMP	MAKE4
MAKE2:	MOV	A,C	;GET USER #
	STA	SUSR	;SELECTED USER
MAKE3:	MOV	M,B	;SAVE SELECTED DISK
	INX	D
MAKE4:	LXI	B,800H	;FILE NAME LENGHT
	CALL	FIELD	;MOVE FILE NAME
	RC		;ERROR
	MVI	B,3	;FILE TYPE LENGHT
	CALL	FIELDT	;MOVE FILE TYPE
	RC		;ERROR
	MVI	A,3	;FILL EX,S1,S2 WITH 0
MAKE5:	INX	H
	MOV	M,B
	DCR	A
	JNZ	MAKE5
	LDA	SUSR
	MOV	B,A	;SAVE POSIBLE USER #
	MOV	A,C
	ORA	A
	RET
;
FIELDT:	CPI	'.'	;NAME.TYPE DELIMETER
	JNZ	BLANKF	;FILE TYPE WITH BLANKS
	INX	D	;GET PAST DELIMETER
FIELD:	CALL	DELIM?
	RC		;ERROR
	JZ	BLANKF	;FILL REST WITH BLANKS
	INX	H
	CPI	'*'
	JNZ	FIELD0	;NON '*'
	MVI	M,'?'	;FILE REST OF NAME
	INR	C	;INCREMENT AMBIGIOUS COUNT
	JMP	FIELD1	;WITH '?'
FIELD0:	MOV	M,A	;MOVE TO FCB
	INX	D	;INCREMENT COMAND LINE
FIELD1:	DCR	B	;DECRIMENT COUNT
	JNZ	FIELD	;CONTINUE WITH FILE NAME
EATUP:	CALL	DELIM?	;EAT UP EXCESS CHARACTER
	RC
	RZ		;TEST DELIMETER
	INX	D
	JMP	EATUP	;CONTINUE UNTIL FOUND
BLANKF:	INX	H	;FILE REST OF FILE NAME W BLANKS
	MVI	M,' '
	DCR	B
	JNZ	BLANKF
	ORA	A	;RESET FLAGS
	RET
;
DELIM?:	LDAX	D	;TEST FOR DELIMETER
	ORA	A	;END OF STRING
	RZ
	CPI	'='
	RZ
	CPI	5FH	;BACK ARROW
	RZ
	CPI	'.'
	RZ
	CPI	':'
	RZ
	CPI	';'
	RZ
	CPI	'<'
	RZ
	CPI	'>'
	RZ
	CPI	' '
	RET
;
SCAN:	LDAX	D	;SCAN TO NEXT CHARACTER >= 30H
	ORA	A
	RZ		;END OF STRING
	CPI	'0'
	RNC
	INX	D
	JMP	SCAN
;
USERIN:	PUSH	H	;SAVE POINTERS
	PUSH	D
	PUSH	B	;SAVE DISK
	LXI	H,0	;ZERO DE
	CALL	ULOOP
	POP	B
	JC	DERR	;OOPS
	MOV	A,H
	ORA	A
	JNZ	DERR	;TO LARGE
	MOV	A,L
	CPI	16	;MAX USER
	JNC	DERR	;>15
	INX	SP	;
	INX	SP
	POP	H	;FCB
	MOV	C,A	;SAVE USER #
	XRA	A	;FLAGS FOR NORMAL RETURN
	RET
DERR:	CMC		;SET UP IF ERROR RETURN
	POP	D	;GET POINTERS BACK
	POP	H
	MVI	A,0
	INR	A	;SET UP NZ W/O CHANGING CARRY
	RET
;
ULOOP:	LDAX	D	;GET A ASCII DIGIT
	CPI	':'	;TERMINATOR
	RZ		;ALL OK
	SUI	'0'	;CONVERT TO BCD AND TEST
	ANA	A	;RESET CARRY
	RM		;TERMINATE CONVERSION IF < ZERO
	CPI	10	;CHECK LEGITIMATE DIGIT (0-9)
	CMC		;COMPLEMENT CARRY
	RC		;RET WITH CARRY SET IF ERROR
	INX	D	;INCR ADDR POINTER
	DAD	H	;SHIFT LEFT 1
	PUSH	H	;SAVE RESULT
	DAD	H
	DAD	H	;SHIFT LEFT 2
	POP	B	;NO * 2 TO B
	DAD	B	;HL NOW CONTAINS 10*NO
	MOV	C,A	;ADD PRODUCT TO DIGIT
	MVI	B,0
	DAD	B
	JMP	ULOOP	;BACK FOR ANOTHER DIGIT
;
ERASE:	LDA	EFLAG
	ORA	A
	RZ
	LDA	DDISK	;SELECT DESTINATION DISK
	MOV	E,A
	MVI	C,14
	CALL	BDOS
	LHLD	DBUFF	;JUST ERASE DESTINATION FILES
	SHLD	BUFF
	LHLD	EDBUFF	;END
	SHLD	NAMPTR
ERASEL:	LHLD	BUFF	;NEXT POINTER
	XCHG
	LHLD	NAMPTR	;END OF BUFFER
	CALL	SUBDHC
	RNC		;THATS ALL FOLKS
	LDAX	D	;GET FLAG
	ANI	1000$0000B;JUST LOOK FOR EQUAL FILES
	JZ	ERASEN	;ONLY ERASE EQAUL FILES
	LHLD	BUFF	;GET TO NAME
	CALL	SETFCB	;GENERATE FCB
	LHLD	BUFF	;GET TO NAME
	XCHG
	INX	D
	INX	D
	LXI	H,SAMEP+1
	MVI	B,8
	CALL	MOVE
	INX	H	;FILE NAME.TYPE DELIMETER
	MVI	B,3
	CALL	MOVE
	LDA	NFLAG	;SEE IF WE PROMT
	ORA	A
	JNZ	ERA	;NO
	LXI	D,ERAFILE
	CALL	PRINT	;ERASE FILE
	MVI	C,1	;GET ANSWER
	CALL	BDOS
	CPI	'y'
	JZ	ERA
	CPI	'Y'
	JNZ	ERASEN	;NO
ERA:	LXI	D,LFCB
	MVI	C,DELET	;ERASE IT
	CALL	BDOS
	CPI	-1	;ERROR
	JZ	ERASER	;CLOSE ERROR
	LHLD	BUFF	;SET ERASED FLAG
	INX	H	;GET TO USER
	MOV	A,M
	ORI	1000$0000B
	MOV	M,A
	LDA	NFLAG	;DON'T PROMT FLAG
	ORA	A
	JZ	ERA
	CALL	CCRLF
	LXI	D,SAMEP+1;GET FILENAME POINTER
	CALL	PRINT
	LXI	D,ERASED
	CALL	PRINT
ERASEN:	LHLD	BUFF	;BUFFER POINTER
	LXI	D,FLEN	;NEXT NAME OFFSET
	DAD	D
	SHLD	BUFF
	JMP	ERASEL
	RET
;
ERASER:	LXI	D,CLOSEM;CAN'T CLOSE FILE
	CALL	PRINT
	JMP	ABEXT5	;ABORT
;
CCRLF:	MVI	E,CR
	MVI	C,2
	CALL	BDOS
	MVI	E,LF
	MVI	C,2
	CALL	BDOS
	RET
;
DISPCRC:
;	LDA	FFLAG
;	ORA	A
;	RZ		;DON'T WRITE FILE
	LDA	OCFLAG	;OPTION FLAG
	STA	CFLAG
	ORA	A
	LXI	D,SFMESG
	CNZ	PRINT
	LDA	S$ACT	;CRCKLIST.CRC ACTIVE FLAG
	ORA	A
	LDA	SDISK	;SOURCE DISK
	MOV	C,A
	LDA	SUSER	;SOURCE USER
	MOV	H,A
	LXI	D,CRCK	;FILE NAME
	CZ	SETFILE	;OPEN FILE
	LHLD	SBUFF	;SOURCE BUFFER START
	XCHG
	LHLD	DBUFF	;END OF SOURCE BUFFER
	CALL	WRTCRC	;WRITE SOURCE FILES
	CALL	CLOSECRC;CLOSE SOURCE FILE
;
	LDA	CFLAG
	ORA	A
	LXI	D,DFMESG
	CNZ	PRINT
	LDA	D$ACT	;CRCKLIST.CRC ACTIVE FLAG
	ORA	A
	LDA	DDISK	;DESTINATION DISK
	MOV	C,A
	LDA	DUSER	;destination user
	MOV	H,A
	LXI	D,CRCK	;FILE NAME
	CZ	SETFILE	;OPEN FILE
	LHLD	DBUFF	;DESTINATION
	XCHG
	LHLD	EDBUFF	;END
	CALL	WRTCRC	;WRITE DESINTATION FILE
	CALL	CLOSECRC;CLOSE DESTINATION FILE
	RET
;
WRTCRC:	SHLD	NAMPTR	;END
	XCHG
	SHLD	BUFF	;START
WCRCLP:	LHLD	BUFF	;NEXT POINTER
	XCHG
	LHLD	NAMPTR	;END OF BUFFER
	CALL	SUBDHC
	RNC		;THATS ALL FOLKS
	LDAX	D	;GET FLAG
	ANI	0001$0000B;JUST SAVE CRC FILES
	STA	FLAG	;SAVE FOR LATER CONVERSION
	INX	D	;PAST FLAG
	LDAX	D	;GET USER #
	ORA	A	;SEE IF ERASED
	JM	WCRCN	;YES, DON'T WRITE
	PUSH	PSW	;SAVE USER #
	INX	D	;GET TO FILE NAME
	LXI	H,FILEN
	MVI	B,8
	CALL	MOVE
	INX	H	;GET PAST .
	MVI	B,3
	CALL	MOVE
	XCHG		;HL=CRC WORD
	XTHL
	PUSH	H	;SAVE USER #
	LXI	D,FILEN	;PRINT LENGHT
	CALL	OUTST
	POP	PSW	;GET USER BACK
	MOV	L,A
	MVI	H,0
	CALL	DECOUT
	LXI	D,CRCM
	LDA	FLAG	;SEE IF WE PRINT CRC
	ORA	A
	CNZ	OUTST
	POP	H	;GET CRC BYTES
	MOV	E,M	;LSB
	INX	H
	MOV	D,M	;MSB
	XCHG
	LDA	FLAG
	ORA	A
	CNZ	HEXHL	;DISPLAY CRC WORD
	CALL	CRLF
WCRCN:	LHLD	BUFF	;BUFFER POINTER
	LXI	D,FLEN	;NEXT NAME OFFSET
	DAD	D
	SHLD	BUFF
	JMP	WCRCLP	;DISPLAY NEXT FILE
;
GETSAME:
	LXI	H,0	;RESET FLAGS
	SHLD	ACT$CRCK
	LDA	XFLAG
	ORA	A	;ACTIVE
	RZ		;NO
	XRA	A
	STA	FCBFINAL+12;EXTENT
	STA	FCBFINAL+15;RC
	STA	FCBFINAL+32;CR
	LXI	D,FCBFINAL
	MVI	C,OPEN
	CALL	BDOS	;OPEN FILE
	CPI	-1
	RZ		;DO NORMAL SORT
	MVI	A,-1	;SET CRCKLIST.CRC ACTIVE ON DISK
	STA	ACT$CRCK
	LHLD	BUFF	;GET BUFFER POINTER
	XCHG
	INX	D	;PUT NAME AT CORRECT OFFSET FROM START
	INX	D
READ$SAME:
	LXI	H,80H	;DMA OFFSET
	DAD	D
	PUSH	H	;SAVE NEXT POINTER
	MVI	C,STDMA
	CALL	BDOS
	LXI	D,FCBFINAL
	MVI	C,READ
	CALL	BDOS	;READ NEXT RECORD
	ORA	A	;END OF DATA
	POP	D	;NEXT DMA ADDRESS
	JZ	READ$SAME;CONTINUE LOOP
	MVI	B,16	;FILL NEXT NAME WORTH
	MVI	A,'Z'-40H
FILL$NEXT:
	STAX	D
	INX	D
	DCR	B
	JNZ	FILL$NEXT
	LHLD	BUFF	;START OF BUFFER
	MOV	D,H	;DE=HL
	MOV	E,L
	INX	D
	INX	D
NEXT$NAME:
	CALL	NSCAN	;GET TO START OF NAME
	JC	END$SAME;THATS ALL FOLKS
	PUSH	H	;SAVE FLAG POINTER
	PUSH	H	;SAVE POINTER
	LHLD	NAMCNT
	INX	H	;INCREMENT NAME COUNT
	SHLD	NAMCNT
	POP	H
	MVI	M,0	;ZERO OUT FLAGS & USER
	INX	H
	LDA	OLDUSR	;PRESET TO OLD USER
	MOV	M,A	;DEFAULT USER
	PUSH	H	;USER POINTER #
	INX	H
	MVI	B,8
	CALL	MOVE
	INX	D	;GET PAST DELIMETER
	MVI	B,3
	CALL	MOVE
	POP	B	;USER POINTER
	LDAX	D	;NEXT CHARACRE
	CPI	TAB	;CRCK GENERATED
	JZ	GET$CRC
	PUSH	H	;SAVE BUFFER POINTER
	LXI	H,USROF	;OFFSET TO USER #
	DAD	D
	XCHG
	CALL	DECIN	;GET USER
	POP	H	;DESTINATIN BACK
	STAX	B
	MVI	A,-1	;SET SAME.COM GENERATED FLAG
	STA	SFLAG	;SAME FLAG
GET$CRC:
	LDAX	D	;GET CHARACTER
	CPI	'Z'-40H	;END OF DATA
	JZ	NO$CRC
	CPI	CR	;END OF STRING
	JZ	NO$CRC
	INX	D	;POINT TO NEXT CHARACTER
	CPI	'='
	JNZ	GET$CRC	;NOT YET
	CALL	NSCAN	;GET TO CRC WORD
	JC	NO$CRC	;OOPS
	PUSH	H	;SAVE DESTINATION POINTER
	CALL	HEXIN	;GET CRC DATA
	LDAX	D
	INX	D	;POINT TO NEXT CHARACTER
	STA	CRCTYPE	;CRC TYPE
	CPI	' '
	CZ	IN1	;YES
	MOV	B,H	;BC=HL
	MOV	C,L
	POP	H	;DESTINATION POINTER
	MVI	A,0001$0000B;CRC ACTIVE FLAG
	JMP	SET$CRC
NO$CRC:	LXI	B,0	;ZERO OUT CRC
	MVI	A,0	;CRC INACTIVE FLAG
SET$CRC:
	MOV	M,C	;SET CRC
	INX	H
	MOV	M,B
	INX	H
	MVI	M,0
	INX	H
	POP	B	;GET CRC FLAG POINTER
	STAX	B
	JMP	NEXT$NAME
END$SAME:
	SHLD	NAMPTR	;END OF BUFFER
	LXI	D,80H	;SET DEFAULT DMA
	MVI	C,STDMA
	CALL	BDOS
	LHLD	NAMCNT	;NAMES IN BUFFER
	MOV	A,H
	ORA	L
	RZ		;NO NAMES IN BUFFER
	LDA	DTYPE	;DEFAULT
	ORA	A
	STC		;RETURN FLAG
	RZ
	LDA	SFLAG	;SAME GENERATED FLAG
	ORA	A
	RZ		;NOT SAME.COM GENERATED
	STC
	RET
;
NSCAN:	LDAX	D	;SCAN TO NEXT CHARACTER >= 30H
	CPI	'Z'-40H	;END OF STRING
	STC		;END OF DATA
	RZ		;END OF STRING
	CPI	'0'
	RNC
	INX	D
	JMP	NSCAN
;
DECIN:	PUSH	B	;SAVE POINTERS
	LXI	H,0
	CALL	DLOOP
	MOV	A,L	;SINGLE BYTE
	POP	B
	RET
;
DLOOP:	LDAX	D	;GET A ASCII DIGIT
	SUI	'0'	;CONVERT TO BCD AND TEST
	ANA	A	;RESET CARRY
	RM		;TERMINATE CONVERSION IF < ZERO
	CPI	10	;CHECK LEGITIMATE DIGIT (0-9)
	CMC		;COMPLEMENT CARRY
	RC		;RET WITH CARRY SET IF ERROR
	INX	D	;INCR ADDR POINTER
	DAD	H	;SHIFT LEFT 1
	PUSH	H	;SAVE RESULT
	DAD	H
	DAD	H	;SHIFT LEFT 2
	POP	B	;NO * 2 TO B
	DAD	B	;HL NOW CONTAINS 10*NO
	MOV	C,A	;ADD PRODUCT TO DIGIT
	MVI	B,0
	DAD	B
	JMP	DLOOP	;BACK FOR ANOTHER DIGIT
;
HEXIN:	LXI	H,0	;ZERO NUMBER
IN1:	LDAX	D	;GET A CHAR
	ORA	A	;CHECK FOR END OF BUFFER
	RZ
	SUI	'0'	;CHECK < 0 AND CONVERT TO HEX
	RC
	ADI	'0'-'G'	;CHECK > F
	RC
	ADI	6
	JP	IN2	;NO BETWEEN A AND F
	ADI	7
	RC
IN2:	ADI	10
	ORA	A	;CLEAR CARRY
	PUSH	B	;SAVE REG
	MOV	C,A	;HEX DIGIT TO C
	MVI	B,0	;ZERO TO B
	DAD	H
	DAD	H
	DAD	H
	DAD	H	;SHIFT LEFT 4
	DAD	B	;ADD IN NEW DIGIT
	POP	B
	INX	D	;INCR BUFFER POINTER
	JMP	IN1	;RETURN FOR MORE INPUT
;
HEXHL:	MOV	A,H
	PUSH	H
	CALL	HEXOUT
	POP	H
	MOV	A,L
HEXOUT:	PUSH	PSW
	RRC
	RRC
	RRC
	RRC		;SHIFT RIGHT 4
	CALL	NIBBLE
	POP	PSW
NIBBLE: ANI	0FH	;MASK 4 BITS
	ADI	90H	;ADD OFFSET
	DAA		;DEC ADJUST
	ACI	40H	;ADD OFFSET
	DAA		;DEC ADJUST
	JMP	OUTCHR
;
SUBDHC:	CALL	SUBDH	;SUBTRACT
	RZ		;NC ALRIGHT
	CMC		;SET UP FOR NC END OF COMPARE
	RET
;HL=HL-DE
SUBDH:	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	RC		;PAST END
	ORA	L	;TEST FOR 0
	RET
;
SETUSR:	MOV	E,A	;SET TO OLD
	MVI	C,32
	CALL	BDOS
	RET
;
SAMDSK:	LXI	D,SDSKM
	JMP	ERROR
BADFCB:	LXI	D,BFCBM	;BAD FCB ERROR
	JMP	ERROR
NSAME:	LXI	D,SAMEM
	JMP	ERROR
NOFILE:	LXI	D,NFILES
ERROR:	CALL	PRINT
RETURN:	LDA	OLDUSR
	CALL	SETUSR
	JMP	0
;
HELP:	MVI	A,0	;CHANGE DELIMETER CHARACTER
	STA	OUTSTL+2;SELF MODIFYING CODE TO DISPLAY DOLLAR SIGNS
	LXI	D,HELPM
	CALL	OUTSTL	;PRINT MESSAGE
	JMP	0	;THATS ALL FOLKS
;
OUTST:	XRA	A
	STA	HCOUNT
OUTSTL:	LDAX	D	;GET CHARACTER
	CPI	'$'
	RZ
	CALL	OUTCHR
	INX	D
	JMP	OUTSTL
;
PRINT:	PUSH	H	;SAVE REGS
	PUSH	D
	PUSH	B
	XRA	A
	STA	HCOUNT
	MVI	C,9
	CALL	BDOS
	POP	B
	POP	D
	POP	H
	RET
;
DECOUT:	PUSH	H	;SAVE REGS
	PUSH	D
	PUSH	B
	LXI	B,-10	;RADIX FOR CONVERSION
	LXI	D,-1	;THIS BECOMES NO DIVIDED BY RADIX
DX:	DAD	B	;SUBTRACT 10
	INX	D
	JC	DX
	LXI	B,10
	DAD	B	;ADD RADIX BACK IN ONCE
	XCHG
	MOV	A,H
	ORA	L	;TEST FOR ZERO
	CNZ	DECOUT	;RECURSIVE CALL
	MOV	A,E
	ADI	'0'	;CONVERT FROM BCD TO HEX
	CALL	OUTCHR
	POP	B	;RESTORE REGISTERS
	POP	D
	POP	H
	RET
;
MOVE:	LDAX	D	;FROM
	MOV	M,A	;TO
	INX	H
	INX	D
	DCR	B
	JNZ	MOVE
	RET
;
SIGNON:	DB	'Same vers 1.01$'
NFILES:	DB	CR,LF,'Directory empty$'
OOPSM:	DB	CR,LF,'File not found that was found last pass$'
SDSKM:	DB	CR,LF,'Same disk and user$'
WAIT:	DB	      'Insert disks to compare and hit any key$'
DONE:	DB	      'Search and Destroy complete$'
FWAIT:	DB	CR,LF,'Insert systemd disk then hit any key$'
BFCBM:	DB	CR,LF,'Bad filename in comand line$'
SAMEM:	DB	CR,LF,'Same file name in different user #$'
SORTING:DB	CR,LF,'Sorting Directory entries$'
ERAFILE: DB	CR,LF,'Erase file <Y,?> '
SAMEP:	DB	' FILENAME',' ','TYP',' $'
DELIM:	DB	'| $'
ERASED:	DB	'file erased$'
SDSAME:	DB	      'Source/Destination file''s same$'
SDNSAME:DB	CR,LF,'Source/Destination file name''s same, '
	DB	'file''s different$'
SNOTD:	DB	CR,LF,'Source name''s not found on destination disk$'
DNOTS:	DB	CR,LF,'Destination name''s not found on source disk$'
WAIT?:	DB	CR,LF,'Hit any key to display results$'
CLOSEM:	DB	CR,LF,'Erase error$'
SFMESG:	DB	CR,LF,'Source disk files',CR,LF,'$'
DFMESG:	DB	      'Destinaion disk files',CR,LF,'$'
;
dir$full:	db	cr,lf
	db	'++No Directory Space for CRC File++'
	db	'$'
;
dsk$full:	db	cr,lf
	db	'++No Disk Space for CRC File++'
	db	'$'
;
no$close:	db	cr,lf
	db	'++Cannot Close CRC File++'
	db	'$'
HELPM:	DB	'Commands:   same drive[user]:name.typ '
	DB	'drive[user]:name.type [$f,e,n,c,x,w,d]',CR,LF
	DB	'	commas are just used here for diferentiating instrusctions',CR,LF
	DB	CR,LF
	DB	'    Options	Descriptionns',CR,LF
	DB	'	$	start options',CR,LF
	DB	'	F	Write compare text to SAMELIST.PRN and crc data',CR,LF
	DB	'		to CRCKLIST.CRC on each disk and default user if',CR,LF
	DB	'		no user selected',CR,LF
	DB	'	E	Erase files that are equal',CR,LF
	DB	'	N	Don''t promt operator to erase file',CR,LF
	DB	'	C	Display CRCKLIST.CRC files on console',CR,LF
	DB	'	X	Use existing CRCKLIST.CRC files from selected',CR,LF
	DB	'		user or default user. Uses old crc generation if',CR,LF
	DB	'		old CRCKLIST.CRC encounteredss',CR,LF
Y	DB	'	W	Wait and promt operator for disk change',CR,LF
	DB	'	D	Default to F,E,N,X,W options',CR,LF
	DB	CR,LF
	DB	'Examples:',CR,LF
	DB	CR,LF
	DB	' same a: b: compare all file''s all user''s on a: to same on b:',CR,LF
	DB	' same a0: b0: compare all file''s user 0 on a: to same on b:',CR,LF
	DB	' same a:*.asm b:*.asm $fwn'
	DB	0
FILEN:	DB	'FILENAME.TYP'
USER:	DB	'    USER $'
USROF	EQU	$-USER
CRCM:	DB	9,' CRC = $'
;
ACT$CRCK DB	0	;CRCKLIST.CRC FILE ACTIVE
CRCTYPE	DB	0	;FLAG FOR CRC TYPE
;
BUFF:	DW	NAMBUF	;BUFFER POINTER
NAMPTR:	DW	NAMBUF	;BUFFER POINTER
NAMCNT:	DW	0	;NAME'S IN BUFFER
;
MFILES:	DB	0	;MULTIPLE FILES FLAG
OLDUSR:	DB	0	;OLD USER #
;
CMPFCB:	DW	0	;COMPARE FCB
SUSR:	DB	0	;SELECTED USER #
;
SDISK:	DB	0	;SOURCE DISK
SUSER:	DB	0	;SOURCE USER
S$ACT:	DB	0	;CRCKLIST.CRC ACTIVE
S$TYPE:	DB	0	;CRCK TYPE
SBUFF:	DW	NAMBUF	;NAME BUFFER
SSBUFF:	DW	NAMBUF	;SEARCH NAME BUFFER
SSFCB:	DW	NAMBUF	;SOURCE FILE NAME POINTER
;
DDISK:	DB	0	;DESINATION DISK
DUSER:	DB	0	;DESINTION USER
D$ACT:	DB	0	;CRCKLIST.CRC ACTIVE FLAG
D$TYPE:	DB	0	;CRCK TYPE
DBUFF:	DW	NAMBUF	;NAME BUFFER
SDBUFF:	DW	NAMBUF	;SEARCH NAME BUFFER
SDFCB:	DW	NAMBUF	;DESTINATION FILE NAME POINTER
EDBUFF:	DW	NAMBUF	;END NAME BUFFER
;
FLAG:	DB	0	;DISPLAY COMPARE FLAG
HCOUNT:	DB	0
CPASS:	DB	0	;COMPARE PASS
CRCFCB:	DW	0	;CRC GENERATION NAME POINTER
;
; program storage area
; 
active:	db	0	; fcb active
dflag:	db	0	; default option
sflag:	db	0	; same.com generted crcklist.crc flag
cflag:	db	-1	; display file flag
ocflag:	db	0	; option selected display file flag
wflag:	db	0	; wait for operator to change disk's flag
fflag:	db	0	; file write request flag
eflag:	db	0	; erase equal files flag
nflag:	db	0	; don't promt erase file
xflag:	db	0	; use crcklist.crc for files
rem:	dw	0	; crc remainder storage
bufad:	ds	2	; read buffer address
;
hitab:	ds	512	; the 2 tables for crc lookup
;
sfilelen:
;
	dw	sfilesiz
;
sfileptr:
;
	ds	2
;
SAMB:	DB	'SAMELISTPRN'
CRCK:	DB	'CRCKLISTCRC'
; 
; build fcb for final name of crcklist.crc
;
fcbfinal:
;
	db	0,'CRCKLISTCRC'
	db	0
	ds	20
;
; 'declare' fcb for output file (temporarily named crcklist.$$$)
;
samfcb:
;
	db	0,'????????$$$'
	db	0
	ds	20
;
sfileadr:
;
	dw	sfilebuff	; buffer all crc file data here
;
SFCB:	DB	0,'????????','???',0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0
;
DFCB:	DB	0,'????????','???',0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0
;
UFCB:	DB	'?','????????','???',0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0
;
LFCB:	DB	0,'????????','???',0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0
;
	DS	40
STACK:
sfilebuff:
	ds	sfilesiz
	DS	16-($ AND 0FH)
NAMBUF:
	END
