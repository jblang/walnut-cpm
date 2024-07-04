	title	mini modem program
;         MINIMOD - a subset modem program for MSDOS.
;         ===========================================
;
;          Dave Moore,
;          QCOM Pty Ltd
;          May 84.
;
;          Thió  prograí  ió  copyright®  (Yes¬  reallù  - itó  iî 
;          source!©  Permissioî ió granteä tï uså it¬  buô noô foò 
;          profit¬  provideä  thaô thió noticå ió retaineä   alonç 
;          witè  thå starô uð messagå iî thå prograí  itself¬  anä 
;          provideä thaô anù modifieä versionó oæ thió prograí arå 
;          returneä  tï  thå publiã domaiî bù submissioî  tï  thió 
;          system.
;
;
;	will perform terminal mode, christensen up and down load and
;	a few others
;
;
;	SYSTEM CONDITIONALS
hp150	equ	1	;delete if not hp150
handle	equ	1	;delete if use CP/M compatible auxilary reads/writes
;
;	hp150 is defined for hp150 only
;	for this machine, handle should also be defined
;
;	handle should be defined if you want to use reads and writes
;	from the devices handle rather than from by using AUX read and write
;	on most machines, either method should work
;
;	The program has been used to connect an HP150 with a SHARP PC5000
;	and with an Osborne 1 using YAM. It has successfully transfered about
;	a megabyte of data using Christensen Protocol
;
;	Note:  *******************************************************
;
;	it may be neccessary to change the name of the device in AUXNAM
;	system equates
;
;
ssize	equ	200	;stack size
cr	equ	13
lf	equ	10
can	equ	24
nak	equ	21
ack	equ	6
soh	equ	1
eot	equ	04h
commode	equ	5	;character to return to command mode from terminal
;			 mode (CTRL E)
;
;		msdos calls
;
stop	equ	4ch
readky	equ	01h
writky	equ	02h
dirky	equ	06h	;check keyboard status
buffky	equ	0ah	;read a buffer of input
dispky	equ	09h
auxred	equ	03h
auxwrt	equ	04h
hndlrd	equ	3fh
hndlwr	equ	40h
parse	equ	29h
iocntl	equ	44h
openhn	equ	3dh
openfl	equ	0fh
closfl	equ	10h
seqrd	equ	14h
seqwrt	equ	15h
create	equ	16h
delete	equ 	13h
setdma	equ	1ah
;
;	msdos macros
;
msdos	macro	op,dxval
	mov	dx,offset dxval
	mov	ah,op
	int	21h
	endm
msdos1	macro	op
	mov	ah,op
	int	21h
	endm
;
;	Remark: Originally, only one macro was defined with an
;	IFDIF <dxval>,<> conditional to detect the presence/absence of
;	the second parameter, but this seemed to cause the assembler to loop
data	segment	
;
;	change of device name  may be required
;
	ifdef	hp150
auxnam	db	'COM1',0	;name of device to use for communication
	else
auxnam	db	'AUX',0		;name of device to use for communication
	endif
fcb	db	60 dup (0)
inbuff	db	20,0
	db	20 dup (0)	;input command buffer
fbuff	db	128 dup (?)	;file buffer
block	dw	0		;block number for file
copyrt	db	cr,lf,'MiniMod - a small MSDOS Modem program'
	db	cr,lf,'=====================================',cr,lf
	db	cr,lf,'Copyright Dave Moore, QCOM Pty Ltd May 84 229-3544'
	db	cr,lf,'$'
greet	db	cr,lf,'Minimodem :$'
ovrwrt	db	cr,lf,'Overwrite ?$'
filep	db	cr,lf,'File name :$'
cancel	db	cr,lf,'Command cancelled $',cr,lf
nocomm	db	cr,lf,'Command invalid',cr,lf,'$'
seqerr	db	cr,lf,'Block sequence error',cr,lf,'$'
dupblk	db	cr,lf,'Duplicate block ignored',cr,lf,'$'
chkerr	db	cr,lf,'Checksum error $',cr,lf,'$'
hnderr	db	cr,lf,'Handle status error :    ',cr,lf,'$'
hexfl	db	0		;send/receive in hex flag
halffl	db	0		;half duplex flag
hexwrk	db	'  $'		;kex work area
auxhnd	dw	?		;handler for aux
errmes	db	'error 0'
errmes1	db	'  opening AUX handle',cr,lf,'$'
nofile	db	cr,lf,'no file found',cr,lf,'$'
tcomp	db	cr,lf,'Transfer complete',cr,lf,'$'
abandn	db	cr,lf,'Transfer abandoned',cr,lf,'$'
aster	db	'*$'
badtr	db	cr,lf,'Got     for ACK',cr,lf,'$'
goodtr	db	'^$'
timout	db	'Christensen timed out ',cr,lf,'$'
expec	db	'Expected :'
expec1	db	'    ',cr,lf,'$'
recvd	db	'Received :'
recvd1	db	'    ',cr,lf,'$'
blokno	db	cr,lf,'Block no :    $'
fprint	db	cr,lf,62 dup (' ')
	db	cr,lf,62 dup (' ')
	db	cr,lf,62 dup (' ')
	db	cr,lf,62 dup (' ')
	db	cr,lf,62 dup (' ')
	db	cr,lf,62 dup (' ')
	db	cr,lf,62 dup (' ')
	db	cr,lf,62  dup (' '),cr,lf,'$'
	ifdef	hp150
;
;	device control strings to set 8 bit and disable handshaking
;
dishnd	db	3,8	;disable handshaking
set8bt	db	2,8	;set 8 bit mode
	endif
prompt	db	0	;prompt character for current f command
promps	db	0	;prompt command for fw command	
nocntl	db	cr,lf,'Device cannot accept control strings'
	db	cr,lf,'Modem aborted',cr,lf,'$'
rspnse	db	0	;response to send down line
rcvblk	db	1	;received block number
wait	dw	2000	;loops to check for response from other end
choke	dw	3000	;choke on output for slow lines
data	ends
;
stack	segment stack
	dw	ssize dup (?)
stack	ends
;
code	segment	byte public 'code'
	assume	cs:code,ds:data,ss:stack
start:  mov     ax,data
	mov	ds,ax
	mov	es,ax
	mov	ax,stack
	mov	ss,ax
	mov	sp,ssize
;
;	open aux handle
;
	mov	al,2
	msdos	openhn,auxnam
	jnc	open1		;on successful
	mov	bx,offset errmes1
	call	hex
	msdos	dispky,errmes
	jmp	excom
open1:	mov	auxhnd,ax	;save handle for aux
;
;		set status for aux handler
;
	mov	bx,auxhnd	
	mov	al,0
	msdos1	iocntl
	or	dx,20h		;set raw mode
	and	dx,0ffh		;clear top byte
	mov	al,1
	mov	bx,auxhnd
	push	dx
	msdos1	iocntl		;save new device status
	pop	dx
	ifdef	hp150
	or	dx,8000h	;check ctrl bit	
	jz	hp1		;on cannot do control strings
	mov	bx,auxhnd
	mov	al,3
	mov	cx,2			;bytes to send
	msdos	iocntl,set8bt
	mov	bx,auxhnd
	mov	al,3
	mov	cx,2			;bytes to send
	msdos	iocntl,dishnd
	jmp	main
hp1:	msdos	dispky,nocntl
	jmp	excom
	endif
;
;		start main procedure
;
main:	msdos	dispky,greet
	msdos	buffky,inbuff	;rea a command line
	mov	al,inbuff+1
	cmp	al,0
	jz	main		;on nothing entered
	cmp	al,1
	jnz	len2
	jmp	len1		;length 1 command
len2:	mov	ax,word ptr inbuff+2
	or	ax,2020h	;set lower case
	cmp	ax,'ht'		;th = terminal half duplex
	jz	thcom
	cmp	ax,'hp'	
	jz	phcom
	cmp	ax,'bp'
	jz	pbcom
	cmp	ax,'xe'		;ex = exit minimod
	jz	excom
	cmp	ax,'gp'		;pg = set prompt character
	jz	pgcom
	cmp	ax,'wf'		;fw = transfer file with wait
	jz	fwcom
	cmp	ax,'cp'		;pc - change choke parameter
	jz	pccom
	cmp	ax,'wp'		;pw - change wait parameter
	jz	pwcom
err:	msdos	dispky,nocomm
	jmp	main
thcom:	mov	halffl,1
	jmp	termmd
excom:	msdos1	stop
	jmp	main
fwcom:	mov	al,promps
	mov	prompt,al
	call	readfw
	jmp	main
pbcom:	mov	hexfl,0		;send/receive in binary
	jmp	main
phcom:	mov	hexfl,1		;send/receive in hex
	jmp	main
pgcom:	mov	al,inbuff+4
	mov	promps,al
	jmp	main
pccom:	mov	al,inbuff+4
	sub	al,'0'
	mov	ah,0
	add	ax,ax
	add	ax,ax
	mov	ah,al
	add	ax,1
	mov	choke,ax
	jmp	main
pwcom:	mov	al,inbuff+4
	sub	al,'0'
	mov	ah,0
	add	ax,ax
	add	ax,ax
	mov	ah,al
	mov	wait,ax
	add	ax,1
	jmp	main
;
;		one byte commands
;
len1:	mov	al,inbuff+2
	or	al,20h		;set lower case
	cmp	al,'t'
	jz	tcom
	cmp	al,'r'
	jz	chread
	cmp	al,'f'
	jz	fcom
	cmp	al,'s'
	jnz	err
;
;	christensen write
;
	call	sendch
	jmp	main
;
;	christensen read
;
chread:	call	readch
	jmp	main
;
;	f com -transmit a file
;
fcom:	mov	prompt,0
	call	readfw
	jmp	main
;
;	terminal mode
;
tcom:	mov	halffl,0	;set full duplex
termmd:	msdos	dirky,0ffh
	jz	termm1		;on no character input from console
	cmp	al,commode
	jz	termm2		; return to command mode
	push	ax
	call	sendrm		;send to remote
	pop	dx
	mov	al,halffl
	cmp	al,0
	jz	termm1		;go and look at remote
	msdos1	writky
	jmp	termmd
;	
termm1:	call	recvrm
	jz	termmd		;on no character received from remote
	mov	dl,al
	msdos1	writky
	jmp	termmd
termm2:	jmp	main
;
;	look for a character from the remote line
;
;	return in al with zero flag clear if found
recvrm:	mov	bx,auxhnd	
	mov	al,6
	msdos1	iocntl		;check ready for input
	cmp	al,0ffh
	jz	recvr1		;on character ready
	cmp	al,0
	jz	recv0
	mov	bx,offset hnderr+24
	call	hex
	msdos	dispky,hnderr
	cmp	al,al		;return zero
recv0:	ret			;return with zero flag set
	ifdef	handle
;
;	read using file handle
;
recvr1:	mov	cx,1
	mov	bx,auxhnd
	msdos	hndlrd,inbuff+2
	mov	al,inbuff+2
	else
recvr1:	msdos1	auxred
	endif
	or	ah,0ffh		;set not zero
	ret
;
;	send a character down the line
;
sendrm:	mov	dl,al
	ifdef	handle
	mov	bx,auxhnd
	mov	cx,1
	mov	inbuff+2,al
	msdos	hndlwr,inbuff+2
	else
	msdos1	auxwrt
	endif
;
;	wait for duration of choke
;
	mov	ax,choke
sendr1:	dec	ax
	jnz	sendr1
	ret
;
;	christensen send routine
;
sendch:	call filenm
	mov	block,1
	msdos	openfl,fcb
	mov	byte ptr fcb+20h,0
	cmp	al,0
	jz	send1		;on found
	msdos	dispky,nofile
	ret
send1:	msdos	setdma,fbuff	;set dma address
;
;	wait for nak to start transmission
;
send2:	call	recvrm
	jz	send2		;on nothin received
	cmp	al,nak
	jnz	send2
send3:	msdos	seqrd,fcb
	cmp	al,0
	jz	send4		;normal completion
	cmp	al,3
	jz	send4		;partial record
	mov	al,eot		;completion message
	call	sendrm		;send completion code
	msdos	dispky,tcomp
	msdos	closfl,fcb
	ret
send4:	call	sendbl		;send block
;
;		wait for response from remote
;
	call	recvwt
	jnz	send6		;on not time out
	mov	al,can		;cancel transmission
	call	sendrm
	msdos	dispky,timout	
	ret
send6:	cmp	al,ack
	jz	send7
	cmp	al,can
	jz	send8		;on remote cancelled
	mov	bx,offset badtr+6
	call	hex
;	
	msdos	dispky,badtr
	jmp	send4		;resend block
send7:	inc	block
	msdos	dispky,aster
	jmp	send3		;send next block
send8:	msdos	dispky,cancel
	ret
;
;
;	christensen receive routine
;
readch:	call filenm
	mov	block,1
	msdos	openfl,fcb
	cmp	al,0
	jnz	read0		;on not found
	msdos	dispky,ovrwrt
	msdos	buffky,inbuff
	mov	al,byte ptr inbuff+2
	or	al,20h		;make lower case
	cmp	al,'y'
	jz	read0		;on overwrite
	jmp	read11
read0:	msdos	setdma,fbuff	;set dma address
	msdos	create,fcb	;create new file
	mov	byte ptr fcb+20h,0	;set relative record
	mov	rspnse,nak		;set nak is to be sent
;
;	send naks until something appears on the line
;
read1:	mov	al,rspnse
	call	sendrm
	call	recvwt		;wait for reply
	jz	read1		;on nothin received
	cmp	al,can
	jz	read9		;remote cancelled request
	cmp	al,eot
	jz	read8		;complete transfer
	cmp	al,soh
	jnz	read1		;on not a soh
;
;		start of header detected - read a block
;
read2:	call	rchead
	jz	read7			;on time out reading header
	call	rcbody		;read body of block
	jz	read7		;on time out
;
;	check that checksum and block number are correct
;
	cmp	al,dl
	jnz	read4			;on checksum error
	mov	al,rcvblk		;received block
	mov	dl,byte ptr block	;expected block
	cmp	al,dl
	js	read5			;on dup block
	jnz	read6			;on missing block
	mov	rspnse,ack		;set successful
	msdos	dispky,aster		;send asterisk to console
	inc	block			;expect next block
	msdos	seqwrt,fcb
	jmp	read1			;do another block
;
;	checksum error
;
read4:	call	dspchk			;diagnode checksum problem
	mov	rspnse,nak		;redo this block
	jmp	read1
;
;	sent a duplicate block - ignore but acknowledge as ok
;
read5:	msdos	dispky,dupblk
	mov	rspnse,ack
	jmp	read1
;
;	we have missed a block
;
;	can only happen if a nak gets corrupted to an ack
;
read6:	msdos	dispky,seqerr
	jmp	read9		;not recoverable
;
;	timed out
;
read7:	msdos	dispky,timout
	jmp	read10
;
;	transfer completed successfully
;
read8:	msdos	dispky,tcomp
	mov	al,ack
	call	sendrm
	jmp	read10
;
;	transfer cancelled
;
read9:	msdos	dispky,cancel	
read10:	msdos	closfl,fcb
	ret
read11:	msdos	dispky,abandn
	jmp	read10
;
;		transfer header for block
;
rchead:	mov	dx,1		;checksum (includes starting soh)
	push	dx
	call	recvhx		;block number
	jz	rch1		;on time out
	mov	rcvblk,al	;save received block number
	pop	dx
	add	dl,al		;add to checksum
	push	dx
	mov	bx,offset blokno+10
	call	hex
	msdos	dispky,blokno
	call	recvhx		;complement (one's) of block number
	pop	dx
	add	dl,al
	mov	ah,0
	sahf			;set not zero on return
	ret
rch1:	pop	dx
	ret
;
;		transfer bosy of block
;
;		return zero if time out
;
rcbody:	mov	bx,offset fbuff
	mov	ax,80h
rcb1:	push	ax		;save loop counter
	push	bx		;and byte pointer
	push	dx		;and checksum
	call	recvhx		;get byte 
	jz	rcb2		;on time out
	pop	dx
	pop	bx
	mov	ds:[bx],al	;put byte in buffer
	inc	bx
	add	dl,al		;add to checksum
	pop	ax
	dec	ax
	jnz	rcb1		;on more to go
	push	dx
	call	recvhx		;read checksum
	jz	rcb2
	pop	dx
	mov	ah,0
	sahf			;set non-zero
rcb2:	ret
;
;	send a block from fbuff
;
sendbl:	mov	al,soh
	call	sendhx
	mov	al,byte ptr block
	call	sendhx
	mov	al,byte ptr block
	not	al
	call	sendhx		;send one's complement of block number
	mov	bx,offset fbuff
	mov	ax,80h
	mov	dx,0
sendb1:	push	ax		;save loop counter
	mov	al,ds:[bx]	;get next byte
	add	dx,ax		;add to checksum
	push	dx
	inc	bx
	push	bx
	call	sendhx		;send character
	pop	bx
	pop	dx
	pop	ax
	dec	ax
	jnz	sendb1
	mov	al,dl		;send checksum
	call	sendhx
	ret
;
;	send a file with optional wait for prompt
;
readfw:	call	filenm
	msdos	openfl,fcb
	mov	byte ptr fcb+20h,0
	cmp	al,0
	jz	readf1
	msdos	dispky,nofile
	ret
readf1:	msdos	setdma,fbuff
;
;	send characters until cr
;
readf2:	msdos	seqrd,fcb
	mov	cx,80h
	mov	bx,offset fbuff
	cmp	al,0
	jz	readf3
	cmp	al,3
	jz	readf3
	ret		;on end of file
readf3:	mov	al,ds:[bx]	;get next character
	push	bx
	push	cx
	call	sendrm		;send it
	call	recvrm		;look for echo of character
	jz	readfa
	mov	dl,al
	msdos1	writky
readfa:	msdos	dirky,0ffh	
	jz	readfb		;on no local keyboard 
	cmp	al,commode
	jz	readf7		;on exit from fw command
	call	sendrm
readfb:	pop	cx
	pop	bx
	mov	al,ds:[bx]	;reload character
;	
	and	al,7fh		;ignore top bit
	cmp	al,9
	jnz	readfe		;on not tab
;
;	tab sent - wait for line to stop returning spaces
;
	push	bx
	push	cx
readfc:	call	recvwt 
	jz	readfd		;on have stopped arriving
	mov	dl,al
	msdos1	writky		;echo to local keyboard
	jmp	readfc
readfd:	pop	cx
	pop	bx
readfe:	cmp	al,cr
	jnz	readf6
;
;	wait for prompt from other end
;
	mov	al,prompt
	cmp	al,0
	jz	readf6	;on no wait required
	push	bx
	push	cx
readf4:	msdos	dirky,0ffh
	jz	readfg
	cmp	al,commode
	jz	readf7
	call	sendrm
readfg:	call recvwt	;wait for character
	jz	readf4	;on nothing read
	push	ax
	mov	dl,al
	msdos1	writky
	pop	ax
	cmp	al,prompt
	jnz	readf4
readf5:	pop	cx
	pop	bx
;
readf6:	inc	bx
	dec	cx
	jnz	readf3
	jmp	readf2
readf7:	pop	cx
	pop	bx
	ret
;
;	receive from line, possibly in hex
;
recvhx:	mov	al,hexfl
	cmp	al,0
	jz	recv1		;on not hex
	call	recvwt
	jz	recv2		;ON TIME OUT
	call	dechx
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	ax,ax
	push	ax
	call	recvwt
	jz	recv2
	call	dechx	
	pop	dx
	add	ax,dx
	cmp	ax,256		;set not zero
	ret
recv1:	call	recvwt
recv2:	ret
;
;	convert to binary from hex
;
dechx:	mov	ah,0
	cmp	al,'A'
	js	dechx1
	sub	ax,'A'-10
	ret
dechx1:	sub	ax,'0'
	ret
;
;	send character in al in hex or binary
;
sendhx:	push	ax
	mov	al,hexfl
	cmp	al,0
	jz	sendh2	;on not send in hex
	pop	ax
	mov	bx,offset hexwrk
	call	hex
	mov	al,hexwrk
	call	sendrm
	mov	al,hexwrk+1
	call	sendrm
	ret
sendh2:	pop	ax
	call	sendrm
	ret
;
;	receive from line with time out
;
recvwt:	mov	bx,wait 	;set wait time
recvw1:	dec	bx
	jz	recvw2		;on time out
	push	bx
	call	recvrm
	pop	bx
	jz	recvw1		;on no character
recvw2:	ret	
;
;	read in a file name parse
;
filenm:	msdos	dispky,filep	;ask for file name
	msdos	buffky,inbuff	;read file name
	mov	al,0		;set parse defaults
	mov	si,offset inbuff+2
	mov	di,offset fcb
	msdos1	parse
	ret	
;
;	convert byte in al to hex
;	bx points to first of two bytes to store value in
;
hex:	push	ax
	shr	al,1
	shr	al,1
	shr	al,1
	shr	al,1
	call	hex1
	pop	ax
	and	al,0fh
	call	hex1
	ret
hex1:	cmp	al,10
	js	hex2
	add	al,'A'-10
	jmp	hex3
hex2:	add	al,'0'
hex3:	mov	ds:[bx],al
	inc	bx
	ret
;
;	checksum error
;
dspchk:	push	dx
	mov	bx,offset recvd1
	call	hex
	msdos	dispky,recvd
	pop	ax
	mov	bx,offset expec1
	call	hex
	msdos	dispky,expec
	msdos	dispky,chkerr
;
;	display buffer read
;
	mov	di,offset fbuff
	mov	bx,offset fprint+2
	mov	cl,80h
dspc1:	mov	al,ds:[di]
	call	hex
	inc	bx
	inc	bx
	inc	di
	dec	cl
	jnz	dspc1
	msdos	dispky,fprint
	ret
code	ends
	end	start

