;
;	****************
;	*	       *
;	*    cd.asm    *
;	*     v7.0     *
;	*	       *
;	****************
;
; 03/06/85 by Harry Kaemmerer CP/M-NET(tm) EAST (201) 249-0691
;	   this utility has ability to chain to a .com file.
;	   this program may be used by anyone for none profit.
;----------------------------------------------------------------------------
;Based on: FASTGO vers. 1.1, by James Whorton, 04/25/84 and GOTO vers. 7.0,
;by Harry Kaemmerer
;
;revisions in reverse order:
;
;03/06/85 made display independend of table entry size, deleted code
;	  that displayed the drive/user (not needed)	  - Harry Kaemmerer
;----------------------------------------------------------------------------
;when executed, this program does the following:
;
;1. checks for input, prints options and quits if none.
;2. evaluates input, seeking a match from the table.
;3. if no match found, tell user, display options and quit.
;4. on match, check for password status and get it if needed.
;5. if password doesn't match, abort.
;6. select specified user-area.
;
;  CD			displays usage and valid area_names
;  CD <area_name>	moves to area_name. if passworded,
;			gets same from user before moving.
;-----------------------------------------------------------------------
NO	EQU	0
YES	EQU	NOT NO
;-----------------------------------------------------------------------
;user settable options
;
USECLR	EQU	NO		;yes = clear screen works
CLR	EQU	26		;^Z = clear screen for kaypro
MAXWORD	EQU	4		;lenght of larest area_name entry in tabel
WIDTH	EQU	16		;# of columns to print across
;-----------------------------------------------------------------------
;equates section
;
SKIP	EQU	(13-MAXWORD)+12	;number of characters to skip when printing
				;DO NOT CHANGE......
BDOS	EQU	5		;bdos call vector
COUT	EQU	2		;console char. out
DIO	EQU	6		;direct i/o call
STUSR	EQU	32		;get/set user #
FCB	EQU	05CH		;first fcb
CR	EQU	13		;carraige return
LF	EQU	10		;line feed
BELL	EQU	7		;console bell
DEFBYT	EQU	4		;current drive/user byte
;
;-----------------------------------------------------------------------
;program starts here
;
	ORG	0100H
;
;the following code is the main body of the program.
;Check if user-area specified.
;
START:	LXI	H,0		;0 -> [HL]
	DAD	SP		;find caller's stack
	SHLD	SAVESP		;save for later
	LXI	SP,STACK	;set up our own stack
;
	 IF	USECLR
	MVI	A,CLR		;clr screen for kaypro
	CALL	CTYPE
	 ENDIF
;
	LDA	FCB+1		;get first byte of fcb
	CPI	32		;blank?
	JZ	USAGE		;yes, print usage and quit
;
;ok, a user-area was specified. Let's see how long it is
;
	MVI	B,0		;set up counter
	LXI	H,FCB+1		;set up pointer
;
LENCHK:	MOV	A,M		;get a byte
	INX	H		;increment pointer
	INR	B		;increment counter
	CPI	32		;is it a blank?
	JNZ	LENCHK		;no, go again
	MOV	A,B
	STA	USRLEN		;store count for later use
;
;now let's start checking the name specified against the table
;
	LXI	H,TABLE+2	;set up pointer
	SHLD	CHARP		;save pointer
;
NAMCHK:	LHLD	CHARP		;get table pointer
	MOV	A,M		;check for end of table
	CPI	0		;are we there?
	JZ	NOMAT		;yes, error message and usage
	LXI	D,FCB+1		;point to input
	LDA	USRLEN		;get length of input
	MOV	B,A		;move it to b
	CALL	COMPAR		;do the comparison
	JZ	MATCH		;it's a match, so do it
	LXI	D,25		;increment the pointer
	LHLD	CHARP		;get the pointer back
	DAD	D		;add it
	SHLD	CHARP		;save it
	JMP	NAMCHK		;try next entry
;
;a match was found, see if pwd protected
;
MATCH:	LHLD	CHARP		;get entry pointer
	DCX	H		;back up 1 bytes
	MOV	A,M		;get access code
	CPI	' '		;need a password?
	JZ	SELECT		;nope, go ahead and do it
				;get a password from user
	CALL	ILPRT		;prompt user
	DB	'Password: ',0
	LXI	H,USRPWD	;point to storage area
	MVI	B,0		;max chars allowed 10
;
PWD1:	PUSH	H
	PUSH	B
	MVI	E,0FFH		;see if char there
	MVI	C,DIO
	CALL	BDOS
	POP	B
	POP	H
	CPI	0		;char ready?
	JZ	PWD1		;not yet
	CPI	8		;back space?
	JZ	BSPACE		;do a backspace
	CPI	7FH		;rubout?
	JZ	BSPACE		;do a backspace
	CPI	CR		;end of input?
	JZ	PWD3		;yes
	MOV	M,A
	INX	H		;increment pointer
	INR	B		;increment char counter
	MOV	A,B		;get counter in a to check
	CPI	10		;buffer full?
	JZ	PWD3		;nope, get another char
	MOV	B,A
	JMP	PWD1
