;	TITLE	'MEX CTS COMPANION MODEM OVERLAY V1.4'
;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; CTS Companion modem 212AH overlay for MEX: revision 1.4
;
; Misc. little fixes 14feb85 to 18feb85 not distributed until final date (v1.4)
; Modified delay to make DSC & abort work consistently 10feb85 I S Wolfe (v1.3)
; Modified for auto baud rate change on CTS-212AH 10feb85 by I S Wolfe (v1.2)
;  a bug in the TYPE routine was fixed & some other problems solved.
; Originally written 07/24/84 by Ronald G. Fowler (V1.0)
;
; ATTENTION:  READ THIS PARAGRAPH BEFORE USING:
; This module adapts MEX for the CTS 212AH modem, but the MEX standard of
; keeping modem & computer overlays independent prevents complete adaptation.
; The module primarily provides dialing capability with automatic
; resetting of the modem with ^T so that baud rate changes can be initiated
; with ^Q^M before the dialing sequence.  NOTE THAT THE USER MUST RESET THE
; MODEM MANUALLY AFTER A COMPLETED CONVERSATION BY TYPING ^T WHILE STILL IN
; TERMINAL MODE.  Resets should occur automatically after a Busy, No answer,
; No tone, or Abort response from the modem.  Letters from the modem are
; displayed so the user can track a call's progress: D for dialing, R for ring,
; B for busy, etc.                               -- I S Wolfe 10feb85
;
;THIS DISCUSSION IS BY RON FOWLER.  I S Wolfe believes it is reasonable but
;only conjectural, and that until you experience trouble, don't worry:
; You may want to disable the ^T disconnect character  by issuing
; the "@@" command in terminal mode (although this will defeat the
; DISC option below, and require disconnect support be handled through
; DTR control in your hardware overlay).  This will sometimes be
; desirable to avoid disconnect problems when transmitting files
; in protocol mode over packet-switched networks (eg, Arpa and Compu-
; serve), where a block ending in control T could cause a disconnect
; if it takes more than one second for the ACK or NAK sequence to
; return from the remote end.  This will not usually be necessary
; for RCPM work, since character turnaround is normally much less
; than one second.
;
; The only conditional you might want to change in this
; module is the DISC equate below -- if left on, MEX will
; use the Companion's disconnect code.  If you prefer to
; provide your own in your overlay's DISCV vector (e.g.,
; by dropping DTR), then set DISC to FALSE and re-assemble.
; (If you don't understand this, then play it safe, and
; leave the equate set as it is).
;
; This overlay will work with any modem overlay that terminates
; prior to 0B00H
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
NUMRES	EQU	FALSE		; TRUE = INTERPRET NUMERIC RESULT CODES
				; FALSE = IGNORE NUMERIC RESULT CODES
;
DISC	EQU	TRUE		;<<== CHANGE TO FALSE IF YOU DISC. WITH DTR
;
; SYSTEM CONSTANTS
;
TPULSE	EQU	0105H		;TONE/PULSE FLAG IN MODEM OVERLAY
DIALV	EQU	0162H		;LOCATION OF DIAL VECTOR IN OVERLAY
DISCV	EQU	0165H		;LOCATION OF DISCONNECT VECTOR IN OVERLAY
DIALOC	EQU	0B00H		;DIALING CODE GOES HERE
MEX	EQU	0D00H		;"CALL MEX"
BDOS	EQU	0005H		;for call bdos in TYPE -- in case it becomes necessary
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
CTRLT	EQU	20	;added by isw
CTRLQ	EQU	17	;added by isw
CONOUT	EQU	2	;added by isw
;
	ORG	DIALV		;OVERLAY THE DIALING VECTOR
	JMP	DIAL
;
	IF	DISC		;IF PROVIDING DISCONNECT CODE here (we do)
	ORG	DISCV		;OVERLAY THE VECTOR
	JMP	DISCON
	ENDIF
