NOTE on a SUBmit utility for ZCPR33 for long submit files.
	by Thomas E. Croley II, 2 July 1987
		* Corrects ZCPR33 error in submit processing for $$$.SUB
			files longer than can be accessed with a single
			directory entry.
		* Requires modification of ZCPR33 CCP !!!! (see below).
		* Requires modification of submit utility, SUB34 (see below).
		* XSUB not supported (I can't get XSUB to work properly with
			the unchanged SUB34 and ZCPR33 with short submit files
			yet, let alone the changed versions with long files!)

Submit file processing is (and has always been?) limited to short *.SUB file
lengths (fewer than 128 lines for disk allocation blocks of 2k, 256 lines
for disk allocation blocks of 4k, ...).  This is because ZCPR33 finds the
last record in the $$$.SUB file for processing and attempts to close the file
one record shorter to remove that record (command) from further processing;
to do this, ZCPR33 decrements the record count in the FCB for the file before
the close.  This works if there is only one directory entry in the directory
for the $$$.SUB file but it does not work if there are more.  If you use a
disk allocation block size of 2k, then one directory entry manages 16k (one
extent) of file space (=128 records) which, at one line per record in a
$$$.SUB file, limits your submit files (*.SUB) to 128 lines.  Likewise, a 4k
block size allows one directory entry to manage 32k (two extents) of file
space (=256 records), limiting submit files to 256 lines, and so forth.
Subsequently, for longer $$$.SUB files, ZCPR33 neither finds the end of file
correctly, nor is it able to reduce the file length past the point allocated
to an earlier directory entry.  The proper way around this is to implement
direct access ("random access" in old CP/M terminology) file manipulations to
find the end of the file and to keep track of the last record processed.  The
SUB utility must be modified also to use this method so that the last record
(first command) to be accessed by the CCP is pointed to in the file (the last
record of the file is used for this purpose here).  Also, file append (for
nesting of SUB commands), must properly maintain this pointer.

If you use wish to use long submit files, you must modify BOTH the SUB
command AND your ZCPR33 CCP by changing the following code as instructed
below.

The PENALTY is that it will slow submit file processing (hardly noticeable on
a RAM disk but may be significant on a floppy) since additional disk reads
and writes are required to find and maintain the next-command pointer.  These
reads and writes are not to sequential records on the disk since the pointer
is maintained in the last record of the file while commands are taken
successively toward the beginning.

The ADVANTAGE is that it will allow arbitrary length submit files for
processing.

IF YOU DO NOT MODIFY THE SUB COMMAND AND DO NOT MODIFY YOUR ZCPR33 CCP AS
FOLLOWS, THEN _BEWARE_ THAT SUMBIT FILES WITH LINE LENGTHS EXCEEDING THE ABOVE
LIMITS WILL NOT BE POSSIBLE _AND_ THERE IS NO ERROR MESSAGE NOR ERROR CHECKING
FOR THIS CONDITION WITHIN THE CCP.

NOTE also that XSUBZ must be modified to be consistent with the new file
structure for $$$.SUB.  I spent a day trying to modify XSUBZ12 but could not
get it to work.  There are difficulties already present in XSUBZ12 since I
could not get the unmodified XSUBZ to work correctly with the unmodified
SUB34 and ZCPR33.  These difficulties should be resolved before similar
changes are made to XSUBZ to allow direct access of records.  For now, XSUBZ
or XSUB cannot be used with the modified SUB routine (nor, apparently, with
the unmodified routine either).


MODIFICATIONS TO ZCPR33.Z80 (may require reconfiguration in Z33HDR.LIB to
		make room for the additional code on your machine)

Find the label "subfcr:" in ZCPR33.Z80 and add the code denoted by ";TEC" as
follows:

subfcr:
	defs	1		; Current record number
subfr:				;TEC
	defs	3		;TEC Random record no. (16 bits) + ovrflw byte

Find the label "readbuf:" in ZCPR33.Z80 and modify or add the code as denoted
by ";TEC" as follows:

readbuf:

	ld	a,(zexrunfl)	; Get ZEX-running flag
	or	a
	jp	nz,userinput	; If ZEX running, go directly to user input

	 if	subon		; If submit facility is enabled, check for it

	ld	a,(subflag)	; Test for submit file running
	or	a
	jr	z,shellinput	; If not, go on to possible shell input

	xor	a		; Log into user 0
	call	setuser
	call	defltdma	; Initialize DMA pointer
	ld	de,subfcb	; Point to submit file FCB
	call	open		; Try to open file
	jr	z,readbuf1	; Branch if open failed

;TEC	ld	hl,subfrc	; Point to record count in submit FCB
;TEC	ld	a,(hl)		; Get the number of records in file
;TEC	dec	a		; Reduce to number of last record
;TEC	ld	(subfcr),a	; ..and put into current record field
	ld	c,23h		;TEC "Compute file size" bdos call no.
	call	bdossave	;TEC DE still => subfcb; get file size in subfr
	ld	hl,(subfr)	;TEC Get file size
	dec	hl		;TEC Decrement to get last record no.
	ld	(subfr),hl	;TEC Replace in random record field
	ld	c,21h		;TEC "Read random" bdos call no.
	call	bdossave	;TEC DE still => subfcb; randm read last record
	ld	hl,(tbuff)	;TEC Get current "last record" from last record
	dec	hl		;TEC Point to next earlier record to read
	ld	(tbuff),hl	;TEC Save pointer in actual last record
	inc	c		;TEC ... and write back to file (c=22h)
	call	bdossave	;TEC DE still => subfcb; randm write last recrd
	ld	(subfr),hl	;TEC Now prepare to read new "last record"
	dec	c		;TEC (c=21h)
	call	bdossave	;TEC Random read record; DE still => subfcb
