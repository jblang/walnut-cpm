;************************************
;*				    *
;*  QUICK TYPE II		    *
;*  VERSION (see below) 	    *
;*  A TYPEWRITER UTILITY	    *
;*  BY ROGER GAGNON  04/01/85	    *
;*  LANSING TECHNICAL DOWNLOAD	    *
;*  (517) 694-8650 (RB) 	    *
;*				    *
;************************************
;
PREFIX	EQU	'1'	;major version number
SUFFIX	EQU	'1'	;minor revision number
;
;   v 1.1  4/18/84  Added NEC-8023A codes and slightly
;   modified some comments to make it easier for other
;   adaptations.  Changed max line length from 80 to 136
;   to allow smaller type sizes to be used to their full
;   extent.  Robert J. Sandel
;
;
; THIS PROGRAM ENABLES THE CONSOLE TO OPERATE AS A DIRECT
; OUTPUT TYPEWRITER. LINES CAN BE EDITED BEFORE PRINTING.
; PRINTER SETUP CODES CAN ALSO BE PASSED BY SIMPLY TYPING
; THE CONTROL KEYS AT THE KEYBOARD AND PRESSING RETURN. A
; HANDY UTILITY FOR NOTES, ENVELOPES, AND LABELS.
;
	ORG	100H
	JMP	PROGRAM
;
; **** GENERAL EQUATES ****
;
maxbuf	equ	136		;was originally 80
BDOS	EQU	05H		;STANDARD CALL TO OPERATING SYSTEM
INSTR	EQU	0AH		;READ CONSOLE BUFFER
OUTSTR	EQU	09H		;PRINT STRING
OUTCHR	EQU	02H		;CONSOLE OUTPUT
CR	EQU	0DH		;ASCII CODE FOR CR
LF	EQU	0AH		;ASCII CODE FOR LF
TRUE	EQU	01H		;VALUE FOR TRUE
FALSE	EQU	00H		;VALUE FOR FALSE
TEMP	DS	1		;TEMPORARY STORAGE SPACE
;
; **** PRINTER TAB INITIALIZATION ****
;
; THE FOLLOWING EQUATES SELECT ANY NECESSARY PRINTER TAB CODES
; AND SCREEN MESSAGES. SOME PRINTERS DON'T REQUIRE ANY SPECIAL
; CODES. SET PRINTER TO TRUE THEN SET SELECTED PRINTER TO TRUE.
; ALSO SET THE POINTER TO THE CORRECT PRINTER MESSAGE IN THE
; 'DISPLAY CODES' SECTION.
;
PRINTER	EQU	TRUE		;SET TO TRUE IF  A PRINTER IS SELECTED
PROWRTR	EQU	FALSE		;SET TO TRUE FOR C.ITOH PRINTERS
NEC8023	EQU	TRUE		;SET TO TRUE FOR NEC-8023A PRINTER
GEMINI	EQU	FALSE		;SET TO TRUE FOR GEMINI 10X PRINTERS
;
; **** MAIN PROGRAM ****
;
PROGRAM	CALL	CRLF		;PRINT CARRIAGE RETURN & LINEFEED
	MVI	C,OUTSTR	;PUT FUNCTION # IN C REG
	LXI	D,MSG1		;POINTER TO MESSAGE
	CALL	BDOS		;PRINT IT!
	CALL	CRLF		;PRINT A BLANK LINE ON CONSOLE
;
; **** ROUTINE TO INSTALL PRINTER TAB CODES ****
;
IF	PRINTER
;
	LXI	H,INITSTR+2	;SET UP HL PAIR AND B
	LDA	INITSTR+1	;GET LENGTH OF SET UP STRING
	MOV	B,A		;GOES IN B
OVER	MVI	C,05H		;SEND CHARACTER TO PRINTER
	MOV	E,M		;GET CHARACTER FROM BUFFER
	INX	H		;INCREMENT POINTER
	PUSH	H		;SAVE H REGISTER
	PUSH	B		;SAVE B REG.
	CALL	BDOS		;DO IT!
	POP	B		;RESTORE B
	POP	H		;RESTORE H
	DCR	B		;CHECK IF DONE. DECREMENT COUNT
	JNZ	OVER		;NOT DONE, GET ANOTHER CHARACTER
	JMP	GETCHR		;GET ON WITH THE PROGRAM
;
ENDIF
;
;
IF	PROWRTR
;
INITSTR	DB	42,39,27,40,48,48,56,',',48,49,54,',',48,50,52,','
	DB	48,51,50,',',48,52,48,',',48,52,56,',',48,53,54,','
	DB	48,54,52,',',48,55,50,'.',CR
