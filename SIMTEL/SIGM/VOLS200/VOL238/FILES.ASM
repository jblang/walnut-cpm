title 'FILES.ASM'
;************************************************
;*						*
;*		FILES.ASM			*
;*						*
;*  CP/M (r) disk file interface module for 	*
;*  X.25 protocol packet interface 		*
;*  (uses CP/M seqio serial I/O macro library)	*
;*						*
;*  rev 0.14	07/18/84	E. Elizondo	*
;*						*
;*  (c) 1984 E. Elizondo - all rights reserved. *
;*						*
;*    This program may be used freely for non-  *
;*  commercial applications. It may not be sold *
;*  or used for commercial applications without *
;*  written permission of the author.           *
;* 						*
;************************************************
;	
	
	maclib	seqio		;DR sequential I/O library
	maclib	Z80		;DR Z80 macro library

false	equ	0
true	equ	not false

;	CP/M system equates

fname1:	equ	005ch		;ccp default file name #1
fname2:	equ	006ch		;ccp default file name #2

;	hooks for other programs

;	subroutines
	public	otxfil		;open transmit file
	public	orxfil		;open receive file
	public	olgfil		;open log file
	public	gfdata		;get a byte from transmit file
	public	pfdata		;put a byte to receive file
	public	logdat		;put a byte to log file
	public	crxfil		;close rx file
	public	ctxfil		;close tx file
	public	clgfil		;close log file
	public	iparms		;initialize system parameters
	public	wparms		;write system parameters on disk

;	addresses
	public	fstat		;file status flags

;	definition of fstat status bits
;	bit	set condition
;	0	receive file open
;	1	transmit file open
;	2	undefined
;	3	undefined
;	4	undefined
;	5	undefined
;	6	undefined
;	7	log file open

;	layout of default parameters in file X25.PAR:
;	byte	name	description
;	1	dtemod	dte/dce mode flag
;	2	baudop	baud rate option
;	3	pvcmod	pvc/vc mode flag
;	4	laddrl	local DTE address length
;	5	raddrl	remote DTE address length
;	6-20	laddr	local DTE address
;	21-35	raddr	remote DTE address


;	external subroutines
	extrn	ilprt		;in line print routine
	extrn	move		;move block of data
	extrn	instr		;input string from console
	
;	external addresses

;	buffers 
	extrn	inbuf		;console string input buffer

;	level 1 parameters
	extrn	baudop		;default baud rate option

;	level 2 parameters
	extrn	dtemod		;dte/dce mode flag
	extrn	lkstat		;level 2 status flags

;	level 3 parameters
	extrn	pvcmod		;pvc/vc mode flag
	extrn	laddrl		;local DTE address length
	extrn	raddrl		;remote DTE address length
	extrn	laddr		;local DTE address
	extrn	raddr		;remote DTE address
	extrn	chstat		;level 3 channel status flags
	extrn	l3stat		;level 3 flow status


;	*****************
;	*  subroutines	*
;	*****************

	cseg			;code section


;	initialize system parameters
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags clobbered

iparms:
;	check if parameter file exists
	file	setfile,pcheck,,X25,PAR,,parbuf
;
	direct	pcheck	;is file there?
	rz		;no, return
;
;	open file for access
	file	infile,oldpar,,X25,PAR,128,parbuf
;
;	update system parameters
	get	oldpar		;get 1st parameter
	sta	dtemod		;update default DTE/DCE mode flag
	get	oldpar		;get 2nd parameter
	sta	baudop		;update default baud rate option
	get	oldpar		;get 3rd parameter
	sta	pvcmod		;update default PVC/VC mode flag
	get	oldpar		;get 4th parameter
	sta	laddrl		;update default local DTE address length
	get	oldpar		;get 5th parameter
	sta	raddrl		;update default remote DTE address length
;
;	update local DTE address
	mvi	b,16		;max address length+1 (in hex chars)
	lxi	h,laddr		;point to local DTE address
iparm1:	dcr	b		;last char?
	jz	iparm2		;yes, exit loop
;
	push	b		;save <bc>
	push	h		;save <hl>
	get	oldpar		;get address char
	pop	h		;restore <hl>
	pop	b		;restore <bc>
	mov	m,a		;update address char
	inx	h		;bump pointer
	jmp	iparm1		;and go for more
;
;	update remote DTE address
iparm2:	mvi	b,16		;max address length+1 (in hex chars)
	lxi	h,raddr		;point to local DTE address