;
;do a backspace on input
;
BSPACE:	DCR	B		;move count to prior character
	DCX	H		;correct H also
	MVI	A,' '		;get a space
	MOV	M,A		;restore password storage
	JMP	PWD1		;and get a new character
;
;now do the check
;
PWD3:	LHLD	CHARP		;point to table entry
	LXI	D,13
	DAD	D
	LXI	D,USRPWD
	MVI	B,10		;check 10 chars (pwd length)
	CALL	COMPAR		;do a comparison
	JZ	SELECT		;correct password supplied
	CALL	ILPRT		;nope, say forget it
	DB	BELL,'Sorry, that area is not available.',CR,LF,0
	JMP	DONE		;display correct areas
;
;no option specified, or bad one, so list usage and table of definitions.
;
NOMAT:	CALL	ILPRT		;
	DB	CR,LF,BELL,'Entry not found.',CR,LF,0
;
USAGE:	CALL	ILPRT
	DB	CR,LF,'Usage: CD <Area_Name> moves you to your area.'
	DB	CR,LF,LF,0
;
;this routine prints the definition table. It prints <width> columns
;across and does not display any passwords.
;
	LXI	H,TABLE+2	;point to names
	MVI	D,MAXWORD	;# of bytes per entry to print
	MVI	B,WIDTH		;# of columns to print
;
;now send char and check for end of entry
;
INFO1:	MOV	A,M		;be sure it's there
	CPI	0		;end of tabel
	JZ	DONE		;yes...
	CALL	CTYPE		;send it
	INX	H		;increment pointer
	DCR	D		;decrement char counter
	MOV	A,D		;get char count to check
	CPI	0		;end of entry?
	JNZ	INFO1		;no, do another byte
;
;done with one entry, so evaluate first, skip past password section,
;print seperator and new line
;
	MVI	D,MAXWORD	;reset char counter
	MVI	A,SKIP		;# of chars to skip
;
SKIP0:	INX	H		;increment pointer
	DCR	A		;decrement char counter
	CPI	0		;past it yet?
	JNZ	SKIP0		;nope, not yet
;
	MOV	A,M		;get a character for end check
	CPI	0		;end of tabel
	JZ	DONE		;yes...
	DCR	B		;decrement column count
	MOV	A,B		;get count
	CPI	0		;need a new line?
	JZ	SKIP1		;yes
;
;add a seperator space between entries
;
	MVI	A,' '		;load a space for seperator
	CALL	CTYPE		;and send to the terminal
	JMP	INFO1		;now back to the grind
;
SKIP1:	MVI	A,CR		;start a new line
	CALL	CTYPE
	MVI	A,LF
	CALL	CTYPE
	MVI	B,WIDTH		;reset column counter
	MOV	A,M		;get a character for end check
	CPI	0		;end of tabel
	JZ	DONE		;yes...
	JMP	INFO1
;
DONE:	CALL	ILPRT
	DB	CR,LF,0
	LHLD	SAVESP		;get callers stack pointer -> [HL]
	SPHL			;now -> [SP]
	RET			;End of program!
;
;subroutines
;
;do a comparison, abort if match found compare routine, # of chars in b,
;text to check in de (input) and hl (table) if a match, zero flag will
;be set on exit
;
COMPAR:	LDAX	D		;get a char.
	CALL	UCASE		;make sure it's upper case
	CMP	M		;check it against text
	RNZ
	INX	H
	INX	D
	DCR	B
	JNZ	COMPAR
	RET
;
ILPRT:	XTHL
;
ILPLP:	MOV	A,M
	ORA	A
	JZ	ILPRET
	CALL	CTYPE
	INX	H
	JMP	ILPLP
;
ILPRET:	XTHL
	RET
;
CTYPE:	PUSH	B		;save registers
	PUSH	D
	PUSH	H
	MOV	E,A		;put character in e reg.
	MVI	C,COUT		;select conout
	CALL	BDOS		;do it
	POP	H		;restore registers
	POP	D
	POP	B
	RET			;done
;
UCASE:	CPI	061H		;converts lower case...
	RC			;in a to upper case
	CPI	07BH
	RNC
	ANI	05FH
	RET
