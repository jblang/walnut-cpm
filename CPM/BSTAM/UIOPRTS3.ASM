;----------------------------------------------------------
; UIOPRTS3  BSTAM Personality Module Version 4.6   10-28-83
;
; Prepared by:     Adams and Hamilton, Inc.
;                         PO Box 932
;                 Kalamazoo, Michigan  49009
;                       (616) 342-0335
;
;    Routines are provided for the following devices;
;
;	California Computer Systems 2710	*
;	Heath/Zenith H-8 or H/Z-89/90		*
;	Heath/Zenith 100 Computer  <8085 CPU>   *
;  	IMSAI SIO-2 (S-100) I/O Board		fixed BR
;	Morrow Design Decision or Multi/IO	*
;	North Star Horizon Computer		fixed BR
;	North Star HSIO-4 (S-100) IOB		*
;	Ohio Scientific C3 Computer		fixed BR
;	Sanyo MBC-1000 Computer			fixed BR
;
;    NOTE: "*" indicates software selectable I/O device
;
;----------------------------------------------------------
;Note:	Should you locate any bugs in these routines please
;       contact us rather than publishing your modification.
;----------------------------------------------------------
no	equ	0	;no  = false
yes	equ	not no	;yes = true
;==========================================================
; To install this I/O module all you need do is set your
; equate to 'yes' (ALL others should be set to 'no').
;==========================================================
ccs	equ	no	;CCS 2710 IO Board
hz89	equ	no	;Heath/Zenith 89  Computer
z100	equ	no	;Heath Zenith 100 Computer
horz	equ	no	;North Star Horizon Computer
hsio	equ	no	;North Star HSIO-4 I/O Board
imsi	equ	no	;IMSAI SIO 2 I/O Board
dec1	equ	no	;Morrow Decision or Multi/IO Board
osic3	equ	no	;Ohio Scientific C3 Computer
snyo	equ	no	;Sanyo MBC-1000 Computer
;
;==========================================================
; Port Equates -- Alter ONLY if your hardware differs
;==========================================================
	if	ccs
data	equ	78h	;Port D (Board base = 10h)
	endif	;ccs
;
	if	hz89
data	equ	0d8h	;Port 330Q
	endif	;hz89
;
	if	z100
data	equ	0edh	;Data   Port
stat	equ	0ech	;Status Port
	endif	;z100
;
	if	dec1
data	equ	48h	;all IO ports base address
dev	equ	2	;Serial Port 2
	endif	;dec1
;
	if	imsi or horz
data	equ	04h	;data i/o port
stat	equ	data+1	;status port
	endif	;imsi or horz
;
	if	hsio
base	equ	10h	;address of HSIO-4 board
port	equ	0ch	;address of Port D
addr	equ	base+port
baud	equ	addr+0	;baud port
intr	equ	addr+1	;interrupt port (not used here)
data	equ	addr+2	;data i/o port
stat	equ	addr+3	;status port
	endif	;hsio
;
	if	osic3
data	equ	0af03h	;data port
stat	equ	data-1	;status port
	endif	;osic3
;
	if	snyo
data	equ	0a4h	;data i/o port
stat	equ	data+1	;status port
	endif	;snyo
;
;==========================================================
;==========================================================
; Code starts here - There should be no reason to modify
; or change any routines below this line.
;==========================================================
;==========================================================
; Jump Table (Do NOT Alter)
;
	org	103h
initil	jmp	initiu	;initialization  routine
insport jmp	inspru	;status port     routine
errset	jmp	errstu	;error reset     routine
inport	jmp	inprtu	;read data port  routine
outport jmp	outpru	;write data port routine
usertne	jmp	useru	;user-defined    routine
;----------------------------------------------------------
; REMEMBER: All I/O devices should be made to 'look' like
;           an INTEL 8251 chip. BSTAM assumes that device
;           is being used in all installations.
;----------------------------------------------------------
;	This is the initialization routine. To be
;	compatible with most BSTAM users, use the
;	following initialization guide lines:
;
;	1. use 1 stop bit		(optional - 2)
;	2. use 8 data bits		(must)
;	3. use 1 start bit		(must)
;	4. use 16x for clock rate	(must)
;	5. use asynchronous mode only	(must)
;
initiu: call	signon	;tell version number to user
;
	if	dec1
	call	fprep	;get PIC addr & prepare the io port
	endif	;dec1