;
ENDIF
;
;
IF	NEC8023
;
INITSTR	DB	INEND-$-1	;max number of bytes in string
	DB	INEND-$		;actual number of bytes
	DB	11H		;select code
	DB	1BH,5BH,1BH,'E'	;incremental and Elite
		;:::Tab settings below:::
	DB	27,40,	     48,48,56,',',48,49,54,',',48,50,52,','
	DB	48,51,50,',',48,52,48,',',48,52,56,',',48,53,54,','
	DB	48,54,52,',',48,55,50,',',48,56,48,',',48,56,56,','
	DB	48,57,54,',',49,48,52,',',49,49,50,',',49,50,48,','
	DB	49,50,56,'.'
INEND	DB	CR

;
ENDIF
;
IF	GEMINI
;
INITSTR	DB	0,0,0,0,0,0	;ECT........
;
ENDIF
;
; **** INPUT AND RESPONSE LOOP ****
;
GETCHR	MVI	A,maxbuf	;SET MAX BUFFER LENGTH TO xx COLUMNS
	STA	INBUF		;STICK IT IN BUFFER
	MVI	A,CR		;SEED BUFFER WITH A CARRIAGE RETURN
	STA	INBUF+2
	MVI	A,00H		;INITIALIZE STORAGE AREA
	STA	TEMP
	MVI	C,INSTR		;CALL READ CONSOLE BUFFER
	LXI	D,INBUF		;BUFFER ADDRESS
	CALL	BDOS
;
; **** CHECK IF INPUT IS A SPECIAL COMMAND CODE ****
;
	LXI	H,INBUF+2	;GET THE INPUT CHARACTER ADDRESS
	MOV	A,M		;MOVE IT INTO A REG
	CPI	0DH		;IS IT A CARRIAGE RETURN?
	JZ	NEWLINE		;DO A LINEFEED
	CPI	3FH		;IS IT A QUESTION MARK?
	JZ	HELP		;PRINT HELP MESSAGE
	CPI	19H		;IS IT FOR CLEAR SCREEN?
	JZ	CLRSCRN		;CLEAR THE SCREEN
	CPI	01H		;IS IT FOR RULER LINE?
	JZ	RULER		;PRINT RULER
;
IF	PRINTER
;
	CPI	1AH		;IS IT FOR PRINTER CODES DISPLAY?
	JZ	CODES		;DISPLAY PRINTER CODES
;
ENDIF
;
	CPI	09H		;IS IT A TAB CHARACTER?
	JZ	TYPE		;PROCEEDE TO PRINT IF SO
	MVI	B,1FH		;IS INPUT A PRINTER CODE?
	ORA	B		;MASK FOR CONTROL CODES
	CPI	1FH
	JNZ	TYPE		;SKIP IF NOT
	MVI	A,01H		;OTHERWISE STORE YES INTO TEMP
	STA	TEMP
;
; **** SEND INPUT STRING TO PRINTER ****
;
TYPE	LXI	H,INBUF+2	;SET UP HL PAIR AND B
	LDA	INBUF+1		;NUMBER OF CHARACTERS TYPED
	CPI	00H		;ANYTHING TYPED?
	JZ	NEWLINE		;IF NOT, DO A LINEFEED
	MOV	B,A		;GOES IN B
AGAIN	MVI	C,05H		;SEND CHARACTER TO PRINTER
	MOV	E,M		;GET CHARACTER FROM BUFFER
	INX	H		;INCREMENT POINTER
	PUSH	H		;SAVE H REGISTER
	PUSH	B		;SAVE B REG.
	CALL	BDOS		;DO IT!
	POP	B		;RESTORE B
	POP	H		;RESTORE H
	DCR	B		;CHECK IF DONE. DECREMENT COUNT
	JNZ	AGAIN		;NOT DONE, GET ANOTHER CHARACTER
	LDA	TEMP		;WAS IT A PRINTER SETUP STRING?
	CPI	01H		;COMPARE TO YES
	JZ	ERALINE		;ERASE INPUT LINE
NEWLINE	MVI	C,5		;DONE. TYPE LINEFEED
	MVI	E,LF
	CALL	BDOS
	;
IF NEC8023
	MVI	C,5		;TYPE CARRIAGE RETURN
	MVI	E,CR		;NEC PRINT COMMAND &
	CALL BDOS		;CARRIAGE RETURN
ENDIF
	;
	CALL	CRLF		;PRINT CR, LF ON CONSOLE
	JMP	GETCHR		;GO ANOTHER ROUND
