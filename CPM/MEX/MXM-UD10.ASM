; MXM-UD10.ASM - MEX1.10 Smart modem overlay for UDS 212 A/D modem
;
;	TO USE: Edit the UDSNEW parameter for your particular modem.
;		Assemble with ASM.COM or equivalent assembler.  Then
;		use MLOAD21.COM (or later) to combine this overlay
;		with the original MEXxx.COM file, and your computer
;		specific overlay file.( MXO-xxxx in the example below).
;
;		A>MLOAD21 MEX.COM=MEXxx.COM,MXM-UD10,MXO-xxxx
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
;  *NOTE* As an owner of a UDS 212-A/D modem you are probably aware
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
;---------------
;
; Misc equates
;
BDOS		EQU	005H
CR:		EQU	0DH		;carriage return
LF:		EQU	0AH		;linefeed
;
;---------------
;
; MEX service processor equates
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
PRNTBL	EQU	237		;print command table in columnar format
PRID	EQU	236		;print MEX ID on console
;
CONOUT	EQU	2		; simulated BDOS functions, for MEX
PRINT	EQU	9
INBUF	EQU	10
;
;---------------
;
;	PDIAL completion codes to be returned to MEX
;
PCARR	EQU	0	; CARRIER DETECT, CONNECTION MADE
PBSY	EQU	1	; PHONE IS BUSY
PNOANS	EQU	2	; NO ANSWER
PABRT	EQU	3	; KEYBD ABORT
PERR	EQU	4	; MODEM ERROR
PNRING	EQU	5	; NO RING
PNDIAL	EQU	6	; NO DIAL TONE
;
;----------------
;
;	MEX Baud rate codes
;
BD110	EQU	0
BD300	EQU	1
BD450	EQU	2
BD600	EQU	3
BD710	EQU	4
BD1200	EQU	5
BD2400	EQU	6
BD4800	EQU	7
BD9600	EQU	8
BD1920	EQU	9
;
;-----------------
;
;	Entry points in the computer overlay area
;
	ORG 0162H		; MEX main overlay
	JMP	PDIAL		;jump to modem dialing routine  162H
	JMP	MDMDSC		;jump to modem disconnect routine    165H
MSPEED:	EQU	0107H		;MEX speed code byte
SET8BT:	EQU	0171H		;Set serial port for 8-bit data, no parity
SETNRM:	EQU	0174H		;Set serial port for normal operation.
;
;----------------
;
;	New MEX 1.10 Smartmodem overlay patch points.
;
	ORG 0D55H	; Fixed at address 0D55H
	DW	DUMMY	; SMINIT - not used.
	DW	SSET	; SSET command processor
	DW	DUMMY	; SMEXIT - not used.
;
;---------------
;
;	Smartmodem code begins at 0900H
;
	ORG 0900H
;
;---------------
;
;	PDIAL - Actual dial service routine.
;
;	Entry point to dialing routine. This routine saves all the digits in
;	a buffer, dialing the number only after all digits/commands have been
;	received.  It then monitors the ACU call progress responses and returns
;	the proper success/failure codes to MEX.
;
;	This routine is called by MEX with a dialing digit (ASCII) in the
;	A register.  The routine can use all registers.  The routine is called
;	with the special value  254 (decimal) to indicate the beginning of a
;	dialing sequence.  The special value 255 indicates the end of the
;	dialing sequence, and requires the PDIAL routine to return one of the
;	MEX dialing completion codes in the A register.
;
PDIAL:	CPI	254
	JZ	STDIAL	; start of dialing sequence, reset pointers
;
	CPI	255
	JNZ	DDIGIT	; store digit, will dial the whole number later
;
;	all digits recieved, time to dial the number.
;
	XRA	A	; Null terminate the phone number
	CALL	DDIGIT
;
;	check for 300/1200 baud rate. Modem ACU will not work at other rates.
;
	LDA	MSPEED
	CPI	BD300
	JZ	PDIAL0
	CPI	BD1200
	JZ	PDIAL0
;
	CALL	ILPRT
	DB	CR,LF,'Baud rate must be 300/1200 for Auto Dial - ',0
	JMP	DLERR	; return the modem error code
;
;	Return error code if an invalid dialing character was received.
;
PDIAL0:	LDA 	ERRFLG
	ORA	A
	JZ	PDIAL1
;
	CALL	ILPRT
	DB	CR,LF,'Invalid Digit/Chara in dial string - ',0
	JMP	DLERR	; return the modem error code
