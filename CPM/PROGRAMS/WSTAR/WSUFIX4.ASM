; WSUFIX VERSION 4 - 11/22/83 by:
;
;                            Ron Mozer
;                    Southwest Computer Center
;                      121 Wyatt Dr. Suite 7
;                      Las Cruces, NM 88001
;                      (505) 523-6037 RCP/M
;                      (505) 526-2842 Voice
;
;
; THIS PROGRAM IS TO BE OVERLAYED WITH WS.COM TO FIX THE PROBLEM
; WITH THE OVERLAY FILES BEING EXPECTED IN THE CURRENT USER.
;
;**NOTICE**NOTICE**  This patch for WS MUST be considered experimental at this
;	time.  It has been tested on a NorthStar Horizon and a Kaypro10 and
;	seems to work as advertised.  Please report any bugs, comments, or
;	suggestions for improvement to the RCP/M listed above or to the
;	Mesilla Valley RCP/M, (505) 522-8856.
;
;
; Known limitations:
;
;	1) The (R)un command has some restrictions that are caused by the fact
;	   that WS must be switched to DEFUSR and stay there while the .COM
;	   file is executing.  WS returns to the current(start up) user when
;	   the first .OVR file is opened upon return to normal WS operation.
;	   All .COM files to be run must be in DEFUSR and either DEFDRV or the
;	   current drive.  When executing programs such as COMPARE, HEXDIF, 
;	   BISHOW, etc. that require a filename input on the command line, 
;	   those files must be in DEFUSR on the CURRENT drive.  Directory
;	   programs such as SD will show the directory of the CURRENT drive and
;	   DEFUSR.  Calculator programs such as @ or ALLBASE, and disk util-
;	   ities such as DU seem to execute with no problem.  The latter are 
;	   the types of programs one would most likely want to (R)un under
;	   Wordstar. (The previous assumes operation under ZCPR2 with DEFUSR/
;	   DRV somewhere in the path.)
;
;	2) If you try to edit an .OVR or .COM file under Wordstar(who would
;	   want to do that?), the file will be created in the current drive/
;	   user, but then cannot be accessed again from that location.  The
;	   file, once created, must be in DEFUSR of the CURRENT drive before it
;	   can be accessed under WS.
;
;	3) This patch has not been tested with SPELSTAR.OVR.  It is expected
;	   that SPELSTAR.DCT would have to be in DEFUSR of the CURRENT drive
;	   for it to execute properly.  Who knows where the various work files
;	   would wind up.
; 	
;
; REVISION HISTORY
;
; 11/22/83  Changed logic to look for an .OVR or .COM filetype before switching
; VER #4    to DEFUSR.  In the case of .COM files, WS stays in DEFUSR while
;	    the program executes and then returns to the current user when the
;	    first .OVR file is again opened.  This allows limited use of the
;	    (R)un command.  Moved CURUSR and added COMFLG, both located in a
;	    safe memory location outside of the MORPAT area.  This area is
;	    overwritten when the (R)un commanbd is used.  Moved code that gets
;	    and saves the current user area to a separate routine invoked from
;	    INISUB.  The user area saved is that from which WS is invoked.
;	    Changed back to 8080 code which uses all but two bytes of MORPAT.
;	    (pwc).  Changed to use table driven compare routine.(Ron Mozer).
;
; 11/10/83  Fixed lots of bugs.  Made Z80 code and require MAC
; VER #3    to assemble. (Ron Mozer)
;
; 11/09/83  Changed to make compatible with all wordstars?
;	    of varied version numbers.  Still must make sure
; VER #2    you get the right address for INTERC. This code now
;	    needs to be simplified since there is only a couple of
;	    bytes left in MOPAT, thus no room to include spell star
;	    as one of the overlay files to check.
;						(Ron Mozer)
;
; 10/03/83  Orignal version 1 (Ron Mozer)
;
; All BDOS calls made by Wordstar except for normal I/O are intercepted
; and sorted out.  If the call is made to open the .OVR files the 
; intercept will set the user to DEFUSR.  After the BDOS returns, the
; intercept will set the user back to the current user. (See VER #4 notes above
; for change).
;
; This will allow those people who are running ZCPR, NZCPR, ZCPR2, etc,
; to have only one copy of wordstar on the system and be able to use
; it from any user/drive combination. (Very useful for hard disk machines)
;
; Care must be taken for those people who have already made major changes
; in wordstar.  The area at MORPAT is being used by this program to
; accomadate the intercept.  With VER #4, INISUB is also used.
;
; To implement this program, first edit this file to suit your needs,
; then assemble it with ASM.  You can then overlay this use DDT as follows:
;
; 	>DDT WS.COM
;	DDT VERS 2.2
;	NEXT  PC
;	3F00 0100
;	-IWSUFIX.HEX
;	-R
;	NEXT  PC
;	3F00 0000
;	-G0
;	>SAVE 62 WS.COM
;	
;
;************************ W A R N I N G **************************
; If you are using a non-standard CP/M (one that does not start the
; TPA at 100H such as TRS-80, HEATH H8, etc.) you will have to change
; MOPAT, INTERC, BDOS, DEFDSK and anything else that may conflict.
;*****************************************************************
;
DEFUSR	EQU	0AH	;User area which has the .OVR and .COM files
DEFDRV	EQU	1	;The default disk drive to test for
			;the .OVR and .COM files (A=1, B=2, etc.)

