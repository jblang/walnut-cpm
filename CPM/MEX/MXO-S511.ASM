	TITLE	'MEX overlay for SSM IO5  v1.0'

; MXO-S511.ASM -- SSM IO5 overlay for MEX	 86/10/20

VERSION	equ	11		;version number

; NOTE 1: This overlay is designed for use with either MEXPLUS or MEX.
;	Edit this file for your preferences, then follow the 'TO USE'
;	example shown below.
;
; NOTE 2: The SSM IO-5 board supports two Intel 8251s plus 3 parallel ports.
;	Extensive configuration options are supported by the many jumpers on
;	this board, but only a few of them relate to software.  These are
;	supported by the SET command, as follows:
;		SET BASE	sets base port number of board
;		SET PORT	selects which serial port (A or B)
;		SET DATA	select position of data port (0 or 1); the
;				status port will be at the other address
;	Other SET commands supported:
;		SET DIAL	select pulse/touch dialing


; TO USE: First edit this file filling in answers for your own equipment,
;	then assemble with ASM.COM or equivalent assembler.  Finally,
;	depending on the version of Mex, create an executable module:
;
;	For MEX (v1.1x), use MLOAD (v2.3 or later) to overlay the base
;	.COM file:
;		A>MLOAD MEX.COM=MEX114.COM,[MXO-SMxx,]MXO-S5xx
;			where MXO-SMxx is an optional modem overlay.
;
;	For MEXPLUS (v1.2 or greater), use MLOAD to create an overlay
;	file (.OVR), boot MEXPLUS, and use its builtin LOAD command to
;	install the overlay:
;		A>MLOAD MXO-MMxx.OVR=MXO-S5xx.HEX
;		A>MEXPLUS
;		[MEX] A0>>LOAD MXO-S5XX.OVR
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 86.10.20 - v1.1: fixed bad generation of port	- Roger Burrows
;		   addresses if DEFPORT is 'B'
; 86.10.03 - v1.0: created first version	- Roger Burrows
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =

YES	equ	0FFH
NO	equ	0

BELL	equ	07H		;bell
TAB	equ	09H		;tab
LF	equ	0AH		;linefeed
CR	equ	0DH		;carriage return
ESC	equ	1BH		;escape

; Change the following information to match your equipment

DEFBASE	equ	090H		;Default base address for IO5 board
DEFPORT	equ	'A'		;Default serial port
DEFDATA	equ	0		;Default data port

; End of information to change

DEFSTAT	equ	1-DEFDATA	;Default status port

DATA	equ	DEFBASE+(DEFPORT-'A')*2+DEFDATA	;8251 data port

STATUS	equ	DEFBASE+(DEFPORT-'A')*2+DEFSTAT	;8251 status port
RXRDY	equ	02H		;  Receiver Ready
MDRCVB	equ	RXRDY		;    Bit to test for Receive
MDRCVR	equ	RXRDY		;    & value when ready
TXEMPTY	equ	04H		;  Transmitter Empty
MDSNDB	equ	TXEMPTY		;    Bit to test for Send
MDSNDR	equ	TXEMPTY		;    & value when ready

COMMAND	equ	STATUS		;8251 command port
TXEN	equ	01H		;  Transmit Enable
DTR	equ	02H		;  Data Terminal Ready
RXEN	equ	04H		;  Receive Enable
SBRK	equ	08H		;  Send Break
ER	equ	10H		;  Error Reset
RTS	equ	20H		;  Request To Send
IR	equ	40H		;  Internal Reset
STDMODE	equ	4EH		;Standard Mode Value (see 8251 spec):
				;  bits: 8 data, 1 stop, no parity
				;  baud rate factor = 16x

; MEX service processor