;
;------------------------
	lxi	h,6dh	;
	mov	a,m	;and move from memory
	cpi	'/'	;is an option specified?
	jnz	ninit	;if not then bypass initialization
;
	if	horz or imsi or osic3 or snyo
	call	print	;these devices are FIXED BAUD RATE
	db	'(Initialization was performed on port)'
	db	13,10,0	;
	jmp	prtset	;make sure we don't go elsewhere
	endif	;horz or imsi or osic3 or snyo
;
	if	ccs or hz89 or hsio or z100 or dec1 
	call	print	;announce initialization
	db	'(Word Set to: 8d, 1S, NP  Baud: ',0
	inx	h	;point to option byte
	mov	a,m	;move from memory
	ani	7fh	;strip away parity bit
	cpi	'1'	;is it a '110', '1200' or '19.2k'?
	jz	hilo1	;if yes, then go find out
	cpi	'3'	;is it a '300' or '38.4k'?
	jz	hilo3	;if yes, then go find out
	cpi	'4'	;is it a '450' or '4800'?
	jz	hilo4	;if yes, then go find out
	cpi	'6'	;is it a '600'?
	jz	check6	;if yes, then double check
	cpi	'2'	;is it a '2400'?
	jz	check2	;if yes, then double check
	cpi	'9'	;is it a '9600'?
	jz	check9	;if yes, then double check
	jmp	error	;bail out of BSTAM
;------------------------
hilo1:	inx	h	;get second character 
	mov	a,m	;move from memory to a
	ani	7fh	;strip away parity bit
	cpi	'1'	;ahah, so it's (ughhh) '110' baud
	jz	init11	;set to 110 baud
	cpi	'2'	;so he likes to talk 212
	jz	init12	;set to 1200 baud
	cpi	'9'	;guess the man crosstalks 'puter's
	jz	init19	;set to 19.2k baud
	jmp	error	;bail out of BSTAM
;
hilo3:	inx	h	;get second character
	mov	a,m	;move from memory to a
	ani	7fh	;strip away parity bit
	cpi	'0'	;he wants to talk 103
	jz	init30	;set to 300 baud
	cpi	'8'	;a real fast talker
	jz	init38	;set to 38.4k baud
	jmp	error	;bail out of BSTAM
;
hilo4:	inx	h	;get second character
	mov	a,m	;move from memory to a
	ani	7fh	;strip away parity bit
	cpi	'5'	;so he wants to speed up 103 modems
	jz	init45	;set to 450 baud
	cpi	'8'	;we've got 'puters talking
	jz	init48	;set to 4800 baud
	jmp	error	;bail out of BSTAM
;------------------------
check2:	inx	h	;get second character
	mov	a,m	;move from memory to a
	ani	7fh	;strip away parity bit
	cpi	'4'	;now we're sure he wants 2400
	jz	init24	;set to 2.4k baud
	jmp	error	;bail out of BSTAM
;
check6:	inx	h	;get second character
	mov	a,m	;move from memory to a
	ani	7fh	;strip away parity bit
	cpi	'0'	;now we're sure he wants 600
	jz	init60	;set to 600  baud
	jmp	error	;bail out of BSTAM
;
check9:	inx	h	;get second character
	mov	a,m	;move from memory to a
	ani	7fh	;strip away parity bit
	cpi	'6'	;now we're sure he wants 9600
	jz	init96	;set to 9600 baud
	jmp	error	;bail out of BSTAM
;------------------------
init11:	call	print	;
	db	'  110)',13,10,0
;
	if	ccs or hz89 or dec1
	push	h	;save hl
	lxi	h,1087	;load  110 baud
	endif	;ccs or hz89 or dec1
;
	if	hsio	
	mvi	a,7	;
	out	baud	;
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init30:	call	print	;
	db	'  300)',13,10,0