iparm3:	dcr	b		;last char?
	jz	iparm4		;yes, exit loop
;
	push	b		;save <bc>
	push	h		;save <hl>
	get	oldpar		;get address char
	pop	h		;restore <hl>
	pop	b		;restore <bc>
	mov	m,a		;update address char
	inx	h		;bump pointer
	jmp	iparm3		;and go for more
;
iparm4:	finis	oldpar		;close file
	ret



;	write system parameters to disk
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags clobbered

wparms:	
;	open file for access
	file	outfile,newpar,,X25,PAR,128,parbuf
;
;	update file with current system parameters
	lda	dtemod		;get new DTE/DCE mode flag
	put	newpar		;update 1st parameter
	lda	baudop		;get new baud rate option
	put	newpar		;update 2nd parameter
	lda	pvcmod		;get pvc/vc mode flag
	put	newpar		;update 3rd parameter
	lda	laddrl		;get local DTe address length
	put	newpar		;update 4th parameter
	lda	raddrl		;get remote DTE address length
	put	newpar		;update 5th parameter
;
;	update local DTE address in file
	mvi	b,16		;max address length+1 (in hex chars)
	lxi	h,laddr		;point to local DTE address
wparm1:	dcr	b		;last char?
	jz	wparm2		;yes, exit loop
;
	push	b		;save <bc>
	push	h		;save <hl>
	mov	a,m		;get address char
	put	newpar		;update char in file
	pop	h		;restore <hl>
	pop	b		;restore <bc>
	inx	h		;bump pointer
	jmp	wparm1		;and go for more
;
;	update remote DTE address in file
wparm2:	mvi	b,16		;max address length+1 (in hex chars)
	lxi	h,raddr		;point to local DTE address
wparm3:	dcr	b		;last char?
	jz	wparm4		;yes, exit loop
;
	push	b		;save <bc>
	push	h		;save <hl>
	mov	a,m		;get address char
	put	newpar		;update char in file
	pop	h		;restore <hl>
	pop	b		;restore <bc>
	inx	h		;bump pointer
	jmp	wparm3		;and go for more
;
wparm4:	finis	newpar		;close file
	ret


;	open transmit file for access:
;	(externally called)
;	on entry:	no parameters
;	on exit:	all regs, flags clobbered

otxfil:
	lxi	h,fstat		;point to status flags
	bit	1,m		;transmit file open?
	jz	otxf1		;no, keep going
;
	call	ilprt		;else tell operator
	db	'L4: transmit file is already open',cr,lf,0
	ret			;and return with no action
;
otxf1:	call	ilprt
	db	'transmit file name: ',0
	call	gfn		;get file name
	rc			;abort function if no input
;
	lxi	h,tfname	;now move parsed name to default..
	lxi	d,fname1	;fcb at first name location
	lxi	b,12		;      /
	call	move		;     /
;
;	set up file to check directory
	file	setfile,txcheck,,1,,
;
	direct	txcheck		;see if file is there
;
	jnz	otxf2		;jump if we found it
	call	ilprt
	db	'L4: file not found',cr,lf,0
	ret
;
;	open file for read
otxf2:	file	infile,source,,1,,1024,txfbuf
	lxi	h,fstat		;point to file status flags
	setb	1,m		;set file open flag
	lxi	h,chstat	;point to level 3 channel status
	bit	0,m		;flow control ready state?
	jz	otxf3		;no, keep going
;
	lxi	h,l3stat	;point to level 3 status
	setb	7,m		;signal message waiting
	call	ilprt		;yes, signal transmission start
	db	'L4: file transmission in process',cr,lf,0
	ret
;
otxf3:	call	ilprt
	db	'L4: ready to transmit file',cr,lf,0
	ret


;	get a byte from transmit file
;	(externally called)
;	on entry:	no parameters
;	on exit:	<a>= byte if available
;			zero flag set if end of file
;			all other regs unchanged

gfdata:	di			;disable interrupts
	push	h		;save regs
	push	d		;	/
	push	b		;      /
	get	source		;get byte from file
	pop	b		;restore regs
	pop	d		;	/
	pop	h		;      /
	ei			;enable interrupts
	ret			;and return

;
;	close transmit file
;	(externally and internally called)
;	on entry:	no parameters
;	on exit:	<a>, flags clobbered
;			all other regs unchanged

