; Title:  Wipe.asm (c)
;      	  Erase ALL (*.PRN, *.HEX, *.SYM, *.REL and *.BAK) on current drive
; Author: Steven D. Rudnik
; Date:   8/9/83
;			   **********************
;                          * Copyright 1983 Sdr *
;			   **********************
;
; *************************************************************************
; Notes:
;        If there are any users of ASM, MAC, CB80, or any other assemblers
;        or compilers, this program is for you.  Programmers who have only
;	 limited disk storage space often find during development the need
;	 to remove resultant files, i.e. BAK, SYM, etc..., from your disks
;	 in order to make room for further development.    Why always type
;	 those familiar ERA *.BAK, ERA *.PRN, etc...?    There is a saying
;	 that reads:
;                    A good programmer does things only once, then has the
;                    computer do them, from then on...
;  						        SOUNDS REASONABLE!
; *************************************************************************
;
;	This software may be used in the PUBLIC DOMAIN for non-commercial
;	use only.  Any comments or suggestions may be referred to:
;
;			Steven D. Rudnik
;			201-993-2000  Ext. 4172  
;		       (12:00 Noon to 4:30 PM EST)
;
; *************************************************************************
;
; Some equates...
;
cpm	 	equ	0	; cpm base
bdos		equ	cpm+5	; bdos entry point
print		equ	09h	; string out
kill		equ	13h	; delete file
curdisk		equ	19h	; return current disk
setdma		equ	1ah	; set DMA
clsrn		equ	1ah	; clearscreen
cr		equ	0dh	; return
lf		equ	0ah	; line feed
endstr		equ	'$'	; marker for string out
;
	org	100h		; let's start here...
;
main:	mvi	c,curdisk	; find which disk we're on
	call	bdos
	adi	41h		; add 65 to make char
	sta	disk		; place char in output string
;
erase:	mvi	c,print		; print sign on message
	lxi	d,signon	
	call	bdos
;
	lxi	h,table		; load HL with table address
loop:	mov	a,m		; get char 1 of type 
	inx	h		; bump pointer...
	sta	ext1		; place char into output string
	cpi	endstr		; check for end of table...
	jz	cpm		; true =: done
	mov	a,m		; repeat for char 2...
	inx	h
	sta	ext2
	mov	a,m		; repeat for char 3...
	inx	h
	sta	ext3
inloop:	mvi	c,kill		; kill file(s) specified in fcb
	lxi	d,fcb		; our own FCB address
	push	h		; preserve because BDOS doth clobber...
	call	bdos
	pop	h		; recall pointer...
	cpi	0ffh		; check return flag  0ffh := none found
	jz	loop		; if none found then wrap up
	jmp	inloop
;
;       Modify table here, each entry must be three bytes (PRN, etc) and
;	end with 'endstr'.
;
table:	db	'PRNBAKSYMRELHEXSYM'
	db	endstr
;
fcb:	db	0
	db	'????????'
ext1:	db	' '
ext2:	db	' '
ext3:	db	' '
	ds      21
;
signon:	db	cr,lf
	db	'Wipe  Version 1.0',cr,lf
	db	'-----------------',cr,lf,lf
	db	'Erasing *.PRN, *.HEX, *.SYM, *.REL and *.BAK from Drive '
disk:	db	0
	db	':',cr,lf,endstr
;
done:	end
