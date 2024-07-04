;
;
;	*****************
;	*		*
;	*  SECTION.ASM	*
;	*     v1.1	*
;	*		*
;	*****************
;
; 06/27/82 by Ron Fowler, Westland, Michigan
;
; 08/09/83 adapt for CP/M+ by Dick Lieber, Chicago Illinois  312-326-4392
;
; 04/20/84 adapted for CP/M+ with user numbers over 9
;          by James M. Scardelis, Director CP/M Plus Users' Group
;	   P.O. Box 295, Little Falls, NJ 07424-0295
; 
; This program is intended for RCPM systems where
; files are grouped into drive/user area by their
; classification.  This program implements a naming
; convention, whereby a caller can move into a
; section by typing its name, rather than the random
; searching formerly needed.
;
; Syntax is:  SECTION [<section-name>]
;
; If section-name is omitted, a short list of
; available sections is printed. The special
; form "SECTION ?" prints the detailed description
; of each section.
;
; You have to fill in the sections table
; (located near the end of this program) for your
; particular system.
;
;----< Examples of use: >-----
;
; A0>SECTION ATARI	;changes drive/user to atari area
; B4>SECTION MBASIC	;changes drive/user to mbasic area
; A6>SECTION		;prints short list of sections
; A9>SECTION ?		;prints the detailed list
;
false	equ	0	;define truth and falsehood
true	equ	not false
;
; the following equates may be
; customized to your preference
;
autodir equ	1		;run directory command when new drive
				;/user is selected.  Only works with
				;cp/m+ but will be ignored in 2.2
descol	equ	15		;column # where description begins
				;(in detailed list) (should be greater
				;than longest section name) (but small
				;enuf so display is not too long)
perlin	equ	4		;names printed per line in short list
tabpos	equ	8		;tab stops (set mod tabpos)
				;should be at least one greater than
				;longest section name.
turbo	equ	false		;set TRUE if you'er running TurboDOS
;
; o/s conventions
;
cpbase	equ	0		;set to 4200H for Heath
ccpdrv	equ	cpbase+4	;ccp user/drive storage loc
bdos	equ	cpbase+5	;system entry point
dfcb	equ	cpbase+5CH	;default file control block
dbuf	equ	cpbase+80H	;default buffer
tpa	equ	cpbase+100H	;base of transient program area
coninf	equ	1		;system call, get console char
conotf	equ	2		;system call, console output
printf	equ	9		;system call, print cons string
cstsf	equ	11		;system call, get console status
version	equ	12		;system call, return version
setdrv	equ	14		;system call, set/drive system call
getdrv	equ	25		;system call, get drive # system call
gsuser	equ	32		;system call, get/set user number
chain	equ	47		;system call, chain to ccp command (cpm+ only)
;
; character definitions
;
cr	equ	13		;carriage-return code
lf	equ	10		;linefeed code
;
; code begins....
;
	org	tpa
;
;
pbase:	lxi	h,0		;save system stack
	dad	sp
	shld	spsave
	lxi	sp,stack	;load local stack
;
	if	not turbo	;cp/m, get drive #
	mvi	c,getdrv	;get current drive #
	call	bdos
	push	psw		;save it
	sta	newdrv		;two ways
	endif
;
	call	sect		;perform the section function
;
	if	not turbo	;turbodos doesn't need this stuff
	lda	newdrv		;get newly logged drive
	mov	b,a		;save for comparison
	pop	psw		;get old logged drive
	cmp	b		;did logged drive change?
	jnz	cpbase		;then relog with warm boot
	endif
;
	lhld	spsave		;else restore stack
	sphl
	ret			;to system...
;
; scan cmd line...if an arg exists, attempt to
; match it in the table.  If no arg, dump a list
; of available sections.
;
sect:	lda	dfcb+1		;is there a cmd-line arg?
	cpi	' '
	jz	prnqk		;then go print sections out
	cpi	'?'		;wants detailed list?
	jz	prntbl		;then go do it
	lxi	h,dbuf		;something there, scan to it
scanbk: inx	h		;  ignoring blanks
	mov	a,m
	cpi	' '
	jz	scanbk
	lxi	d,table 	;point de to the section table
loop:	push	h		;save cmd line arg pointer
eloop:	ldax	d		;test entry against table
	cpi	1		;end of entry marker?
	jnz	noend		;jump if not
	mov	a,m		;yes, did user cmd terminate also?
	ora	a
	jz	match		;then declare a match
	jmp	nomat		;else declare a mismatch
noend:	cmp	m
	jnz	nomat		;skip if no match
	inx	h		;continue with comparison
	inx	d
	jmp	eloop
;
; here when an entry didn't match
;
nomat:	ldax	d
	ora	a		;entry terminator?
	inx	d
	jnz	nomat		;scan through it
	pop	h		;restore cmd line arg pntr
	inx	d		;end of entry, skip over user #
	inx	d		;and drive
	ldax	d		;end of table?
	ora	a		;(terminated by 0)
	jnz	loop		;go scan another if not