ctxfil:
	push	h		;save regs
	push	d		;	/
	push	b		;      /
	lxi	h,fstat		;reset tx file open flag
	bit	1,m		;transmit file open?
	jz	ctx1		;no, exit
;
	res	1,m		;else reset flag
	finis	source		;close file
	call	ilprt		;and tell operator
	db	'L4: transmit file closed',cr,lf,0
ctx1:	pop	b		;restore regs
	pop	d		;	/
	pop	h		;      /
	ret



;	open receive file for access
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, regs clobbered

orxfil:
	lxi	h,fstat		;point to status flags
	bit	0,m		;receive file open?
	jz	orxf1		;no, keep going
;
	call	ilprt		;else tell operator
	db	'L4: receive file is already open',cr,lf,0
	ret			;and return with no action
;
orxf1:	call	ilprt
	db	'receive file name: ',0
	call	gfn		;get file name into tfname
	rc			;abort function if no input
;
;
	lxi	h,tfname	;now move parsed name to default..
	lxi	d,fname2	;fcb at second name location
	lxi	b,12		;      /
	call	move		;     /
;

;	set up file to check directory
	file	setfile,rxcheck,,2,,
;
	direct	rxcheck		;see if file is there
;
	jz	orxf2		;jump if new file
;
;	file exists by same name
	call	ilprt
	db	'file already exists, delete it (y/n)? ',cr,lf,0
	get	key		;get reply
	cpi	'y'		;is it yes?
	jz	orxf2		;yes, keep going
;
	cpi	'Y'		;upper case also
	jz	orxf2		;	/
;
	call	ilprt		;else terminate line
	db	cr,lf,0		;	/
	ret			;and return
;
;	open file for read
orxf2:	call	ilprt		;terminate line
	db	cr,lf,0
	file	outfile,dest,,2,,1024,rxfbuf
;
	call	ilprt
	db	'L4: receive file open - awaiting data',cr,lf,0
	lxi	h,fstat		;point to file status flags
	setb	0,m		;set rx file open flag
	ret



;	write a byte to receive file
;	(externally called)
;	on entry:	<a>= byte to be written
;	on exit:	all regs unchanged

pfdata:	push	h		;save regs
	push	d		;	/
	push	b		;      /
	put	dest		;write byte to file
	pop	b		;restore regs
	pop	d		;	/
	pop	h		;      /
	ret			



;	close receive file
;	(externally called)
;	on entry:	no parameters
;	on exit:	<a>,flags clobbered
;			all other regs unchanged

crxfil:
	push	h		;save regs
	push	d		;	/
	push	b		;      /
	lxi	h,fstat		;point to file status flags
	bit	0,m		;receive file open?
	jz	crx1		;no, exit
;
	res	0,m		;else clear rx file open flag
	finis	dest		;close file
 	call	ilprt		;and tell operator
	db	'L4: receive file closed',cr,lf,0
crx1:	pop	b		;restore regs
	pop	d		;	/
	pop	h		;      /
	ret



;	get and parse file name into temp file name buffer
;	(internally called)
;	on entry:	no parameters
;	on exit:	carry set if file name error
;			parsed file name in tfname buffer
;			(so it can be copied to fcb)
;			all other flags, regs clobbered

gfn:
	call	instr		;read console string
	call	ilprt		;output a line feed
	db	lf,0		;	/
	lda	inbuf+1		;<a>=input string size
	mov	b,a		;save it in <b> also
	ora	a		;no input?
	stc			;set carry for abort
	rz			;and return
;
	lxi	h,tfname	;<hl>=A(tfname)
	xra	a		;clear drive specifier
	mov	m,a		;	/
	inx	h		;now clear file name & type
	mvi	a,' '		;to spaces
	mvi	c,11		;all 11 bytes
gfn0:	mov	m,a		;clear a byte
	inx	h		;bump pointers
	dcr	c		;	/
	jnz	gfn0		;until end of file type
;
;	get drive specifier, if any
	lxi	d,tfname	;<de>=A(tfname)
	lxi	h,inbuf+2	;<hl>=A(input string)
	call	getchr		;get first non-space character
	jz	gfnerr		;error if none available
;
	inx	h		;point to second byte
	mov	a,m		;get second byte
	dcx	h		;point back to first byte
	cpi	':'		;drive separator?
	jnz	gfn2		;no, process normally
