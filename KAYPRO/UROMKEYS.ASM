;
; UROMKEYS.ASM -- Program to set/reset the Kaypro Universal ROM
;		  BIOS function keys to a given set of keys.
;
;
; By	Tim Farley			Copyright (c) 1986, Tim Farley
;	415 Ethel St, N.W.		All Rights Reserved.
;	Atlanta, GA  30318-7942		License granted for free non-
;					commercial use ONLY.
;
; NOTE: only good with Kaypro version 2.2u.  Do not even attempt
;	to use this program with any other version of CP/M, nor
;	with any other computer than a Kaypro, version 2.2u.
;
;
; Problem:	How to dynamically redefine the function keys on
;		a Kaypro using the new 'universal ROMs' without
;		running CONFIG and rebooting the machine.  EXKKEYS
;		does not support the U-ROM's, and AUTOKEYS 4.0, though
;		it claims to support them, does not work properly,
;		especially if you have changed your memory size
;		or installed a CCP replacement.
;
; Solution:	Edit the vector keys and function (keypad) keys
;		in the areas below to suit any given application
;		you may have in mind.  Assemble this program using
;		ASM, LASM or MAC; and name it anything you like.
;		Now you have a 1K .COM file that you can run just
;		prior to running some other program, to reset
;		the vector or keypad keys to anything you like.
;
; How it works:	The program uses the largely undocumented Kaypro
;		Universal ROM calls which are accessible by an
;		'extra' jump vector in the BIOS table, which is
;		located by examining the WBOOT vector at location
;		0 in memory.  Several other ROM calls are available
;		that are of use--look for documentation about them
;		from me in the future.
;
;					--Tim Farley
;					  Atlanta, GA
;
; Ascii equates
;
CTRL	EQU	1FH
;
CR	EQU	CTRL AND 'M'
LF	EQU	CTRL AND 'J'
bell	equ	7
;
FS	EQU	1CH	; Form separator, used for function keys
;
;
; Kaypro U-ROM equates
;
ROMJMP	EQU	037H	; Offset from start of BIOS that is a JMP
;			  leading directly into Kaypro ROM handler.
;
CFGOFF	EQU	03AH	; Offset from start of BIOS that is a word
;			  value (0224H in 2.2u1).  Add this to base
;			  of BIOS table to find CONFIG area.
;
ROMVER	EQU	0FFF8H	; ROM version # in ASCII (4 chars) at this
;			  location.  4 bytes sum up to byte following
;			  the string in 2.00+ ROM's.
;
;
; CP/M Equates
;
prstr	equ	9	; BDOS print string call
bdos	equ	5	; Standard CP/M entry
;
;
	ORG	100H
;
	JMP	START
;
; Here is where the Vector keys are defined.
;	One byte per key only, total of four bytes.
;
VECKEYS:
	DB	CTRL AND 'K'	; Up Arrow	(Default: 0BH, or ^K)
	DB	CTRL AND 'J'	; Down Arrow	(Default: 0AH, or ^J)
	DB	CTRL AND 'H'	; Left Arrow	(Default: 08H, or ^H)
	DB	CTRL AND 'L'	; Right Arrow	(Default: 0CH, or ^L)
;
; Here is a pre-built function key table.
;	Only define the key strings in the DB's starting
;	at KEY0: and proceeding to ENDKEY:, all the other
;	values are built automatically.
;
FNKEYS:
	DB	KEY1-KEY0,KEY0-FNKEYS
	DB	KEY2-KEY1,KEY1-FNKEYS
	DB	KEY3-KEY2,KEY2-FNKEYS
	DB	KEY4-KEY3,KEY3-FNKEYS
	DB	KEY5-KEY4,KEY4-FNKEYS
	DB	KEY6-KEY5,KEY5-FNKEYS
	DB	KEY7-KEY6,KEY6-FNKEYS
	DB	KEY8-KEY7,KEY7-FNKEYS
	DB	KEY9-KEY8,KEY8-FNKEYS
	DB	KEY10-KEY9,KEY9-FNKEYS
	DB	KEY11-KEY10,KEY10-FNKEYS
	DB	KEY12-KEY11,KEY11-FNKEYS
	DB	KEY13-KEY12,KEY12-FNKEYS
	DB	ENDKEY-KEY13,KEY13-FNKEYS
;
; Just modify the below strings to suit, any length such that total
;	length is less than 241 bytes (so complete table fits in
;	255 bytes).
;
KEY0:	DB	'0'	; 0 on keypad
KEY1:	DB	'1'	; 1 on keypad
KEY2:	DB	'2'	; 2 on keypad
KEY3:	DB	'3'	; 3 on keypad
KEY4:	DB	'4'	; 4 on keypad
KEY5:	DB	'5'	; 5 on keypad
KEY6:	DB	'6'	; 6 on keypad
KEY7:	DB	'7'	; 7 on keypad
KEY8:	DB	'8'	; 8 on keypad
KEY9:	DB	'9'	; 9 on keypad
KEY10:	DB	'-'	; Dash key on keypad
KEY11:	DB	','	; Comma key on keypad
KEY12:	DB	CR	; ENTER key on keypad
KEY13:	DB	'.'	; Period key on keypad
ENDKEY:	DB	0
;
;
; Actual start of program here, function table above for easy
;	patching and the like.
;
	ORG	FNKEYS+0100H
;
START:	lxi	d,signon
	mvi	c,prstr		; print sign-on to user
	call	bdos
;
; The code between here and the 'jz doit' is taken
;	from Kaypro's own PUTSYSU program, and is present
;	in several other universal-ROM utility programs.
;	It is the 'official' way to determine whether a
;	Kaypro has the a U-ROM installed.
;
	mvi	b,4		; 4 chars in string: '2.00'
	lxi	h,romver
	xra	a		; sum = 0 to start
next:	adc	m		; build checksum
	inx	h
	dcr	b		; next byte
	jnz	next
	cmp	m
	jz	doit		; Checksum matches--go ahead
;
;
	lxi	d,error		; Checksum did not match: wrong ROM!
	mvi	c,prstr		;	Print error and return to CCP
	call	bdos
	ret
;
signon:	db	cr,lf,'Replacing Kaypro CP/M 2.2u''s function keys....'
	db	cr,lf,'$'
;
error:	db	cr,lf,'ERROR!  Program requires 2.00 ROM or higher!',bell,'$'
;
;
; Now that we are sure that this is a 2.00+ ROM, let's
;	go ahead and do it.
;
doit:
	lhld	0001H		; get warm boot vector
	xra	a		; a=0
	mov	l,a		; set low byte to 0 (base of BIOS)
	mvi	e,romjmp	; offset to Kaypro ROM jump
	mov	d,a
	dad	d		; Add to BIOS base to find jump
	shld	jpat1+1		; Put address into first CALL
	shld	jpat2+1		;	and into second CALL
;
	lxi	b,veckeys	; BC points to vector keys (4 bytes)
	mvi	d,31H		; ROM function 31h: new vector keys
jpat1:	call	0		; <-- vector here gets patched above
;
	lxi	b,fnkeys	; BC points to function keys (255 bytes)
	mvi	d,32H		; ROM function 32h: new keypad keys
jpat2:	call	0		; <-- vector here gets patched above
;
	ret			; Return to CCP
;
	END	
§