MEX	equ	0D00h		;address of the service processor
INMDM	equ	255		;get char from port to A, CY=no more in 100 ms
TIMER	equ	254		;delay 100ms * reg B
TMDINP	equ	253		;B=# secs to wait for char, cy=no char
CHEKCC	equ	252		;check for ^C from KBD, Z=present
SNDRDY	equ	251		;test for modem-send ready
RCVRDY	equ	250		;test for modem-receive ready
SNDCHR	equ	249		;send a character to the modem (after sndrdy)
RCVCHR	equ	248		;recv a char from modem (after rcvrdy)
LOOKUP	equ	247		;table search: see CMDTBL comments for info
PARSFN	equ	246		;parse filename from input stream
BDPARS	equ	245		;parse baud-rate from input stream
SBLANK	equ	244		;scan input stream to next non-blank
EVALA	equ	243		;evaluate numeric from input stream
LKAHED	equ	242		;get nxt char w/o removing from input
GNC	equ	241		;get char from input, cy=1 if none
ILP	equ	240		;inline print
DECOUT	equ	239		;decimal output
PRBAUD	equ	238		;print baud rate

CONOUT	equ	2		;simulated BDOS function 2: console char out
PRINT	equ	9		;simulated BDOS function 9: print string
INBUF	equ	10		;input buffer, same structure as BDOS 10


	org	100h		;we begin

	ds	3		;for the "JMP START" instruction
PMODEM:	db	NO		;yes=PMMI modem \ / These 2 locations are not
SMODEM:	db	NO		;yes=Smartmodem / \ referenced by MEX
TPULSE:	db	'T'		;T=touch, P=pulse (referenced by MXO-SMxx)
CLOCK:	db	40		;clock speed x .1, up to 25.5 mhz.
MSPEED:	db	5		;sets display time for sending a file
				;0=110	1=300  2=450  3=600  4=710
				;5=1200 6=2400 7=4800 8=9600 9=19200
BYTDLY:	db	5		;default time to send character in
				;terminal mode file transfer (0-9)
				;0=0 delay, 1=10 ms, 5=50 ms, 9=90 ms
CRDLY:	db	5		;end-of-line delay after CRLF in terminal
				;mode file transfer for slow BBS systems
				;0=0 delay, 1=100 ms, 5=500 ms, 9=900 ms
COLUMS:	db	5		;number of directory columns
SETFL:	db	YES		;yes=user-defined SET command
SCRTST:	db	YES		;yes=if home cursor and clear screen
				;routine at CLRSCRN
	db	0		;was once ACKNAK, now spare
BAKFLG:	db	NO		;yes=make .BAK file
CRCDFL:	db	YES		;yes=default to CRC checking
				;no=default to Checksum checking
TOGCRC:	db	YES		;yes=allow toggling of Checksum to CRC
CVTBS:	db	NO		;yes=convert backspace to rub
TOGLBK:	db	YES		;yes=allow toggling of bksp to rub
ADDLF:	db	NO		;no=no LF after CR to send file in
				;terminal mode (added by remote echo)
TOGLF:	db	YES		;yes=allow toggling of LF after CR
TRNLOG:	db	YES		;yes=allow transmission of logon
				;write logon sequence at location LOGON
SAVCCP:	db	YES		;yes=do not overwrite CCP
LOCNXT:	db	NO		;yes=local cmd if EXTCHR precedes
				;no=not local cmd if EXTCHR precedes
TOGLOC:	db	YES		;yes=allow toggling of LOCNXTCHR
LSTTST:	db	YES		;yes=allow toggling of printer on/off
				;in terminal mode. Set to no if using
				;the printer port for the modem
XOFTST:	db	NO		;yes=allow testing of XOFF from remote
				;while sending a file in terminal mode
XONWT:	db	NO		;yes=wait for XON after sending CR while
				;transmitting a file in terminal mode	
TOGXOF:	db	YES		;yes=allow toggling of XOFF testing
IGNCTL:	db	NO		;yes=do not send control characters
				;above CTL-M to CRT in terminal mode
				;no=send any incoming CTL-char to CRT
