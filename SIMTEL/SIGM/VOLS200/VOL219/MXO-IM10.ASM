	TITLE	'MEX CERMETEK INFO-MATE 212A OVERLAY V1.0'
;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; Cermetek Info-Mate 212A overlay for MEX: version 1.0
;
; Derived from MXO-SM11.AQM by Ronald Mozer (V1.0)
; Original written by Ronald G. Fowler (V1.0)
;
; This modules adapts MEX for the Cermetek Info-Mate 212A modem.
; The main function of this module is to provide dialing capability;
; the disconnect vector is ancillary.  You must supply the disconnect
; routine which drops the DTR line in the standard mdm7 overlay as
; the info-mate has no other way of hanging up after the 'U 1' code.
;
; Use the MXO-SM?? or MXO-PM?? as a model to develop dialing routines
; for non-standard modems (e.g., the Racal-Vadic) as they will be better
; supported.
;
; This overlay will work with any modem overlay that terminates
; prior to 0B00H
;
;
; SYSTEM CONSTANTS
;
DIALV	EQU	0162H		;LOCATION OF DIAL VECTOR IN OVERLAY
GOODBY	EQU	0168H		;LOCATION OF GOODBYE VECTOR IN OVERLAY
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
	ORG	DIALV		;OVERLAY THE DIALING VECTOR
	JMP	DIAL
;
; This is the DIAL routine called by MEX to dial a digit. The digit
; to be dialed is passed in the A register.  Note that two special
; codes must be intercepted as non-digits: 254 (start dial sequence)
; and 255 (end-dial sequence).  Mex will always call DIAL with 254
; in the accumulator prior to dialing a number.  Mex will also call
; dial with 255 in A as an indication that dialing is complete. Thus,
; the overlay may use these values to "block" the number, holding it
; in a buffer until it is completely assembled (in fact, that's the
; scheme employed here for the Info-Mate).
;
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
STDIAL:	CALL	GOODBY
	LXI	H,DIALBF	;SET UP BUFFER POINTER
	SHLD	DIALPT
	RET
;
; Here on an end-dial sequence
;
ENDIAL:	MVI	M,27H		;CLOSE INFO-MATE QUOTES
	INX	H
	MVI	M,CR		;STUFF END-OF-LINE INTO BUFFER
	INX	H		;FOLLOWED BY TERMINATOR
	MVI	M,0
	LXI	H,IMDIAL	;POINT TO DIALING STRING
	CALL	IMSEND		;SEND IT
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 60 SECONDS: YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE).
; NOTE THAT THE SMARTMODEM HAS AN INTERNAL 30 SECOND TIMEOUT WHILE
; FOR A CARRIER ON THE OTHER END.  YOU CAN CHANGE BY PLAYING WITH THE
; S7 VARIABLE (I.E. SEND THE SMARTMODEM "AT S7=20" TO LOWER THE 30 SECOND
; WAIT TO 20 SECONDS).
;
RESULT:	MVI	C,30		;<<== MAXIMUM TIME TO WAIT FOR RESULT
SMWLP:	PUSH	B
	MVI	B,1		;CHECK FOR A CHAR, UP TO 1 SEC WAIT
	MVI	C,TMDINP	;DO TIMED INPUT
	CALL	MEX
	POP	B
	JNC	IMTEST		;JUMP IF MODEM HAD A CHAR
	PUSH	B		;NO, TEST FOR CONTROL-C FROM CONSOLE
	MVI	C,CHEKCC
	CALL	MEX
	POP	B
	JNZ	IMNEXT		;IF NOT, JUMP
	CALL	GOODBY		;YES, SHUT DOWN THE MODEM
	MVI	A,3		;RETURN ABORT CODE
	RET
IMNEXT:	DCR	C		;NO
	JNZ	SMWLP		;CONTINUE
;
; ONE MINUTE WITH NO MODEM RESPONSE (OR NO CONNECTION)
;
SMTIMO:	MVI	A,2		;RETURN TIMEOUT CODE
	RET
;
; MODEM GAVE US A RESULT, CHECK IT
;
IMTEST:	ANI	7FH		;IGNORE ANY PARITY
	CALL	IMANAL		;TEST THE RESULT
	JC	RESULT		;GO TRY AGAIN IF UNKNOWN RESPONSE
	MOV	A,B		;A=RESULT 
	PUSH	PSW		;SAVE IT
IMTLP:	MVI	C,INMDM		;EAT ANY ADDITIONAL CHARS FROM SMARTMODEM
	CALL	MEX
	JNC	IMTLP		;UNTIL 100MS OF QUIET TIME
	POP	PSW		;RETURN THE CODE
	ORA	A		;CONNECT????
	RZ
	PUSH	PSW
	CALL	GOODBY		;HANGUP THE PHONE IF NOT GOOD CONNECT...
	POP	PSW		;SAVE RESULT CODE...
	RET
;
IMANAL:	MVI	B,0		;PREP CONNECT CODE
	CPI	'A'		;"CONNECT"?
	RZ
	INR	B		;PREP BUSY CODE B=1
	CPI	'B'
	RZ
	INR	B		;PREP NO CONNECT MSG B=2
	CPI	'N'		;N=NO CONNECT
	RZ
	MVI	B,4		;PREP MODEM ERROR
	CPI	'?'		;E=ERROR
	RZ
;
; THE FOLLOWING ARE CODES THAT THE INFO-MATE CAN DETECT BUT MEX DOES
; NOT SUPPORT AN APPROPIATE RESULT CODE... ALL OF THE FOLLOWING INDICATE
; AN ABORT SITUATION - SO - I AM USING THE CONTROL C ABORT RESULT CODE.
;
	MVI	B,3		;ABORT CODE
	CPI	'W'		;WRONG SPEED.
	RZ
	CPI	'V'		;HUMAN VOICE DETECTED..
	RZ
	CPI	'X'		;NO DIAL TONE DETECTED..
	RZ
;
; UNKNOWN RESPONSE, RETURN CARRY TO CALLER.
;
	STC
	RET
;
; INFO-MATE UTILITY ROUTINE: SEND STRING TO MODEM
;
IMSEND:	MVI	C,SNDRDY	;WAIT FOR MODEM READY
	CALL	MEX
	JNZ	IMSEND
	MOV	A,M		;FETCH NEXT CHARACTER
	INX	H
	ORA	A		;END?
	RZ			;DONE IF SO
	MOV	B,A		;NO, POSITION FOR SENDING
	MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	CALL	MEX
	JMP	IMSEND
;
; DATA AREA
;
IMDIAL:	DB	'N'-40H,'U 1,D ',27H ;SET MODEM TO QUITE AND DIAL #
DIALBF:	DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	DS	2		;DIAL POSITION POINTER
;
	END
