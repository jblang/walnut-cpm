;		NEW	CHAT	version 1.2

;	This is basically the program CHAT....PLUS!!!

; This program is similar in nature as the 'message service' for a
; SYSOP  on a BBS. The  main  point is, that it can be used in the
; command line in CP/M.  I was tired of having to re-enter the BBS
; just to  leave a  message  because the  SYSOP didn't  answer  on
; CHAT.

; It should also be noted that this program has  NO provisions for
; anything less than CP/M 2.x...

;-----------------------------------------------------------------

;See the related DOC file for more information....

;Origional version by: Roderick Hart

;Several people have made upgrades to various versions of CHAT,
;this program uses only some of them.

;Sorry, I do not have all the names to give proper credit.

;This version written by:
;(except where noted)

;Version 1.0

;		R. Kester
;		Springfield, VA.

;###############################

;Version 1.1

;	I don't know, was there? (Just in case)

;Version 1.2

;		R. Kester
;Cleaned up code and added the some of the latest upgrades for CHAT.
;These  include:  Aborting  immediately from  ethier ^Z or  ACK, and
;sending name to CRT (if SEEIT=YES).

;I don't care what you say, the YES/NO is a good idea!
NO	EQU	0
YES	EQU	0FFH

STDCPM	EQU	YES		;True if standard CP/M
ALTCPM	EQU	NO		;True if other than 'standard' (TRS-80, etc.)

;Define base of CP/M..
	IF	STDCPM
BASE	EQU	0
	ENDIF

	IF	ALTCPM
BASE	EQU	4200H
	ENDIF

	ORG	BASE+100H

;Version 1.2
VER	EQU	12		;* Version number

CONOUT	EQU	2		;Console type (character)
BDOS	EQU	BASE+5
FCB	EQU	5CH
OPEN	EQU	0FH		;Open file
MAKE	EQU	16H		;Create file
READ	EQU	14H		;Read sequentially
WRITE	EQU	15H		;Write sequentially
CLOSE	EQU	10H		;Close file
SETDMA	EQU	1AH		;Set DMA addr.
USR	EQU	20H		;Set new user area
DEFBUF	EQU	80H		;CP/M default buffer

CR	EQU	0DH
LF	EQU	0AH
BELL	EQU	07
SPACE	EQU	20H
SECT	EQU	80H

ABORT	EQU	'A'-40H		;^A, for aborting in MESSAGE mode.
BYBY	EQU	'C'-40H		;^C, for aborting in CHAT mode.
FINIS	EQU	'S'-40H		;^S, for saving data in ANY mode.
EOF	EQU	'Z'-40H		;^Z, End-Of-File mark.
TIRED	EQU	'X'-40H		;^X, for aborting PAGE mode.
BACKUP	EQU	'H'-40H		;^H, for BACKSPACE
DEL	EQU	7FH		;Delete character

	JMP	START

; NOTE:  When specifying the drive code, enter the number
; corresponding to the drive.
; i.e.		0=current drive
;		1=drive 'A'
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

;* * * * * *  USER MOD AREA   * * * * * *

;*    Message limit (see note above)	*
MEMLIM	EQU	20000 

;*  Set to your CPU clock speed in MHZ	*
CPUMHZ	EQU	5

;*	    Make for many bells		*
NOISEY	EQU	YES

;*  Delay value (fine tune max=65,535)	*
DELVAL	EQU	62000

;*	Do we use a LASTCALR file	*
RBBS	EQU	YES

;*    SYSOP acknowledge (escape key)	*
ACK	EQU	1BH

;*	 # of characters per line	*
LIMIT	EQU	72

;*	     Alert attempts		*
ALERT	EQU	6

;*   How many repetitive characters?	*
;*     - see note under 'Features'	*
TOMANY	EQU	LIMIT-8

;*   User area you want messages in	*
USER	EQU	10

;*  Drive for messages, put number here	*
DFDRV	EQU	1

;*	 Drive with LASTCALR on it	*
CALLDR	EQU	1

;*	  User area of LASTCALR		*
CALLU	EQU	0