EXTRA1:	db	0		;for future expansion
EXTRA2:	db	0		;for future expansion
BRKCHR:	db	'@'-40h		;^@ = Send a 300 ms. break tone
NOCONN:	db	'N'-40h		;^N = Disconnect from phone line
LOGCHR:	db	'L'-40h		;^L = Send logon
LSTCHR:	db	'P'-40h		;^P = Toggle printer
UNSVCH:	db	'R'-40h		;^R = Close input text buffer
TRNCHR:	db	'T'-40h		;^T = Transmit file to remote
SAVCHR:	db	'Y'-40h		;^Y = Open input text buffer
EXTCHR:	db	'^'-40h		;^^ = Send next character
	ds	2		;used for PMMI (not referenced by MEX)

INSTAT:				;in modem status port
ST1:	in	STATUS
	ret

; We have 7 free bytes here, so let's use them (for modem stuff)

OUTCMD:				;mex doesn't know about this
ST2:	out	COMMAND
	ret

; Default values for BASE, PORT, DATA

BASEVAL:db	DEFBASE		;or this
PORTVAL:db	DEFPORT
DATAVAL:db	DEFDATA

	db	0

OTDATA:				;out modem data port
DA1:	out	DATA
	ret
	db	0,0,0,0,0,0,0

INDATA:				;in modem data port
DA2:	in	DATA
	ret
	db	0,0,0,0,0,0,0

MASKR:	ani	MDRCVB		;bit to test for receive ready
	ret
TESTR:	cpi	MDRCVR		;value of receive bit when ready
	ret
MASKS:	ani	MDSNDB		;bit to test for send ready
	ret
TESTS:	cpi	MDSNDR		;value of send bit when ready
	ret

DCDTST:	jmp	DCDVEC		;data carrier detect (MEXPLUS)
RNGDET:	jmp	RNGVEC		;ring detect (MEXPLUS)
	db	0,0,0,0,0	;reserved
SMDISC:	ds	3		;smartmodem disconnect (MEXPLUS)

DIALV:	ds	3		;dial digit in A
DISCV:	jmp	PDISC		;disconnect modem (with DTR)
GOODBV:	jmp	GOODBY		;call just before exit to CP/M
INMODV:	jmp	INITMD		;called on entry from CP/M
NEWBDV:	jmp	DUMMY		;set new baud rate
NOPARV:	jmp	DUMMY		;set modem for no parity
PARITV:	jmp	DUMMY		;set modem for parity
SETUPV:	jmp	SETCMD		;process SET cmd
	ds	3		;reserved, not used by MEX
VERSNV:	jmp	SYSVER		;sign-on message from overlay
BREAKV:	jmp	PBREAK		;send a break

; Do not change the following six lines
; (jump vectors, not supported in MEX 2.0)

	ds	3		;replace with MEX function 9
	ds	3		;replace with MEX function 10
	ds	3		;replace with MEX function 247
	ds	3		;replace with MEX function 255
	ds	3		;not supported by MEX
	ds	3		;replace with MEX function 254

; Routines to clear screen & clear to end of screen.  If using
; these routines, set SCRTST to YES at 010AH (above).

CLREOS:	mvi	c,PRINT
	lxi	d,TCLEOS
	call	MEX
	ret

CLS:	mvi	c,PRINT
	lxi	d,TCLSCR
	call	MEX
	ret

; End of fixed area ... from here to 1FFH is reserved (MEXPLUS)

	org	200H

;..........	start of free-format user routines	..........

; Return data carrier detect status (MEXPLUS)

DCDVEC:	mvi	a,254		;not supported - no DCD on 8251s
	ret

; Return ring indicator status (MEXPLUS)

RNGVEC:	mvi	a,254		;not supported - no RI on 8251s
	ret

; Disconnect modem

PDISC:	call	INDATA		;clear any pending data
	mvi	A,TXEN+RXEN+ER+RTS	;turn off DTR
	call	OUTCMD		;clear DTR in command reg
	mvi	b,3		;delay 300 milliseconds
	mvi	c,TIMER
	call	MEX
	mvi	a,TXEN+DTR+RXEN+ER+RTS	;set DTR to modem again
	call	OUTCMD
	ret