;
	if	ccs or hz89 or dec1
	push	h	;save hl
	lxi	h,384	;load  300 baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	mvi	a,6	;
	out	baud	;
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init45:	if	ccs or hz89 or dec1
	call	print	;
	db	'  450)',13,10,0
	push	h	;save hl
	lxi	h,256	;load  450 baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	jmp	error	;no such BR on HSIO-4
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init60:	call	print	;
	db	'  600)',13,10,0
;
	if	ccs or hz89 or dec1
	push	h	;save hl
	lxi	h,192	;load  600 baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	mvi	a,5	;
	out	baud	;
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init12:	call	print	;
	db	' 1.2k)',13,10,0
;
	if	ccs or hz89 or dec1
	if	bell212
;
; If you are using a Bell 212-A Modem (or something that
; thinks that it is) you may set its internal switches so
; that it will respond to a harware signal and automatically
; enter 1200 baud operation. In the Morrow Decision I, as it
; does not support RS-232 PIN 23 we strap PIN 23 to PIN 5 &
; turn on RTS which produces a compatible signal. If you are
; using an 8250 the following code will do the trick. Other-
; wise please fudge accordingly.
;
	mvi	a,3	;fudge up a 212 'HI' signal by turn-
	call	prep	;ing on RTS (5) and strapping to (23)
	out	data+4	;on the RS-232 for automatice 1200 bd
			;operation.
	endif	bell212
;
	push	h	;save hl
	lxi	h,96	;load 1200 baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	mvi	a,4	;
	out	baud	;
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init24:	call	print	;
	db	' 2.4k)',13,10,0
;
	if	ccs or hz89 or dec1
	push	h	;save hl
	lxi	h,48	;load 2400 baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	mvi	a,3	;
	out	baud	;
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init48:	call	print	;
	db	' 4.8k)',13,10,0
;
	if	ccs or hz89 or dec1
	push	h	;save hl
	lxi	h,24	;load 4800 baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	mvi	a,2	;
	out	baud	;
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init96:	call	print	;
	db	' 9.6k)',13,10,0
;
	if	ccs or hz89 or dec1
	push	h	;save hl
	lxi	h,12	;load 9600 baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	mvi	a,1	;
	out	baud	;
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init19:	call	print	;
	db	'19.2k)',13,10,0
;
	if	ccs or hz89 or dec1
	push	h	;save hl
	lxi	h,6	;load 19.2k baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	mvi	a,0	;
	out	baud	;
	endif	;hsio
;
	jmp	iostrt	;reset & rearm I/O
;
init38:	if	ccs or hz89 or dec1
	call	print	;
	db	'38.4k)',13,10,0
	push	h	;save hl
	lxi	h,3	;load 38.4k baud
	endif	;ccs or hz89 or dec1
;
	if	hsio
	jmp	error	;no such BR on HSIO-4
	endif	;hsio
;------------------------
iostrt:	if	dec1
	call	prep	;inform the pic
	endif	;dec1
;
	if	ccs or hz89 or dec1
	mvi	a,83h	;
	out	data+3	;
	mov	a,l	;
	out	data+0	;
	mov	a,h	;
	out	data+1	;
	mvi	a,3	;
	out	data+3	;
	mvi	a,1	;
	out	data+4	;
	pop	h	;restore hl
	ret		;return to BSTAM
	endif	;ccs or hz89 or dec1
;
	if	hsio
	push	b 	;save bc
	push	h	;save hl
	lxi	h,inits	;point to commands
	mvi	b,5	;number of commands to be issued
;
initlp:	mov	a,m	;move command to Reg A
	inx	h	;increment the pointer
	call	statlp	;send it to the 8251	
	dcr	b	;decrement the counter
	jnz	initlp	;loop until B=0
	in	data	;gobble up garbage
	in	data	;gobble up garbage
	pop	h	;restore hl	
	pop	b	;restore bc
	ret		;return to BSTAM
;
statlp:	out	stat	;send it to the 8251
	nop		;
	nop		;
	nop		;
	nop		;
	nop		;
	nop		;
	ret		;return to routine
