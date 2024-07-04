;   COPYRIGHT 1984 BY JOHN M. BLALOCK

;   ####################################
;   ##				      ##
;   ##		GETIT.ASM	      ##
;   ##				      ##
;   ##	    Written by: 	      ##
;   ##				      ##
;   ##		John M. Blalock       ##
;   ##		April 22, 1984	      ##
;   ##				      ##
;   ####################################

; This	program  is a very simple CP/M terminal  and  ASCII
; text	 capture   program.    Once  customized  for   your
; particular computer, it will enable you to communicate to
; another computer via a serial port.	It is expected that
; the serial port will be connected to a modem.  GETIT will
; allow  you  to  transfer  ASCII  files  from	the  remote
; computer  to	yours  and save them on disk as long as the
; files  are no larger than the available  capture  buffer.
; Longer  files  will  have to be broken  up  into  smaller
; segments and recombined on your computer with PIP.

; Once you have established communications with the  remote
; computer,  entering  Ctl-Y  from your console will  cause
; GETIT  to start saving text sent from the remote computer
; into	a RAM buffer that starts at  0100H.   This  capture
; function can be toggled on and/or off by subsequent entry
; of another Ctl-Y.  An ASCII BELL character is sent to the
; console  when capture is toggled on,	and nothing is sent
; when it is toggled off.

; Entering  Ctl-E  will cause GETIT to exit to	CP/M  after
; first  telling  you the decimal number of  pages  in	the
; capture buffer.   GETIT will also exit when the buffer is
; filled.  An  X-OFF  (Ctl-S) is first sent to	the  remote
; computer  that will stop further output by it as long  as
; it supports the X-ON/X-OFF protocol.	 The captured  data
; will be in your RAM starting at 0100H and can be saved to
; disk	by  entering SAVE nn FILENAME.EXT where nn  is	the
; number of pages GETIT told you to SAVE.

; GETIT  is  purposefully  short and simple  to  facilitate
; entry  of its source code from the keyboard.	 Leave	out
; the comments - you have them here.   Probably  the  first
; thing for which you will want to use it (and perhaps	its
; only	use)  is  to  download	a  better,   more   capable
; communications  program.   But it does solve the Catch-22
; problem of not being able to download any  communications
; program  because  you don't have any to start  with.   If 
; MDM730.HEX is available on the remote  computer,  capture
; it  with  GETIT,  LOAD  it,  and  now  you  have  a  good
; communications program.

; GETIT  is released for use in the public domain for  non-
; profit usage only.   If it helps you sell your product, I
; would like to share in the profits.  If you sell GETIT, I
; want all the profits.   Any questions should be addressed
; to John Blalock,  Blalock and Associates,  PO Box  39356,
; Phoenix, AZ 85069.  Include an SASE if you want a reply.


; MODEM CONSTANTS - You will need to change these to  match
; your particular UART.  If your UART transmit buffer empty
; and/or receive data available bits are low  true,  you'll
; have to change the conditional jumps that test these bits
; from JNZ to JZ  and  from  JZ to JNZ.  The affected lines
; are marked with an asterick (*) in the comments below.

MDATA	EQU	080H		;MODEM DATA PORT
MSTAT	EQU	081H		;MODEM STATUS PORT
TXRDY	EQU	001H		;TX BUFFER EMPTY BIT
RXRDY	EQU	002H		;RX DATA AVAILABLE BIT


; Equate DEST to 0C0H bytes or more  below  the CCP in your
; version of CP/M.   The  higher  it  is,  the	larger	the
; capture buffer will be.  I have 52.5K bytes  available in
; the capture buffer  with  my	version  of  CP/M  and	the
; following DEST value.

DEST	EQU	0D340H		;PROGRAM IS RELOCATED TO HERE

; The following equates shouldn't require any changes for a
; standard CP/M system.