;
;we got this far, let's change the user # and drive
;
SELECT:	LHLD	CHARP		;point to table
	DCX	H		;back up 2 bytes
	DCX	H
	MOV	A,M		;get value from table
	STA	DEFBYT		;put it in memory byte
	MOV	A,M		;get the byte
	ANI	0F0H		;mask out drive
	RAR			;rotate 4 times to get user #
	RAR			;in proper position
	RAR
	RAR
	MOV	E,A		;do it
	MVI	C,STUSR
	CALL	BDOS
	LDA	DEFBYT		;get user/drive byte
;
;----------------------------------------------------------------------------
; 04/20/84 by - Harry Kaemmerer
; auto chain to .com file routine for cp/m 2.2
; note "A" reg. must have user/drive info upon entry
;
	PUSH	PSW		;save drive/user
	CALL	ILPRT
;
	 IF	USECLR
	DB	CLR
	 ENDIF
;
	DB	CR,LF,'Standby... ',0
	POP	PSW		;get user/drive info
	MVI	D,0		;insure d register is zero
	MOV	E,A		;drive/user from a to e
	MVI	C,37		;reset drive/user
	CALL	BDOS		;do it
	LHLD	1		;get bios jump table address
	MOV	A,H		;move jump vector in a << lh reversed
	SUI	16H		;change to start of ccp location
	MOV	H,A		;return to h register
	MVI	L,0		;make cold start address
	SHLD	CCPLOC		;and save it for jump vector
	MVI	L,7		;move offset to l
	XCHG			;put in de
	LXI	H,FNAM		;location of file name
;
LLOOP:	MOV	A,M		;get character
	INX	H		;increment from pointer
	XCHG			;swap hl with de
	MOV	M,A		;place character in memory
	CPI	0		;look for a zero
	JZ	JUMP		;fake jump to cold boot vector
	INX	H		;increment to: pointer
	XCHG			;swap hl with de
	JMP	LLOOP		;not done
;
JUMP:	DB	0C3H		;we need a jump instruction and next 2 bytes
CCPLOC:	DB	0,0		;become the jump address
;
; finish
;----------------------------------------------------------------------------
;storage area
;
USRPWD:	DB	32,32,32,32,32	;force ten spaces for password...
	DB	32,32,32,32,32	;input and compare storage space...
CHARP:	DS	2		;next char. address pointer
USRLEN:	DS	1		;length of user-area specified
	DS	64
STACK:	DS	2		;new stack
SAVESP:	DS	2		;old stack
;
;--------------------------------------------------------------------
;change as needed the name of file or command to CHAIN to:
;
FNAM:	DB	3,'DIR',0	;number of bytes in name & file name to run
;		|   |	|
;		|   |	+--->	must be a zero
;		|   +------->	file or command name (must be in UPPER case)
;		+----------->	number of characters in name above.
;
;--------------------------------------------------------------------
;definition table.
;
;byte	   purpose
;--------- ----------------------------------------------------------
;  1	   allways a zero (0)			  [ 1 byte ]
;  2	   user#  in Hex			  [ 1 byte ]
;  3	   drive# in Hex			  [ 1 byte ]
;  4	   access code (* for passworded)	  [ 1 byte ]
;  5	   area name				  [13 bytes]
;  6	   password (if indicated in access code) [10 bytes]
;
;examples: 000H=0A,001H=0B,010H=1A,011H=1B, etc.
;the examples may be changed, added to or deleted
;as long as the proper format is kept. all entries
;in table should be in upper case.
;
;format guide.. 123H,'455555555555556666666666'
;
TABLE:
;
	DB	000H,' A0                     '
	DB	010H,' A1                     '
	DB	020H,' A2                     '
	DB	030H,' A3                     '
	DB	040H,' A4                     '
	DB	050H,' A5                     '
	DB	060H,' A6                     '
	DB	070H,' A7                     '
	DB	080H,' A8                     '
	DB	090H,' A9                     '
	DB	0A0H,' A10                    '
	DB	0B0H,' A11                    '
	DB	0C0H,' A12                    '
	DB	0D0H,' A13                    '
	DB	0E0H,' A14                    '
	DB	0F0H,' A15                    '
;
	DB	001H,'pB0           123456    '
	DB	011H,' B1                     '
	DB	021H,' B2                     '
	DB	031H,' B3                     '
	DB	041H,' B4                     '
	DB	051H,' B5                     '
	DB	061H,' B6                     '
	DB	071H,' B7                     '
	DB	081H,' B8                     '
	DB	091H,' B9                     '
	DB	0A1H,' B10                    '
	DB	0B1H,' B11                    '
	DB	0C1H,' B12                    '
	DB	0D1H,' B13                    '
	DB	0E1H,' B14                    '
	DB	0F1H,' B15                    '
