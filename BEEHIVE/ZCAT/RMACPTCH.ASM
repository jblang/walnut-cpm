; RMACPTCH.ASM - 7/20/85
; Adapted by Bruce Morgen from Jay Sage's ingenious MACPATCH.ASM, this
; patch turns the RMAC assembler into a partial ZCPR3 utility.  When it
; runs, it automatically sets the program error flag in the message buffer
; to show whether or not RMAC encountered any errors in assembly.  The flow
; control command IF ERROR can then be used to control command flow.
;
; (NOTE: in the original distribution of SYSFCP.ASM there is an error that
; reverses the sensing of the program error flag.  You must either correct
; that error or use the reverse test IF ~ERROR.  The com file IF12.COM has
; the correct sensing {as does Jay's SYSFCP11.LBR package - b/m}.)
;
; BIG NOTE: The patched RMAC.COM must be installed by Z3INS.COM using a
; valid *.ENV file as a reference - neglect this and the patch will NOT
; work unless you are very lucky (your ENV load address would have to be
; DE00h).  The patch may be installed with MLOAD (version 2.1 or later)
; or a debugger like DDT, ZDM or SID.  I used MAC to assemble it, ASM
; would probably do in a pinch - b/m.
;
; Idea and all running code from MACPATCH.ASM by Jay Sage,
; sysop, Newton Centre (Massachusetts) Z-Node.

patch		equ	3024h		;place to intercept RMAC
conout		equ	2f78h		;address called at patch originally
newcode		equ	0150h		;place to put new flag setting code
rmcstart	equ	01a8h		;where RMAC code really begins
signon		equ	319ch		;location of signon message

cr		equ	0dh
lf		equ	0ah

;-----------------------------------------------------------------------------

; First we patch the beginning of the program to make it look like a ZCPR3
; utility program.  It can then be installed using Z3INS to know the address
; of the environment descriptor.  From that it can find the program error
; flag in the message buffer and patch it into the flag-setting code at
; at newcode.  The code patched in at 100h overwrites the copyright message.

		org	100h

		jmp	start

		db	'Z3ENV'
		db	1		;external environment
z3env:		dw	0de00h		;this address set by Z3INS

start:		lhld	z3env		;get env address into hl
		lxi	d,22h		;offset to message buffer address
		dad	d		;hl points to address of message buf
		mov	a,m		;read address out
		inx	h
		mov	h,m
		mov	l,a		;hl now points to start of message buf
		lxi	d,6		;offset to program error flag
		dad	d		;now hl points to program error flag
		mvi	m,0		;set it to no error status
		shld	store+1		;patch flag-setting code below
		jmp	rmcstart	;continue with original code

;-----------------------------------------------------------------------------

; We intercept RMAC execution at address PATCH.  The original instruction here
; was CALL CONOUT.  We replace it with a call to our new code, which in turn
; will jump to conout.

		org	patch

		call	newcode

;-----------------------------------------------------------------------------

; At NEWCODE, which is within a PIP-style patching area near the start
; of RMAC, we place the code to set the error flag.  This address is
; compatible with the George Blat and Sigi Kluger RMAC patches.

		org	newcode

		push	psw		;make sure we don't mess anything up
		mvi	a,0ffh		;value to set the flag
store:		sta	0		;address will be filled in by code
		pop	psw		;restore registers
		jmp	conout		;go to where RMAC went originally

;-----------------------------------------------------------------------------

; Just for the hell of it, patch the signon message to show it is a ZCPR3
; version.  Eighteen characters max, not including final mandatory carriage
; return.

		org	signon

		db	lf
		db	'Z3 REL/MACRO ASSEM',cr

		end
ters max, not includi