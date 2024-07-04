
*****************************************************************
*		     AMPRO Computers Inc.			*
*  			   Date.asm				*
*								*
* 		     Adapted from DATE.MAC 			*
*	                by Don Delwood, 			*
*	            with mods by Roger Warren			*	
*                                                               *
*  Additional modifications were made to allow update from      *
*  the Calendar/Clock board by Kenmore Computer Technologies    *
*                                                               *
*                 by Ernest J. Levesque                         *
*                                                               *
*       (changes are in lower case, ending with ******)         *
*                                                               *
*  Implementation is competed ajusting the equate "cbase" to the*
*  base port of the clock board.  Date functions as usual but   *
*  adding S after the command causes the date and time to be    *
*  taken from clock board.  Note that the time is also set.     *
*  Note that the posibility exists that if call to the clock    *
*  occurs during an update of the clock the wrong time could be *
*  set.  This could cured by looping through the clock update   *
*  routine until two passes match.  I may get around to that    *
*  implementation but current is satisfactory for my needs      *
*****************************************************************
;
; Version    date	  by	History
; -------  --------	------	--------
;   1.0	   4 mar 86	 fsw	Version 1.0 for use with bios 3.6
;
*---------------------------------------------------------------*

VER	EQU	10		; version 1.0

CR	EQU	13
LF	EQU	10

LDIR	EQU	0B0EDH		; z80 ldir

	ORG	100H
	JMP	BEGIN		; jump over logo
HELP:	CALL	PRINT
	DB	CR,LF,LF
	DB	'DATE '
	DB	'Version ',VER/10+'0','.',VER MOD 10+'0',CR,LF
	DB	'AMPRO Computers Inc.'
	DB	CR,LF,'To change the date, enter change '
	DB	'on the command line as follows:',cr,lf,lf
	DB	'du>DATE mm-dd-yy',cr,lf
	DB	0
	JMP	EXIT
BEGIN:	
	DW	73EDH,OLDSTK	; save old stack pointer
	LXI	SP,LOCSTK	; set new stack
;
	LXI	D,WBOOT		; build bios entry table
	LHLD	1		; get bios start
	LXI	B,51		; bytes to move
	DW	LDIR		; move it
;
	CALL	GETTBL		; get address of next jmp tbl
	CPI	36		; must be bios ver 3.6 or higher
	JC	BADVER		; give message and exit
	LXI	D,NXTTBL	; 'hl' has bios nxttbl address
	LXI	B,15		; 
	DW	LDIR		; move the table
	LXI	H,0		; make sure that clock is enabled
	CALL	TOD		; get clock base address
	MOV	A,L		; see if address of tick was returned
	ORA	H
	JZ	NOCLK		; exit clock not enabled

; 'hl' has addres of clock

	LXI	D,SEC		; move time
	LXI	B,6
	DW	LDIR		; save time

; Everthing needed has been moved into program area now.
; parse command tail to see if time was entered on command line.
;
	LXI	H,80H		; point to command tail
	MOV	A,M		; get character count
	ANA	A		; if zero nothing on cmd line
	STA	UPDATE		; save possible entry on cmd line
	JZ	SHDATE		; skip no char on command line
LOOP:	INX	H		; point to first char on command line
	MOV	A,M
	CPI	' '
	JZ	LOOP		; filter leading spaces
                    ;*******                                       ******
       cpi 'S'      ;*******  See if set command is requested      ******
       jz  kendate  ;*******  Jump off to get date from clock port ******
                    ;*******                                       ******
	PUSH	H
	CALL	VALID		; test for valid numeric ascii
	POP	H
	CALL	EVAL10
	CPI	12+1		; see if more than december
	JNC	NVALMS
	STA	TMONTH		; set temp month
	MOV	C,A		; save month
	INX	H
	CALL	EVAL10		
	PUSH	H
	LXI	H,MTHS-1	;
	MVI	B,0
	DAD	B		; point to number of days in month
	CMP	M		; see if valid entry for the month
	POP	H
	JZ	CONT
	JNC	NVALMS
CONT:	STA	TDAY		; set temp month
	INX	H
	CALL	EVAL10
	STA	YEAR		; set year
	CALL	MD2J		; convert the month/day to julian

SHDATE:	CALL	J2MD		; convert julian date to month/day
	LDA	TMONTH
	DCR	A		; adjust
	MOV	E,A		;
	ADD	A		; times 2
	ADD	E		; times 3
	MOV	E,A
	MVI	D,0
	LXI	H,AMONTHS	; find month in string
	DAD	D
	LXI	D,MON
	LXI	B,3		; move 3 bytes
	DW	LDIR

	LDA	TDAY
	CALL	BINASC
	DW	43EDH,DAY
	LDA	YEAR
	CALL	BINASC
	DW	43EDH,YR


	CALL 	PRINT		; print message
CURDAT:	DB	'Current date is '
MON:	DB	'    '
DAY:	DB	'  , 19'
YR:	DB	'  '
	DB	0

;
; if time was not changed from the command line, do not place
; the time prameters back into the bios clock area.
;
	LDA	UPDATE
	ANA	A		; if zero time was only displayed
	JZ	EXIT