;
	DB	002H,' C0                     '
	DB	012H,' C1                     '
	DB	022H,' C2                     '
	DB	032H,' C3                     '
	DB	042H,' C4                     '
	DB	052H,' C5                     '
	DB	062H,' C6                     '
	DB	072H,' C7                     '
	DB	082H,' C8                     '
	DB	092H,' C9                     '
	DB	0A2H,' C10                    '
	DB	0B2H,' C11                    '
	DB	0C2H,' C12                    '
	DB	0D2H,' C13                    '
	DB	0E2H,' C14                    '
	DB	0F2H,' C15                    '
;
	DB	003H,' D0                     '
	DB	013H,' D1                     '
	DB	023H,' D2                     '
	DB	033H,' D3                     '
	DB	043H,' D4                     '
	DB	053H,' D5                     '
	DB	063H,' D6                     '
	DB	073H,' D7                     '
	DB	083H,' D8                     '
	DB	093H,' D9                     '
	DB	0A3H,' D10                    '
	DB	0B3H,' D11                    '
	DB	0C3H,' D12                    '
	DB	0D3H,' D13                    '
	DB	0E3H,' D14                    '
	DB	0F3H,' D15                    '
;
	DB	004H,' E0                     '
	DB	014H,' E1                     '
	DB	024H,' E2                     '
	DB	034H,' E3                     '
	DB	044H,' E4                     '
	DB	054H,' E5                     '
	DB	064H,' E6                     '
	DB	074H,' E7                     '
	DB	084H,' E8                     '
	DB	094H,' E9                     '
	DB	0A4H,' E10                    '
	DB	0B4H,' E11                    '
	DB	0C4H,' E12                    '
	DB	0D4H,' E13                    '
	DB	0E4H,' E14                    '
	DB	0F4H,' E15                    '
;
	DB	005H,' F0                     '
	DB	015H,' F1                     '
	DB	025H,' F2                     '
	DB	035H,' F3                     '
	DB	045H,' F4                     '
	DB	055H,' F5                     '
	DB	065H,' F6                     '
	DB	075H,' F7                     '
	DB	085H,' F8                     '
	DB	095H,' F9                     '
	DB	0A5H,' F10                    '
	DB	0B5H,' F11                    '
	DB	0C5H,' F12                    '
	DB	0D5H,' F13                    '
	DB	0E5H,' F14                    '
	DB	0F5H,' F15                    '
;
	DB	006H,' G0                     '
	DB	016H,' G1                     '
	DB	026H,' G2                     '
	DB	036H,' G3                     '
	DB	046H,' G4                     '
	DB	056H,' G5                     '
	DB	066H,' G6                     '
	DB	076H,' G7                     '
	DB	086H,' G8                     '
	DB	096H,' G9                     '
	DB	0A6H,' G10                    '
	DB	0B6H,' G11                    '
	DB	0C6H,' G12                    '
	DB	0D6H,' G13                    '
	DB	0E6H,' G14                    '
	DB	0F6H,' G15                    '
;
	DB	007H,'pH0           12345678  '
	DB	017H,' H1                     '
	DB	027H,' H2                     '
	DB	037H,' H3                     '
	DB	047H,' H4                     '
	DB	057H,' H5                     '
	DB	067H,' H6                     '
	DB	077H,' H7                     '
	DB	087H,' H8                     '
	DB	097H,' H9                     '
	DB	0A7H,' H10                    '
	DB	0B7H,' H11                    '
	DB	0C7H,' H12                    '
	DB	0D7H,' H13                    '
	DB	0E7H,' H14                    '
	DB	0F7H,' H15                    '
;
	DB	008H,' I0                     '
	DB	018H,' I1                     '
	DB	028H,' I2                     '
	DB	038H,' I3                     '
	DB	048H,' I4                     '
	DB	058H,' I5                     '
	DB	068H,' I6                     '
	DB	078H,' I7                     '
	DB	088H,' I8                     '
	DB	098H,' I9                     '
	DB	0A8H,' I10                    '
	DB	0B8H,' I11                    '
	DB	0C8H,' I12                    '
	DB	0D8H,' I13                    '
	DB	0E8H,' I14                    '
	DB	0F8H,' I15                    '
;
	DB	009H,' J0                     '
	DB	019H,' J1                     '
	DB	029H,' J2                     '
	DB	039H,' J3                     '
	DB	049H,' J4                     '
	DB	059H,' J5                     '
	DB	069H,' J6                     '
	DB	079H,' J7                     '
	DB	089H,' J8                     '
	DB	099H,' J9                     '
	DB	0A9H,' J10                    '
	DB	0B9H,' J11                    '
	DB	0C9H,' J12                    '
	DB	0D9H,' J13                    '
	DB	0E9H,' J14                    '
	DB	0F9H,' J15                    '
;note: the following 4 bytes must be kept at the end of this table!
	DB	0,0,0,0		;<<<--- must be here....
;
	END