; Exit to CP/M

GOODBY:	call	INDATA		;clear any pending data
	xra	a		;turn off everything (DTR, RTS etc)
	call	OUTCMD
	ret

; Enter from CP/M (also called from FIXIO)

INITMD:	mvi	b,3		;send 3 nulls
	xra	a		; to force to command state
INITLP:	call	OUTCMD
	dcr	b
	jnz	INITLP
	mvi	a,IR		;reset to mode level
	call	OUTCMD
	mvi	a,STDMODE 	;set standard mode
	call	OUTCMD
	mvi	a,TXEN+DTR+RXEN+ER+RTS	;enable receive, transmit, DTR, RTS
	call	OUTCMD
	ret

; Dummy routine

DUMMY:	ret

; Issue signon message

SYSVER:	mvi	c,ILP
	call	MEX
	db	'Version ',VERSION/10+'0','.',VERSION MOD 10+'0'
	db	' for SSM IO5 board',CR,LF,0
	mvi	c,ILP
	call	MEX
	db	'Base address ',0
	lda	BASEVAL		;print base port number
	call	PRTHEX
	mvi	c,ILP
	call	MEX
	db	', serial port ',0
	mvi	c,CONOUT
	lda	PORTVAL		;print serial port (A or B)
	mov	e,a
	call	MEX
	mvi	c,ILP		;show data port as even or odd
	call	MEX
	db	', data port is ',0
	lda	DATAVAL
	lxi	d,EVEN		;print even/odd
	ora	a		;is it even ?
	jz	SYSVR1		;yes
	lxi	d,ODD		;else odd
SYSVR1:	mvi	c,PRINT
	call	MEX
	mvi	c,ILP
	call	MEX
	db	', ',0
	lda	TPULSE
	lxi	d,PLSMSG	;print pulse/touch
	cpi	'P'		;is it pulse ?
	jz	SYSVR2		;yes
	lxi	d,TCHMSG	;else touch
SYSVR2:	mvi	c,PRINT
	call	MEX
	mvi	c,ILP
	call	MEX
	db	' dialing',0
	ret

; Send break to remote

PBREAK:	mvi	a,TXEN+DTR+RXEN+SBRK+ER+RTS	;set break
	call	OUTCMD
	mvi	b,3				;delay 300 milliseconds
	mvi	c,TIMER
	call	MEX
	mvi	a,TXEN+DTR+RXEN+ER+RTS		;resuming normal service ...
	call	OUTCMD
	ret

; Handle SET command

SETCMD:	mvi	c,SBLANK	;any arguments?
	call	MEX
	jc	STSHOW		;if not, go print out values
	mvi	c,LOOKUP
	lxi	d,CMDTBL	;parse command
	call	MEX
	jc	SETERR		;can't find it
	pchl			;else go there
SETERR:	mvi	c,PRINT
	lxi	d,SETEMS	;print error
	call	MEX
	ret

SETEMS:	db	'SET command error',CR,LF,CR,LF,'$'

CMDTBL:	db	'?'+80h			; "set ?"
	dw	STHELP
	db	'BAS','E'+80h		; "set base"
	dw	STBASE
	db	'DAT','A'+80h		; "set data"
	dw	STDATA
	db	'DIA','L'+80h		; "set dial"
	dw	STDIAL
	db	'POR','T'+80h		; "set port"
	dw	STPORT
	db	0

; SET <no-args>: print current statistics

STSHOW:	lxi	h,SHOTBL	;get table of SHOW subroutines
STSHLP:	mov	e,m		;get table address
	inx	h
	mov	d,m
	inx	h
	mov	a,d		;end of table?
	ora	e
	rz			;exit if so
	push	h		;save table pointer
	xchg			;adrs to HL
	call	GOHL		;do it
	mvi	c,CHEKCC	;check for console abort
	call	MEX
	pop	h		;it's done
	jnz	STSHLP		;continue if no abort
	call	CRLF
	ret

