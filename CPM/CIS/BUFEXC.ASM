;	*** CompuServe Information Service Executive for CP/M (R)
;		(CP/M is a trademark of Digital Research)
;	Copyright (C) 1980, 1981 CompuServe Incorporated
;	Version 2.3
;	Written by:
;			Russ Ranshaw


false:	equ	0
true:	equ	not false

usebios:	equ	false		; true to use direct BIOS calls for
					; console output
			;*** Note: If you choose to use BDOS call for console
			; write, AND have "shoxfr" true, you may not be able
			; to do file transfers if your communication channel
			; is operating at greater than 300 baud!
shoxfr:	equ	true	; true to show data during file transfer
sholcc:	equ	09h	; lowest displayable control character for console
shohcc:	equ	0dh	; highest "" (used in PRODSP to map ctl characters)
paglen:	equ	60	; printer page length

other:	equ	false	; true if the computer is NOT one of the special ones
hz89:	equ	false	; true if the computer is a Heath/Zenith 88, 89, 8
hz19:	equ	false		; Console is a Heath/Zenith -19
pmmi	equ	true	; true if PMMI modem board

	if	other
BBASE:	EQU	0000H	; "PAGE 0" ADDRESS
CTL	EQU	03H	; CONTROL PORT
SIO	EQU	01H	; SIO PORT
SIOIR	EQU	40H	; SIO PORT DATA INPUT READY FLAG
SIOTR	EQU	80H	; SIO PORT TRANSMITTER READY FLAG
hitrue:	equ	false	; SIO flags are "hi" (1) when true
	endif

	if	hz89
bbase:	equ	4200h	; "Page 0" Address - Set to 0 if you have 0 based CP/M
ctl:	equ	0ddh	; Line Control Register 
sio:	equ	0d8h	; Receive/Transmit Data Register
sioir:	equ	01h	; Receive Data Ready flag
siotr:	equ	20h	; Transmitter Buffer Ready flag
hitrue:	equ	true
	endif

	if	pmmi
bbase:	equ	0h	; "Page 0" address
basprt:	equ	0c0h	; base i/o port address for pmmi board
ctl:	equ	basprt	; primary control port
sio:	equ	basprt+1	; serial data port
sioir:	equ	02h	; data input ready flag
siotr:	equ	01h	; transmitter ready flag
hitrue:	equ	true	; flags are high when true
	endif

; SPECIAL CHARACTERS FOR DATA TRANSMISSION PROTOCOL

SOH:	EQU	01H	; START OF TEXT
ETX:	EQU	03H	; END OF TEXT
EOT:	EQU	04H	; END OF TRANSMISSION
ENQ:	EQU	05H	; ^E, USED FOR PMMI EXIT W/O DISCONNECT
SI:	EQU	0FH	; <SI> = SHIFT INTO PROTOCOL MODE
SO:	EQU	0EH	; <SO> = SHIFT OUT OF PROTOCOL MODE]
			; PROTOCOL MODE IMPLIES THAT <ESC> SEQUENCES
			; ARE NOT SENT TO CONSOLE BUT ARE USED TO CONTROL
			; THE UP/DOWN LOAD PROTOCOL
DC1:	EQU	11H	; <DC1> CONTROL-Q: RESUME TRANSMISSION
DC2:	EQU	12H	; <DC2> CONTROL-R: PRINTER ON
DC3:	EQU	13H	; <DC3> CONTROL-S: STOP TRANSMISSION
DC4:	EQU	14H	; <DC4> CONTROL-T: PRINTER OFF
KNAK:	EQU	15H	; <NAK>
DLE:	EQU	10H	; <DLE> (TRANSPARACY FLAG)
ESC:	EQU	1BH	; ESCAPE
EOF:	EQU	1AH	; ^Z (CP/M END OF FILE)
CR:	EQU	0DH	; <RET>
LF:	EQU	0AH	; <LF>
FF:	EQU	0CH	; <FF>
MON:	EQU	18H	; ^X (RETURN TO CP/M) (& DISCONNECT PMMI)

; CP/M EQUATES

BDOS:	EQU	BBASE+0005H	; MAIN ENTRY POINT FOR CP/M
TFCB:	EQU	BBASE+005CH	; DEFAULT FILE CONTROL BLOCK
TBUFF:	EQU	BBASE+0080H	; DEFAULT FILE BUFFER
TBASE:	EQU	BBASE+0100H	; TRANSIENT BASE

; DEFINE OFFSETS INTO FILE CONTROL BLOCK (FCB)

FCB$ET:	EQU	0	; ENTRY TYPE
FCB$FN:	EQU	1	; FILE NAME (8 BYTES)
FCB$FT:	EQU	9	; FILE TYPE (3 BYTES)
FCB$RC:	EQU	15	; RECORD COUNT (CURRENT EXTENT)
FCB$DM:	EQU	16	; DISK MAP
FCB$NR:	EQU	32	; NEXT RECORD NUMBER TO READ OR WRITE

; 	BDOS FUNCTIONS:

FN$SR:	EQU	0	; SYSTEM RESET
FN$RC:	EQU	1	; READ CONSOLE
FN$WC:	EQU	2	; WRITE CONSOLE
FN$RR:	EQU	3	; READ READER
FN$WP:	EQU	4	; WRITE PUNCH
FN$WL:	EQU	5	; WRITE LIST
FN$IS:	EQU	7	; INTERROGATE I/O STATUS
FN$AS:	EQU	8	; ALTER I/O STATUS
FN$PCB:	EQU	9	; PRINT CONSOLE BUFFER
FN$RCB:	EQU	10	; READ CONSOLE BUFFER
FN$CCS:	EQU	11	; CHECK CONSOLE STATUS
FN$LDH:	EQU	12	; LIFT DISK HEAD
FN$RDS:	EQU	13	; RESET DISK SYSTEM
FN$SD:	EQU	14	; SELECT DISK
FN$OPN:	EQU	15	; OPEN FILE
FN$CLS:	EQU	16	; CLOSE FILE
FN$SF:	EQU	17	; SEARCH FIRST
FN$SN:	EQU	18	; SEARCH NEXT
FN$DEL:	EQU	19	; DELETE FILE
FN$RDR:	EQU	20	; READ DISK RECORD
FN$WDR:	EQU	21	; WRITE DISK RECORD
FN$CRE:	EQU	22	; CREATE FILE
FN$REN:	EQU	23	; RENAME FILE
FN$IL:	EQU	24	; INTERROGATE LOGIN
FN$ID:	EQU	25	; INTERROGATE DISK
FN$SDA:	EQU	26	; SET DMA ADDRESS
FN$IA:	EQU	27	; INTERROGATE ALLOCATION

	ORG	TBASE