;
PDIAL1:	CALL	FLUSH	; Flush the modem input
	CALL	SET8BT	; Set the serial port for 8-bit operation.
	CALL	FLUSH	; Flush input again.
;
;	First step is to train the modem to the current baud rate.
;
	CALL	MDMTRN	; Send the modem training command 'EN'
	JC	DLERR	; Exit upon training error.
;
	LXI	H,DOPTS	; Send the options commands
	CALL	SNDSTR
	CALL	FLUSH	; Ignore modem responses
;
;	Now dial the number
;
	MVI	A,'D'	; Dialing command = 'D'
	CALL	SEND1
	LXI	H,DPREFX ; Send the dialing prefix
	CALL	SNDSTR
	LXI	H,DNUMBR ; Send the phone number
	CALL	SNDSTR
	MVI	A,CR	; Send a Return to start the dialing procedure
	CALL	SEND1
;
;	Begin call progress monitoring
;
	CALL	FLUSH	; Flush the "DIALING - " message
; *** Note: cannot abort with Control-C while waiting on first dial tone ***
	MVI	B,30	; get a chara, time out after 30 seconds
	MVI	C,TMDINP
	CALL	MEX
	JC	DLERR	; Timeout = Modem error
	CPI	'D'
	JNZ	PDLER	; No Dial tone error - exit
	CALL 	FLUSH	; Flush the "D.T. - " message
;
;	Got past first Dial Tone, now look for the following completion msgs.
;	If there is no response in 25.5 seconds, report a modem error to MEX.
;
;	COMPLETE
;	NO ABT - ABORT
;	BUSY - ABORT
;	NO D.T. - ABORT
;	NO ANSWER - ABORT
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
;
PDL20:	MVI	C,INMDM	; Flush charas until LF or a timeout is rcv'd.
	CALL	MEX
	JC	PDL21
	CPI	LF
	JNZ	PDL20
PDL21:	MVI	A,PCARR	; Return carrier detect (success) code to MEX
	CALL	SETNRM	; reset serial port for normal operation.
	RET
;
PDLP3:	CPI	'B'	; Check for the letter 'B' as in 'BUSY'
	JNZ	PDLP4
	MVI	A,PBSY ; Return the busy error code
	JMP	MDMRST
;
PDLP4:	CPI	'.'	; Check for '.' as in 'NO D.T.'
	JNZ	PDPLP5
PDLER:	MVI	A,PNDIAL ; Return the No dial tone error code
	JMP	MDMRST
;
PDPLP5:	CPI	'A'	; Check for 'A' as in 'NO ANSWER/NO ABT'
	JNZ	PDLP0	; Get/check another chara from modem
	MVI	A,PNOANS ; Return the no answer error code
	JMP	MDMRST
;
DLERR:	MVI	A,PERR	; Return the modem error code
	JMP	MDMRST
;
PDABRT:	POP	B
	MVI	A,PABRT	; Keyboard abort code
	JMP	MDMRST
;
;---------------
;
;	Start the dialing process, reset the dial pointer, error flag
;
STDIAL:	LXI	H,DNUMBR	; Reset the dial string pointer
	SHLD	DPTR
	XRA	A		; Clear the error flag
	STA	ERRFLG
	RET
;
;---------------
;
;	Add another digit to the phone number string
;
DDIGIT:	CPI	','	; map ',' into 'D' (delay)
	JNZ	DDGT1	
	MVI	A,'D'
;
; Check digit/chara for validity
;
DDGT1:	CALL	CHKDGT
	JC	DGTERR
;
; Load valid digit into phone num string
; Dashes and spaces are ignored...
;
	CPI	'-'
	RZ
	CPI	' '
	RZ
	LHLD	DPTR
	MOV	M,A
	INX	H
	SHLD	DPTR
	RET
;
; Invalid digit, set flag and exit.
;
DGTERR:	MVI	A,PERR	; Must use the modem error code
	STA	ERRFLG
	RET
;
;---------------
;
;	CHKDGT - Check for valid dialing digit/char
;	Returns CY=1 if invalid chara
;
CHKDGT:	MOV	B,A	; Save orig char in B
	LXI	H,CHRSTR
	MOV	A,M
;
DGTLP:	CMP	B
	RZ		; Character is ok, return CY=0
	INX	H	; Chk for end of table
	MOV	A,M
	ORA	A
	JNZ	DGTLP
;
	STC		; CY=1 indicates error
	RET