;*   File name created for messages	*
;*         spaces ||||||||||| =11  	*
FNAME	DB DFDRV,'MESSAGE CPM'
;*         spaces ||||||||||| =11  	*

;* Set the following YES - ONLY if you	*
;* want the  LASTCALR  name sent to the	*
;* CRT, AND RBBS is YES... 		*

SEEIT	EQU	YES

;*	 End of option selections	*
;****************************************

; From here on, you shouldn't need to modify anything else...

	IF RBBS
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

	MVI	E,0FFH
	MVI	C,USR
	CALL	BDOS
	STA	OLDUSR		;Save it for return

;Get any potential options next...
	LDA	DEFBUF+1
	ORA	A
	JZ	NONE1
	LDA	DEFBUF+2
	STA	OPT

NONE1:
	IF	RBBS
	XRA	A
	STA	CALLERFCB+12
	STA	CALLERFCB+32
	LXI	H,CALLERSIZ
	SHLD	CALLERLEN
	SHLD	CALLERPTR

	MVI	E,CALLU		;Set area for LASTCALR
	MVI	C,USR
	CALL	BDOS

	LXI	D,CALLERFCB
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
	LXI	D,DEFBUF	;Make sure we have
	MVI	C,SETDMA	; the default buffer
	CALL	BDOS

	MVI	C,READ
	LXI	D,CALLERFCB
	CALL	BDOS
	ORI	0FFH
	JNZ	ROK

	CALL	ILPRT
	db bell,cr,lf,lf
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
DB '                    New Chat v'
DB VER/10+'0','.',VER MOD 10+'0'
DB CR,LF,LF,0

; If the operator wishes to see the caller's name during paging.
	IF	SEEIT AND RBBS
	LXI	D,OTMSG		;Send first part
	CALL	OLOOP		;Send bytes
	LXI	D,DEFBUF	;Point to name
	CALL	OLOOP		;Send name to CRT
	LXI	D,OMSG		;Send last part
	CALL	OLOOP		;Send bytes
	JMP	STAR

OLOOP:
	LDAX	D
	CPI	'$'
	RZ
	MOV	C,A
	INX	D
	PUSH	D
ZLOOP:
	CALL	COUT
	POP	D
	JMP	OLOOP

OTMSG:	DB CR,LF,'Please hang on $'
OMSG:	DB ', I''ll check.',CR,LF,LF,'$'
	ENDIF		;SEEIT AND RBBS

; First, move the FNAME into the FCB
STAR:
	MVI	B,12		;Number of bytes to move
	LXI	H,FCB		;The 'to' place
	LXI	D,FNAME		;The 'what to move' name
LOOP:
	LDAX	D
	MOV	M,A
	INX	H
	INX	D
	DCR	B
	JNZ	LOOP
	CALL	CLRFCB		;Clear certain extensions

; And set the area for the messages...
	MVI	E,USER
	MVI	C,USR
	CALL	BDOS

	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
	CPI	YES		;Was it successful?
	JZ	MAKEIT		;Zero = make it the first time

; Now read in the current contents...

	LXI	D,BUFF		;Point to message buffer
RLOOP:
	MVI	C,SETDMA
	PUSH	D
	CALL	BDOS
	LXI	D,FCB		;Point to name
	MVI	C,READ		;Read it in
	CALL	BDOS
	POP	D
	ORA	A		;Finished?
	JNZ	FINISHED	;Zero = not finished
	LXI	H,SECT		;Sector value
	DAD	D		;HL has new DMA addr.
	XCHG
	JMP	RLOOP

CLRFCB:
	XRA	A
	STA	FCB+12
	STA	FCB+32
	RET

; We finished reading the file into the buffer
FINISHED:
	XCHG			;Get the last DMA for a double check
	SHLD	POINTR	
	CALL	CLRFCB		;Clear the record info for writing
	CALL	SEARCH		;Find the EOF mark and cancel it.
				; and then reset the POINTR.

