			       BYE
			    CALLBACK
			  MODIFICATION
			  ------------

     With this modification to the B5IM code in BYE5 or
equivalent B3IM code in recent versions of BYE3, your modem only
answers the second of two calls placed less than a minute apart,
and only then if the telephone rang less than three times on the
first call.  This makes your computer accessable on a line
ordinarily used for voice communication, without preventing use
of that line by incoming voice callers.

     Changes are made to three areas of the BYE source code.

     First, add the following equates in the OPTION CONFIGURATION
SECTION.  Location is not critical; I added them after the four
equates under the heading "The next 4 equates are only used if
B5IM is YES" --

-----------------------------------------------------------------
;
;	Equates for callback feature - B5IM must = YES
;
CALLBK	EQU	YES		; Yes activates callback code in B5IM
CLBKTM	EQU	30		; Seconds to wait for callback (<64)
CBMSGS	EQU	YES		; If YES, ring count, ready and time up
				; messages are printed (also activated
				; by PRGRSS)
;
;
;
-----------------------------------------------------------------

     Next, go to the B5IM code.
DELETE the portion which looks like this:

	 IF	B5IM
IMRING: CALL	MDINST		; Character ready from modem?
	RZ			; No
	CALL	MDINP		; Get the modem response code
	ANI	7FH		; Strip parity
	 ENDIF			; B5IM
;
	 IF	B5IM AND PRGRSS
	CALL	RCDISP		; Display RC for local sysop
	PUSH	PSW
	LXI	H,LFMSG
	CALL	PRINTL		; Turn up a line on crt
	POP	PSW
	 ENDIF			; PRGRSS
;
	 IF	B5IM
	CPI	CR
	RZ
	CPI	LF
	RZ
	CPI	'2'		; Ring?
	JNZ	REDOIT		; No, something wrong, start over
	 ENDIF			; B5IM


and REPLACE that code with this:

-----------------------------------------------------------------

;*************************************************************
;
;	B5IM MODIFIED FOR CALLBACK
;
;*************************************************************
	 IF	B5IM
IMRING:
	 ENDIF
	 IF	B5IM AND CALLBK
	LHLD	RDYFLG		; Does flag show
	MOV	A,H		; ready for callback?
	ORA	L
	JZ	RCT4		; No...carry on
	CALL	KDELAY		; Yes...continue countdown
	DCX	H		;
	MOV	A,H		; and see if time up
	ORA	L
	SHLD	RDYFLG
	JNZ	RCT4		; Time not up ... carry on
	 ENDIF			; B5IM AND CALLBACK
	 IF	B5IM AND CALLBK AND (CBMSGS OR PRGRSS)
	LXI	H,RNMS4 	; Time up ... print message
	CALL	PRINTL
	 ENDIF			; B5IM, etc.
	 IF	B5IM AND CALLBK
RCT4:
	 ENDIF			; B5IM AND CALLBK
	 IF	B5IM
	CALL	MDINST		; Character ready from modem?
	RZ			; No
	CALL	MDINP		; Get the modem response code
	ANI	7FH		; Strip parity
	 ENDIF			; B5IM
;
	 IF	B5IM AND PRGRSS
	CALL	RCDISP		; Display RC for local sysop
	PUSH	PSW
	LXI	H,LFMSG
	CALL	PRINTL		; Turn up a line on crt
	POP	PSW
	 ENDIF			; PRGRSS
;
	 IF	B5IM
	CPI	CR
	RZ
	CPI	LF
	RZ
	CPI	'2'		; Ring?
	JNZ	REDOIT		; No, something wrong, start over
	 ENDIF			; B5IM
;
	 IF	B5IM AND CALLBK
	LHLD	RDYFLG		; Ready for callback?
	MOV	A,H
	ORA	L
	LXI	H,0		; (Reset counter regardless)
	SHLD	RDYFLG
	JNZ	IMRIN1		; Yes ... then answer 'phone
RNGCNT: XRA	A		; Reset ringcounter and
	STA	RNG
	 ENDIF
	 IF	B5IM AND CALLBK AND (CBMSGS OR PRGRSS)
	MVI	A,' '
	STA	RNMS2		; Ascii representation buffer
	STA	RNMS2+1
	STA	RNMS2+2
	 ENDIF			; B5IM, etc.
	 IF	B5IM AND CALLBK
RCT0:	LDA	RNG		; Update ringcount
	INR	A
	STA	RNG
	 ENDIF
	 IF	B5IM AND CALLBK AND (CBMSGS OR PRGRSS)
	LXI	H,RNMS2 	; Put in ascii form
	CALL	DEC8
	LXI	H,RNMS1 	; And print # in message
	CALL	PRINTL
	 ENDIF
	 IF	B5IM AND CALLBK
	LXI	B,8000		; Set ringstoptest timer
RCT1:	CALL	MDINST		; Anything from modem?
	JZ	RCT2		; No
	CALL	MDINP		; Yes ... get it
	ANI	07FH
	CPI	'2'		; Ring?
	JZ	RCT0		; Yes ... update ringcount
				; and reset counter
RCT2:	CALL	KDELAY		; 8 seconds since last ring?
	DCX	B
	MOV	A,C
	ORA	B
	JNZ	RCT1		; No ... keep checking
	 ENDIF
	 IF	B5IM AND CALLBK AND (CBMSGS OR PRGRSS)
	LXI	H,LFMSG
	CALL	PRINTL
	 ENDIF
	 IF	B5IM AND CALLBK
	LDA	RNG		; Yes ... more than 2 rings?
	CPI	3
	JNC	RCT3		; Yes ... Ignore that call
	 ENDIF
	 IF	B5IM AND CALLBK AND (CBMSGS OR PRGRSS)
	LXI	H,RNMS3 	; Its a callback signal, so
	CALL	PRINTL		; print ready message and
	 ENDIF
	 IF B5IM AND CALLBK
				; Set ready flag/timer
	LXI	H,CLBKTM*1000
	SHLD	RDYFLG
RCT3:	XRA	A		; Set zero flag and return
	RET			; as though no call
	 ENDIF			; B5IM AND CALLBK

-----------------------------------------------------------------


     Finally, go to the messages section near the end of the
code, and place the following code after the end of the B5IM
command strings section --


-----------------------------------------------------------------
;
;
;
	 IF	B5IM AND CALLBK
RNG:	DB	0
RDYFLG: DB	0,0
	 ENDIF
	 IF	B5IM AND CALLBK AND (CBMSGS OR PRGRSS)
RNMS1:	DB	CR,'Ring #'
RNMS2:	DB	'   ',0
RNMS3:	DB	'Ready for callback...',CR,LF,0
RNMS4:	DB	'No callback...time up!',CR,LF,0
	 ENDIF			; B5IM AND CALLBK, etc.
;
;
;
-----------------------------------------------------------------

Notes:

     1) For use with BYE3, proceed as indicated but change "B5IM"
to "B3IM" wherever it appears in the modification.

     2) The modified program starts looking for the callback ring
seven or eight seconds after the last ring of a one- or two-ring
call.  It answers the callback after the first ring.  It stops
looking if no callback occurs within CLBKTM seconds (actually
about 1.18 times CLBKTM if MHZ = 4).  CLBKTM should not be
greater than 64.

O. Gray
Toronto, Ont
Sept. 12, 1985