START:	JMP	START0		; NORMAL START
INISIO:	JMP	SIOINI		; INITIALIZE MODEM UART
GETSIO:	JMP	SIOGET		; GET CHAR FROM MODEM UART
PUTSIO:	JMP	SIOPUT		; PUT A CHAR TO MODEM UART

; <ESC><I> response for this executive:

	if	other
SYSID:	DB	'#CPMTarbell,CC,HC,PA,PL',CR,00
	endif

	if	hz89
sysid:	db	'#CPMHeath/Zenith,CC,HC,PA,PL',cr,00
	endif

	if	pmmi
sysid:	db	'#CPMPMMI,CC,HC,PA,PL',CR,00
	endif

; CC = Cursor Control
;   Implies following cursor controls:
;	<ESC><A>	cursor up
;	<ESC><B>	cursor down
;	<ESC><C>	cursor right
;	<ESC><D>	cursor left
;	<ESC><H>	cursor home (line 1, column 1)
;	<ESC><J>	erase to end of screen
;	<ESC><K>	erase to end of line
;	<ESC><j>	erase screen and home cursor (also <FF>)
;	<ESC><Y><L+31><C+31> position cursor to line L column C
; HC = Hard Copy
;   Implies following:
;	<DC2> (^R, 022 octal, 12 hex) enable printer; subsequent data
;				      will be copied to local printer
;	<DC4> (^T, 024 octal, 14 hex) disable printer
;	<ESC><e>	disable terminal display
;	<ESC><f>	enable terminal display
; PA = A Protocol
;    Implies file transfer capability using the CompuServe A protocol
; PL = Load Protocol
;    Implies ability to load code segments under the CompuServe L protocol

banner:	db	'CompuServe CP/M (R) Executive Version 2.3',cr,lf
	if	other
	db	'**** Tarbell/Z-80 ****',cr,lf,0
	endif

	if	hz89
	db	'**** Heath/Zenith ****',cr,lf,0
	endif

	if	pmmi
	db	'**** PMMI Modem ****',cr,lf
	db	'^E exit WITHOUT disconnect, ^X exit WITH disconnect'
	db	cr,lf,lf,'$'
	endif

	DB	'Copyright (C) 1980, 1981 CompuServe Incorporated',CR,LF
	DB	CR,LF,'$'

START0:	LXI	SP,STACK		; SET UP OUR OWN STACK
	MVI	C,FN$ID		; GET CURRENT CP/M DISK DRIVE
	CALL	BDOS
	STA	CPMDEF
	LHLD	BBASE+1		; GET START OF BIOS
	XCHG
	LXI	H,3		; OFFSET TO CONSOLE CHECK
	DAD	D
	SHLD	TRMGET+1	; STORE ADDRESS
	LXI	H,6		; OFFSET TO CONSOLE READ
	DAD	D
	SHLD	TERMRD+1
	if	usebios
	LXI	H,9		; OFFSET TO CONSOLE WRITE
	DAD	D
	SHLD	TERMWR+1
	endif
	LXI	H,2AH		; OFFSET TO LIST STATUS
	DAD	D		; MUST BE IMPLEMENTED IN BIOS
	SHLD	LSTST+1		; FOR PRINT BUFFERING TO WORK

	XRA	A		; DISABLE PRINTER OUTPUT
	STA	PRTFLG
	STA	SIFLAG		; NO <SI> SEEN
	if	shoxfr
	sta	shoflg		; Don't come up in "show transfer"
	endif			; mode!
	CALL	INISIO		; INITIALIZE MODEM UART
	LXI	D,BANNER	; ANNOUNCE OURSELVES
	MVI	C,FN$PCB
	CALL	BDOS

; TERMINAL EMULATOR LOOP

TERM:	CALL	TRMGET
	JZ	TSTSIN
	CPI	MON		; IF USER WANTS TO RETURN TO CP/M
	
	IF	NOT PMMI
	JZ	BBASE		; THEN DO IT!
	ENDIF	;NOT PMMI

	IF	PMMI
	JZ	DISCON		; DISCONNECT MODEM
	ENDIF	;PMMI

	CPI	ENQ		; IF ^E
	JZ	BBASE		; THEN JUST EXIT
	CPI	DC2		; IF ^R
	JZ	PRTON		; THEN TURN PRINTER ON
	CPI	DC4		; IF ^T
	JZ	PRTOFF		; THEN TURN PRINTER OFF
	CALL	PUTSIO		; ELSE PUT CHAR OUT TO SIO

TSTSIN:	CALL	GETSIN		; ELSE GET A CHAR FROM SIO
	JZ	TSTPRT
	CPI	DLE		; IF <DLE>
	JZ	ISDLE		; THEN PROCESS <DLE>
	CPI	SI		; IF <SI>
	JZ	ISSI		; THEN PROCESS <SI>
	CPI	SO		; IF <SO>
	JZ	ISSO		; THEN PROCESS <SO>
	CPI	ESC		; IF <ESC>
	JZ	ISESC		; THEN GO PROCESS ESCAPE SEQUENCE
	CPI	DC2		; IF ^R
	JZ	PRTON		; THEN TURN PRINTER ON
	CPI	DC4		; ELSE IF ^T
	JZ	PRTOFF		; THEN TURN PRINTER OFF

	IF	HZ19		; IF RUNNING A H/Z-19 CONSOL
	CPI	FF		; THEN IF CHAR IS <FF>
	JZ	FFHZ19		; THEN MAP IT TO <ESC><E>
	ENDIF