GOHL:	pchl

; table of SHOW subroutines

SHOTBL:	dw	SHOWBA
	dw	SHOWPO
	dw	SHOWDT
	dw	SHOWDL
	dw	0

; SET ?  processor

STHELP:	mvi	c,PRINT
	lxi	d,HLPMSG
	call	MEX
	ret

; The help message

HLPMSG:	db	CR,LF,'SET command options:'
	db	CR,LF,'  SET BASE <hex #>      ... set new base port (00,10 ... F0)'
	db	CR,LF,'  SET DATA <0|1>        ... set data port address (0=even,1=odd)'
	db	CR,LF,'  SET DIAL <P|T>        ... set Pulse or Touch dialing'
	db	CR,LF,'  SET PORT <A|B>        ... set serial port id'
	db	CR,LF
CRLFMS:	db	CR,LF,'$'

; SET BASE command processor

STBASE:	mvi	c,SBLANK	;skip blanks
	call	MEX
	jc	SETERR		;nothing else
	lxi	h,0		;use HL to build port #
STBAS1:	push	h		;save across MEX
	mvi	c,GNC		;get char from input, cy=1 if none
	call	MEX
	pop	h		;restore
	jc	STBAS2
	call	HEXCON		;convert to hex nybble in A
	jc	SETERR		;not hex
	dad	h		;shift L left by 4 bits
	dad	h
	dad	h
	dad	h
	ora	l		;or with new nybble
	mov	l,a		;back to L
	mov	a,h		;anything in H yet ?
	ora	a
	jnz	SETERR		;yes - too big
	jmp	STBAS1		;else go round again
STBAS2:	mov	a,l		;reg L contains base port #
	ani	0fh		;check boundary alignment
	jnz	SETERR		;no good
	mov	a,l		;ok - save for display
	sta	BASEVAL
	call	FIXIO		;fix up in/out with BASEVAL,PORTVAL,DATAVAL
SHOWBA:	mvi	c,ILP
	call	MEX
	db	'Base address set to ',0
	lda	BASEVAL
	call	PRTHEX
	call	CRLF
	ret

; SET DATA processor

STDATA:	mvi	c,SBLANK	;skip blanks
	call	MEX
	jc	SETERR		;nothing else
	mvi	c,EVALA		;get numeric from input
	call	MEX
	mov	a,h
	ora	a		;> 256 ?
	jnz	SETERR		;yes, error
	mov	a,l
	cpi	2		;check it
	jnc	SETERR		;invalid
	sta	DATAVAL		;store it
	call	FIXIO		;fix up in/out with BASEVAL,PORTVAL,DATAVAL
SHOWDT:	mvi	c,ILP
	call	MEX
	db	'Data port set to ',0
	lda	DATAVAL		;get data setting
	lxi	d,EVEN		;assume even
	ora	a		;is it ?
	jz	SHOWT2		;yes
	lxi	d,ODD		;else odd
SHOWT2:	mvi	c,PRINT
	call	MEX
	call	CRLF
	ret

; SET DIAL processor

STDIAL:	mvi	c,SBLANK	;skip blanks
	call	MEX
	jc	SETERR		;nothing else
	lxi	d,DIALTB	;parse cmd
	mvi	c,LOOKUP
	call	MEX
	jc	SETERR
	mov	a,l		;get upper case character
	sta	TPULSE		;store it for MXO-SMxx
SHOWDL:	mvi	c,ILP		;display status
	call	MEX
	db	'Dialing type set to ',0
	lda	TPULSE		;get pulse/touch setting
	lxi	d,PLSMSG	;assume pulse
	cpi	'P'		;is it ?
	jz	SHOWD2		;yes
	lxi	d,TCHMSG	;else touch
SHOWD2:	mvi	c,PRINT
	call	MEX
	call	CRLF
	ret

