; NEWBACK - DISK DIRECTORY AND BACKUP PROGRAM - 11/20/83
;
;		    COPYRIGHT 1980, GARY YOUNG
;
; THE PRIMARY PURPOSE OF THIS PROGRAM IS TO BACKUP HARD DISKS ON TO
; MULTIPLE FLOPPIES.  FIRST, IT EXTRACTS THE DIRECTORIES FROM ALL OF
; THE HARD DISKS, SORTS BY TYPE AND FILE NAME, AND PRINTS A CONSOLIDATED
; DIRECTORY.  THEN IT DELETES DUPLICATE FILES FROM THE CONSOLIDATED
; DIRECTORY, DELETES UNWANTED TYPES (PRN, BAK, ETC), AND UNWANTED
; FILES TO CREATE A LIST OF FILES TO BACKUP.  THESE ARE COPIED TO
; MULTIPLE FLOPPIES AS NEEDED WHILE PRODUCING AN INDEX OF WHAT FILES
; ARE ON EACH DISKETTE.  RESTART CAPABILITY IS PROVIDED TO BEGIN THE
; BACKUP AT ANY FILE.
;					- Gary Young
;
;=======================================================================
;
; 11/20/83  Reformatted for standard display.  Saved 14k source code by
;   v2.4    removing superfluous spaces in favor of tabs.
;					- Irv Hoff
;
; 08/20/83  1 - Clock for Sierra Data Sciences SBC-100 BIOS
;   v2.3    2 - Option to have no Clock this allows more space in memory
;		 for Directory entries
;	    3 - Backup all CP/M 2.2 user areas
;	    4 - Fixed bug that caused crashed system when nothing to
;		 backup			- Alex Soya
;
; 07/01/83  Added features to mark files that have been backed up on the
;   v2.2    floppy bye eather setting the 'T3' byte of the FCB for Mo-
;	    ular computers or setting the 'F4' byte for other computers.
;	    This is done at assembly time by setting the MOLEC equate
;	    for either.			- Ron Stevenson
;
; 06/23/83  Corrected problem in code for backing up to copying to drive
;   v2.1    'P'.  Original code stripped off too many bits which would
;	    not allow program to see drive 'P' no matter what.  Cleaned
;	    up some of the code.	- Ron Stevenson
;
; 06/13/83  Added code at begining for setting up the drive to backup
;   v2.0    from as well as to.  You are now prompted as to which drives
;	    you want backup and then which drive to put the stuff on.
;					- Ron Stevenson
;
;=======================================================================
;
	ORG	100H
;
;
	JMP	START
;
	DB	'COPYRIGHT 1980, G. YOUNG, INC.'
;
YES:	EQU	0FFH
NO:	EQU	0
;
MOLEC:	EQU	YES		;yes for molecular, no for others
CLOCK:	EQU	NO		;yes if clock is installed.
SIERRA: EQU	NO		;yes if sierra data sc. sbc-100 board
COMPUT: EQU	NO		;yes if computime clock board
USERS:	EQU	YES		;yes if option to back up all user areas
;
;
;
RECSIZ:	EQU	12		;record size as follows
				; type	 = 3 bytes
				; file	 = 8 bytes
				; diskid = 1 bytes
NOSKIP:	EQU	6			;number of files in skip list
SKPTYP:	DB     'PRNHEXSYMBAK$$$TMP'     ;files to not back up
IDSIZE:	EQU	1		;id now means a:, b:, c:, etc
LINSPG:	EQU	60		;lines per page
RECLIN:	EQU	4		;entries per line
;....
;
;
;***********************************************************************
;
;
START:	LXI	SP,STACK+80
	LXI	H,RAM		;set up table address
	SHLD	TABADDR
	LXI	H,0000H
	SHLD	TABCNT
	XRA	A		;the table refers to the remaining area
	STA	ABORT		;..of ram to hold as many directory en-
	STA	EOF		;.. tries as possible
	STA	GOTONE		;flag shows no file found yet if zero
;
START1: LXI	D,SIGNON	;print signon message
	CALL	OUTPUT
	LXI	D,DRIVMSG	;ask for the drive letters to backup
	CALL	QUESTION
	CPI	0		;ck to see if anything was added
	JZ	START1		;if not start over
	ADI	1
	STA	MAX1
;
	 IF	USERS
	STA	MAX3		;used to restore max1 later
	 ENDIF			;USERS
;
	MOV	B,A		;setup count for move
	LXI	H,INREC 	;data to move
	LXI	D,DRIVES	;where to put the date
	CALL	MOVE
	XCHG
	DCR	B		;correct the count befor cking
;
STRT:	MOV	A,M		;get a drive char
	CPI	'Q'             ;ck it for good char
	JP	START1		;no good if positive
	INX	H		;point to next
	DCR	B		;dec count
	JNZ	STRT		;loop
	MVI	M,'$'           ;store end-of-string char at end
	LXI	D,BKUPMSG	;ask for the drive letter to store it to
	CALL	QUESTION
	CPI	1
	JNZ	START1		;if no input then exit program
	LDA	INREC		;get drive letter to store to
	STA	BACKUPDRV
;
START2: LXI	D,CORRMSG	;verify all data is correct
	CALL	OUTPUT
	LXI	D,DRIVES	;get drives to backup
	CALL	OUT1		;output drive letter chain
	LXI	D,CORRMSG1
	CALL	OUT1
	LDA	BACKUPDRV	;get drive to backup to back again
	MOV	E,A
	MVI	C,CONOUT
	CALL	BDOS		;output drive to backup to out
	LXI	D,CORRY$N	;get correct message
	CALL	QUESTION	;and get responce
	CPI	1
	JNZ	START2
	LDA	INREC		;get answer
	CPI	'Y'
	JNZ	START1
;
	 IF	USERS
	LXI	D,USRMSG	;ask if all users to back up
	CALL	QUESTION
	CPI	1
	JNZ	START1		;thats what you get for a wrong answer
	LDA	INREC		;get answer
	CPI	'Y'             ;do all user areas
	JNZ	NOUSRS		;
	MVI	A,0		;set user 0 meaning do them all
	JMP	DONUSR
;
NOUSRS:	MVI	A,17		;set user 17 meaning do only what we are
;
DONUSR:	STA	CURUSER
	 ENDIF			;USERS
;
	 IF	NOT CLOCK
MSG1:	LXI	D,DATEMSG	;get current date for reports
	CALL	QUESTION	;print msg and get reply
	CPI	8		;8 char must have been entered
	JNZ	MSG1		;repeat question if not
	LXI	H,INREC 	;move date from inrec
	 ENDIF			;NOT CLOCK
