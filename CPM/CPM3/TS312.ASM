Title 'Time stamp   vers: 03.11  date: 10/11/83  time: 22:37:17'

;************************
;			*
;	timestamp3	*
;			*
; version, date & time	*
;	stamp		*
;    for cp/m+		*
;			*
;************************

;	by	dick lieber - Bridgeport RCP/M+ (Chicago) 312-326-4392
;	based on a program by Eric Forbes
;
;	version 3.12	fix leap year bug  rcl
;	version 3.11	fix wrong data for July & Nov in months table
;	version 3.1	don't abort if file not found so a new file
;			can be created with editor.
;
;	if assembled as a transient program
;
;	A>ts3 name.typ [o]
;
;	Will increment the minor version number & date/time stamp the file
;	name.typ if the strings:
;
;		"vers:"
;		"time:"
;		"date:"
;
;	are found in the first 128 bytes of the file.  Be sure
;	to allow enough blank space after each string for the 
;	information shown!
;
;	[o] is an option:
;
;		where o=N	to leave old version number
;		      o=M	to increment major version number
;				and zero minor version number
;
;	if assembled as a patch and SIDed onto an editor
;	the same functions will take place automatically
;	before the actual edit:
;
;	A>edit name.typ [o]
;
;	an additional option is added with the patched version:
;
;	[z] will cause the timestamp patch to not modify the
;	file at all
;
;	To attach the patched version of timestamp:
;
;	A>mac ts3		<= assemble "patched" version
;	CP/M MACRO ASSEM 2.0
;	2B2E
;	024H USE FACTOR
;	END OF ASSEMBLY

;	A>sid ws.com		<= load your editor
;	CP/M 3 SID - Version 3.0
;	NEXT MSZE  PC  END
;	2700 2700 0100 CEFF
;	#rts3.hex		<= load ts3 patch
;	NEXT MSZE  PC  END
;	2B2E 2B2E 0100 CEF	<= note the NEXT address
;	#wwsts.com,100,2b2e	<= save patched editpor
;	0055h record(s) written.
;	#^C

;	Use and enjoy you new editor that automatically
;	updates version etc.
;

maclib	z80		;as supplied with cp/m+

no:	equ	0
yes:	equ	not no

patched: equ	yes 	;yes to attach to an editor
			;no to make transient command

opt$del: equ	'['	;option delimiter
recsiz:	equ	128		;record length
cr:	equ	0dh
lf:	equ	0ah
bell:	equ	7


	if 	patched	;into an editor
;
;	these equates define interface of 
;	this program to the editor
;
;	values show are for Wordmaster

endasm:	equ	2700h	;where this program will live

oldjmp:	equ	269h	;used to restore the jump at the
			;start of the assembler

jmpadd:	equ	0100h	;address of the JP (C3h) used to get
			;to this program

assemb:	equ	0100h	;address to return to when finished
			;updating the file
;
;	this will patch the hook from the editor 
;	to this porgram.  it gets restored automatically
;	when when version info has been updated
;
	org	jmpadd + 1
	dw	endasm		;patch hook to this program

	else

endasm	equ	100h	;org if stand alone
fcb	equ	5ch	;work at default fcb cause
			;we don't care if it's altered
	endif

	org	endasm		;end of assembler or tpa

start:	lxi	d,crlf
	mvi	c,prstr		;new line
	call	bdos
;
;	check version
;
	mvi	c,getvers
	call	bdos
	lxi	d,bad$ver$mess
	mov	a,h
	cpi	1		;check if mp/m
	jrz	version$ok
	mov	a,l
	cpi	31h
	jc	exit		;below cp/m+
version$ok:

	if 	patched	;into an editor
;
;	copy name to timestamp's fcb
;
	lxi	h,5ch	;default fcb set up by ccp
	lxi	d,fcb
	lxi	b,15	;length of drive & name
	ldir		;move it
	endif		;patched
;
;	copy password to dma
;
	lda	53h	;get password length
	ora	a	;set flags
	jrz	no$password
	mov	c,a	;get length of password
	mvi	b,0
	lhld	51h	;get password address (source)
	lxi	d,buff	;(dest)
	ldir		;move password to dma
			;password must be in dma
			;on open call if file is
			;read protected
no$password:
	mvi	a,' '	;no option
	sta	option	
	lda	80h	;get command tail length
	mov	c,a
	mvi	b,0
	lxi	h,81h	;start of tail
	dad	b	;point to end of tail
	mvi	a,opt$del
	ccdr		;search for delimeter
	jpo	option$done
	inx h! inx h	;point to option byte
	mov	a,m
	sta	option
	cpi	'N'		;keep old version option
	jrz	option$done
	cpi	'M'		;major version update option
	jrz	option$done

	if	patched
	cpi	'Z'		;no change at all option
	mvi	a,0		;no abort
	lxi	d,as$is$msg
	jz	exit
	endif	;patched

	lxi	d,bad$opt$msg
	mvi	a,0ffh		;abort flag
	jmp	exit
