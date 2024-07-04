
              -[ From Seattle's 'downspout' - 206-325-1325 ]-

This code documents a method of modifing ZCPR3 to recognise that it has
loaded a ZCPR3 installable utility and "auto-install" it by loading the
environment address at the correct place in the TPA.

Search the ZCPR3 source file for the label "EXECADR:" and insert the code
shewn below.  Note that all additional code is commented thus ";+ "...

		; RUN LOADED TRANSIENT PROGRAM
		CALL	DEFDMA		; SET DMA TO 0080

		; 
		; attempt to install z3env utilities...
		ld	hl,0100h	;+ point to position of z3env id.
		ld	de,idstring	;+ point to z3env descriptor string.
		ld	b,idlength	;+ reg b will count bytes
z3test:		ld	a,(de)		;+ get a byte for compare...
		cp	(hl)		;+ ...match against code...
		jr	nz,noz3env	;+ ...branch if not installable.
		inc	hl		;+ bump pointers...
		inc	de		;+ ...
		djnz	z3test		;+ branch until all bytes match.
		; tpa contains an installable utility...
		ld	(hl),low z3env	;+ load environment address...
		inc	hl		;+ ...
		ld	(hl),high z3env	;+ ...		
		; 
		; EXECUTION (CALL) OF PROGRAM (SUBROUTINE) OCCOURS HERE
EXECADR:	EQU	$+1		; CHANGE ADDRESS FOR IN-LINE CODE MODIFICATION
noz3env:	CALL	0100H		; CALL TRANSIENT
		; zcpr3 code continues....


		; Insert z3 environment id string in any convenient place.
idstring:	defb	"Z3ENV",01	;+ z3 environment id.
idlength	equ	$-idstring	;+ 

<eof>
