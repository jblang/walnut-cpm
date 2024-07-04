	TITLE	'MEX CTS COMPANION MODEM OVERLAY V1.0'
;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; CTS Companion modem overlay for MEX: revision 1.0
; Written 07/24/84 by Ronald G. Fowler (V1.0)
;
; This modules adapts MEX for the CTS Companion modem. The main
; function of this module is to provide dialing capability;
; the disconnect vector is ancillary.
;
; This overlay assumes that the 'echo command' switch on the
; back panel (switch 2) is in the UP position, causing command
; characters to be echoed.  We use the echoed characters to
; pace the command, since the CTS input buffer is easily overrun.
;
; Note that you must handle the initial ^Q<RET> baudrate setup
; (needed by the Companion at powerup) in terminal mode, since MEX
; does not yet provide a smartmodem initialization entrypoint. You
; may also want to disable the ^T disconnect character  by issuing
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
; 
; 
;
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
; in a buffer until it is completely assembled (in fact, that's the
; scheme employed here for the CTS modem).
;
; After the 254-start-dial sequence, MEX will call the overlay with
; digits, one-at-a-time.  MEX will make no assumptions about the dig-
; its, and will send each to the DIAL routine un-inspected (some modems,
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
DIAL:	LHLD	DIALPT		;FETCH POINTER
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
	RET			;ALL DONE
;
; Here on a start-dial sequence
;
STDIAL:	LXI	H,DIALBF	;SET UP BUFFER POINTER
	SHLD	DIALPT
STD1:	MVI	C,INMDM		;CLEAR ANY WAITING MODEM CHARACTERS
	CALL	MEX
	JNC	STD1		;LOOP UNTIL NO MORE
	RET
;
; Here on an end-dial sequence
;
ENDIAL:	MVI	M,CR		;STUFF END-OF-LINE INTO BUFFER
	INX	H		;FOLLOWED BY TERMINATOR
	MVI	M,0
	LDA	TPULSE		;GET OVERLAY'S TOUCH-TONE FLAG
	STA	CTDIAL		;MAKE DIALING COMMAND
	LXI	H,CTDIAL	;POINT TO DIALING STRING
	CALL	CTSEND		;SEND IT
WAITSM:	MVI	C,INMDM
	CALL	MEX		;CATCH ANY OUTPUT FROM THE MODEM
	JNC	WAITSM		;LOOP UNTIL NO MORE CHARACTERS
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 60 SECONDS: YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE).
;
RESULT:	MVI	C,60		;<<== MAXIMUM TIME TO WAIT FOR RESULT
SMWLP:	PUSH	B
	MVI	B,1		;CHECK FOR A CHAR, UP TO 1 SEC WAIT
	MVI	C,TMDINP	;DO TIMED INPUT
	CALL	MEX
	POP	B
	JNC	SMTEST		;JUMP IF MODEM HAD A CHAR
	PUSH	B		;NO, TEST FOR CONTROL-C FROM CONSOLE
	MVI	C,CHEKCC
	CALL	MEX
	POP	B
	JNZ	SMNEXT		;IF NOT, JUMP
	MVI	B,CR		;YES, SHUT DOWN THE MODEM
	MVI	C,SNDCHR
	CALL	MEX
	MVI	A,3		;RETURN ABORT CODE
	RET
SMNEXT:	DCR	C		;NO
	JNZ	SMWLP		;CONTINUE
;
; ONE MINUTE WITH NO MODEM RESPONSE (OR NO CONNECTION)
;
SMTIMO:	MVI	A,2		;RETURN TIMEOUT CODE
	RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
SMTEST:	ANI	7FH		;IGNORE ANY PARITY
	CALL	SMANAL		;TEST THE RESULT
	MOV	A,B		;A=RESULT (CY SIGNIFICANT HERE TOO)
	PUSH	PSW		;SAVE IT
SMTLP:	MVI	C,INMDM		;FLUSH ANY REMAINING COMMAND LINE
	CALL	MEX
	JC	SMCHEK		;JUMP IF NO INPUT
	CPI	LF		;GOT SOME ... WAITING FOR EOL
	JNZ	SMTLP		;EAT ANY IN-BETWEEN
SMCHEK:	POP	PSW		;A HAS MEX RETURN-CODE, CY=1 IF UNKNOWN
	RNC			;IF VALID RETURN CODE, EXIT
	CPI	'R'		;RING?
	JNZ	RESULT		;IGNORE IT IF NOT
	MVI	A,'*'		;YEP, SHOW CONSOLE WITH AN ASTERISK
	CALL	TYPE
	JMP	RESULT		;AND CONTINUE
;
; ANALYZE CODE, RETURN CY=1 IF UNKNOWN CODE. VALID
; EXIT CODES COME BACK  IN B, CHAR IN A IS PRESERVED.
;
SMANAL:	MVI	B,0		;PREP CONNECT CODE
	CPI	'O'		;"ON LINE"?
	RZ
	INR	B		;PREP BUSY CODE B=1
	CPI	'B'		;B=BUSY
	RZ
	INR	B		;PREP NO CONNECT MSG B=2
	CPI	'N'		;N=NO PHONE # OR NO ANSWER OR NO DIALTONE
	RZ
 	STC			;UNKNOWN...
	RET
;
; FOLLOWING ROUTINE DISCONNECTS THE MODEM USING THE CTS
; DISCONNECT CODE. ALL REGISTERS ARE AVAILABLE FOR THIS FUNCTION.
; NOTHING RETURNED TO CALLER.
;
	IF	DISC
;
DISCON:	LXI	H,CTDISC	;SEND ^T
	CALL	CTSEND
	MVI	B,1		;WAIT 1 SECOND
	MVI	C,TIMER
	CALL	MEX
	RET
;
CTDISC:	DB	'T'-64,0
;
	ENDIF
;
; SEND STRING TO MODEM
;
CTSEND:	MVI	C,SNDRDY	;WAIT FOR MODEM READY
	CALL	MEX
	JNZ	CTSEND
	MOV	A,M		;FETCH NEXT CHARACTER
	INX	H
	ORA	A		;END?
	RZ			;DONE IF SO
	MOV	B,A		;NO, POSITION FOR SENDING
	MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	CALL	MEX
	MVI	C,INMDM		;WAIT FOR ECHOED CHARACTER
	CALL	MEX
	JMP	CTSEND
;
; TYPE CHARACTER IN A ON SCREEN
;
TYPE:	PUSH	H		;SAVE THE REGISTERS
	PUSH	D
	PUSH	B
	PUSH	PSW
	MOV	E,A		;ALIGN
	MVI	C,2		;FUNCTION CODE
	CALL	MEX		;DO IT
	POP	PSW		;CLEAN UP AND EXIT
	POP	B
	POP	D
	POP	H
	RET
;
; DATA AREA
;
CTDIAL:	DB	'T'
DIALBF:	DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	DS	2		;DIAL POSITION POINTER
;
	END
                                                                 