;
; move the newly set time prameters to bios clock area
;
     lda   kenflag           ; Load the Kenmorre clock flag       *****
     cpi   0ffh              ; See if we set the flag for Kenmore *****
     jnz   oldexit           ; exit through former method if not  *****
     call  tod               ; get address of time counters       *****
     xchg                    ; bios time counter addresss to 'de' *****
     lxi   h,sec             ;                                    *****
     lxi   b,6               ; date only, not time                *****
     dw    ldir              ; move it to bios memory             *****
     jmp   exit              ;                                    *****
oldexit: CALL	TOD		; get address of time counters *****
	LXI	D,3		; offset to date
	DAD	D		; add offset to 'hl'
	XCHG			; bios time counter addresss to 'de'
	LXI	H,JDAY		;
	LXI	B,3		; date only, not time
	DW	LDIR		; move it to bios memory
	JMP	EXIT
;
; Get the seconds, minutes, hours, day, and  month from Kenmore Clock board
;
kenflag: ds 1                    ;  Flag for Set from Kenmore clock   ******
cbase  equ 0e0H                  ;  Port address of millisecond clock ******
kendate: mvi a,0ffh              ;  Set Clock flag for exit update    ******
       sta kenflag               ;  Store flag                        ******
       in  cbase+7               ;  Port address of month             ******
       call fix                  ;  change BCD from clock to binary   ******
       sta tmonth                ;  Store the month temporary         ******
       in  cbase+6               ;  Port address of day               ******
       call fix                  ;  change BCD from clock to binary   ******
       sta tday                  ;  Store the day temporary           ******
       in  cbase+4               ;  Port address of hour              ******
       call fix                  ;  change BCD from clock to binary   ******
       sta hour                  ;  Store hours                       ******
       in  cbase+3               ;  Port address of minutes           ******
       call fix                  ;  change BCD from clock to binary   ******
       sta min                   ;  Store minutes                     ******
       in  cbase+2               ;  Port address of second            ******
       call fix                  ;  change BCD from clock to binary   ******
       sta sec                   ;  Store seconds                     ******
       call md2j                 ;  Convert temp day month to julian  ******
       mvi a,86                  ;  Load the year                     ******
       sta year                  ;  Store                             ******
       jmp  shdate               ;  Show the date and exit            ******
;                                                                     ******
; FIX - Fix converts BCD from the Kenmorre clock to binary through    ******
;       existing routines                                             ******
;                                                                     ******
fix:   mov  c,a                  ;  place character in c for later    ******
       ani  0f0h                 ;  strip tens digit                  ******
       rrc                       ;  rotate to units                   ******
       rrc                       ;                                    ******
       rrc                       ;                                    ******
       rrc                       ;                                    ******
       adi 030h                  ; make into character                ******
       sta clockchr              ; store in two character string      ******
       mov a,c                   ; get back the character             ******
       ani 0fh                   ; strip units digit                  ******
       adi 030h                  ; make into character                ******
       sta clockchr+1            ; store in string                    ******
       lxi h,clockchr            ; point to clock string              ******
       jmp eval10                ; jmp to eval. let eval return       ******
clockchr: db '  ',0              ; this is the string that allows the ******
                                 ; the use of eval10 to make binary   ******
;
; Test the command for valid time entry. Scan the command tail
; for along its legnth for the pattern hh:mm:ss. test for
; valid numeric characters. it has already been determined that
; somthing was entered on the command line
;
VALID:	LXI	H,80H		; character count
	MOV	B,M		; get number of characters typed
	INX	H
	DCR	B
	JZ	NVALMS		; exit only spaces or one char on line
	MOV	A,M		; get first char
	CPI	' '
	JZ	VALID+4		; filter the spaces

VAL1:	MOV	A,M
	INX	H		; point to next char
	ANA	A		; 00h is terminator or zero count
	RZ
	CPI	'/'
	JZ	HELP		; show instructions
	CPI	'?'
	JZ	HELP		; show insturctions
	CPI	'-'
	JZ	VAL1		; delimeter ok
	CPI	'0'	
	JC	NVALMS		; less than ascii 0
	CPI	'9'+1
	JNC	NVALMS		; more than ascii 9
	JMP	VAL1
;
NVALMS:	CALL	PRINT
	DB	'Invalid date',cr,lf,0
	JMP	EXIT
;
; time of day TOD jmp was not in bios
;
NOCLK:
	CALL	PRINT
	DB	'Clock not installed',cr,lf,0
	JMP	EXIT
;
; wrong version bios
;
BADVER:	CALL	PRINT
	DB	'Requires Bios 3.6 or higher.',cr,lf,0
				; fall through to exit

;
; Normal program exit. Restores system stack and returns
;
EXIT:	
	DW	7BEDH,OLDSTK	; recover old stack pointer
	RET

;
; Print string of characters terminated with zero '0'.
;
PRINT:	POP	H
	MOV	A,M		; get byte
	ANA	A
	JZ	PRNEND
	PUSH	H		;
	MOV	C,A
	CALL	CONOUT		; call bios routine
	POP	H
	INX	H		; next byte
	JMP	PRINT+1

