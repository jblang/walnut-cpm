; Routine:	FRESET -- fast drive reset and login
; Author:	Bridger Mitchell (Plu*Perfect Systems)
; CPU:		Z80-compatible
; Date:		December 27, 1987
; 
; This routine (fast-)resets and logs in the cp/m drive in register
; (A).  When possible, it uses BDOS function 37 (logoff drives). 
; In most cases FRESET is significantly faster than using function 13
; (reset all drives) to do a general reset.
; 
; FRESET functions correctly with Digital Research's CP/M 2.2 bdos,
; which contains a bug that does not allow the logged-in drive to
; be reset with function 37.
; 
; Some CP/M bdos emulators (such as ZRDOS, PZDOS, ...) have changed
; the operation of the general-reset function 13, in order to speed
; up warm-boots and disk-resets on systems with hard-drives. In this
; case, a non-removable drive (hard disk, ram disk), after it
; has been initially logged in, remains logged in after a general
; reset.
; 
; On such systems it is **essential** that any program that uses
; BIOS disk functions to write to a non-removable drive also cause
; the disk's allocation map to be rebuilt before any BDOS disk
; functions are used.  DU (DU3) and UNERASE are probably the most
; common examples of such programs; they modify the disk directory.
; For these systems, the drive must first be logged off with
; function 37 and then logged in.  Calling FRESET within such
; programs will ensure that the disk's allocation map is recomputed.
; 
; The FRESET algorithm:
;
;   if requested_drive is logged in
; 	if a second drive is logged in
; 	    log in the second drive
; 	    logoff requested drive (fn.37)
; 	else
; 	    do general reset (fn. 13)	
;   log in requested drive
; 
;
xbdos	equ	5

;	Fast-reset drive (A)
;	A = 0 ... 15  for  A: ... P:
;	
CSEG
freset:
	ld	(reqdrv),a	; save requested drive
	push	af
	ld	c,24		; get logged-in drives vector
	call	xbdos
	pop	af		; (recover requested drive)
	push	hl		; save logged-in vector
	call	fshftr		; shift requested drive's bit to bit 0
	bit	0,l		; is requested drive logged in?
	pop	hl		;  (recover (unshifted) logged vector)
	jr	z,flogit	; ..z - no, just log it in
	ld	b,0		;  initialize drive index/count
	jr	frese2
;
frese1:	ld	a,1		; shift vector right 1 bit
	call	fshftr
frese2:	bit	0,l		; if drive is logged in
	jr	z,frese3	;
	ld	a,(reqdrv)	; .. and it is not requested drive
	cp	b
	jr	nz,fnd2nd	; .. have found 2nd logged in drive
frese3:	inc	b		; else increment drive count
	ld	a,b		;   and continue for 16 drives 
	cp	16
	jr	c,frese1	;
	ld	c,13		; no other drive is logged in, so..
	jr	flogit0		; ..do general reset, then (re)log requested
;
;	have a second logged-in drive, so switch to it
;
fnd2nd:	ld	e,b		; select b'th drive
	call	fslctit
	ld	a,(reqdrv)	; set up bit to log out drive
	ld	hl,1
	call	fshftl
	ex	de,hl
	ld	c,37		; log out drive in DE vector
;
flogit0:call	xbdos
;
;	login requested drive
;
flogit:	ld	a,(reqdrv)
	ld	e,a
fslctit:ld	c,14		; select bdos drive
	jp	xbdos	
;
;
; shift hl right (a) bits
;
fshftr:
	inc	a
shftr1:	dec	a
	ret	z
	srl	h
	rr	l	
	jr	shftr1
;
;
; shift hl left (a) bits
;
fshftl:
	inc	a
shftl1:	dec	a
	ret	z
	add	hl,hl
	jr	shftl1	

;--------------------
DSEG
reqdrv:	ds	1

	end
t
	call	fshftr
frese2:	bit	0,l		; i