NOTSIM:	CALL	TERDSP		; DISPLAY/PRINT CHARACTER
TSTPRT:
LSTST:	CALL	0000		; MODIFIED TO LIST STATUS
	ORA	A
	JZ	TERM		; IF PRINTER IS BUSY
				; THEN CONTINUE TO SERVICE THE
				; KEYBOARD & MODEM AT HIGH POLLING RATE
	LHLD	HEAD		; GET HEAD POINTER
	XCHG
	LHLD	TAIL		; AND TAIL POINTER
	CALL	DEHLCMP		; SEE IF THEY ARE EQUAL
	JZ	TERM		; IF SO, BUFFER IS EMPTY, SO EXIT
	PUSH	H		; SAVE TAIL POINTER
	MOV	A,M		; GET THE CHAR
	ANI	7FH		; STRIP PARITY
	LXI	H,LINCNT	; POINT TO LINE COUNTER
	CPI	FF		; IF FF
	JZ	NEWPAGE		; RESET LINE COUNTER
	CPI	LF		; IF LF
	JNZ	OUTP		; DECREMENT LINE COUNTER
	DCR	M		; IF ROOM LEFT ON PAGE
	JNZ	OUTP		; OUTPUT THE LF
NEWPAGE	MVI	M,PAGLEN	; ELSE A FF
	MVI	A,FF
OUTP:	MOV	E,A
	MVI	C,FN$WL		; CHAR TO LIST DEVICE
	CALL	BDOS
	POP	H		; RESTORE TAIL PTR
	INX	H
	LDA	BDOS+2		; CHECK FOR MEMORY TOP
	DCR	A
	CMP	H
	JNC	OUTP1
	LXI	H,PRTBUF	; WRAPAROUND
OUTP1:	SHLD	TAIL		; UPDATE TAIL PTR
	JMP	TERM

DEHLCMP:	; TEST (DE)-(HL) COMPARISON
	MOV	A,D
	CMP	H
	RNZ
	MOV	A,E
	CMP	L
	RET


; GET A CHARACTER FROM LOCAL TERMINAL
; RETURN Z FLAG IF LOCAL NOT READY

TRMGET:	CALL	0000H		; **** MODIFIED ADDRESS!!!
	ANI	01
	RZ			; RETURN IF NO LOCAL INPUT
TERMRD:	CALL	0000H		; **** MODIFIED ADDRESS!!!
	ANI	7FH		; RETURN WITH PARITY STRIPPED
	RET

; HERE IF <DC2> (^R) RECEIVED FROM HOST OR CONSOLE

PRTON:	MVI	A,0FFH		; SET PRINTER FLAG
	STA	PRTFLG
	JMP	TERM

; HERE IF <DC4> (^T) RECEIVED FROM HOST OR CONSOLE

PRTOFF:	XRA	A		; CLEAR PRINTER FLAG
	STA	PRTFLG
	JMP	TERM

; HERE IF <DLE> RECEIVED FROM HOST

ISDLE:	CALL	GETSIX		; GET CHARACTER FOLLOWING <DLE>
	CALL	TERDSP		; DISPLAY IT ON CONSOLE/PRINTER
	JMP	TERM

ISSO:	XRA	A	; <SO> DISABLES PROTOCOL MODE
	if	shoxfr
	sta	shoflg
	endif
	LXI	SP,STACK	; RESTORE STACK INCASE OF ABORT
ISSI:	STA	SIFLAG	; <SI> ENABLES PROTOCOL MODE
	JMP	TERM

; HERE ON <ESC> 

ISESC:	LDA	SIFLAG	; IF <SI> NOT RECEIVED
	ORA	A
	MVI	A,ESC

	IF	NOT HZ19
	JZ	NOTSIM	; THEN JUST DISPLAY IT
	ENDIF

	IF	HZ19
	JZ	CK1061		; THEN CHECK FOR SPECIAL MAPPINGS
	ENDIF

ISESCN:	CALL	GETSIX	; ELSE GET CHARACTER FROLLOWING <ESC>
	CPI	'I'	; IF <ESC><I>
	JNZ	ESC0	; THEN
	LXI	H,SYSID		; SEND THE ID STRING TO HOST

SNDID:	MOV	A,M		; GET NEXT ID BYTE
	ORA	A		; IF NULL
	JZ	TERM		; THEN FINISHED
	CALL	PUTSIO		; ELSE SEND TO HOST
	INX	H
	JMP	SNDID


	IF	HZ19		; IF WE HAVE A H/Z-19 AS CONSOLE
CK1061:	CALL	GETSIX		; GET CHAR FOLLOWING <ESC>
	CPI	'j'		; <ESC><j> = <ESC><E>
	JNZ	NT1061
FFHZ19:	MVI	A,'E'
NT1061:	PUSH	PSW
	MVI	A,ESC
	CALL	TERDSP
	POP	PSW
	JMP	NOTSIM
	ENDIF			; H/Z-19 MAPPING

ESC0:	CPI	'L'	; IF <ESC><L>
	JNZ	ESC1	; THEN
	MVI	E,0	; 	PERFORM SYSTEM LOAD FUNCTION
	CALL	GETCKS	; GET BYTE COUNT
	MOV	B,A
	CALL	GETCKS	; GET LOW ADDRESS BYTE
	MOV	L,A
	CALL	GETCKS
	MOV	H,A	; AND HIGH-ORDER

ESCL0:	CALL	GETCKS	; GET NEXT DATA BYTE
	MOV	M,A	; SAVE IT
	INX	H	; BUMP MEMORY ADDRESS
	DCR	B	; COUNT BYTES RECEIVED
	JNZ	ESCL0	; & LOOOP TILL ZERO
	MOV	C,E	; SAVE CHECKSUM
	CALL	GETCKS	; GET NEXT BYTE
	CMP	C	; IF MATCH
	MVI	A,'.'	; THEN SEND .
	JZ	ESCL1	; ELSE
	MVI	A,'/'	;	SEND /