;
inits:	db	03h,03h,40h,4eh,37h
	endif	;hsio
;
	endif	;ccs or hz89 or hsio or z100 or dec1
;------------------------
	if	horz or imsi or snyo
prtset:	push	b 	;save bc
	push	h	;save hl
	lxi	h,inits	;point to commands
	endif	;horz or imsi or snyo
;
	if	horz or imsi
	mvi	b,5	;number of commands to be issued
	endif	;horz or imsi
;
	if	snyo
	mvi	b,3	;number of commands to be issued
	endif	;snyo
;
	if	horz or imsi or snyo
initlp:	mov	a,m	;move command to Reg A
	inx	h	;increment the pointer
	call	statlp	;send it to the 8251	
	dcr	b	;decrement the counter
	jnz	initlp	;loop until B=0
	endif	;horz or imsi or snyo
;
	if	horz or imsi
	in	data	;gobble up garbage
	in	data	;gobble up garbage
	endif	;horz or imsi
;
	if	horz or imsi or snyo
	pop	h	;restore hl	
	pop	b	;restore bc
	ret		;return to BSTAM
;
statlp:	out	stat	;send it to the 8251
	nop		;
	nop		;
	nop		;
	nop		;
	nop		;
	nop		;
	ret		;return to routine
	endif	;horz or imsi or snyo
;
	if	horz or imsi
inits:	db	03h,03h,40h,4eh,37h
	endif	;horz or imsi
;
	if	snyo
inits:	db	40h,4eh,37h
	endif	;snyo
;
	if	osic3
prtset:	mvi	a,0	;blank out register a
	nop		;
	nop		;
	nop		;screw around a while
	mvi	a,03h	;
	sta	stat	;send it to the 6850
	mvi	a,51h	;
	sta	stat	;send it to the 6850
	endif	;osic3
;
	ret		;return to BSTAM 
;
;----------------------------------------------------------
;	This is the status read port routine.
;	When exiting this routine, BSTAM expects
;	the following bits to be set in Register A,
;	if needed:
;
;	1. 20 bit set if framing error
;	2. 10 bit set if overrun error
;	3. 08 bit set if parity  error
;	4. 04 bit set if transmitter empty 
;	5. 02 bit set if receiver ready
;	6. 01 bit set if transmitter ready 
;	7. do not set the 80 bit or 40 bit
;
;
inspru:	if	dec1
	call	prep	;prepare the io
	endif	;dec1
;
	if	horz or hsio or z100 or imsi or snyo
	in	stat	;input status port
	endif	;horz or hsio or z100 or imsi or snyo
;
	if	ccs or hz89 or dec1
	in	data+5	;
	ani	21h	;
	push	b	;save bc
	rlc		;
	mov	b,a	;save it
	rlc		;
	rlc		;
	ora	b	;
	pop	b	;restore bc
	ani	3	;
	ori	4	;
	endif	;ccs or hz89 or dec1
;
	if	osic3
	push	b	;save bc
	lda	stat	;get status
	mov	b,a	;and tuck it away
	ani	2	;isolate rxrdy
	rar		;
	mov	c,a	;save rxrdy
	mov	a,b	;untuck it
	ani	1	;isolate txrdy
	ral		;rotate left
	ora	c	;add it back
	pop	b	;restore bc
	endif	;osic3
;
	ret		;return to BSTAM
;
;----------------------------------------------------------
; This is the error reset routine. OSI does NOT reset 6850.
;
errstu: if	dec1
	call	prep	;
	endif	;dec1
;
	if	horz or hsio or z100 or imsi or snyo
	mvi	a,37h	;reset fe, pe & oe
	out	stat	;send it to 8251
	endif	;horz or hsio or z100
		;imsi or snyo
;
	ret		;return to BSTAM
;
;----------------------------------------------------------
;	This is the read data port routine.
;	Before this routine is entered, the 02 bit of
;	the status read routine must have been set.
;	Do not clear the 80 bit from the data input port.
;	Return with Register A loaded with input data.
;
inprtu: if	not osic3
	if	dec1
	call	prep	;prepare the io
	endif	;dec1
