;
;	BYETIME2     by:   Joubert Berger
;			   Atlanta Kaypro MBBS
;			   (404) 923-2580 [300/1200 baud]
;
; 8/16/86 - Fixed code to save stack properly so program will exit
; v. 31     with a simple RETurn instead of a warm-boot (faster this
;	    way).  Removed seconds display (non-essential info).
;
; 6/28/86 - Eliminated 'S' option. Now displays time/date along with
; v. 30     stats.  Fixed nulls (removed MOV E,A as value already in A).
;	    Added equate for clock. Made display a little more pleasing
;	    to the eye.
;		Lawrence Davis - Glendale Litera QBBS - 818/956-6164
;
;
;**********************************************************************
; 12/22/85  ADDED RBBS38 SUPPORT     JIM GOOCH (Norcross RCPM) 921-1116
;**********************************************************************
;  After just setting up BYE502, I decided to play around a bit with
;  the extended BDOS functions that are in BYE5xx.
;
;  BYETIME will display the time and date to the user if he just types
;  'BYETIME'.  If he types 'BYETIME S' he will be given some statistcs about
;  what kind of access he has.	It will include the max. drive/user,
;  time on system, max. time allowed, number of nulls, and if the
;  sysop is in.
;
;  It is nothing fancy, and not written that great, but it is just a
;  demonstration how you can use all those new BDOS calls in BYE5xx.
;  If anyone adds or updates anything to this, I would appreciate it
;  if they send me a copy of it.
;			Joubert Berger - 12/17/85
;
;
NO	EQU	0
YES	EQU	NOT NO
;
RBBS	EQU	YES		; Set YES if RBBS or QBBS
MBBS	EQU	NO		; Set YES if MBBS
CLOCK	EQU	YES		; Yes, if RTC installed
;
GSUSR	EQU	32		; Get/Set user
MXDRV	EQU	69		; Max drive
MXUSR	EQU	70		; Max user
NULLS	EQU	72		; Number of nulls
BELLON	EQU	78		; Bell toggle
RTCBUF	EQU	79		; Get clock(RTC) buffer
LCDATA	EQU	80		; Get user buffer
MXTIME	EQU	81		; Max time on system
;
CR	EQU	0DH		; Carrige return
LF	EQU	0AH		; Line feed
FCB	EQU	5CH		; File control block
BDOS	EQU	0005H		;

	ORG	100H

BEGIN:	LXI	H,0		; Save stack for RET exit
	DAD	SP
	SHLD	OLDSP
;
	MVI	C,GSUSR		; Check if running BYE
	MVI	E,241
	CALL	BDOS
	CPI	77
	JZ	START		; If there continue
	CALL	ILPRT		; If not abort - Print abort message
	DB	'BYE5xx is not running....aborting.',0
	JMP	EXIT
;
START:
;
	 IF	CLOCK
TIME:	CALL	ILPRT
	DB	CR,LF,0
	CALL	DATE		; Read the clock buffer
	LDA	HRSAV		; Get hour
	CALL	PASC		; Print it
;
	MVI	A,':'
	CALL	CTYPE
;
	LDA	MNSAV		; Get minutes
	CALL	PASC		; Print it
;
	CALL	ILPRT
	DB	'  ',0
;
	LDA	MMSAV		; Get the month
	CPI	1		; And print the month name
	JNZ	FEBU
	CALL	ILPRT
	DB	'January ',0
	JMP	DONE
;
FEBU:	CPI	2
	JNZ	MARC
	CALL	ILPRT
	DB	'February ',0
	JMP	DONE
;
MARC:	CPI	3
	JNZ	APRL
	CALL	ILPRT
	DB	'March ',0
	JMP	DONE
;
APRL:	CPI	4
	JNZ	MAYY
	CALL	ILPRT
	DB	'April ',0
	JMP	DONE
;
MAYY:	CPI	5
	JNZ	JUNE
	CALL	ILPRT
	DB	'May ',0
	JMP	DONE
;
JUNE:	CPI	6
	JNZ	JULY
	CALL	ILPRT
	DB	'June ',0
	JMP	DONE