;
	 IF	CLOCK
	CALL	GETDATE 	;get date from clock board
	LXI	H,DATETIME+1
	 ENDIF			;CLOCK
;
	MVI	B,8		;move the date to a hold area
	LXI	D,DATE		;to "date"
	CALL	MOVE
;
	 IF	USERS
REPEAT: LDA	CURUSER 	;get user number
	CPI	16		;check if we do them all
	JNC	GOON		;no users greater than 15
	MOV	E,A		;valid user so set it.
	MVI	C,32		;set user function
	CALL	BDOS		;tell cp/m to do some work !
	LXI	D,USRNOMS	;send user id message
	CALL	OUTPUT
	LDA	CURUSER
	CALL	CONVRT
	MOV	A,B		;send id to console
	STA	USERID
	MOV	A,C
	STA	USERID+1
	LXI	D,USERID
	CALL	OUT1
	 ENDIF			;USERS
;
GOON:	CALL	EXTRACT 	;get directory entries
	LDA	ABORT		;see if too many entries for memory size
	ORA	A		;should be zero to be ok
	JZ	NOMORE
	LXI	D,TABFULL	;report will not be complete
	CALL	OUTPUT		;memory full error
;
NOMORE: LDA	GOTONE		;no file found fix
	ORA	A
	JNZ	ALLOK
	LXI	D,NOFILS	;no files message
	CALL	OUTPUT
	JMP	FINISHED	;as nothing to do we are done
;
ALLOK:	CALL	SORT		;sort by type, file name and disk id
	MVI	A,RECSIZ	;setup to remove duplicate entries
	STA	COMPSIZE	;compare on all char
	CALL	KILLDUPS	;remove duplicate entries
	CALL	REPORT		;print all entries
	MVI	A,11		;remove files that are on multiple disks
	STA	COMPSIZE
	CALL	KILLDUPS
	CALL	SELECT		;restrict the files to backup
;
MSG3:	LXI	D,BACKQUS	;ask if you want backup function
	CALL	QUESTION
	CPI	1
	JNZ	MSG3
	LDA	INREC
	CPI	'N'
	JZ	FINISHED
	CPI	'Y'
	JNZ	MSG3
	CALL	BACKUP		;backup those files reported on
;
FINISHED:
	MVI	C,0
;
	 IF	USERS
	LDA	CURUSER
	INR	A
	CPI	16		;;get user and see if another one to do
	JNC	DONE		;all done so lets go
	STA	CURUSER 	;else do next user
	LDA	MAX3		;restore drive pointer
	STA	MAX1		;so we do all drives in next user area.
	LXI	H,RAM		;restore all the required pointers
	SHLD	TABADDR 	;and things.
	LXI	H,0000H
	SHLD	TABCNT
	XRA	A
	STA	ABORT
	STA	EOF
	STA	GOTONE
	JMP	REPEAT		;until done
	 ENDIF			;USERS
;
DONE:	JMP	BDOS		;reset and return to cpm
;
; the extract routine scans all the drives in the drive table when com-
; plete, it asks for the next drive id when the hard disk is up, it will
; not ask for the drive id but will automatically scan the three hard
; disks and finish without ever asking for the drive id.
;
; the dummyfcb sets up a skeleton to read all files on the directory
;
DUMMYFCB:
	DB	0,'????????????',0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;
EXTRACT:LXI	H,DRIVES	;get address of the drive table
	SHLD	ADDR1		;to scan
;	MVI	A,NODRV+1	;set up counter for the number to scan
;	STA	MAX1
;
NEXTDRV:LDA	MAX1		;see if there are more drives to scan
	DCR	A
	STA	MAX1		;return when all have been scanned
	RZ
	LHLD	ADDR1		;get address of drive table
	MOV	A,M		;get drive character
	STA	RDISK
	ANI	1FH		;convert a=1...p=16
	STA	DUMMYFCB	;set in dr of dummyfcb
	INX	H		;set for next read of drive table
	SHLD	ADDR1
	LXI	D,DISKBUF	;set a dma address for directory entries
	MVI	C,1AH
	CALL	BDOS		;set dma
	LXI	D,DUMMYFCB	;get first directory entry
	MVI	C,11H
	CALL	BDOS		;get directory
	INR	A
	JZ	NEXTDRV 	;no more entries on this drive
	JMP	GETFCB		;extract data from fcb
;
NEXTFCB:LXI	D,DUMMYFCB	;get next entry after the first
	MVI	C,12H
	CALL	BDOS
	INR	A
	JZ	NEXTDRV 	;no more directories on this disk
;
GETFCB: LXI	D,32		;each entry is 32 bytes long
	LXI	H,DISKBUF	;directory record is in diskbuf
	CPI	1		;first entry in record???
	JZ	FORMREC 	;yes
	DAD	D		;add 32 to address in record
	CPI	2		;second entry in record???
	JZ	FORMREC
	DAD	D		;add 64 to address of record
	CPI	3		;third entry in record???
	JZ	FORMREC
	DAD	D		;add 96 to address of record
;
FORMREC:INX	H		;pass drive byte
	LXI	D,RFILE 	;move file name
	MVI	B,8		;move 8 characters
	CALL	MOVE
	LXI	D,8		;position past name to type
	DAD	D
	LXI	D,RTYPE 	;move type
	MVI	B,3		;move 3 characters
	CALL	MOVE
;
	 IF	NOT MOLEC
	PUSH	H		;save it for a min
	LXI	H,RFILE+4	;get file name to ck for 'F4' taged
	MOV	A,M
	POP	H		;get it back
	 ENDIF			;NOT MOLEC
;
	ANI	80H		;ck to see if we should backup this file
	JNZ	NEXTFCB 	;by checking 'T3' for molecular computers
				;or 'F4' for other computers
	INX	H		;position to the extent number
	INX	H
	INX	H
	MVI	A,0FFH
	STA	GOTONE		;set flag that we have at least on entry
	MOV	A,M		;get the extent
;	ORI	30H		;diagnostic display
;	STA	RDISK+1
;	LXI	D,RTYPE
;	CALL	OUTPUT
;	LDA	RDISK+1
;	ANI	0FH
	LXI	H,RTYPE 	;strip off the high bit set by
	MVI	B,11		;the version program
;
STRIP:	MOV	A,M
	ANI	07FH
	MOV	M,A
	INX	H
	DCR	B
	JNZ	STRIP
	LXI	H,RTYPE 	;skip over junk disk entries
	MVI	B,11		;containing nonprinting characters
;
NONPRNT:MOV	A,M
	CPI	20H		;any char less than a blank
	JC	NEXTFCB 	;go to next one if so
	INX	H
	DCR	B
	JNZ	NONPRNT