;
CHRSTR:	DB	0	; 0 is a valid digit, must be first digit of table.
	DB	'0123456789' ; Valid dialing digits
	DB	'PDWT'	; Special ACU commands, Pulse,Delay,Wait,Tone
	DB	'pdwt'	; Lower case versions okay.
	DB	'- '	; Allow dash and space for clarity
	DB	0	; end of table
;
TRNSTR:	DB	'EN',0
;
CLRSTR:	DB	'OG0   ',0
;
CCODE:	DB	0	; Completion code byte
;
DNUMBR:	DS	50	; storage for phone number
;
DPTR:	DW	DNUMBR	; Pointer into DNUMBR for next digit
;
ERRFLG:	DB	0	; Digit error flag
;
;---------------
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
;	Table Search, - for SSET command parsing
;
TSRCH:	  MVI	C,LOOKUP
	  JMP	MEX
;
;	In-Line Print, null-terminated string
;
ILPRT:	MVI	C,ILP
	JMP	MEX
;
;	CRLF - Send CR,LF to console
;
CRLF:	CALL	ILPRT
	DB	CR,LF,0
	RET
;
;---------------
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
;---------------
;
;	MDMRST - Reset the ACU to an untrained state.  Aborts any
;	dialing operation in progress. Preserves register A
;
;	Send 'Q' to abort dial operation
;	Send 'OG0' to untrain the ACU. (if ACU is active)
;
MDMRST:	EI
	PUSH	PSW	; Save 'A', trashes all other reg's
	CALL	SET8BT	; Set port for 8 bit data
	CALL	FLUSH
	MVI	A,'Q'	; Abort dialing in progress
	CALL	SEND1	;
	CALL	GCOLON	; Check if ACU is alive
	JC	MDMRS1	;
	LXI	H,CLRSTR ; Send the 'OG0' command string
	CALL	SNDSTR	;
MDMRS1:	CALL	FLUSH
	CALL	SETNRM	;reset the serial port for normal oper.
	CALL	FLUSH
	POP	PSW	; restore 'A'
	RET
;
;---------------
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
;---------------
;
;	Flush charas from modem, returns upon timeout.
;
FLUSH:	MVI	C,INMDM	; Read until there are no more charas in 100msec
	CALL	MEX
	JNC	FLUSH
	RET
;
;---------------
;
;	Disconnect modem from phone line and untrain the ACU.
;
;	Uses the Disconnect string if the modem has the new EPROM.
;	Otherwise the computer overlay must drop DTR for at least
;	60 msec to disconnect the modem.
;
MDMDSC:	PUSH	PSW
;
	IF UDSNEW
	  CALL	SET8BT
	  CALL	FLUSH
	  LXI	H,DSCSTR
	  CALL	SNDSTR
	ENDIF	; UDSNEW
;
	CALL	MDMRST	; untrain the modem ACU
	CALL	FLUSH	; extra delay for modem to reset itself.
	POP	PSW
	RET
;
	IF UDSNEW
DSCSTR:	  DB	'XXXT',CR,0
	ENDIF	; UDSNEW
;
;--------------------------------
;
; SSET command processing routine 
;
SSET:	MVI	C,SBLANK
	CALL	MEX
	JC	SETSHO
	LXI	D,CMDTBL
	CALL	TSRCH
	PUSH	H
	RNC
	POP	H
SETERR:	CALL	ILPRT
	DB	CR,LF,'SSet command error',CR,LF,0
	RET
;
;
CMDTBL:	DB	'?'+80H
	DW	SETHLP
	DB	'PREFI','X'+80H ; dialing prefix string
	DW	SETPRE
	DB	'OPTION','S'+80H ; Options command string
	DW	SETOPT
	; INSERT ADDITIONAL SSET COMMANDS HERE
	DB	0		;End of table
;
;---------------
;
; SSET <no-args> display status of all 'sset' items
;
SETSHO:	CALL	CRLF
	LXI	H,SHOTBL
SETSLP:	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	MOV	A,D
	ORA	E
	JZ	CRLF	;Exit thru CRLF
	PUSH	H
	XCHG
	CALL	GOHL
	CALL	CRLF
	POP	H
	JMP	SETSLP
;
GOHL:	PCHL
;
; table of Show routine addresses
;
SHOTBL:	  DW	OPTSHO	; Option commands
	  DW	PRESHO	; show the dialing prefix string
	; Add other status routines here
	  DW	0	; End of table