option$done:
;
;	open file
;
	lxi	d,buff
	mvi	c,setdma
	call	bdos
	lxi	d,fcb
	mvi	c,15
	call	bdos
	lxi	d,nofile	;report if can't open and
	inr	a
	if 	patched
	mvi	a,0		;reset abort flag
	else
	mvi	a,0ffh		;set abort flag
	endif
	jz	exit
;
;	zero record number
;
	lxi	h,fcb+33
	mvi	b,2
rn$loop:
	mvi	m,0
	dcr	b
	inx	h
	jrnz	rn$loop

	lxi	d,fcb
	mvi	c,readran	;read record 1st record (0)
	call	bdos

	lxi	d,verstx
	call	find		;update version
	lxi	d,novers
	cnz	print
	cz	versn

	lxi	d,datetx
	call	find		;update date
	lxi	d,nodate
	cnz	print
	cz	date

	lxi	d,timetx
	call	find		;update time
	lxi	d,notime
	cnz	print
	cz	time
;
;	write record back into file and exit to editor or CP/M
;
	mvi	c,writeran	;random write
	lxi	d,fcb
	call	bdos

	mvi	c,closef
	lxi	d,fcb
	call	bdos

	lxi	d,done$msg

exit:	call	print		;print error message and exit.
	ora	a		;a=ff means abort after message
	jnz	0		;abort if error

	if 	patched	;into editor
;
;	Restore the editor to it's original condition and jump to it
;
	lxi	h,oldjmp	;restore value in hl
	shld	jmpadd+1	;restore old jump address
	jmp	assemb		;jump to the assembler

	else

	ret	;to cp/m+

	endif	;patched
;
;	print a string (de) and file name
;
print:	push	psw
	mvi	c,prstr
	call	bdos
	lxi	h,fcb+1
	lxi	d,prtnam
	lxi	b,11
	ldir
	lxi	d,prtfil
	mvi	c,prstr
	call	bdos
	pop	psw
	ret
;
;Increment the version number
;
versn:	inx	h		;hl --> units of major change
	lda	option		;is a major change requested
	cpi	'M'
	cz	twoinc		;inc major change number
	jrz	zeromn		;zero minor change number
	cpi	'N'		;do not change version if
	rz			;'n' option given
	inx	h
	inx	h
	inx	h		;hl --> units of vers no.

twoinc:	push	psw		;increment a 2 digit field
	push	h
	mvi	b,2
	mvi	a,'9'+1		;hl --> units position
two1:	inr	m
	cmp	m
	jrnz	twox		;exit if not > 9 ascii
	mvi	m,'0'		;else zero the units
	dcx	h		;and inc the tens
	djnz	two1
twox:	pop	h
	pop	psw
	ret

zeromn:	inx	h		;zero minor version
	inx	h
	mvi	m,'0'	;used when major changes
	inx	h
	mvi	m,'0'
	ret
;
;	insert new date into buffer at hl
;
date:
	call	get$clock
	push	h
	lhld	datepb		;get days since 1/1/78
	call	cnvday		;convert to month,day, year
	pop	h
	lda	months
	call	putbcd

	mvi	m,'/'
	inx	h

	lda	days
	call	putbcd

	mvi	m,'/'
	inx	h

	lda	years
	call	putbcd
	ret
;
;	convert bcd in a to two ascii charcters at hl
;
putbcd:
	push	psw
	rrc ! rrc ! rrc ! rrc	;get high nibble
	call	putnib
	pop	psw
	call	putnib
	ret
;
;	make ascii & put into buffer
;
putnib:	ani	0fh
	ori	'0'
	mov	m,a
	inx	h		;next buffer location
	ret
;
;	insert time into buffer at hl
;
time:
	call	get$clock
	lxi	d,datepb+2	;point to seconds byte
	sta	datepb+4	;put seconds in date parm block
	mvi	b,2
time1:	ldax	d
	inx	d
	call	putbcd		;insert hh:mm:
	mvi	m,':'
	inx	h
	djnz	time1
	ldax	d
	call	putbcd		;insert seconds
	ret
;
;	get time from cp/m+
;
get$clock:
	push	h
;
;	this bios call is needed because the bdos rdtime
;	function doesn't call bios to update the clock data
;	in the scb
;
	mvi	c,drbios	;direct bios call
	lxi	d,biospb	;read time function
	call	bdos
	mvi	c,rdtime	;get date/time
	lxi	d,datepb	;where to put date
	call	bdos
	pop	h
	ret