;
; This is the DIAL routine called by MEX to dial a digit.  The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  MEX will always call DIAL with 254
; in the accumulator prior to dialing a number.  MEX will also call
; dial with 255 in A as an indication that dialing is complete.  Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (in fact, that's the
; scheme Ron Fowler employed here for the CTS modem).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the digits,
; and will send each to the DIAL routine un-inspected (some modems,
; like the CTS modem, allow special non-numeric characters in the
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
DIAL:
;
	LHLD	DIALPT		;FETCH POINTER
	CPI	254		;START DIAL?
	JZ	STDIAL		;JUMP IF SO
	CPI	255		;END DIAL?
	JZ	ENDIAL		;JUMP IF SO
;
; Not start or end sequence, must be a digit to be sent to the modem
;
	MOV	M,A		;PUT CHAR IN BUFFER
	INX	H		;ADVANCE POINTER
	SHLD	DIALPT		;STUFF PNTR
	RET			;DONE with this "digit"
;
; Here on a start-dial sequence
;
STDIAL:
;
	LXI	H,CTSPED	;SEND ^Q^M     ;inserted here by isw to set modem speed
	CALL	CTSEND                 ;after modem was reset entirely by extra ^t.
;
	LXI	H,DIALBF	;SET UP BUFFER POINTER
	SHLD	DIALPT
	RET
;
; Here on an end-dial sequence
;
ENDIAL:
;
	MVI	M,CR		;STUFF END-OF-LINE INTO BUFFER
	INX	H		;FOLLOWED BY null TERMINATOR
	MVI	M,0
	LDA	TPULSE		;GET OVERLAY'S TOUCH-TONE FLAG
	STA	CTDIAL		;put it into the dialing command
;
ENDL0:    ;added by isw to pick up & discard "modem ready" from the ^q^m
;
	MVI	C,INMDM		;CLEAR ANY WAITING MODEM CHARACTERS
	CALL	MEX
	JNC	ENDL0		;LOOP UNTIL NO MORE
;
	LXI	H,CTDIAL	;POINT TO DIALING STRING
	CALL	CTSEND		;SEND IT
;
WAITSM:
;
	MVI	C,INMDM
	CALL	MEX		;CATCH ANY OUTPUT FROM THE MODEM
	JNC	WAITSM		;LOOP UNTIL NO MORE CHARACTERS
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 60 SECONDS: YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE).
;
RESULT:
;
	MVI	C,60		;<<== MAXIMUM TIME TO WAIT FOR RESULT
;
SMWLP:
;
	MVI	B,1		;CHECK FOR A CHAR, UP TO 1 SEC WAIT
	MVI	C,TMDINP	;DO TIMED INPUT
	CALL	MEX
	JNC	SMTEST		;JUMP IF MODEM HAD A CHAR
	MVI	C,CHEKCC
	CALL	MEX
	JNZ	SMNEXT		;IF NOT, JUMP
	CALL	DISCON	;added by isw to replace 3 deleted lines that didn't do enough
	MVI	A,3		;RETURN ABORT CODE
	RET
;
SMNEXT:
;
	DCR	C		;NO so reduce the 60 second count
	JNZ	SMWLP		;CONTINUE
;
; ONE MINUTE WITH NO MODEM RESPONSE (OR NO CONNECTION)
;
SMTIMO:
;
	CALL	DISCON	;added by isw
	MVI	A,2		;RETURN TIMEOUT CODE
	RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
SMTEST:
;
	ANI	7FH		;IGNORE ANY PARITY
	CALL	SMANAL		;TEST THE RESULT
	MOV	A,B		;A=RESULT (CY SIGNIFICANT HERE TOO)
	PUSH	PSW		;SAVE IT
;
SMTLP:
;
	MVI	C,INMDM		;FLUSH ANY REMAINING COMMAND LINE
	CALL	MEX
	JC	SMCHEK		;JUMP IF NO INPUT
	CPI	LF		;GOT SOME ... WAITING FOR EOL
	JNZ	SMTLP		;EAT ANY IN-BETWEEN
;
SMCHEK:
;
	MVI	A,' '		;isw lets display a space for formatting purposes
	CALL	TYPE	;isw
	POP	PSW		;A HAS MEX RETURN-CODE, CY=1 IF UNKNOWN
	JC	SMC1	;isw go process unknown response
	ORA	A	;isw check for 0
	RZ		;isw return now if on line
	PUSH	PSW	;isw save return code
	CALL	DISCON	;isw reset modem since not on line
	POP	PSW	;isw get back return code
	RET			;was VALID RETURN CODE, so EXIT
;
SMC1:	;note: isw removed Ron's code, left extra jump in for possible later use
;
	JMP	RESULT		;AND CONTINUE, ignoring the Dialing or Ring or any unknown code