;
FIRSTEXT:
	LHLD	TABADDR 	;get memory table address
	LXI	D,RTYPE 	;get memory record address
	XCHG			;rtype (hl) to tabaddr (de)
	MVI	B,RECSIZ	;move recsiz bytes
	CALL	MOVE
	LHLD	TABADDR 	;increment for next entry
	LXI	D,RECSIZ	;recsiz bytes in record
	DAD	D
	SHLD	TABADDR 	;save new address
	MVI	M,1AH		;set an end-of-table indicator
	LHLD	TABCNT		;get record count
	INX	H
	SHLD	TABCNT		;increment record count
	LHLD	TABADDR 	;see if new address is greater
	XCHG			;than the top of tpa-128
	LHLD	BDOS+1		;hl=top...de=table+recsiz
	LXI	B,-128
	DAD	B		;subtract 128 from top
	CALL	COMPREG 	;compare register values
	JNC	NEXTFCB 	;there is room for more
	MVI	A,1		;no more room...abort now
	STA	ABORT
	RET
;.....
;
;
; the following routine is a bubble sort.  in pseudobasic this would be
; done as follows:  sort   addr1=bottom(ram)-recsiz (recsiz is count of
; bytes in one record)
;
;	MAX1=0
;LOOP1:	MAX1=MAX1+1
;	ADDR1=ADDR1+RECSIZ     (first time this would be the bottom)
;	IF MAX1>TABCNT-1 THEN TO TO SORTED
;	ADDR2=ADDR1
;	MAS2=MAX1
;LLOP2:	MAX2=MAX2+1
;	ADDR2=ADDR2+RECSIZ
;	IF MAX2>TABCNT THEN GO TO LOOP1
;	IF TABLE(ADDR1)<TABLE(ADDR2)THEN GO TO LOOP2
;	TEMP=TABLE(ADDR1)
;	TABLE(ADDR1)=TABLE(ADDR2)
;	TABLE(ADDR2)=TEMP
;	GO TO LOOP2
;
;SORTED:RETURN
;
; now that this logic is intuitively obvious, here'S THE NOT SO OBVIOUS
; code:
;
SORT:   LXI     D,SORTMSG       ;put out a message so the user does
        CALL    OUTPUT          ;not think this crashed while sorting
        LXI     H,0000          ;initialize count
        SHLD    MAX1            ;since it will decrement first
        LXI     D,-RECSIZ       ;subtract recsiz from the beginning
        LXI     H,RAM           ;of the table since it will add
        DAD     D               ;recsiz to it first
        SHLD    ADDR1
;
LOOP1:  LHLD    ADDR1           ;get the current address
        LXI     D,RECSIZ        ;increment it by recsiz
        DAD     D               ;past the next entry
        SHLD    ADDR1
        LHLD    MAX1            ;see if the count has reached the limit
        INX     H               ;increment the counter
        SHLD    MAX1
        XCHG                    ;move to de to compare to limit
        LHLD    TABCNT
        DCX     H               ; is max1 > tabcnt - 1 ???
        CALL    COMPREG         ;compare de (current count) to hl (tabcnt-1)
        JC      SORTED          ;finished when max1 > tabcnt-1
        LHLD    ADDR1           ;setup for the inner loop
        SHLD    ADDR2
        LHLD    MAX1
        SHLD    MAX2
;
LOOP2:  LHLD    ADDR2           ;start with one entry greater then
        LXI     D,RECSIZ        ;the outer loop and increment
        DAD     D               ;by recsiz each time past the next record
        SHLD    ADDR2           ;pointer to the current record
        LHLD    MAX2            ;likewise see if the counter for the
        INX     H
        SHLD    MAX2
        XCHG
        LHLD    TABCNT
        CALL    COMPREG
        JC      LOOP1           ;when finished, increment outer loop
        LHLD    ADDR2
        XCHG                    ;addr2 now in de
        LHLD    ADDR1
        CALL    COMPARE         ;compare strings pointed to by de/hl
        JNC     LOOP2           ;table(hl) < table (de)
;
;
; exchange the two entries via a temporary record
;
        LXI     D,TEMP
        LHLD    ADDR1
        MVI     B,RECSIZ
        CALL    MOVE            ;temp=table(addr1)
        XCHG                    ;addr1=destination
        LHLD    ADDR2           ;addr2=source
        CALL    MOVE            ;table(addr1)=table(addr2)
        XCHG                    ;addr2 = destination
        LXI     H,TEMP
        CALL    MOVE            ;table(addr2)=temp
        JMP     LOOP2
;.....
;
;
SORTED: RET                     ;finished sorting
;
;
; report prints the sorted consolidated directory entries.  linspg is
; the number of lines per page and reclin is the number of 20 byte en-
; tries per line.  each type begins on a new page.
;
REPORT: LHLD    TABCNT          ;set count of entries
        INX     H               ;plus one
        SHLD    LASTTYPE        ;init lasttype to invalid data
        SHLD    MAX1            ;to decrement first
        LXI     H,RAM-RECSIZ    ;set starting address
        SHLD    ADDR1
        CALL    HEADING
;
NEXTPRT:LHLD    ADDR1
        LXI     D,RECSIZ        ;set to add the receive length
        DAD     D
        SHLD    ADDR1
        LHLD    MAX1            ;decrement count to see when done
        DCX     H
        SHLD    MAX1
        LXI     D,0000          ;see if reached zero yet
        CALL    COMPREG
        JZ      TOPPAGE         ;go to top of next page
        LHLD    ADDR1           ;current type = last type?
        MVI     B,3             ;compare 3 characters
        LXI     D,LASTTYPE
        CALL    COMPARE
        JNZ     SKIP3           ;new type on new page
;
PRNTNOW:LDA     MAX2            ;decrement records per line
        DCR     A
        STA     MAX2
        JZ      NEWLINE         ;line full, go to new line
        CALL    FORMAT
        LXI     D,PRNTREC
        CALL    LIST
        JMP     NEXTPRT
;
SKIP3:  LDA     LINECNT
        DCR     A
        JZ      NEWPAGE
        DCR     A
        JZ      NEWPAGE
        DCR     A
        JZ      NEWPAGE
        STA     LINECNT
        LXI     D,CRLFLFLF
        CALL    LIST
        JMP     CHKTYPE
;
NEWPAGE:CALL    HEADING
;
CHKTYPE:LXI     D,LASTTYPE      ;set last type to current type
        LHLD    ADDR1
        MVI     B,3
        CALL    MOVE
;
SETCNT: MVI     A,RECLIN+1
        STA     MAX2
        JMP     PRNTNOW
;
NEWLINE:LXI     D,CRLF
        CALL    LIST
        LDA     LINECNT
        DCR     A
        STA     LINECNT
        JZ      NEWPAGE         ;page full
        JMP     SETCNT
