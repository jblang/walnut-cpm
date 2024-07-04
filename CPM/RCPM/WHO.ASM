	TITLE	'Who -> Print name of current user logged in'
;
;	WHO is on the system?
;	Who will allow the system operator to simply type WHO on the console
;	and the system will respond by looking up the user.  This is just one
;	of the many programs incorporated in the OxGate BBS system.  If
;	you would like more information on the OxGate, feel free to call
;	(408) 867-1768 (voice) in the evenings (Pacific Time).
;	NB: Who will also work with RBBS.
;
;	Copyright (C) 1983 By Paul Traina - All rights reserved.
;	This program has been released for non-commercial useage.
;	This program may not be sold without the express written
;	conscent of the Author.
;
	MACLIB	SEQIO22			;Public domain macro library
;
FILAREA:	EQU	14		;User area that LASTCALR is in
FILDRIV:	EQU	'A'		;Drive where LASTCALR resides
;
;**************************************************************************
;	End of user modifiable section
;**************************************************************************
		PAGE
;
BDOS		EQU	0005h		;BDOS vector
LF		EQU	10		;Ascii line feed
CR		EQU	13		;Ascii carriage return
EOF		EQU	1Ah		;CP/M end of file

OUTPUT		EQU	6		;BDOS console output function
PRINT		EQU	9		;BDOS print string
BSIZE		EQU	80H		;Size of buffer
FILERR		SET	ERROR		;Error exit routine
BUFFERS		SET	DBUF		;Disk buffer to use
;
; The following allocations are used by the 'FILE' macros
;
	ORG	100h
	JMP	PSTART
	DB	'Who - Copyright (C) 1982 by Paul Traina',CR,LF,EOF
PSTART:	PUSH	B	;SAVE STACK AND REGISTERS
	PUSH	D
	PUSH	H
	LXI	H,0
	DAD	SP
	SHLD	STACK
	XRA	A	;This makes WHO re-entrant
	STA	COMMA
	JMP	START
;
DEFAULT$USER:	DB	FILAREA
CUR$USER:	DB	0FFh
DEFAULT$DISK:	DB	FILDRIV-'A'
CUR$DISK:	DB	0FFh
PGSIZE:		DW	0
;
START:	FILE	INFILE,CALLER,,LASTCALR,,BSIZE,,PUBLIC,TRUE
;
GETLOOP	GET	CALLER		;Get a character from the file
	CPI	EOF
	JZ	EXIT
	CPI	','		;Don't print the ',' between names
	JNZ	CHAROK
	LDA	COMMA		;only allow one comma
	INR	A		;this is so that we don't see the date
	CPI	2		;that is right after the last name
	JZ	EXIT		;this is all we should print, STOP
	STA	COMMA		;save new comma value
	MVI	A,' '		;and instead of a comma, print a space
CHAROK:	CALL	CONOUT
	JMP	GETLOOP
;
CONOUT:	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A		;move character to 'E' register
	MVI	C,OUTPUT	;tell BDOS to print it
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET

ERROR:	MVI	C,PRINT
	LXI	D,ERRMSG
	CALL	BDOS

EXIT:	LHLD	STACK		;restore the stack
	SPHL
	POP	H		;restore the registers
	POP	D
	POP	B
	RET			;return to the CCP
;
ERRMSG:	DB	'File error?$'

	DS	20h		;lots of stack space
STACK:	DW	0		;save stack vector here
COMMA:	DB	0		;number of comma's so far
;
DBUF:	EQU	$		;must be last in program, disk buffer
	END
