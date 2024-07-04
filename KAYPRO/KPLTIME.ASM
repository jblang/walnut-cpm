;------------------------- KPLTIME.ASM --------------------------------
;  TIME program for the LEGACY Computer Systems Real Time Clock (RTC)
;  Modified for Kaypro, prints time/date string on screen or in reverse
;  video or on the 25th status line on a Kaypro video capable machines.
;  This program will run on either the Kaypro 2/4 or Kaypro 10 depending
;  on the on selected equates, in the optional configuration section below.
;
;  Use:	A0>time		print time/date
;	A0>time set	set the clock mode, can also be
;	A0>time s
;----------------------------------------------------------------------
; 07/11/86  This version contains equates so this program will work for
;   V 3.0   Kaypro 2,4,or 10 depending on the equates set.  Other NEW
;	    equates allow you to either or do reverse video, so this
;	    program can also be used on 83 machines.
;	    Ernest-Hintz KAY+FUN-RCP/M-SYSTEM (415)572-8219
;----------------------------------------------------------------------
; modified from K10TIME.ASM
; Modified for Kaypro 10, prints time/date string on the
; 25th status line in inverse video.  - Steve Sanders
;----------------------------------------------------------------------
VER1	EQU	03		; Main program version number
VER2	EQU	00		; Program version number
;MINE	EQU	00		; Your own version number for own changes
;
NO	EQU	0
YES	EQU	NOT NO		; For conditional assembly
;======================================================================
;  OPTIONAL CONFIGURATION SECTION
;======================================================================
;
NOTK10	EQU	YES		; YES, if Kaypro 2 or 4
KPRO10	EQU	NO		; YES if Kaypro 10
				; The above has written intentionally
				; to protect the novice if he messes up.
;
VIDEO	EQU	NO		; YES, if using Kaypro video
				; NO, for no reverse video 
LINE25	EQU	NO		; YES, if using the 25th status line
				; this will not work on 83 kaypro's
;======================================================================
;  Pio addresses with the standard Ports for
;
;	     KAYPRO 2 or 4
	 IF  NOTK10  AND  (NOT KPRO10)
BDATA	EQU	0AH		; port B data
BCMND	EQU	0BH		; port B command
	 ENDIF
;
;	      KAYPRO 10
	 IF  KPRO10  AND (NOT NOTK10)
BDATA	EQU	079H		; port B data
BCMND	EQU	07AH		; port B command
	 ENDIF
;
HOLD	EQU	16		; Hold 5832 to set up read/write
WR	EQU	64		; Read 5832
RD	EQU	32		; Write 5832
MODE0	EQU	0FH		; Pio output mode
MODE3	EQU	0CFH		; Pio control mode
;
;----------------------------------------------------------------------
;  Bdos equates
;
BDOS	EQU	5		; CP/M entry point
CONO	EQU	2		; Console output function
CPRT	EQU	9		; Print string to console function
RCONS	EQU	10		; Read console buffer function
FCB	EQU	5CH		; Default file control block
CBUF	EQU	80H		; console buffer
TPA	EQU	100H		; Transient Program Area
;
;  ASCII equates
;
CR	EQU	13		; Carriage return code
LF	EQU	10		; Line feed code
;
;----------------------------------------------------------------------
;  Program begins
;
	ORG	TPA		; Transient Program Area
;
START:	LXI	H,0		; clear it
	DAD	SP		; put stack ptr in it
	SHLD	STACK		; save it for exit
	LXI	SP,STACK	; set local stack
;
;  Set port to output mode
;
BEGIN:	MVI	A,MODE0		; output mode
	OUT	BCMND		; command port
	MVI	A,3		; disable interrupts
	OUT	BCMND		; command port
;
;----------------------------------------------------------------------
;  Main program
;
	LXI	H,TIME		; clock buffer
	MVI	C,13		; read 13 bytes
	MVI	A,1
CL1:	MOV	M,A		; move em to buffer
	INX	H
	DCR	C		; dec register
	JNZ	CL1		; if not zero, loop
;
	LDA	FCB+1		; check the fcb for set option
	ANI	5FH		; force upper case
	CPI	'S'		; is it 's' or 'S'
	JNZ	TIM		; if not, tell time and exit
	CALL	SETTIM		; or do the set clock routines
;
;----------------------------------------------------------------------
;  Screen display time/date either plain, video, or 25th status line.
;
TIM:	CALL 	ILPRT		; print to Kaypro CRT
;
;  For video kaypro's only
	 IF	LINE25
	DB	1BH,'C7'	; disable 25th line
	DB	1AH		; clear screen/25th line
	DB	1BH,'B7'	; enable 25th line
	DB	1BH,'=8 '	; load cursor to 25,0
	 ENDIF
