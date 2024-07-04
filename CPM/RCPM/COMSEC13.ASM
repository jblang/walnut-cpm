;			COMSEC	v1.3
; This program is similar in nature as the 'message service' for a
; SYSOP  on a BBS. The  main  point is, that it can be used in the
; command line in CP/M.  I was tired of having to re-enter the BBS
; just to  leave a  message  because the  SYSOP didn't  answer  on
; CHAT.

; Some of these  routines were  borrowed from CHAT.  The origional
; author of CHAT was: Roderick Hart...

; The caller simply enters the program  name or uses the option to
; immediately  start without instructions.  Using a ' D' after the
; name will directly enter it.

; It should also be noted that this program has  NO provisions for
; anything less than CP/M 2.x...

;###############################################
; Written by:
;(except where noted)
; Version 1.0
;		R. Kester
;		JAN 05 84

; Version 1.1
;	Minor changes, renumbered for me
; Version 1.2
;	Some more minor changes...
; Version 1.3
;	Re-did code so compatible with NUCHAT's..
;################################################

NO	EQU	0
YES	EQU	0FFH

STDCPM	EQU	YES		;Yes for 'standard' CP/M
ALTCPM	EQU	NO		;Yes for other type CP/M (TRS-80,etc)

	IF	STDCPM
BASE	EQU	0
	ENDIF

	IF	ALTCPM
BASE	EQU	4200H
	ENDIF

	ORG	BASE+100H

;Version 1.3
VER	EQU	13		;* Current version number

BDOS	EQU	BASE+5
FCB	EQU	5CH
OPEN	EQU	0FH
MAKE	EQU	16H
READ	EQU	14H
WRITE	EQU	15H
CLOSE	EQU	10H
SETDMA	EQU	1AH
USR	EQU	20H
DEFBUF	EQU	80H

CR	EQU	0DH
LF	EQU	0AH
BELL	EQU	07H
SPACE	EQU	20H
SECT	EQU	80H
DEL	EQU	7FH

ABORT	EQU	'A'-40H		;Abort program in message mode
FINIS	EQU	'C'-40H		;Quit and save file (message)
EOF	EQU	'Z'-40H		;End Of File
BACKUP	EQU	'H'-40H		;Baskspace

	JMP	START		;Bypass

; NOTE: When specifying the drive code, enter the number
; corrosponding to the drive.
; i.e.		0=current drive
;		1=dirve 'A'
;		2=drive 'B'.....etc.

; 'MEMLIM' = This allows that number (MEMLIM) of bytes to be added
; starting at BUFF.  BUFF is the area directly following this pro-
; gram where all received characters are stored, INCLUDING already
; existing messages (if any). i.e. If the value of MEMLIM were 50,
; then this program would only allow 50 bytes to be placed in mem-
; ory. It would then issue an error telling the user it is running
; low on memory and  automatically  'close up shop'.  It should be
; noted that,  even if it does enter the error condition, it still
; includes the LASTCALR information. So this number should be used
; as a reference only.

; I.E. 20,000 = 20,000 BYTE MESSAGE FILE.

;* * * * * *  USER MOD AREA * * * * * * *

;*    Message limit (see note above)	*
MEMLIM	EQU	20000

;*	Set YES for an RBBS system	*
;*        (use the LASTCALR file)	*
RBBS	EQU	YES

;*       # of characters per line	*
LIMIT	EQU	72

;*   How many repeatative characters	*
;*       before tagging an error?	*
TOMANY	EQU	LIMIT-8

;*    User area you want messages in	*
USER	EQU	10

;*  Drive for messages, put number here	*
DFDRV	EQU	1

;*       Drive with LASTCALR on it	*
CALLDR	EQU	1

;*        User area of LASTCALR		*
CALLU	EQU	0

;*    File name created for messages	*
;*         spaces ||||||||||| =11  	*
FNAME	DB DFDRV,'MESSAGE CPM'
;*         spaces ||||||||||| =11  	*

;	End of option selections	*
;****************************************

; From here on, you shouldn't need to modify anything else...

	IF	RBBS
DBUF	EQU	80H
BSIZE	EQU	80H
CALLERFCB:
	DB	CALLDR,'LASTCALR   ',0
	DS	23
	DB	0FFH
CALLERADR:DW	DBUF
CALLERSIZ:EQU	BSIZE
CALLERLEN:DW	BSIZE
CALLERPTR:DS	2
	ENDIF		;RBBS

START:
; Do the usual routine for the SP
	LXI	H,0
	DAD	SP
	SHLD	STACK
	LXI	SP,STACK