;
; **** PRINT CHARACTERS TO CONSOLE ****
;
PUTCHR	MVI	C,OUTCHR	;BDOS FUNCTION #2
	MOV	E,A		;MOVE CHAR. TO E REG
	CALL	BDOS		;PRINT IT
	RET
;
; **** CARRIAGE RETURN AND LINEFEED TO CONSOLE ****
;
CRLF	MVI	A,CR
	CALL	PUTCHR
	MVI	A,LF
	CALL	PUTCHR
	RET
;
; **** DISPLAY HELP MESSAGE ****
;
HELP	MVI	C,OUTSTR	;PUT FUNCTION # IN C REG
	LXI	D,MSG2		;POINTER TO HELP MESSAGE
	CALL	BDOS		;PRINT IT!
	CALL	CRLF		;PRINT A BLANK LINE ON CONSOLE
	JMP	GETCHR		;BACK TO INPUT LOOP
;
; **** DISPLAY PRINTER CODES ****
;
IF	PRINTER
;
CODES	MVI	C,OUTSTR	;PUT FUNCTION # IN C REG
	LXI	D,PWRT		;**** SET TO CORRECT PRINTER MESSAGE ****
	CALL	BDOS		;PRINT IT!
	JMP	GETCHR		;BACK TO INPUT LOOP
;
ENDIF
;
; **** DISPLAY RULER LINE ON CONSOLE ****
;
RULER	MVI	C,OUTSTR	;PUT FUNCTION # IN C REG
	LXI	D,MSG5		;POINTER TO RULER
	CALL	BDOS		;PRINT IT!
	JMP	GETCHR		;BACK TO INPUT LOOP
;
; **** PRINT A BLANK LINE ON CONSOLE ****
;
ERALINE	MVI	C,OUTSTR	;PUT FUNCTION # IN C REG
	LXI	D,MSG6		;POINTER TO BLANK LINE
	CALL	BDOS		;DO IT!
	JMP	GETCHR		;BACK TO DOIN' IT
;
; **** CLEAR SCREEN SEQUENCE ****
;
CLRSCRN	MVI	C,OUTSTR	;PUT FUNCTION # IN C REG
	LXI	D,MSG3		;POINTER TO CLEAR SCREEN
	CALL	BDOS		;DO IT!
	JMP	GETCHR		;BACK TO DOIN' IT
;
; **** MESSAGES ****
;
; SIGN ON MESSAGE
;
MSG1	DB	'Quick Type II   Version ',prefix,'.',suffix,CR,LF
	DB	'Use CTL-C to exit, ? for HELP',CR,LF
	DB	'$'
;
; HELP MESSAGE
;
MSG2	DB	CR,LF,LF,LF,LF,LF
	DB	'                 Quick Type II',CR,LF
	DB	'                 Version  ',prefix,'.',suffix
	DB	CR,LF,LF,LF
	DB	'    This program allows the use of the console',CR,LF
	DB	'as a direct output typewriter. Lines are typed',CR,LF
	DB	'after each  <RETURN>.  Input line length is 136',CR,LF
	DB	'characters maximum.',CR,LF
	DB	LF,LF
	DB	'Command Keys:'
	DB	CR,LF,LF
	DB	'  Ctrl - A     Display ruler line',CR,LF
	DB	'  Ctrl - C     Exit to CP/M',CR,LF
	DB	'  Ctrl - H     <BS> Backspace one character',CR,LF
	DB	'  Ctrl - I     <TAB> Tab 8 spaces',CR,LF
	DB	'  Ctrl - X     Erase line and start over',CR,LF
	DB	'  Ctrl - Y     Clear screen',CR,LF
;
IF	PRINTER
;
	DB	'  Ctrl - Z     Display printer setup codes',CR,LF
;
ENDIF
;
	DB	'    ?          Display this help',CR,LF,LF,LF
	DB	'$'
;
MSG3	DB	LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF
	DB	LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF	;good for 25 l.
	DB	'$'
;
; RULER LINE DISPLAY
;
MSG5	DB	' ------^-1-----^---2---^-----3-^-------^'
	DB	'-------^-5-----^---6---^-----7-^-------^'
	DB	'-------^-9-----^---A---^-----B-^-------^-------^-D------'
	DB	CR,LF
	DB	'$'