; See if any requests are there
MAKDON:
	LDA	OPT
	CPI	NO
	JZ	NONE
	CPI	'D'
	JZ	DIRECT
	CPI	'C'
	JZ	SYYES
	JMP	INSTRUC

SYYES:
	MVI	A,YES		;Mark for sysop
	STA	OPFLG

	CALL	ILPRT
	DB 'ch> ',0		;CHAT prompt

	JMP	READIT

INSTRUC:

; Otherwise give brief instructions
	CALL	ILPRT
	DB CR,LF
	DB 'Remote conversation utility.'
	DB CR,LF,LF
	DB 'Usage:'
	DB CR,LF,LF
	DB 'When the  program is invoked, it rings the bell at  operator''s'
	DB CR,LF
	DB 'console, signaling that  you wish to "converse" with the sysop'
	DB CR,LF
	DB 'If the operator is available, you will be signaled to go ahead'
	DB CR,LF
	DB 'If not, the message  mode is entered  and you may type in your'
	DB CR,LF
	db 'message.'
	DB CR,LF,LF,0

NONE:
	CALL	ILPRT
	DB 'Fetching operator...'
	DB CR,LF
	DB 'Use Cntrl-X to abort alert sooner.'
	DB CR,LF,LF
	DB 'Ringing and counting down... ',0

STARIT:
	CALL	ILPRT
	DB BELL,08,0		;Bell & backspace

	LHLD	DECNT		;Get count value (same as CNT)
	DCX	H
	SHLD	DECNT		;Save it again
	INX	H
	CALL	DECOUT		;Display the number (and count down)
	CALL	DELAY		;Wait some seconds
	LDA	CNT		;get attempt counter
	DCR	A		;Done with alert attempts?
	STA	CNT		;Save new count
	JNZ	STARIT

NOHERE:
	CALL	ILPRT
	DB CR
	DB 'Sorry',0

	IF	SEEIT AND RBBS
	CALL	FIRSTNM
	ENDIF		;SEEIT AND RBBS

	CALL	ILPRT
	DB ', no operator available - BUT...'
	DB CR,LF,LF,LF,0

DIRECT:
	CALL	ILPRT
	DB 'When the  -:  prompt appears, you may  start entering'
	DB CR,LF
	DB 'your message. Hitting the RETURN key is not necessary'
	DB CR,LF
	DB 'for terminating lines. You may  ABORT  the process by'
	DB CR,LF
	DB 'entering a  ^A. Use  ^S  to save message  (quitting).'
	DB CR,LF,LF
	DB 0

	JMP	FIRSTPR

DECOUT:
;Display the attempt counter value. We will count down so the caller
;knows what's happening... (enter with HL = value)

	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	B,-10
	LXI	D,-1
DECOUT2:
	DAD	B
	INX	D
	JC	DECOUT2
	LXI	B,10
	DAD	B
	XCHG
	MOV	A,H
	ORA	L
	CNZ	DECOUT
	MOV	A,E
	ADI	'0'
	CALL	TYPE
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET
TYPE:
	PUSH	H
	PUSH	B
	PUSH	D
	PUSH	PSW
	MOV	C,A
	CALL	COUT
	POP	PSW
	POP	D
	POP	B
	POP	H
	RET

DELAY:	MVI	A,CPUMHZ	;Clock speed

DELAY1:
	IF	NOISEY
	PUSH	PSW
	MVI	C,BELL
	CALL	COUT
	POP	PSW
	ENDIF			;NOISEY

	LXI	H,DELVAL	;Set at begining
	LXI	D,1
WAIT:
	PUSH	H		;Save regs. for upcoming
	PUSH	D
	PUSH	PSW
	MVI	C,06		;Direct console I/O
	MVI	E,0FFH		;Request
	CALL	BDOS
	ORA	A
	JNZ	KIO		;Something, then leave
CMBCK:
	POP	PSW		;Get regs back
	POP	D
	POP	H
	DAD	D		;Wait between bell rings
	JNC	WAIT		;Loop
	DCR	A		;Done?
	JNZ	DELAY1
	RET

