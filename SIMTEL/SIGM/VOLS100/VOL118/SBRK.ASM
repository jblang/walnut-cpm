;
;	Rest of Full K&R alloc() and free() for AZTEC C II
;
;	This module copyright (c) 1982 William C. Colley III
;
; I grant Manx Software Systems permission to incorporate these functions
; into the AZTEC C library subject only to the condition that my copyright
; notice remain in the source code.  WCC3.
;
; See the module ALLOC.C for documentation.  To use this module, you must
; modify the AZTEC module CALLCPM.ASM by removing the definition of the
; location $MEMRY.  You also will save code if you remove their function
; xsettop()/xsbrk() as two of these functions will replace it.
;
		PUBLIC	xsettop_, xsbrk_, rsvstk_, $MEMRY

		CSEG

;******************************************************************************

xsettop_:	LXI	H, 4		;Fudge up a call to xsbrk() to allocate
		CALL	xsbrk1		;  the space.

		INX	H		;If xsbrk() returned -1, set the Z flag
		MOV	A, H		;  and return 0 as space was not
		ORA	L		;  available.
		RZ

		DCX	H		;If space was available, return a
		RET			;  pointer to the space.  Note that
					;  Z flag is cleared at this point.

xsbrk_:		LXI	H, 2		;Get size of block to allocate and
xsbrk1:		DAD	SP		;  compute end address of prospective
		MOV	E, M		;  block.
		INX	H
		MOV	D, M
		LHLD	$MEMRY
		DAD	D
		XCHG

		JC	xsbrk2		;If block wraps around top of memory,
					;  not enough space available.

		LHLD	safety		;Compute stack pointer less safety
		DAD	SP		;  margin -- i.e. top of memory.

		MOV	A, L		;If end address > top of memory,
		SUB	E		;  not enough space available.
		MOV	A, H
		SBB	D
		JC	xsbrk2

		LHLD	$MEMRY		;If space is available, allocate
		XCHG			;  the space, set Z flag on pointer,
		SHLD	$MEMRY		;  and return pointer to space.
		XCHG
		MOV	A, H
		ORA	L
		RET

xsbrk2:		XRA	A		;If not enough space, clear the Z flag
		DCR	A		;  and send back -1.
		MOV	H, A
		MOV	L, A
		RET

;******************************************************************************

rsvstk_:	LXI	H, 2		;Get new stack safety margin.
		DAD	SP
		MOV	A, M
		INX	H
		MOV	H, M

		CMA			;Negate and save it.
		MOV	L, A
		MOV	A, H
		CMA
		MOV	H, A
		INX	H
		SHLD	safety

		RET			;Return nothing in particular.

;******************************************************************************

		DSEG

safety:		DW	-1024		;Default value of safety margin.

		END
