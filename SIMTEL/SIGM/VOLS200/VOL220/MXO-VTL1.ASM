;      	   ====== MEX OVERLAY FOR VENTEL-MDM212 PLUS MODEM =====
;          ==========   with OTRONA ATTACHE COMPUTER   =========
;              [ MXO-VTL1.ASM    Version 1.0    ..by PHIL OYER ]
;
;  This overlay is hardware-specific for Z80SIO and OTRONA ATTACHE computer.
;
;  ****  Adapted from Smartmodem overlay for MEX: revision 1.2 which was ****
;         *****  written 04/16/84 by Ronald G. Fowler (V1.0) *****
;
; 08/23/84: Revised ENDIAL:  SMANAL: and DISCON: routines to autodial the 
;	    Ventel MDM212 Plus intelligent modem. Also changed the DB's for
;	    SMATN:  SMDISC: and SMDIAL: to correspond to the Ventel modem
;	    instruction codes. The DISC equate was left TRUE and the Ventel
;	    disconnect routine was simply inserted as a new DISCON: routine 
; 	    even though the routine as written disconnects by dropping DTR 
;	    momentarily. The code sent by DISCON to the SIO to cause DTR drop 
;	    (7AH out port 0F1h) and DTR restore (0EAh out port 0F1H) are 
;	    specific for the Z80SIO and the OTRONA ATTACHE. Change to other
;	    systems should be simple...just insert your own status port into
;	    MODCTL1: equate in this overlay. If you have a Z80SIO, that 
;	    should be all...otherwise you'll have to tell your own SIO device
;	    how to drop DTR and restore it in the DISCON: routine....[PEO]
;
; Small bug repaired: (V1.1) 05/14/84 (Steve Grandi): Smartmodem was not being 
;	flushed after a dial string so that last digit of the phone number 
;	was being interpreted as a numeric result code causing the program, 
;	for certain numbers, to give up even as the modem merrily dialed away.
;
; This module adapts MEX for the DC Hayes Smartmodem (as well
; as many others -- including US Robotics -- that use a similar
; command language). The main function of this module is to pro-
; vide dialing capability; the disconnect vector is ancillary.
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
; leave the equate set as it is).
;
; This overlay will work with any modem overlay that terminates
; prior to 0B00H
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
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
MODCTL1:EQU	0F1H		;INSERT YOUR MODEM STATUS PORT HERE
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
ENDIAL: MVI	M,CR		;PUT <CR> INTO DIAL BUFFER
	INX  	H		
	MVI	M,'>'		;PUT '>' (VENTEL BATCH DELIM) INTO DIAL BUFFER
	INX	H
	MVI 	M,0		;TERMINATE DIAL BUFFER
	LXI	H,SMDIAL	;POINT TO DIALING STRING
	CALL	SMSEND
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
	JC	RESULT		;IF RESULT UNKNOWN, IGNORE IT
	RET
;
SMANAL:	MVI	B,0		;PREP CONNECT CODE
	CPI	'O'		;O="ONLINE "
	RZ
	INR	B		;PREP BUSY CODE B=1
	CPI	'B'		;B="BUSY"
	RZ
	INR	B		;PREP NO CONNECT MSG B=2
	MVI	B,4		;PREP MODEM ERROR
	CPI	'N'		;N="NO ANSWER"
	RZ
	STC			;UNKNOWN...
	RET
;
; FOLLOWING ROUTINE DISCONNECTS THE MODEM USING SMARTMODEM
; CODES. ALL REGISTERS ARE AVAILABLE FOR THIS FUNCTION.
; NOTHING RETURNED TO CALLER.
;
	IF	DISC
;
DISCON:	MVI	A,5		;SIO WRITE REG 5 SELECT
	OUT	MODCTL1
	MVI	A,7AH		;TURN OFF DTR (7AH)
	OUT	MODCTL1
	CALL	DLY		;SHORT DELAY
	MVI	A,5		;SIO WRITE REGISTER 5 SELECT
	OUT	MODCTL1
	MVI	A,0EAH		;TURN DTR BACK ON (0EAH)
	OUT	MODCTL1
	CALL    DLY		;SHORT DELAY
	LXI	H,SMATN		;FIRST <CR> TO REINIT VENTEL
	CALL    SMSEND
	CALL 	DLY		;SHORT DELAY BETWEEN <CR>'S
	LXI	H,SMATN		;SECOND <CR> TO REINIT VENTEL
	CALL 	SMSEND
	CALL	DLY
	LXI	H,SMDISC	;POINT TO QUIT COMMAND
	CALL	SMSEND
	CALL	DLY		;SHORT DELAY
	LXI	H,SMATN		;SEND ANOTHER <CR>
	CALL	SMSEND
	CALL 	DLY
	LXI	H,SMATN		;AND AGAIN
	CALL	SMSEND
	RET
DLY:	MVI	B,4	
	MVI	C,TIMER
	CALL 	MEX
	RET
;
SMATN:	DB	CR,0	      ;VENTEL CODE
SMDISC:	DB	'Q',0	      ;VENTEL QUIT COMMAND
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
SMDIAL:	DB	'<','K'		;START VENTEL DIAL COMMAND (BATCH SEND)
DIALBF:	DS	52		;2* 24 CHAR MAX, + CR + NULL + SLOP
DIALPT:	DS	2		;DIAL POSITION POINTER
;
	END