;
JULY:	CPI	7
	JNZ	AUGS
	CALL	ILPRT
	DB	'July ',0
	JMP	DONE
;
AUGS:	CPI	8
	JNZ	SEPT
	CALL	ILPRT
	DB	'August ',0
	JMP	DONE
;
SEPT:	CPI	9
	JNZ	OCTO
	CALL	ILPRT
	DB	'September ',0
	JMP	DONE
;
OCTO:	CPI	10
	JNZ	NOVB
	CALL	ILPRT
	DB	'October ',0
	JMP	DONE
;
NOVB:	CPI	11
	JNZ	DECM
	CALL	ILPRT
	DB	'November ',0
	JMP	DONE
;
DECM:	CALL	ILPRT
	DB	'December ',0
;
DONE:
;
	LDA	DDSAV		; Get the day
	CALL	PASC		; Print it
;
	CALL	ILPRT
	DB	', ',0
;
	LDA	CNSAV		; Get the century
	CALL	PASC		; Print it
	LDA	YYSAV		; Get the year
	CALL	PASC		; Print it
	 ENDIF
;
;
STATIS:
	CALL	ILPRT
	DB	CR,LF,LF,0
	MVI	C,LCDATA	; Get the user buffer
	MVI	E,255
	CALL	BDOS
; next 2 not necessary for RBBS (lastcalr name starts in col 1)
;
	 IF	MBBS
	INX	H		; Jump over the first two spaces
	INX	H		; AT LEAST FOR MBBS
	 ENDIF			; MBBS
;
PRTNAM:	MOV	A,M		; Print the first name
;
	 IF	MBBS
	CPI	';'		; Check for end of first name
	 ENDIF			; MBBS
;
	 IF	RBBS
	CPI	' '		; Rbbs uses a space
	 ENDIF			; Rbbs
;
	JZ	PRTNDN
	CALL	CTYPE
	INX	H
	JMP	PRTNAM
;
PRTNDN:	CALL	ILPRT
	DB	', here are some statistics regarding your'
	DB	' access level.',CR,LF,LF,0
;
;  Here we go...
	CALL	ILPRT
	DB	'Maximum Drive/User      : ',0
;
	MVI	C,MXDRV		; Get max. drive
	MVI	E,255		; Using the BDOS calls in BYE5
	CALL	BDOS
	ADI	40H		; Make it a letter
	CALL	CTYPE		; Print it
;
	MVI	C,MXUSR		; Get max. user
	MVI	E,255
	CALL	BDOS
;
	CPI	10		; If user # < 10, skip
	JC	DUX
	PUSH	B
	MVI	C,'0'-1
DUY:	INR	C		; Get tens digit
	SUI	10
	JNC	DUY		; Loop until we've gone too far
	ADI	10
	MOV	B,A		; Save units digit
	MOV	A,C		; Print tens digit
	CALL	CTYPE
	MOV	A,B		; Get units back
	POP	B
DUX:	ADI	'0'
	CALL	CTYPE
;
	CALL	ILPRT		; Finish with a colon
	DB	':',CR,LF,0
;
;
	CALL	ILPRT
	DB	'Number of Nulls         : ',0
;
	MVI	C,NULLS		; Get number of nulls
	MVI	E,255		; Will be between 0 and 9
	CALL	BDOS
;	MOV	A,E			; Move it over
	ADI	30H		; Make it a digit to print
	CALL	CTYPE
	CALL	ILPRT		; Clean up with a CR/LF
	DB	CR,LF,0
;
;
	CALL	ILPRT
	DB	'Minutes on System       : ',0
;
	CALL	DATE		; Use DATE to get current time on
	LDA	TOS		; System
	CALL	PASC		; Print it - already in binary
	CALL	ILPRT		; And clean up
	DB	CR,LF,0
;
;
	CALL	ILPRT
	DB	'Maximum Time Allowed    : ',0
;
	MVI	C,MXTIME	; Max. time on system allowed
	MVI	E,255
	CALL	BDOS
	CPI	0		; Check for unlimited
	JNZ	NOLIMT
	CALL	ILPRT		; And print "Unlimited" if so
	DB	'UNLIMITED',0
	JMP	EXMXTIM
