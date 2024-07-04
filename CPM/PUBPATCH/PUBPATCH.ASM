.title 'pubpatch.asm 4-13-84   (c) 1984 Plu*Perfect Systems'
.settim 16:19:00
.setdat 11/18/84
.setwid 90
.setlen 60

;11/18/84 minor change to published DDJ version to produce
;relocatable object file, to be relocated using HXRLOAD

.remark ~
			 -- PUBPATCH --

A CP/M 2.2 BDOS modification to support the PUBlic filetype. 

	  --------------------------------------------
	   Copyright (c) 1984 -- All rights reserved.

		       Plu*Perfect Systems
			 P. O. Box 1494
		       Idyllwild CA 92349
	  --------------------------------------------

Attribute bit 2 of a filename signifies a PUBlic file,
accessible by its unambiguous filename from all user
numbers.

PUBlic files are not accessible via the usual ambiguous
filenames (e.g. *.* or ABC.D?F), to prevent unintentional
erasure	and avoid directory clutter.

Directory entries for PUBlic files are, however, accessible
via ambiguous filenames by using the BDOS search-for-first,
search-for-next functions with a '?' in the drive-byte of the
fcb.  Extended versions of SD and DISK7 displays PUBlic files.

To erase a PUBlic file, use "ERA unambiguous-filename". Or use
DISK7.  Or change it to a private file and then erase with a
wildcard erase command.

The PUBLIC.COM utility is available to make files either
PUBlic or private and to list the current PUBlic files.

If another utility is used to set the PUBlic attribute bit,
avoid creating multiple files with the same name on the same
drive, unless all of them are private. (PUBLIC.COM checks
for this situation and prevents a conflict.)
	
The REName command removes all attributes, so RENaming a
PUBlic file will make it private, R/W, DIR in its original
user number.
~
.page
.remark ~
		       --- TO INSTALL ---

1a. Determine the BIOSBASE address of your system in memory
    by subtracting 3 from the warm-boot address in memory:
	DDT
	L0
	subtract 3 ==> BIOSBASE address
1b. Subtract 1600H to determine the CCPBASE_MEMORY address.
1c. Assemble PUBPATCH for these addresses.

    Either: use CDL's MACROIII assembler:

	MACROIII PUBPATCH A:DHK

    Or:	convert the pseudo-opcodes to your assembler's 
	pseudo-ops and assemble into a HEX file.
	e.g. 	.loc	==>	org
		=    	==>	set
		=\	==>	????, 	etc.

2. Create a system image for the SYSGEN operation.
   There are two ways to get the image:

   a. Either use SYSGEN to extract a system image from a disk
      in the usual manner --
 	SYSGEN
	source drive? A
	destination drive? <CR>
     	SAVE pp ORIG.SYS.    Use pp=50 pages or so to get
				the entire BIOS.

   b. Or generate a new system --
	MOVCPM ss *		where ss=64 for a 64K system,
	SAVE pp ORIG.SYS	or whatever you are running.

3. Find the base address of the Command Processor in the image
	DDT ORIG.SYS
   Look for the command processor at 980H:
   You recognize it by two JMP instructions, followed by
   the command buffer (containing a Digital Research
   copyright notice, in the case of the original CCP):
	L980
	D980
   Call that address CCPBASE_IMAGE (normally 980H).
   (If you don't find it, you have a non-standard system, and
   your user's manual should have a memory map.  See, e.g.,
   the Compupro Disk 1 Controller manual, sec. 6.4).

4. Calculate the offset needed to cause the PUBPATCH.HEX file to
   load on top of the BDOS image.  'offset' will satisfy:

	CCPBASE_IMAGE = CCPBASE_MEMORY + offset

5. Create a new system image containing the patch:

	DDT ORIG.SYS
	IPUBPATCH.HEX
	Roffset
	G0
	SAVE pp NEWSYS.SYS

6. Finally, put the new system on a FLOPPY disk for testing:
	
	SYSGEN NEWSYS.SYS
	<CR>
	destination_drive


	------------------------------------------------
	Code also corrects a CP/M 2.2 bug that caused
	Rename, Set Attribute, and Delete File functions
	to return 0 status on success instead of 0,1,2,3 
	per CP/M 2.2 Installation Guide.
	------------------------------------------------
