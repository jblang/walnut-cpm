;RUNFILE.ASM	Ver 1.0		27 Nov 1983
;
;Phil Cary, W5TYF
;Mesilla Valley RCP/M, Las Cruces, NM
;(505) 522-8856
;
;The following is an application of the technique described in CPMCHAIN.DOC
;
;The purpose of this program is to aid the user who is unfamiliar with your
;system in running the message program.  It gives a message reminding the
;user of the correct filename, and then chains to that program.
;
;Since there are at least four major message systems(CBBS, MINICBBS, RBBS,
;and MINIRBBS) plus some others like my own MSGSYS, this will take the guess
;work out of the user's attempts to run your message system.  
;
;To use this aid, fill in the name of the message program you are using below,
;change the message texts as desired, change the defdrv/usr equates as
;required and assemble.  Then rename the COM file to one of the above and
;copy it into the drive/area of your message system.  Rename the COM file
;again to another possibility from above and copy again.  Continue until you
;think you have covered all bases.
;
;BDOS functions

wrcon:	equ	2		;console output
printf:	equ	9		;print string
bdos:   equ     5		;bdos call
openf:  equ     15		;open file
readf:  equ     20		;read sequential
dmaf:   equ     26		;set dma address
usrset:	equ	32		;set user area

;Misc equates

cr:	equ	0dh
lf:	equ	0ah

	org	100h

	jmp	start		;skip over following data

;############################################################################

;CHANGE THE FOLLOWING TO MEET YOUR REQUIREMENTS

defdrv:	equ	'F'-'@'		;drive containing message system COM file
defusr:	equ	0		;user area  "        "      "     "    "

runfil:	db	'MSGSYS  '	;filename for your message system COM file,
; eight chars-->>^^^^^^^^<<	;...MINICBBS, RBBS, MINICBBS, CBBS, etc.

;Remind the user of the name of your message program

opnmsg:	db	cr,lf
	db	'Message program here is MSGSYS',cr,lf
	db	'Chaining to MSGSYS.....',cr,lf,'$'

errmsg:	db	cr,lf
	db	'Chain error! Warmbooting.  Enter MSGSYS please.$'

;#############################################################################

start:	mvi	c,8		;first move the filename above into fcb below
	lxi	h,runfil	;location of filename
	lxi	d,fcb+1		;destination
	call	move		; 8 bytes

	mvi 	c,usrset	;Set up set user function
	mvi 	e,defusr	;desired user area
	call 	bdos		;..do it

	lxi	d,opnmsg	;print the reminder
	call	prnmsg

	lhld 	bdos+1		;start of BDOS address
	lxi 	b,-codeln	;subtract length of code to be moved
	dad 	b		;..to make room at top of TPA
	shld 	jmpr+1          ;fill in jump address below
	push 	h               ;save code address for RET
	xchg			;..and use to calculate final location of fcb
	lxi 	h,fcb-loader	;distance between start of loader and fcb
	dad 	d   		;add address computed above
	shld 	fcbr+1          ;and put in LXI below for eventual file read
	push 	h               ;save FCB destination address
	lxi 	h,loader	;point to start of loader
	mvi 	c,codeln	;length of loader
	call 	move		;destination still in DE from above
	pop 	d               ;recover FCB address( saved as push h above )
	mvi 	c,openf
	call 	bdos       	;open file
	inr 	a		
	jz 	error           ;signal if error
	pop 	h		;recover start of loader
	sphl			;point stack to top of
	push 	h          	;start of loader and save address again
	lxi 	h,100h          ;point to start of TPA for set DMA below
	ret			;to address on stack which is start of loader

loader:	push 	h		;DMA address at start of TPA
	xchg			;put in DE for DMA set
	mvi 	c,dmaf
	call 	bdos		;set DMA address

fcbr:	lxi 	d,$-$		;address of moved fcb filled in earlier
	mvi 	c,readf		
	call 	bdos		;read next record
	ora 	a		;check for end of file
	jnz 	100h            ;EOF -> start TPA
	pop 	h		;recover
	lxi 	d,128		;...and bump DMA address
	dad 	d
             
jmpr:   jmp 	$-$             ;jump to loader address filled in earlier

fcb:	db      defdrv          ;drive code
	ds      8		;room for filename
	db      'COM'           ;file type
	db      0,0,0,0,0,0	;Zero out remaining 24 bytes of fcb
	db      0,0,0,0,0,0
	db	0,0,0,0,0,0
	db	0,0,0,0,0,0

codeln: equ     $-loader

move:   ; c = # bytes, hl = source, de = destination
	mov 	a,m
	stax 	d
	inx  	h
	inx 	d
	dcr 	c
	jnz 	move
	ret

error:	lxi	d,errmsg
	call	prnmsg
	jmp	0

; Write a string of characters to the CRT
;
prnmsg:	mvi	c,printf
	call	bdos
	ret

	end