; Initialize direct CBIOS calls
	LHLD	1
	LXI	D,3
	DAD	D
	SHLD	CSTAT+1		;Con stat
	DAD	D
	SHLD	CIN+1		;Con in
	DAD	D
	SHLD	COUT+1		;Con out

; Get current user area and save it
	MVI	E,0FFH		;Code for GET
	MVI	C,USR
	CALL	BDOS		;Do it
	STA	OLDUSR		;Save it for return

;Get any potential options next
	LDA	DEFBUF+1
	ORA	A
	JZ	NNOP
	LDA	DEFBUF+2
	STA	OPT

NNOP:
	IF	RBBS
	XRA	A		;Zero A
	STA	CALLERFCB+12
	STA	CALLERFCB+32
	LXI	H,CALLERSIZ	;Get value
	SHLD	CALLERLEN
	SHLD	CALLERPTR
	MVI	E,CALLU		;Set area for LASTCALR
	MVI	C,USR
	CALL	BDOS
	LXI	D,CALLERFCB	;Point to filename
	MVI	C,OPEN
	CALL	BDOS
	CPI	YES		;Was it successful?
	JNZ	OPENOK		;Zero = No

	CALL	ILPRT
	DB BELL,CR,LF,LF
	DB 'ERROR --> LASTCALR file not found!...ABORTING'
	DB CR,LF,LF,0

	JMP	LEAVE

OPENOK:
	LXI	D,DEFBUF	;Point to default buffer
	MVI	C,SETDMA	;Make new DMA addr
	CALL	BDOS
	MVI	C,READ		;Read in file @DMA
	LXI	D,CALLERFCB
	CALL	BDOS
	ORI	0FFH		;Read OK?
	JNZ	ROK

	CALL	ILPRT
	DB BELL,CR,LF,LF
	DB 'ERROR -> Can''t read LASTCALR file!'
	DB CR,LF,LF,0
	JMP	LEAVE

ROK:
	CALL	VEIW		;Set up name
	MVI	M,'$'		;Mark end
	ENDIF		;RBBS

; Do sign-on
	CALL	ILPRT
	DB CR,LF,LF
	DB '            Computer Secretary v'
	DB VER/10+'0','.',VER MOD 10+'0'
	DB CR,LF,LF,0

; See if any requests are there
	LDA	OPT
	CPI	NO		;Any options?
	JZ	NONE		;No...
	CPI	'D'		;Direct entry?
	JZ	DIRECT		;We saw a 'D'

; Otherwise give brief instructions
NONE:
	CALL	ILPRT
	DB CR,LF
	DB 'When the  -:  prompt appears, you may  start entering'
	DB CR,LF
	DB 'your message. Hitting the RETURN key is not necessary'
	DB CR,LF
	DB 'for terminating lines. You may  ABORT  the process by'
	DB CR,LF
	DB 'entering a  ^A. Use  ^C for saving message.'
	DB CR,LF
	DB 'You may also make your life easier next time by:'
	DB CR,LF,LF
	DB 'A>progname D           <-- use a ''D'' for direct entry'
	DB CR,LF,LF
	DB 0

; First, move the FNAME into the FCB
DIRECT:
	MVI	B,12		;Number of bytes to move
	LXI	H,FCB		;The 'to' place
	LXI	D,FNAME		;The 'what to move' name
LOOP:
	LDAX	D		;Get the byte
	MOV	M,A		;Get the 'what' byte
	INX	H		;Bump the pointer
	INX	D		;Bump the 'getter'
	DCR	B		;Decrement the counter
	JNZ	LOOP		;If B<>0 then keep chuggin'
	CALL	CLRFCB		;Clear certain extensions

; And set the area for the messages...
	MVI	E,USER		;Get ready to set the
	MVI	C,USR		; user are desired
	CALL	BDOS		;Do it.
	LXI	D,FCB		;Point to the filename
	MVI	C,OPEN		;Get ready to open
	CALL	BDOS		;the file pointed by DE
	CPI	YES		;Was it successful?
	JZ	MAKEIT		;Zero = make it the first time

; Now read in the current contents...
	LXI	D,BUFF		;Point to buffer
RLOOP:
	MVI	C,SETDMA
	PUSH	D		;Save previous DMA addr.
	CALL	BDOS
	LXI	D,FCB		;Point to filename
	MVI	C,READ		;Read it in
	CALL	BDOS
	POP	D
	ORA	A		;Find out DIR code
	JNZ	FINISHED	;Zero = not finished
	LXI	H,80H		;Value of 1 sector
	DAD	D		;HL has new DMA addr.
	XCHG			;Now DE has
	JMP	RLOOP