BDOS	EQU	5	;BDOS ENTRY POINT
USRCMD	EQU	32	;GET/SET USER COMMAND
OPEN	EQU	15	;OPEN FILE COMMAND

DEFDSK	EQU	02DCH	;location of DEFDSK in WS.COM
MORPAT	EQU	02E0H	;location of MORPAT (free space)
inisub	equ	02a4h	;location of inisub routine called on startup
INTERC	EQU	1824H	;location of intercept address. NOTE:
			;you should check this with your favorite
			;debuger to make sure that it is the LSB of
			;the BDOS entry point. INTERC-1 should be:
			; CD 05 00

;******************************************************************************

;NOTE*****  These locations must be in an unused area of memory.  DO NOT leave
;them in the morpat area as they are overwritten by WS when the (R)un command
;is used.

CURUSR	equ	0FE08H	;TEMP SAVE AREA for startup user area.
comflg	equ	0FE0AH	;location of COM file flag

;******************************************************************************

yes	equ	0ffh
no	equ	0

	org	inisub
	jmp	savusr  ;Save user area from which WS is invoked.

	ORG	DEFDSK
	DB	DEFDRV	;Set the default disk drive in WS.

	ORG	INTERC
	DW	PATCH	;INSTALL INTERCEPT PATCH

	ORG	MORPAT
PATCH	MOV	A,C	;GET COMMAND
	CPI	OPEN	;OPEN???
	JNZ	BDOS	;LET BDOS HAVE IT IF NOT
	push	h
	push	d
	push	b
	xchg		;get address of FCB in HL
	lxi	d,9
	dad	d	;point to filetype
	LXI	D,OVRNM ;Set up to compare filetype with OVR
	CALL	CMPARE	;check it
	JNZ	TRYCOM	;NO, check for COMfile
	mvi	a,no	;is OVR, so indicate not COM
	sta	comflg
	jmp	setdef	;is OVR so look in def drive/user

trycom	LXI	D,COMNM	;Set up to compare filetype with COM
	CALL	CMPARE	;check it
	JNZ	RETBDOS	;Not COM so do normal BDOS call
	mvi	a,yes	;is COM so set flag and fall through to setdef
	sta	comflg

setdef	pop	b
	pop	d
	pop	h
	MVI	A,DEFUSR	;SELECT DEFAULT USER
	CALL	USER
	CALL	BDOS	;PROCESS OPEN COMMAND
	PUSH	PSW
	lda	comflg	;If COM file, must stay in defusr until finished
	cpi	yes	;return to current du after next OVR file open.
	jz	stay
	LDA	CURUSR	;GET CURRENT USER BACK
	CALL	USER
	POP	PSW
	RET
;
USER	PUSH	B	;SAVE EVERYTHING IN SIGHT
	PUSH	D
	PUSH	H
	MOV	E,A
	MVI	C,USRCMD
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET

retbdos	pop	b
	pop	d	;restore registers
	pop	h
	jmp	bdos	;normal bdos call

stay	pop	psw	;get back open file result and stay in DEFUSR.
	ret

CMPARE	MVI	B,3	;CHECK THREE BYTES
CMPLP	LDAX	D	;WHAT WERE CHECKING AGAINST
	CMP	M	;WHAT WERE CHECKING
	RNZ		;NOT THE SAME
	INX	H	;POINT TO NEXT BYTE
	INX	D
	DCR	B	;DECREMENT COUNTER
	JNZ	CMPLP	;LOOP TILL DONE
	RET

OVRNM	DB	'OVR'
COMNM	DB	'COM'

;The following routine is jumped to from INISUB

savusr:	MVI	A,0FFH	;REQUEST USER NUMBER
	CALL	USER
	STA	CURUSR	;SAVE IT
	ret

	end
