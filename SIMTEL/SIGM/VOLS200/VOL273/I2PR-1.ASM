; I2PR-1 FOR IMP-244	 11/18/85
;
; Adapts a Penril 1200-AD modem to IMP244.  The alternate long-distance
; routines routines have not been patched to work with the Penril modem.
;
;					- Frank Sauciunas
;					  Voice 504-261-4035
;
BDOS	EQU	05H
BELL	EQU	07H
LF	EQU	0AH
CR	EQU	0DH
LIBLEN	EQU	22H
INBUFF	EQU	80H
TCHPUL	EQU	010FH
EXTCHR	EQU	0114H
ILPRT	EQU	017DH
INBUF	EQU	0180H
INMDM	EQU	0186H
SNDCHR	EQU	018CH
SNDSTR	EQU	018FH
TIMER	EQU	0192H
ALTDL1	EQU	0BCEH
ALTDL2	EQU	0BE6H
HEXSHOW	EQU	0BFEH
NUMBLIB	EQU	0C00H
TERML	EQU	17F1H
MDRCV	EQU	1ED1H
CRLF	EQU	2DB7H
STAT	EQU	2DC4H
KEYIN	EQU	2DCFH
TYPE	EQU	2DD9H
DECOUT	EQU	2DFDH
MOVE	EQU	2EC0H
KBDCHR	EQU	2EFEH
INLNCP	EQU	32C8H
MOVER	EQU	3397H
MENU	EQU	3626H
MDMSPD	EQU	45ECH
NEWLINE	EQU	4727H
SPACES	EQU	4730H
CLRTST	EQU	476EH
A$FLAG	EQU	489AH
B$FLAG	EQU	48A4H
CMDBUF	EQU	48B9H
C$FLAG	EQU	48FAH
STACK	EQU	4AFEH
BUFFER	EQU	4E00H
;
;
	ORG	0400H
;
;
; DIAL to DIAL15 are untouched except for calls, jumps, etc.
;
DIAL:	XRA	A
	STA	FLAG2
	STA	FLAG3
	STA	B$FLAG
	LXI	H,0000H
	SHLD	A$FLAG
	LXI	H,CMDBUF+1
	MOV	A,M
	CPI	4
	JC	DIAL2
	MOV	C,A
	MVI	B,0
	SUI	4
	MOV	M,A
	INX	H
	XCHG
	LXI	H,CMDBUF+6
	CALL	MOVER
	JMP	DIAL4
;
DIAL2:	MVI	C,12H
	LXI	H,NUMBLIB
	LXI	D,BUFFER
	CALL	NEWLINE
	STAX	D
	INX	D
;
DIAL3:	MVI	B,LIBLEN
	CALL	MOVE
	CALL	SPACES
	PUSH	H
	PUSH	D
	LXI	D,(17*LIBLEN)
	DAD	D
	POP	D
	MVI	B,LIBLEN
	CALL	MOVE
	POP	H
	CALL	NEWLINE
	DCR	C
	JNZ	DIAL3
	MVI	A,'$'
	STAX	D
	CALL	CLRTST
	MVI	C,9
	LXI	D,BUFFER
	CALL	BDOS
	CALL	ILPRT
	DB	CR,LF,'Enter library code '
	DB	'or phone number,',CR,LF
	DB	'Hit RET to abort this function '
	DB	'now or',CR,LF,'CTL-X quits '
	DB	'while dialing or ringing: '
	DB	0
	LXI	D,CMDBUF
	CALL	INBUF
;
DIAL4:	LXI	H,CMDBUF+1
	MOV	A,M
	ORA	A
	JZ	DIALEXIT
	STA	FLAG4
	LDA	CMDBUF+3
	CPI	'/'
	CZ	LDCMDBF
	CPI	','
	CZ	LDCMDBF1
	CALL	SETSPD