ESCL1:	CALL	PUTSIO
	if	not shoxfr
	call	viomrk		; display protocol mark
	endif
	JMP	TERM

	if	not shoxfr
viomrk:
	push	psw
	mvi	a,cr
	call	viodsp
	mvi	a,lf
	call	viodsp
	mvi	a,32
	sta	xfrctr
	pop	psw
	cpi	'.'
	cnz	viodsp
	ret

ctxfr:	push	h
	push	psw
	lxi	h,xfrctr	; decrement count of xfr'd characters
	dcr	m
	jnz	ctxfr0
	mvi	m,32
	mvi	a,'+'		; display '+' every 32 bytes
	call	viodsp
ctxfr0:	pop	psw
	pop	h
	ret
	endif


ESC1:	CPI	'A'	; IF <ESC><A>
	JNZ	TERM	; THEN

; Initialize for data transmission using the CompuServe A-protocol
; The protocol begins with the following being sent from the host:
;	<ESC><A><SOH><U | D><A | B><FILESPEC><ETX><CKSUM>
; where:
;	U = upload, D = download
;	A = ASCII (file ends in 1Ah), B = binary
;	FILESPEC = standard CP/M file specification, including optional drive
;	CKSUM = checksum for the record

	MVI	A,'0'		; INIT RECORD NUMBER
	STA	APNXT
	CALL	APRCVX		; GET COMMAND LINE FROM HOST
	LXI	H,APBUF+2	; POINT TO FILE SPEC FROM USER
	LXI	D,TFCB		; POINT TO FILE CONTROL BLOCK
	MOV	B,M		; GET POSSIBLE DISK DRIVE NAME
	INX	H		; IF : NEXT
	MOV	A,M
	CPI	':'
	JNZ	NOCOL		; THEN
	INX	H		; SKIP THE COLON
	MVI	A,7		; MASK OFF DRIVE NUMBER
	ANA	B
	JMP	FIRSTB

NOCOL:	DCX	H		; POINT BACK TO FIRST FILE BYTE
	XRA	A		; USE DEFAULT DRIVE NUMBER
FIRSTB:	STAX	D		; STORE DRIVE NUMBER
	INX	D		; POINT TO FIRST FILE NAME BYTE
	MVI	B,8		; MAX LENGTH OF NAME
	CALL	NAAME		; GET FILE NAME
	MOV	A,M		; GET NEXT BYTE
	CPI	'.'		; IF . PRESENT
	JNZ	EXT		; THEN
	INX	H		; SKIP OVER IT
EXT:	MVI	B,3		; LENGTH OF EXTENSION
	CALL	NAAME		; GET EXTENSION
	XRA	A		; ZERO FILE EXTENT
	STAX	D
	LDA	TFCB		; SELECT THE DISK
	ORA	A		; IF 0 THEN USE DEFAULT DISK
	JZ	NODISK
	SUI	1		; MAP A INTO 0, B INTO 1, ETC.
	MOV	E,A
	MVI	D,0
	MVI	C,FN$SD
	CALL	BDOS

NODISK:
	lda	apbuf+1		; store transfer type
	sta	xfrtyp
	LDA	APBUF		; CHECK DIRECTION
	CPI	'D'		; IF DOWN LOAD
	JNZ	CHKUPL		; THEN
	lxi	d,dnload
	mvi	c,fn$pcb
	call	bdos
	MVI	C,FN$OPN	; IF THE FILE EXISTS
	CALL	DSKOP
	CPI	0FFH
	JZ	DLOKAY		; THEN
	LXI	D,DLBOMB	;	TELL THE USER ABOUT IT
	MVI	C,FN$PCB
	CALL	BDOS
	MVI	C,FN$RC		; GET USER'S RESPONSE
	CALL	BDOS
	ani	7fh
	PUSH	PSW
	MVI	A,CR
	CALL	VIODSP
	MVI	A,LF
	CALL	VIODSP
	POP	PSW
	CPI	'Y'		; IF NOT 'Y'
	JZ	DLDEL
	CPI	'y'
	JNZ	ABORT		; THEN ABORT THE DOWNLOAD ATTEMPT
DLDEL:	MVI	C,FN$DEL	; ELSE DELETE THE FILE
	CALL	DSKOP
DLOKAY:	CALL	OPNOUT		; OPEN FOR OUTPUT
	if	shoxfr
	mvi	a,0ffh
	sta	shoflg
	endif

; THE FOLLOWING LOOP DOES THE DOWNLOAD FUNCTION

DL0:	CALL	APRCV		; GET NEXT LINE OF DATA
	JNZ	DLEOT		; HANDLE END OF TRANSMISSION
	LXI	H,APBUF		; POINT TO BUFFER
DL1:	MOV	A,M		; GET NEXT BYTE
	INX	H		; POINT TO NEXT BYTE
	CALL	PUTBYT		; PUT IT INTO OUTPUT BUFFER
	DCR	B		; COUNT THE BYTE
	JNZ	DL1
	JMP	DL0		; GET NEXT RECORD FROM HOST

; HERE WHEN THE HOST'S <EOT> MESSAGE HAS BEEN RECEIVED

DLEOT:
	lda	xfrtyp		; if binary transfer
	cpi	'B'
	jz	dleotb		; then don't insert ^Z
	MVI	A,EOF		; PUT ^Z (END OF FILE MARK)
	CALL	PUTBYT
dleotb:	MVI	C,FN$WDR
	CALL	DSKOP
DLEOT0:	MVI	C,FN$CLS
	CALL	DSKOP
	CALL	RSTDEF
	MVI	A,'.'		; TELL HOST WE GOT IT
	CALL	PUTSIO
	if	not shoxfr
	call	viomrk
	endif
	if	shoxfr
	xra	a
	sta	shoflg
	endif
	JMP	TERM		; BACK TO TERMINAL MODE

; HERE IF NOT A DOWN LOAD - BETTER BE UP LOAD!