;
TOPPAGE:RET
;.....
;
;
; the purpose of select is to create a final list of files to backup.
; since backing up 26 meg can be quite long, this reduces the list to
; only neccessary files.  it also allows a restart at any file.  it will
; delete duplicate file names (files on a: will be used since that is
; assumed to be the latest), and will delete the file types listed in
; the skip table.  then it will list each type and ask if you do want to
; back up all of this type (y), skip backing up of the entire type (n),
; or select certain files (s) to back up.  if the select option is
; chosen, each file name will be printed and you be asked to back up the
; file (y), ignore the file during the backup (n), or continue (c) to
; backup all of the remaining files within this type without asking any
; further names (used for restart).  after the list has been reduced, it
; will be listed before the backup actually begins.
;
KILLDUPS:
        LXI     H,RAM
        SHLD    ADDR1           ;set the start of the table
;
NEXTEQUAL:
	LHLD    ADDR1           ;check each entry against the next
        LXI     D,RECSIZ
        DAD     D
        SHLD    ADDR2
;
NEXTCHK:
	MOV     A,M             ;check for end of table
        CPI     1AH
        RZ
        XCHG
        LHLD    ADDR1           ;compare addr1 with addr2
        LDA     COMPSIZE
        MOV     B,A
        CALL    COMPARE
        JNZ     SAVELAST
        PUSH    H               ;save current position
        LHLD    ADDR2           ;set up for moving list
        SHLD    ADDR1           ;down one entry
        LXI     D,RECSIZ
        DAD     D               ;move third entry to the second
        SHLD    ADDR2		
        CALL    MOVELIST
        LHLD    TABCNT
        DCX     H
        SHLD    TABCNT
        POP     H               ;restore current position
        SHLD    ADDR1           ;now compare 1st & 3rd
        JMP     NEXTEQUAL
;
SAVELAST:
        LHLD    ADDR2           ;make new one the current one
        SHLD    ADDR1
        JMP     NEXTEQUAL       ;compare

SELECT: EQU     $
;
NOWSELECT:
        LXI     H,RAM-RECSIZ    ;initialize
        SHLD    ADDR1
        SHLD    LASTTYPE        ;make sure lasttype does not match
;
NEXTENTRY:
	LHLD    ADDR1           ;get next record in table
        LXI     D,RECSIZ
        DAD     D
        SHLD    ADDR1           ;increment table entry
;
CHKNEXT:
	MOV     A,M             ;check for the end of the table
        CPI     1AH             ;cntl-z is at end
        JZ      LISTBKUP        ;list the final table
        LXI     D,LASTTYPE      ;see if the current type is the
        LHLD    ADDR1           ;last type
        MVI     B,3
        CALL    COMPARE
        JZ      CHKSELECT       ;types match, check file select
        CALL    MOVE            ;types don'T MATCH, MAKE THE
				;last type = current type now
	MVI	C,NOSKIP+1	;see if the new type is in the
	LXI	D,SKPTYP	;list of file types to skip
	MVI	B,3
;
NEXTSKIP:
	DCR	C		;decrement no of files to skip
	JZ	FORMQUS 	;file is good
	LHLD	ADDR1
	CALL	COMPARE
	JZ	SKIPALLTYPE	;file was on the skip list
	INX	D		;increment to next skip file
	INX	D
	INX	D
	JMP	NEXTSKIP
;
FORMQUS:
	LXI	D,QTYPE 	;form the question about whether
	LHLD	ADDR1		;to skip this file type or not
	MVI	B,3		;move the file type to the
	CALL	MOVE		;question print line
	XRA	A
	STA	SELFLAG 	;reset the select flag
;
REASK1: LXI	D,QUEST1
	CALL	QUESTION	;ask the question about the type
	CPI	1		;one character response allowed
	JNZ	REASK1
	LDA	INREC		;get the response
	CPI	'N'
	JZ	SKIPALLTYPE
	CPI	'Y'
	JZ	SAVEALLTYPE
	CPI	'S'             ;s=select certain files from this
	JNZ	REASK1		;type
	MVI	A,1		;set the select flag
	STA	SELFLAG 	;to ask the next question
;
ASKFILE:LHLD	ADDR1		;format a question to ask if this
	LXI	D,QTYPE2	;particular file is to be saved
	MVI	B,3
	CALL	MOVE
	LXI	D,QFILE2	;move the file name to the question
	INX	H
	INX	H		;position past the file type
	INX	H		;in the table
	MVI	B,8
	CALL	MOVE		;move the name
	LXI	D,8		;position past name to the
	DAD	D		;disk id
	LXI	D,QDISK2	;move the disk id
	MVI	B,IDSIZE
	CALL	MOVE
;
REASK2: LXI	D,QUEST2	;ask the file question
	CALL	QUESTION
	CPI	1		;only a 1 char response allowed
	LDA	INREC
	JNZ	REASK2
	CPI	'C'             ;continue with the rest of the
	JZ	SAVEALLTYPE	;files within this type - restart
	CPI	'Y'             ;save this particular file
	JZ	NEXTENTRY
	CPI	'N'
	JNZ	REASK2
	LHLD	ADDR1		;shorten the list by one entry
	LXI	D,RECSIZ
	DAD	D
	SHLD	ADDR2		;skip the last one
	CALL	MOVELIST	;moves the list down from addr1
				;to addr2
	LHLD	ADDR1
	JMP	CHKNEXT 	;check next entry
;
CHKSELECT:
	LDA	SELFLAG 	;check the select flag
	ORA	A		;if not zero, ask the question
	JNZ	ASKFILE 	;about each file
	JMP	NEXTENTRY
;
SKIPALLTYPE:
	CALL	FINDTYPE	;find the next type not matching
	CALL	MOVELIST	;this one and move the list down
	LHLD	ADDR1
	JMP	CHKNEXT 	;to skip this type
;
SAVEALLTYPE:
	CALL	FINDTYPE	;save all of this type
	LHLD	ADDR2		;reset the address to the next
	SHLD	ADDR1		;type
	JMP	CHKNEXT
;
MOVELIST:
	LHLD	ADDR2		;move the table from addr2 down
	XCHG			;to addr1 thereby eliminating
	LHLD	ADDR1		;unwanted entries
;
MOVENEXT:
	LDAX	D		;and making more room for the
	MOV	M,A
	CPI	1AH
	RZ
;
	INX	H
	INX	D
	JMP	MOVENEXT
;
FINDTYPE:
	LHLD	ADDR1		;find the next entry
	SHLD	ADDR2		;with a type different