;
; ANALYZE CODE, RETURN CY=1 IF UNKNOWN CODE.  VALID
; EXIT CODES COME BACK IN B, CHAR IN A IS PRESERVED
;
SMANAL:
;
	CPI	' '	;is it okay to display? added by isw to see what's going on
	CNC	TYPE	;call type if char from modem is greater than space
	MVI	B,0		;PREP CONNECT CODE
	CPI	'O'		;"ON LINE"?
	RZ
	INR	B		;PREP BUSY CODE B=1
	CPI	'B'		;B=BUSY
	RZ
	INR	B		;PREP NO CONNECT MSG B=2
	CPI	'N'		;N=NO PHONE # OR NO ANSWER OR NO DIALTONE
	RZ
	CPI	'M'		;M=MODEM READY which will occur after DEAD LINE gives a D
	RZ
	STC			;set carry means it is an UNKNOWN code
	RET
;
; FOLLOWING ROUTINE DISCONNECTS (& resets) THE MODEM USING THE CTS
; DISCONNECT CODE. ALL REGISTERS ARE AVAILABLE FOR THIS FUNCTION.
; NOTHING RETURNED TO CALLER.
;
	IF	DISC
;
DISCON:
;
;the ^t only works, it appears (v1.4) if there are no characters flowing after
;it in EITHER direction, so I'm cutting the time to 9 tenths & waiting for a
;pause in incoming chars (adding 1 tenth +) before sending each of 3 ^t's
;
	LXI	H,CTDISC	;SEND ^T
	CALL	CTSEND
;
DCN0:
;
	MVI	C,INMDM		;CLEAR ANY WAITING MODEM CHARACTERS
	CALL	MEX
	JNC	DCN0		;LOOP UNTIL NO MORE
	MVI	B,9		;WAIT .9 SECOND more for 1 second total
	MVI	C,TIMER
	CALL	MEX
	LXI	H,CTDISC	;SEND ^T
	CALL	CTSEND
;
DCN3:
;
	MVI	C,INMDM		;wait until incoming char's are cleared & no more coming
	CALL	MEX
	JNC	DCN3		;LOOP UNTIL NO MORE
	MVI	B,9		;WAIT 1 SECOND total including inmdm loop
	MVI	C,TIMER
	CALL	MEX		;to reset modem entirely awaiting ^q^m
;	LXI	H,CTDISC	;SEND ^T        this third one commented out to see if okay
;	CALL	CTSEND
;
;DCN2:
;
;	MVI	C,INMDM		;wait until incoming char's are cleared & no more coming
;	CALL	MEX
;	JNC	DCN2		;LOOP UNTIL NO MORE
;	MVI	B,9		;WAIT 1 SECOND total
;	MVI	C,TIMER
;	CALL	MEX		;to reset modem entirely awaiting ^q^m
;
DCN1:
;        ;added to pick up & discard "disconnect"
	MVI	C,INMDM		;CLEAR ANY WAITING MODEM CHARACTERS
	CALL	MEX
	JNC	DCN1		;LOOP UNTIL NO MORE
	RET
;
	ENDIF
;
; SEND STRING TO MODEM
;
CTSEND:
;
	MVI	C,SNDRDY	;WAIT FOR MODEM READY
	CALL	MEX
	JNZ	CTSEND
	MOV	A,M		;FETCH NEXT CHARACTER
	INX	H		;step the pointer
	ORA	A		;END? (signified by null)
	RZ			;DONE IF SO
	MOV	B,A		;NO, POSITION FOR SENDING
	MVI	C,SNDCHR	;SEND THE CHARACTER
	CALL	MEX
	JMP	CTSEND
;
; TYPE CHARACTER IN  A  ON the SCREEN
;
TYPE:
;
	PUSH	H		;SAVE THE REGISTERS
	PUSH	D
	PUSH	B
	PUSH	PSW
	MOV	E,A		;ALIGN
	MVI	C,CONOUT		;FUNCTION CODE
	CALL	MEX	;call bdos via mex
	POP	PSW		;CLEAN UP AND EXIT
	POP	B
	POP	D
	POP	H
	RET
;
; DATA AREA
;
CTDISC:	DB	CTRLT,0	;added by isw
CTSPED:	DB	CTRLQ,CR,0	;added by isw
CTDIAL:	DB	'T'
DIALBF:	DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	DS	2		;DIAL POSITION POINTER
;
	END