;
;-----------------------
;
; SSET ? print available SSET commands
;
SETHLP:	  CALL	ILPRT
	  DB	CR,LF,'Available SSET Commands: (UDS-212 A/D)',0
;
	  LXI	H,CMDTBL
	  MVI	C,PRNTBL
	  CALL	MEX
	  CALL	CRLF
	  JMP	CRLF	; Exit thru CRLF
;
;--------------
;
; SSET PREFIX {string} Change the dialing prefix string, default is 'P'
;	other useful prefixes are T, P9W, etc.
;
; SSET PREFIX			Print current string.
; SSET PREFIX ""		Set prefix to null string
; SSET PREFIX string		Set prefix to 'string'
; SSET PREFIX "string"		(Quotes are optional, same as above)
;
SETPRE:	  MVI	C,SBLANK	; Isolate the space terminated string
	  CALL	MEX
	  JC	PRESHO		; Show current string
;
	  MVI	B,(ENDPRE-DPREFX)-2	; B=Max length of string
	  LXI	H,DPREFX
	  MVI	C,GNC		; MEX service code for get next chara
SETPLP:	  PUSH	H
	  PUSH	B
	  CALL	MEX		; Fetch chara, CY=1 means end of string
	  JC	SETPEX
; Verify chara as a valid dialing digit. 
	  CPI	'"'
	  CNZ	CHKDGT
	  JNC	SETP1
; Invalid digit, report error, terminate PREFIX string.
	  CALL	ILPRT
	  DB	CR,LF,'Invalid character in PREFIX string'
	  DB	CR,LF,0
	  JMP	SETPEX
; Store good digit, except quote marks
SETP1:	  POP	B
	  POP	H
	  CPI	'"'
	  JZ	SETPLP
	  MOV	M,A		; Store new chara
	  INX	H
	  DCR	B		; Check for string too long
	  JNZ	SETPLP		; get next chara
	  JMP	SETPX1		; Exit, if no more room

SETPEX:	  POP	B
	  POP	H
SETPX1:	  MVI	M,0		; Finished. Insert 0, insert 'RET'
	  INX	H
	  MVI	M,0C9H		; Insert RET instruction
	; Fall thru to PRESHO
;
;---------------
;
; PRESHO  Show current dial prefix string.
;
PRESHO:	  CALL	ILPRT
	  DB	'Dialing prefix: ',0
	  CALL	ILPRT
DPREFX:	  DB	'P'	; dialing prefix string, default = 'P'
	  DB	0,0,0,0,0,0,0,0,0,0,0 ; Max of 12 charas
	  DB	0	; String must be null-terminated, *plus* a RET inst.
	  RET
ENDPRE:
;
;--------------
;
; SSET OPTIONS {string} Change the dialing options string, default is 'OF1'
;	other useful options are OBx
;
; SSET OPTIONS Print current string.
; SSET OPTIONS ""		Set options to null string
; SSET OPTIONS string		Set options to 'string'
; SSET OPTIONS "string"		(Quotes are optional, same as above)
;
SETOPT:	  MVI	C,SBLANK	; Isolate the space terminated string
	  CALL	MEX
	  JC	OPTSHO		; Show current string
;
	  MVI	B,(ENDOPT-DOPTS)-2	; B=Max length of string
	  LXI	H,DOPTS
	  MVI	C,GNC		; MEX service code for get next chara
SETOLP:	  PUSH	H
	  PUSH	B
	  CALL	MEX		; Fetch chara, CY=1 means end of string
	  POP	B
	  POP	H
	  JC	SETOP1
	  CPI	'"'		; ignore quote charas
	  JZ	SETOLP
	  MOV	M,A		; Store new chara
	  INX	H
	  DCR	B		; Check for string too long
	  JNZ	SETOLP		; get next chara
;
SETOP1:	  MVI	M,0		; Finished. Insert 0, insert 'RET'
	  INX	H
	  MVI	M,0C9H		; Insert RET instruction
	; Fall thru to PRESHO
;
;--------------
;
; OPTSHO
;
OPTSHO:	CALL ILPRT
	DB	'Modem Options : ',0
	CALL ILPRT
DOPTS:	DB 'OB1',0,0,0,0,0,0	; 18 charas max, default=OB1
	DB 0,0,0,0,0,0,0,0,0
	DB 0
	RET
ENDOPT:
;
;----------------
;
DUMMY:	RET	; Do nothing routine.
;
;
;
	END