;
; here when no match can be found
;
	lxi	d,matmsg	;print out no-match message
	mvi	c,printf
	call	bdos
	jmp	prnqk		;go give short list
;
; here when a match is found
;
match:	xchg			;hl==> user #
scmat:	inx	h		;scan past description
	mov	a,m		;looking for terminating null
	ora	a
	jnz	scmat
	inx	h		;skip over terminator
	mov	a,m		;fetch user #
	sui	'0'		;subtract ascii bias
	cpi	10		;is it > 9?
	jc	scmat2		;no, so continue on
	sui	7		;remove the rest 
scmat2:	mov	e,a
	inx	h		;point hl to drive #
	push	d		;save user #
	push	h		;and pointer
	mvi	c,gsuser	;set user number
	call	bdos
	pop	h		;restore pointer to drive
	mov	a,m		;fetch drive
	sui	'A'		;subtract ascii bias
	sta	newdrv		;set new logged drive
	pop	d		;restore user number in e
	mov	d,a		;save drive #
	mov	a,e		;fetch user number
	rlc			;rotate to high nybble
	rlc
	rlc
	rlc
	ora	d		;"or" in the drive
	sta	ccpdrv		;save for ccp use
;
;	if	turbo		;if turbodos...
	push	h
	mvi	c,setdrv	;...have to set drive explicitly
	mov	e,d		;get drive in e
	call	bdos		;set the drive
	pop	h
;	endif
;
	pop	d		;clear garbage from stack
;
;	cpm+ stuff  -- setting user/drive at 4 is an undocumented
;		       feature of cp/m 2.2, it has no effect on version 3
;
	push	h
	mvi	c,version
	call	bdos
	mvi	a,30h		;version that supports chain
	cmp	l
	pop	d
	rnc			;all done if not cp/m+
;
;	move user/drive from table to default buffer
; 
	lxi	h,80h
	ldax	d	;get drive
	mov	m,a

	inx	h
	dcx	d
	ldax	d	;get user
	cpi	'A'     ; is it a letter?
	jc	fin
	inx	h	; yes, so move to second position in d/u spec.
	sui	17	; subtract bias
	mov	m,a	; save it
	dcx	h	; go back to first position.
	mvi	a,'1'	; first digit is always a one now.
	mov 	m,a	; put it there
	inx	h	; and set H for next routine
	jmp	fin2	;and do it.

fin:	mov	m,a

fin2:	inx	h
	mvi	m,':'	;to indicate user/drive request
	if	autodir
	inx	h
	mvi	m,'!'	;command seperator
	inx	h
	mvi	m,'D'
	inx	h
	mvi	m,'I'
	inx	h
	mvi	m,'R'
	endif
	inx	h
	mvi	m,0	;mark end of command buffer

	mvi	c,chain
	mvi	e,0		;flag to make current drive/user ccp default
	call	bdos
	

;
; message printed when match failed
;
matmsg: db	cr,lf,'++ Entry not found ++'
	db	cr,lf,cr,lf,'$'
matms2: db	cr,lf,'Type "SECTION ?" for detailed list'
	db	cr,lf,'      of available sections.',cr,lf
	db	cr,lf,'Type "SECTION <section-name>" to log'
	db	cr,lf,'      into a particular section.'
	db	cr,lf,'$'
;
; print "quick list"
;
prnqk:	lxi	d,tblmsg
	mvi	c,printf
	call	bdos
	lxi	h,table 	;print abbreviated list
qloop:	mvi	b,perlin	;get names-per-line counter
qloop2: mov	a,m		;end of table?
	ora	a
	jz	qkend		;then go print end msg
	call	prathl		;else print the name
qscan:	mov	a,m		;scan to description terminator
	inx	h		;(this effectively ignores
	ora	a		; the description)
	jnz	qscan
	inx	h		;skip over user #
	inx	h		;and drive #
	dcr	b		;count down line entry counter
	jnz	qtab		;go tab if line not full
	call	crlf		;else turn up new line
	jmp	qloop		;and continue
;
; tab between entry names
;
qtab:	mvi	a,' '		;seperate names with tabs
	call	type
	lda	column		;get column #
qsub:	sui	tabpos		;test tab position
	jz	qloop2		;continue if at a tab position
	jnc	qsub		;convert mod tabpos
	jmp	qtab		;keep tabbing
;
qkend:	call	crlf		;do newline
	lxi	d,matms2	;print ending message
	mvi	c,printf
	call	bdos
	call	crlf
	ret
;
; here to print out a list of available section numbers
;
prntbl: lxi	d,tblmsg	;print heading message
	mvi	c,printf
	call	bdos
	call	crlf		;turn up new line
	lxi	h,table
prloop: mov	a,m		;end-of-table?
	ora	a
	rz			;then all done
	call	prathl		;print the name
