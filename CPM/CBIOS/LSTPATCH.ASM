;		LSTPATCH.ASM ver 1.0
;	      by Keith Petersen, W8SDZ
;		  (revised 12/29/84)
;
;This program moves an alternate list driver into high
;memory and then patches CP/M to use it instead of the
;regular CBIOS list routine.  The patch will remain
;intact until the next cold boot.
;
;Why this is useful: if your list driver is too long
;to fit into your CBIOS or the list STAT routine is
;not implemented, this program can be used to patch it
;in after CP/M is booted.  Another use would be if
;a temporary list driver is needed for an otherwise
;unimplemented port.
;
;------------------------------------------------
;Change the following equate to an area in your high
;memory where the alternate list driver may be located
;without interference to or from CP/M.
;
DEST	EQU	0FB80H		;running location of code
;
;------------------------------------------------
;
;Define I/O ports and status bits
;
LISTS	EQU	02H		;list status port
LISTD	EQU	03H		;list data port
LISRDY	EQU	80H		;list trans. buf. empty
;
CR	EQU	0DH		;carriage return
LF	EQU	0AH		;line feed
NULL	EQU	00H		;null character
BDOS	EQU	0005H		;BDOS entry adrs
;
	ORG	100H
;
;Move the console and list drivers up to high ram
;
MOVEUP:	LXI	B,PEND-START+1	    ;number of bytes to move
	LXI	H,DEST+PEND-START+1 ;end of moved code
	LXI	D,SOURCE+PEND-START ;end of source code
;
MVLP:	LDAX	D		;get byte
	DCX	H		;bump pointers
	MOV	M,A		;new home
	DCX	D
	DCX	B		;bump byte count
	MOV	A,B		;check if zero
	ORA	C
	JNZ	MVLP		;if not, do some more
;
;now patch cp/m to use the new drivers
	LHLD	1		;get CP/M jump table adrs
	LXI	D,13		;ready to add 13
	DAD	D		;HL = LISTOUT + 1
;
	MVI	M,LISOUT AND 0FFH ;modify LSB jmp adrs
	INX	H
	MVI	M,LISOUT SHR 8	  ;modify MSB jmp adrs
	LXI	D,29		  ;ready to add 29
	DAD	D		  ;hl = lststat + 1
	MVI	M,LSTSTAT AND 0FFH ;modify LSB jmp adrs
	INX	H
	MVI	M,LSTSTAT SHR 8	   ;modify MSB jmp adrs
;
;Print message saying what has been done, then exit to CP/M
	LXI	D,MSG		;point to message
	MVI	C,9		;bdos print string function
	JMP	BDOS		;print msg then return to CCP
;
MSG:	DB	'++Alternate LIST driver now patched++',CR,LF,'$'
;
SOURCE	EQU	$		;boundary memory marker
;
OFFSET	EQU	DEST-SOURCE	;reloc amount
;-----------------------------------------------;
;	The following code gets moved		;
;	to high RAM located at "DEST"		;
;-----------------------------------------------;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xx   C A U T I O N :  if modifying anything	xx
;xx	in this program from here on:		xx
;xx	A-L-L  labels must be of the form:	xx
;xx	LABEL	EQU	$+OFFSET		xx
;xx	in order that the relocation to high	xx
;xx	RAM work successfully.	Forgetting to	xx
;xx	specify '$+OFFSET' will cause the pro-	xx
;xx	gram to JMP into whatever is currently	xx
;xx	in low memory, with unpredictable	xx
;xx	results.  Be careful....		xx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
START	EQU	$+OFFSET
;
;This is the new list output routine
LISOUT	EQU	$+OFFSET
	IN	LISTS		;get list status
	ANI	LISRDY		;ready for character?
	JZ	LISOUT		;no, loop and wait
	MOV	A,C		;get character
	ANI	7FH		;strip parity
	OUT	LISTD		;send to printer
	CPI	LF		;was it a line feed?
	RNZ			;no, return
;
;Send null to printer to allow time for carriage to return
	MVI	C,NULL		;get a null
	CALL	LISOUT		;send it to printer
	MVI	C,LF		;restore line feed
	RET
;
;This is the new list status routine
LSTSTAT	EQU	$+OFFSET
	IN	LISTS		;get list status
	ANI	LISRDY		;ready for character?
	MVI	A,0
	RZ			;no, return with 0
	CMA			;else make it 0ffh
	RET
;
PEND	EQU	$+OFFSET	;end of relocated code
;
	END