;
FINDIT: LHLD	ADDR2		;than the current type
	LXI	D,RECSIZ
	DAD	D
	SHLD	ADDR2
	MOV	A,M		;stop at end of the table
	CPI	1AH
	RZ
	XCHG
	LHLD	ADDR1
	MVI	B,3
	CALL	COMPARE
	RNZ
	JMP	FINDIT		;addr2 will have the address of
				;the next type when finished
LISTBKUP:
	SHLD	ADDR2		;save the end of the table for later
	LXI	H,RAM-RECSIZ
	SHLD	ADDR1
	CALL	HEADING2
NEXTONE:
	LHLD	ADDR1		;print the next table entry
	LXI	D,RECSIZ
	DAD	D
	SHLD	ADDR1		;increment to the next entry
	MOV	A,M		;check for the end of the
	CPI	1AH		;table
	RZ
	CALL	FORMAT		;format entry
	LXI	D,PRNTREC
	CALL	LIST		;print it
	LDA	MAX2		;see if more will fit on this line
	DCR	A
	STA	MAX2
	JZ	LINEFULL
	JMP	NEXTONE
;
LINEFULL:
	LXI	D,CRLF
	CALL	LIST
	LDA	LINECNT
	DCR	A
	STA	LINECNT
	JZ	PAGEFULL
	JMP	SETLINE
;
PAGEFULL:
	CALL	HEADING2
	MVI	A,LINSPG
	STA	LINECNT
;
SETLINE:
	MVI	A,RECLIN
	STA	MAX2
	JMP	NEXTONE
;
HEADING2:
	LXI	D,HEAD2
	CALL	LIST
	LXI	D,CRLF
	CALL	LIST
	MVI	A,LINSPG
	STA	LINECNT
	MVI	A,RECLIN
	STA	MAX2
	RET
;.....
;
;
; backup is used to backup the files in the created list.  it will not
; back up any file that will not fit on one disk entirely.  the files
; that it backs up will come from any of the hard disks, but not necces-
; sarily in disk order, but rather alphabetical file name order.  it
; will prompt for the floppy disk id and print a report showing the
; floppy id and the files copied for index.  ; if the file will not fit
; on a disk, it will be deleted from the disk, that disk closed and re-
; moved, and prompted for a new disk to receive the file.  blank 1024
; byte sectored disks should be used for best performance.  when one
; diskette is full, it will prompt for a new one so many diskettes can
; be used to backup the hard disks.  if it is necessary to abort during
; this process, use the restart capability provided in 'SELECT'.  the
; area for the disk buffer is all of ram from the end of the table to
; the start of 'BDOS'.
;
BACKUP: CALL	TOPOFFORM
	LHLD	ADDR2		;get the current end of table
	INX	H		;plus one for the start of the
	SHLD	ADDR3		;read/write buffer
	LXI	H,RAM		;set the address of the first entry
	SHLD	ADDR1
	LXI	D,RECSIZ	;set an address for the second entry
	DAD	D		;next entry = current + recsiz
	SHLD	ADDR2		;later, use movelist to move the list
				;down from addr2 to addr1 after each file
				;has been copied.  this is so that the
				;ram buffer will expand as the files are
				;copied so that copying will be faster.
	 IF	USERS
	LDA	CURUSER 	;we only mount if the user is 0 or
	CPI	17		;if no user option asked for
	JZ	OKMOUNT
	CPI	1		;if we do not do users
	JNC	NOMNT
	 ENDIF			;USERS
;
OKMOUNT:CALL	MOUNT
;
NOMNT:	JMP	PASSMOVE
;
NEXTFILE:
	CALL	MOVELIST
	INX	H		;new start of read/write buffer
	SHLD	ADDR3
	XRA	A		;reset the flag for files too big
	STA	TOOBIG		;to fit on one floppy
;
PASSMOVE;
	LXI	H,RAM		;the table shrinks so the current
				;entry is always at "ram" but the
				;read/write buffer grows
	MOV	A,M
	CPI	1AH
	JZ	DISMOUNT	;finished
;
FORMFCB:
	LXI	D,HDFCB 	;clear the fcb
	MVI	B,36
	XRA	A
;
ZEROFCB:
	STAX	D
	INX	D
	DCR	B
	JNZ	ZEROFCB
	LXI	H,RAM		;get address of table entry
	LXI	D,HDTYPE	;move in the type
	MVI	B,3
	CALL	MOVE
	INX	H
	INX	H		;position to name
	INX	H
	LXI	D,HDFILE	;move the file name
	MVI	B,8
	CALL	MOVE
	LXI	D,8
	DAD	D		;position to disk id, a:, b: etc
	MOV	A,M
	ANI	1FH		;convert a=1...p=16
	STA	HDFCB
	LXI	D,FPFCB 	;copy the hdfcb to the floppy fcb
	LXI	H,HDFCB
	MVI	B,36
	CALL	MOVE
	LDA	BACKUPDRV	;set the receiving floppy drive number
	ANI	1FH		;convert floppy drive to number
	STA	FPFCB
	LXI	D,HDFCB 	;open the hd file
	MVI	C,0FH
	CALL	BDOS		;open the input file
	INR	A
	JZ	NOTFOUND
	LXI	D,FPFCB 	;delete the file on floppy if it
	MVI	C,13H		;exists
	CALL	BDOS
	LXI	D,FPFCB 	;create the file on floppy
	MVI	C,16H
	CALL	BDOS		;make file
	INR	A
	JZ	DISKFULL
	LXI	H,RAM
	CALL	FORMAT
	LXI	D,PRNTREC
	CALL	OUTPUT
;
COPYLOOP:
	CALL	LOADBUFF	;load memory with file
	CALL	WRITEBUF		;write memory file
	LDA	EOF			;display the status
	ADI	30H
	MOV	E,A			;console output
	MVI	C,2
	CALL	BDOS
	LDA	EOF
	CPI	1
	JZ	ENDOFFILE
	CPI	2
	JZ	DISKFULL
	JMP	COPYLOOP
;
ENDOFFILE:
	LXI	D,FPFCB 	;close floppy file
	MVI	C,10H
	CALL	BDOS		;close
;
	 IF	 MOLEC
	LXI	H,HDFCB+11	;tag 'T3' byte to indicate backuped
	 ENDIF			;MOLEC
;
	 IF	NOT MOLEC
	LXI	H,HDFCB+4	;tag 'F4' byte to indicate backuped
	 ENDIF			;NOT MOLEC

	MOV	A,M		;get 'T3' byte for taging on molecular
				;or 'F4' byte for other computers
	ORI	80H		;set the bit
	MOV	M,A		;put it back in hdfcb
	LXI	D,HDFCB 	;setup for attribute setting
	MVI	C,1EH
	CALL	BDOS		;write it on the disk
	LXI	H,RAM
	CALL	PRINTFILE	;write file name on index list
	JMP	NEXTFILE