;
DIAL4A:	XRA	A
	STA	FLAG1
	LDA	FLAG3
	ORA	A
	JNZ	GOT$NO
	LDA	FLAG4
	STA	CMDBUF+1
	CPI	2
	JNC	DIAL12
	LXI	H,CMDBUF+2
;
DIAL5:	MOV	A,M
	MVI	B,'A'
	MVI	E,0
	MVI	C,1AH
;
DIAL6:	CMP	B
	JZ	DIAL8
	INR	B
	INR	E
	DCR	C
	JNZ	DIAL6
	MVI	B,'0'
	MVI	E,1AH
	MVI	C,0AH
;
DIAL7:	CMP	B
	JZ	DIAL8
	INR	B
	INR	E
	DCR	C
	JNZ	DIAL7
	JMP	DIALBAD
;
DIAL8:	LXI	H,NUMBLIB
	LXI	B,LIBLEN
	MOV	A,E
	ORA	A
	JZ	DIAL10
;
DIAL9:	MOV	A,M
	ORA	A
	JZ	DIALBAD
	DAD	B
	DCR	E
	JNZ	DIAL9
;
DIAL10:	MVI	B,LIBLEN
	LXI	D,CMDBUF+1
	XCHG
	MOV	M,B
	XCHG
	INX	D
	CALL	MOVE
	LXI	H,CMDBUF+1
	MOV	E,M
	INX	H
;
DIAL11:	MOV	A,M
	CALL	TYPE
	INX	H
	DCR	E
	JZ	DIALEXIT
	CPI	'.'
	JZ	DIAL13
	JMP	DIAL11
;
DIAL12:	LXI	H,CMDBUF+1
	MOV	A,M
	MOV	E,M
	INX	H
;
DIAL13:	PUSH	H
	CALL	WAKEUP
	POP	H
;
DIAL13A:MOV	A,M
	ORA	A
	JZ	DIALBAD
	CALL	DIALA
	CALL	STAT
	JZ	DIAL15
	CALL	KEYIN
	CPI	18H
	JZ	DIAL14
	MOV	B,A
	LDA	EXTCHR
	CMP	B
	JNZ	DIAL15
;
DIAL14:	MVI	B,CR
	CALL	SNDCHR
	JMP	DIALEXIT
;.....
;
;
;***********************************
;
DIAL15:	INX	H
	DCR	E
	JNZ	DIAL13A
	MVI	B,CR
	CALL	SNDCHR
	CALL	INMDM
	CALL	ILPRT
	DB	' - try #',0
	LHLD	A$FLAG
	INX	H
	SHLD	A$FLAG
	CALL	DECOUT
	MVI	A,' '
	CALL	TYPE
	JMP	SMRESULT
;.....
;
;
BSYANSR:LXI	SP,STACK
	XRA	A
	STA	FLAG5
	LDA	B$FLAG
	ORA	A
	JNZ	DIALAGN2
	CALL	ILPRT
	DB	CR,LF,CR,LF,'     Redial? '
	DB	'(C/Y/N): ',BELL,0
	CALL	KBDCHR
	PUSH	PSW
	CALL	CRLF
	POP	PSW
	CPI	'Y'
	JZ	DIALAGN2
	CPI	'C'
	JNZ	DIALEXT1
	MVI	A,1
	STA	B$FLAG
;
DIALAGN2:
	CALL	CRLF
	JMP	DIAL4A
;
DIALA:	CALL	TYPE
	MOV	B,A
	CALL	DIALAD
	MOV	A,B
;
;
; Penril accepts the following codes withing the phone numbers.
;
;	(R)otary must preceed the number
;	(T)one	 is not needed if modem switches are set for tone
;
DIALA1:	CPI	'*'		; Star
	JZ	DIALA2
	CPI	'#'		; Pound
	JZ	DIALA2
	CPI	'-'		; Dash
	JZ	DIALA2
	CPI	'P'		; Pause 2 sec
	JZ	DIALA2
	CPI	'R'		; Rotory
	JZ	DIALA2
	CPI	'T'		; Tone
	JZ	DIALA2
	CPI	'W'		; Wait for
	JZ	DIALA2		; Dial tone.
	CPI	'0'
	RC			; Zero
	CPI	':'		; Through
	RNC			; Nine ok.