BASE	EQU	0000H		;CP/M BASE ADDRESS
BUFF	EQU	BASE + 0100H	;CAPTURE BUFFER START ADDRESS
BDOS	EQU	0005H		;BDOS ENTRY ADDRESS
CAPT	EQU	'Y'-40H		;CTL-Y = START/STOP CAPTURE
EXIT	EQU	'E'-40H		;CTL-E = STOP, EXIT TO CP/M
BELL	EQU	07H		;BEEP THE CONSOLE
CR	EQU	0DH		;ASCII CARRIAGE RETURN
LF	EQU	0AH		;ASCII LINE FEED

	ORG	BUFF		;PROGRAM STARTS HERE

BEGIN	LDA	BASE+2		;GET BIOS PAGE NUMBER AND
	STA	PCONST+2	; PATCH PROGRAM WITH YOUR
	STA	PCONIN+2	; BIOS ENTRY ADDRESSES
	STA	PCONOUT+2
INIT	;Insert here any code required to initialize your
	;UART if it is not already initialized by some
	;other program or your CP/M cold boot routine.
BMOVE	LXI	D,DEST		;BLOCK MOVE DESTINATION
	LXI	H,START		;FIRST ADDRESS TO MOVE
	MVI	C,PEND-START	;NUMBER OF BYTES TO MOVE
MVLOOP	MOV	A,M		;GET A BYTE
	STAX	D		;MOVE IT
	INX	H		;BUMP POINTERS
	INX	D
	DCR	C		;COUNT THE BYTE
	JNZ	MVLOOP		;LOOP 'TIL DONE
	JMP	GETIT		;NOW GO RUN THE PROGRAM
START	EQU	$		;START OF RELOCATED CODE
OFFSET	EQU	DEST-START	;PROGRAM OFFSET AMOUNT
GETIT	EQU	$+OFFSET	;PROGRAM START IN HI MEMORY
	LXI	H,BUFF		;INITIALIZE BUFFER POINTER
GETLP	EQU	$+OFFSET	;MAIN PROGRAM LOOP
	IN	MSTAT		;GET MODEM STATUS
	ANI	RXRDY		;DATA AVAILABLE ?
	JNZ	RXDRDY		;YES, THEN JUMP 	   *
	CALL	CONST		;NO, CHECK KEYBOARD
	ORA	A		;ANYTHING TYPED ?
	JZ	GETLP		;NO, THEN LOOP FOREVER
	CALL	CONIN		;YES, GET IT
	CPI	CAPT		;CTL-Y ?
	JZ	TOGCAPT		;YES, TOGGLE CAPTURE FLAG
	CPI	EXIT		;CTL-E ?
	JZ	ENDIT1		;YES, WE'RE DONE FOR NOW
	MOV	C,A		;NO, MOVE CHARACTER TO C
	CALL	SENDIT		;SEND THE CHARACTER
	JMP	GETLP		;LOOP FOREVER
SENDIT	EQU	$+OFFSET	;SEND (C) TO MODEM
	IN	MSTAT		;GET MODEM STATUS
	ANI	TXRDY		;TX BUFFER EMPTY ?
	JZ	SENDIT		;NO, LOOP UNTIL EMPTY	   *
	MOV	A,C		;CHAR TO REG A
	OUT	MDATA		;SEND TO MODEM
	RET
RXDRDY	EQU	$+OFFSET	;RX DATA IS AVAILABLE
	IN	MDATA		;GET MODEM CHARACTER
	ANI	7FH		;CLEAR PARITY BIT
	MOV	C,A		;PUT IN REG C
	LDA	CAPTFG		;GET CAPTURE FLAG
	ORA	A		;WANT TO SAVE IT ?
	JZ	NOSAVE		;NO, THEN DON'T SAVE
	MOV	M,C		;YES, PUT CHAR IN MEMORY
	INX	H		;INCREMENT POINTER
	MOV	A,H		;CHECK FOR TOO FAR
	CPI	DEST SHR 8	;CAN'T SAVE THIS MUCH
	JZ	ENDIT		;EXIT IF BUFFER IS FULL
	;Insert "  JMP	GETLP" here if using a slow console.
	;You won't see the data as it's being saved, but
	;you'll get it without missing characters.
