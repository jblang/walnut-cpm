;
; 	CALLS.ASM	version 2.0  as of 05/11/82
;       By Dave Hardy
;
;
;  Print number of log-in attempts and log-ins.
;  For use with BYE.ASM to allow remote callers to
;  see number of log-ins and log-in attempts
;
;  Note that the addresses of the number of log-in attempts
;  and the number of log-ins must be hard coded into this program.
;
;Modification history
;05/10/82 Added "/R" option to allow number of callers to be reset
;	  By Dave Hardy
;
;  Define some miscellaneous values:
CR	EQU	0DH	;ASCII carriage return
LF	EQU	0AH	;ASCII linefeed
BDOS	EQU	5	;CP/M BDOS jump address
CONOUT	EQU	2	;CP/M BDOS CONSOLE OUTPUT function
PRNSTR	EQU	9	;CP/M BDOS PRINT STRING function
FCB	EQU	5CH	;CP/M FUNCTION CONTROL BLOCK address
;
;  You'll have to get the addresses of OLDUSR and NEWUSR from your
;  version of the BYE program (from a .PRN file or a .SYM file).
;  Then, plug them in here...
OLDUSR	EQU	0E6F4H	;Address of LOG-IN attempts counter in BYE program
NEWUSR	EQU	0E6F5H	;Address of LOG-IN counter in BYE program
;
	ORG	0100H	;for standard CP/M, change if you have ALTCPM
;
;  Check for /R option on command - request to reset counters
	LXI	H,FCB+1 ;Look for option
	MOV	A,M
	CPI	'/'	;Is it there?
	JNZ	TELL	;Jump if not there
;  Option is there, so check to see if it's valid
	INX	H	;Point to option character
	MOV	A,M
	CPI	'R'	;See if it's the right character
	JNZ	TELL	;Jump if no
;  Proper option given, so reset counters
	XRA	A	;Reset counters to 0
	STA	OLDUSR
	STA	NEWUSR
	RET		;Return to CP/M
;
;  Tell how many calls and attempts
TELL	LDA	OLDUSR	;Get number of log-in attempts
	CALL	HXNUM	;Print it
	LXI	D,NATMP	;Print message telling what it is
	MVI	C,PRNSTR
	CALL	BDOS
;
	LDA	NEWUSR	;Get number of log-ins
	CALL	HXNUM	;Print it
	LXI	D,NCALL	;Print message telling what it is
	MVI	C,PRNSTR
	CALL	BDOS
	RET		;Return to CP/M
;
;  Subroutine to print the number in A as 2 ASCII characters on the screen
;
HXNUM	PUSH	PSW	;Save the character for second part
	ANI	0F0H	;Get first digit of number
	RRC
	RRC
	RRC
	RRC
	ADI	'0'	;Make it ASCII 
	MOV	E,A
	MVI	C,CONOUT
	CALL	BDOS	;Print it via BDOS CONOUT function
	POP	PSW	;Get second digit of number
	ANI	0FH
	ADI	'0'	;Make it ASCII
	MOV	E,A
	MVI	C,CONOUT
	JMP	BDOS	;Print it, too 
;
NATMP	DB	' attempted log-ins',CR,LF,'$'
NCALL	DB	' successful log-ins',CR,LF,'$'
;
	END