KIO:
	CPI	TIRED		;User has cold feet?
	JZ	LEAVE		;Yes? then go back to CP/M
	CPI	BYBY
	JZ	LEAVE
	CPI	ACK		;Was it the right answer?
	JNZ	CMBCK		;No? then try again

;Operator is present...
	LXI	SP,STACK	;Fix stack
	MVI	A,YES
	STA	OPFLG		;Set so we know

	CALL	ILPRT
	DB bell,CR
	DB 'Operator is available',0

	IF	SEEIT AND RBBS
	CALL	FIRSTNM		;Type first name
	ENDIF			;SEEIT AND RBBS

	CALL	ILPRT
	DB ', enter CTL-C to exit CHAT.'
	DB CR,LF
	DB 'Please go ahead:'
	DB CR,LF,LF,'ch> ',0		;CHAT prompt

	JMP	READIT

	IF	SEEIT AND RBBS
FIRSTNM:
	MVI	C,' '
	CALL	COUT
	LXI	H,DEFBUF
FRST:
	MOV	A,M
	CPI	' '
	RZ
	MOV	C,A
	PUSH	H
	CALL	COUT
	POP	H
	INX	H
	JMP	FRST
	ENDIF		;SEEIT AND RBBS

FIRSTPR:
	CALL	ILPRT
	DB bell,CR,LF
	DB '      - ^A  aborts       - ^S saves message'
	DB CR,LF,LF
	DB '-: '			;Freudian message prompt
	DB 0

READIT:
	CALL	TESTMEM		;Check memory limit
	CALL	CIN		;Get a byte typed
	CPI	BYBY		;^C?
	JZ	LEAVE		;Yes
	CPI	FINIS		;^S?
	JZ	QUIT		;Yes?, then tidy up
	CPI	ABORT		;Change their mind?
	JZ	STOP		;Yes?, then don't tidy up
	CPI	CR		;A return?
	JZ	CRLF		;Yes?, do the dirty work
	CPI	BACKUP		;A backspace?
	JZ	BACK		;Then fix it
	CPI	DEL		;delete key?
	JZ	BACK		;Then fix it
	CPI	' '
	JC	READIT		;If it equals a value below, then loop
	CALL	PUTNMEM		;Slip it in memory
	PUSH	PSW
	MOV	C,A		;Swap it for output
	CALL	COUT
	POP	B
	LDA	COUNT		;How far we gone on the screen?
	INR	A
	STA	COUNT
	CPI	LIMIT		;Too many characters yet?
	JZ	CRLF
	CPI	LIMIT-8		;Near the limit?
	JC	READIT
	MOV	A,B		;Find out if we can
	CPI	' '		; help'm out and do a
	JNZ	READIT		; return for them...

CRLF:
	LDA	OPFLG
	CPI	YES		;Which prompt?
	JZ	NEWP

	CALL	ILPRT
	DB CR,LF
	DB '-: '		;MESSAGE prompt
	DB 0

	JMP	PASPR

NEWP:
	CALL	ILPRT
	DB CR,LF
	DB 'ch> '		;CHAT prompt
	DB 0

PASPR:
	XRA	A		;Reset the counter
	STA	COUNT
	MVI	A,CR
	CALL	PUTNMEM
	MVI	A,LF
	CALL	PUTNMEM
	JMP	READIT

BACK:
	LDA	COUNT
	DCR	A		;Sub one for a backspace
	JM	READIT		;Already at 0?
	STA	COUNT

	CALL	ILPRT
	DB BACKUP,' ',BACKUP,0

	LHLD	POINTR		;Get pointer value
	MVI	A,L		;If it is already
	ORA	H		; a zero then
	JZ	READIT		; skip the rest
	DCX	H		;Sub one for backup
	SHLD	POINTR
	JMP	READIT

; Inline print routine using direct I/O
ILPRT:
	XTHL
ILPLP:
	MOV	C,M
	PUSH	H
	CALL	COUT		;Send it to the console
	POP	H
	INX	H
	MOV	A,M
	ORA	A		;Is it a null?
	JNZ	ILPLP
	XTHL
	RET

;Message for SYSOP if too many characters in a row.