; Dial table - saves us worrying about upper/lower case

DIALTB:	db	'P'+80H		;pulse dial
	db	'P',0
	db	'T'+80H		;touch dial
	db	'T',0
	db	0

; SET PORT processor

STPORT:	mvi	c,SBLANK	;skip blanks
	call	MEX
	jc	SETERR		;nothing else
	lxi	d,PORTTB	;parse cmd
	mvi	c,LOOKUP
	call	MEX
	jc	SETERR
	mov	a,l		;get upper case character
	sta	PORTVAL		;a-ok, save it
	call	FIXIO		;fix up in/out with BASEVAL,PORTVAL,DATAVAL
SHOWPO:	mvi	c,ILP		;display status
	call	MEX
	db	'Port set to ',0
	mvi	c,CONOUT
	lda	PORTVAL
	mov	e,a
	call	MEX		;display it
	call	CRLF
	ret

; Port table - saves us worrying about upper/lower case

PORTTB:	db	'A'+80H
	db	'A',0
	db	'B'+80H
	db	'B',0
	db	0

;..........	subroutines used by the above routines	..........

; Convert ascii char in A to hex nybble

HEXCON:	cpi	'0'		;< '0' ?
	rc			;error - return with carry set
	cpi	'9'+1		;<= '9' ?
	jc	HEXNUM		;yes - must be 0-9
	cpi	'A'		;< 'A' ?
	rc			;error
	cpi	'F'+1		;<= 'F' ?
	jc	HEXALF		;yes - convert to hex nybble
	cpi	'a'		;< 'a' ?
	rc			;error
	cpi	'f'+1		;<= 'f' ?
	jnc	HEXERR		;no - error
	sui	'a'-'A'		;convert lower case a-f to upper
HEXALF:	stc
	adi	9		;convert upper case A-F to 3ah-3fh
HEXNUM:	ani	0fh		;clear high-order nybble
	ret
HEXERR:	stc
	ret

; Print contents of A as hex, followed by 'h'

PRTHEX:	push	psw		;save A
	rrc			;right justify one hex digit
	rrc
	rrc
	rrc
	call	PRTNYB		;print first hex digit
	pop	psw
	call	PRTNYB		;print second hex digit
	mvi	c,CONOUT
	mvi	e,'h'
	call	MEX		;print trailing 'h'
	ret

; Print hex nybble

PRTNYB:	ani	0fh		;print one hex digit
	adi	90h		;trust me, this works
	daa
	aci	40h
	daa			;now ascii
	mvi	c,CONOUT	;print it
	mov	e,a
	call	MEX
	ret

; Do cr, lf

CRLF:	mvi	c,PRINT
	lxi	d,CRLFMS
	call	MEX
	ret

; Update in & out instructions with new BASEVAL, PORTVAL, DATAVAL

FIXIO:	lda	PORTVAL		;get port id
	sui	'A'		; make it 0 or 1
	add	a		;  then 0 or 2 (offset to 1st reg for A or B)
	mov	b,a		;   in reg b
	lda	BASEVAL		;get base address
	ora	b
	mov	b,a		;b = address of even port
	lda	DATAVAL		;get data port offset
	ora	b		;a = address of data port
	sta	DA1+1
	sta	DA2+1
	xri	01h		;now a = address of status port
	sta	ST1+1
	sta	ST2+1
	jmp	INITMD		;go reinitialise ports & return

; Miscellaneous messages

EVEN:	db	'even address','$'
ODD:	db	'odd address','$'
PLSMSG:	db	'pulse','$'
TCHMSG:	db	'touch','$'

; Terminal-dependent control sequences

TCLEOS:	db	17H,'$'		;clear to end-of-screen
TCLSCR:	db	18H,'$'		;clear screen

;.....
;
; Note:	This overlay must terminate prior to 0B00H (with Smartmodem overlay)
;					     0D00H (without Smartmodem overlay)
;.....

	END