;
	 IF	VIDEO
	DB	1BH,'B0'	; inverse video ON
	DB	1BH,'B1'	; dim video on
	 ENDIF
;
	DB	' Time ',0	; print time/date line
	CALL	TELTIM		; tell the time
	JMP	EXIT		; and exit
;
; Read the clock digits from the buffer
;
TELTIM:
	CALL	RDMOD		; set chb to read mode
	LXI	H,TIME		; clock buffer
	MVI	C,13		; # bytes to read
TTLP:	MOV	A,L
	ANI	0FH		; mask off high nybble
	CALL	RDCLK
	MOV	M,A		; store it in clock buffer
	INX	H		; bump buffer ptr
	DCR	C		; finished?
	JNZ	TTLP		; guess not
;
; Output clock buffer to screen
;    hh:mm:ss  format
;
	LHLD	HOUR		; hours
	MOV	A,H		; 10's digit
	ANI	3		; mask hi bits
	CALL	ASCII		; to screen
	MOV	A,L		; 1's digit
	CALL	ASCII		; to screen
	MVI	A,':'		; separator
	CALL	TYPE		; to screen
	LHLD	MIN		; minutes
	MOV	A,H		; 10's digit
	CALL	ASCII		; to screen
	MOV	A,L		; 1's digit
	CALL	ASCII		; to screen
	MVI	A,':'		; separator
	CALL	TYPE		; to screen
	LHLD	SEC		; seconds
	MOV	A,H		; 10's digit
	CALL	ASCII		; to screen
	MOV	A,L		; 1's digit
	CALL	ASCII		; to screen
	MVI	A,' '		; space
	CALL	TYPE		; to screen
	MVI 	A,' '		; turn up a 
	CALL	TYPE		; blank space
	MVI	A,' '		; ditto
	CALL	TYPE
;
; Day of the week
	LDA	DAY		; varies from 0 - 6
	ANI	7		; mask hi bits
	MOV	L,A		; preset hl
	MVI	H,0
	DAD	H		; day * 2 for table offset
	LXI	D,DAYS		; point to days table
	DAD	D		; point to day of week
	MOV	E,M		; move pointer to de
	INX	H
	MOV	D,M
	MVI	C,CPRT		; print string
	CALL	BDOS		; print day of week
	MVI	A,' '		; print a
	CALL 	TYPE		; blank space
;
; Month of the year (varies from 1 to 12)
	LDA	MONTH+1		; 10's digit
	ANI	1		; is it October or later?
	JZ	MONT		; guess not
	MVI	A,10
MONT:	MOV	L,A		; A = 0 or 10
	MVI	H,0
	LDA	MONTH		; 1's digit
	ANI	0FH		; mask hi bits
	ADD	L
	MOV	L,A		; month in hl
	DCX	H		; rel zero for months table
	DAD	H		; times 2 for offset
	LXI	D,MONTHS	; point to table
	DAD	D		; point to month
	MOV	E,M		; move pointer to de
	INX	H
	MOV	D,M
	MVI	C,CPRT
	CALL	BDOS		; month to console
; Date of the month
	LHLD	DATE		; date of month
	MOV	A,H		; 10's digit
	ORA	A		; is it zero?
	JZ	DATL		; if so
	CALL	ASCII		; to screen if not
DATL:	MOV	A,L		; 1's digit
	CALL	ASCII		; to screen
	MVI	A,','		; space
	CALL	TYPE		; to screen
	mvi	a,' '		; print a
	call	type		; blank space
; Print year to console
	CALL	ILPRT
	DB	'19',0		; print century
	LDA	YEAR+1		; 10's digit
	CALL	ASCII		; to screen
	LDA	YEAR		; 1's digit
	CALL	ASCII		; to screen
	CALL	ILPRT		; print
;
;   For video kaypro
	 IF	VIDEO
	DB	' ',1BH,'C0'	; inverse video OFF
	DB	1BH,'C1'	; dim video off
	 ENDIF
	 IF	LINE25
	DB	1AH		; home cursor/clear screen
	 ENDIF
	DB	0
	RET			; to exit

SETTIM:
;
; Ask 'What time is it?'
;
	MVI	A,80H		; max console buffer length
	STA	CBUF		; init buffer length
	CALL	ILPRT		; print setting message
	DB	1AH			; clr screen
;
;   For video kaypro
	 IF 	VIDEO
	DB	1BH,'B0',1BH,'B1'	; clr screen/inverse video on
	DB	'      Set Kaypro Legacy Clock.   '
	DB	'Ver ',VER1+'0','.',VER2+'0'
	DB	1BH,'B2','       CTRL-C to Exit  '
	DB	1BH,'C0',1BH,'C1',1BH,'C2'	; inverse video & blinking off
	DB	CR,LF,LF
	 ENDIF