;TEC	call	read		; Attempt to read submit file
;TEC	jr	nz,readbuf1	; Branch if read failed

;TEC	dec	(hl)		; Reduce file record cound
;TEC	dec	hl		; Point to S2 byte of FCB (yes, this is req'd!)
;TEC	ld	(hl),a		; Stuff a zero in there (A=0 from call to READ)
	ld	(subfrc-1),a	;TEC Zero FCB S2 byte (A=0 from previous read)
	call	close		; Close the submit file one record smaller
	jr	z,readbuf1	; Branch if close failed

END of ZCPR33.Z80 changes...


MODIFICATIONS TO SUB34.Z80

Find the label "wrset:" in SUB34.Z80 and modify or add the code denoted by
";TEC" as follows:

;
;	SET UP THE $$$.SUB FILE
;	FOR WRITING
;
wrset:
	call	print
	db	cr,lf,' Writing Command File to Disk',0

	ld	e,0		; Set user 0
	ld	c,20h
	call	bdos

	ld	de,subfcb
	ld	c,openf
	call	bdos		; Open the file
	inc	a		; Check cpm return
	jp	z,none1		; None exists already
;
;	$$$.SUB EXISTS, SO SET
;	FCB TO APPEND TO IT
;

	ld	de,subfcb	;TEC Point to submit file FCB
	ld	c,23h		;TEC "Compute file size" bdos call no.
	call	bdos		;TEC Get file size in subfr
	ld	hl,(subfr)	;TEC Get file size
	dec	hl		;TEC Decrement to get last record no.
	ld	(oldfsz),hl	;TEC Save present file last record no.
	ld	(subfr),hl	;TEC Replace in random record field
	ld	de,subfcb	;TEC Point to submit file FCB again
	ld	c,21h		;TEC "Read random" bdos call no.
	call	bdos		;TEC Random read last record
	ld	hl,(tbuf)	;TEC Get current "last record" pointer
	dec	hl		;TEC Decr. to point to last unprocessed record
	ld	(subfr),hl	;TEC Now read "last record"
	ld	de,subfcb	;TEC Point to submit file FCB again
	ld	c,21h		;TEC "Read random" bdos call no.
	call	bdos		;TEC Random read record
	ld	de,subfcb	;TEC Prepare for sequential (re)write to update
	ld	c,15h		;TEC ... DOS pointers for further writes
	call	bdos		;TEC Write same info back to set DOS pointers
;TEC	ld	a,(subfcb+fcbrc) ; Get record count
;TEC	ld	(subfcb+fcbnr),a ; Make next record
	ret
oldfsz:	ds	2		;TEC space for "old file size"
;
;	COME HERE WHEN NO $$$.SUB EXISTS
;
none1:
	xor	a		;TEC
	ld	(oldfsz),a	;TEC Zero "old file size" since it did'nt exist
	ld	(oldfsz+1),a	;TEC
	ld	de,subfcb
	ld	c,makef
	call	bdos
	inc	a
	jp	z,nomake	; 0ffh=can't create file
	ret

Find the label "close:" in SUB34.Z80 and add the code denoted by ";TEC" as
follows:

;
;	$$$.SUB IS WRITTEN, CLOSE THE FILE
;
close:
	ld	de,subfcb	;TEC
	ld	c,24h		;TEC Set random record number for record after
	call	bdos		;TEC ... last write
	ld	hl,(subfr)	;TEC Get rndm record no. for last record write
	ld	(tbuf),hl	;TEC Place in write buffer
	ld	de,(oldfsz)	;TEC DE = old last record number
	xor	a		;TEC Clear carry bit
	sbc	hl,de		;TEC Is new last record number >= old?
	jr	nc,nfeok	;TEC New file end O.K.
	ld	(subfr),de	;TEC ... else use old last record number
nfeok:	ld	de,subfcb	;TEC
	ld	c,22h		;TEC "Write random" bdos call no.
	call	bdos		;TEC Write current record no. to last record.
	ld	de,subfcb
	ld	c,closef
	jp	bdos

Find the label "subfcb:" in SUB34.Z80 and modify or add the code denoted by
";TEC" as follows:

;
;
;	FCB FOR $$$.SUB
;
subfcb:
	db	1		; Drive specifier (a selected)
	db	'$$$     '
subtyp:
	db	'SUB'
	dw	0,0,0,0		; Initialize rest of fcb
	dw	0,0,0,0
;TEC	dw	0,0,0,0
	dw	0,0		;TEC
	db	0		;TEC
subfr:	dw	0		;TEC Direct-access 16-bit record number
	db	0		;TEC Overflow byte
;
clbuf:	ds	2		; Ptr to command line buffer
fremem:	ds	2		; Ptr to free memory area
;
	end

END of SUB34.Z80 changes...


END OF NOTE on a SUBmit utility for ZCPR33 for long submit files.