CLRFCB:
	XRA	A		;Zero A
	STA	FCB+12
	STA	FCB+32
	RET

; We finished reading the file in to buffer
FINISHED:
	XCHG			;Get the last DMA for a double check
	SHLD	POINTR
	CALL	CLRFCB		;Clear the record info for writing
	CALL	SEARCH		;Find the EOF mark and cancel it.
				; and then reset the POINTR.
BEGIN:
	IF	RBBS
	CALL	FIRSTNM		;Get & print callers name
	ENDIF		;RBBS

	CALL	ILPRT
	DB BELL,CR,LF
	DB '      - ^A  aborts  -  ^C saves message'
	DB CR,LF,LF
	DB '-: '
	DB 0

READIT:
	CALL	TESTMEM		;Check memory limit
	CALL	CIN		;Get a byte typed by the user
	CPI	FINIS		;A ^C?
	JZ	QUIT		;Yes?, then tidy up
	CPI	ABORT		;Change their mind?
	JZ	STOP		;Yes?, then don't tidy up
	CPI	CR		;A return?
	JZ	CRLF		;Yes?, do the dirty work
	CPI	BACKUP		;A backspace?
	JZ	BACK		;Do what it requires
	CPI	DEL
	JZ	BACK
	CPI	' '		;A space?
	JC	READIT		;If it equals a value below, then loop
	CALL	PUTNMEM		;Slip it in memory
	PUSH	PSW		;Save 'A'
	MOV	C,A		;Swap it for output
	CALL	COUT		;Send it to them
	POP	B		;Get 'A' into 'B' now
	LDA	COUNT		;How far we gone on the screen?
	INR	A		;Bump it
	STA	COUNT		;Save it
	CPI	LIMIT		;Too many characters yet?
	JZ	CRLF		;Yep
	CPI	LIMIT-8		;Near the limit?
	JC	READIT		;Nope
	MOV	A,B		;Find out if we can
	CPI	' '		; help'm out and do a
	JNZ	READIT		; return for them...
CRLF:
	CALL	ILPRT		;...we could!
	DB CR,LF
	DB '-: '
	DB 0

	XRA	A		;Reset the counter
	STA	COUNT
	MVI	A,CR		;Load a RETURN
	CALL	PUTNMEM
	MVI	A,LF		;Load a LINE FEED
	CALL	PUTNMEM
	JMP	READIT		;Do it all again

BACK:
	LDA	COUNT		;Get the counter
	DCR	A		;Sub one for a backspace
	JM	READIT		;Already at 0?
	STA	COUNT		;Then save it

	CALL	ILPRT
	DB BACKUP,' ',BACKUP,0

	LHLD	POINTR		;Get pointer value
	MVI	A,L		;If it is already
	ORA	H		; a zero then
	JZ	READIT		; skip the rest
	DCX	H		;Sub one for backup
	SHLD	POINTR		;Save it
	JMP	READIT		;Go back and do some more

; Inline print routine using direct I/O
ILPRT:
	XTHL			;Swap SP/HL
ILPLP:
	MOV	C,M		;'C' = ->HL
	PUSH	H
	CALL	COUT		;Send it to the console
	POP	H
	INX	H		;Bump the char. pointer
	MOV	A,M		;'A' = ->(HL)
	ORA	A		;Is it a null?
	JNZ	ILPLP		;Nope, do some more
	XTHL			;Yep, swap HL/SP
	RET

	IF	RBBS
;Enter here to display callers name to CRT...
FIRSTNM:
	CALL	ILPRT
	DB 'Sorry I wasn''t around ',0

	LXI	H,DEFBUF	;Point to area
HAGA:
	MOV	A,M		;Get byte
	CPI	'$'		;See if end
	JZ	ALM		;Yes...
	PUSH	H		;Else, save HL
	MOV	C,A		;Get byte to send
	CALL	COUT		;Send it to CRT
	POP	H		;Get HL back
	INX	H		;Bump it
	JMP	HAGA		;Loop..

ALM:
	CALL	ILPRT
	DB '....',CR,LF,LF,0		;Send this for looks
	RET

;Enter this routine to set-up the name to be printed
;in the file, Replaces the comma with a space. Puts
;it the default buffer...
VEIW:
	LXI	H,DEFBUF	;Point to defualt buffer
DLOP:
	MOV	A,M		;Get a byte
	CPI	EOF		;End of file
	RZ			;Yes..or
	CPI	CR		; found a CR?
	RZ			;Yes...

ALOOP:
	CPI	','		;Then check for this
	JNZ	BLOP		;No...
	MVI	A,' '		;Then make it a space
BLOOP:
	MOV	M,A		;Put it in memory