~
	.page
	.phex

bdosbase = .

;	Internal BDOS locations:
;
FINDNXT	=	bdosbase+072Dh
NXENTRY	=	bdosbase+0605h
CKFILPOS =	bdosbase+05F5h
MOREFLS	=	bdosbase+057Fh
FCB2HL	=	bdosbase+055Eh
SAMEXT	=	bdosbase+0707h
STFILPOS =	bdosbase+05FEh
SETSTAT	=	bdosbase+0301h
SAVEFCB	=	bdosbase+0DD9h
COUNTER	=	bdosbase+0DD8h
FILEPOS	=	bdosbase+0DEAh
STATUS	=	bdosbase+0345h
FNDSTAT	=	bdosbase+0DD4h
CHKWPRT	=	bdosbase+0554h
CHKROFL	=	bdosbase+0544h
FINDFST	=	bdosbase+0718h
SETFILE	=	bdosbase+066bh
DIRWRITE =	bdosbase+05c6h
CKFILPOS =	bdosbase+05f5h
DELFILE	=	bdosbase+0cd7h
EXTMASK	=	bdosbase+0dc5h
CLOSEFLG =	bdosbase+0dd2h
RDWRTFLG =	bdosbase+0dd3h
GETEMPTY =	bdosbase+0924h
OPENIT1	=	bdosbase+085ah
STRDATA	=	bdosbase+04bbh
SETSTAT	=	bdosbase+0301h
IOERR1	=	bdosbase+0305h
SETS2B7	=	bdosbase+0578h
;
	.page
	.loc	FINDNXT

fnxt0:	lxi	h,0
	shld	pflag	;initialize PUBlic & wildcard flags
	mov	c,h	;0
	call	NXENTRY
	call	CKFILPOS
	jrz	nomatch		;if done
	lhld	SAVEFCB
	xchg			;de=user-fcb
	ldax	d
	cpi	0E5h	;if Getempty fn  wants first
	jrz	fnxt1	;..deleted file slot in directory
	push	d
	call	MOREFLS
	pop	d
	jrnc	nomatch		;if no more files
;
fnxt1:	call	FCB2HL		;hl=directory fcb
	lda	COUNTER
	mov	b,a		;b=count
	mvi	c,0		;c=byte #
	ora	a		;COUNTER=0 ==> Search fn
	jrz	matched		;..so match every entry
;
fnxt2:	mov	a,c		;get byte #
	cpi	13
	jrz	nxtbyte		;omit S1 byte
	ldax	d		;get user-fcb char
	cpi	'?'
	jrnz	fnxt3
	sta	qflag	;flag wildcard
	jr	nxtbyt
;
fnxt3:	mov	a,m	;get directory-fcb char
	cpi	0E5h	;check for blank/deleted file
	mov	a,c	;A = byte #
	jrz	chkext	;if a deleted file, omit user # check
	ora	a
	jrnz	chkext	;or if not user # byte
	inx	h	;else check for PUBlic file
	inx	h
	bit	7,m	;..at attribute bit 2
	dcx	h
	dcx	h
	jrz	chkext	;if not PUBlic, match on user #
;
; the file is PUBlic
; -- but is BDOS looking for an empty directory slot?
	mov	a,b	;if COUNTER=1, this is a Getempty request
	dcr	a	;
	jrz	fnxt0	;..so go to next file
	sta	pflag	;else flag the file PUBlic,
	jr	nxtbyt	;..and omit matching user #