biospb:	db	26	;time function
	db	0	;value for A 

;
;	find the first character of string in de (V, D or T)
;
find:	lxi	h,buff		;de = compare string
	lxi	b,recsiz	;limit search to 1 rec
trynxt:	ldax	d		;get 1st char to find
	ccir
	rpo			;ret nz set = not found
;
;	see if the rest of the string compares equal. Retry
;	until we get to the end of the buffer
;
	push	b
	push	d
	mvi	b,5		;compare next 5 chars
find2:	inx	d
	ldax	d
	cmp	m
	jrnz	tryagn		;try for another string
	inx	h
	djnz	find2		;keep comparing til b = 0
	pop	d
	pop	b
	ret			;ret with z set

tryagn:	pop	d		;Found the 1st character, but
	pop	b		;there was a bad compare in
	jr	trynxt		;the next 6 characters.

;************************************************
;						*
;	cnvdate					*
;						*
;	routine to convert cp/m or mp/m date 	*
;	from days since 1/1/78 to month, day &	*
;	year.					*
;						*
;						*
;************************************************
;
;
year	equ	365	;leap year gets adjusted for
;
;	count up until goal days exceeded
;
cnvday:
	shld	goaldays	;save as goal to reach
	mvi	a,1		;initial values
	sta	days
	sta	months		;month counter (jan is one)

	lxi	h,0
	shld	dayscnt		;start at zero
	lxi	d,year		;one year of days
	
	mvi	a,78h		;the first year (bcd)
	sta	years		;save year value
;
;	it's much eaiser to detect leap years in binary
;
	mvi	a,78		;1st year (binary)
	sta	years$bin	;for leap year determination
yearloop:
	lhld	dayscnt
	dad	d		;trial add one year of days
	call	ckleap
	jrnz	no$leap
	inx	h		;was a leap year
no$leap:
	call	ckgoal
	jnc	yeardone	;year over flowed
	lda	years
	cmc			;daa screws up if carry is set
	inr	a		;add one to the year count
	daa			;make bcd
	sta	years		;save years
	jz	done		;exact match
	shld	dayscnt		;year was ok to add
	lxi	h,years$bin
	inr	m
	jr	yearloop
;	
yeardone:
;
;	see if this is a leap year and adjust Feb if required
;
	call	ckleap
	lxi	h,feb		;point to feburary
	mvi	m,28
	jrnz	not$leap	;no, don't adjust feb
	inr	m		;make 29
not$leap:
	lxi	d,montbl	;point to month table
monthloop:
	lhld	dayscnt
	ldax	d		;get month
	mov	c,a
	mvi	b,0
	dad	b
	call	ckgoal
	jnc	monthdone
	push	psw
	cmc
	lda	months
	inr	a		;count to next month
	daa
	sta	months
	pop	psw
	jrz	done		;exact (on the first of the month)
	shld	dayscnt
	inx	d		;point to next month
	jr	monthloop
monthdone:
;
;	continue counting until day of month attained
;
	lhld	dayscnt
daysloop:
	inx	h		;add one day
	call	ckgoal
	jnc	done
	cmc			;zero carry bit so daa is screwed up
	lda	days
	inr	a
	daa
	sta	days
	jr	daysloop
done:	ret			;leave module

	
;
;	compare count (in hl) with goal
;	C if count < goal
;	Z if count = goal
;
ckgoal:	push	d
	lded	goaldays
	mov	a,h
	cmp	d
	jrnz	ckend
	mov	a,l
	cmp	e
ckend:	pop	d
	ret
;
;	check for leap year
;	return z if leap year
;
ckleap:
	lda	years$bin	;get years
	ani	03h
	ret

montbl:
	db	31	;jan
feb:	db	28	;feb
	db	31	;mar
	db	30	;apr
	db	31	;may
	db	30	;jun
	db	31	;jul
	db	31	;aug
	db	30	;sep
	db	31	;oct
	db	30	;nov
	db	31	;dec
;	dseg
;
;	these values are the output of this module
;
days:	  ds	1	;counts days in month (bcd)
months:	  ds	1	;counts months in year (bcd)
years:    ds	1	;counts years (starts at 78) (bcd)
;
;	cnvdays ram area
;
years$bin: ds	1	;years in binary (for leap year calc)

dayscnt:  ds	2	;counts days
goaldays: ds	2	;days since 1/1/78

done$msg:
	db	'Version Update$'

nofile:	db	'File not found$'

novers:	db	'No '
verstx:	db	'vers: '
	db	'in$'

nodate:	db	'No '
datetx:	db	'date: '	
	db	'in$'

