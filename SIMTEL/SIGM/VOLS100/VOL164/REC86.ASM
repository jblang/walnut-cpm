

;	*******************************************************
;	*  REC module containing the REC nucleus and some of  *
;	*  the really indispensable operators and predicates  *
;	*  such as those defining two byte binary numbers and *
;	*  ASCII constant strings.  The model of a pushdown   *
;	*  list is assumed in the expectation that additional *
;	*  operators and predicates will also follow reversed *
;	*  Polish notation. There are additionally many small *
;	*  service routines which may be used externally.     *
;	*						      *
;	*  The source language for these programs is the one  *
;	*  introduced by SORCIM for ACT86.COM, which is not   *
;	*  quite the same that Intel's ASM86 uses.	      *
;	*						      *
;	*  REC86 was obtained from the previously existing    *
;	*  REC80 by applying SORCIM's TRANS86 translator and  *
;	*  then adjusting the resulting code manually. It is  *
;	*  intended that REC86 will be functionally identical *
;	*  to REC80. All error corrections, additions, or     *
;	*  alterations are made simultaneously to the two     *
;	*  programs, when they are not purely cosmetic.	      *
;	*  Braces, creating a different style of subroutine   *
;	*  definition, were incorporated in REC at the time   *
;	*  the translation to the Intel 8086 was made.	      *
;	*						      *
;	*  REC86 contains the following compiling entries:    *
;	*						      *
;	*	reclp	left parenthesis		      *
;	*	recco	colon				      *
;	*	recsc	semicolon			      *
;	*	recrp	right parenthesis		      *
;	*	recop	operator			      *
;	*	recpr	predicate			      *
;	*	recsq	single quotes			      *
;	*	recdq	double quotes			      *
;	*	reccm	comments			      *
;	*	reco1	operator with one ASCII parameter     *
;	*	recp1	predicate with one ASCII parameter    *
;	*	recms	unary minus sign		      *
;	*	recdd	decimal digit			      *
;	*						      *
;	*  REC86 contains the following operators and         *
;	*  predicates:					      *
;	*						      *
;	*	'	single quote			      *
;	*	"	double quote			      *
;	*	nu	two byte decimal number		      *
;	*	O	decimal ASCII string to number	      *
;	*	#	number to decimal ASCII string	      *
;	*	L	erase argument (lift)		      *
;	*	@	execute subroutine		      *
;	*	{	initiate program segment	      *
;	*	}	discontinue program segment	      *
;	*	?	report detected error		      *
;	*						      *
;	*  The following are initialization programs which    *
;	*  can be called at the outset of a compilation.      *
;	*						      *
;	*	inre	initialize REC temporary registers    *
;	*						      *
;	* * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	*						      *
;	*	    REC86  -  Copyright (C) 1982	      *
;	*	   Universidad Autonoma de Puebla	      *
;	*		All Rights Reserved		      *
;	*						      *
;	*        [Harold V. McIntosh, 25 April 1982]	      *
;	*						      *
;	14 April 1983 - AR recognizes @@		      *
;	14 April 1983 - cosmetic changes: use of <lea>	      *
;	14 April 1983 - suppress TLU and TLV		      *
;	*******************************************************

;	=======================================================
;	The nucleus of REC is a compiler for control symbols,
;	operators and predicates, some auxiliary subroutines,
;	and an initilazation routine.
;
;	The compiler proper uses only the folowing external
;	references:
;
;		RAM storage		xpd, ypd, zpd
;		I-O routine		read
;		skip instruction	skp
;
;	The RAM storage must be initialized, which may be
;	accomplished by calling inre.
;
;	The location in which the object code is placed is
;	passed along through the register pair (dx), which is
;	continually updated to reflect the next available byte.
;	None of the other registers are either conserved nor
;	significant after the completion of compilation.
;
;	The usage of the registers is the following
;
;		pair (cx) contains the execution pointer
;		pair (dx) contains the object program counter
;		pair (bx) contains the compiling address
;
;	=======================================================

;	Equivalences defining INTEL 8086 instructions and some
;	constants.