NOSAVE	EQU	$+OFFSET	;NOT SAVING OR NOT FULL
	CALL	CONOUT		;DISPLAY RECEIVED CHAR
	JMP	GETLP		;AND LOOP SOME MORE
TOGCAPT	EQU	$+OFFSET	;TOGGLE CAPTURE FLAG
	LDA	CAPTFG		;GET IT
	CMA			;COMPLEMENT IT
	STA	CAPTFG		;RESTORE FLAG
	ORA	A		;CAPTURE NOW ON ?
	JZ	GETLP		;NO, BACK TO LOOPING
	MVI	C,BELL		;YES, TELL USER CAPTURE
	CALL	CONOUT		; HAS BEEN TOGGLED ON
	JMP	GETLP		;BACK TO LOOPING
ENDIT	EQU	$+OFFSET	;BUFFER FULL, GO TO CP/M
	MVI	C,'S'-40H	;STOP OUTPUT IF POSSIBLE
	CALL	SENDIT		; WITH A CTL-S
ENDIT1	EQU	$+OFFSET	;ENTER HERE TO EXIT W/O ^S
	MVI	A,'Z'-40H	;END OF FILE FLAG
	MOV	M,A		;SAVE IN BUFFER
	MOV	A,H		;GET NUM OF PAGES TO SAVE
	PUSH	PSW		;SAVE ON STACK
	LXI	D,SAVE		;POINT DE TO "SAVE" MESSAGE
	MVI	C,9		;PRINT STRING FUNCTION
	CALL	BDOS		;PRINT EXITING MESSAGE
	POP	PSW		;RESTORE NUMBER OF PAGES
	MVI	C,'0'		;INIT HUNDREDS DIGIT
HUND	EQU	$+OFFSET	;LOOP HERE 'TIL < 100
	SUI	100		;ANY HUNDREDS DIGITS?
	JC	TENS		;NO, CHECK TENS
	INR	C		;YES, BUMP HUNDREDS DIGIT
	JMP	HUND		;ANY MORE HUNDREDS ?
TENS	EQU	$+OFFSET	;NO MORE HUNDREDS
	ADI	100		;PUT BACK 100
	PUSH	PSW		;SAVE COUNT
	CALL	CONOUT		;PRINT HUNDREDS DIGIT
	POP	PSW		;RESTORE COUNT
	MVI	C,'0'		;INIT TENS DIGIT
TEN1	EQU	$+OFFSET	;LOOP HERE 'TIL < 10
	SUI	10		;ANY TENS DIGITS?
	JC	ONES		;NO, CHECK ONES
	INR	C		;YES, BUMP TENS DIGIT
	JMP	TEN1		;ANY MORE TENS?
ONES	EQU	$+OFFSET	;NO MORE TENS
	ADI	10+'0'		;PUT BACK 10, ADD ASCII BIAS
	PUSH	PSW		;SAVE NUMBER
	CALL	CONOUT		;PRINT TENS DIGIT
	POP	PSW		;RESTORE ONES DIGIT
	MOV	C,A		;PASS TO CONOUT IN REG C
	CALL	CONOUT		;PRINT ONES DIGIT
	RET			;BACK TO CP/M
CONST	EQU	$+OFFSET	;PATCHED BY PROGRAM TO
PCONST	JMP	BASE+6H		; YOUR BIOS CONST ADDRESS
CONIN	EQU	$+OFFSET	;PATCHED BY PROGRAM TO
PCONIN	JMP	BASE+9H		; YOUR BIOS CONIN ADDRESS
CONOUT	EQU	$+OFFSET	;PATCHED BY PROGRAM TO
PCONOUT	JMP	BASE+0CH	; YOUR BIOS CONOUT ADDRESS
SAVE	EQU	$+OFFSET	;EXITING MESSAGE
	DB	BELL,CR,LF,LF,'GETIT exiting, SAVE $'
CAPTFG	EQU	$+OFFSET	;CAPTURE FLAG
	DB	0		;00 = NO CAPTURE, DEFAULT
PEND	EQU	$		;END OF RELOCATED PROGRAM
	END
