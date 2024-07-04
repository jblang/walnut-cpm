
; FFOR.ASM - Displays the FFOR text file, describing old files - 12/10/85
;
;	This program has been copyrighted (c) by Irvin M. Hoff
;
;			    FOR.ASM
;			       by
;			  Irvin M. Hoff
;			 (17 July 1985)
;
	ASEG			; For M80 and RMAC, ignore if using MAC
;
;
; This program displays the FFOR text file, showing the description of
; recently uploaded files.  It should go on A0: area, giving full secur-
; ity, and allowing it to be called from any drive/user area.  ^S pauses
; and the following characters will terminate at the end of the current
; line:
;
;	^C   C	 c   ^K   K   k   ^X   X   x
;
; It can also show the entire description of any file area that contains
; a string of characters typed after the FFOR name, in a similar (but
; more simple) manner to FIND52, etc.  Example:
;
;		A>FFOR ? 	(displays a help guide)
;		A>FFOR IBM	(types all files with IBM somewhere)
;		A>FFOR .A?M	(accepts ? for a wildcard)
;
;-----------------------------------------------------------------------
;
; 12/10/85  Rewritten (slightly) for FFOR	- Irv Hoff
; 08/20/85  Redated for KMD04			- Irv Hoff
; 07/17/85  Initial version			- Irv Hoff
;
;-----------------------------------------------------------------------
;
; User choices
;
DRIVE	EQU	'A'		; FFOR text file location in your system
USER	EQU	5		; FFOR text file location in your system
;
;
; Equates
;
CR	EQU	0DH		; Carriage return
LF	EQU	0AH		; Line feed
EOF	EQU	1AH		; End of file character
EOT	EQU	04H		; End of transmission
ETX	EQU	03H		; End of text
;
;
	ORG	0100H
;
;
	JMP	START
;
;
STDRIV:	DB	DRIVE		; Location of FFOR text file
STUSER:	DB	USER		; Location of FFOR text file
;
;
;=======================================================================
;
;			PROGRAM STARTS HERE
;
;=======================================================================
;
; Save stack, print sign-on, look for file specification
;
START:	LXI	H,0
	DAD	SP		; Get 'CCP' stack
	SHLD	STACK		; Save it for exit
	LXI	SP,STACK	; Set stack pointer
;
	LDA	0004H		; Get current drive/user
	STA	DRUSER		; Store
;
;
; Set drive/user to the FFOR text file area listed above
;
	LDA	STUSER		; Set user to FFOR text file area
	MOV	E,A
	MVI	C,SETUSR
	CALL	BDOS
	LDA	STDRIV		; Set drive to FFOR text file area
	SUI	41H
	MOV	E,A
	MVI	C,SELDSK
	CALL	BDOS
;
;
; Open source file
;
	LXI	D,FILE
	MVI	C,OPEN
	CALL	BDOS
	INR	A		; Check for no open
	JZ	NONE		; No file, exit
;
	CALL	ILPRT
	DB	CR,LF
	DB	'FFOR - copyright 1985 by Irvin M. Hoff - 12/10/85'
	DB	CR,LF,'[type ^S to pause, ^C, ^X or ^K to abort, ? for '
	DB	'help]',CR,LF
	DB	'wait a moment...'
	DB	0
;
	LDA	TBUF		; Any search string requested?
	ORA	A
	STA	SHOWAL		; If no strings to find, show everything
	JNZ	CHECK
	CALL	ILPRT		; Will overwrite "wait" message
	DB	CR,'                  ',CR,LF,0
	JMP	READLP		; If no strings, exit
;
;
; Want the help guide?
;
CHECK:	LDA	TBUF+2
	CPI	'?'		; First chararter typed a '?' for help?
	JNZ	LOOP		; If not, continue
	LDA	TBUF+3		; Check next character after '?'
	ORA	A		; If a zero, they want some help
	JZ	HELP