;
;	transfer drive code to tfname
	mov	a,m		;get drive code
	inx	h		;and move past it
	inx	h
	dcr	b		;and bump pointer
	dcr	b
	call	valchr		;valid ASCII?
	jc	gfnerr		;exit with error if not
	sui	40h		;else remove ASCII bias
	stax	d		;and store at tfname+0
;
;	transfer file name to tfname
gfn2:	inx	d		;skip over drive code field
	mvi	c,8		;max file name length
	call	getchr		;get a real char
	jz	gfnerr		;error if no character available
;
gfn3:	call	getchr		;get char
	rz			;exit if end of input
	cpi	'.'		;file type delimiter
	jz	gfn4		;yes, go process it
	call	valchr		;valid ASCII?
	jc	gfnerr		;no, signal error
	stax	d		;else store in tfname
	inx	h		;bump pointers
	inx	d		;	/
	dcr	b		;	/
	rz			;exit if end of input
	dcr	c		;loop until end of name
	jnz	gfn3		;	/
;
	call	getchr		;get next char
	rz			;done if out of input
	cpi	'.'		;file type delimiter?
	jnz	gfnerr		;no, name is too long
;
gfn4:	inx	h		;skip over '.'
	dcr	b		;	/
	rz			;exit if done
	lxi	d,tfname+9	;<de>=A(file type)
	mvi	c,3		;max length of file type
gfn5:	call	getchr		;get char
	rz			;exit if done
	call	valchr		;valid ASCII?
	jc	gfnerr		;no, exit with error
	stax	d		;else store in tfname
	inx	h		;bump pointers
	inx	d		;	/
	dcr	b		;	/
	rz			;return if out of input
	dcr	c		;loop until end of file type
	jnz	gfn5		;or drop thru if file type too long
;
gfnerr:	call	ilprt
	db	'L4: file name error',cr,lf,0
	stc			;set carry for abort
	ret

;	get char from input buffer, deleting spaces
;	(internally called)
;	on entry: <hl>= current pointer location
; 		  <c> = remaining character count
;	on exit:  <a> = character
;		  zero set if last character
;
getchr:	mov	a,m		;get char
	cpi	' '		;space?
	rnz			;no, return with char in hand
	inx	h		;else bump pointers
	dcr	b		;	/
	rz			;return with zero if last char
	jmp	getchr		;or loop till out of spaces


;	check for valid file name character
;	(internally called)
;	on entry: <a>= character (converted to upper case)
;	on exit:  carry set if error

valchr:	cpi	'0'		;control or punctuation?
	rc			;yes, return with error
	cpi	61h		;lower case?
	jc	valch1		;no don't process it
	sui	20h		;make it upper case
;
valch1:	cpi	'Z'+1		;punctuation?
	cmc			;yes, return with error
	rc			;	/
	cpi	'A'		;possible special character?
	rnc			;no, char is ok
	cpi	'9'+1		;special character?
	cmc			;yes, set carry for error
	ret			;and return in any case


;	open log file
;	(externally called)
;	on entry:	no paramters
;	on exit:	all regs, flags clobbered

olgfil:	file	outfile,lgfil,,X25,LOG,1024,logbuf
	lxi	h,fstat		;point to file status flags
	setb	7,m		;signal log file open
	call	ilprt		;and tell operator
	db	'L4: frame logging enabled',cr,lf,0
	ret


;	write byte to log file
;	(externally called)
;	on entry:	<a>=byte
;	on exit:	all regs unchanged

logdat:	push	h		;save regs
	push	d		;	/
	push	b		;      /
	put	lgfil		;write byte to file
	pop	b		;restore regs
	pop	d		;	/
	pop	h		;      /
	ret


;	close log file
;	(externally called)
;	on entry:	no parameters
;	on exit:	all flags, regs clobberd


clgfil:	lxi	h,fstat		;point to file status flags
	bit	7,m		;log file open?
	rz			;no, exit
;
	res	7,m		;else signal log file closed
	finis	lgfil		;close file
	call	ilprt		;and tell operator
	db	'L4: frame logging disabled',cr,lf,0
	ret



;	*****************
;	* data area	*
;	*****************

;	leave in cseg

;	status flags
fstat:	dw	0	;file status flags

;	disk data buffers
tfname:	ds	12	;temp buffer for file name
parbuf:	ds	128	;disk buffer for parameters
rxfbuf:	ds	1024	;rx disk file buffer area
txfbuf:	ds	1024	;tx disk file buffer area
logbuf:	ds	1024	;log disk file buffer area
