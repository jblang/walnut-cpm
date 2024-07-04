;
;
;     NEC 3550 Printer install for Wordstar ver 3.30.
;                    by Brad Harrison
; 	                 12/03/86
;
; NOTE: This patch will only work if you use the Wordstar Port driver.
;
; This patch allows Wordstar ver 3.3 to function correctly with
; a NEC 3550 printer. The WINSTALL program has a selection for
; the NEC-3550 but this definition is flawed. There are two
; basic errors in the NEC-3550 definition as supplied by Micropro:
;
;    1. The DRLF sequence is incorrect. This sequence is used to
;	reverse line feed a daisy wheel printer. The sequence
;	supplied is - 1B 0A <ESC LF>. This patch will correct the
;	sequence to 1B 37 <ESC 7>.
;
;    2. The NEC 3550 printer is unique in that it requires an escape
;	sequence after the VMI (vertical motion index) sequence.
;	WS 3.3 added the DVMITR area to accomplish this but when
;	it is used, Wordstar seems to lose track of the page length
;	and basically just doesn't work right. This patch will clear
;	out the DVMITR sequence so that WS will print correctly.
;	In order to send the VMI trailer sequence, the Wordstar port
;	driver will be changed to look at the characters being printed
;	and append a 1B 32 <ESC 2> after it finds a 1B 41 xx.
;
;	Example:				    (DVMITR)
;					<---->  --- VMI trailer sequence
;			1B   41   01   1B   42
;         VMI header --	<---->    ! 
;	  (DVMILE)		  !----- VMI value (0 to 56)
;
; INSTALLATION:
;    1. Use the WINSTALL program to set up wordstar. Install the NEC-3550
;	printer and use the port driver.
;    2. Change the DATOUT equate below to match the output port for
;	your printer. (should be the same value you used with WINSTALL)
;    3. Assemble this patch.  ex: ASM WS3550
;    4. Overlay the resulting hex file onto your installed WS COM file.
;	example:   MLOAD WS.COM=WS.COM,WS3550.HEX
;
DATOUT:	EQU	0F8H		; output port  ** HARDWARE DEPENDANT **
;
;
; change signon message	- show date of this mod
	ORG	1AEH
	DB	'NEC-3550 Printer   (12/03/86 BH)'
;
;
; ---- begin of WS port driver patch for NEC 3550
;	scan all outgoing characters to printer and when
;	a ESC,'A',x is found, append a ESC,'2' afterwards
	ORG	2BDH		; space in user1 for patch
NECOUT: EQU	$
	PUSH	A		; save registers
	PUSH	H
	PUSH	B
	LXI	H,NSTAT		; (HL) is our status flag
	MOV	C,A		; char to be sent in C
	LDA	NSTAT		; find out where we are
	ORA	A
	JZ	NEC00		; nstat=0 (looking for esc)
	CPI	1
	JZ	NEC01		; nstat=1 (looking for 'A')
; nstat must be a 2 - we need to append esc '2' after this char
	DCR	M		; put nstat back to 0
	DCR	M
	CALL	CHOUT
	MVI	C,ESC		; add on an ESC '2'
	CALL	CHOUT
	MVI	C,'2'
NEC99:	CALL	CHOUT		; send char and return
	POP	B		; restore registers
	POP	H
	POP	A
	RET			; back to the ws driver
;
; nstat must be a 0 - we need to look for ESC that begins ESC 'A'
NEC00:	EQU	$
	MOV	A,C
	CPI	ESC		; first thing to look for is esc
	JNZ	NEC99		; n - just send char
	INR	M		; y - change from 0 to 1
	JMP	NEC99		;     send char and return
;
; nstat must be a 1 - we found an ESC now check for 'A'
NEC01:	EQU	$
	DCR	M		; put back to 0 just in case
	MOV	A,C
	CPI	'A'
	JNZ	NEC99		; nstat is back to 0 : look for esc
	INR	M		; 0 --> 1
	INR	M		; 1 --> 2 
	JMP	NEC99
;
CHOUT:	CALL	POBSY		; printer busy?
	JC	CHOUT		; y- we will wait
	MOV	A,C		; get back the char to print
	OUT	DATOUT		; send the char
	RET
;
NSTAT:	DB	0		; 0= check for esc
				; 1= found esc, check for 'A'
				; 2= found esc and 'A' append after this chr
;
; ---- end of wordstar port driver patch
;
;
BS:	EQU	8			; backspace
LF:	EQU	10			; line feed	
FF:	EQU	12			; form feed	
CR:	EQU	13			; carriage return
DEL:	EQU	7FH			; delete or rubout
ESC:	EQU	01BH			; escape
;
;
; ********************************************************************
; we must modify the WS port driver so that it calls our
; extension which is located in USER1 (and listed above).	
;
POBSY:	EQU	727H			; port driver : status check
;
	ORG	732H			; port driver : character out
POSEND:	EQU	$
	CALL	NECOUT			; call our modified driver
	RET
;
; ----- daisy wheel printer stuff ------------------
; the nec 3550 driver normally has WS append a ESC '2' after
; a VMI sequence. WS doesn't do this correctly, so we blank
; out the VMI trailing sequence and let the printer driver
; (above) append the ESC '2'
;
	ORG	77FH
DVMITR:	DB	0
	DB	0,0,0,0
;
;
; this was just a bug in the NEC driver as supplied from MICROPRO
; The reverse line feed sequence shoud be 1B 37 <ESC 7>
;
; ----- fix up :drlf+2 from 0A to 37
	ORG	7ABH+2
	DB	'7'
;
	END