;
;
; Store the search string in STRING
;
LOOP:	LXI	H,TBUF
	MOV	B,M		; Get number of characters in string
	LXI	D,STRING	; Get and store the requested string(s)
	INX	H
;
LOOP1:	INX	H
	MOV	A,M
	STAX	D
	INX	D
	DCR	B
	JNZ	LOOP1
;
;
; Address the main buffer, now
;
	LXI	D,BUFFER	; Put in buffer
;
;
; Read record from source file
;
READLP:	PUSH	D		; Save the line address
	MVI	C,SETDMA
	LXI	D,TBUF
	CALL	BDOS
;
	MVI	C,READ
	LXI	D,FILE
	CALL	BDOS
;
	POP	D
	ORA	A		; Read ok?
	JNZ	RERROR		; If not, display an error
;
	LXI	H,TBUF		; Read buffer address
;
WRDLOP:	LDA	LFEED		; Last character a line feed?
	ORA	A
	JZ	WRDL1		; If not, keep going
;
	XRA	A
	STA	LFEED		; Clear the flag
	MOV	A,M
	ANI	7FH		; Remove any parity
	CPI	'-'		; Is this a separator line?
	JNZ	WRDL1		; If not, keep going
	MVI	A,03H		; If yes, store an "end of text" char.
	STAX	D
	JMP	COMPAR		; Handle the string
;
WRDL1:	MOV	A,M		; Get byte from read buffer
	ANI	7FH		; Strip parity bit
	CPI	7FH		; DEL (rubout) ?
	JZ	NEXT		; Yes, ignore it
	CPI	EOF		; End of file marker ?
	JZ	TDONE		; Transfer done, close, exit
;
	MOV	B,A		; Store the character temporarily
	LDA	SHOWAL		; Going to show everything?
	ORA	A
	MOV	A,B		; Get the character back
	JNZ	WRDL2
	CALL	TYPE
	JMP	WRDL3
;
;
; Store the character in the buffer
;
WRDL2:	STAX	D		; Store the character in the buffer
	INX	D		; Next buffer position
;
WRDL3:	CPI	LF		; See if finished with this line
	JNZ	NEXT		; If not get next character
	LDA	SHOWAL
	STA	LFEED		; Show we just had a line feed character
	CALL	ABORT		; Ready to quit?
;
NEXT:	INR	L		; Done with sector?
	JZ	READLP		; If yes get another sector
	JMP	WRDLOP		; No, get another byte
;.....
;
;
;=======================================================================
;
;			 SUBROUTINES
;
;=======================================================================
;
;
; Aborts the display when requested, but only at end of line
;
ABORT:	PUSH	H		; Save the TBUF address
	PUSH	D
	MVI	C,CONST		; Check to see if key pressed
	CALL	BDOS
	ORA	A
	JZ	ABORT3		; If no key pressed, then continue
	MVI	C,RDCON		; If key pressed, then check for abort
	ANI	5FH		; Remove parity, insure upper-case
	CALL	BDOS
	CPI	'S'-40H
	JNZ	ABORT1
	MVI	C,RDCON
	CALL	BDOS
	ANI	5FH
;
ABORT1:	CPI	'C'-40H		; Is it CTL-C?
	JZ	ABORT2
	CPI	'K'-40H		; Is it CTL-K?
	JZ	ABORT2		; If no, then continue
	CPI	'X'-40H		; Is it CTL-X?
	JZ	ABORT2
	ANI	5FH		; Cnvert to upper-case
	CPI	'C'
	JZ	ABORT2
	CPI	'K'
	JZ	ABORT2
	CPI	'X'
	JNZ	ABORT3
;
ABORT2:	CALL	EXIT		; If yes, then print abort message
	DB	CR,LF,'++ ABORTED ++','$'
;
ABORT3:	POP	D
	POP	H
	RET
;.....
;
;
; Print message then exit to CP/M
;
EXIT:	POP	D		; Get message address
	MVI	C,PRINT		; Print message
	CALL	BDOS
