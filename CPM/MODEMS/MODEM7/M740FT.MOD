;*** New routine for T-mode file transfer in MDM740
;*** Eric Meyer - 1/85  (new code is in lowercase)
;(Note that the SPD command and its time delays have been deleted, and
;instead the transmitted characters now echo [from the remote in T mode,
;locally in L mode].  Also there's a new XONCH, which you can put in 
;place of CRDLY if you want; modify your TXO routine to ask you what the
;XON character should be, and store it in XONCH.  This allows waiting for
;virtually any "system prompt".  Eg: use ":" for prompts like "1:")
;
MODOUT:	PUSH	PSW		;save the character so can use 'A' reg.
	CPI	LF
	JNZ	MODOUTL
	LDA	ADDLF		;going to send the line feed to modem?
	ORA	A
	JNZ	MODOUTL		;if yes, go do it
	POP	PSW		;get the char. back (a line feed)
	lda	locflg
	ora	a		;need to fake echo?
	rz
	mvi	a,lf		;yes.
	CALL	TYPE		;show on CRT, do not send to modem
	RET
;
MODOUTL: call	rcvready	;check for incoming stuff
	jnz	mdoutl1
	call	in$moddatp	;get char
	ora	a		;(ignore nulls)
	jz	modoutl
	cpi	xoff		;(check for XOFF)
	push	psw
	cnz	type		;show on screen if not
	pop	psw
	jnz	modoutl
	LDA	XOFFTST		;waiting for X-off, X-on ?
	ORA	A
	cnz	waitxon		;if yes, wait for XON
mdoutl1: CALL	SENDRDY		;wait until modem is ready to send
	jnz	mdoutl1
	POP	PSW		;get the character back
	push	psw
	CALL	OUT$MODDATP	;send character to modem
	lda	locflg
	ora	a		;need to fake echo?
	jz	mdoutl2
	pop	psw		;yes.
	push	psw
	call	type
	jmp	mdoutl3
mdoutl2: call	stat		;check keyboard
	ora	a
	jnz	mdoutl3
	call	rcvready	;wait for echo
	jnz	mdoutl2
	call	in$moddatp
	call	type		;show it
mdoutl3: pop	psw
	CPI	CR		;was it an end of line?
	RNZ
;
MODOUTN:LDA	XONWAIT		;wait for X-on after CR?
	ORA	A
	JNZ	WAITXON
	RET
;.....
;
;
TXOFF:	CALL	RCVREADY
	RNZ
	CALL	IN$MODDATP
	ANI	7FH
	CPI	XOFF
	CZ	WAITXON
	RET
;.....
;
;
WAITXON:CALL	RCVREADY	;have a character? (like x-on)
	JNZ	WTXON1		;if no char. see if want to abort
	CALL	IN$MODDATP
	ANI	7FH		;strip off any parity
	JZ	WAITXON		;ignore nulls
	push	psw
	call	type		;show it
	pop	psw
	mov	e,a
	lda	xonch	;XON character
	cmp	e		;see if char. was x-on
	rz
;
WTXON1:	CALL	STAT		;test to see if requesting cancellation
	JZ	WAITXON
	CALL	KEYIN		;can abort if the x-on never comes
	CPI	CANCEL		;ctl-x to abort?
	JNZ	WAITXON		;if not, keep going
	RZ