CA	equ	0E8H		;call w/16 bit displacement
JU	equ	0E9H		;jump w/16 bit displacement
RN	equ	0C3H		;return w/o change of segment
POBX	equ	05BH		;pop bx
PUBX	equ	053H		;push bx
JUBX	equ	0E3FFH		;jmp bx
PUME	equ	036FFH		;push direct address
POME	equ	0068FH		;pop into memory
INBX	equ	043H		;inc bx
LDME	equ	006C7H		;ld mem,imm
ZE	equ	0000H		;zero
FF	equ	00FFH		;one byte complement of zero


;	=============
	org	0100H
;	=============


	jmp	main	;<===============================<<<


;	Compile a left parenthesis.

RECLP:	pop	bp
	push	ZPD		;save the linkage to semicolon exits
	push	YPD		;save the higher linkage to false jumps
	push	XPD		;save the repeat references
	ld	ax,#ZE		;initialze the new chains
	sto	ax,ZPD		;null TRUE exit list
	sto	ax,YPD		;null FALSE jump list
	sto	dx,XPD		;new parenthesis level begins here
	jmp	bp

;	Compile a colon.

RECCO:	ld	bx,XPD		;pick up reference to left parenthesis
	sub	bx,dx
	lea	bx,[bx-3]
	call	RECJU		;and insert a jump to its location
	jmp	RECFY		;fill in any FALSE predicate jumps

;	Compile a semicolon.

RECSC:	ld	bx,ZPD		;pick up link to TRUE exit chain
	call	RECJU		;insert this one on it too
	sto	bx,ZPD		;store it as the new head of the chain
	jmp	RECFY		;fill in any FALSE predicate jumpe

;	Compile an operator.

RECOP:	xchg	bx,dx
	stob	#CA,[bx]	;store the 8086 code for a call
	lea	bx,[bx+3]	;advance (dx) to receive next byte
	sub	cx,bx
	sto	cx,[bx-2]
	xchg	bx,dx
	ret

;	Compile a predicate.

RECPR:	call	RECOP		;call its subroutine, same as operator
RECYJ:	ld	bx,YPD		;linkage to FALSE exits
	call	RECJU		;incorporate a jump if result FALSE
	sto	bx,YPD		;update for new head of chain
	ret

;	Compile a right parenthesis.

RECRP:	pop	bp		;recover xpd, which is hidden
	pop	XPD		;replace it
	cmp	XPD,#ZE
	jz	RECFP		;if so, continue with recfp
	pop	bx		;recover wpd
	call	RECJU		;link expr to ypd on its own level
	push	bx		;but save pointer until we finish up
	call	RECFY		;false predicates in last segment
	pop	YPD		;replace ypd for higher level
	ld	bx,ZPD		;now we have destination for semicolons
	call	recfc		;so insert all the correct addresses
	pop	ZPD		;replace old zpd
	jmp	bp

;	Final right parentheses get a different treatment.

RECFP:	mov	bx,dx		;compile pointer in bx
	stob	#RN,[bx]	;store a <ret> for false exit
	inc	bx		;ready for next byte
	push	bx		;save compile pointer
	ld	dx,#SKP		;address of skip - TRUE exit from REC
	call	RECFY		;use it for last segment
	ld	bx,ZPD		;destination of semicolons now known
	call	recfc		;so fill out that chain
	pop	dx		;compile pointer that was saved
	pop	YPD		;restore old ypd
	pop	ZPD		;restore old zpd
	ret			;return one level higher than expected

;	Insert a new element in a chain of jmp's which will
;	eventually have destination addresses.  In the interim
;	each is given the address of its predecessor. On entry
;	(dx) holds the address where the instruction will be
;	stored and (bx) holds the address of its predecessor.
;	On exit, (dx) is incremented by 3 to point to the next
;	free byte, and (bx) has the starting value of (dx).

RECJU:	xchg	bx,dx		;(bx) and (dx) exchanged is better
	stob	#JU,[bx]	;store the jump instruction
	inc	bx
	sto	dx,[bx]		;store old link
	lea	dx,[bx+2]
	ret

;	When the destination of a linked chain of jumps is
;	finally known, the destination can be substituted into
;	each one of the links.  On entry, (bx) contains the
;	address of the first link unless it is zero signifying
;	a null chain.

