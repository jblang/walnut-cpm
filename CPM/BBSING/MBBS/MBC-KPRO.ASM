;
;**********************************************************************
;
; MBC-KPRO.ASM -- Version 1.0 -- 03/01/84 -- by Kim Levitt
;
;	CLOCK routine for MBYE running on Kaypro 2 with Pro-Clock
;	(adapted from Kaypro Pro-Clock driver written by Greg Haerr)
;
;	This overlay is designed to work on a Kaypro II running MBYE
;	and equipped with a Business Computer Systems Pro-Clock RTC.
;	(Use the DATE program to initialize the clock outside of BYE.)
;	(BCS address: 5350 South 3600 West; Salt Lake City, UT 84118)
;
;	When called this routine will check the RTCBUF. If a '99H'
;	is in the first byte, the clock is initialized. Next the
;	seconds are checked, and if changed since last update of
;	RTC buffer, the clock is stopped, data copied to RTCBUF and
;	the clock is restarted. (If no change in seconds, the
;	routine returns immediately.)
;
;**********************************************************************
;
CLOCK:
	PUSH	PSW		; save ALL regs that are used
	PUSH	B
	PUSH	H
	LDA	RTCBUF		; get first BCD byte
	CPI	099H		; 99 ?
	CZ	CLKINIT		; if so, init clock...
	CALL	HOLDON		; put clock on hold
	MVI	C,0		; check low seconds
	CALL	RDPIO		; to see if change...
	LXI	H,RTCBUF+2	; compared to old secs
	XRA	M		; value stored in
	ANI	0FH		; RTC buffer (low nibble)
	JZ	CLKEXIT		; if no change, skip update
	MVI	C,5		; start with hi hours
	LXI	H,RTCBUF	; and copy to RTCBUF
	CALL	GETCLK		; (get time)
	MVI	C,12		; start with hi year
	LXI	H,RTCBUF+4	; and copy to RTCBUF
	CALL	GETCLK		; (and date)
	LDA	RTCBUF		; get hours
	ANI	03FH		; mask out PM/24 hour bits
	STA	RTCBUF
	LDA	RTCBUF+6	; get day
	ANI	03FH		; mask out leap year bit
 	STA	RTCBUF+6
CLKEXIT:
	MVI	C,13		; set clock addr. to
	CALL	WRADDR		; junk location so no data cleared
	CALL	HOLDOFF		; when we take clock off hold..
	POP	H		; restore ALL regs
	POP	B
	POP	PSW
	RET			; and return (for now..)
;
GETCLK:
	MVI	B,3		; repeat 3 times for 3 BCD bytes
CLKLP:
	CALL	RDPIO		; get data at address C
	RLC ! RLC ! RLC ! RLC	; move to high nibble for BCD
	MOV	M,A		; save at location temporarily
	DCR	C		; decrement clock addr
	CALL	RDPIO		; get data at next address
	ORA	M		; OR with previously saved data
	MOV	M,A		; and save it
	DCR	C		; decrement clock addr
	INX	H		; increment to next BCD byte
	DCR	B		; decrement BCD counter
	JNZ	CLKLP		; if 3rd BCD byte, done..
	RET			; return
;
; PIO STUFF
;
MODE3	EQU	0CFH	; bit control mode
;
DATA	EQU	0AH	; port B data
CMD	EQU	0BH	; port B cmd
;
; mask values for clock chip
;
LATCH	EQU	80H	; set address latch (active high)
WR	EQU	40H	; write (active high)
RD	EQU	20H	; read (active high)
HOLD	EQU	10H	; time hold (active high)
;
CLKINIT:
	MVI	A,7		; disable interrupts
	OUT	CMD
;
; fall into set output 
;
; set output mode
;
SETOUT:
	LDA	FLAG		; get current state
	OUT	DATA		; preset data register
	MVI	A,MODE3		; set bit control mode
	OUT	CMD
	XRA	A		; set all outputs mask
	OUT	CMD
	LDA	FLAG
	OUT	DATA
	RET
;
; set input mode
;
SETIN:
	LDA	FLAG		; get current state
	ORI	RD		; set read line
	OUT	DATA
	MVI	A,MODE3
	OUT	CMD
	MVI	A,0FH		; d7-d4 are still output, mask em'
	OUT	CMD
	LDA	FLAG
	ORI	RD
	OUT	DATA
	XCHG ! XCHG		; delay for 6 uS min.
	RET
;
; send data in A to address in C
;
WRPIO:
	MOV	B,A		; save data in B
	CALL	WRADDR		; set address
	MOV	A,B		; fall into write data
;
; write data in A
;
WRDATA:
	MOV	C,A		; save in C
	LDA	FLAG		; get current flag
	ORA	C		; or in data
	OUT	DATA
	ORI	WR		; and write it
	OUT	DATA
	NOP			; delay for 1 uS min
	NOP
	ANI	(NOT WR) AND 0FFH	; reset write
	OUT	DATA
	RET
;
; read data into A from address in C
;
RDPIO:
	PUSH	B
	CALL	WRADDR		; set address
;
; fall into read data
;
; read data into A
;
RDDATA:
	CALL	SETIN		; set input mode
	IN	DATA		; input data
	ANI	0FH		; just in case
	MOV	C,A		; save in C
	CALL	SETOUT		; set to output mode
	MOV	A,C		; get saved data
	POP	B		; restore BC
	RET
;
; latch address in C
;
WRADDR:
	LDA	FLAG		; get current flag
	ORA	C		; or in address
	OUT	DATA		; send address
	ORI	LATCH		; set latch
	OUT	DATA		; and latch it
	ANI	(NOT LATCH) AND 0FFH
	OUT	DATA
	RET
;
HOLDON:
	MVI	A,HOLD		; set hold flag
	STA	FLAG
	CALL	WRDATA
HOLD0:
	MVI	B,20		; wait 150 uS
HOLD1:
	XCHG ! XCHG
	DCR	B
	JNZ	HOLD1
	RET
;
HOLDOFF:
	XRA	A		; reset hold flag
	STA	FLAG
	JMP	WRDATA
;
FLAG:	DB	0		; current hold/nohold status flag
;
;**********************************************************************
;
; This is the end of the CLOCK routine overlay for MBYE-31. If you
; include this after your modem overlay, and have a Kaypro 2 equipped
; with a Pro-Clock, it SHOULD work fine...
;
;**********************************************************************
;