;
; BLANK LINE
;
MSG6	DB	CR,'                              ',CR,'$'
;
; PROWRITER CONTROL CODE DISPLAY MESSAGE
;
IF	PROWRTR
;
PWRT	DB	'Prowriter control codes:                '
	DB	'        - Quick Type II - vers. ',prefix,'.',suffix
	DB	CR,LF,LF
	DB	'    ESC - N    Pica  (10 / inch)',CR,LF
	DB	'    ESC - E    Elite (12 / inch)',CR,LF
	DB	'    ESC - p    Pica  Proportional',CR,LF
	DB	'    ESC - P    Elite Proportional',CR,LF
	DB	'    ESC - n    Extended (9 / inch)',CR,LF
	DB	'    ESC - q    Condensed (15 / inch)',CR,LF
	DB	'    ESC - Q    Ultracondensed (17 / inch)',CR,LF,LF
	DB	'    CTL - N    Headline on              '
	DB	'    ESC - >    Left to right printing',CR,LF
	DB	'    CTL - O    Headline off             '
	DB	'    ESC - <    Bidirectional printing',CR,LF,LF
	DB	'    ESC - !    Boldface on              '
	DB	'    ESC - f    Forward linefeed',CR,LF
	DB	'    ESC - "    Boldface off             '
	DB	'    ESC - r    Reverse linefeed',CR,LF,LF
	DB	'    ESC - X    Underline on             '
	DB	'    ESC - A    6 Lines / inch',CR,LF
	DB	'    ESC - Y    Underline off            '
	DB	'    ESC - B    8 Lines / inch',CR,LF
	DB	'                                        '
	DB	'    ESC - Tnn  (distance = nn/144 inch)',CR,LF
	DB	'    ESC - D    Slashed Zeros',CR,LF
	DB	'    ESC - Z    Unslashed Zeros          '
	DB	'    CTL - L    Form Feed',CR,LF,LF
	DB	'$'
;
ENDIF
;
; NEC-8023A CONTROL CODE DISPLAY MESSAGE
;
IF	NEC8023
;
PWRT	DB	CR,LF,LF,LF
	DB	'NEC 8023A control codes:                '
	DB	'        - Quick Type II - vers. ',prefix,'.',suffix
	DB	CR,LF,LF
	DB	'    ESC - N    Pica  (10 / inch)',CR,LF
	DB	'    ESC - E    Elite (12 / inch)',CR,LF
	DB	'    ESC - P    Elite Proportional',CR,LF
	DB	'    ESC - Q    Ultracondensed (17 / inch)',CR,LF,LF
	DB	'    CTL - N    Headline on              '
	DB	'    ESC - Lnnn   Left Margin Offset  ',CR,LF
	DB	'    CTL - O    Headline off             '
	DB	'    ESC - 2      Clear(kill) all TABS',CR,LF,LF
	DB	'    ESC - !    Boldface on              '
	DB	'    ESC - f    Forward linefeed',CR,LF
	DB	'    ESC - "    Boldface off             '
	DB	'    ESC - r    Reverse linefeed',CR,LF,LF
	DB	'    ESC - X    Underline on             '
	DB	'    ESC - A    6 Lines / inch',CR,LF
	DB	'    ESC - Y    Underline off            '
	DB	'    ESC - B    8 Lines / inch',CR,LF
	DB	'                                        '
	DB	'    ESC - Tnn  (distance = nn/144 inch)',CR,LF
	DB	'    CTL - L    Form Feed',CR,LF,LF
	DB	'$'
;
ENDIF


IF	GEMINI
;
GEMINI	DB	'Gemini control codes:                    '
	DB	'        - Quick Type II - vers. ',prefix,'.',suffix
	DB	CR,LF,LF
	DB	'        -      Pica  (10 / inch)',CR,LF
	DB	'        -      Elite (12 / inch)',CR,LF
	DB	'        -      Pica  Proportional',CR,LF
	DB	'        -      Elite Proportional',CR,LF
	DB	'        -      Extended (9 / inch)',CR,LF
	DB	'        -      Condensed (15 / inch)',CR,LF
	DB	'        -      Ultracondensed (17 / inch)',CR,LF,LF
	DB	'        -      Headline on              '
	DB	'        -      Left to right printing',CR,LF
	DB	'        -      Headline off             '
	DB	'        -      Bidirectional printing',CR,LF,LF
	DB	'        -      Boldface on              '
	DB	'        -      Forward linefeed',CR,LF
	DB	'        -      Boldface off             '
	DB	'        -      Reverse linefeed',CR,LF,LF
	DB	'        -      Underline on             '
	DB	'        -      6 Lines / inch',CR,LF
	DB	'        -      Underline off            '
	DB	'        -      8 Lines / inch',CR,LF
	DB	'                                        '
	DB	'        -      (distance = nn/144 inch)',CR,LF
	DB	'        -      Slashed Zeros',CR,LF
	DB	'        -      Unslashed Zeros          '
	DB	'        -      Form Feed',CR,LF,LF
	DB	'$'
;
ENDIF
;
INBUF	DS	1		;CONSOLE BUFFER STORAGE
;
	END