;	
chkext:	cpi	12	; (A=byte #)
	ldax	d
	jrz	tstext	;extent byte(#12) is special case
	sub	m	;compare the characters
	ani	07fh	;..excluding attribute bits
	jr	extdone
tstext:	push	b	;check for same extent
	mov	c,m
	call	SAMEXT
	pop	b
extdone:jrnz	fnxt0	;if mismatch, get next file
;
nxtbyt:	inx	d	;chars match, bump to next byte
	inx	h
	inr	c	;byte # ++
	djnz	fnxt2	;count--
;
; here if-- COUNTER > 1 and filenames match
; 
;Test for PUBlic file and wild-card combination:
;			;flags initially = 0, but
pflag = .+1		;  = COUNTER-1 if PUBlic
qflag = .+2		;  = '?'(3Fh) if '?' in fcb+1...
	lxi	h,.-.
	mov	a,l		;if file is PUBlic
	ana	h		;..and there's a wildcard
				;(3Fh & 1...n) ==> NZ
	jrnz	fnxt0		;..get next directory entry
;
; here if--
;     (a) non-PUBlic filenames match, 
;  or (b) find-all-files (searchfirst/searchnext functions
;	  with drive byte = '?')
;  or (c) delete unambiguous PUBlic-filename.
;
matched:jmp	PATCH1
;
nomatch:call	STFILPOS
	mov	a,l		;l=0ffh
	jmp	SETSTAT
;
	.page
;	the ERASE FILE routine -- in a new location
;
;	Routine is split, with remainder stuffed
;	into free bytes at end of BDOS.
;
ERAFILE:call	CHKWPRT	;write-protect aborts
	mvi	c,12
	call	FINDFST
eraf1:	call	CKFILPOS ;check for 'E5' case
	rz
	call	CHKROFL	;read-only file aborts
	call	FCB2HL
	jmp	PATCH2
LAST1 = .	;must be <= bdosbase+07BEh
;
;


;Remainder of ERASE routine goes at end of BDOS
;
	.loc	bdosbase+0deeh	;there are 18 spare bytes

PATCH2:
eraf2:	mvi	m,0E5h	;install erase mark
	mvi	c,0
	call	SETFILE	;clear file's space in bitmap
	call	DIRWRITE ;write directory sector
eraf3:	call	FINDNXT	;look for next entry
	jmp	eraf1
LAST2 = .	;must be <= bdosbase+0E00h
;
	.page
;rewrite last part of bdos GETNEXT routine to gain space
;
	.LOC	bdosbase+0971h
;
gnxt0:	jrz	gnxt1	;( overlaying jz gtnext1)
	mov	b,a	;extent byte
	lda	EXTMASK
	ana	b
	lxi	h,CLOSEFLG
	ana	m
	jrz	gnxt2	;must read next extent
gnxt3:	call	OPENIT1	;open current extent
gnxt4:	call	STRDATA ;update rec#, extent#,...
	xra	a
jsetst:	jmp	SETSTAT
;
;	have overflowed normal extent, check s2 byte
gnxt1:	inx	h	;shorter code, replacing
	inx	h	;lxi b,2 & dad b
	inr	m	;bump s2 byte
	mov	a,m
	ani	0fh
	jrz	gnxt5	;error if too many extents
gnxt2:	mvi	c,15	;open the next extent
	call	FINDFST
	call	CKFILPOS
	jrnz	gnxt3
	lda	RDWRTFLG ;no extant extent
	inr	a	;..if reading, can't open one
	jrz	gnxt5
	call	GETEMPTY ;writing, so get next free entry
	call	CKFILPOS
	jrnz	gnxt4	;and if no error, save the data
gnxt5:	call	IOERR1	;set error &
	jmp	SETS2B7	;..don't close file
;	
;
;	use space (14 bytes) for fragment from FINDNXT routine:
;
PATCH1:	lda	FILEPOS
	ani	03h
	sta	STATUS	;save its directory buffer index
	lxi	h,FNDSTAT
;
	.remark ~
The original CP/M 2.2 code removed below is erroneous, and
causes BDOS Erasefile, Renamefile, Setattribute functions
to return A=0 on success rather than the directory index
(0,1,2 or 3) specified in the Interface Guide.

;;	mov	a,m
;;	ral
;;	rnc
;;	xra	a
~
;
	mov	m,a	;also save it for use
	ret		;..by Erase,Rename,Set Attribute fns
;
LAST3 = .	;must be <= bdosbase+09BCh
;
;
;patch ERAFILE reference to its new location
;
	.loc	(DELFILE+3)
	CALL	ERAFILE
;
	.end