;
DIALA2:	CALL	SNDCHR
	JMP	INMDM		; Eat char.
;.....
;
;
DIALBAD:CALL	ILPRT
	DB	CR,LF,CR,LF,'++ Bad library '
	DB	'number called ++',CR,LF
	DB	0
;
DIALEXIT:
	CALL	CRLF
;
DIALEXT1:
	LXI	SP,STACK
	CALL	MDQUIT
	XRA	A
	STA	B$FLAG
	JMP	MENU
;.....
;
;
; Alternate dial has not been modified to work with a Penril
;
DIALAD:	LDA	TCHPUL
	CPI	'T'
	RNZ
	MOV	A,B
	CPI	'<'
	JNZ	DIALAD1
	PUSH	H
	LXI	H,ALTDL1
	JMP	DIALAD2
;
DIALAD1:CPI	'>'
	RNZ
	PUSH	H
	LXI	H,ALTDL2
;
DIALAD2:MOV	A,M
	CPI	'$'
	JZ	DIALAD3
	CALL	TYPE
	MOV	B,A
	CALL	DIALA1
	INX	H
	CALL	CKSTAT
	JMP	DIALAD2
;
DIALAD3:MVI	A,' '
	MOV	B,A
	CALL	TYPE
	POP	H
	RET
;
CKSTAT:	CALL	STAT
	RZ
	CALL	KEYIN
	CPI	18H
	JZ	CKSTAT1
	MOV	B,A
	LDA	EXTCHR
	CMP	B
	MOV	A,B
	JZ	CKSTAT1
	CPI	0BH
	RNZ
	MVI	B,CR
	CALL	SNDCHR
	MVI	B,0AH
	CALL	TIMER
	POP	H
	JMP	BSYANSR
;
CKSTAT1:POP	H
	JMP	DIALEXIT
;
INMODEM:CALL	INMDM
	JNC	INMODEM
	RET
;
CLRBUF:	MVI	B,50H
	LXI	H,INBUFF
;
CLRBLP:	MVI	M,' '
	INX	H
	DCR	B
	JNZ	CLRBLP
	RET
;
SETSPD:	CALL	MDMSPD
	CALL	CRLF
	RET
;
;
; This routine wakes up the Penril
;
WAKEUP:	MVI	B,CR		; Wakeup
	CALL	SNDCHR		; Modem.
;
;
; Wait for Penril to send out its logo
;
WAKE1:	 CALL	INMDM
	JC	WAKE1
	CPI	'>'		; Prompt
	JNZ	WAKE1
;
;
; Delay and send 'K' to start keyboard phone number entry
;
	MVI	B,02
	CALL	TIMER
	MVI	B,'K'		; Kybd
	CALL	SNDCHR
;
;
; Wait for Penril to send number mesage
;
;	---> NO:_ <---
;
WAKE2:	CALL	INMDM
	JC	WAKE2
	CPI	' '		; No:_
	JNZ	WAKE2
	MVI	B,02
	JMP	TIMER
;
MDQUIT:	MVI	B,CR		; Kill
	CALL	SNDCHR		; Modem
	MVI	B,10		; 1 sec.
	CALL	TIMER
	RET
;
;
; The real fun starts here
;
SMRESULT:
	CALL	CLRBUF
	LXI	H,INBUFF
	PUSH	H
	LXI	D,0400H		; Loop
;
RESULT1:CALL	MDRCV
	JZ	RESULT2
	CALL	CKSTAT
	CALL	INMDM
	JNC	PRTEST
	DCX	D
	MOV	A,D
	ORA	E
	JNZ	RESULT1
	POP	H
	JMP	ABORTIT
;
RESULT2:CALL	INMDM
	JC	TSTMDM
