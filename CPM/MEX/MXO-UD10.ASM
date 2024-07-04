; MXO-UD10.ASM - UDS 212 A/D MODEM OVERLAY FOR MEX
;
; You will want to look this file over carefully. There are a number of
; things that will have to be done to adapt your computer overlay file
; for proper interaction with this modem overlay file.
;
;
; Edit this file for your preferences then follow the "TO USE:" example
; shown below.
;
;	TO USE: Assemble with ASM.COM or equivalent
;		assembler.  Then use MLOAD21.COM (or later) to combine
;		this overlay with the original MEXxx.COM file, and your
;		computer specific overlay file.( MXO-xxxx in the example
;		given below).
;
;		A>MLOAD21 MEX.COM=MEXxx.COM,MXO-UD10,MXO-xxxx
;
;	>>>>  Report bugs to fortfone rcp/m 414-563-9932 <<<<<<<<<<<< 
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
YES	EQU	0FFH
NO	EQU	000H
;
;	UDSNEW - If yes, this is a revised UDS 212 A/D.  The new
;	models can be disconnected by sending the string 'XXXT' followed
;	by carriage return.  Older models can only be disconnected by
;	dropping DTR low for at least 60 msec.  Define UDSNEW to be yes
;	if you want to use the 'XXXT' disconnect string,  Define UDSNEW
;	to be NO to use the DTR disconnect method. (The computer overlay
;	must intercept the DISCV vector, drop DTR, then JMP to the original
;	DISCV vector address.)
;
UDSNEW	EQU	YES
;
;
;  *NOTES* As an owner of a UDS 212-A/D modem you are probably aware
;	of the consequences regarding training the modem at one baud rate
;	and then changing baud rates without untraining the modem first.
;	The poor thing will go crazy.  Using this overlay *requires* the
;	user to always disconnect a call before changing baud rates.
;	The Ctl-J + N command will disconnect the modem and then untrain 
;	the ACU.  Do *NOT* make a completed call, exit terminal mode
;	with Ctl-J + E, and then try to change baud rates. (Incomplete or
;	aborted calls don't count, the modem is automatically untrained
;	if the call isn't completed.)  If you're in doubt, enter terminal
;	mode and give the disconnect command, Ctl-J + N, this will insure
;	the modem is disconnected and 'untrained'.
;
;
; MEX11 if YES will compile the patches for the smartmodem entry points
;	that are new to MEX version 1.10 (MEX11)
;
MEX11	EQU	NO
;
;
BDOS		EQU	005H
CR:		EQU	0DH		;carriage return
LF:		EQU	0AH		;linefeed
;
; MEX service processor stuff
;
MEX	EQU	0D00H		; MEX SERVICE PROCESSOR ENTRY POINT
INMDM	EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER	EQU	254		;delay 100ms * reg B
TMDINP	EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC	EQU	252		;check for ^C from KBD, Z=present
SNDRDY	EQU	251		;test for modem-send ready
RCVRDY	EQU	250		;test for modem-receive ready
SNDCHR	EQU	249		;send a chara (B) to the modem (after sndrdy)
RCVCHR	EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP	EQU	247		;table search: see CMDTBL comments for info
PARSFN	EQU	246		;parse filename from input stream
BDPARS	EQU	245		;parse baud-rate from input stream
SBLANK	EQU	244		;scan input stream to next non-blank
EVALA	EQU	243		;evaluate numeric from input stream
LKAHED	EQU	242		;get nxt char w/o removing from input
GNC	EQU	241		;get char from input, cy=1 if none
ILP	EQU	240		;inline print
DECOUT	EQU	239		;decimal output
PRBAUD	EQU	238		;print baud rate
;
CONOUT	EQU	2		; simulated BDOS functions, for MEX
PRINT	EQU	9
INBUF	EQU	10
;
;	PDIAL completion codes to be returned to MEX
;
PCARR	EQU	0	; CARRIER DETECT, CONNECTION MADE
PBSY	EQU	1	; PHONE IS BUSY
PNOANS	EQU	2	; NO ANSWER
PABRT	EQU	3	; KEYBD ABORT
PERR	EQU	4	; MODEM ERROR
;
;
;
;
;
	ORG 0162H		; MEX main overlay
DIALV:	JMP	PDIAL		;jump to modem dialing routine  162H
DISCV:	JMP	MDMDSC		;jump to modem disconnect routine    165H
;
; NOTE: User must drop DTR for at least 60 msec and then call MDMRST
; 	to properly disconnect the UDS 212 A/D
;
;
	ORG 0B00H
;
;	Entry point to dialing routine. This routine saves all the digits in
;	a buffer, dialing the number only after all digits/commands have been
;	received.  It then monitors the ACU call progress responses and returns
;	the proper success/failure codes to MEX.
;
PDIAL:	EI
	CPI	254
	JZ	STDIAL	; start of dialing sequence, reset pointers
	CPI	255
	JNZ	DDIGIT	; store digit, will dial the whole number later
;
;	all digits recieved, time to dial the number.
;
	XRA	A	; Null terminate the phone number
	CALL	DDIGIT
;
;
	CALL	FLUSH	; Flush the modem input
	MVI	B,3	; 0.3 second delay, Baud rate might have changed,
	MVI	C,TIMER	; this lets your UART adjust to the new rate (?).
	CALL	MEX
	CALL	FLUSH	; Flush input again.
;
;	First step is to train the modem to the current baud rate.
;
	CALL	MDMTRN	; Send the modem training command 'EN'
	JC	DLERR	; Exit upon training error.
;
;	Now dial the number
;
	MVI	A,'D'	; Dialing command = 'D'
	CALL	SEND1
	LXI	H,DNUMBR ; Send the phone number
	CALL	SNDSTR
	MVI	A,CR	; Send a Return to start the dialing procedure
	CALL	SEND1
;
;	Begin call progress monitoring
;
	MVI	B,20	; Delay 2 seconds, to let modem get started.
	MVI	C,TIMER
	CALL	MEX
;
	XRA	A	; clr the completion code flag
	STA	CCODE
;
;	Look for 'COMPLETE', 'BUSY', or 'ABORT' responses followed by
;	a cr,lf combination.  If there is no response from the modem in
;	25.5 seconds, report an error.
;
PDLP0:	MVI	B,0	; no response timeout counter 0=25.5 sec
PDLP1:	DCR	B
	JZ	DLERR	; Exit upon timeout error
	PUSH	B
	MVI	C,CHEKCC ; Check for Ctl-C from Keyboard
	CALL	MEX
	JZ	PDABRT
	MVI	C,INMDM
	CALL	MEX
	POP	B
	JC	PDLP1	; try again, if no chara
;
PDLP2:	CPI	'C'	; Check for the letter 'C' as in 'COMPLETE'
	JNZ	PDLP3
	STA	CCODE
;
PDLP3:	CPI	'Y'	; Check for the letter 'Y' as in 'BUSY'
	JNZ	PDLP4
	STA	CCODE
;
PDLP4:	CPI	LF	; Check for LF to terminate the response line
	JNZ	PDLP0	; reset timer and check for next chara
;
; LF has been received, if 'C' was received, we were a success, if not
; it was busy or aborted
;
	LDA	CCODE
	CPI	'C'
	JZ	PDOK
;
	CPI	'Y'
	JZ	PBUSY
; Default must be No answer/No ABT
	MVI	A,PNOANS
	JMP	MDMRST
;
PBUSY:	MVI	A,PBSY	; phone busy code
	JMP	MDMRST	; reset modem to untrained state
;
DLERR:	MVI	A,PERR	; modem error code
	JMP	MDMRST
;
PDABRT:	POP	B
	MVI	A,PABRT	; Keyboard abort code
;
;	MDMRST - Reset the ACU to an untrained state.  Aborts any
;	dialing operation in progress.
;
;	Send 'Q'. Send 'OG0'.
;	Send 3 space characters, for timing
;
MDMRST:	EI
	PUSH	PSW	; Save 'A', trashes all other reg's
	CALL	FLUSH
	MVI	A,'Q'	; Abort dialing in progress
	CALL	SEND1	;
	CALL	GCOLON	; Check if ACU is alive
	JC	MDMRS1	;
	LXI	H,CLRSTR ; Send the 'OG0' command string
	CALL	SNDSTR	; Send it if ACU was alive
MDMRS1:	CALL	FLUSH
	POP	PSW	; restore 'A'
	RET
;
PDOK:	MVI	A,PCARR
	RET
;
;	start the dialing process, reset the dial pointer
;
STDIAL:	LXI	H,DNUMBR
	SHLD	DPTR
	RET
;
;	Add a digit to the phone number string
;
DDIGIT:	LHLD	DPTR
	MOV	M,A
	INX	H
	SHLD	DPTR
	RET
;
;
TRNSTR:	DB	'EN',0
CLRSTR:	DB	'OG0   ',0
CCODE:	DB	0	; Completion code byte
DNUMBR:	DS	40	; storage for phone number
DPTR:	DW	DNUMBR	; Pointer into DNUMBR for next digit
;
;
; Support routines
;
;	Send null terminated string to modem
; 
SNDSTR:	MOV	A,M
	ORA	A
	RZ		; Null terminated string
	INX	H
	PUSH	H
	CALL	SEND1
	POP	H
	JMP	SNDSTR
;
;	Send One chara to modem
;
SEND1:	PUSH	PSW
SND1LP:	MVI	C,SNDRDY
	CALL	MEX
	JNZ	SND1LP
	POP	PSW
	MOV	B,A
	MVI	C,SNDCHR
	JMP	MEX
;
;	'Train' the modem ACU
;
MDMTRN:	LXI	H,TRNSTR	; Send the training string
	CALL	SNDSTR
	CALL	GCOLON	; Check for a ':' from the modem
	RC		; CY=1 indicates training error
	XRA	A	; CY=0
	RET
;
;	Get a colon response from the modem, if there is a character
;	timeout before receiving colon, return CY=1 to indicate error
;	All other characters are accepted, up to a maximum of 30
;
GCOLON:	MVI	C,INMDM
	MVI	B,30
GCOLP:	PUSH	B
	CALL	MEX
	POP	B
	RC		; return CY=1 upon modem timeout..
	CPI ':'
	RZ		; return CY=0 upon receving ':'
	DCR	B
	STC
	RZ		; return CY=1 upon too many characters
	JMP	GCOLP
;
FLUSH:	MVI	C,INMDM	; Read until there are no more charas in 100msec
	CALL	MEX
	JNC	FLUSH
	RET
;
;
MDMDSC:	PUSH	PSW
;
	IF UDSNEW
	  LXI	H,DSCSTR
	  CALL	SNDSTR
	  CALL	GCOLON
	ENDIF	; UDSNEW
;
	CALL	MDMRST	; untrain the modem ACU
	MVI	B,10	; 1 sec delay, let the command reach the modem and
	MVI	C,TIMER	; give it time to reset itself.
	CALL	MEX
	POP	PSW
	RET
;
DSCSTR:	DB	'XXXT',CR,0
;
;	NEW MEX1.10 Additional Code
;
	IF	MEX11
SSET:	  MVI	C,ILP
	  CALL	MEX
	  DB 	'SSET Command is not supported'
	  DB	CR,LF,0
DUMMY:	  RET
;
; MEX 1.10 Smartmodem patch points, not used for UDS 212 A/D
;
	ORG 0D55H	; Fixed at address 0D55H
	  DW	DUMMY	; SMINIT - not used.
	  DW	SSET	; SSET command not implemented.
	  DW	DUMMY	; SMEXIT - not used.
	ENDIF	; MEX11
;
	END
