*	back2ddt.asm	Version 1	September 5, 1981
*
*	Enables exiting from DDT via "G18" and returning via control-B.
*
*	(C) 1981 by Roy Lipscomb, Logic Associates, Chicago
*	Copying for non-profit distribution is permitted.
*
*
***********************************************************************
*
*	This module is useful when debugging a program for which you
*	have a .PRN file on disk.  You can exit from DDT; display the
*	.PRN listing; then return to DDT and the program being tested.
*
*	Notes:
*
*	1)  As supplied, BACK2DDT uses restart locations 3-6 (18h-37h).
*
*	2)  The CCP must be protected from being overlaid.  (This
*	requirement is met if DDT is loaded via DDTX, a public-
*	domain program by Ken Barbier available on many RCPM
*	systems.)
*
*	3)  The program being debugged will be preserved during
*	CCP resident commands--ERA, DIR, TYPE, REN, or SAVE.  Any
*	other (transient) commands will overlay the program.
*
*	4)  The CCP resets the dma to 80h, and alters 80h-ffh. Thus,
*
*		a)  Be sure you have nothing critical in this area
*		(such as the program stack) when exiting with "G18".
*
*		b)  If your program uses a different dma, be sure to
*		reset the dma after typing control-B.
*
*	5)  Registers A, PSW, and PC are not restored by control-B.
*
********************************************************************

	org 	100h
	jmp	begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		initial variables			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; change trap char, if so desired
trapchr	equ	2		;control-b means "back to ddt"


;do not change these
trubase	equ	18h		;actual load point of trap
bdos	equ	5
cindisp	equ	10		;displacement of conin addr in jmptable
display	equ	2

cr	equ	13
lf	equ	10

poph	equ	0e1h		;one of the test instructions



; "done" message
eom	equ	'$'

done	db	cr,lf,'Back2ddt   version 1, Sept 81'
	db	cr,lf
	db	cr,lf,'After protecting the CCP and loading DDT,'
	db	cr,lf,'exit DDT via "G18" and return via control-B.'
	db	cr,lf,eom

notdone	db	cr,lf,'Back2ddt already loaded:  no action',cr,lf,eom


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		mainline				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

begin	push	h
	push	d
	push	b

;test if already loaded
	call	testit
	jz	return		;yes, already loaded

;move module into place
loadit	lxi	h,module
	lxi	d,trubase
	lxi	b,length
	call	move

;divert cp/m jmp-addresses to trap
	call	patchit	

;exit to cpm
return	pop	b
	pop	d
	pop	h
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		patch bios to trap conin		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;address conin entry in bios jump-table
patchit	lhld	1
	mvi	l,cindisp		;insert offset for conin

;remove true conin jmp-address
	mov	e,m
	inx	h
	mov	d,m

;insert trap address into jmp table
	lxi	b,trpentr-adjust
	mov	m,b
	dcx	h
	mov	m,c

;insert true conin address into trap
	xchg
	shld	trpentr-adjust+1

;print "done" message
	lxi	h,done
	call	message

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		test if already loaded			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;test if bios jump table already points to trap

;address conin table entry
testit	lhld	1
	mvi	l,cindisp
	mov	c,m
	inx	h
	mov	b,m

;compare jump-table entry with trap entry
	lxi	d,trpentr-adjust

	mov	a,c
	sub	e

	mov	a,b
	sbb	d

	rnz		;if not equal, assume not already loaded

;already loaded, so output message
	lxi	h,notdone
	call	message

;turn on zero flag
	xra	a

	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		move block of data			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;source in hl, destination in de, length in bc.

move	mov	a,b
	ora	c
	rz
	mov	a,m
	stax	d
	inx	d
	inx	h
	dcx	b
	jmp	move

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		print signoff mess			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
message	mov	a,m
	inx	h
	cpi	eom
	rz		;return if message completed

	mov	e,a
	mvi	c,display
	push	h
	call	bdos
	pop	h
	jmp	message


*********************************************************
*********************************************************
*		conin-trap module			*
*********************************************************
*********************************************************


module	equ	$
adjust	equ	module-trubase		;fudge factor, to compute
					;true address


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exit from ddt (save important values)  (takes 15 bytes)
ddtexit	push	b		;save registers
	push	d
	push	h

	lhld	6		;save ddt trap address
	push	h

	lxi	h,0		;save stack pointer
	dad	sp
	shld	stksav-adjust

	rst	0		;reboot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; if trapchr found, jmp to ddt; else return (takes 17 bytes)

trpentr	call	0		;perform conin (0 changed at run time)
	cpi	trapchr		;go to ddt?
	rnz			;no, back to CCP

	lxi	sp,0		;restore stack address
stksav	equ	$-2		;(filled at ddt-exit time)

;next two instructions are used to test for already-loaded module
testlod	pop	h		;restore ddt trap address
	shld	6

	pop	h		;restore registers
	pop	d
	pop	b

;must use actual RST 7 instruction, to preserve stack pointer.
	rst	7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;get length of relocatable routines
length	equ	$-module	;must equal 38h, in orig version.

	end