;
DISKFULL:
	LXI	D,FPFCB
	MVI	C,13H		;delete file on floppy
	CALL	BDOS
	LDA	TOOBIG		;is this the second floppy
	ORA	A		;it has tried to copy to?
	JZ	FIRSTTRY	;no, first floppy. retry
	LXI	D,BIGMSG	;yes, 2nd floppy. send message
	CALL	LIST		;warning that this file cannot
	LXI	H,RAM
	CALL	FORMAT		;be backed up with this program
	LXI	D,PRNTREC
	CALL	LIST		;print the file name also
	CALL	MOUNT
	JMP	NEXTFILE
;
FIRSTTRY:
	INR	A		;set indicator that it has tried
	STA	TOOBIG		;once already to copy it
	CALL	MOUNT		;get new disk
	JMP	FORMFCB
;
NOTFOUND:
	LXI    H,RAM
	CALL	FORMAT
	LXI	D,NFMSG
	CALL	OUTPUT
	LXI	D,PRNTREC
	CALL	OUTPUT
	RET
;.....
;
;
DISMOUNT:
	CALL   BELL
;
	 IF	USERS
	LDA	CURUSER 	;only dismount if we are all done
	CPI	15
	JC	 NODISMS
	 ENDIF			;USERS
;
	LXI	D,DMNTMSG	;dismount floppy
	CALL	QUESTION
	CALL	TOPOFFORM
;
NODISMS:RET
;.....
;
;
; assorted routines
;
PRINTFILE:
	CALL	FORMAT
	LXI	D,PRNTREC	;print the file entry
	CALL	LIST
	LDA	MAX2
	DCR	A
	STA	MAX2		;entries per line counter
	RNZ
	LXI	D,CRLF		;go to new line
	CALL	LIST
	MVI	A,RECLIN
	STA	MAX2
	RET
;.....
;
;
HEADING3:
	LXI	D,CRLFLFLF	;index heading not at top of form
	CALL	LIST
	LXI	D,IDISKNO	;move the disk id no to heading
	LXI	H,VOLSER
	MVI	B,3
	CALL	MOVE
	LXI	D,IDATE
	LXI	H,DATE
	MVI	B,8
	CALL	MOVE
	LXI	D,INDEX
	CALL	LIST
	LXI	D,CRLF
	CALL	LIST
	MVI	A,RECLIN
	STA	MAX2
	MVI	A,LINSPG
	STA	LINECNT
	RET
;.....
;
;
TOPOFFORM:
	MVI	E,0CH		;position printer to top of form
	MVI	C,5
	JMP	BDOS
;.....
;
;
MOUNT:	CALL	BELL
	LXI	D,MNTMSG
	CALL	QUESTION
	CPI	3
	JNZ	MOUNT
	LXI	H,INREC
	LXI	D,ENDLIT
	MVI	B,3
	CALL	COMPARE
	JZ	FINISHED
	LXI	D,VOLSER
	LXI	H,INREC
	MVI	B,3
	CALL	MOVE		;move volser id to volser
	MVI	C,0DH		;do a system reset to  change disks
	CALL	BDOS
;
ERA:	LXI	D,ERASE
	CALL	QUESTION
	CPI	1
	JNZ	ERA
	LDA	INREC
	CPI	'N'
	JZ	NOERA
	CPI	'Y'
	JNZ	ERA
	LDA	BACKUPDRV
	ANI	1FH
	STA	DUMMYFCB
	MVI	C,13H
	LXI	D,DUMMYFCB
	CALL	BDOS		;delete all files on floppy
;
NOERA:	CALL	HEADING3
	LXI	D,FPFCB 	;clear the fcb to create a file name
	MVI	B,36
	XRA	A
;
CLRFCB: STAX	D
	INX	D
	DCR	B
	JNZ	CLRFCB
	LDA	BACKUPDRV	;set up the drive as the backup
	ANI	1FH		;convert floppy drive to number
	STA	FPFCB
	LXI	H,DATE		;create a null file with the date as
	LXI	D,FPFCB+1	;the file name and the 3 digit
	MVI	B,8
	CALL	MOVE
	LXI	H,VOLSER	;3 digit volser as the file type
	LXI	D,FPFCB+9
	MVI	B,3		;this file will be used to identify
	CALL	MOVE		; the disk and mark the date
	LXI	D,FPFCB
	MVI	C,16H		;create the file
	CALL	BDOS
	INR	A
	JZ	MOUNT		;disk full?
	LXI	D,FPFCB
	MVI	C,10H		;close the file
	CALL	BDOS
	RET
;.....
;
;
LOADBUFF:
	LXI	H,0000		;memory with the file as possible
	SHLD	MAX1
	LHLD	ADDR3		;new top of table +2
	SHLD	TEMP
	XRA	A
	STA	EOF		;clear eof flag
;
LOADNEXT:
	LHLD	TEMP
	XCHG			;set dma address
	MVI	C,1AH
	CALL	BDOS
	LXI	D,HDFCB 	;read hard disk
	MVI	C,14H
	CALL	BDOS
	ORA	A
	JNZ	HDEOF		;eof?
	LHLD	MAX1
	INX	H		;increment record count
	SHLD	MAX1
	LHLD	TEMP		;see if next record would exceed the
	LXI	D,128		;tpa area
	DAD	D
	SHLD	TEMP
	DAD	D		;will the next record overwrite bdos?
	XCHG
	LHLD	BDOS+1		;find the top of memory
	CALL	COMPREG 	;compare registers
	RC			;return if memory already full
	JMP	LOADNEXT	;get another record
;
HDEOF:	MVI	A,1		;set file eof
	STA	EOF
	RET
;.....
;
;
BELL:	MVI	C,9
	LXI	D,MSG
	CALL	BDOS
;
BEEP:	MVI	C,5		;bell on printer
	MVI	E,07H
	CALL	BDOS
	MVI	C,2		;07h on crt
	MVI	E,07H
	CALL	BDOS
	MVI	C,0BH
	CALL	BDOS		;get console status
	ORA	A
	JZ	BEEP
	MVI	C,01
	CALL	BDOS		;get the dummy char
	RET
;.....
;
;
MSG:	DB	0DH,0AH,0AH,'PRESS ANY KEY TO CONTINUE'
	DB	0DH,0AH,0AH,'$'
;
WRITEBUF:
	LHLD	ADDR3
	SHLD	TEMP
	LHLD	MAX1		;allow for files that have no
	LXI	D,0000		;records such as restart
	CALL	COMPREG
	RZ