CHKUPL:	CPI	'U'
	JNZ	ABORT		; SEND NAK TO HOST IF NOT .
	lxi	d,upload
	mvi	c,fn$pcb
	call	bdos
	CALL	OPNINP		; OPEN THE FILE FOR INPUT
	MVI	A,'.'		; TELL HOST WE'RE READY TO SEND DATA
	CALL	PUTSIO
	if	not shoxfr
	call	viomrk
	endif

; THE UPLOAD FUNCTION IS DONE IN THE FOLLOWING LOOP:

	CALL GETSIX		; GET HOST'S PROMPT
	CPI	'.'		; ABORT IF NOT '.'
	JNZ	ABORT
	if	shoxfr
	mvi	a,0ffh
	sta	shoflg
	endif

UPL1:	MVI	B,0		; INIT COUNT
	LXI	H,APBUF
UPL2:	CALL	GETBYT		; GET DATA FROM FILE
	jp	upl3		; jump if <EOF> occured
	MOV	M,A		; THEN PUT INTO BUFFER
	INX	H		; BUMP POINTER
	INR	B		; AND BYTE COUNT
	JNZ	UPL2		; GET NEXT BYTE IF BUFFER NOT FILLED
UPL4:	MOV	A,B		; SAVE COUNT
	STA	APLEN
	CALL	APSND		; SEND THE DATA
	JMP 	UPL1		; GO DO NEXT LINE

UPL3:	MOV	A,B		; WRITE FINAL DATA BLOCK IF THERE IS ONE
	STA	APLEN
	ORA	A
	CNZ	APSND
	MVI	A,0FFH		; SEND <EOT> MESSAGE WITHOUT MASKING
	LXI	H,EOTMSG
	CALL	APSND0
	CALL	RSTDEF		; RESTORE CP/M'S DEFAULT DISK DRIVE
	if	shoxfr
	xra	a
	sta	shoflg
	endif
	JMP	TERM		; RETURN TO TERMINAL MODE

EOTMSG:	DB	1,EOT

;***

; ROUTINE TO INTERFACE TO CP/M'S CONSOLE OUTPUT DRIVER

viodsp:	push	b	; save register
	push	d
	push	h
	push	psw
	if	usebios
	mov	c,a
TERMWR:	CALL	0000H	; ***** MODIFIED TO CONOT IN BIOS
	endif
	if	not usebios
	mov	e,a		; call BDOS to write char on console
	mvi	c,fn$wc
	call	bdos
	endif
	pop	psw
	pop	h
	pop	d
	pop	b
	RET

; ROUTINE TO DISPLAY C(A) ON CP/M CONSOLE AND PRINTER IF NECESSARY

TERDSP:	PUSH	PSW		; SAVE C(A)
	CALL	VIODSP		; DISPLAY ON CONSOLE
	POP	PSW		; GET CHARACTER BACK
	MOV	E,A		; SAVE CHARACTER
	LDA	PRTFLG		; IF ^R RECEIVED
	ORA	A
	RZ			; THEN
; STORE THE CHAR IN THE PRINTER BUFFER
	LHLD	HEAD		; GET BUFFER PTR
	MOV	M,E		; STORE THE CHAR
	INX	H		; BUMP PTR
	LDA	BDOS+2		; CHECK FOR TOP OF MEMORY
	DCR	A
	CMP	H
	JNZ	TERDS1		; IF REACHED, WRAPAROUND
	LXI	H,PRTBUF
TERDS1:	SHLD	HEAD		; UPDATE PTR
	RET

; ROUTINE TO OPEN A FILE FOR OUTPUT

OPNOUT:	MVI	C,FN$CRE	; CREATE FILE
	CALL	DSKOP	; CALL CP/M
	CPI	0FFH	; IF OKAY
	JZ	ERRCRE		; ERROR DURING CREATE (DIRECTOR FULL?)
	XRA	A	; CLEAR NEXT RECORD COUNT
	STA	TFCB+FCB$NR
	STA	IBP	; INIT BUFFER POINTER
	RET

; ROUTINE TO OPEN FILE FOR INPUT

OPNINP:	MVI	C,FN$OPN
	CALL	DSKOP
	CPI	0FFH		; IF FILE NOT FOUND
	JZ	ERROPN		; THEN ERROR MESSAGE TIME!
	XRA	A
	STA	TFCB+FCB$NR	; INIT TO FIRST RECORD
	MVI	A,80H		; "EMPTY BUFFER"
	STA	IBP
	RET


; ROUTINE TO PUT C(A) INTO DISK BUFFER

PUTBYT:	PUSH	B	; SAVE REGS
	PUSH	D
	PUSH	H
	PUSH	PSW	; SAVE BYTE
	LDA	IBP	; IF BUFFER IS FULL
	CPI	80H
	JNZ	PUT0	; THEN
	MVI	C,FN$WDR
	CALL	DSKOP
	ORA	A
	JNZ	ERRWDR		; WRITE ERROR???
	XRA	A	; INIT IBP TO 0

PUT0:	MOV	E,A	; SAVE CUR BYTE POSITION
	MVI	D,0
	INR	A	; BUMP POINTER
	STA	IBP
	LXI	H,TBUFF	; POINT TO BUFFER
	DAD	D	; NOW POINT TO BYTE
	POP	PSW	; GET BYTE
	MOV	M,A	; STORE BYTE
	POP	H	; RESTORE REGS
	POP	D
	POP	B
	RET

; ROUTINE TO GET NEXT BYTE FROM A DISK RECORD

GETBYT:	PUSH	B	; SAVE REGS
	PUSH	D
	PUSH	H
	mvi	b,0	; assume not <EOF>
	LDA	IBP	; IF BUFFER IS EMPTY
	CPI	80H
	JNZ	GET0
	MVI	C,FN$RDR
	CALL	DSKOP
	mov	b,a		; save return code (0 implies okay)
	XRA	A	; RESET BYTE POINTER
GET0:	MOV	E,A	; SAVE BYTE POS
	MVI	D,0
	INR	A	; BUMP BYTE POS
	STA	IBP
	LXI	H,TBUFF
	DAD	D
	lda	xfrtyp		; if binary transfer
	cpi	'B'
	jz	gtbtbn		; then don't check for ^Z
	MOV	A,M	; GET THE BYTE
	cpi	eof	; if ^Z
	jnz	gtrstr	; then
	mvi	b,1	; we will exit with N cleared