TOMSG:	DB CR,LF,LF,'This person possibly tried to fool you!',CR,LF,'$'

TOERR:

;Enter here when we get too many of the same character in a row.
	CALL	ILPRT
DB BELL,CR,LF,LF
DB 'ERROR -> Too many similar characters, ABORTING!'
DB CR,LF,LF,0

	LHLD	ORNPTR		;Get value before anything was entered
	SHLD	POINTR		;Make that the current value
	LXI	D,TOMSG		;Enter a message so SYSOP knows why
	CALL	PLOOP		; nothing was entered
QUIT:
	MVI	A,CR
	CALL	PUTNMEM
	MVI	A,LF
	CALL	PUTNMEM
	CALL	PUTNMEM

	IF	NOT RBBS
	JMP	ALMOST
	ENDIF		;NOT RBBS

	IF	RBBS
	CALL	CALLGET		;Put callers name there too
	JMP	ALMOST
	ENDIF

	IF	SEEIT AND RBBS
;This routine called from very beginning. Puts the name read in
;from the file, to the default buffer so we can get at it...
VEIW:
	LXI	H,DEFBUF	;Where name will go

;Set up callers name for print out, change ',' to  a space...
DLOOP:
	MOV	A,M
	CPI	EOF
	RZ
	CPI	CR
	RZ

ALOOP:
	CPI	','		;Do not print the comma
	JNZ	BLOP
	MVI	A,' '
BLOOP:
	MOV	M,A
BLOP:
	INX	H
	JMP	DLOOP
	ENDIF			;SEEIT AND RBBS

; Call this routine each time we enter a byte into the buffer
; and keep track of twits...
PUTNMEM:
	STA	TEMP
	LHLD	POINTR
	MOV	B,A
	MOV	M,A
	INX	H
	SHLD	POINTR
	LHLD	POINTR
	DCX	H
	DCX	H
	MOV	A,M
	CMP	B		;The same as B?
	JZ	SETNOT
	CPI	CR
	JZ	SETNOT
	CPI	LF
	JZ	SETNOT
	XRA	A
	STA	MNYCNT
	LDA	TEMP
	RET

;Enter here when we find the same character typed twice in a row.
;And exit if too many of them, and keep the caller's name.
SETNOT:
	LDA	MNYCNT
	INR	A
	STA	MNYCNT
	CPI	TOMANY		;Too many of them?
	JZ	TOERR		;Yes?, then error exit
	LDA	TEMP
	RET

; Test memory limit... if we are there, then quit
TESTMEM:
	LHLD	MEMS		;The number not to exceed
	XCHG
	LHLD	POINTR		;The number to compare to
	MOV	A,H		;Put MS part in A
	CMP	D
	RC
	MOV	A,L
	CMP	E
	RC

	CALL	ILPRT
DB CR,LF,LF,BELL
DB 'SORRY -> Ending things, running low on memory!'
DB CR,LF,LF
DB 'Please try again another time...'
DB CR,LF,LF,0

	JMP	QUIT
	
MEMS:	DW	BUFF+MEMLIM

; End of message delimeter.

ENDING:	DB CR,LF,LF,'+ + + + + + + + + + + + + + + + +',CR,LF,LF,'$'

ALMOST:
	LXI	D,ENDING	;Put the delimmiter in memory
	CALL	PLOOP
	JMP	GONE

;Used elsewhere...
PLOOP:
	LDAX	D
	CPI	'$'
	RZ
	CALL	PUTNMEM		;Slip byte into memory
	INX	D
	JMP	PLOOP

GONE:
	MVI	A,EOF		;Mark the End of file
	CALL	PUTNMEM

;Change the user area for the message file
	MVI	E,USER
	MVI	C,USR
	CALL	BDOS
	LXI	D,BUFF		;Beginning of DMA (Start of messages)
	PUSH	D