BLOP:
	INX	H		;Bump pointer
	JMP	DLOP		;Loop...
	ENDIF		;RBBS

;Message for SYSOP if too many chars. in  arow.

TOMSG:	DB CR,LF,LF,'This person possibly tried to fool you!',CR,LF,'$'

;Enter here when we got too many of the same character in a row.
TOERR:
	CALL	ILPRT
	DB BELL,CR,LF,LF
	DB 'ERROR -> Too many similar characters, ABORTING!'
	DB CR,LF,LF,0

	LHLD	ORNPTR		;Get value before anything was entered
	SHLD	POINTR		;Make that the current value
	LXI	D,TOMSG		;Enter a msg. so SYSOP nows why
	CALL	PLOOP		; nothing was entered
QUIT:
	MVI	A,CR		;Put some area in for readibility
	CALL	PUTNMEM
	MVI	A,LF
	CALL	PUTNMEM
	CALL	PUTNMEM

	IF	NOT RBBS
	JMP	ALMOST
	ENDIF		;NOT RBBS

	IF	RBBS
	CALL	CALLGET		;Put name into file
	JMP	ALMOST

;Enter here to place callers name into file..
CALLGET:
	LXI	D,DEFBUF
HLOOP:
	LDAX	D		;Get byte
	CPI	'$'		;End?
	RZ			;Yes..
	PUSH	D		;Then save DE
	CALL	PUTNMEM		;Get byte=>DE put in file by (HL)
	POP	D		;Get DE back
	INX	D		;Bump it
	JMP	HLOOP		;Loop...
	ENDIF		;RBBS

; Call this routine each time we enter a byte into the buffer
; and keep track of twits...

PUTNMEM:
	STA	TEMP		;Save A for the following
	LHLD	POINTR		;Get current value
	MOV	B,A		;Save it
	MOV	M,A		;Slip in byte
	INX	H		;Bump the pointer
	SHLD	POINTR		;Save it
	LHLD	POINTR		;Get it back
	DCX	H		;Decrement it
	DCX	H		; again
	MOV	A,M		;Get byte
	CMP	B		;The same as B?
	JZ	SETNOT		;Yep..
	CPI	CR		; ?
	JZ	SETNOT		;Yep..
	CPI	LF		; ?
	JZ	SETNOT		;Yes?, do something about it
	XRA	A		;No?, then
	STA	MNYCNT		; reset count
	LDA	TEMP		;Get A back
	RET

;Enter here when we find the same character typed twice in a row.
;And exit if too many of them, and keep the caller's name.

SETNOT:
	LDA	MNYCNT		;Get count
	INR	A		;Bump it
	STA	MNYCNT		;Save new count
	CPI	TOMANY		;Too many of them?
	JZ	TOERR		;Yes?, then error exit
	LDA	TEMP		;Get A back
	RET

; Test memory limit... if we are there, then quit

TESTMEM:
	LHLD	MEMS		;The number not to exceed
	XCHG			;Swap
	LHLD	POINTR		;The number to compare to
	MOV	A,H		;Put MS part in A
	CMP	D
	RC			;Ok, if carry
	MOV	A,L		;Else do the same
	CMP	E
	RC			;Ok, if carry

;No carry so we are over exteneded...
	CALL	ILPRT		;Then print error message
	DB BELL,CR,LF,LF
	DB 'SORRY -> Ending things, running low on memory!'
	DB CR,LF
	DB 'Please try again another time...'
	DB CR,LF,LF,0

	JMP	QUIT		;Close up shop
	
MEMS:	DW	BUFF+MEMLIM	;Max. value not to exceed

; Put some sort of marking for the next message
; when being typed out.

; End of message delimmiter.
ENDING:	DB CR,LF,LF,'+ + + + + + + + + + + + + + + +',CR,LF,LF,'$'

ALMOST:
	LXI	D,ENDING	;Put the above line in the file
	CALL	PLOOP		; for readibility
	JMP	GONE

;Used elsewhere...
PLOOP:
	LDAX	D
	CPI	'$'
	RZ
	CALL	PUTNMEM
	INX	D
	JMP	PLOOP

GONE:
	MVI	A,EOF		;Get EOF mark
	CALL	PUTNMEM

; Change the user area for the message file
	MVI	E,USER
	MVI	C,USR
	CALL	BDOS
	LXI	D,BUFF		;Beginning of DMA
	PUSH	D		;Save it