gtrstr:	dcr	b	; set N if NOT eof
	POP	H	; RESTORE REGS
	POP	D
	POP	B
	RET

gtbtbn:	mov	a,m	; get binary byte
	jmp	gtrstr	; set N flag and exit

; FATAL CP/M ERROR CONDITIONS PRINT A LOCAL MESSAGE 
; THEN SEND A <NAK> TO HOST

ERRCRE:	LXI	D,CREMSG
	JMP	DFATAL


ERROPN:	LXI	D,OPNMSG
	JMP	DFATAL


ERRWDR:	LXI	D,WDRMSG
	JMP	DFATAL



DFATAL:
FATAL:	MVI	C,FN$PCB		; WRITE ERROR MESSAGE
	CALL	BDOS

ABORT:
	lxi	d,abload	; tell user we are aborting
	mvi	c,fn$pcb
	call	bdos
	MVI	C,FN$CLS
	CALL	DSKOP
	CALL	RSTDEF		; RESTORE DEFAULD DISK
	MVI	A,KNAK
	CALL	PUTSIO			; TELL HOST WE HAVE BOMBED
	JMP	ISSO			; DISABLE PROTOCOL MODE

; HERE TO DO A CP/M DISK OPERATION; CALLED WITH DESIRED FUNCTION CODE IN C

DSKOP:	LXI	D,TFCB
	CALL	BDOS
	PUSH	PSW		; SAVE RETURN CODE
	XRA	A		; OUTPUT A NULL TO CONSOLE
	CALL	VIODSP		; TO FLUSH DISK BUFFER
	POP	PSW		; RESTORE DSK RETURN CODE
	RET

; ROUTINE TO RESTORE CP/M'S DEFAULT DISK DRIVE

RSTDEF:	LDA	CPMDEF
	MOV	E,A
	MVI	D,0
	MVI	C,FN$SD
	CALL	BDOS
	RET

; ROUTINE TO EXTRACT FILE NAME AND EXTENSION

NAAME:	MOV	A,M	; GET NEXT BYTE
	CPI	CR	; <RET> ENDS NAME
	JZ	FILL	; FILL IF END OF STRING
	CPI	'.'	; IF EXTENSION
	JZ	FILL	; THEN FILL OUT WITH SPACES
	INX	H	; SKIP THIS BYTE
	CPI	60H	; LOWER CASE A
	JC	NAME1	; JUMP IF NOT LOWER CASE
	SBI	20H	; CONVERT LOWER CASE TO UPPER
NAME1:	STAX	D	; STORE BYTE IN FCB
	INX	D
	DCR	B	; COUNT THIS BYTE
	JNZ	NAAME	; PROCESS NEXT IF MORET
	RET

FILL:	MVI	A,' '	; STORE A SPACE
	JMP	NAME1


; THIS ROUTINE RECEIVES A RECORD USING THE ASCII PROTOCOL

APRCV:	MVI	A,'.'	; PROMPT REMOTE FOR NEXT RECORD
	CALL	PUTSIO
	if	not shoxfr
	call	viomrk
	endif
APRCVX:	LDA	APNXT	; BUMP EXPECTED RECORD NUMBER
	INR	A
	CPI	'9'+1	; WRAP-AROUND
	JC	APRCVY	; JUMP IF LEQ 9
	MVI	A,'0'
APRCVY:	STA	APNXT
	if	not shoxfr
	call	viodsp
	endif
APRCV0:	CALL	TRMGET		; GET LOCAL KEYBOARD INPUT
	CPI	ETX			; IF ^C
	JZ	ABORT			; THEN ABORT THE TRANSFER
	CALL	GETSIX	; GET NEXT CHARACTER
	CPI	SOH	; <SOH> STARTS THE RECORD
	JZ	APRCV1
	CPI	ETX	; <ETX> BY ITSELF IS QUESTIONABLE
	JNZ	APRCV0
	MVI	A,'/'	; SEND A LOGICAL NAK
	CALL	PUTSIO
	if	not shoxfr
	CALL	VIODSP
	endif
	JMP	APRCV0

APRCV1:	MVI	E,0	; INIT CHECKSUM
	MOV	B,E	; INIT BYTE COUNT
	MOV	A,E	; CLEAR <EOT> FLAG
	STA	APEOT
	LXI	H,APBUF
	CALL	GETCKS	; GET SENDER'S RECORD NUMBER
	STA	APCUR

APRCV2:	CALL	GETCKS	; GET A CHECKSUMMED CHARACTER
	JZ	APRCV3
	MOV	M,A	; PUT BYTE IN BUFFER
	INR	B	; COUNT THIS BYTE
	INX	H
	if	not shoxfr
	call	ctxfr	; display '+' every 32 bytes
	endif
	JMP	APRCV2

APRCV3:	MOV	C,E	; SAVE CHECKSUM
	CALL	GETCKS	; GET REMOTE'S CHECKSUM
	CMP	C	; IF SAME
	JNZ	APRCV4	; THEN
	LDA	APNXT		; CHECK RECORD COUNT
	MOV	C,A
	LDA	APCUR
	CMP	C
	JNZ	APRCV8		; JUMP IF NOT MATCHED
	MOV	A,B	; STORE BYTE COUNT
	STA	APLEN
	LDA	APEOT	; RETURN WITH EOT FLAG STATUS
	ORA	A
	RET

APRCV4:	MVI	A,'/'	; ELSE REQUEST RETRANSMISSION
	CALL	PUTSIO
	if	not shoxfr
	CALL	VIODSP
	endif
	JMP	APRCV0

APRCV8:	JNC	ABORT		; ABORT IF RCV GTR EXPECTED
	MVI	A,'.'		; MUST HAVE RECEIVED A DUPLICATE RECORD
	CALL	PUTSIO		; ACCEPT IT, AND TRY AGAIN
	if	not shoxfr
	call	viomrk
	endif
	JMP	APRCV0


; ROUTINE TO SEND A MESSAGE

