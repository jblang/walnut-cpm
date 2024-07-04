TITLE 'MBASIC console output - printer redirection'
;****************************************************************
;*								*
;*                      R E D I R . A S M                       *
;*								*
;****************************************************************
;                               by
;                          Jack L. Owens
;
;                   Jack Owens Service Company
;                       1626 Del Dayo Drive
;                     Carmichael, California
;                              95608
;
;                          (916)485-8995
;
;                          March 7, 1984
;
;       For use with Microsoft Basic version 5.21 interpreter
;
;	Patch to the base page of operating system to allow
;	 redirection of BASIC console output to the printer.
;
;	Method:
;		a) set up one of the RST locations with a jump
;			to the BIOS print vector.
;
;		b) set up another RST location with a call to
;			the BIOS print vector and then a routine
;			to jump to the CONOUT vector.
;
;		c) poke an RST <n> in place of the call instruction
;			in BASIC then continue with BASIC program
;
;		d) when all through, poke a <call> instruction to return
;			the CONOUT vector in BASIC to it's original
;			condition.
;
;	Note: You may find out where the base of the BIOS jump vector is
;		by inspecting the pointer found in addresses 1 and 2 in
;		a normal CP/M system.
;
;	Set your program up with the following information:
;	
;100 LIST% = 207'		RST 1
;110 BOTH% = 223'		RST 3
;120 CALLL% = 205'		Replace RST instruction with CALL (CD)
;130 CONOUT% = &H41E4'		Location in MBASIC 5.21 with call to CONOUT
;
;	Then whenever you wish to redirect the console output to the printer
;	 only, do:
;
;1500 POKE CONOUT%,LIST%
;	
;	 and all console output will go to the printer.  If you want the
;	 console output to go to both printer and console, then do:
;
;1500 POKE CONOUT%,BOTH%
;
;	 and all console output goes to both printer and console.
;
;	Whenever you want to return to normal operation, do:
;
;2500 POKE CONOUT%,CALLL%
;
;	 and the MBASIC interpreter returns to normal operation.
;
;	Run the following program once after boot up.  Then go ahead
;	 with normal operation.  Only shutting the system down should
;	 destroy the routines in the RST locations.  WARNING! some
;	 CP/M systems use these RST locations for their own purposes. 
;	 If so, change to another set of RST locations not in use.  My
;	 system uses the RST 2 location to keep track of the system
;	 clock time.
;
BIOS	equ	0EE00h		;start of BIOS jump table
				; change to suit your system
;
CONOUT		equ	BIOS+12		;CONOUT jump vector
LIST		equ	BIOS+15		;LIST jump vector
RESTART1	equ	8		;location of RST 1
RESTART3	equ	18h		;location of RST 3
;
	
org	100h
;
	jmp	START		;jump around code to be moved
;
; The following code up to start is moved with the code at START
;
;RST 1 routine
CODE:	jmp	LIST		;redirect to printer
;
;RST 3 routine
	push	B		;save the character for CONOUT
	call	LIST		;go print a character
	pop	B		;get the character back
	jmp	CONOUT		;go print the character on the screen
;
START:
	lxi	h,CODE		;pointer to CODE to be moved
	lxi	d,RESTART1	;pointer to relocated code address
	mvi	b,3		;length of RESTART1 code
	call	mover
	lxi	d,RESTART3	;pointer to RST 3 address
	mvi	b,8		;length of both console and printer code
	call	mover
	jmp	0		;reset the system
;
Mover:
	mov	a,m		;get a byte
	stax	D		; and store it
	inx	h		;And
	inx	d		;	bump
	dcr	b		;		Registers
	jnz	mover
	ret
;
	end
