;PATVLU  version 1.0  01/11/88

;This file patches VLU101-D.COM so that it will run on a non-ZCPR3 system.
;It was put together from Z3BASE2.LIB and SYSENV.LIB.  What it does is to
;tack the environment descriptor onto the end of VLU and patch a couple of
;addresses to keep VLU happy.  The file is currently set up for an Osborne I
;so unless that's the computer that you're using you will want to change the
;terminal stuff starting at the label 'envorg2'.  Make sure that you don't
;change the size of the code before CL string.  The code can be variable
;length after that, with a 0 terminator on each string.  You may also want
;to change things like the maximum disk and screen size.  After you've made
;the necessary changes, just ASM and MLOAD.

;Thanks to Steve Greenberg and Ben Grey for their help.
;	enjoy
;		Bob Schultz


;================================================================
; Update 1/17/88					 v. blade

false	equ	0
true	equ	not false

; Now capable of patching dim- or reverse-video version of VLU for
; Osborne I, Kaypro II, Kaypro 4/10/2X, Epson QX-10, Commodore 128
; or TVI955.  Though these are the only equates provided, notice
; that many terminals share the same video commands.  For example,
; the Osborne I, Epson QX-10, Qume QVT-102, TVI912, TVI920, and
; C-128 are exactly the same as far as VLU is concerned.  The TVI955
; (and TVI905) differ only in the clear screen sequence.	vb

dimvideo	equ	false

OsborneI	equ	false		;elect only one
KayproII	equ	false
Kaypro2X	equ	true		;4/10/2X
EpsonQX		equ	false
C128		equ	false
TVI955		equ	false



; EXTERNAL PATH
;
;	The following equates define the address of the ZCPR3 External
; Path and the number of two-byte elements contained in this path (maximum).
; If there is no ZCPR3 External Path, both of these values should be set to 0.
;
EXPATH	EQU	0	; EXTERNAL PATH
EXPATHS	EQU	0	;  (PATH SIZE = EXPATHS*2 + 1)

; WHEEL BYTE
;
;	The following equate defines the address of the ZCPR3 Wheel Byte.
; If there is no ZCPR3 Wheel Byte, this value should be set to 0.
;
Z3WHL	EQU	0	; WHEEL BYTE ADDRESS

; RCP LOCATION
;
;	The following equates define the address of the ZCPR3 Resident
; Command Package and its size in 128-byte blocks.  If there is no
; ZCPR3 Resident Command Package, both of these values should be 0.
;
RCP	EQU	00000H	; RESIDENT COMMAND PACKAGE
RCPS	EQU	00	; 00 128-byte Blocks (0K bytes)

; IOP LOCATION
;
;	The following equates define the address of the ZCPR3 Input/Output
; Package and its size in 128-byte blocks.  If there is no ZCPR3 Input/Output
; Package, both of these values should be 0.
;
IOP	EQU	00000H	; REDIRECTABLE I/O PACKAGE
IOPS	EQU	00	; 00 128-byte Blocks (0K bytes)

; FCP LOCATION
;
;	The following equates define the address of the ZCPR3 Flow Command
; Package and its size in 128-byte blocks.  If there is no ZCPR3 Flow Command
; Package, both of these values should be 0.
;
FCP	EQU	00000H	; FLOW COMMAND PACKAGE
FCPS	EQU	0	; 0 128-byte Blocks (0K bytes)

; ENV LOCATION
;
;	The following equates define the address of the ZCPR3 Environment
; Descriptor and its size in 128-byte blocks.  If there is no ZCPR3 Environment
; Descriptor, both of these values should be 0.
;
;**************************************************
;***		DON'T change this		*** 
;**************************************************

	 if dimvideo
z3env	equ	03e19h	; environment descriptor
	 else
z3env	equ	03dcbh
	 endif

z3envs	equ	2	; size of environment descriptor in 128-byte blocks

; SHELL STACK
;
;	The following equates define the address of the ZCPR3 Shell Stack,
; the number of entries permitted in the ZCPR3 Shell Stack, and the size
; of each entry in the Shell Stack in terms of bytes.  If there is no ZCPR3
; Shell Stack, all three values should be 0.
;
SHSTK	EQU	0	; ZCPR3 SHELL STACK
SHSTKS	EQU	0	; NUMBER OF SHSIZE-BYTE SHELL STACK ENTRIES
SHSIZE	EQU	0	; SIZE OF A SHELL STACK ENTRY
			;   (STACK SIZE = SHSTKS * SHSIZE)

; ZCPR3 MESSAGES
;
;	The following equate defines the address of the ZCPR3 Message Buffer.
; This buffer is always 80 bytes long.  If there is no ZCPR3 Message Buffer,
; this address should be 0.
;
Z3MSG	EQU	0	; ZCPR3 MESSAGE BUFFER

