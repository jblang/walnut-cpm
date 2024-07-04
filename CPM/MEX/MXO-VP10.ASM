	TITLE	'MEX VENTEL MD212 PLUS MODEM OVERLAY V1.0'
;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; used smartmodem overlay for MEX: revision 1.2
; Written 04/16/84 by Ronald G. Fowler (V1.2) as an outline.
;
;			Written by:
;		Bruce Childers & Jon Albers
;		Data - 202-633-0804, 0805, 0806
;		       703-281-7907
;
; This overlay will allow you to use a Ven-Tel Plus modem with Mex.
; It will allow auto-dial.  Note -- You can only disconnect using
; DTR, so set the DISC equatte to false.
;
; This overlay will work with any modem overlay that terminates
; prior to 0B00H
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;
DISC	EQU	FALSE		;<<== CHANGE TO FALSE IF YOU DISC. WITH DTR
PENRIL	EQU	FALSE		;Set true if you have a Penril
;
; SYSTEM CONSTANTS
;
DIALV	EQU	0162H		;LOCATION OF DIAL VECTOR IN OVERLAY
DISCV	EQU	0165H		;LOCATION OF DISCONNECT VECTOR IN OVERLAY
DIALOC	EQU	0B00H		;DIALING CODE GOES HERE
MEX	EQU	0D00H		;"CALL MEX"
;
; FOLLOWING ARE FUNCTION CODES FOR THE MEX SERVICE CALL PROCESSOR
;
INMDM	EQU	255		;RETURN CHAR FROM MDM IN A, CY=NO CHR IN 100MS
TIMER	EQU	254
TMDINP	EQU	253		;B=# SECS TO WAIT FOR CHAR, CY=NO CHAR
CHEKCC	EQU	252		;CHECK FOR ^C FROM KBD, Z=PRESENT
SNDRDY	EQU	251		;TEST FOR MODEM-SEND READY
RCVRDY	EQU	250		;TEST FOR MODEM-RECEIVE READY
SNDCHR	EQU	249		;SEND A CHARACTER TO THE MODEM (AFTER SNDRDY)
RCVCHR	EQU	248		;RECV A CHAR FROM MODEM (AFTER RCVRDY)
;
CR	EQU	13
LF	EQU	10
;
;
;
	ORG	DIALV		;OVERLAY THE DIALING VECTOR
	JMP	DIAL
;	
	IF	DISC		;IF PROVIDING DISCONNECT CODE
	ORG	DISCV		;OVERLAY THE VECTOR
	JMP	DISCON
	ENDIF
;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled.
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the dig-
; its, and will send each to the DIAL routine un-inspected (some modems,
; like the Smartmodem, allow special non-numeric characters in the
; phone number, and MEX may make no assumptions about these).
;
; After receiving the end-dial sequence (255) the overlay must take
; whatever end-of-dial actions are necessary *including* waiting for
; carrier at the distant end.  The overlay should monitor the keyboard
; during this wait (using the MEX keystat service call), and return
; an exit code to MEX in the A register, as follows:
;
;	0 - Carrier detected, connection established
;	1 - Far end busy (only for modems that can detect this condition)
;	2 - No answer (or timed out waiting for modem response)
;	3 - Keyboard abort (^C only: all others should be ignored)
;	4 - Error reported by modem
;
; <No other codes should be returned after an end-dial sequence>
;
; The overlay should not loop forever in the carrier-wait routine, but
; instead use either the overlay timer vector, or the INMDMV (timed 100
; ms character wait) service call routine.
;
; The DIAL routine is free to use any of the registers, but must return
; the above code after an end-dial sequence
;
	ORG	DIALOC
;
DIAL:	CPI	254		;START DIAL?
	JZ	STDIAL		;JUMP IF SO
	CPI	255		;END DIAL?
	JZ	ENDIAL		;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
	CALL	SEND		;SEND CHARACTER TO MODEM
	RET			;ALL DONE
;
; Here on a start-dial sequence
;
STDIAL:	CALL 	SETUP		;WAKE UP THE VENTEL
	RET
;
; Here on an end-dial sequence
;
ENDIAL: MVI	A,CR		;PUT A CR AT THE END
	CALL	SEND		;SEND CR TO MODEM