APSND:	XRA	A		; Flag for masking control characters
	LXI	H,APLEN		; BUFFER ADDRESS: LENGTH FOLLOWED BY DTA
APSND0:	STA	APFLG		; STORE MASK FLAG
	SHLD	APADDR		; STORE BUFFER ADDRESS
	LDA	APNXT		; BUMP NEXT RECORD COUNT
	INR	A
	CPI	'9'+1
	JC	ASND0A
	MVI	A,'0'
ASND0A:	STA	APNXT
	if	not shoxfr
	call	viodsp
	endif

APSND1:	MVI	E,0		; CLEAR CHECKSUM
	LHLD	APADDR
	MOV	B,M		; GET LENGTH
	INX	H		; POINT TO DATA
	MVI	A,SOH		; START THE MESSAGE
	CALL	APPUTS
	LDA	APNXT		; SEND RECORD NUMBER
	CALL	DOCKS		; UPDATE CHECKSUM
	CALL	APPUTS
APSND2:	MOV	A,M		; GET NEXT DATA BYTE
	CALL	DOCKS		;UPDATE CHECKSUM
	CPI	20H		; IF CONTROL CHARACTER
	JNC	ASND2A		; THEN
	LDA	APFLG		; IF MASKING CONTROL CHARACTERS
	ORA	A
	MOV	A,M		; GET BYTE AGAIN
	JNZ	ASND2A		; THEN
	CPI	05H		; FOR EFFICIENCY, ONLY MASK THE BADDIES
	JC	ASND2B		; MASK 00H 01H 02H 03H 04H
				;      NUL SOH STX ETX EOT
	CPI	dle
	JZ	ASND2B		; 10H DLE
	CPI	knak
	JNZ	ASND2A		; 15H NAK
ASND2B:	MVI	A,DLE		; SEND <DLE><DATA+40H)
	CALL	APPUTS
	MOV	A,M	
	ORI	40H
ASND2A:	CALL	APPUTS		; TRANSMIT THE CHARACTER
	INX	H
	if	not shoxfr
	call	ctxfr		; display '+' every 32 characters
	endif
	DCR	B
	JNZ	APSND2	; BACK FOR MORE IF ANY

APSND3:	MVI	A,ETX		; TERMINATE THE TEXT PORTION
	CALL	APPUTS
	MOV	A,E		; GET CHECKSUM
	CPI	20H		; IF < 20H
	JNC	ASND3A		; THEN
	MVI	A,DLE		; SEND IT MASKED
	CALL	APPUTS
	MOV	A,E
	ORI	40H
ASND3A:	CALL	APPUTS

ASND4A:	MVI	C,30		; ABOUT 4 SECONDS
ASND4C:	LXI	D,2500H		;
ASND4:	CALL	GETSIN		; GET HOST'S REPLY
	JNZ	SND4B
	CALL	TRMGET
	CPI	ETX
	JZ	ABORT		; ABORT THE OPERATION IF ^C TYPED
	DCX	D		; DECREMENT INNER LOOP COUNT
	MOV	A,D
	ORA	E
	JNZ	ASND4
	DCR	C
	JNZ	ASND4C
	MVI	A,ETX		; SEND EXTRA <ETX>
	CALL	APPUTS
	JMP	ASND4A

snd4b:
	if	shoxfr
	call	viodsp
	endif
	if	not shoxfr
	call	viomrk
	endif
	CPI	'.'
	RZ			; RETURN IF HOST GOT IT OKAY
	CPI	'/'		; ELSE IF / 
	JZ	APSND1		; THEN RETRANSMIT THE MESSAGE
	CPI	KNAK		; ELSE IF <NAK>
	JZ	ISSO		; THEN ABORT
	JMP	ASND4		; ELSE KEEP WAITING

APPUTS:	PUSH	PSW		; SAVE CHAR
	CALL	GETSIN		; CHECK MODEM FIRST
	JZ	APPUT4		; THEN
	ani	7fh
	CPI	KNAK		; IF WE RECEIVE A <NAK>
	JZ	ISSO		; THEN SHUT DOWN THE PROTOCOL
	CPI	DC3		; IF X-OFF
	JNZ	APPUT4		; THEN
	PUSH	D		; DELAY A FEW SECONDS
	PUSH	B
	MVI	B,2
APPUT0:	LXI	D,8000H
APPUT1:	CALL	GETSIN		; IF CHAR PRESENT
	JZ	APPUT2		; THEN
	ani	7fh
	CPI	DC1		; IF ^Q (XON)
	JZ	APPUT3		; THEN EXIT
APPUT2:	DCX	D
	MOV	A,D
	ORA	E
	JNZ	APPUT1
	DCR	B
	JNZ	APPUT0
APPUT3:	POP	B		; RESTORE REGS AND RETURN
	POP	D
APPUT4:	POP	PSW		; GET CHAR
	CALL	PUTSIO		; SEND CHAR
	RET


; ROUTINE TO GET A CHARACTER FROM UART WITH WAIT

GETSIN:	CALL	GETSIO	; RETURN SIO CHAR WITH BIT 7 = 0
	RZ
	ANI	7FH
	RET

GETSIX:	CALL	GETSIO	; GET SIO CHAR OR WAIT
	JZ	GETSIX	; WAIT FOR A CHARACTER
	CPI	KNAK	; IF <NAK> RECEIVED
	JZ	ISSO	; THEN REVERT TO TERMINAL MODE
	RET		; RETURN


GETCKS:	CALL	GETSIX	; GET NEXT SIO CHAR WITH CHECKSUMMING
	CPI	ETX	; IF <ETX>
	RZ		; THEN RETURN
	PUSH	PSW
	CPI	EOT
	JNZ	NOTEOT	; THEN
	STA	APEOT	; SET <EOT> SEEN FLAG
NOTEOT:	CPI	DLE	; IF <DLE>
	JNZ	GETCK0	; THEN
	CALL	GETSIX	;	GET NEXT CHARACTER
	ANI	1FH	;	MAKE CONTROL CHAR OF IT
