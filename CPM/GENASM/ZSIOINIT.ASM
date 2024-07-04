;	Initialization program for Televideo 801/802
;		    written by Les Freed
;		    Version 1.0 3/17/82
;
;07/25/82 Corrected error which had SIO initialization code going to data port
;	  rather than status/control port and inserted code using Z80 block
;	  output instruction from a program I had written previously. Actually
;	  the Televideo seems to initialize the SIO somewhere in the system
;	  software and for the most part only needs the CTC initialized to set
;	  the baud rate, which is why this program worked before. (Bob Clyne)
;
bdos	equ	5		;CP/M entry point
;
udta	equ	20h		;usart data port
usta	equ	22h		;usart status port
;
cr	equ	0dh		;carriage return
lf	equ	0ah		;line feed
;
	org	100h
;
start:	lxi	d,signon	;print table
	call	print
;
	lxi	d,msg1		;print message
	call	print
i1:	call	input		;get input
	call	check		;check range
	jc	i1		;try again if carry set
	sui	30h		;remove ASCii bias
	sta	baud		;store divisor
;
show:	lxi	d,clear		; clear screen
	call	print
	lxi	d,msg1		;print 'baud rate:'
	call	print
	lda	baud		;get a's divisor
	call	prbaud		;print a's baud rate
	lxi	d,crmsg		;ask user if okay
	call	print
	call	input
	cpi	cr
	jnz	start		;if not CR, then start over
;

;			 SIO-INIT.ASM
;			  Version 02
;		 Originally written by Bob Clyne
;		      November 22, 1981
;
;This code initializes a Z80-SIO or Z80-DART IC for asynchronous communication.
;It uses Z80 instructions and therefore will only run on a Z80 CPU. This
;program can be run prior to using the I/O port or this code may be transferred
;to the initialization section of another program such as one of the MODEM
;programs. The status/control port number will need to be set for each
;application.
;
;01/21/82 Changed introduction and added equates for XEROX 820 Channel A.
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;Only one of the following equates should be set true.
;
XEROX	EQU	FALSE
ALTOS	EQU	FALSE
TELEVID	EQU	TRUE	;Added 07/25/82
;
	IF	ALTOS	;ALTOS 2nd printer port
DPORT	EQU	28H	;DATA PORT (Included for information only, not used.)
CTRLPT	EQU	29H	;Status/control port.
	ENDIF
;
	IF	XEROX	;XEROX 820 Channel A serial port.
CTRLPT	EQU	06H	;Status/control port.
	ENDIF
;
	IF TELEVID
CTRLPT	EQU	usta	;Use port equate from begining of pgm. (RAC 07/25/82)
	ENDIF
;
;	MACLIB	Z80	;To assemble using ASM comment out this line and make
			;the change noted below.
;
;	ORG	100H
;

SIO:	MVI	B,07H	;NUMBER OF BYTES NEEDED TO INITIALIZE THE SERIAL PORT
	MVI	C,CTRLPT;PORT TO SEND INITIALIZATION BYTES TO
	LXI	H,INITBL;ADDRESS OF TABLE OF BYTES TO SEND
;	OUTIR		;OUTPUT THE BLOCK
	DB	0EDH,0B3H;To assemble on ASM, comment out the above instruction
			 ;and remove the ';' from in front of 'DB'
;	RET		;RETURN TO CPM
	JMP	CTC	;Jump to old code to set the CTC (RAC 07/25/82)
;
INITBL:	DB	18H	;CHANNEL RESET
	DB	04H	;WRITE REGISTER 4
	DB	44H	;SET X16 CLOCK, 1 STOP BIT, NO PARITY
	DB	05H	;WRITE REGISTER 5
	DB	0EAH	;SET DTR & RTS ACTIVE & ENABLE 8 BIT TRANSMIT
	DB	03H	;WRITE REGISTER 3
	DB	0E1H	;ENABLE 8 BIT RECEIVE & AUTO ENABLES
;	DB	0C1H	;Enable 8 bit receive without AUTO ENABLES.
			;Comment out whichever of the above 2 lines you don't
			;... want.
 
;	END
;
CTC:	mvi	a,47h		; counter mode follows (Lable added RAC)
	out	08h		; send
	lda	baud		; get baud rate divisor
	out	08h		; send to port
;
	lxi	d,msg		;tell user we're done
	call	print
	ret			;& return to CP/M	
;
print:	mvi	c,9		;CP/M print string call
	call	bdos
	ret
;
input:	mvi	c,1		;CP/M get char. call
	call	bdos
	ret
;
check:	cpi	30h		;at least '0'
	jc	notok
	cpi	37h		;& not >'6'
	jnc	notok
	stc			;reset carry
	cmc
	ret
;
notok:	lxi	d,badmsg	;print message, move back up screen
	call	print
	stc ! ret		;return w/ carry set
;
prbaud:	cpi	0		;find divisor, convert & print baud rate 
	jnz	pr1
	lxi	d,m19
	mvi	a,2
	jmp	pr8
;
pr1:	cpi	1
	jnz	pr2
	lxi	d,m96
	mvi	a,4
	jmp	pr8
;
pr2:	cpi	2
	jnz	pr3
	lxi	d,m48
	mvi	a,8
	jmp	pr8
;
pr3:	cpi	3
 	jnz	pr4
	lxi	d,m24
	mvi	a,10h
	jmp	pr8
;
pr4:	cpi	4
	jnz	pr5
	lxi	d,m12
	mvi	a,20h
	jmp	pr8
;
pr5:	cpi	5
	jnz	pr6
	lxi	d,m6
	mvi	a,40h
	jmp	pr8
;
pr6:	cpi	6
	jnz	pr8
	lxi	d,m3
	mvi	a,80h
;
pr8:	sta	baud
	jmp	print
;

;
signon:	db	1ah,'INIT v 1.0      3-18-82',cr,lf,lf,lf
	db	'Select Baud Rate: ',cr,lf,lf
;
	db	'Speed',cr,lf
	db	'19200 0',cr,lf
	db	' 9600 1',cr,lf
	db	' 4800 2',cr,lf
	db	' 2400 3',cr,lf
	db	' 1200 4',cr,lf
	db	'  600 5',cr,lf
	db	'  300 6',cr,lf
	db	lf,lf,lf,'$'
;
m19:	db	'  19200$'
m96:	db	'   9600$'
m48:	db	'   4800$'
m24:	db	'   2400$'
m12:	db	'   1200$'
m6:	db	'    600$'
m3:	db	'    300$'
;
badmsg:	db	cr,lf,7,'Re-enter',cr
	db	11,12,12,12,12,12,12
	db	12,12,12,12,12,'$'	;move cursor back to entry
;
clear:	db	1ah,'$'
;
crmsg:	db	cr,lf,lf,lf,lf,'Press RETURN to set baud rate :','$'
;
msg:	db	cr,lf,'Port initialized',0dh,0ah,'$'
msg1:	db	cr,lf,'Baud rate :$'
;
baud	ds	1
;
	end