;
	in	data	;get data from port
	endif	;not osic3
;
	if	osic3
	lda	data
	endif	;osic3
;
	ret		;return to BSTAM
;
;----------------------------------------------------------
;	This is the write data port routine.
;	Before this routine is entered, the 04 bit & 01 bit
;	of status read must be set.
;
;	Do not clear the 80 bit from the data output port.
;	Register A contains the output data.
;
outpru: if	not osic3
	if	dec1
	call	prep	;prepare the io
	endif	;dec1
;
	out	data	;send data to remote cpu
	endif	;not osic3
;
	if	osic3
	sta	data
	endif	;osic3
;
	ret		;return to BSTAM
;
;----------------------------------------------------------
;	This is the device driver signon routine
;
signon: call	print
	db	13,10,10,7
	db	'Adams and Hamilton, Inc. Kalamazoo, MI'
	db	13,10
;
	if	ccs
	db	'CCS 2710        Port D   '
	endif	;ccs
;
	if	hz89
	db	'Heath/Zenith 8 or 89/90  '
	endif	;hz89
;
	if	z100
	db	'Zenith 100 <8085 CPU>    '
	endif	;z100
;
	if	horz
	db	'North Star Horizon   '
	endif	;horz
;
	if	hsio
	db	'North Star HSIO-4        '
	endif	;hsio
;
	if	imsi
	db	'Imsai SIO-2  Port B  '
	endif	;imsi
;
	if	dec1
	db	'Morrow Design Multi/IO   '
	endif	;dec1
;
	if	osic3
	db	'Ohio Scientific C3   '
	endif	;osic3
;
	if	snyo
	db	'Sanyo MBC-1000       '
	endif	;snyo
;
	if	ccs or hz89 or dec1
	db	'(110-38.4 kb)'
	endif	;ccs or hz89 or dec1
;
	if	hsio or z100
	db	'(110-19.2 kB)'
	endif	;hsio or z100
;
	if	imsi or horz or osic3 or snyo
	db	'(Fixed Baud Rate)'
	endif	;imsi or horz or osic3 or snyo
;
	db	13,10,0
	ret		;return to routine
;
print:	xthl		;
	push	b	;
	push	d	;
;
ploop:	mov	e,m	;move from ram
	inx	h	;increment the count
	mvi	a,0	;let's see if we're
	cmp	e	;at the end?
	jz	pend	;bail out if so
	push	h	;else save hl
	mvi	c,6	;and do..
	call	5	;.. a print
	pop	h	;restore hl
	jmp	ploop	;loop until '0' is encountered
;
pend:	pop	d	;
	pop 	b	;restore it all
	xthl		;
	ret
;
ninit:	call	print	;
	db	13,13	;
	db	'(No initialization performed by BSTAM)'
	db	13,10,0
	ret		;return to BSTAM
;
error:	call	print	;
	db	'ERROR)',13,10,13,10,7
	db	'*** BAUD RATE ERROR - PROGRAM ABORTING '
	db	'***',13,10,7,0
	jmp	0	;bail out of BSTAM
;
;----------------------------------------------------------
;	This is the io preparation area for Morrow & God-
;       bout I/O Boards (S-100)
;
	if	dec1
fprep:	push	d	;save de
	push	h	;save hl
	lhld	1	;point to wboot addr
	lxi	d,37h	;offset for PIC
	dad	d	;add 'em together
	shld	grpad	;store 'em
	pop	h	;restore hl
	pop	d	;restore de
;
prep:	push	h	;save hl
	push	psw	;save psw
	lhld	grpad	;get the group address
	mov	a,m	;move it to Register A
	ori	dev	;Serial Port P2
	out	data+7	;inform I/O board
	pop	psw	;restore psw
	pop	h	;restore hl
	ret		;return to routine
;
grpad:	ds	2	;PIC address stored here
	endif		;dec1
;
;----------------------------------------------------------
useru:	ret		;return to BSTAM
;----------------------------------------------------------
	end