PRNEND:	XTHL			; hl has return
	RET

;***************************************************************
;		convert binary to ascii
; in:	a  - binary value
; out:	bc - ascii character (low high)	  (mod. after Rich Conn)
;***************************************************************
BINASC:	MVI	C,0		; init count
	MVI	B,10

BIN1:	SUB	B
	JC	BINEXT
	INR	C
	JMP	BIN1

binext:	ADD	B		; A = ones digit  C = tens digit
	ADI	'0'
	MOV	B,A
	MOV	A,C
	ADI	'0'
	MOV	C,A	
	RET
								
;***************************************************************
;	eval10 - convert ascii string to decimal value
; in:	hl - points to beginning of string
; out:	a  - e
;	de - value
;	hl - points to delimiter (error character)
;					(mod. after Rich Conn)
;***************************************************************

EVAL10:	PUSH	B
	LXI	D,0		; init de to zero

E10L:	MOV	A,M		; next digit, check range '0'-'9'
	CPI	'0'
	JC	EVLOUT		; less than ascii 0
	CPI	'9'+1
	JNC	EVLOUT		; more than ascii 9
	SUI	'0'

MUL10:	PUSH	H		; multiply DE by 10
	MOV	H,D
	MOV	L,E
	DAD	H		; *2
	DAD	H		; *4
	DAD	D		; *5
	DAD	H		; *10
	MOV	E,A		; add in latest digit
	MVI	D,0
	DAD	D
	XCHG
	POP	H
	INX	H
	JMP	E10L

EVLOUT:	MOV	A,E
	POP	B
	RET

;****************************************************************
; 		  convert month/day to julian
;****************************************************************
MD2J:	LXI	D,MTHS-1	; init month pointer
	LXI	H,0
	LDA	TMONTH		; get binary month
	MOV	B,A		; set count

MD2J1:	LDAX	D		; get number of days in month
	ADD	L
	MOV	L,A		; update 'l'
	CC	MD2J3		; adjust 'h' if carry
	DCR	B
	INX	D		; next month
	JNZ	MD2J1

MD2J2:	LDA	TDAY		; get binary day
	MOV	E,A		;
	MVI	D,0
	DAD	D		; add the day
	DCX	H		; adjust for ordinal 0
	SHLD	JDAY
	RET

MD2J3:	MVI	A,1		; if carry add 1 to 'h'
	ADD	H
	MOV	H,A
	RET

;****************************************************************
;                 convert julian to month/day
;****************************************************************
J2MD:	LXI	D,MTHS		; int month pointer
	LHLD	JDAY		; julian day in 'hl'
	INX	H		; adjust for ordinal 0
	XRA	A
	MOV	B,A		; init high byte of sub with 0
	INR	A
	STA	TMONTH		; init month to 1

J2MD1:	LDAX	D
	ORA	A		; clear carry
	MOV	C,A
	MOV	A,L		; may be day
	DW	42EDH		; sbc hl,bc
	JC	J2MD2
	JZ	J2MD2
	LDA	TMONTH
	INR	A		; update month
	STA	TMONTH
	INX	D
	JMP	J2MD1

J2MD2:	STA	TDAY		; set day
	RET
	
	

	DB	0
MTHS:	DB	31,29,31,30,31,30,31,31,30,31,30,31
AMONTHS:
	DB	'JanFebMarAprMayJunJulAugSepOctNovDec'
; local stack area
;
	DS	32		; 16 level stack
LOCSTK:	DW	EXIT		; exit point on top of stack
OLDSTK: DS	2		; save for old stack
UPDATE	DS	1		; flag for command entry
;
; bios jmp table, moved from the bios during init.
;
WBOOT:	DS	3		; Warm start
CONST:	DS	3		; Console status
CONIN:	DS	3		; Console character in
CONOUT:	DS	3		; Console character out
LIST:	DS	3		; List character out
PUNCH:	DS	3		; Punch character out
READER:	DS	3		; Reader character in
HOME:	DS	3		; Seek to home position
SELDSK:	DS	3		; Select disk
SETTRK:	DS	3		; Set track number
SETSEC:	DS	3		; Set sector number
SETDMA:	DS	3		; Set DMA address
READ:	DS	3		; Read disk
WRITE:	DS	3		; Write disk
LISTST:	DS	3		; Return list status
SECTRAN:DS	3 		; Sector translate

GETTBL:	DS	3		; Point to more jumps, returns bioss
				; version in 'a'.
NXTTBL:	
SWAP:	DS	3		; jmp swap
HD$INF:	DS	3		; get hd table info
PHTBAC:	DS	3		; get/set phytab acces
PAGET:	DS	3		; get phytab entry address
TOD:	DS	3		; get base address of clock tick

; time/date counters from bios

SEC:	DS	1
MIN:	DS	1
HOUR:	DS	1
JDAY:	DS	2		; julian day 0-366 for leap year
YEAR:	DS	1 ; PRESET YEAR

TMONTH:	DS	1		; temp storage for month
TDAY:	DS	1		; temp storage for day
TYEAR:	DS	1		; temp storage for year

	END