;
WRITENEXT:
	LHLD	TEMP
	XCHG			;set dma address
	MVI	C,1AH
	CALL	BDOS
	LXI	D,FPFCB
	MVI	C,15H		;write sequential
	CALL	BDOS
	ORA	A
	JNZ	FPFULL		;floppy disk full
	LHLD	MAX1		;decrease record count
	DCX	H
	SHLD	MAX1
	LXI	D,0000		;check for no more to write
	CALL	COMPREG
	RZ
	LHLD	TEMP
	LXI	D,128		;increment write address
	DAD	D
	SHLD	TEMP
	JMP	WRITENEXT
;
FPFULL: MVI	A,2		;full diskette
	STA	EOF
	RET
;.....
;
;
FORMAT: LXI	D,PRNTYPE	;format the entry from the table
	MVI	B,3		;format to the print format
	CALL	MOVE		;the table address is assummed to be
	LXI	D,3		;in hl. first move the type
	DAD	D		;now position to the file name
	LXI	D,PRNFILE	;move the file name
	MVI	B,8
	CALL	MOVE
	LXI	D,8		;position to the disk id
	DAD	D
	LXI	D,PRNTREC	;move the disk id to the line
	MVI	B,IDSIZE
	CALL	MOVE
	RET
;.....
;
;
COMPREG:
	MOV	A,H		;compare hl to de
	CMP	D
	RNZ
	MOV	A,L
	CMP	E
	RET

OUTPUT: PUSH	D		;put out a crlf
	LXI	D,CRLF
	MVI	C,09
	CALL	BDOS
	POP	D		;now put out the message
;
OUT1:	MVI	C,09
	JMP	BDOS
;.....
;
;
HEADING:
	LXI	D,HEAD1
	CALL	LIST
	LXI	D,DATE
	CALL	LIST
	LXI	D,TABFULL
	LDA	ABORT
	ORA	A
	CNZ	LIST
	MVI	A,LINSPG
	STA	LINECNT
	LXI	D,CRLF
	CALL	LIST
	LXI	D,CRLF
	JMP	LIST
;
LIST:	PUSH	H		;this differs from output
	PUSH	B		; in that list goes to the
	PUSH	D		;list device and output goes
;
LIST1:	LDAX	D		;to the console device
	CPI	'$'
	JZ	LIST2
	INX	D
	PUSH	D
	MOV	E,A
	MVI	C,5
	CALL	BDOS
	POP	D
	JMP	LIST1
LIST2	POP	D
	POP	B
	POP	H
	RET
;.....
;
;
QUESTION:
	CALL	OUTPUT		;put out the question
	LXI	D,INBUF
	MVI	C,0AH		;input the reply
	CALL	BDOS
	LDA	INCNT		;see if anything was entered
	RET
;.....
;
;
MOVE:	PUSH	H		;move data pointed to in hl
	PUSH	D		;to the area pointed to in de
	PUSH	B		;by the byte count in b
;
MOVE1:	MOV	A,M
;	ani	7fh		;reset the high order bit because it
				;may have been turned on for the type
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	MOVE1
	POP	B		;restore the total environment
	POP	D
	POP	H
	RET
;.....
;
;
COMPARE:
	PUSH	H		;compare the strings pointed to in hl
	PUSH	D		;to the string pointed to in de
	PUSH	B		;for a length of b characters
;
COMP1:	LDAX	D		; jc if hl > de
	CMP	M		; jz if hl = de
	JNZ	COMP2		;jnc if hl < de
	INX	H
	INX	D
	DCR	B
	JNZ	COMP1
;
COMP2:	POP	B
	POP	D
	POP	H
	RET
;.....
;
;
; this routine reads the computime clock and formats the time and date
;
	 IF	COMPUT AND CLOCK
GETDATE:
	MVI	A,16		;raise the hold signal
	OUT	C2
	MVI	A,50		;delay at least 50 milliseconds
;
WAIT50: DCR	 A
	JNZ	WAIT50
	LXI	H,DATETIME	;set message start.  1st char is space
	MVI	A,42		;get month tens char
	CALL	GETTIME
	MVI	A,41		;get month units char
	CALL	GETTIME
	INX	H		;skip slash
	MVI	A,40		;get day tens char
	CALL	GETTIME
	ANI	0F3H		;drop leap year indicator
	MOV	M,A
	MVI	A,39		;get day units char
	CALL	GETTIME 	
	INX	H		;skip slash
	MVI	A,44		;get year tens char
	CALL	GETTIME
	MVI	A,43		;get year units char
	CALL	GETTIME
	INX	H		;skip blank
	MVI	A,37		;get hour tens char
	CALL	GETTIME
	ANI	0F3H		;drop am/pm and 24hr indicators
	MOV	M,A
	MVI	A,36		;get hour units char
	CALL	GETTIME
	INX	H		;skip colon
	MVI	A,35		;get minutes tens char
	CALL	GETTIME
	MVI	A,34		;get minutes units char
	CALL	GETTIME
	INX	H		;skip colon
	MVI	A,33		;get seconds tens char
	CALL	GETTIME
	MVI	A,32		;get seconds units char
	CALL	GETTIME
	XRA	A
	OUT	C2		;lower hold signal
	RET
;.....
;
;
C1:	EQU	254		;clock address port
C2:	EQU	253		;clock data output port
;
GETTIME:
	INX	H		;advance to next print position
	OUT	C1
	MVI	A,6		;delay at least 6 milliseconds
;
WAIT6:	DCR	A
	JNZ	WAIT6
	IN	C1
	ORI	30H		;convert to ascii
	MOV	M,A
	RET
	 ENDIF			;COMPUT AND CLOCK
;.....
;
;
; this routine reads the time and day on the sierra data sciences bios
; clock.  the julian date from the sirra bios is converted to real date.
; (why use a julian date sierra ?  does not save any memory anyway ????)
;
	 IF	SIERRA AND CLOCK
DINM:	DB	31,28,31,30,31,30,31,31,30,31,30,31
MONTH:	DB	1
YEAR:	DB	0
TEMDAY: DW	0
;
GETDATE:LDA	64		;get year
	STA	YEAR
	CALL	CONVRT		;make it decimal
	MOV	A,B
	STA	DATETIME+7
	MOV	A,C
	STA	DATETIME+8
	LDA	YEAR		;we need to know if this a leap year
	SUI	80		;will only work post 1980 !!!!
;
LEAP:	SUI	4		;you need to change this in year 2000
	JZ	AJUS		;it is a leapyear
	JNC	LEAP		;do it until we know
	JMP	STIM
;
AJUS:	MVI	A,29
	STA	DINM+1		;29 days in feb this year
;
STIM:	LXI	B,DINM		;point to days in month table
	LHLD	65		;copy date local
	SHLD	TEMDAY