tab:	mvi	a,'.'		;tab over with leader
	call	type
	lda	column		;get column
	cpi	descol		;at description column yet?
	jc	tab		;then keep tabbing
	call	prathl		;print description
	inx	h		;skip over user #
	inx	h		;and drive number
	call	crlf		;turn up new line
	jmp	prloop		;and continue
;
; print message @hl until null or 01 binary
;
prathl: mov	a,m		;fetch char
	inx	h		;point past it
	ora	a		;null?
	rz			;then done
	cpi	1		;1 also terminates
	rz
	call	type		;nope, print it
	call	break		;check for console abort
	jmp	prathl
;
; test for request from console to stop (^C)
;
break:	push	h		;save 'em all
	push	d
	push	b
	mvi	c,cstsf 	;get console sts request
	call	bdos
	ora	a		;anything waiting?
	jz	brback		;exit if not
	mvi	c,coninf	;there, is, get it
	call	bdos
	cpi	'S'-64		;got pause request?
	mvi	c,coninf
	cz	bdos		;then wait for another character
	cpi	'C'-64		;got abort request?
	jz	quit		;then go abort
brback: pop	b		;else restore and return
	pop	d
	pop	h
	ret
;
; request from console to abort
;
quit:	lxi	d,qmesg 	;tell of quit
	mvi	c,printf
	call	bdos
	lhld	spsave		;get stack pointer
	sphl
	ret
;
qmesg:	db	cr,lf,'++ Aborted ++',cr,lf,'$'
;
; turn up a new line on display
;
crlf:	mvi	a,cr		;print a return
	call	type
	mvi	a,lf		;get lf, fall into type
;
; Routine to print char in A on console,
; while maintaining column number. 
;
type:	push	h		;save everybody
	push	d
	push	b
	mov	e,a		;align char for printing
	push	psw		;save char
	mvi	c,conotf
	call	bdos		;print it
	pop	psw		;restore char
	lxi	h,column	;bump column counter
	cpi	lf		;linefeed doesn't chang column
	jz	nochg
	inr	m
	cpi	cr		;carriage-return zeroes it
	jnz	nochg		;skip if not cr
	mvi	m,0		;is, zero column
nochg:	pop	b		;restore & return
	pop	d
	pop	h
	ret
;
; dump heading message
;
tblmsg: db	cr,lf,'Available sections are:',cr,lf,'$'

;
;
; variables
;
spsave: dw	0		;stack-pointer save
column: db	0		;current column #
newdrv: db	0		;new drive # to log
	ds	20		;the stack
;
stack	equ	$		;define it
;
;
;
;
; SECTIONS TABLE (located at end for easy patching with DDT)
;
; This is the table that defines the sections.	Entry format is:
;
;	<name>,sep,<description>,null,user,drive
;
; where <name>	       is the section name
;	sep	       is a binary 1 used to terminate the match test
;	<description>  is a one-line-or-less comment printed when
;		       the list is dumped.  Match testing terminates
;		       before this field.
;	null	       is a binary 0 used to terminate the description
;	user	       is the user number (0-15) of the section (ascii)
;	drive	       is the drive (A-P) number of the section (ascii)
;
; the table ends with a <name> of zero (binary).
;
; Note: be sure to make section names ALL-CAPS, because the
;	CCP converts command-line arguments to capitals. The
;	description may be in lower case, since it has nothing
;	to do with the matching process.
; Also: although the drive and user # is in ascii (for convenience
;	in setting up the table), be sure to use caps for the
;	drive designation.  No error checking is done on the values.
;
table:	DB	'ARCHIVE',1,'Archives - .LBR files',0,'1A'
	db	'ASSEM',1,'Assembly Language Sources',0,'3B'
	db	'BASIC',1,'BASIC Language Sources',0,'5B'
	db	'BIOS',1,'This system''s BIOS',0,'FB'
	db	'C',1,'C Language Sources',0,'9B'
	db	'CPPLUG',1,'CP/M Plus User''s Group Library - .LBR Files',0,'7B'
	db	'DBASE',1,'dBase II Sources and Database',0,'6B'
	db	'DOCS',1,'Documentation - .LBR Files',0,'8B'
	db	'GAMES',1,'Games - .LBR Files',0,'4B'
	db	'HDUTIL',1,'Hard Disk Utilities',0,'FA'
	db	'OTHER',1,'Whatever fails classification',0,'BB'
	db	'PASCAL',1,'PASCAL Language Sources',0,'2B'
	db	'PL/I',1,'PL/I Language Sources',0,'1B'
	db	'SYSTEMA',1,'System Files - No Access',0,'0A'
	db	'SYSTEMB',1,'System Files - No Access',0,'0B'
	db	'UPLOADS',1,'Recently Uploaded Software',0,'AB'
	db	0		;<<== end of table
;
; -----< end of SECTIONS table>-----
;
	end	pbase		;that's all.