notime:	db	'No ' 
timetx:	db	'time: '	
	db	'in$'

crlf:	db	cr,lf,'$'


	if 	patched		;transient version uses def fcb
fcb:	db	0
	rept	35
	db	0
	endm
	endif

option:	ds	1		;saved option byte
buff:	rept	recsiz		;fill with blanks so password
	db	' '		;is set in blanks
	endm

prtfil:	db	' File:- '
prtnam:	db	'           ',cr,lf,lf,'$'
datepb: ds	5		;date parameter block
 
bad$ver$mess:
	db	'Requires CP/M version 3', cr, lf, '$'
bad$opt$msg:
	db	'Bad timestamp option.',cr,lf
	db	'Options are:',cr,lf
	db	9,'[N] for no version update.',cr,lf
	db	9,'[M] to increment major version.',cr,lf
	if	patched
	db	9,'[Z] to not alter version or timestamping',cr,lf
	endif
	db	'$'
	if	patched
as$is$msg:
	db	'Version & time unchanged.',cr,lf,'$'
	endif
;
;	bdos functions  (cp/m 3.0)
;
bdos	equ	5
sysrst	equ	0	;warmstart
rdcon	equ	1	;wait for & read console character
wrcon	equ	2	;write to console
rdaux	equ	3	;wait for & read aux
wraux	equ	4	;write to aux
list	equ	5	;write to list device
drcon	equ	6	;direct console i/o character or
;					    ff=read
;					    fe=status only
;					    fd=wait for input	
auxinst	equ	7	;aux in status
auxotst	equ	8	;aux out status
prstr	equ	9	;de=string
rdbuff	equ	10	;de=buffer   max, count, c1,c2,... 
const	equ	11	;console in status
getvers	equ	12	;return version in HL
dskrst	equ	13	;reset disk system
seldsk	equ	14	;select disk 0=a:
openf	equ	15	;open file de=fcb
closef	equ	16	;close file
searchf	equ	17	;search for first occurance
searchn	equ	18	;find next occurance
delete	equ	19	;delete file
read	equ	20	;read sequential
write	equ	21	;write sequential
make	equ	22	;make file
rename	equ	23	;rename file new name at fcb+16
loginv	equ	24	;return login vector in hl
curdsk	equ	25	;return current disk in a
setdma	equ	26	;set new dma
getalv	equ	27	;get allocation vector address
wrtprt	equ	28	;write protect current disk
rovec	equ	29	;get r/o vector in hl
setflag	equ	30	;set file attributes
getdpb	equ	31	;return dpb address
user	equ	32	;get/set user ff=get
readran	equ	33	;read random record
writeran equ	34	;write random record
flsize	equ	35	;compute file size
setran	equ	36	;set random record from last sequential read
rstdrv	equ	37	;reset drive
accdrv	equ	38	;mpm only - access drive
freedrv equ	39	;mpm only - free drive
wrran0	equ	40	;fill a random record with 0
tstwrt	equ	41	;mpm only - test and write
lock	equ	42	;mpm only - lock record
unlock	equ	43	;mpm only - unlock record	
multi	equ	44	;set multi sector count
errmd	equ	45	;set bdos error mode
freesp	equ	46	;return free space in 1st 3 bytes of dma
chain	equ	47	;chain to pgm name in def buff (80h)
flush	equ	48	;flush buffers
scb	equ	49	;get set scb de=.scb pb   db offset
;						  db ffh set byte
;						     feh set word
;						     00h get
;					  	  dw value
drbios	equ	50	;direct bios call de=.bios pb  db bios func #
;						       db = A
;						       dw =BC
;						       dw =DE
;						       dw =HL
ldovl	equ	59	;load overlay
calrsx	equ	60	;call rsx  de=.rsx pb	db rsx func #
;						db # of word parameters
;						dw p1
;						dw p2
frblks	equ	98	;free temporary blocks
trunf	equ	99	;truncate file
setdirl	equ	100	;set driectory label
dirl	equ	101	;return directory label data e=drive
rdstamp	equ	102	;read file stamps & password mode
wrxfcb	equ	103
setdate	equ	104
rdtime	equ	105
defpwd	equ	106	;set def password
retsn	equ	107	;return serial number address
retcode	equ	108	;get/set return code
conmode	equ	109	;get/set console mode
delim	equ	110	;get/set string output delimiter
prtblk	equ	111	;print block  de = ccb	dw=address
;						dw=length
lstblk	equ	112	;list block
parse	equ	152	;parse file name   de=pfcb   dw=input addr
;						     dw=fcb addr
	end

length
lstblk	equ	112	;list block
parse	equ	152	;parse file name   de=pfcb   dw=input a