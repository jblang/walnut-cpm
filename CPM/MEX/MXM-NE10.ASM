 TITLE	'MEX NEC N212BR-L1 MODEM OVERLAY V1.0'
;
; (DELETE ABOVE TITLE LINE IF ASSEMBLING WITH ASM)
;
; Original File: MXO-SM14.ASM
;
; Smartmodem overlay for MEX: revision 1.3
; Written 04/16/84 by Ronald G. Fowler (V1.0)
;
; 19/09/86: Altered for the NEC N212BR-L1 modem command set. This uses the
;	    NEC modem DIAL MODE 'K' command for KEYBOARD DIAL, sending
;	    two CRs with a two second wait between them to wake up the modem, 
;	    another two second wait, the 'K', wait two more seconds, then 
;	    the phone number.
;	    Also removed the NUMRES equate and the associated code as it's
;	    not used in this overlay.
;	    The NEC modem returns a whole scentence from the dialing
;	    sequence. For instance, if you tell it to dial: 1-234-567-8901
;	    the NEC modem would return:
;
;		DIALING 1-234-567-8901.............(message)
;
;	    Where the message could be *ON LINE*, BUSY, RINGING, or ABORTED.
;	    So we have to search that string for valid characters. The on line
;	    is easy; look for a '*'. Busy look for a 'U', so the 'B' of
;	    'ABORTED' doesn't trigger it, 'R' for ringing, and 'O' for 
;	    'ABORTED' so the 'A' in DIALING doesn't set that one off. We'll
;	    never see the 'O' in the on line message as the '*' grabs it first.
;	    This is kind of a kludge, but it works.
;	    This overlay assumes you are dropping DTR to disconnect. See the
;	    note at the DISC code if you plan to disconnect from here.
;	    (David Chapman)
;
; 09/05/84: Added option to check DCD to determine if a connection has
;           been made. THIS IS MACHINE SPECIFIC. Also, Switch 6 on the
;           Smartmodem should be UP. (David Jewett)
;
; 07/16/84: Added equate NUMRES to enable/disable numeric result code 
;	    interpretation.  Under TurboDos, the first digit of the 
;	    phone number was being interpreted as a result code as it 
;	    was echoed by the Anchor modem as it dialed.  Set NUMRES false
;	    to disable numeric results. (Bob Puckett)
;
; 06/06/84: Fixed problem for Anchor users, where, when the modem returned
;	    "DIAL TONE", the "N" in "TONE" was being regarded as a NO-CONNECT
;	    code.  Now we flush the entire result line before reading another.
;	    Also added code for numeric version of "CONNECT 1200".  --RGF
;
; Small bug repaired: (V1.1) 05/14/84 (Steve Grandi): Smartmodem was not being 
;	flushed after a dial string so that last digit of the phone number 
;	was being interpreted as a numeric result code causing the program, 
;	for certain numbers, to give up even as the modem merrily dialed away.
;
; This modules adapts MEX for the NEC N212BR-L1 modem. It is quite
; machine specific. I don't know of any other modem that uses
; this scheme. The main function of this module is to provide 
; dialing capability; the disconnect vector is ancillary.
; You may use this module as a model to develop dialing routines
; for non-standard modems (e.g., the Racal-Vadic).  The only
; pertinent entry point is the DIAL routine; you'll find entry
; specs for that below.
;
; The only conditional you might want to change in this
; module is the DISC equate below -- if left on, MEX will
; use the Smartmodem's disconnect code.  If you prefer to
; provide your own in your overlay's DISCV vector (e.g.,
; by dropping DTR), then set DISC to FALSE and re-assemble.
; (If you don't understand this, then play it safe, and
; leave the equate set as it is). (Set FALSE here - dlc)
;
; This overlay will work with any modem overlay that terminates
; prior to 0B00H
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;
DCD	EQU	FALSE		; TRUE = CHECK DCD FOR CARRIER
	IF	DCD		; if using DCD, we must know the following:
STPORT	EQU	0EDH		; ... Status Port assignment to get DCD
DCDBIT	EQU	0100$0000b	; ... Bit HIGH to test for DCD
	ENDIF	; DCD
;
DISC	EQU	FALSE		;<<== CHANGE TO FALSE IF YOU DISC. WITH DTR
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
ILP	EQU	240		;INLINE PRINT
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
; scheme employed here for the Smartmodem).
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
STDIAL:	LXI	H,DIALBF	;SET UP BUFFER POINTER
	SHLD	DIALPT
	RET
;
; Here on an end-dial sequence
;
ENDIAL:	MVI	M,CR		;STUFF END-OF-LINE INTO BUFFER
	INX	H		;FOLLOWED BY TERMINATOR
	MVI	M,0
	MVI	B,CR		; Send a couple of CRs to put the
	MVI	C,SNDCHR	;   modem in the interactive mode.
	CALL	MEX		;   If it's already there thats ok too.
	MVI	B,20		; Two second wait
	MVI	C,TIMER
	CALL	MEX
	MVI	B,CR		; There goes the second one
	MVI	C,SNDCHR
	CALL	MEX
	MVI	B,20		; And another 2 seconds
	MVI	C,TIMER
	CALL	MEX
	MVI	B,'K'		; Keyboard dial in NEC modem
	MVI	C,SNDCHR
	CALL	MEX
	MVI	B,20		; Wait a couple of seconds
	MVI	C,TIMER
	CALL	MEX
	LXI	H,DIALBF	;POINT TO DIALING STRING
	CALL	SMSEND		;SEND IT