; EXTERNAL FCB
;
;	The following equate defines the address of the ZCPR3 External FCB.
; This buffer is always 36 bytes long.  If there is no ZCPR3 External FCB,
; this address should be 0.
;
EXTFCB	EQU	0	; ZCPR3 EXTERNAL FCB

; NAMED DIRECTORY BUFFER
;
;	The following equates define the address and size (in terms of 18-byte
; entries) of the ZCPR3 Named Directory Buffer.  If there is no such buffer,
; both of these values should be 0.
;
Z3NDIR	EQU	0	; ZCPR3 NAMED DIRECTORY AREA
Z3NDIRS	EQU	0	; 14 18-byte Named Directory Elements permitted
			;   (NDIR SIZE = Z3NDIRS*18 + 1 for trailing 0)

; COMMAND LINE
;
;	The following equates define the address and size (in terms of bytes)
; of the ZCPR3 Command Line Buffer (formerly called the Multiple Command Line
; Buffer under ZCPR2).  If there is no such buffer, both of these values should
; be 0.
;
Z3CL	EQU	0	; ZCPR3 COMMAND LINE BUFFER
Z3CLS	EQU	0	; SIZE OF COMMAND LINE BUFFER

; EXTERNAL STACK
;
;	The following equate defines the address of the ZCPR3 External Stack.
; This stack is always 48 bytes in size.  If there is no such stack, this
; value should be 0.
;
EXTSTK	EQU	0	; ZCPR3 EXTERNAL STACK



	org	109h
	dw	z3env		;patch envptr

	 if dimvideo
	org	0127ch		;patch free memory pointer
	 else
	org	01244h
	 endif

	dw	z3env+z3envs*80h


;
;  Environment Descriptor
;	If inline, there is a leading JMP just before this
;
	org	z3env

	ds	3