; Write contents to file...
WLOOP:
	POP	D
	PUSH	D
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,FCB
	MVI	C,WRITE
	CALL	BDOS
	CPI	NO		;Successful?
	JNZ	WEXIT		;Zero = yes
	POP	H
	LXI	D,SECT
	DAD	D
	PUSH	H
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
	INR	A
	ANA	A		;Set any flags? (a -1?)
	JNZ	WLOOP		;No, then we have more to write.
	POP	H		;Clean the stack
	JMP	EXIT
;
WEXIT:
	CALL	ILPRT
DB CR,LF,LF,BELL
DB 'ERROR --> Can''t write file, ABORTING!'
DB CR,LF,LF,0

	JMP	LEAVE		;Leave and do nothing

EXIT:
	LXI	D,FCB		;Point to filename
	MVI	C,CLOSE
	CALL	BDOS
	CPI	YES		;Successful?
	JNZ	LEAVE		;Zero = No

	CALL	ILPRT
DB CR,LF,LF,BELL
DB 'ERROR --> Can''t close file.......ABORTING!'
DB CR,LF,LF,0

LEAVE:
	MVI	C,SETDMA	;Re-set the DMA
	LXI	D,DEFBUF
	CALL	BDOS

	LDA	OLDUSR		;Return to origional user area
	MOV	E,A
	MVI	C,USR
	CALL	BDOS

	LHLD	STACK		;Get intro. stack
	SPHL			; for 'soft' return
	RET			;FINISHED!

STOP:
	CALL	ILPRT
DB CR,LF,LF
DB '      * * *  ABORTING! - Nothing saved  * * *'
DB CR,LF,LF,0
	JMP	LEAVE

; Create the file

MAKEIT:
	CALL	ILPRT
DB CR,LF
DB 'Creating file...'
DB CR,LF,LF,0

	LXI	D,FCB		;We had to create it
	MVI	C,MAKE
	CALL	BDOS
	CPI	YES		;successful?
	LXI	H,BUFF
	SHLD	POINTR
	SHLD	ORNPTR
	JZ	MERR		;Zero = No
	CALL	CLRFCB		;Clear extensions
	JMP	MAKDON

MERR:
	CALL	ILPRT
DB BELL,CR,LF,LF
DB 'ERROR --> No directory space or trouble opening.'
DB CR,LF,LF
DB '...Please try again another time.'
DB CR,LF,LF,0
	JMP	EXIT

	IF	RBBS
; Since the last caller's  name is in the default  buffer,
; get it from there and do not 'type' the name again to the 
; CRT... (used for inserting name into file)
CALLGET:
	LXI	D,DEFBUF
HLOOP:
	LDAX	D
	CPI	'$'
	RZ
	PUSH	D
	CALL	PUTNMEM
	POP	D
	INX	D
	JMP	HLOOP
	ENDIF		;RBBS

;Search the current file and blank out the EOF mark...
SEARCH:
	LXI	D,BUFF		;Point to beginning
	LHLD	POINTR		;Get current position
SLOOP:
	LDAX	D		;Move byte into A
	CPI	EOF		;Was it the EOF?
	JZ	NULLIT		;Yep?, then zero it
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
	SHLD	POINTR		;Save the areas
	SHLD	ORNPTR
	RET

; Enter here if we did not find an EOF mark in the available
; number of positions (double check)
NULLERR:
	CALL	ILPRT
DB BELL,CR,LF,LF
DB 'The validity of the file might be questioned!'
DB CR,LF
DB 'Did NOT find  the EOF mark, and should  have!'
DB CR,LF,LF,0
	RET

CSTAT:	JMP	$-$		;Set upon entry
CIN:	JMP	$-$		; "    "    "
COUT:	JMP	$-$		; "    "    "

CNT:	DB	ALERT
OPFLG:	DB	NO
VWFLG:	DB	NO
OPT:	DB	NO
COUNT:	DB	0

DECNT:	DW	ALERT

POINTR:	DS	2
ORNPTR:	DS	2
TEMP:	DS	1
MNYCNT:	DS	1
OLDUSR:	DS	1
DLSPD:	DS	1

	DS	64
STACK:
	DS	2		;storge for stack

BUFF	EQU	$		;Message buffer starts here

	END