;
;  For regular kaypro
	 IF	(NOT VIDEO)
	DB	'      Set Kaypro Legacy Clock.   '
	DB	'Ver ',VER1+'0','.',VER2+'0'
	DB	'      CTRL-C to Exit  '
	DB	CR,LF,LF
	 ENDIF
;
;  For video kaypro
	 IF 	VIDEO
	DB	1BH,'B3'	; dim mode on
	DB	'Enter the year? (e.g. 86)                      '
	DB	1BH,'C3',' : ',0	; dim mode off
	 ENDIF
;
;  For non-video kaypro
	 IF	(NOT VIDEO)
	DB	'Enter the year? (e.g. 86)                      : ',0
	 ENDIF	
;
	LXI	D,CBUF		; console buffer
	MVI	C,RCONS		; read console buffer
	CALL	BDOS
	LDA	CBUF+1		; length
	ORA	A		; no entry?
	JZ	SMONTH		; next
	LXI	H,CBUF+2	; first digit
	MOV	A,M
	ANI	0FH		; strip ascii
	STA	YEAR+1		; store it
	INX	H		; next digit
	MOV	A,M
	ANI	0FH		; strip ascii
	STA	YEAR		; store it
;
SMONTH:
	CALL	ILPRT
	DB	CR,LF,CR,LF
;
;  For video kaypro
	 IF VIDEO
	DB	1BH,'B3'	; dim mode on
	DB	'Enter month? (Jan = 01, Feb = 02, etc.)        '
	DB	1BH,'C3',' : ',0	; dim mode off
	 ENDIF
;
;  For non-video kaypro
	 IF	(NOT VIDEO)
	DB	'Enter month? (Jan = 01, Feb = 02, etc.)        : ',0
	 ENDIF	
;
	LXI	D,CBUF
	MVI	C,RCONS
	CALL	BDOS
	LDA	CBUF+1
	ORA	A
	JZ	SDATE		; no month specified

	LDA	CBUF+2
	ANI	0FH
	STA	MONTH+1
	LDA	CBUF+3
	ANI	0FH
	STA	MONTH
;
SDATE:	CALL	ILPRT		; in-line print
	DB	CR,LF,CR,LF
;
;
;  For video kaypro
	 IF 	VIDEO
	DB	1BH,'B3'	; dim mode on
	DB	'Enter today''s date? (i.e. 01 to 31)            '
	DB	1BH,'C3',' : ',0	; dim mode off
	 ENDIF
;
;  For non-video kaypro
	 IF	(NOT VIDEO)
	DB	'Enter today''s date? (i.e. 01 to 31)            : ',0
	 ENDIF	
;
	LXI	D,CBUF		; console buffer
	MVI	C,RCONS
	CALL	BDOS
	LDA	CBUF+1
	ORA	A
	JZ	SDAY
;
	LDA	CBUF+2		; 10's digit
	ANI	0FH		; mask hi nybble
	STA	DATE+1
	LDA	CBUF+3
	ANI	0FH
	STA	DATE
;
SDAY:	CALL	ILPRT
	DB	CR,LF,CR,LF
;
;  For video kaypro
	 IF 	VIDEO
	DB	1BH,'B3'	; dim mode on
	DB	'Enter the day (Sun = 1, Mon = 2, etc.)         '
	DB	1BH,'C3',' : ',0	; dim mode off
	 ENDIF
;
;  For non-video kaypro
	 IF	(NOT VIDEO)
	DB	'Enter the day (Sun = 1, Mon = 2, etc.)         : ',0
	 ENDIF	
;
	LXI	D,CBUF
	MVI	C,RCONS
	CALL	BDOS
	LDA	CBUF+1
	ORA	A
	JZ	STIME		; no day specified
	LDA	CBUF+2
	ANI	0FH
	DCR	A		; rel 0
	STA	DAY
;
STIME:	CALL	ILPRT
	DB	CR,LF,CR,LF
;
;  For video kaypro
	 IF  VIDEO
	DB	1BH,'B3'	; dim mode on
	DB	'Enter current time (24-hour mode 1545 = 3:45p) '
	DB	1BH,'C3',' : ',0	; dim mode off
	 ENDIF
;
;  For non-video kaypro
	 IF	(NOT VIDEO)
	DB	'Enter current time (24-hour mode 1545 = 3:45p) : ',0
	 ENDIF	
