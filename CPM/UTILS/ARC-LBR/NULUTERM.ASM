;	NULUTERM.ASM	11/01/85
;
;	For NULU.COM Version 1.5
;
;	The NULU.DOC contains the information to patch NULU.COM
;	using DDT and the save command.  An easier way is to use
;	this routine and MLOADxx.COM.  Set the various items as
;	desired and assemble with ASM or MAC to obtain a hex file.
;	Then use MLOAD as follows:
;
;		MLOAD NEWFILE.COM=OLDFILE.COM,NULUTERM
;
;	NOTE: NULUTERM is the hex file NULUTERM.HEX.  The file
;	type extension is not necessary.
;
;		Keith W. Antcliff
;		P.O. Box 906
;		Mead, WA 99021
;		Northwest GodBout/CompuPro RCP/M (509) 624-6799
;		S.M.U.G. (509) 624-7321
;
; **************************************************************
; * 11/01/85	Revised for Version 1.5 (mm)
; * 01/25/85	Revised for Version 1.1 (kwa)                  *
; * 12/02/84	Added EQU's for Patch ORG's (kwa)              *
; **************************************************************
;
;	See NULU.DOC for further information on the following values.
;
;
true	equ	01h
false	equ	00h
;
patch1	equ	00163h	;Number of Characters etc.
patch2	equ	00167h	;Number of Open Files etc.
patch3	equ	0019ch	;BDOS Vector
patch4	equ	0021ch	;Some Toggles and Storage Area
patch5	equ	0024ch	;Terminal Control Area
patch6	equ	0026fh	;Number of Lines for LST
patch7	equ	00271h	;Printer Initialization Area
;

nl	equ	03	;Nesting Level for NCF files

	 org	patch1

	db	80	;Number of Characters each line can contain 
	db	80	;Number of Visible Characters/Line

	 org	patch2

	db	04h+nl	;Number of Open Files Allowed
	dw	0ch+nl	;Number of Relocatable Tasks
	db	16	;Number of Contiguously numbered drives
	db	32	;Number of Contiguous User Areas

	 org	patch3

	dw	5	;BDOS vector (See Doc)

	 org	patch4

	db	false	;NULU Read/Only
	db	false	;Exit like LU on command tail
	db	true	;BRIEF mode OFF
	db	true	;Allow ESC,RET from PROMPT etc.
	db	nl	;Nesting Level for NCF files
;
;	The following 39 bytes can be used to store any
;	valid NULU operators.  See NULU.DOC for details
;
	db	'-O',0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0
	db	0			;Terminator...Do Not Change

;
;	The following routines are for a TeleVideo 950 terminal.
;	Change to suit your terminal.  Use This Format:
;
;	ID byte,Number of Bytes,byte,byte,byte,byte,byte  ;7 bytes total
;	Do Not Change The ID Byte
;
	 org	patch5

	db	1,2,27,41,0,0,0		;Background Mode ON
	db	2,2,27,40,0,0,0		;Background Mode OFF
	db	3,3,27,71,56,0,0	;Underline ON
	db	4,3,27,71,48,0,0	;Underline OFF
	db	6,1,26,0,0,0,0		;Clear Screen

	 org	patch6

	db	60	;Number of lines/page for LST
			;0 to supress page formatting

;	Number of Bytes,byte,byte,byte,byte,byte,byte	;6 bytes total
;
	 org	patch7

	db	0,0,0,0,0,0		;Initialize Printer
ng

;	Num