recfc:	or	bx,bx		;test for end of chain
	jz	recfx		;if address is zero, chain ends
	mov	ax,dx
	dec	ax
	dec	ax
recfi:	ld	cx,[bx]		;save next link
	sto	ax,[bx]		;store destination
	sub	[bx],bx
	mov	bx,cx		;update link
	or	bx,bx
	jnz	recfi		;continue
recfx:	ret

;	Call recfc with the intention of filling the y chain.

RECFY:	ld	bx,YPD
	call	recfc
	sto	bx,YPD
	ret

;	Subroutine which will initialize the temporary
;	registers used by the REC compiler.

INRE:	ld	bx,#ZE
	sto	bx,XPD
	sto	bx,YPD
	sto	bx,ZPD
	ret


;	=======================================================
;	The following are specialized compiling subroutines
;	which apply to special structures and depend on the
;	model of a pushdown list with a linked chain structure
;	and special registers px and py delimiting the top
;	segment on the chain.
;	=======================================================

;	-------------------------------------------------------
;	Compilation of quoted expressions.  Single and double
;	quotes may alternate with one another to an arbitrary
;	depth.  Both kinds of quotes are executed in the same
;	way, by loading the quoted expression from the program
;	onto the pushdown list.
;	-------------------------------------------------------

;	Compile single quotes.

RECSQ:	call	RECOP		;record call to qu
	inc	dx		;set aside two bytes
	inc	dx		;to hold length of ASCII chain
	push	dx		;keep beginning for future reference
	push	QUEN		;delay cleanup until ret
SQ:	ld	bp,read		;read the next character
	call	bp
	cmp	al,#''''	;test for single quote
	jz	SQ2		;if so go after entire chain
	cmp	al,#'"'		;test for double quotes
	jnz	SQ1
	call	DQ1		;if so, read it all
SQ1:	xchg	bx,dx
	sto	al,[bx]
	xchg	bx,dx		;otherwise keep on storing
	inc	dx		;and advancing pointer
	jmp	SQ		;go after next character
SQ2:	ret

;	Compile double quotes.

RECDQ:	call	RECOP		;record call to qu
	inc	dx		;set aside two bytes
	inc	dx		;to hold length of chain
	push	dx		;put chain origin away for reference
	push	QUEN		;delay cleanup until ret
DQ:	ld	bp,read		;read the next character
	call	bp
	cmp	al,#'"'		;test for double quotes
	jz	DQ2		;if so, chain finished
	cmp	al,#''''	;check for single quotes
	jnz	DQ1
	call	SQ1		;if so go after whole chain
DQ1:	xchg	bx,dx
	sto	al,[bx]
	xchg	bx,dx		;otherwise keep on storing
	inc	dx		;and advancing pointer
	jmp	DQ		;go after next character
DQ2:	ret

;	Cleanup for both quote compilers.

QUEN:	dw	ENQU		;for the direct push
ENQU:	pop	bx		;beginning of chain in (bx)
	mov	cx,dx
	sub	cx,bx
	sto	cx,[bx-2]	;store length
	ret

