;-----------------------------------------------------------------
; MXC-KC10.ASM
; clock overlay for mex and the Kenmore Computer Technologies (KCT)
; Ztime-I real-time clock.

rev	equ	12	;V 1.2

; V1.2  30 Aug 86 - Fixed Year storage to chip          - Rea Williams
; V1.1  26 Apr 85 - Added CSET routine			- Joe Griffith
; V1.0  24 Apr 85 - Original, TM-KCT11.ASM		- Joe Griffith

;--------------------------------------------------------------------
;     This overlay provides the current date and time to MEX+ or higher
; versions of MEX.  It is configured for the Kenmore Computer
; Technologies (KCT) Ztime-I real-time calendar/clock although it
; will probably work with any clock using the MM58167A clock chip.

no	equ	0	
yes	equ	0ffh
i8080	equ	yes		;for xlat- do not change
i8086	equ	no
cpm	equ	yes
pcdos	equ	no
cr	equ	13
lf	equ	10

mex	equ	0D00h		;address of the service processor
ilp	equ	240		;inline print
sblank	equ	244		;scan input stream to next non-blank (cy=end)
evala	equ	243		;evaluate number from input to HL
gnc	equ	241		;get next character
decout	equ	239		;decimal output from HL

bport	equ	0E0h		;base port address for KCT clock
				;this address should be changed to
				;reflect wherever your MM58167A is.
centry	equ	1900		;hard code since it is not available
				;from the clock chip

;--------------------------------------------------------------------
	
	org	100h		;processor type flag is here

if i8080
	db	0c3h		;show which processor we are for
endif
if i8086
	db	0E9h
endif

;-----------------------------------------------------------------
;   JMP table for clock overlay

	org	0e00h		;start of clock overlay 

	jmp	gettim		;get time
	jmp	getdat		;get date
	jmp	setclk		;cset processor
	ret			;clock overlay init
	nop
	nop
	ret			;clock overlay de-init
thisyr:	db	0		;this is actually the space reserved
				;for the address portion of the jmp
				;but no de-init is needed so the year
				;is stored here.  Note that the system
				;must be cloned after the clock is set
				;to permanently store the year here.
hlpflg:	db	0		;likewise the help flag is stored here

;--------------------------------------------------------------------
; subroutine GETTIM returns the time as follows:
;
; B - Hours (0-23)
; C - Minutes (0-59)
; D - Seconds (0-59)
; E - Hundreths of seconds (0-99) 

gettim:	in	bport+2		;get seconds
	push	psw		;save for future reference
	
	call	makbin		;make it a binary number
	mov	d,a		;store it
	in	bport+3		;get minutes
	call	makbin
	mov	c,a
	in	bport+4		;get hours
	call	makbin
	mov	b,a

	in	bport+2
	mov	l,a		;store it
	pop	psw		;get original seconds back
	cmp	l		;compare the two
	jnz	gettim		;not the same so do it over else
	mvi	e,0		;clear hundreds of seconds
	ret

;------------------------------------------------------------------------
; subroutine GETDAT returns the date as follows:
; 
; BC - Year (1985-2099)
; D - Month (1=January, 2=February, etc.)
; E - Day of month (1-31)

getdat:	in	bport+2		;get seconds
	push	psw		;save it for future reference

	in	bport+7		;get month
	call	makbin
	mov	d,a
	in	bport+6		;get day of month
	call	makbin
	mov	e,a

	in	bport+2		;get seconds again
	mov	l,a		;store temporarily
	pop	psw		;get original seconds
	cmp	l		;compare the two
	jnz	getdat		;if not the same do it over
	in      bport+9         ;get year 
	call	makbin
	mov	c,a		;put in it's proper place
	mvi	b,0
	lxi	h,centry	;load the century
	dad	b		;add it to the stored value
	mov	c,l		;move hl to bc
	mov	b,h
	ret

;-----------------------------------------------------------------
;  This routine takes the two BCD values in each nibble of the
; accumulator and converts it to a single binary value.

makbin:	push	d		;save the current value
	push	psw		;save the original value
	rrc			;put the 10s value in the lower bits
	rrc
	rrc
	rrc
	ani	0Fh		;mask off whatever is in the high nibble
	add	a		;multiply this register by 10
	mov	e,a
	add	a
	add	a
	add	e
	mov 	e,a		;save in e
	pop	psw		;get the original value
	ani	0Fh		;allow only low bits
	add	e		;get total to a
	pop	d		;restore de
	ret			;all done

;----------------------------------------------------------------------
;   CSET processor.  This routine allows the user to set the clock from
; command level by typing CSET yy/mm/dd hh:mm:ss.

setclk:	call	ilprt
	db	'KCT Clock OVR V'
	db	rev/10+'0','.'
	db	rev mod 10+'0'
	db	cr,lf,lf,0

	xra	a		;get a zero
	sta	hlpflg		;store it as a flag
	call	twobcd		;get the first two numbers
	rc
	out	bport+9		;put in the year
	call	twobcd		;get the month
	rc
	out	bport+7		;put in the months counter
	call	twobcd		;get the day of the month
	rc
	out	bport+6		;put in the day counter
	call	twobcd		;get the hour
	rc
	out	bport+4		;put in the hour counter
	call	twobcd		;get the minutes
	rc
	out	bport+3		;put in the minutes counter
	call	twobcd		;get the seconds
	rc
	out	bport+2		;put in the seconds counter
	ret

;------------------------------------------------------------------
;   this routine looks at the CSET parameter and returns with a BCD
; pair in the two nibbles of the accumulator.  Blanks and separators
; are skiped.  The carry flag is set when the end of the line is
; reached.

twobcd:	call	getnum		;get the 10's digit
	jc	chlp		;no numbers there
	rrc			;put it in the high nibble
	rrc
	rrc
	rrc
	push	psw		;save it
	call	getnum		;get the 1's
	mov	b,a		;temporary storage
	pop	psw		;get the 10s back
	ora	b		;merge the two
	ret

getnum:	mvi	c,gnc		;get the next character
	call	mex
	rc			;carry means there is no more input
	cpi	'0'
	jc	getnum		;char is smaller than ascii zero
	cpi	':'
	jnc	getnum		;char is not an ascii digit
	cmc			;reset carry flag
	sta	hlpflg
	sbi	'0'		;make it a binary value
	ret

chlp:	lda	hlpflg		;get the help flag
	cpi	0		;is it null
	stc			;flag the end
	rnz			;if not then don't print
	call 	ilprt
	db	'CSET YY/MM/DD HH:MM:SS'
	db	cr,lf,lf,0
	stc			;flag the system
	ret

;----------------------------------------------------------------------
; inline print routine

ilprt:	mvi	c,ilp
	jmp	mex

	end	