GETCK0:	CALL	DOCKS	; UPDATE CHECKSUM
	POP	PSW	; RESTORE FLAGS
	MOV	A,D	; RESTORE NEW CHAR
	RET		; RETURN

DOCKS:	MOV	D,A	; SAVE BYTE
	MOV	A,E	; GET OLD CHECKSUM
	RLC		; ROTATE ONE BIT LEFT
	ADD	D	; ADD NEW BYTE
	ACI	0	; ADD POSSIBLE CARRY
	MOV	E,A	; REPLACE CHECKSUM WITH UPDATED ONE
	MOV	A,D	; RESTORE NEW BYTE
	RET

;	VARIOUS MESSAGE STRINGS

proini:	db	cr,lf,'% CSEXEC - Initializing file transfer',cr,lf,'$'
dnload:	db	cr,lf,'% CSEXEC - Beginning Download',cr,lf,'$'
upload:	db	cr,lf,'% CSEXEC - Beginning Upload',cr,lf,'$'
abload:	db	cr,lf,'? CSEXEC - Aborting file transfer',cr,lf,'$'
DLBOMB:	DB CR,LF,'% CSEXEC - That file already exists on your disk.',CR,LF
	DB	'Do you wish to replace it (Y or N) ? $'
CREMSG:	DB	cr,lf,'? CSEXEC - Diskette is full!',CR,LF,'$'
opnmsg:	db Cr,lf,'? CSEXEC - That file is not on your diskette!',cr,lf,'$'
wdrmsg:	db	cr,lf,'? CSEXEC - Your diskette is full!',cr,lf,'$'
dmsg:	db	cr,lf,'++DISCONNECTED++',cr,lf,'$'

; I/O SUBROUTINES FOR SIO

SIOGET:	IN	CTL	; GET MIO STATUS FLAGS
	ANI	SIOIR	; ISOLATE INPUT READY FLAG
	if	not hitrue
	XRI	SIOIR	; INVERT IT
	endif
	RZ		; RETURN IF NOW 0
	IN	SIO	; ELSE GET SIO CHARACTER

	if	shoxfr
	call	prodsp
	endif
	RET		; AND RETURN (Z FLAG = 0)

SIOPUT:	PUSH	PSW	; WRITE (A) TO SIO
PUTSI1:	IN	CTL	; WAIT FOR FLAG TO = 0
	ANI	SIOTR
	if	not hitrue
	JNZ	PUTSI1
	endif

	if	hitrue
	jz	putsi1
	endif
	POP	PSW
	OUT	SIO

	if	shoxfr
	if	hz19
	push	psw
	mvi	a,esc	; invert video for incoming characters
	call	viodsp
	mvi	a,'p'
	call	viodsp
	pop	psw
	push	psw
	call	prodsp
	mvi	a,esc
	call	viodsp
	mvi	a,'q'		; return to normal video
	call	viodsp
	pop	psw
	endif

	if	not hz19
	call	prodsp
	endif

	endif
	RET

sioini:
	if	hz89
	mvi	a,3		; init uart to
	out	sio+3		; 8 data bits, 1 stop bit, no parity
	endif

	if	pmmi
	mvi	a,93		; 8 data bits, 1 stop bit, no parity
	out	basprt
	mvi	a,52		; 300 baud
	out	basprt+2
	mvi	a,127		; originate mode
	out	basprt+3
	endif
 
	ret

	if	shoxfr
prodsp:	push	psw		; save the character
	lda	shoflg		; if in protocol
	ora	a
	jz	proter		; then
	pop	psw
	push	psw
	ani	7fh		; remove high-order bit
	cpi	' '		; if this is a control char
	jnc	proyes		; then
	lda	xfrtyp		; if doing a binary transfer
	cpi	'B'
	jz	pronot		; then "flag" all control characters
	pop	psw		; else flag only funny ones
	push	psw
	cpi	sholcc		; is it a normal control character?
	jc	pronot		; (ie, <HT> thru <RET>, 08h - 0Dh)
	cpi	shohcc+1
	jc	proyes
pronot:	mvi	a,'^'		; flag the control character
	call	viodsp
	pop	psw
	push	psw
	adi	40h		; map char to letter
proyes:	call	viodsp
proter:	pop	psw
	ret

	endif

	if	pmmi	; routine to disconnect pmmi modem
discon:	mvi	a,03fh
	out	basprt+3
	xra	a
	out	basprt
	out	basprt+2
	lxi	d,dmsg	; print disconnect msg
	mvi	c,fn$pcb
	call	bdos
	jmp	bbase	; and exit
	endif

;	RAM STORAGE AREA

	if	shoxfr
shoflg:	ds	1		; 1 if in file transfer protocol
	endif
	if	not shoxfr
xfrctr:	ds	1		; counter for displaying +'s
	endif
CPMSTK:	ds	2		; SAVES CP/M'S STACK POINTER
CPMDEF:	ds	1		; SAVES CP/M'S DEFAULT DISK DRIVE
PRTFLG:	ds	1	; FF IF PRINTER ENABLED, 00 OTHERWISE
SIFLAG:	ds	1	; NON-ZERO IMPLIES <SI> RECEIVED AND PROTOCOL ACTIVE
APEOT:	ds	1	; NON ZERO IF <EOT> SEEN IN GETCKS
APFLG:	ds	1	; 00 IF MASKING CONTROL CHARACTERS, FF IF NOT
xfrtyp:	ds	1	; 'A' if ASCII, 'B' if binary
APADDR:	ds	2	; POINTER TO BUFFER
APLEN:	DB	0	; LENGTH OF RECORD AS RECEIVED
APBUF:	DS	256	; STORAGE FOR THE RECORD
IBP:	DS	1	; BYTE POINTER
APNXT:	DS	1	; EXPECTED RECORD NUMBER
APCUR:	DS	1	; CURRENT (RECEIVED) RECORD NUMBER
	DS	256	; STACK GOES HERE
STACK:
HEAD:	DW	PRTBUF
TAIL:	DW	PRTBUF
LINCNT:	DB	PAGLEN
PRTBUF	EQU	$

	END	START