;
EXIT1:	CALL	ILPRT		; Print CRLF before quitting
	DB	CR,LF,0
	LDA	DRUSER		; Get original drive/user area back
	RAR
	RAR
	RAR
	RAR
	ANI	0FH		; Just look at the user area
	MOV	E,A
	MVI	C,SETUSR	; Restore original user area
	CALL	BDOS
	LDA	DRUSER		; Get the original drive/user back
	ANI	0FH		; Just look at the drive for now
	MOV	E,A
	MVI	C,SELDSK	; Restore original drive
	CALL	BDOS
;
	LHLD	STACK
	XRA	A
	SPHL
	RET
;.....
;
;
; Help guide if no search string is included
;
HELP:	CALL	EXIT
	DB	CR,'   Examples of how to use:',CR,LF
	DB	CR,LF,'   B>FFOR MOD'
	DB	CR,LF,'   B>FFOR MOD|BYE'
	DB	CR,LF,'   B>FFOR M7'
	DB	CR,LF,'   B>FFOR \M7'
	DB	CR,LF,'   B>FFOR SPHL'
	DB	CR,LF,'   B>FFOR .A?M'
	DB	CR,LF,CR,LF,'   If no string is included, all the file '
	DB	'is shown.  A ''|'' allows',CR,LF,'   numerous '
	DB	'strings to be used at the same time.  ''?'' is used '
	DB	'for',CR,LF,'   "any character at this position".  A '
	DB	'''\'' fakes a line feed and',CR,LF,'   looks only at '
	DB	'the start of the filename line.',CR,LF,'$'
;.....
;
;
; Inline print routine - prints string pointed to by stack until a zero
; is found.  Returns to caller at the next address after the zero ter-
; minator.
;
ILPRT:	XTHL			; Save HL, get message address
;
ILPLP:	MOV	A,M		; Get chararacter
	CALL	TYPE		; Show on CRT
	INX	H		; Next character location
	MOV	A,M		; Get the character
	ORA	A		; If zero, all done
	JNZ	ILPLP		; Else keep going
	XTHL			; Restore HL, ret address
	RET			; Return past the end of the message
;.....
;
;
NONE:	CALL	EXIT
	DB	CR,LF,'++ No current FFOR text file available ++','$'
;.....
;
;
; Scan for the string
;
COMPAR:	PUSH	H		; Save the TBUF address
	LXI	H,STRING
;
ORLINE:	SHLD	STRPTR
	LXI	H,BUFFER
;
NXTSTR:	XCHG			; Buffer location into DE for now
	LHLD	STRPTR
	XCHG			; DE=string ponter, HL=buffer address
	PUSH	H		; Save current buffer position
;
;
; Replace '\' with a line feed character
;
CLOOP:	LDAX	D		; Get character from the string
	CPI	'\'
	JNZ	$+5
	MVI	A,LF		; Call it a line feed
;
;
; Compare the string with characters in the buffer
;
	INX	D
	ORA	A		; End of string?
	JZ	MATCHED
;
	CPI	'|'
	JZ	MATCHED		; First part
;
	MOV	B,A		; Store the string character for now
	MOV	A,M		; Get the buffer character
	CPI	'a'		; Test for lower case
	JC	NOTLWR
	CPI	'z'+1
	JNC	NOTLWR
	ANI	5FH
;
NOTLWR:	MOV	C,A		; Store temporarily
	INX	H
	MOV	A,B		; Get the string character back again
	CPI	'?'		; If wild card, accept any character
	JZ	CLOOP		; Match so far, keep going
	CMP	C		; String char. match buffer char?
	JZ	CLOOP		; Matched, so keep going
;
;
; Not equal
;
	POP	H		; Restore the buffer address
	INX	H		; Next buffer position
	MVI	B,0		; Zero out temporary "end of file" flag
	MOV	A,M		; Get the character
	CPI	ETX		; At end of buffer?
	JZ	NOTEQL		; If yes, exit
;
	CPI	EOT
	JNZ	NXTSTR		; If not, keep going
	INR	B
;
NOTEQL:	LHLD	STRPTR		; Reload the string pointer
;
;
; If an 'OR' (|) is in the line, scan for it
;
FINDOR:	MOV	A,M		; Get the character from the string
	INX	H		; Next position in string
	CPI	'|'		; Divisor between strings
	JZ	ORLINE		; Was a divisor, so check next string
	ORA	A		; End of string?
	JNZ	FINDOR		; If neither, keep checking
;
;
; Start the buffer over again
;
	MOV	A,B		; Get our temporary "all done" flag
	ORA	A
	JNZ	TDONE1		; If not zero, all finished
	LXI	D,BUFFER+1	; Keep the one '-' from very first line
	POP	H		; Restore the TBUF address
	JMP	NEXT		; Get the next character and continue
;
;
; Now print the line itself
;
MATCHED:POP	H		; Restore the stack from inner loop
	LDA	FIRSTM
	ORA	A
	JNZ	MATCH0
	INR	A
	STA	FIRSTM
	CALL	ILPRT
	DB	CR,'                  ',CR,LF,0
;
MATCH0:	LXI	H,BUFFER	; Start at beginning of buffer
;
MATCH1:	MOV	A,M		; Get the character
	CPI	ETX		; End of Text?
	JZ	MATCH2		; If yes, start next group
	CPI	EOT		; End of transmission?
	JZ	TDONE1		; If yes, all finished now
	CALL	TYPE		; Show on CRT
	INX	H		; Next character in buffer
	JMP	MATCH1
;
MATCH2:	POP	H		; Restore the TBUF address
	LXI	D,BUFFER+1	; Keep the original '-' to balance line
	JMP	NEXT		; Get the next group
;.....
;
;
RERROR:	CPI	1		; File finished?
	JZ	TDONE		; Exit, then
	CALL	EXIT
	DB	'++ SOURCE FILE READ ERROR ++$'
;.....
;
;
; Transfer is done - close destination file
;
TDONE:	LDA	SHOWAL		; Showing all text?
	ORA	A
	JZ	TDONE1		; If yes, exit
	MVI	A,EOT		; Store ad "end of transmission" char.
	STAX	D
	JMP	COMPAR		; Make a final comparison
;
TDONE1:	MVI	C,CLOSE
	LXI	D,FILE
	CALL	BDOS
	CALL	EXIT
	DB	CR,'----'
	DB	CR,LF,'[End of listing]','$'
	JMP	EXIT1
;.....
;
;
; Send character in A register to console
;
TYPE:	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
	MOV	E,A		; Character to 'E' for CP/M
	MVI	C,WRCON		; Write to console
	CALL	BDOS
	POP	PSW
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
;***********************************************************************
;
; Data area
;
;***********************************************************************
;
;
FILE:	DB	0,'FFOR       '
	DB	0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0
;
DRUSER:	DB	0		; Store original drive/user area
FIRSTM:	DB	0		; To clear "wait a momemnt....."
LFEED:	DB	0		; Checks the character after a line feed
SHOWAL:	DB	0		; Flag to show all text if no strings
STRPTR:	DW	0		; Pointer for "|" scan
;
STRING:	DS	128		; What to search for
	DS	40		; Room for 20-level stack
;
;
; Set write buffer to even page boundry
;
	ORG	($+255)/256*256
;
BUFFER	EQU	$		; Write buffer starts here
STACK	EQU	BUFFER-2
;
;
; BDOS equates
;
RDCON	EQU	1		; Read console
WRCON	EQU	2		; Write to console
PRINT	EQU	9		; Print string
CONST	EQU	11		; Get console status
SELDSK	EQU	14		; Select requested disk drive
OPEN	EQU	15		; Open a file
CLOSE	EQU	16		; Close a file
READ	EQU	20		; Read sequential file
SETDMA	EQU	26		; Set dma address
SETUSR	EQU	32		; Set requested user area
;
BDOS	EQU	0005H
TBUF	EQU	0080H
;.....
;
;
	END