;
SLOOP:	LDAX	B		;get no of days in this month
	MOV	D,A
	LDA	TEMDAY
	SUB	D
	JNC	SIER1		;we still have too many days
	STA	TEMDAY		;keep low day here till later
	LDA	TEMDAY+1	;get high day
	CPI	1		;still set ?
	JNZ	GOTMON		;no, we got the month
	XRA	A		;high date done
	STA	TEMDAY+1
	JMP	NXMON
;
SIER1:	STA	TEMDAY
;
NXMON:	INX	B		;next month
	LDA	MONTH
	INR	A
	STA	MONTH
	JMP	SLOOP
;
GOTMON:	LDA	TEMDAY
	ADD	D		;correct days
	CALL	CONVRT		;we got the day so put in string
	MOV	A,B
	STA	DATETIME+4
	MOV	A,C
	STA	DATETIME+5
	LDA	MONTH
	CALL	CONVRT
	MOV	A,B
	STA	DATETIME+1
	MOV	A,C
	STA	DATETIME+2
	LDA	67		;get the hour
	CALL	CONVRT
	MOV	A,B
	STA	DATETIME+10
	MOV	A,C
	STA	DATETIME+11
	LDA	68		;minutes
	CALL	CONVRT
	MOV	A,B
	STA	DATETIME+13
	MOV	A,C
	STA	DATETIME+14	;i know this code is not elegant
	LDA	69
	CALL	CONVRT
	MOV	A,B
	STA	DATETIME+16
	MOV	A,C
	STA	DATETIME+17	;finaly
	RET
	 ENDIF			;SIERRA AND CLOCK
;.....
;
;
	 IF	SIERRA OR USERS
CONVRT: MVI	B,030H		;convert binary to decimal routine
	MVI	C,030H		;for nos from 0 to  99 b=tens,c=ones
;
CON1:	SUI	10		;a holds value to convert
	JC	CON2
	INR	B
	JMP	CON1
;
CON2:	ADI	10		;correct it
;
CON3:	SUI	1
	RC			;we are done
	INR	C		;do ones
	JP	CON3
	 ENDIF			;SIERRA OR USERS
;
DATETIME: DB	' 00/00/00 HH:MM:SS$'
DRIVES:   DB	'ABCDEFGHIJKLMNOP'      ;drive nos for the hard disks
BACKUPDRV:DS	1			;backup floppy drive letter


SIGNON:	  DB	1AH,'HARD DISK CATALOG AND BACKUP   v2.3 11/20/83$'
DRIVMSG:  DB	0AH,'Enter Letter of Drives to Backup from as '
	  DB	'"ABCD..ect." $'
BKUPMSG:  DB	0AH,'Enter Letter of Floppy Drive to Backup to $'
CORRMSG:  DB	0AH,'Backing up Drives  $'
CORRMSG1: DB	'  to Floppy Drive  $'
CORRY$N:  DB	0AH,'is this Correct (Y/N)? $'
DATEMSG:  DB	0AH,'Enter 8 Char Date for Reports MM/DD/YY: $'
USRMSG:   DB	0AH,'Backup all user areas (Y/N)? $'
NOFILS:   DB	0AH,'NO files to backup here !! $'
USRNOMS:  DB	0AH,'Starting Backup procedure in user area : $'
USERID:   DB	'00$$$' 
ERASE:	  DB	0AH,07H,'ERASE Floppy Disk First (Y/N)? $'
TABFULL:  DB	0AH,07H,'MEMORY FULL...REPORT NOT COMPLETE$'
BACKQUS:  DB	0AH,'Begin Backup Procedure (Y/N)? $'
SORTMSG:  DB	0AH,'SORTING...$'
NFMSG:	  DB	0AH,07H,'FILE NOT FOUND...ABORTING$'
DMNTMSG:  DB	'DISMOUNT BACKUP DISK AND ENTER RETURN$'
MNTMSG:   DB	'MOUNT DISKETTE FOR BACKUP AND ENTER '
	  DB	'3 CHAR DISK ID OR "END": $'
ENDLIT:   DB	'END'
VOLSER:   DS	3
QUEST1:   DB	'BACKUP ALL FILES OF TYPE '
QTYPE:	  DS	3
	  DB	', (Y/N/S)? $'
QUEST2:   DB	'BACKUP FILE NAMED '
QDISK2:   DS	1
	  DB	':'
QFILE2:   DS	8
	  DB	'.'
QTYPE2:   DS	3
	  DB	', (Y/N/C)? $'
HEAD2:	  DB	0CH,'THE FOLLOWING FILES WILL BE COPIED TO DISKETTES$'
PRNTREC:  DS	1
	  DB	':'
PRNFILE:  DS	8
	  DB	'.'
PRNTYPE:  DS	3
	  DB	'    $'
CRLFLFLF: DB	0DH,0AH,0AH,0AH,'$'
INDEX:	  DB	'THE FOLLOWING FILES ARE ON DISKETTE NO. '
IDISKNO:  DS	3
	  DB	' AS OF '
IDATE:	  DS	8
	  DB	'$'
CRLF:	  DB	0DH,0AH,'$'
HEAD1:	  DB	0CH,'CONSOLIDATED INDEX BY FILE TYPE AS OF $'
CURUSER:  DB	16	;current user number (local)
DATE:	  DS	8
	  DB	'   $'
BIGMSG:   DB	0DH,0AH,'FILE TOO LARGE TO FIT ON ONE DISKETTE '
	  DB	'SO NOT BACKED UP **** $'
HDFCB:	  DS	1
HDFILE:   DS	8
HDTYPE:   DS	3
	  DS	24
FPFCB:	  DS	36
TOP:	  DB	0CH,'$'
INBUF:	  DB	30
INCNT:	  DS	1
INREC:	  DS	30
STACK:	  DS	80
EOF:	  DS	1
ABORT:	  DS	1
GOTONE:   DS	1	;flag to indicate valid file found, entry made
LINECNT:  DS	1
LASTTYPE: DS	3
LASTFILE: DS	8
TABADDR:  DS	2
TABCNT:   DS	2
SELFLAG:  DS	1
TOOBIG:   DS	1
ADDR1:	  DS	2
ADDR2:	  DS	2
ADDR3:	  DS	2
MAX1:	  DS	2
MAX2:	  DS	2
MAX3:	  DS	2	;used to restore max1 between users
RTYPE:	  DS	3
RFILE:	  DS	8
RDISK:	  DS	3
	  DB	'$'
TEMP:	  DS	RECSIZ
DISKBUF:  DS	128
COMPSIZE: DS	1
RAM:	  EQU	$
BDOS:	  EQU	05H
CONIN:	  EQU	01H
CONOUT:   EQU	02H
;.....
;
;
	  END	100H