WAITVP: MVI	C,INMDM
	CALL	MEX		;CATCH ANY OUTPUT FROM THE MODEM
	JNC	WAITVP		;LOOP UNTIL NO MORE CHARACTERS
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 60 SECONDS: YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE).
;
RESULT:	MVI	C,60		;<<== MAXIMUM TIME TO WAIT FOR RESULT
VPWLP:	PUSH	B
	MVI	B,1		;CHECK FOR A CHAR, UP TO 1 SEC WAIT
	MVI	C,TMDINP	;DO TIMED INPUT
	CALL	MEX
	POP	B
	JNC	VPTEST		;JUMP IF MODEM HAD A CHAR
	PUSH	B		;NO, TEST FOR CONTROL-C FROM CONSOLE
	MVI	C,CHEKCC
	CALL	MEX
	POP	B
	JNZ	VPNEXT		;IF NOT, JUMP
	MVI	B,CR		;YES, SHUT DOWN THE MODEM
	MVI	C,SNDCHR
	CALL	MEX
	MVI	A,3		;RETURN ABORT CODE
	RET
VPNEXT:	DCR	C		;NO
	JNZ	VPWLP		;CONTINUE
;
; ONE MINUTE WITH NO MODEM RESPONSE (OR NO CONNECTION)
;
VPTIMO:	MVI	A,2		;RETURN TIMEOUT CODE
	RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
VPTEST:	ANI	7FH		;IGNORE ANY PARITY
	CALL	VPANAL		;TEST THE RESULT
	MOV	A,B		;A=RESULT (CY SIGNIFICANT HERE TOO)
	PUSH	PSW		;SAVE IT
VPTLP:	MVI	C,INMDM		;FLUSH ANY REMAINING COMMAND LINE
	CALL	MEX
	JC	VPCHEK		;JUMP IF NO INPUT
	CPI	LF		;GOT SOME ... WAITING FOR EOL
	JNZ	VPTLP		;EAT ANY IN-BETWEEN
VPCHEK:	POP	PSW		;A HAS MEX RETURN-CODE, CY=1 IF UNKNOWN
	JC	RESULT		;IF RESULT UNKNOWN, IGNORE IT
	RET
;
VPANAL:	MVI	B,0		;PREP CONNECT CODE
	CPI	'O'		;"CONNECT"?
	RZ
	INR	B		;PREP BUSY CODE B=1
	CPI	'B'
	RZ
	INR	B		;PREP NO CONNECT MSG B=2
	CPI	'N'		;N=NO CONNECT
	RZ
	MVI	B,4		;PREP MODEM ERROR
	CPI	'E'		;E=ERROR
	RZ
	STC			;UNKNOWN...
	RET
;
;	SET UP ROUTINE TO WAKE VEN-TEL UP
;
SETUP:	MVI	C,SNDRDY	;CHECK TO SEE IF MODEM IS ALIVE
	CALL 	MEX
	JNZ	SETUP
	MVI	A,CR		;send first cr of 3
	CALL	SEND
	CALL	DELAY1		;Wait to avoid sending CR's too fast for modem
SETUP2:	MVI	C,SNDRDY
	CALL	MEX
	JNZ	SETUP2
	MVI	A,CR		;send second cr
	CALL	SEND
	CALL	DELAY1
SETUP3:	MVI	C,SNDRDY	
	CALL	MEX
	JNZ	SETUP3
	MVI	A,CR		;send third cr
	CALL	SEND
	MVI	B,30		;Wait to get past banner
	MVI	C,TIMER
	CALL	MEX
	CALL	DELAY1
KOUT:	MVI	C,SNDRDY
	CALL	MEX
	JNZ	KOUT
	MVI	B,'K'	;GET READY TO DIAL
	MVI	C,SNDCHR
	CALL	MEX
	CALL	DELAY1
	RET
; 
DELAY1:	MVI	B,5		;Delay routine
	MVI	C,TIMER
	CALL	MEX
	RET

;	SEND A CHARACTER TO THE MODEM
;
SEND:	MOV	B,A		;WHEN CALLING HERE, THE CHAR IS IN A
	MVI	C,SNDCHR
	CALL	MEX
	RET
;				End of  Overlay
	END