;
	LXI	D,CBUF
	MVI	C,RCONS
	CALL	BDOS
	LDA	CBUF+1
	ORA	A
	JZ	SETCLK		; no time specified
	LDA	CBUF+2
	ANI	0FH
	ORI	8		; 24 hour format
	STA	HOUR+1
	LDA	CBUF+3
	ANI	0FH
	STA	HOUR
	LDA	CBUF+4
	ANI	0FH
	STA	MIN+1
	LDA	CBUF+5
	ANI	0FH
	STA	MIN
	CALL	ILPRT		;LINE FEED THEN PRINT
	DB	CR,LF,CR,LF,LF,0
;
;  Write the time buffer to the clock
;
SETCLK: CALL	WRMOD
	LXI	H,TIME
	MVI	C,13
STCLK1:	MOV	E,M
	MOV	A,L
	ANI	0FH
	CALL	WRCLK
	INX	H
	DCR	C
	JNZ	STCLK1
	RET
;
ILPRT:	POP	H		; hl points to string
ILP1:	MOV	A,M		; get the character
	INX	H		; point to next character
	ORA	A		; is this the zero terminator?
	JZ	ILEX		; yep. we'RE DONE
	CALL	TYPE		; to screen
	JMP	ILP1		; do it again
ILEX:	PCHL			; jump to instruction following string
;
ASCII:	ADI	30H		; binary to ascii
TYPE:	PUSH	PSW		; out to screen, saving all registers
	PUSH	H
	PUSH	D
	PUSH	B
	MOV	E,A
	MVI	C,CONO		; console output
	CALL	BDOS
	POP	B
	POP	D
	POP	H
	POP	PSW
	RET
;
RDCLK:		; FOR KCLOCK
	push	psw		; save address
	call	wrmod		; setup pio
	pop	psw
	ori	hold+80h	; add hold and address gate bit
	out	bdata		; set address and gate
	ani	7fh		; reset gate bit
	out	bdata		; address is now latched
	call	wait		; 150 usec to establish hold
	call	rdmod		; setup to read lo nybble
	mvi	a,hold+rd	; add read command to hold
	out	bdata
	call	wait1		; wait 6 usec
	in	bdata		; read clock
	ani	0fh		; mask hi nybble
	push	psw		; save it
	xra	a		; clear a
	out	bdata		; release hold
	pop	psw		; restore clock data
	ret
;
wrclk:		; for KClock
	push	psw		; save address
	call	wrmod
	pop	psw
	ori	hold+80h	; hold plus address gate bit
	out	bdata
	ANI	7FH		; reset gate bit
	out	bdata
	call	wait		; wait 150 usec to establish hold
	mvi	a,hold+wr	; add write command to hold
	ORA	e		; data to write
	out	bdata
	PUSH	PSW
	call	wait1		; wait 6 usec
	POP	PSW
	XRI	WR		; turn off write command
	OUT	BDATA
	xra	a		; clear a
	out	bdata		; release hold
	ret
;
; set port b to write the clock
WRMOD:	MVI	A,MODE3		; control mode
	OUT	BCMND
	MVI	A,0		; write to clock
	OUT	BCMND
	RET
;
; set port b to read the clock
RDMOD:	MVI	A,MODE3		; control mode
	OUT	BCMND
	MVI	A,0FH		; to read clock
	OUT	BCMND
	RET
;
wait:		; 150 usec timing loop
	mvi	a,54		; loop control
w0:	dcr	a
	jnz	w0
	ret
;
wait1:		; 6 usec timing loop
	mvi	a,3
	jmp	w0
;
EXIT:	LHLD	STACK
	SPHL
	RET
;
TIME:	EQU	$+15 AND 0FFF0H	; 16-byte boundary
	ORG	TIME
SEC:	DS	2		; seconds
MIN:	DS	2		; minutes
HOUR:	DS	2
DAY:	DS	1		; day of week
DATE:	DS	2
MONTH:	DS	2
YEAR:	DS	2
;
DAYS:	DW	SUN
	DW	MON
	DW	TUE
	DW	WED
	DW	THU
	DW	FRI
	DW	SAT
;
SUN	DB	'Sunday $'
MON	DB	'Monday $'
TUE	DB	'Tuesday $'
WED	DB	'Wednesday $'
THU	DB	'Thursday $'
FRI	DB	'Friday $'
SAT	DB	'Saturday $'
;
MONTHS:	DW	JAN
	DW	FEB
	DW	MAR
	DW	APR
	DW	MAY
	DW	JUN
	DW	JUL
	DW	AUG
	DW	SEP
	DW	OCT
	DW	NOV
	DW	DEC
;
JAN	DB	'January $'
FEB	DB	'February $'
MAR	DB	'March $'
APR	DB	'April $'
MAY	DB	'May $'
JUN	DB	'June $'
JUL	DB	'July $'
AUG	DB	'August $'
SEP	DB	'September $'
OCT	DB	'October $'
NOV	DB	'November $'
DEC	DB	'December $'
;
	DS	32
STACK:	END	START