;
PRTEST:	ANI	7FH
	CPI	CR		; Ignore CR
	JZ	RESULT2
	CPI	LF		; Ignore LF
	JZ	RESULT2
	POP	H
	MOV	M,A
	INX	H
	PUSH	H
	JMP	RESULT2
;
;
; The following are messages that the Penril modem sends to the system
;
TSTMDM:	POP	H		; Penril
	LXI	D,INBUFF	; Replies
	CALL	INLNCP
	DB	'OK',0		; Answered
	JNC	ANSWER
	CALL	INLNCP
	DB	'BUSY',0	; Busy
	JNC	PHBUSY
	CALL	INLNCP
	DB	'DIALING: ',0	; Dialing
	JNC	DIALIT
	CALL	INLNCP
	DB	'NO CD',0	; No carrier
	JNC	NOCRD
	CALL	INLNCP
	DB	'NO ANSWER',0	; No answer
	JNC	NOANSWR
	CALL	INLNCP
	DB	'NO RING',0	; No ring
	JNC	ABORTIT
	CALL	INLNCP
	DB	'ABORT',0	; Abort
	JNC	ABORTIT
	CALL	INLNCP
	DB	'ERROR',0	; Error
	JNC	ABORTIT
	CALL	INLNCP
	DB	'NO DIAL TONE',0
	JNC	NODIALT
	JMP	ABORTIT
;
;
; replies to Penril messages
;
NOANSWR:CALL	ILPRT
	DB	'no answer! ',0
	JMP	BSYANSR
;
NOCRD:	CALL	ILPRT
	DB	'no carrier detected! ',0
	JNC	ABORTIT
;
PHBUSY:	CALL	ILPRT
	DB	'busy! ',0
	LDA	HEXSHOW
	MOV	B,A
	CALL	TIMER
	JMP	BSYANSR
;
;
; This routine eats the numbers that the Penril sends out when it is
; doing the dialing.  ---> DIALING: 15045551212 <---  It also puts de-
; lays between numbers and times out when no more numbers are being sent
; from the Penril.
;
DIALIT:	CALL	ILPRT
	DB	'dialing, ',0
	LXI	D,0C000H	; Timer
;
EATWT:	CALL	MDRCV		; Wait for
	JZ	EATIT		; Numbers
	DCX	D
	MOV	A,D
	ORA	E
	JNZ	EATWT
	JMP	SMRESULT	; Timeout
;
EATIT:	CALL	INMDM		; Eat numbers
	LXI	D,0C000H	; Reset timer
	JMP	EATWT
;
ANSWER:	CALL	ILPRT
	DB	CR,LF,CR,LF
	DB	'<<<<-- CONNECTED -->>>>'
	DB	BELL,0
	JMP	TERML
;
ABORTIT:CALL	ILPRT
	DB	' <ABORT>',BELL,0
	LDA	HEXSHOW
	MOV	B,A
	CALL	TIMER
	JMP	BSYANSR
;
NODIALT:CALL	ILPRT
	DB	'no dial tone! ',0
	JMP	ABORTIT
;
LDCMDBF:STA	FLAG2
;
LDCMDBF1:
	MVI	A,0FFH
	STA	FLAG3
	STA	B$FLAG
	MVI	B,40H
	LXI	H,CMDBUF+1
	LXI	D,C$FLAG
	JMP	MOVE
;
GOT$NO:	LDA	FLAG3
	INR	A
	INR	A
	STA	FLAG3
	MOV	C,A
	MVI	B,0
	LDA	C$FLAG
	CMP	C
	JNC	GOT$NO1
	MVI	A,1
	MOV	C,A
	STA	FLAG3
;
GOT$NO1:LXI	H,C$FLAG
	DAD	B
	JMP	DIAL5
;.....
;
;
FLAG1:	DB	0
FLAG2:	DB	0
FLAG3:	DB	0
FLAG4:	DB	0
FLAG5:	DB	0
;
;
	END