envorg1:
	db	'Z3ENV'		; Environment ID
	db	2		; class 2 environment (internal)

	dw	expath		; external path address
	db	expaths		; number of 2-byte elements in path

	dw	rcp		; RCP address
	db	rcps		; number of 128-byte blocks in RCP

	dw	iop		; IOP address
	db	iops		; number of 128-byte blocks in IOP

	dw	fcp		; FCP address
	db	fcps		; number of 128-byte blocks in FCP

	dw	z3ndir		; NDR address
	db	z3ndirs		; number of 18-byte entries in NDR

	dw	z3cl		; ZCPR3 Command Line
	db	z3cls		; number of bytes in Command Line

	dw	z3env		; ZCPR3 Environment Descriptor
	db	z3envs		; number of 128-byte blocks in Descriptor

	dw	shstk		; Shell Stack address
	db	shstks		; number of shsize-byte entires in Shell Stack
	db	shsize		; size of a Shell Stack entry

	dw	z3msg		; ZCPR3 Message buffer

	dw	extfcb		; ZCPR3 External FCB

	dw	extstk		; ZCPR3 External Stack

	db	0		; quiet flag (1=quiet, 0=not quiet)

	dw	z3whl		; address of Wheel Byte

	db	4		; Processor Speed in MHz

	db	'C'-'@'		; maximum disk
	db	31		; maximum user

	db	1		; 1=OK to accept DU, 0=not OK

	db	0		; CRT selection (0=CRT 0, 1=CRT 1)
	db	0		; Printer selection (n=Printer n)

	db	80		; width of CRT 0
	db	24		; number of lines on CRT 0
	db	24		; number of lines of text on CRT 0

	db	128		; width of CRT 1
	db	24		; number of lines on CRT 1
	db	24		; number of lines of text on CRT 1

	db	80		; width of Printer 0
	db	66		; number of lines on Printer 0
	db	58		; number of lines of text on Printer 0
	db	1		; form feed flag (0=can't formfeed, 1=can)

	db	102		; width of Printer 1
	db	66		; number of lines on Printer 1
	db	58		; number of lines of text on Printer 1
	db	1		; form feed flag (0=can't formfeed, 1=can)

	db	80		; width of Printer 2
	db	66		; number of lines on Printer 2
	db	58		; number of lines of text on Printer 2
	db	0		; form feed flag (0=can't formfeed, 1=can)

	db	102		; width of Printer 3
	db	66		; number of lines on Printer 3
	db	58		; number of lines of text on Printer 3
	db	0		; form feed flag (0=can't formfeed, 1=can)

	db	'SH      '	; shell variable filename
	db	'VAR'		; shell variable filetype

	db	'        '	; filename 1
	db	'   '		; filetype 1

	db	'        '	; filename 2
	db	'   '		; filetype 2

	db	'        '	; filename 3
	db	'   '		; filetype 3

	db	'        '	; filename 4
	db	'   '		; filetype 4

	ds	80H-($-envorg1+3)	; make exactly 80H bytes long
					; (+3 compensates for leading JMP)
;
; Terminal Capabilities Data
;
envorg2:
	 if OsborneI or EpsonQX or TVI955 or C128

	 if OsborneI
	DB	'Osborne I       '	;Name of Terminal
	 endif
	 if EpsonQX
	DB	'QX-10 Epson     '
	 endif
	 if TVI955
	DB	'TVI955          '
	 endif
	 if C128
	DB	'C128 Commodore  '
	 endif

	DB	'K'-'@'			;Cursor UP
	DB	'J'-'@'			;Cursor DOWN
	DB	'L'-'@'			;Cursor RIGHT
	DB	'H'-'@'			;Cursor LEFT
	DB	00			;CL Delay
	DB	00			;CM Delay
	DB	00			;CE Delay
	 if TVI955
	DB	1bh,'+',0
	 else
	DB	1ah,0			;CL String   clear screen
	 endif ;TVI955
	DB	1bh,'=%+ %+ ',0		;CM String   cursor addressing
	DB	1bh,'T',0		;CE String   clear to end of line
	DB	1bh,')',0		;SO String   into highlighting
	DB	1bh,'(',0		;SE String   exit highlighting
	DB	0			;TI String   terminal initialization
	DB	0			;TE String   terminal deinitialization

	 endif ;OsborneI or EpsonQX or TVI955 or C128

	 if KayproII or Kaypro2X

	 if Kaypro2X
	DB	'KP-10 Kaypro 10 '
	 else
	DB	'KP-2 Kaypro II  '	;Name of Terminal
	 endif ;Kaypro2X

	DB	'K'-'@'			;Cursor UP
	DB	'J'-'@'			;Cursor DOWN
	DB	'L'-'@'			;Cursor RIGHT
	DB	'H'-'@'			;Cursor LEFT
	DB	00			;CL Delay
	DB	00			;CM Delay
	DB	00			;CE Delay
	DB	1ah,0			;CL String   clear screen
	DB	1bh,'=%+ %+ ',0		;CM String   cursor addressing
	DB	18h,0			;CE String   clear to end of line
	 if Kaypro2X
	 if dimvideo
	DB	1bh,'B1',0		;SO String   into highlighting
	DB	1bh,'C1',0		;SE String   exit highlighting
	 else
	DB	1bh,'B0',0		;you don't really like inverse-video
	DB	1bh,'C0',0		;do you?
	 endif ;dimvideo
	 else
	DB	0			;SO String   into highlighting
	DB	0			;SE String   exit highlighting
	 endif ;Kaypro2X
	DB	0			;TI String   terminal initialization
	DB	0			;TE String   terminal deinitialization

	 endif ;KayproII of Kaypro2X

	 if 0	;model tcap for those who still need to build their own

	DB	'Terminal name   '	;16 characters

					;arrow keys, one byte each
	DB	'K'-'@'			;Cursor UP
	DB	'J'-'@'			;Cursor DOWN
	DB	'L'-'@'			;Cursor RIGHT
	DB	'H'-'@'			;Cursor LEFT

					;delays for cursor routines
	DB	00			;CL Delay
	DB	00			;CM Delay
	DB	00			;CE Delay

					;cursor routines, 0 terminated
	DB	1ah,0			;CL String   clear screen
	DB	1bh,'=%+ %+ ',0		;CM String   cursor addressing
	DB	18h,0			;CE String   clear to end of line
	DB	1bh,'B1',0		;SO String   into highlighting
	DB	1bh,'C1',0		;SE String   exit highlighting
	DB	0			;TI String   terminal initialization
	DB	0			;TE String   terminal deinitialization

; cursor addressing sequence:
; %    represents the row and column coordinates (first one is row)
; %+c  add offset c to coordinate ('%+ ' adds a space, 20h, to coordinate)
; %d   output coordinate as decimal characters (as many as needed)
; %2   output coordinate as two decimal characters
; %3   output coordinate as three decimal characters
;
; the following codes affect interpretation of the entire string and
; may appear anytime before the first coordinate
; %i   increment, home position is (1,1) instead of (0,0)
; %r   reverse, send column figure first
;
; %%   send '%' character
;
; example:  1bh,'[%i%d;%dH'  translates as   esc  [   1   ;   1   H
;					     1bh 5bh 31h 3bh 31h 48h
;           1bh,'=%+ %+ '    translates as   esc  =           
;					     1bh 3dh 20h 20h
;
; Of course, you could get Z3TCAP26.LBR and look in the source code,
; but what fun would that be?

	 endif ;0

	ds	80H-($-envorg2)		; make exactly 80H bytes long

;
;  End of Environment Descriptor
;

; The following code change corrects an intermittent bug that could
; inhibit constructing libraries under ZCPR3 and standard CP/M.
; It sacrifices nothing under ZCPR33.
;								vb

	 if dimvideo
	org	00d44h
	call	02776h
	 else
	org	00d17h
	call	02728h
	 endif


	end