;	(') (")   Execute single or double quote.

QU:	pop	bx		;get call location off the 8080 stack
	ld	cx,[bx]		;count
	inc	bx		;
	inc	bx		;
	mov	si,bx		;save source origin
	add	bx,cx		;calculate source end = return adress
	push	bx
	call	NARG		;check space, put dest. pointer in (bx)
	cld
	mov	di,bx
	mov	ax,ds
	mov	es,ax
	mov	ax,cs
	mov	ds,ax
	rep
	movsb
	mov	ax,es
	mov	ds,ax
	sto	di,PY		;record end of argument
	ret

;	-------------------------------------------------------
;	Comments are enclosed in square brackets, which must be
;	balanced.  Code may be disabled by enclosing it in
;	square brackets, but care must be taken that the
;	expression so isolated does not contain individual
;	brackets, such as arguments of arrobas or quoted
;	brackets, which might disrupt the balance. Since
;	comments are ignored by the compiler they are not
;	executed.
;	-------------------------------------------------------

;	Compile comments by ignoring them.

RECCM:	ld	bp,read		;get next character
	call	bp
	cmp	al,#']'		;test for closing ]
	jz	RECCX		;if so we're done
	cmp	al,#'['		;test for beginning of new level
	jnz	RECCM		;otherwise keep on reading
	call	RECCM		;if so go after it recursively
	jmp	RECCM
RECCX:	ret

;	-------------------------------------------------------
;	Sometimes, notably in compiling arroba as a call to a
;	subroutine named by a single letter, a parameter will
;	follow a subroutine call as its calling sequence.
;	-------------------------------------------------------

;	Operator with one ASCII parameter.

RECO1:	call	RECOP		;always compile the subroutine call
	ld	bp,read		;read the parameter
	call	bp
	mov	bx,dx
	sto	al,[bx]		;store as a 1-byte calling sequence
	inc	dx		;always ready for next byte
	ret

;	Predicate with one ASCII parameter.

RECP1:	call	RECO1		;compile as the analogous operator
	jmp	RECYJ		;then take account of false exit

;	-------------------------------------------------------
;	Decimal numbers are of such frequent occurrence in the
;	form of counters, arguments, or just data that it is
;	convenient to compile them on sight without requiring
;	any special delimiters.  Likewise, negative numbers are
;	easier to designate using a minus sign than using their
;	modular form, but this should not prevent the use of a
;	minus sign as an operator.
;	-------------------------------------------------------

;	Compile a minus sign. This involves determining whether
;	it is followed immediately by a decimal digit, in which
;	case it is compiled as part of a negative number.

RECMS:	ld	bp,read		;read in one byte
	call	bp
	call	MS1		;decide whether it is a digit
	push	ax		;it was not, save it
	call	RECOP		;compile call to binary minus
	pop	ax		;recover the extra character
	jmp	skp86		;skip because we have next character

MS1:	call	RND		;return if not digit
	inc	sp		;erase call to ms1
	inc	sp		;
	call	RECDS		;read and convert digit string
	ld	cx,GNU		;fake that it was nu, not ms
	push	ax		;save terminating character
	neg	bx		;negate (bx)
	jmp	DD1		;continue as though positive number

GNU:	DW	NU

;	Compile a decimal digit, which requires reading any
;	further digits which follow, and saving the terminator.

RECDD:	ror	al		;undo multiplication by 4
	ror	al		;
	push	cx		;save execution address
	call	RECDS		;read and transform rest of digits
	pop	cx		;recover execution address
	push	ax		;recover terminating character
DD1:	call	RECOP		;compile subroutine call
	xchg	bx,dx		;(dx) and (bx) must be interchanged
	sto	dx,[bx]		;put low order byte in calling sequence
	inc	bx		;
	inc	bx		;ready for next byte
	xchg	bx,dx		;put (dx) and (bx) back as they were
	pop	ax		;recover terminating character
	jmp	skp86		;skip over character read call

;	Multiply (bx) by 10 and add A.  (dx) is conserved.

TXP:	mov	cx,bx		;transfer (bx) to (cx)
	add	bx,bx		;multiply (bx) by 2
	add	bx,bx		;another 2 makes 4
	add	bx,cx		;the original (bx) makes 5
	add	bx,bx		;another 2 makes 10
	add	bx,ax		;add in the accumulator
	ret

;	The heart of number compilation.

RECDS:	and	al,#0FH		;mask ASCII down to binary value
	mov	BL,al		;put it into register pair (bx)
	ld	BH,#ZE		;fill out H with a zero
RD1:	ld	bp,read		;read the next character
	call	bp
	call	RND		;quit if it is not another digit
	call	TXP		;multiply (bx) by ten and add A
	jmp	RD1		;continuing while digits keep coming

;	Execute a number, which means load it on pdl.

NU:	ld	cx,#2		;two bytes will be required
	call	NARG		;close last argument, open new
	pop	dx		;get beginning of calling sequence
	xchg	bx,dx
	ld	ax,[bx]
	xchg	bx,dx
	sto	ax,[bx]		;and copy it over
	inc	dx		;on to the high order byte
	inc	bx		;and the place to store it
	inc	dx		;move on to program continuation
	inc	bx		;always leave PDL ready for next byte
	push	dx		;put back the return address
	sto	bx,PY		;mark end of the argument
	ret

;	(O) Transform an ASCII character string on the PDL into
;	a two-byte number.  Predicate - false if the argument
;	is not a digit string or null, leaving the argument
;	unchanged.

UCO:	ld	cx,#2		;two bytes are required
	call	OARG		;check that they are available
	ld	bx,PY		;fetch the end of the argument string
	stob	#ZE,[bx]	;put a zero there to mark its end
	ld	dx,PX		;load pointer to argument string
	ld	bx,#ZE		;zero in (bx) to start the conversion
O1:	xchg	bx,dx
	ld	al,[bx]
	xchg	bx,dx		;fetch one character
	inc	dx		;get ready for next
	or	al,al		;test for zero
	jz	O2		;go to accumulation phase
	call	RND		;FALSE, chain unaltered if non-digit
	call	TXP		;otherwise continue to work up value
	jmp	O1		;and keep on reading bytes
O2:	xchg	bx,dx		;safeguard converted number in (dx)
	ld	bx,PX		;get pointer to argument
	sto	dx,[bx]		;store low byte
	inc	bx		;increment pointer
	inc	bx		;increment pointer again
	sto	bx,PY		;store to close argument
	jmp	SKP		;TRUE exit from predicate

;	(#)  Change two-byte binary number into a decimal-based
;	ASCII string without sign. The special cases of a zero-
;	byte or a one-byte argument are also considered.

NS:	ld	cx,#05H		;five bytes may be required
	call	OARG		;reuse the old argument
	ld	cx,PY
	ld	bx,PX
	sub	cx,bx
	ld	dx,#ZE		;put zero in (dx) for default
	jcxz	NS1		;load nothing
	ld	dl,[bx]		;load low byte
	dec	cx		;test for one byte
	jcxz	NS1		;only byte and it's loaded
	ld	dh,[bx+1]	;load high byte
NS1:	push	bx		;save pointer for ASCII string
	ld	al,#'0'		;prepare to write a zero
	ld	bx,#-10000	;will there be 5 digits?
	add	bx,dx		;
	jc	NS2		;
	ld	bx,#-1000	;will there be 4 digits?
	add	bx,dx		;
	jc	NS3		;
	ld	bx,#-100	;will there be 3 digits?
	add	bx,dx		;
	jc	NS4		;
	ld	bx,#-10		;will there be 2 digits?
	add	bx,dx		;
	jc	NS5		;
	jmp	NS6		;write one no matter what
NS2:	ld	cx,#-10000	;ten thousands digit
	call	NSA		;
NS3:	ld	cx,#-1000	;thousands digit
	call	NSA		;
NS4:	ld	cx,#-100	;hundreds digit
	call	NSA		;
NS5:	ld	cx,#-10		;tens digit
	call	NSA		;
NS6:	add	al,dl		;units digit
	pop	bx		;recover pointer to PDL
	sto	al,[bx]		;store the digit
	inc	bx		;position pointer for next byte
	sto	bx,PY		;done, store it as terminator
	ret

NSA:	mov	bx,cx		;put power of ten in (bx)
	add	bx,dx		;subtract it once
	jnc	NSB		;can't subtract
	inc	al		;increase the count
	xchg	bx,dx		;put diminished number in (dx)
	jmp	NSA		;repeat the cycle
NSB:	pop	bp		;get <call nsa> return address
	pop	bx
	sto	al,[bx]		;store new digit
	inc	bx		;advance pointer
	ld	al,#'0'		;load a fresh ASCII zero
	push	bx
	jmp	bp		;return to the <call nsa>

;	=======================================================
;	Some simple procedures to compile REC expressions into
;	subroutines, deposit a reference to them in a symbol
;	table, and eventually to recover the space and erase
;	the symbol table reference.
;	=======================================================

;	Table search. The table whose address is stored at fxt
;	is consulted for its pair of addresses at position 4*A.
;	Thus on entry, A holds the table index.  This table
;	alternates the address of a compiling subroutine with
;	the execution address of the same entry.  On exit, (cx)
;	holds the execution address, (dx) is preserved, and a
;	jump is made to the compiling address.

rects:	ld	ah,#ZE
	add	ax,ax
	add	ax,ax
	ld	bx,FXT		;load base address of table
	add	bx,ax
	push	[bx]		;put the first entry in (cx)
	ld	cx,[bx+2]	;table pointer is going
	ret			;then off to the compilation

;	Pick out left delimiters: (, {, or [.

left:	ld	bp,read
	call	bp
	cmp	al,#'('
	jz	eft
	cmp	al,#'{'
	jz	eft
	cmp	al,#'['
	jnz	left
	call	reccm
	jmps	left
eft:	ret

;	A main program to compile characters one by one as
;	they are read in from the console.  Note that the
;	compiling programs invoked by rects can generate skips
;	when they have already read the following character.
;	This occurs most notably when compiling digits. Also
;	note that svc86 normalizes characters when it accepts
;	them.

recre:	ld	bp,read		;read a character from whereever
	call	bp
recrr:	call	svc86		;check for space, control character
	jmp	recre		;not valid, go back for another
	call	rects		;look up in table and compile it
	jmp	recre		;read another character and repeat
	jmp	recrr		;repeat but next character already read

;	A subroutine which will pass over comments, and wait
;	for an opening left parenthesis or brace before compiling
;	a REC expression.

EMCE:	call	UCL		;entry here erases an argument from PDL
EMCX:	call	left 		;get a character from whereever
	ld	dx,C1
	ld	bx,C1
	mov	bp,sp
	xchg	bx,[bp]
	push	bx
	call	recrr		;compiling prgrm one char already read
	sto	dx,C1
	ret

EMCU:	pop	dx
	pop	bx
	push	dx
	push	bx
	ld	dx,#EMCV
	push	dx
	jmp	bx
EMCV:	jmp	EMCW
	pop	C1
	jmp	skp86
EMCW:	pop	C1
	ret

;	({) Introduce a series of definitions.

LBR:	xchg	bx,dx
	stob	#CA,[bx]	;insert a call to the executable subroutine
	xchg	bx,dx
	inc	dx
	mov	cx,dx		;place to put call address - keep in BC
	inc	dx		;make room
	inc	dx
	call	RECYJ		;link in the FALSE exit
	call	RECJU
	push	bx		;keep this address
	push	XPD
	sto	#ZE,XPD		;this is top level for ensuing subroutines
	ld	bx,#ZE
LB1:	push	dx		;record entry point to subroutine
	inc	bx		;increment count of subroutines
	push	bx		;keep it next to top on stack
	push	cx		;jump address at entry - keep it on top
	call	left
	call	recrr		;compile at least one subroutine
LB2:	ld	bp,read		;get possible name of subroutine
	call	bp
	cmp	al,#'}'		;no name - we execute this one
	jz	LB3
	call	svc86		;convert name into serial number
	jmp	LB2		;punctuation instead of name
	add	al,#' '
	ld	ah,#ZE
	ld	bx,VRT
	add	bx,ax
	add	bx,ax
	pop	cx		;get this out of the way
	mov	bp,sp
	xchg	bx,[bp]		;store table address, put subr count in bx
	jmp	LB1
LB3:	cld
	mov	ax,ds
	mov	es,ax
	pop	bx		;origin of brace compilation
	mov	di,dx
	sto	di,[bx]		;store displacement at initial jump
	sub	[bx],bx
	dec	[bx]
	dec	[bx]
	pop	cx		;number of subroutines + 1
	push	cx		;we'll need it again later
	mov	bp,cx		;put it in bp too
	dec	bp
	add	bp,bp
	add	bp,bp
	add	bp,sp
	ld	al,#POBX
	stosb
	jmp	LB5
LB4:	ld	ax,#PUME	;for each defined symbol we insert the
	stos
	ld	ax,[bp]
	stos
	ld	ax,#LDME	;
	stos
	ld	ax,[bp]
	stos
	ld	ax,[bp+2]
	stos
	sub	bp,#4		;we read the stack backwards
LB5:	loop	LB4
	ld	al,#PUBX
	stosb
	ld	al,#CA
	stosb
	pop	cx
	pop	ax
	sub	ax,di
	dec	ax
	dec	ax
	stos
	push	cx
	ld	al,#JU		;	jmp	$+6
	stosb
	push	di		;	inx	h
	inc	di		;	inx	h
	inc	di		;	inx	h
	ld	al,#POBX
	stosb
	ld	al,#INBX
	stosb
	stosb
	stosb
	ld	al,#PUBX
	stosb
	pop	bx
	sto	di,[bx]
	sub	[bx],bx
	dec	[bx]
	dec	[bx]
	ld	al,#POBX
	stosb
	pop	cx
	jmp	LB7
LB6:	ld	ax,#POME	;after an expression in braces is
	stos
	pop	ax
	stos
	inc	sp
	inc	sp
LB7:	loop	LB6
	ld	ax,#JUBX	;the whole thing is finished off by a return
	stos
	mov	dx,di
	pop	XPD
	pop	bx
	cmp	XPD,#ZE
	jz	LB8
	sto	dx,[bx]
	sub	[bx],bx
	dec	[bx]
	dec	[bx]
	ret
LB8:	ld	cx,[bx]
	sto	#SKP,[bx]
	sub	[bx],bx
	dec	[bx]
	dec	[bx]
	sub	bx,cx
	sto	dx,[bx]
	sub	[bx],bx
	dec	[bx]
	dec	[bx]
	xchg	bx,dx
	sto	#JUBX,[bx]
	inc	bx
	inc	bx
	xchg	bx,dx
	inc	sp
	inc	sp
	ret

;	(@) Subroutine which will transform an ASCII character
;	into a table reference, and then jump to the address
;	so encountered.  This is essentially REC's subroutine
;	call mechanism, necessarily a predicate since it calls
;	a REC expression, which is itself a predicate.

AR:	pop	bx		;entry if name is a parameter
	ld	al,[bx]		;read the calling sequence
	inc	bx		;advance pointer for return
	push	bx		;put it back on 8080 stack
	cmp	al,#'@'
	jnz	XAR
NAR:	ld	bx,PX		;entry if subroutine index is argument
	ld	al,[bx]
	call	UCL
XAR:	ld	ah,#ZE
	add	ax,ax
	mov	di,ax
	ld	bx,VRT		;entry when index is in register A
	jmp	[bx+di]		;then use it as jump address

;	=======================================================
;	Some general service routines.
;	=======================================================

;	Skip on valid character, meaning, not control symbol.
;	If valid, 20H (space) is subtracted, making A = 1, etc.

svc86:	cmp	al,#'!'		;reject space, excl is lower limit
	jc	sv
	cmp	al,#7FH		;seven bits is upper limit
	jnc	sv
	sub	al,#' '		;normalize to begin with (excl) = 1
	pop	bp
	inc	bp
	inc	bp
	jmp	bp
sv:	ret			;don't skip for control or flag bit

;	Return if not decimal. A unchanged if not decimal, else
;	reduced to binary.

RND:	cmp	al,#':'		;colon follows 9 in ASCII alphabet
	jnc	RTN
	cmp	al,#'0'		;ASCII zero is lower limit
	jc	RTN
	sub	al,#'0'		;normalize to get binary values
	ld	ah,#ze		;zero for uncomplicated arithmetic
	ret
RTN:	inc	sp
	inc	sp
	ret

;	Second level return on error.

RR2:	pop	bx		;entry to clear two items from PDL
	mov	bp,sp
	xchg	bx,[bp]		;
RR1:	pop	bx		;entry to clear one item from PDL
	mov	bp,sp
	xchg	bx,[bp]		;
RER:	pop	ax		;site where ther error occurred
	cmp	ER,#ZE		;only record the first error
	jnz	RRR
	sto	ax,ER
RRR:	ret

;	(?)  Test whether an error has been reported: predicate
;	which is true if er is nonzero, in which case it will
;	reset er.  It will also, if TRUE, place the calling
;	address of the last reported error on the pushdown
;	list.  If false, only a FALSE return is generated. Note
;	the ironic circumstance that, if PDL is exhausted, qm
;	can generate an error trying to report an error - but
;	the TRUE result will still be valid.

QM:	cmp	ER,#ZE		;test the error cell
	jz	QQ		;FALSE return if no error
	ld	cx,#2		;we want two bytes for error address
	call	NARG		;check space, prepare for new argument
	ld	ax,ER		;fetch error address
	sto	ax,[bx]		;transfer it to REC PDL
	inc	bx		;
	inc	bx		;pointer must always advance
	sto	bx,PY		;end of the argument
	sto	#ZE,ER		;reset ER
	jmp	SKP		;TRUE return - there was an error
QQ:	ret

;	Generate a skip (skp), which is often combined with the
;	erasure of an argument on the pushdown list (cucl).

CUCL:	call	UCL		;erase the top argument
SKP:	xchg	bx,sp
	inc	[bx]		;assume the skip will be over a
	inc	[bx]		;three-byte instruction, such as a jump
	inc	[bx]		;
	xchg	bx,sp
	ret			;return to the altered address

skp86:	xchg	bx,sp
	inc	[bx]
	inc	[bx]
	xchg	bx,sp
	ret

;	Test PDL space beginning at top argument. On entry (cx)
;	contains the total space required.  On exit, (cx) stays
;	unchanged, (dx) holds pz, while (bx) holds px+(cx).
;	If the space is not available, return is made from the
;	calling program after noting the error.  Otherwise
;	normal return to the calling program occurs. The likely
;	use of oarg is to record a result without having to go
;	through ucl, NARG.

OARG:	ld	dx,PZ		;load limit of PDL
	dec	dx		;keep one byte margin
	ld	bx,PX		;load beginning of current argument
	add	bx,cx
	sub	dx,bx
	jc	oar		;no, note error, quit calling program
	ret			;yes, continue normally
oar:	call	RER		;this must be here to get a short jump

;	Check space for, and then set up, a new argument. On
;	entry, (cx) should contain the amount of additional
;	space required.  The program will automatically add
;	two more bytes for the pointer which would close the
;	argument and then, if the required space is available,
;	close it, define the new px, and leave its value in
;	(bx).  (dx) will contain the old value of px to be used
;	in case the superseded argument is still interesting.
;	When space is not available, the error return rer is
;	taken.
;
;	The entry RARG can be taken when it is known that
;	sufficient space is available but the pointers still
;	have to be set up.

NARG:	mov	di,cx
	ld	bx,PY		;load end of current argument
	lea	ax,[bx+di+3]
	cmp	ax,PZ
	jnc	NRER		;check available space
RARG:	ld	dx,PX		;entry if no space check needed
	ld	bx,PY
	sto	dx,[bx]		;low byte of closing link
	inc	bx		;on to high byte
	inc	bx		;beginning of new space
	sto	bx,PX		;which is recorded by px
	ret			;and remains in (bx)
NRER:	call	RER

;	(L)  Remove argument from pushdown list. There are no
;	requirements for entry to ucl.  On exit, (cx) remains
;	unchanged, (dx) holds the end of the former argument
;	and (bx) holds the beginning of the former argument -
;	the one that was exposed when the current argument was
;	erased. Erasing non-existent arguments creates an error
;	condition which is noted and ignored.

UCL:	ld	bx,PX		;pointer to current argument
	dec	bx		;just behind the present
	dec	bx
	ld	dx,[bx]		;argument is the address
	or	dx,dx		;so we always test out of caution
	jz	ULE
	sto	bx,PY		;(bx) now holds end of previous arg.
	sto	dx,PX		;pointer to beginning of prev. arg.
	xchg	bx,dx
	ret
ULE:	call	RER		;record error if pointer was zero

;	Null program for undefined operators.

NOOP:	ret

;	=======================================================
;
;	Some of the service routines, which might be external
;	references in other modules, are:
;
;		oarg	space when reusing an argument
;		NARG	close old argument, space for new
;		rarg	same as NARG when space is assured
;		skp	generic skip
;		rer	return on error
;		rr2	rer after popping two addresses
;		rtn	generic return
;		ucl	lift argument from PDL (L)
;		cucl	lift argument, then skip
;
;	Three entry points can be used according to the variant
;	of the compiling operator C desired.  One of them could
;	also be used by a main program.
;
;		emce	lift pushdown, open block, compile
;		emcx	compile a sequence of subroutines
;
;	=======================================================

	LINK	PDL86.ASM