WAITSM:	MVI	C,INMDM	
	CALL	MEX		;CATCH ANY OUTPUT FROM THE MODEM
	JNC	WAITSM		;LOOP UNTIL NO MORE CHARACTERS
;
; THE FOLLOWING LOOP WAITS FOR A RESULT FROM THE MODEM (UP TO
; 60 SECONDS: YOU MAY CHANGE THIS VALUE IN THE FOLLOWING LINE).
; NOTE THAT THE SMARTMODEM HAS AN INTERNAL 30 SECOND TIMEOUT WHILE
; FOR A CARRIER ON THE OTHER END.  YOU CAN CHANGE BY PLAYING WITH THE
; S7 VARIABLE (I.E. SEND THE SMARTMODEM "AT S7=20" TO LOWER THE 30 SECOND
; WAIT TO 20 SECONDS).
;
RESULT:	MVI	C,60		;<<== MAXIMUM TIME TO WAIT FOR RESULT
SMWLP:	PUSH	B
	MVI	B,1		;CHECK FOR A CHAR, UP TO 1 SEC WAIT
	MVI	C,TMDINP	;DO TIMED INPUT
	CALL	MEX
	POP	B
	CPI	'*'		; parse the returned string for
	JZ	SMTEST		;  valid characters
	CPI	'O'		; if an abort
	JZ	SMTEST
	CPI	'U'		; if it's busy
	JZ	SMTEST
	CPI	'R'		; if it's ringing
	CZ	RING
;
	IF	DCD		;if DCD is available, take a look at it
	IN	STPORT		;   get the status byte
	ANI	DCDBIT		;   and test the DCD flag
	XRI	DCDBIT		;   return with A=0 if found,
	RZ			;but otherwise ...
	ENDIF	;DCD
;
	PUSH	B		; TEST FOR CONTROL-C FROM CONSOLE
	MVI	C,CHEKCC
	CALL	MEX
	POP	B
	JNZ	SMNEXT		;IF NOT, JUMP
	MVI	B,' '		;YES, SHUT DOWN THE MODEM
	MVI	C,SNDCHR	;  NEC uses a space to abort dialing
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
	JC	RESULT		;IF RESULT UNKNOWN, IGNORE IT
	RET
;
SMANAL:	MVI	B,0		;PREP CONNECT CODE
	CPI	'*'		;"CONNECT"? (NEC "*ON LINE*")
	RZ

	INR	B		;PREP BUSY CODE B=1
	CPI	'U'
	RZ

	INR	B		;PREP NO CONNECT MSG B=2
	CPI	'O'		;N=NO CONNECT (NEC "AB'O'RT")
	RZ

	MVI	B,4		;PREP MODEM ERROR
	CPI	'O'		;E=ERROR (NEC "AB'O'RT")
	RZ

	STC			;UNKNOWN...
	RET
;
RING:	PUSH	B		; is that the phone ?
	MVI	C,ILP
	CALL	MEX
	DB	'Ringing... ',0
	POP	B
	RET			; go back & find if successful
;
; FOLLOWING ROUTINE DISCONNECTS THE MODEM USING SMARTMODEM
; CODES. ALL REGISTERS ARE AVAILABLE FOR THIS FUNCTION.
; NOTHING RETURNED TO CALLER.
; This is not used in this implementation. However, if you do
; not use DTR to disconnect and you want to use this routine
; set the disconnect code in the NEC modem to this string (+++ath)
; or to whatever other string you desire. Be sure to change the
; string here to match the one you set in the modem.
;
	IF	DISC
;
DISCON:	MVI	B,20
	MVI	C,TIMER		;WAIT 2 SECONDS
	CALL	MEX
	LXI	H,SMATN		;SEND '+++'
	CALL	SMSEND
	MVI	B,20		;WAIT 2 MORE SECONDS
	MVI	C,TIMER
	CALL	MEX
	LXI	H,SMDISC	;SEND 'ATH'
	CALL	SMSEND
	MVI	B,1		;WAIT 1 SECOND
	MVI	C,TIMER
	CALL	MEX
	RET
;
SMATN:	DB	'+++',0
SMDISC:	DB	'ATH',CR,0
;
	ENDIF
;
; SMARTMODEM UTILITY ROUTINE: SEND STRING TO MODEM
;
SMSEND:	MVI	C,SNDRDY	;WAIT FOR MODEM READY
	CALL	MEX
	JNZ	SMSEND
	MOV	A,M		;FETCH NEXT CHARACTER
	INX	H
	ORA	A		;END?
	RZ			;DONE IF SO
	MOV	B,A		;NO, POSITION FOR SENDING
	MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	CALL	MEX
	JMP	SMSEND
;
; DATA AREA
;
DIALBF:	DS	52		;2 * 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	DS	2		;DIAL POSITION POINTER
;
	END
