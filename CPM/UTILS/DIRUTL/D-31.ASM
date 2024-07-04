
; D.ASM v3.1  -  05/05/84
;
;		RESTRICTED DIRECTORY LIST PROGRAM
;
; D.COM is a directory list program, which writes 4 or 5 entries on a
; line, separated by colons.
;
;
;   (THIS IS THE 'WHATSNEW' PROGRAM SEEN ON MANY RCPM SYSTEMS)
;
;
; The command contains an internal table of file names, which are not to
; be shown when just "D" is typed.  (NOTE typing "D *.*" always shows
; all files)
;
; Why is this useful:  A typical CP/M disk contains many utility files,
; such as ED.COM, ASM,COM, PIP.COM, STAT.COM, etc.  When you do a direc-
; tory listing, you typically are not interested in seeing all those
; files, but rather just the "current" or "active" files.  This is what
; "D.COM" can do.
;
; NOTE: Direct CBIOS calls are used for input and output in order to
;	avoid echoing of inputted characters.  This keeps a noisy phone
;	line from causing garbage characters in the display.
;-----------------------------------------------------------------------
;
; 05/05/84  Line with the "use FILE xxx*.*" now only appears on the line
;   v3.1    with the message about moved or deleted files.
;					- Irv Hoff
;	
; 05/01/84  Changed the "Deleted files since --- " to "Files moved else-
;   v3.0    where or deleted", then added a line "use FILE xxx*.* to see
;	    if available."  With 20-40 megabyte disk systems now common,
;	    this is a convenient way to locate files which are no longer
;	    in the "Whatsnew" user area.  It was misleading when reading
;	    the files had been deleted when most have merely been moved.
;	    (Every SYSOP needs FILE.COM on his system.)  SD xxx*.* $U0AD
;	    may also be used, but gives information that is superfluous.
;	    Standardized the format.	- Irv Hoff
;
; 08/12/82  Added SUB file option to allow writing each new filename
;   v2.9    that appears in the "New Files" display to a .SUB file of
;	    the form:
;			XSUB
;			PIP
;			$1=$2 Fn.Ft$3
;			$1=$2 Fn.Ft$3
;
;	    etc., to allow a simple archive of new files to be performed
;	    by: SUBMIT D A:=B: [G1].  Also repaired bug in EXIT routine
;	    and removed character 'gobbler' routine so that the program
;	    will work better with 'type-ahead' BIOSes.
;					- Dave Hardy
;
; 11/23/78  Originally written by Ward Christensen.
;
;=======================================================================
;
; Use:	D *.*	prints all names, 5 across.
;
;	D *.ASM prints selected files just like DIR.
;
;	D SET builds a table (in D.COM) of all names currently on the
;		disk. (see *NOTE).
;
;	D SET <DATE>  adds the date for printing whenever is called by
;		'A>D<CR>' with no options.  If the date field is left
;		blank, it will be ignored.  Note that the date must be
;		8 characters or less (see *NOTE).
;
;	D TIT <TITLE FOR DISK> sets an internal disk title which prints
;		out each time the program is run (if a title has been
;		set).  (maximum of about 70 characters, please, although
;		it will handle a full CP/M input line.
;
;		NOTE: To get rid of title (and accompanying
;		print put type 'D TIT' and the title is
;		set to null.
;
;	D ADD FN.FT adds a name to the table in D.COM, so FN.FT will not
;		be listed by the 'D' command (see *NOTE).
;
;	D DEL FN.FT deletes a name from the table in D.COM, so if FN.FT
;		is in the directory, it will be listed by 'D' (see NOTE)
;
;	D SUB causes a file named 'D.SUB' to be generated on the current-
;		ly logged-in drive.  The file contains all of the 'New
;		Files' names, and is of the form:
;
;			XSUB
;			PIP
;			$1<fn1.ft>$2
;			$1<fn2.ft>$2
;			$1<fn3.ft>$2
;
;		etc.  D.SUB can be used to archive 'New Files' with a
;		simple command line like:  SUBMIT D B:=A: [G5] which
;		would PIP all of the new files from B5: to A:
;
;	D     lists the directory, showing only those files NOT in D.COM
;		as put there by 'D SET' or 'D ADD FN.FT'
;
;			*NOTE:	the program must write itself
;				back to disk, modified, so your
;				disk must not be write protected.
;
;-----------------------------------------------------------------------
;
;		Examples:  Suppose your disk has:
;
;	D.COM	  \
;	ASM.COM    \
;	ED.COM	    on it initially.
;	LOAD.COM   /
;	DDT.COM   /
;
;		You would type:  D SET to set these names into the
;		D.COM program.
;
;		Typing "D" would then list:
;
;	-->New files
;	A: ++ NONE ++
;
;	-->Deleted files
;	A: ++ NONE ++
;
;		Suppose you:  A>ED TEST.ASM, A>ASM TEST and LOAD TEST.
;		Typing D would then list:
;
;	-->New files
;	A: TEST    ASM : TEST	 BAK : TEST    HEX : TEST    COM
;
;	-->Deleted files
;	A: ++ NONE ++
;
;		i.e., it tells you of the "current" files on the disk.
;		Now, supposing you wanted to add TEST.COM as a "regular"
;		file on your disk.  Type:
;
;	D ADD TEST.COM
;
;		Now, typing D will show:
;
;	-->New files
;	A: TEST    ASM : TEST	 BAK : TEST    HEX
;
;	-->Deleted files
;	A: ++NONE++
;
;		i.e., TEST.COM is now considered a "permanent" file.
;
;		Now, suppose you accidentally erased ASM.COM from your
;		disk.  Typing D gives:
;
;	-->New files
;	A: TEST    ASM : TEST	 BAK : TEST    HEX
;
;	-->Deleted files
;	A: ASM	   COM
;
;		showing you are missing one of the "regular" files.  If,
;		in fact, you didn't want ASM.COM to be on the disk, type:
;
;	D DEL ASM.COM
;
;		which will delete the name from the D.COM table, so
;		ASM.COM will not up as "deleted".
;
;=======================================================================
;
;	       SPECIAL NOTES FOR REMOTE SYSTEM USE:
;
; If you keep a dedicated copy of this program on each drive of your re-
; mote system, you can 'dedicate' each copy of this program to a drive
; by filling in the byte at 103H with the drive number.  This prevents
; such things as:
;
;	A>D B:
;		or
;	B>A:D
;
; Do this by using the command:
;
;	A>D LOK A:	to lock to a drive
;		or
;	A>D LOK 	to unlock
;
; If the conditional 'NOSYS' is set YES, $SYS files in CP/M 2.x will be
; ignored in both directory listings and when the "ADD" option is in-
; voked, unless the override char is specified.  This allows D.COM to be
; used as a "WHAT'S NEW" program for remote CP/M systems, where the $SYS
; files must not be listed.
;
; Examples:
;
;	A>D *.* S	 displays everything
;	A>D SET S	 puts ALL files in table
;	A>D SET 12/23/80 sets date for reference
;
;	    (if you use 'D SET S', you lose the date option..
;
; If you use this program on a remote system, you will likely want to
; change the commands (ADD, DEL, and SET) for security.  You will also
; want to change the $SYS suppress override character.	You may also
; want to change the name of the program to make the name itself more
; informative, e.g. "D.COM".
;
;
; -->IMPORTANT: If you want the program to be 'TAG'ed after every D SET
;		(so it cannot be taken by XMODEM), see the note at label
;		"WRBACK" for setting the F1 bit in the filename itself.
;
;
; Note that this program defines its own name for write-back purposes
; under the label "WRBACK".
;
;=======================================================================
;
; Define some stuff
;
YES:	EQU	0FFH
NO:	EQU	0
;
;
BIAS:	EQU	0		;for std cp/m or 4200h for altcpm
BDOS:	EQU	5+BIAS		;cp/m's BDOS access jump
CPMBUFF:EQU	80H+BIAS	;cp/m command line buffer
CR:	EQU	0DH		;carriage return
FCB:	EQU	5CH+BIAS	;cp/m's file control block
FCBRNO:	EQU	FCB+32		;rec # in fcb
LF:	EQU	0AH		;line feed
;
;
; Set the following for your system:
;
NOSYS	EQU	YES		;yes=ignore $sys files
FENCE	EQU	':'		;file name separator
NPL	EQU	4		;file names per line
;
;
; The leader string for the SUB file (XSUB, PIP) is located at label
; SUBF4.
;
;
	ORG	100H+BIAS
;
;
DENTRY:	JMP	AROUND
;
DRIVE:	DB	0		;<---drv # is put here if dedicated
				;(this can be done with the lok command)
;
;Initialize the local stack
;
AROUND:	LXI	H,0		;hl=0
	DAD	SP		;hl=stack
	SHLD	STACK		;save stack pointer
	LXI	SP,STACK	;init local stack
;
;
;Initialize direct CBIOS calls
;
	LHLD	1+BIAS
	LXI	D,3
	DAD	D		;hl=constat
	SHLD	TYPES+1
	DAD	D		;hl=conin
	SHLD	CIC+1
	DAD	D		;hl=conout
	SHLD	TYPEC+1
;
;
; Print ID message
;
	CALL	ILPRT		;print:
	DB	'D v3.1',CR,LF
	DB	'CTL-S pauses, CTL-C aborts',CR,LF,0
;
;
; Print Disk Title
;
PTITL:	LXI	H,DTITLE	;get title address
	MOV	A,M		;load it
	ORA	A		;end of string
	JZ	CONT		;don't print title
	CALL	ILPRT		;print heading
	DB	'Title: ',0
	LXI	H,DTITLE	;load it again
;
LOOP1:	MOV	A,M
	ORA	A		;zero?
	JZ	ENDPRT		;all done
	CALL	TYPE		;type this char
	INX	H		;next char
	JMP	LOOP1		;repeat ...

DTITLE:	DB	0		;storage for
	DS	7FH		;title
;
ENDPRT:	CALL	CRLF
;
;
; Set file control block
;
CONT:	LDA	DRIVE
	ORA	A		;non-dedicated?
	JZ	NOND		;jump if so
	STA	FCB
;
NOND:	LHLD	FCB+17		;get $sys override characters
	SHLD	SYSTOO		;and save for later
	LDA	FCB+19
	STA	SYSTOO+2
;
;
; See if request to add name to list
;
	LXI	H,FCB+1
	CALL	ADDCM2
;
ADDCM:	DB	'ADD        '	;11 characters (padded with spaces)
;
ADDCM2:	POP	D		;make de point to add command
	LXI	B,ADDCM2-ADDCM	;bc gets length of string
	CALL	COMPR
	JNZ	NOADD
;
;
; Got request to add name to table
;
	CALL	DELNAM		;first, delete the name
	CALL	FINDFF		;find end of table
	XCHG			;addr to de
;
;
; Move name to table
;
	LXI	H,FCB+17
	LXI	B,11
	CALL	MOVER
	MVI	A,0FFH
	STAX	D		;set new end
	JMP	WRBACK		;write program back
;
;
; See if request to add title to disk
;
NOADD:	LXI	H,FCB+1
	CALL	NOADD1A
NOADD1B:
	DB	'TIT'		;total of this and the next line must..
TITLEN:	DB	'        '	;be 11, change for a longer title name
;
NOADD1A:
	POP	D		;get to
	LXI	B,NOADD1A-NOADD1B
	CALL	COMPR
	JNZ	NOADD2A
;
;
; Process the title or erase it, if none given
;
	LXI	H,CPMBUFF	;get length
	MOV	A,M		;move it to a
	SUI	TITLEN-NOADD1B+1;but don't include the title command
	JZ	TITNO		;no title?
	LXI	H,CPMBUFF+TITLEN-NOADD1B+2
	LXI	B,0000
	MOV	C,A		;put length in bc
	LXI	D,DTITLE	;place to store
	CALL	MOVER		;move title in storage
	MVI	A,00		;and mark end
	STAX	D		;of string
	JMP	WRBACK		;and write back to disk
;...
;
;	
; No title - Clear title
;
TITNO:	LXI	H,DTITLE	;load in space
	MVI	M,00		;store end of string
	JMP	WRBACK		;and write back to disk
;.....
;
;
; See if request to lock D.COM to a drive
;
NOADD2A:
	LXI	H,FCB+1
	CALL	NOADD3
;
NOADD2:	DB	'LOK        '
;
NOADD3:	POP	D		;get to
	LXI	B,NOADD3-NOADD2
	CALL	COMPR
	JNZ	NOLOK
;
;
; Got request to lock
;
	LDA	FCB+16
	STA	DRIVE
	STA	FCB
	JMP	WRBACK
;.....
;
;
; See if request to DEL name from list
;
NOLOK:	LXI	H,FCB+1
	CALL	NOLOK3
NOLOK2:	DB	'DEL        '	;must be 11 total
;
NOLOK3:	POP	D		;get to
	LXI	B,NOLOK3-NOLOK2
	CALL	COMPR
	JNZ	NODEL
;
;
; Got request to delete a name from the file
;
	CALL	DELNAM		;delete the name
	JNC	WRBACK		;write back if ok
	CALL	MSGXIT
	DB	'++ NAME NOT IN TABLE ++$'
;.....
;
;
; See if request is to make SUB file
;
NODEL:	LXI	H,FCB+1
	CALL	SUBF3
SUBF2:	DB	'SUB        '	;must be 11 total
;
SUBF3:	POP	D
	LXI	B,SUBF3-SUBF2
	CALL	COMPR
	JNZ	NOSUB
;
;
; Got request to make SUB file, so say so, and set flag to force it
;
	CALL	SAYSUB		;tell console that sub file will be made
	DB	'Writing SUBMIT file...',CR,LF,'$'
;
SAYSUB:	POP	D
	MVI	C,9
	CALL	BDOS
	MVI	A,0FFH		;tell prgm to make sub file
	STA	SUBFLG
	LXI	H,SUBBUF	;write sub file start into file buffer
	CALL	SUBF5		;(xsub, pip, etc.)
;
SUBF4:	DB	'XSUB',CR,LF,'PIP',CR,LF
;
SUBF5:	POP	D		;use mover routine to copy to sub buffer
	XCHG
	LXI	B,SUBF5-SUBF4
	CALL	MOVER
	XCHG
	SHLD	SUBPTR		;save sub file buffer pointer
	LXI	H,FCB+1		;then fill tail in with spaces to make
	MVI	C,11		;  program think that no options chosen
;
NXSPC:	MVI	M,' '
	DCR	C
	INX	H
	JNZ	NXSPC
	MVI	C,36H		;initialize local fcb
	LXI	H,LFCB		;(no default, because commands there)
;
NXFCB:	MVI	M,0
	DCR	C
	INX	H
	JNZ	NXFCB
	LXI	D,LFCB+1	;set up local fcb to write d.sub file
	CALL	UWR2
;
UWR1:	DB	'D       SUB',0
;
UWR2:	POP	H
	LXI	B,UWR2-UWR1
	CALL	MOVER
	MVI	C,ERASE		;erase old file, if it exists
	LXI	D,LFCB
	CALL	BDOS
	XRA	A
	STA	LFCB		;set up to write to default drive
	STA	FCBRNO		;initialize record number
	MVI	C,MAKE		;create the file
	LXI	D,LFCB
	CALL	BDOS
	JMP	NOSET		;then jump off to display names as usual
;.....
;
;
; See if request to set up table from directory
;
NOSUB:	LXI	H,FCB+1
	CALL	NODEL3
NODEL2:	DB	'SET        '	;must total 11
;
NODEL3:	POP	D		;get to
	LXI	B,NODEL3-NODEL2
	CALL	COMPR
	JNZ	NOSET
;
;
; Got request to setup table.  Move the date (may be blank).
;
	LXI	H,FCB+17
	LXI	D,DATE
	LXI	B,8
	CALL	MOVER
;
	LXI	H,FCB+17
	LXI	D,DATE1
	LXI	B,8
	CALL	MOVER
;
	MVI	A,1		;turn on..
	STA	SETFLG		;..set flag
	MVI	A,0FFH		;clear..
	STA	NAMES		;..names table
	CALL	FILLQ		;make fcb '????????.???'
;
NOSET:	LDA	FCB+1		;get prtflg
	SUI	' '
	STA	PRTFLG
	PUSH	PSW
	CZ	HEAD1
	POP	PSW
	JNZ	GOTNAM
	CALL	FILLQ		;make name ????????.???
;
GOTNAM:	LDA	FCB
	ORA	A
	JZ	NODISK
	DCR	A
	MOV	E,A
	MVI	C,SELDSK
	CALL	BDOS
;
NODISK:	MVI	B,NPL		;names per line
	CALL	LINMRK
	MVI	C,SRCHF
	JMP	CALLIT
;
LINE:	MVI	B,NPL		;names per line
	CALL	LINMRK
;
NEXT:	MVI	C,SRCHN
;
CALLIT:	PUSH	B
	LXI	D,FCB
	CALL	BDOS
	INR	A
	JZ	CKNONE
	DCR	A
	ANI	3
	MOV	L,A
	MVI	H,0
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	LXI	D,81H+BIAS
	DAD	D
;
;
; Check for $SYS attribute, then clear all attributes
;
	PUSH	H
	LXI	D,9		;sys att offset
	DAD	D
	MOV	A,M
	ANI	80H
	STA	SYSFLG
	POP	H		;retrieve filename ptr
	PUSH	H
	MVI	E,11		;11 chars in filename
;
ATTLP:	MOV	A,M		;pick up char
	ANI	7FH		;kill attribute
	MOV	M,A		;put back down
	INX	H
	DCR	E
	JNZ	ATTLP
	POP	H
;
;
; See if name is to be printed
;
	XCHG			;name pointer to de
	LDA	SETFLG		;request to setup table?
	ORA	A
	JNZ	SETUP		;go set entry into table
	LDA	PRTFLG
	ORA	A
	JNZ	GOPRNT		;explicit request for all
	PUSH	D
	LXI	H,NAMES
;
CKNEXT:	POP	D		;get name pointer
	POP	B
	PUSH	B
	MOV	A,M		;end of table?
	INR	A		;was it 0ffh?
	JZ	GOPRNT
	MVI	B,0
	MVI	C,11		;name length
	PUSH	D
;
CKLP:	LDAX	D
	CMP	M
	JNZ	NOMACH
	INX	D
	INX	H
	DCR	C
	JNZ	CKLP		;loop for 11 chars
;
;
; Got match, mark it found but do not print it
;
	LXI	D,-11		;point back to name
	DAD	D
	MVI	M,0		;mark it found
	POP	D		;pop pointer
	POP	B
	JMP	NEXT		;skip the name
;
;
; Name didn't match, try next
;
NOMACH:	DAD	B		;point to next name
	JMP	CKNEXT
;
;
; Print the name
;
GOPRNT:
	 IF	NOSYS
	CALL	SYSCK
	JZ	DONAME
	LDA	SYSFLG
	RAL
	POP	B
	JC	NEXT
	PUSH	B
	 ENDIF			;NOSYS
;
;
DONAME:	LDA	SUBFLG		;see if sub file is to be made
	ORA	A
	CNZ	NAMSUB		;write the name into the sub buffer
	MVI	A,1		;say we got one
	STA	GOTFLG
	MVI	C,8
	XCHG			;name back to hl
	CALL	TYPMEM
	MVI	A,'.'
	CALL	TYPE
	MVI	C,3
	CALL	TYPMEM
	POP	B
	CALL	SPACE
	MVI	A,FENCE
	DCR	B
	PUSH	PSW
	CNZ	TYPE
	CALL	SPACE
	POP	PSW
	JNZ	NEXT
	CALL	CRLF
	JMP	LINE
;.....
;
;
; Write the filename pointed to by DE into the SUB file buffer in the
; format: $1<fn.ft>$2<cr><lf>
;
NAMSUB:	PUSH	H		;save hl (whatever's in it)
	PUSH	D		;save filename pointer
	PUSH	B		;save bc (whatever's in it)
	LHLD	SUBPTR		;hl to sub buffer (de to filename)
	MVI	C,8		;8 characters in filename
	MVI	M,'$'		;first write '$1'
	CALL	INCPTR		;increment file buffer pointer and..
	MVI	M,'1'		;..write if full
	CALL	INCPTR
;
SNAM:	LDAX	D		;get a character of the name
	CPI	' '	       ;do not transfer spaces to sub buffer
	JZ	SNAM2
	ANI	7FH		;trim off any nasty attributes
	MOV	M,A		;put the character into the sub buffer
	CALL	INCPTR		;point to next sub location
;
SNAM2:	INX	D		;point to next character of filename
	DCR	C		;decrement filename counter
	JNZ	SNAM		;continue until all 8 characters read
	MVI	M,'.'		;put a '.' separator into the sub buffer
	CALL	INCPTR		;point to next location in sub buffer
	MVI	C,3	;now do the 3 character long filetype
;
SNAM3:	LDAX	D
	CPI	' '
	JZ	SNAM4
	ANI	7FH
	MOV	M,A
	CALL	INCPTR
;
SNAM4:	INX	D
	DCR	C
	JNZ	SNAM3
	MVI	M,'$'		;then write '$2<cr><lf>' on the end..
	CALL	INCPTR		;.. of the name
	MVI	M,'2'
	CALL	INCPTR
	MVI	M,CR
	CALL	INCPTR
	MVI	M,LF
	CALL	INCPTR
	SHLD	SUBPTR		;save the new sub buffer pointer
	POP	B		;restore all the registers
	POP	D
	POP	H
	RET			;then return back to doname
;.....
;
;
; Increment the HL file buffer pointer, and write the buffer if full
;
INCPTR:	INX	H		;see if buffer is full
	MVI	A,(SUBBUF+80H) AND 0FFH
	CMP	L		;(see if lsh of hl = lsh of subbuf+80h)
	RNZ			;return if buffer not full
WRTSBF:	LXI	H,SUBBUF	;reset pointer to start of buffer
;
WRTSB2:	PUSH	H
	PUSH	D
	PUSH	B
	LXI	D,SUBBUF	;set dma address to sub buffer
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,LFCB		;write the buffer to disk
	MVI	C,WRITE
	CALL	BDOS
	LXI	D,CPMBUFF	;now set dma address back to default so
	MVI	C,SETDMA	;..other routines can read directory
	CALL	BDOS
	POP	B
	POP	D
	POP	H
	ORA	A		;notify console and abort if write error
	JNZ	WRERR
	RET
;
CKNONE:	LDA	GOTFLG		;some new files found?
	ORA	A
	JNZ	NOTFND		;jump if yes
	LDA	PRTFLG		;print names?
	ORA	A
	JNZ	NOTFND		;jump if yes
	CALL	ILPRT
	DB	'++ NONE ++',CR,LF,0
;
;
; Print the files not found
;
NOTFND:	LDA	SETFLG		;is this 'D SET'?
	ORA	A
	JNZ	FINI		;done if so
	LDA	PRTFLG		;are we printing?
	ORA	A
	JNZ	CKNON2		;done if not
;
; If this D.COM is dedicated ("DRIVE" is non-zero), then be sure to
; print the "FILES NOT FOUND".
;
	LDA	DRIVE
	ORA	A
	JNZ	NOCHK
	LDA	FCB		;drive specified?
	ORA	A
	JNZ	FINI		;skip not found if so
;
NOCHK:	CALL	HEAD3		;print not fnd header
	LXI	H,NAMES		;start of table
	LXI	D,11
;
LINE2:	MVI	B,NPL
	CALL	LINMRK
;
NEXT2:	MOV	A,M		;first char of name
	ORA	A		;marked found?
	JZ	NOPRNT		;jump if so
	INR	A		;check for table end
	JZ	CKNON2		;jump if end
	MVI	A,1
	STA	GOTNF
	MVI	C,8
	CALL	TYPMEM
	MVI	A,'.'
	CALL	TYPE
	MVI	C,3
	CALL	TYPMEM
	CALL	SPACE
	MVI	A,FENCE
	DCR	B
	PUSH	PSW
	CNZ	TYPE
	CALL	SPACE
	POP	PSW
	JNZ	NEXT2
	CALL	CRLF
	JMP	LINE2
;
NOPRNT:	DAD	D
	JMP	NEXT2
;.....
;
;
; Print header
;
HEAD1:	CALL	ILPRT		;print:
	DB	CR,LF,'-->New files',0
	LDA	DATE
	CPI	' '
	JZ	HEAD2
	CALL	SYSCK
	JZ	HEAD2
	CALL	ILPRT		;print:
	DB	' since '
;
DATE:	DB	'        '	;eight spaces
	DB	0		;string terminator
	JMP	CRLF
;
HEAD2:	MVI	A,':'
	CALL	TYPE
	JMP	CRLF
;.....
;
;
HEAD3:	CALL	ILPRT		;print:
	DB	CR,LF,CR,LF,'-->Files moved elsewhere or deleted',0
	LDA	DATE
	CPI	' '
	JZ	HEAD5
	CALL	SYSCK
	JZ	HEAD5
	CALL	ILPRT		;print:
	DB	' since '
;
DATE1:	DB	'        '	;eight spaces
	DB	0		;string terminator
;
HEAD4:  CALL	ILPRT
	DB	CR,LF,'   (use FILE xxx*.* to see if available)'
	DB	CR,LF,0
	RET
;
HEAD5:	MVI	A,':'
	CALL	TYPE
	JMP	HEAD4
;.....
;
;
CKNON2:	LDA	GOTNF
	ORA	A
	JNZ	FINI		;jmp if got no 'NOT FOUND's
	LDA	PRTFLG
	ORA	A
	JNZ	FINI
	CALL	ILPRT		;print: (then fall into 'FINI')
	DB	'++ NONE ++',CR,LF,0
;
;
; Finished.  If building table, write back.  If making a SUB file, then
; flush the file buffer and close it.
;
FINI:	LDA	SUBFLG		;see if sub file is to be written
	ORA	A
	JNZ	WRTSUB		;jump if so,
	LDA	SETFLG		;else see if set was performed
	ORA	A
	JZ	EXIT		;jump out if not,
	JMP	WRBACK		;else write the program back to disk
;
;
; Write the SUB file to the currently logged in disk as 'D.SUB'
;
WRTSUB:	LHLD	SUBPTR		;fill rest of last sector with eof's
	XCHG
	LXI	H,SUBBUF+7FH
;
WNXTS:	MVI	M,1AH
	MOV	A,L
	DCX	H
	CMP	E
	JNZ	WNXTS
	CALL	WRTSB2		;write the last sector to disk
	MVI	C,CLOSE		;close the file
	LXI	D,LFCB
	CALL	BDOS
	INR	A		;if close error, then notify console..
	JZ	BADWCL		;..and abort
	JMP	EXIT		;exit back to cp/m
;
BADWCL:	CALL	MSGXIT
	DB	'BAD CLOSE, SUB file incomplete$'
;
;
; Set up the name in the table
;
SETUP:
	 IF	NOSYS
	CALL	SYSCK
	JZ	SETU2
	LDA	SYSFLG
	RAL
	JC	SETSKP
	 ENDIF			;NOSYS
;
SETU2:	CALL	FINDFF		;find end of table
	XCHG			;setup for move
;
;
; (HL = name, DE = end of table)
;
	LXI	B,11
	CALL	MOVER
	MVI	A,0FFH		;get table end flag
	STAX	D		;store it
;
SETSKP:	POP	B		;delete stack garbage
	JMP	NEXT		;get next entry
;
;
; Routine to type 'C' characters from memory (HL)
;
TYPMEM:	MOV	A,M
	CALL	TYPE
	INX	H
	DCR	C
	JNZ	TYPMEM
	RET
;.....
;
;
; Inline print routine - prints string pointed to by stack until a zero
; is found.  Returns to caller at next address after the zero terminator.
;
ILPRT:	XTHL			;save hl, get msg adrs
;
ILPLP:	MOV	A,M		;get char
	CALL	TYPE		;output it
	INX	H		;point to next
	MOV	A,M		;test
	ORA	A		;..for end
	JNZ	ILPLP
	XTHL			;restore hl, ret addr
	RET			;ret past msg
;.....
;
;
CRLF:	CALL	ILPRT	;print:
	DB	CR,LF,0
	RET
;.....
;
;
SPACE:	MVI	A,' '
;
;
; Print character in A to console
;
TYPE:	PUSH	B
	PUSH	D
	PUSH	H
	MOV	C,A		;char to c for cbios
;
TYPEC:	CALL	$-$		;supplied at start
;
;
; See if console key pressed
;
TYPES:	CALL	$-$		;supplied at start
	ORA	A		;key pressed?
	CNZ	CKKB		;yes, see which one
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
CKKB:	CALL	CI		;get char
	CPI	'S'-40H		;pause?
	CZ	CI		;yes, get next char
	CPI	'C'-40H		;abort?
	RNZ			;no, return
	CALL	MSGXIT
	DB	CR,LF,'++ ABORTED ++$'
;.....
;
;
; Move (BC) bytes from (HL) to (DE)
;
MOVER:	MOV	A,M
	STAX	D
	INX	D
	INX	H
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	MOVER
	RET
;.....
;
;
; Compare routine
;
COMPR:	LDAX	D
	CMP	M
	RNZ
	INX	D
	INX	H
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	COMPR
	RET			;equal means z=1
;.....
;
;
; Routine to find 0FFH at end of table
;
FINDFF:	LXI	H,NAMES
;
FINDLP:	MOV	A,M
	INX	H
	INR	A		;0ffh?
	JNZ	FINDLP
	DCX	H		;back up to table end
	RET
;.....
;
;
; Delete the name from the table
;
DELNAM:	LXI	H,NAMES
;
DELLP:	MOV	A,M
	CPI	YES
	STC
	RZ			;not found
	LXI	D,FCB+17
	LXI	B,11
	CALL	COMPR
	JZ	DELETE
	DAD	B		;calc next
	JMP	DELLP
;.....
;
;
; Delete the name
;
DELETE:	XCHG			;next name to de
	LXI	H,-11		;to back up..
	DAD	D		;..to name to del
;
DELCH:	LDAX	D
	MOV	M,A
	INX	H
	INX	D
	INR	A		;moved the 0ffh?
	JNZ	DELCH
	ORA	A		;show found
	RET
;.....
;
;
; Fill FCB with all '?'
;
FILLQ:	LXI	H,FCB+1
	MVI	B,8+3
	MVI	A,'?'
;
QMLOOP:	MOV	M,A
	INX	H
	DCR	B
	JNZ	QMLOOP
	RET
;.....
;
;
; Write back the program - note that you may set any of the CP/M 2.x
; attribute bits in the file name (be sure to define all 11 characters
; of the name).
;
WRBACK:	LXI	D,FCB+1
	CALL	WRBK2
;
WRBK1:	DB	'D'+80H		;<--put 'D'+80h here to set tag
	DB	'       COM'	 ;see comment above
	DB	0		;extent number
;
WRBK2:	POP	H
	LXI	B,WRBK2-WRBK1
	CALL	MOVER
	MVI	C,ERASE
	LXI	D,FCB
	CALL	BDOS
	XRA	A		;get 0
	STA	SETFLG		;clear the flags..
	STA	GOTFLG
	STA	GOTNF
	STA	SYSTOO
	STA	FCBRNO		;zero record number
	MVI	C,MAKE
	LXI	D,FCB
	CALL	BDOS
;
;
; Before writing back, find end of table
;
	CALL	FINDFF
	MOV	B,H		;b=end page
	INR	B		;for compare
	LXI	D,100H+BIAS	;starting addr
;
WRLP:	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,SETDMA
	CALL	BDOS
	MVI	C,WRITE
	LXI	D,FCB
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	ORA	A		;successful write?
	JNZ	WRERR		;..no
	LXI	H,80H		;point to..
	DAD	D		;..next block
	XCHG			;addr to de
	MOV	A,D		;get page
	CMP	B		;past table end?
	JC	WRLP		;loop until done
	MVI	C,CLOSE
	LXI	D,FCB
	CALL	BDOS
	INR	A		;successful close?
	JZ	BADCLS		;..no, print err msg
	CALL	MSGXIT		;ok, exit w/msg
	DB	'++ DONE ++$'
;.....
;
;
WRERR:	CALL	MSGXIT
	DB	'++ WRITE ERROR ++$'
;.....
;
;
BADCLS:	CALL	MSGXIT
	DB	'++ BAD CLOSE, D.COM CLOBBERED ++$'
;.....
;
;
; Get console input via direct CBIOS call
;
CI:	PUSH	B		;console input
	PUSH	D
	PUSH	H
;
CIC:	CALL	$-$		;supplied at start
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
; Exit with message (error or informational)
;
MSGXIT:	POP	D		;get msg
	MVI	C,PRINT
	CALL	BDOS
;
;
; Exit, restoring DMA and stack, then return to CCP
;
EXIT:	LXI	D,CPMBUFF	;reset dma adr to normal
	MVI	C,SETDMA
	CALL	BDOS
	LHLD	STACK		;get old stack
	SPHL			;restore it
	RET			;return to ccp
;.....
;
;
LINMRK:	PUSH	B
	PUSH	D
	PUSH	H
	LDA	FCB		;get drive name from fcb
	ORA	A		;any there?
	JNZ	GOTDRV		;yes, go print it
	MVI	C,CURDSK	;else get current disk
	CALL	BDOS
	INR	A		;make 'A'=1
;
GOTDRV:	ADI	40H		;make ascii
	CALL	TYPE		;print drive name
	CALL	ILPRT		;print
	DB	': ',0
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
; Test for system file override
;
SYSCK:	PUSH	H
	PUSH	D
	PUSH	B
	LXI	H,SYSTOO
	LXI	D,SYSOK
	MVI	B,3
;
RSYSCK:	LDAX	D
	CMP	M
	INX	H
	INX	D
	JNZ	SYSOUT
	DCR	B
	JNZ	RSYSCK
;
SYSOUT:	POP	B
	POP	D
	POP	H
	RET
;.....
;
;
	DS	64		;room for stack
STACK:	DS	2		;old stack stored here
SUBFLG	DB	00H		;flag to order sub file built
SUBPTR	DW	0000H		;pointer to end of sub file
GOTFLG:	DB	0
GOTNF:	DB	0
SYSTOO:	DB	0,0,0
SYSOK:	DB	'S  '	      ;sys suppression override chars
SETFLG:	DB	0		;1 => setup table
PRTFLG:	DB	0		;print only some
SYSFLG:	DB	0		;$sys attrib indicator
LFCB	DS	36H		;local fcb used by sub file
SUBBUF	DS	128		;buffer used by sub file write routines
NAMES	EQU	$		;names not to print are stored here..
				;..(i.e., the current dir)
;
; Note the names are initially built by the "D SET" command
;
	DB	0FFH	;end of table
;
;
; Miscellaneous BDOS equates
;
RDCON	EQU	1
DIO	EQU	6
PRINT	EQU	9
CONST	EQU	11
SELDSK	EQU	14
CLOSE	EQU	16
SRCHF	EQU	17
SRCHN	EQU	18
ERASE	EQU	19
READ	EQU	20
WRITE	EQU	21
MAKE	EQU	22
CURDSK	EQU	25
SETDMA	EQU	26
;
	END
