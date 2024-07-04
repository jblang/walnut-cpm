;DDTtools.*         --CHR$(13)08DEC84lastupdate 
;           ...to be kept as a *.HEX file.  DDT 
;brings it in as an overlay to other work  (or, 
;better, in its initial load), to provide a few 
;tools  Kildall didn't think we'd need back  in 
;the TTY days.   Don't LOAD it to a *.COM file; 
;the COMfile is a memory image that'll take  up 
;a   lot   of  diskfile  space  and  wipe   out 
;whatever's in low memory when it's brought in. 
;Use the *.HEX file.
; Variables are loaded into registers using the 
;"X"  command before entry with "G".  Constants 
;are provided by the routines.  The labels  are 
;there  to  point out the starting  points  for 
;these routines.
; The binary-to-decimal conversion routine came 
;from "Soul of CP/M".
; This code is self-modifying,  to avoid  over-
;using the little  DDT stack in the DMA block.
;Print  a  copy of this or the  *.PRN  file  to 
;serve as a manual.  I need it, and I wrote the 
;thing!
;  
; I  hereby  place my portions of this work  in 
;the public domain.  I do request credit in its 
;distribution,   complete with call-letters and 
;my weird pseudoBasic signature/datecode.
;        --C. R. Bryan III WB1HKU/6
; IMPORTANT:  If you are running with less than 
;64k of memory, you MUST lower the origin. This 
;package should load in just under DDT where it 
;overlays  the  CCP,  leaving room  for  a  few 
;scribbles .  In my Ampro system, DDT starts at 
;0D000h.
;
;
;EQUATES:
BDOS	equ	5
CR	equ	0Dh
LF	equ	0Ah
CTRLC	equ	3
CTRLZ	equ	01Ah

	org	0CA00h	;well out of the way of a PUMP image.
ORIGIN:	equ	$	;Here. Whatever you change org to be.
LABEL1:	db	'STRINGFINDR:'
	mvi	a,1
	sta	HIT+1
	lda	BYCT
	sta	CHECK+1
	lxi	h,STRING
CEIL:	lxi	b,ORIGIN-1	;early stop, otherwise it'll 
				;match the string with itself.
	lxi	d,100h		;TPA start.
LUP:	ldax	d
	ani	7Fh	;NO-OP this out for object code. 
			;This mask keeps WordStar 
			;raised bits from preventing 
			;a match.
	cmp	m
	jz	HIT	;go advance everything for the next byte.
	mvi	a,1
	sta	HIT+1	;we reset our hit-count on any mismatch.
	lxi	h,STRING	;and our pointer.
MIDLUP:	inx	d	;HIT rejoins us here.
	dcx	b
	mvi	a,0	;test: have we run out of room to play?
	cmp	c
	jnz	LUP
	cmp	b
	jnz	LUP
	lxi	h,0	;this is your indication of failure to
	rst	7	;find a match. An address in h and nonzero
			;in b means h has end--of-match address.
;
BYCT	db	0	;it's zero until you put something in it.
			;this is the number of bytes you put in the 
			;string to be matched (byte count). 
STRING:	db	'PUT '	;if you need more room, repoint to somewhere
			;else in memory. Don't forget to load BYCT.
	db	'STRING HERE!'

;
HIT:	mvi	a,1	;we rezero this up at the top for each use.	
CHECK:	cpi	0	;this too gets modified, to BYCT.
	jz	REPORT	;hitcount = BYCT. We found it. Go brag.
	inr	a	;well, not all of it.
	sta	HIT+1
	inx	h	;point to the next byte to match
	jmp	MIDLUP	;and get on with it.
;
REPORT:	xchg
	shld	SCRTCH
	mvi	e,7	;beep
	mvi	c,2
	call	BDOS
	mvi	e,24h	;sure sign of success: dollar-signs
	mvi	c,2	;(well, one) showing up on your screen.
	call	BDOS	;use "eXamine" function of DDT to see
	lhld	SCRTCH	;where the string was, in hl.
	rst	7
SCRTCH:	dw	0	;scratchpad
;
LABEL2:	db	'PAGES:'	
			;this is why I wrote this package in
			;the first place. Saves the HP-16's
			;batteries if the Z80 tells how many
			;pages to SAVE. Give it the last valid
			;address in hl (or leave it in there if
			;it's already there). Then go see what it
			;left you after SAVE:.
	mov	l,h
	mvi	h,0
	lxi	d,-100
	call	SUBCNT
	sta	LOOKY+6
	lxi	d,-10
	call	SUBCNT
	sta	LOOKY+7
	lxi	d,-1
	call	SUBCNT
	sta	LOOKY+8
	rst	7
;
SUBCNT:	mvi	c,2Fh
SUBL:	inr	c
	shld	SCRTCH
	dad	d
	jc	SUBL
	lhld	SCRTCH
	mov	a,c
	ret
;
LOOKY:	db	'SAVE:      '
;
LABEL3:	db	'TOPSTRIP:'	
			;resets the top bit of each byte so 
			;WordStar files aren't cloudy with dots. PIP
			;does the same thing if you transfer with
			;a [z argument, but only if you're willing
			;to copy over to a new file. This does it
			;for you within DDT, ready to SAVE. Load
			;hl with the first address, de with the last.
			;Next time, write your .ASM file in
			;non-document mode and avoid all this.
STRIP:	mov	a,m
	ani	7Fh
	mov	m,a
	inx	h
	mov	a,e
	cmp	l
	jnz	STRIP
	mov	a,d
	cmp	h
	jnz	STRIP
	rst	7
;
LABEL4:	db	'PRINTSAF:'	
			;this routine makes embedded strings
			;(like those in WINSTALL) readable by 
			;WordStar, once you've reformed and
			;thrown out the gibberish. Anything
			;that would bother a printer gets turned
			;into a space, leaving only linefeeds,
			;carriage returns, and good printing
			;characters. First address in hl, last
			;address in de. 
SAFT:	mov	a,m
	ani	7Fh
	cpi	20h	;less than a space?
	jc	ITSOK
	cpi	0Dh	;carriage-return
	jz	ITSOK
	cpi	0Ah	;linefeed
	jz	ITSOK
	mvi	a,20h	;well, it's NOT okay. Space it.
ITSOK:	mov	m,a
	inx	h
	mov	a,e
	cmp	l
	jnz	SAFT
	mov	a,d
	cmp	h
	jnz	SAFT
	rst	7
;
LABEL5:	db	'TYPECHAR:'	
			;when invoked, this routine lets you
			;type ASCII strings directly into
			;memory,rather than having to translate
			;them into hex. Stops when you give it
			;a control C, or whenever it hits the
			;ceiling. Control Z is allowed as a
			;character. Load hl with the first byte's
			;address first.
GOTYPE:	shld	SCRTCH
	mvi	c,1	;Conin. Any mail? Wait 'til there is.
	call	BDOS
	cpi	3	;test: control C?
	jz	QUIT
	lhld	SCRTCH
	mov	m,a
	inx	h
	lda	CEIL+2	;ceiling page over in Stringfindr
	cmp	h
	jnz	GOTYPE
	lda	CEIL+1	;final allowed bytes.
	cmp	l
	jnz	GOTYPE	;these routines won't work if you type on
QUIT:	rst	7	;them, you know.
;
	end

eof DDTTOOLS/ampro[000049] --CHR$(13)07DEC84