WLOOP:
	POP	D		;Get previous push into DE
	PUSH	D		;Save on the stack
	MVI	C,SETDMA	;Set the DMA to
	CALL	BDOS		;the addr. in DE
	LXI	D,FCB		;Point to filename
	MVI	C,WRITE		;Write to it
	CALL	BDOS
	CPI	NO		;Successful?
	JNZ	WEXIT		;Zero = yes
	POP	H		;Get the past DMA addr.
	LXI	D,SECT		;One more sector
	DAD	D		; is added to the value
	PUSH	H		;Save the next DMA addr.
	MOV	A,H		;Get the high byte
	CMA			;1's compliment
	MOV	D,A		;Save that in D
	MOV	A,L		;Get the low byte
	CMA			;1's compliment
	MOV	E,A		;Save that in E
	INX	D		;= inverted current DMA addr.+1
	LHLD	POINTR		;Get # of bytes that were typed
	DAD	D		;Effectively -> NEW - CURRENT =
				; # of bytes left to write in HL
	MOV	A,H		;Get the MS value in A
	INR	A		;Bump it
	ANA	A		;Set any flags? (a -1?)
	JNZ	WLOOP		;No, then we have more to write.
	POP	H		;Clean the stack
	JMP	EXIT

WEXIT:
	CALL	ILPRT
	DB CR,LF,LF,BELL
	DB 'ERROR --> Can''t write file, ABORTING!'
	DB CR,LF,LF,0

	JMP	LEAVE		;Leave and do nothing

EXIT:
	LXI	D,FCB		;Point to filename
	MVI	C,CLOSE		;And close it
	CALL	BDOS
	CPI	YES		;Successful?
	JNZ	LEAVE		;Zero = No

	CALL	ILPRT
	DB CR,LF,LF,BELL
	DB 'ERROR --> Can''t close file, ABORTING!'
	DB CR,LF,LF,0

LEAVE:
	MVI	C,SETDMA	;Re-set the DMA
	LXI	D,DEFBUF	; so we don't
	CALL	BDOS		; mess up.

	LDA	OLDUSR		;Get origional
	MOV	E,A		; user area and
	MVI	C,USR		; return us to
	CALL	BDOS		; there.
	LHLD	STACK		;Get origional SP
	SPHL			; for 'soft' return
	RET

STOP:
	CALL	ILPRT
	DB CR,LF,LF
	DB '* * *  ABORTED! - Nothing saved  * * *'
	DB CR,LF,LF,0

	JMP	LEAVE

; Create the file
MAKEIT:
	CALL	ILPRT
	DB CR,LF
	DB 'Creating file...'
	DB CR,LF,LF,0

	LXI	D,FCB		;We had to create it new
	MVI	C,MAKE
	CALL	BDOS
	CPI	YES		;successful?
	LXI	H,BUFF		;If we goto BEGIN....
	SHLD	POINTR
	JNZ	BEGIN		;Zero = No

	CALL	ILPRT
	DB CR,LF,LF,BELL
	DB 'ERROR --> No directory space or trouble opening.'
	DB CR,LF,LF
	DB 'Please try again another time....'
	DB CR,LF,LF,0

	JMP	EXIT

;Search the current file and blank out the EOF mark...
SEARCH:
	LXI	D,BUFF		;Point to beginning
	LHLD	POINTR		;Get current position
SLOOP:
	LDAX	D		;Move byte into A
	CPI	EOF		;Was it the EOF?
	JZ	NULLIT		;Yep?, the zero it
	INX	D		;No?, then keep searching
	DCX	H		;Decrement the pointer
	MOV	A,H		;Find out if we have no
	ORA	L		; more positions
	JZ	NULLERR		;Just used for a double check
	JMP	SLOOP		;Else, check some more
NULLIT:
	XRA	A		;Zero A
	XCHG			;Get position in HL
	MOV	M,A		;Put a '0' there
	SHLD	POINTR		;Save the area where our new
	DCX	H		;Save for later if we
	SHLD	ORNPTR		; need it...
	RET			; buffer starts

; Enter here if we did not find an EOF mark in the available
; number of positions (double check)
NULLERR:
	CALL	ILPRT
	DB BELL,CR,LF,LF
	DB 'The validity of the file might be questioned'
	DB CR,LF
	DB 'Did NOT find the EOF, and should have!'
	DB CR,LF,LF,0
	RET

CSTAT:	JMP	$-$		;Set upon entry
CIN:	JMP	$-$		; "    "    "
COUT:	JMP	$-$		; "    "    "
COUNT:	DB	0
OPT:	DB	NO
TEMP:	DS	1
MNYCNT:	DS	1
OLDUSR:	DS	1
POINTR:	DS	2
ORNPTR:	DS	2

	DS	64		;32 level stack
STACK:
	DS	2		;Storge for incoming stack

BUFF	EQU	$		;Message buffer starts here

	END