NOLIMT:	CALL	PASC		; Else print max. time allowed
	CALL	ILPRT
	DB	' minutes',0
EXMXTIM:CALL	ILPRT		; And finish up
	DB	CR,LF,0
;
;
	CALL	ILPRT
	DB	CR,LF,'The System Operator is currently ',0
;
	MVI	C,BELLON	; Now tell if sysop is in - this
	MVI	E,255		; Is done by checking if console
	CALL	BDOS		; Bell is set or not
	CPI	0FFH		; Check if set
	JZ	BELON
	CALL	ILPRT
	DB	'not ',0	; It is set so report it
BELON:	CALL	ILPRT
	DB	'in.',CR,LF,0
;

EXIT:
	LHLD	OLDSP
	SPHL
	RET			; Done, so lets exit...
;
;========================================================================
;
;  The call will find the Real-Time Clock buffer in BYE and get the hour,
;  minutes, second, month, date, century, and year and save it in buffers
;
DATE:	MVI	C,RTCBUF	; Lets find the buffer
	CALL	BDOS		; Use BYE's BDOS call
;
	MOV	A,M		; Get the hour
	CALL	BCDBIN		; Change to binary
	STA	HRSAV		; Save it for later
	INX	H		; Increment the buffer
;
	MOV	A,M		; Get the minute
	CALL	BCDBIN		; Change to binary
	STA	MNSAV		; Save it for later
	INX	H		; Increment buffer
;
	MOV	A,M		; Get the second
	CALL	BCDBIN		; Change to binary
	STA	SESAV		; Save it
	INX	H		; Increment buffer
;
	MOV	A,M		; Get the century
	CALL	BCDBIN		; Change to binary
	STA	CNSAV		; Save it
	INX	H		; Increment buffer
;
	MOV	A,M		; Get the year
	CALL	BCDBIN		; Change to binary
	STA	YYSAV		; Save it
	INX	H		; Increment buffer
;
	MOV	A,M		; Get the month
	STA	MMSAV		; Save it - no need to change
	INX	H		; Increment buffer
;
	MOV	A,M		; Get the day
	CALL	BCDBIN		; Change to binary
	STA	DDSAV		; Save it for later
	INX	H		; Increment buffer
;
	MOV	A,M		; Get time on system
	STA	TOS		; Save if for later
;
	RET
;
;  Inline print routine - this will print everything until it finds
;  a null (0).
;
ILPRT:	XTHL
ILPLP:	MOV	A,M
	INX	H
	ORA	A
	JZ	ILPRET
	CALL	CTYPE
	JMP	ILPLP
ILPRET:	XTHL
	RET
;
;  This will print the character in register A
;
CTYPE:	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
	MOV	E,A
	MVI	C,2
	CALL	BDOS
	POP	PSW
	POP	H
	POP	D
	POP	B
	RET
;
;  This will convert the BCD number in A to binary
;
BCDBIN:	PUSH	PSW
	ANI	0F0H
	RRC
	RRC
	RRC
	RRC
	MOV	C,A
	MVI	B,9
;
BCDBL:	ADD	C
	DCR	B
	JNZ	BCDBL
	MOV	B,A
	POP	PSW
	ANI	0FH
	ADD	B
	RET
;
;  This will print the the binary number in A
;
PASC:	MVI	C,0
PASC1:	SUI	10
	JC	PASC2
	INR	C
	JMP	PASC1
PASC2:	ADI	10
	PUSH	PSW
	MOV	A,C
	ORA	A
	JZ	ONENUM
	ADI	030H
	CALL	CTYPE
	JMP	TWONUM
ONENUM:	MVI	A,'0'
	CALL	CTYPE
TWONUM:	POP	PSW
	ADI	030H
	CALL	CTYPE
	RET
;
;	Buffer area
;
HRSAV:	DB	0		; Hour
MNSAV:	DB	0		; Minutes
SESAV:	DB	0		; Seconds
CNSAV:	DB	0		; Century
YYSAV:	DB	0		; Year
MMSAV:	DB	0		; Month
DDSAV:	DB	0		; Day
TOS:	DB	0		; Time on system
;
OLDSP:	DS	2
	DS	20
STACK	EQU	$
	END
