;
;		    D.ASM ver 2.9
;	    RESTRICTED DIRECTORY LIST PROGRAM
;		    (revised 08/12/82)
;
;D.COM is a directory list program, which writes
;4 or 5 entries on a line, separated by colons.
;  (THIS IS THE 'WHATSNEW' PROGRAM SEEN ON MANY RCPM SYSTEMS)
;
;The command contains an internal table of file names,
;which are not to be shown when just "D" is typed.
;(NOTE typing "D *.*" always shows all files)
;
;Why is this useful:  A typical CP/M disk contains many
;utility files: ed.com, asm.com, submit.com, etc.  When
;you do a directory listing, you typically aren't interested
;in seeing all those files, but rather just the "current"
;or "active" files.  This is what "D.COM" can do.
;
;NOTE: Direct CBIOS calls are used for input and output
;      in order to avoid echoing of inputted characters.
;      This keeps a noisy phone line from causing garbage
;      characters in the display.
;
;Revisions/updates: (in reverse order to minimize reading time)
;
;08/12/82 Added SUB file option to allow writing each new filename
;	  that appears in the "New Files" display to a .SUB file
;	  of the form:
;	  XSUB
;	  PIP
;	  $1=$2 Fn.Ft$3
;	  $1=$2 Fn.Ft$3
;	  etc.
;	  to allow a simple archive of new files to be performed
;	  by: SUBMIT D A:=B: [G1]
;	  Also repaired bug in EXIT routine and removed character
;	  'gobbler' routine so that program will work better with
;	  'type-ahead' BIOSes                 by Dave Hardy
;
;07/01/82 Modified TITLE feature to allow TITLE command to be
;	  easily changed.  Previous version had hard-coded TITLE
;	  command length and TITLE start.  Also removed TITSTART
;	  symbol (no longer needed) and cleaned up some of the
;	  comments (Dave Hardy)
;
;06/23/82 Added Title feature for disk.. allows you to set
;         the title for the disk.(See Below)
;                         Bob Bowerman.
;
;06/19/81 Added BIAS for modified or standard CP/M. Ted Shapin.
;
;06/13/81 Fixed names counter in files not found routine.
;	  (KBP).
;
;06/12/81 Changed routines for printing so that CTL-C abort
;	  will work properly.  Added ILPRT and TYPMEM routines
;	  to reduce program size.  (KBP)
;
;05/20/81 Increased system file security by increasing pasword
;	  option to 3 characters.  (By Howard Booker, W8IU)
;
;03/01/81 Added reset of DMA to 80H default on exit so D will
;	  work properly with submit.  Deleted CEXIT routine,
;	  which was no longer used.  Expanded documentation.
;	  (KBP)
;
;02/28/81 Mod. of 2/21 changed by popular demand to use of direct
;         BIOS calls for freezing and aborting output. (CS)
;
;02/21/81 Abort on receipt of control-C character only (to prevent
;	  premature exit on remote systems with noisy telephone
;	  connections). Charlie Strom
;
;12/23/80 Changed sign-on message, revised documentation. (KBP)
;
;12/22/80 Fixed stack and file extent problems.  Fully expanded
;	  macros so ASM may be used.  Fixed problem in LOK routine
;	  By Keith Petersen, W8SDZ.
;
;12/07/80 Added drive select byte and expanded move macro in WRBACK
;	  routine.  Also added "LOK" command.  By Ron Fowler.
;
;12/02/80 Added "NOSYS" equate to ignore system files, code to strip
;	  attributes from files for CP/M 2.x, added date display and
;	  print options.  Fixed up display format.  By Ron Fowler
;
;12/01/80 Added "FILES NOT FOUND" feature of updated
;	  D.ASM of Ward Christensen.  By Ron Fowler.
;
;11/23/78 Originally written by Ward Christensen.
;
;===================================================
;
;Use:	D *.*	prints all names, 5 across.
;
;	D *.ASM prints selected files just like DIR.
;
;	D SET	builds a table (in D.COM) of all
;		names currently on the disk. (see *NOTE).
;
;	D SET <DATE>  adds the date for printing whenever
;		D is called by 'A>D<CR>' with no options.
;		If the date field is left blank, it will
;		be ignored. Note that the date must be 8
;		characters or less (see *NOTE).
;
;	D TIT <TITLE FOR DISK> sets an internal disk title
;		which prints out each time the program is
;		run (if a title has been set).(maximum of
;               circa 70 chars please although it will
;               handle a full CP/M input line.
;
;		NOTE: To get rid of title (and accompanying
;		print put type 'D TIT' and the title is
;               set to null.
;
;	D ADD FN.FT  adds a name to the table in
;		D.COM, so FN.FT won't be listed
;		by the 'D' command (see *NOTE).
;
;	D DEL FN.FT  deletes a name from the table
;		in D.COM, so if FN.FT is in the
;		directory, it will be listed by 'D'
;		(see *NOTE).
;
;	D SUB	causes a file named 'D.SUB' to be generated on
;		the currently logged-in drive.  The file contains
;		all of the 'New Files' names, and is of the form:
;
;		XSUB
;		PIP
;		$1<fn1.ft>$2
;		$1<fn2.ft>$2
;		$1<fn3.ft>$2
;		etc.
;
;		D.SUB can be used to archive 'New Files' with a
;		simple command line like:
;		SUBMIT D B:=A: [G5]
;		which would PIP all of the new files from B5: to A:
;
;	D	lists the directory, showing
;		only those files NOT in D.COM, as
;		put there by 'D SET' or 'D ADD FN.FT'
;
;*NOTE: the program must write itself back to disk,
;modified, so your disk must not be write protected.
;
;------------------------------------------------
;
;Examples:  Suppose your disk has: 
;	D.COM
;	ASM.COM
;	ED.COM		on it initially.
;	LOAD.COM
;	DDT.COM
;
;You would type:  D SET
;to set these names into the D.COM program.
;
;Typing "D" would then list:
;
;	-->New files
;	A: ++NONE++
;
;	-->Deleted files
;	A: ++NONE++
;
;Suppose you ED TEST.ASM, ASM it, and LOAD it.
;Typing D would then list:
;
;	-->New files
;	A: TEST    ASM : TEST    BAK : TEST    HEX : TEST    COM
;
;	-->Deleted files
;	A: ++NONE++
;
;i.e. it tells you of the "current" files on the disk.
;
;Now, supposing you wanted to add TEST.COM as a "regular"
;file on your disk.  Type:
;
;	D ADD TEST.COM
;
;Now, typing D will show:
;
;	-->New files
;	A: TEST    ASM : TEST    BAK : TEST    HEX
;
;	-->Deleted files
;	A: ++NONE++
;
;i.e. TEST.COM is now considered a "permanent" file.
;
;-----
;
;Now, suppose you accidentally erased ASM.COM from your
;disk.  Typing D gives:
;
;	-->New files
;	A: TEST    ASM : TEST    BAK : TEST    HEX
;
;	-->Deleted files
;	A: ASM     COM
;
;showing you are missing one of the "regular" files.
;
;If, in fact, you didn't want ASM.COM to be on the disk,
;type:
;
;	D DEL ASM.COM
;
;which will delete the name from the D.COM table, so ASM.COM
;won't show up as "deleted".
;
;===================================================
;
;	SPECIAL NOTES FOR REMOTE SYSTEM USE:
;
;If you keep a dedicated copy of this program on each drive of
;your remote system, you can 'dedicate' each copy of this program
;to a drive by filling in the byte at 103H with the drive number.
;This prevents such things as:
;
;	A>D B:
;		or
;	B>A:D
;
;Do this by using the command:
;
;	A>D LOK A:	to lock to a drive
;		or
;	A>D LOK 	to unlock
;
;If the conditional 'NOSYS' is set TRUE, $SYS files in CP/M 2.x
;will be ignored in both directory listings and when the "ADD"
;option is invoked, unless the override char is specified.  This
;allows D.COM to be used as a "WHAT'S NEW" program for remote CP/M
;systems, where the $SYS files must not be listed.
;
;Examples:
;	A>D *.* S	 displays everything
;	A>D SET S	 puts ALL files in table
;	A>D SET 12/23/80 sets date for reference
;		(if you use 'D SET S', you lose the date option..
;		..sorry about that).
;
;If you use this program on a remote system, you will likely
;want to change the commands (ADD, DEL, and SET) for security.
;You will also want to change the $SYS suppress override character.
;You may also want to change the name of the program to make the
;name itself more informative, e.g. "D.COM".
;
;-->IMPORTANT: If you want the program to be 'TAG'ed after every
;D SET (so it cannot be taken by XMODEM), see the note at label
;"WRBACK" for setting the F1 bit in the filename itself.
;
;Note that this program defines its own name for write-back
;purposes under the label "WRBACK".
;
;===================================================
;
;NOTE: If you add improvements or otherwise update
;this program, please modem a copy of the new file
;to "TECHNICAL CBBS" in Dearborn, Michigan - phone
;313-846-6127 (110, 300, 450 or 600 baud). Use the
;filename D-XX.NEW.  (KBP)
;
;===================================================
;
;  Define some stuff
FALSE	EQU	0
TRUE	EQU	NOT FALSE
BIAS	EQU	0		;For STD CP/M or 4200H for ALTCPM
BDOS	EQU	5 + BIAS	;CP/M's BDOS access jump
FCB	EQU	5CH + BIAS	;CP/M's file control block
FCBRNO	EQU	FCB + 32	;Rec # in FCB
CPMBUFF	EQU	80H + BIAS	;CP/M command line buffer
CR	EQU	13		;Carriage Return
LF	EQU	10		;Line Feed
;
;  Set the following for your system:
NOSYS	EQU	TRUE	;TRUE means ignore $SYS files
FENCE	EQU	':'	;Character printed between filenames in display
NPL	EQU	4	;Number of names to be displayed on each line
;
; The leader string for the SUB file (XSUB, PIP) is located at label SUBF4
;
	ORG	100H+BIAS
;
DENTRY:	JMP	AROUND
;
DRIVE:	DB	0	;<---DRV # IS PUT HERE IF DEDICATED
;			(this can be done with the LOK command)
;Init local stack
AROUND:	LXI	H,0	;HL=0
	DAD	SP	;HL=STACK
	SHLD	STACK	;SAVE STACK POINTER
	LXI	SP,STACK ;INIT LOCAL STACK
;
;Initialize direct CBIOS calls
	LHLD	1+BIAS
	LXI	D,3
	DAD	D	;HL=CONSTAT
	SHLD	TYPES+1
	DAD	D	;HL=CONIN
	SHLD	CIC+1
	DAD	D	;HL=CONOUT
	SHLD	TYPEC+1
;
;Print ID message
	CALL	ILPRT	;PRINT:
	DB	'D ver 2.9',CR,LF
	DB	'CTL-S pauses, CTL-C aborts',CR,LF,0
;
;Print Disk Title
;
PTITL	LXI	H,DTITLE	;get title address
	MOV	A,M	;load it
	CPI	0	;end of string
	JZ	CONT	;don't print title
	CALL	ILPRT	;print heading
	DB	'Title: ',0
	LXI	H,DTITLE	;load it again
LOOP1:	MOV	A,M	;...
	CPI	0	;zero?
	JZ	ENDPRT	;all done
	CALL	TYPE	;type this char
	INX	H	;next char
	JMP	LOOP1	;repeat ...

DTITLE:	DB	0	;storage for
	DS	7FH	;title
ENDPRT:	CALL	CRLF
;
;Set file control block
CONT:	LDA	DRIVE
	ORA	A	;Non-dedicated?
	JZ	NOND	;Jump if so
	STA	FCB
;
NOND:	LHLD	FCB+17	;Get $SYS override characters
	SHLD	SYSTOO	;and save for later
	LDA	FCB+19
	STA	SYSTOO+2
;
;See if request to add name to list
	LXI	H,FCB+1
	CALL	ADDCM2
ADDCM:	DB	'ADD        '	;11 characters (padded with spaces)
;
ADDCM2:	POP	D	;Make DE point to ADD command
	LXI	B,ADDCM2-ADDCM	;BC gets length of string
	CALL	COMPR
	JNZ	NOADD
;
;Got request to add name to table
	CALL	DELNAM	;FIRST, DELETE THE NAME
	CALL	FINDFF	;FIND END OF TABLE
	XCHG		;ADDR TO DE
;
;Move name to table
	LXI	H,FCB+17
	LXI	B,11
	CALL	MOVER
	MVI	A,0FFH
	STAX	D	;SET NEW END
	JMP	WRBACK	;WRITE PROGRAM BACK
;
;See if request to add title to disk
;
NOADD:	LXI	H,FCB+1
	CALL	NOADD1A
NOADD1B:
	DB	'TIT'		;MUST be your command to set title
TITLEN	DB	'        '	;# spaces here + length of your command = 11
NOADD1A:
	POP	D	;GET TO
	LXI	B,NOADD1A-NOADD1B
	CALL	COMPR
	JNZ	NOADD2A
;
;Process the title or erase it, if none given
;
	LXI	H,CPMBUFF	;get length
	MOV	A,M		;move it to A
	SUI	TITLEN-NOADD1B+1	;but don't include the title command
	JZ	TITNO		;no title?
	LXI	H,CPMBUFF+TITLEN-NOADD1B+2	;Get START OF DTITLE
	LXI	B,0000
	MOV	C,A		;Put length in BC
	LXI	D,DTITLE		;Place to store
	CALL	MOVER		;Move title in storage
	MVI	A,00		;And Mark End
	STAX	D		;Of string
	JMP	WRBACK		;And write back to disk
;        
;No title - Clear title
;
TITNO:	LXI	H,DTITLE		;load in space
	MVI	M,00		;store end of string
	JMP	WRBACK		;and write back to disk
;
;See if request to lock D.COM to a drive
;
NOADD2A:
	LXI	H,FCB+1
	CALL	NOADD3
NOADD2:	DB	'LOK        '
;
NOADD3:	POP	D	;GET TO
	LXI	B,NOADD3-NOADD2
	CALL	COMPR
	JNZ	NOLOK
;
;Got request to lock
	LDA	FCB+16
	STA	DRIVE
	STA	FCB
	JMP	WRBACK
;
;See if request to DEL name from list
;
NOLOK:	LXI	H,FCB+1
	CALL	NOLOK3
NOLOK2:	DB	'DEL        '
;
NOLOK3:	POP	D	;GET TO
	LXI	B,NOLOK3-NOLOK2
	CALL	COMPR
	JNZ	NODEL
;
;Got request to delete a name from the file
	CALL	DELNAM ;DELETE THE NAME
	JNC	WRBACK	;WRITE BACK IF OK
	CALL	MSGXIT
	DB	'++NAME NOT IN TABLE++$'
;
;See if request is to make SUB file
;
NODEL:	LXI	H,FCB+1
	CALL	SUBF3
SUBF2:	DB	'SUB        '
SUBF3:	POP	D
	LXI	B,SUBF3-SUBF2
	CALL	COMPR
	JNZ	NOSUB
;
;Got request to make SUB file, so say so, and set flag to force it
	CALL	SAYSUB		;Notify console that SUB file will be made
	DB	'Writing SUBMIT file...',CR,LF,'$'
SAYSUB:	POP	D
	MVI	C,9
	CALL	BDOS
	MVI	A,0FFH		;Set SUBFLG to tell program to make SUB file
	STA	SUBFLG
	LXI	H,SUBBUF	;Write SUB file start into file buffer
	CALL	SUBF5		;(XSUB, PIP, etc.)
SUBF4:	DB	'XSUB',CR,LF,'PIP',CR,LF
SUBF5:	POP	D		;Use MOVER routine to copy it into SUB buffer
	XCHG
	LXI	B,SUBF5-SUBF4
	CALL	MOVER
	XCHG
	SHLD	SUBPTR		;Save SUB file buffer pointer
	LXI	H,FCB+1		;Then fill tail in with spaces to make
	MVI	C,11		;  program think that no options chosen
NXSPC:	MVI	M,' '
	DCR	C
	INX	H
	JNZ	NXSPC
	MVI	C,36H		;Initialize local FCB
	LXI	H,LFCB		;(Can't use default, because commands there)
NXFCB:	MVI	M,0
	DCR	C
	INX	H
	JNZ	NXFCB
	LXI	D,LFCB+1	;Set up local FCB to write D.SUB file
	CALL	UWR2
UWR1:	DB	'D       SUB',0
UWR2:	POP	H
	LXI	B,UWR2-UWR1
	CALL	MOVER
	MVI	C,ERASE		;Erase old file, if it exists
	LXI	D,LFCB
	CALL	BDOS
	XRA	A
	STA	LFCB		;Set up to write to DEFAULT drive
	STA	FCBRNO		;Initialize record number
	MVI	C,MAKE		;Create the file
	LXI	D,LFCB
	CALL	BDOS
	JMP	NOSET		;Then jump off to display names as usual
;
;See if request to set up table from directory
;
NOSUB:	LXI	H,FCB+1
	CALL	NODEL3
NODEL2:	DB	'SET        '
;
NODEL3:	POP	D	;GET TO
	LXI	B,NODEL3-NODEL2
	CALL	COMPR
	JNZ	NOSET
;
;Got request to setup table.
;Move the date (may be blank).
	LXI	H,FCB+17
	LXI	D,DATE
	LXI	B,8
	CALL	MOVER
	MVI	A,1	;TURN ON..
	STA	SETFLG	;..SET FLAG
	MVI	A,0FFH	;CLEAR..
	STA	NAMES	;..NAMES TABLE
	CALL	FILLQ	;MAKE FCB '????????.???'
;
;
NOSET:	LDA	FCB+1	;Get PRTFLG
	SUI	' '
	STA	PRTFLG
	PUSH	PSW
	CZ	HEAD1
	POP	PSW
	JNZ	GOTNAM
	CALL	FILLQ	;MAKE NAME ????????.???
;
GOTNAM:	LDA	FCB
	ORA	A
	JZ	NODISK
	DCR	A
	MOV	E,A
	MVI	C,SELDSK
	CALL	BDOS
;
NODISK:	MVI	B,NPL	;NAMES PER LINE
	CALL	LINMRK
	MVI	C,SRCHF
	JMP	CALLIT
;
LINE:	MVI	B,NPL	;NAMES PER LINE
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
;Check for $SYS attribute, then clear all attributes
	PUSH	H
	LXI	D,9	;SYS ATT OFFSET
	DAD	D
	MOV	A,M
	ANI	80H
	STA	SYSFLG
	POP	H	;RETRIEVE FILENAME PTR
	PUSH	H
	MVI	E,11	;11 CHARS IN FILENAME
;
ATTLP:	MOV	A,M	;PICK UP CHAR
	ANI	7FH	;KILL ATTRIBUTE
	MOV	M,A	;PUT BACK DOWN
	INX	H
	DCR	E
	JNZ	ATTLP
	POP	H
;
;See if name is to be printed
	XCHG		;NAME POINTER TO DE
	LDA	SETFLG	;REQUEST TO SETUP TABLE?
	ORA	A
	JNZ	SETUP	;GO SET ENTRY INTO TABLE
	LDA	PRTFLG
	ORA	A
	JNZ	GOPRNT	;EXPLICIT REQUEST FOR ALL
	PUSH	D
	LXI	H,NAMES
;
CKNEXT:	POP	D	;GET NAME POINTER
	POP	B
	PUSH	B
	MOV	A,M	;END OF TABLE?
	INR	A	;WAS IT 0FFH?
	JZ	GOPRNT
	MVI	B,0
	MVI	C,11	;NAME LENGTH
	PUSH	D
;
CKLP:	LDAX	D
	CMP	M
	JNZ	NOMACH
	INX	D
	INX	H
	DCR	C
	JNZ	CKLP	;LOOP FOR 11 CHARS
;
;Got match, mark it found and don't print it
	LXI	D,-11	;POINT BACK TO NAME
	DAD	D
	MVI	M,0	;MARK IT FOUND
	POP	D	;POP POINTER
	POP	B
	JMP	NEXT	;SKIP THE NAME
;
;Name didn't match, try next
;
NOMACH:	DAD	B	;POINT TO NEXT NAME
	JMP	CKNEXT
;
;Print the name
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
	ENDIF		;NOSYS
;
;
DONAME:	LDA	SUBFLG	;See if SUB file is to be made
	ORA	A
	CNZ	NAMSUB	;If so, then write the name into the SUB buffer
	MVI	A,1	;SAY WE GOT ONE
	STA	GOTFLG
	MVI	C,8
	XCHG		;NAME BACK TO HL
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
;
;Write the filename pointed to by DE into the SUB file buffer
;  in the format: $1<fn.ft>$2<cr><lf>
NAMSUB:	PUSH	H	;Save HL (whatever's in it)
	PUSH	D	;Save filename pointer
	PUSH	B	;Save BC (whatever's in it)
	LHLD	SUBPTR	;Point HL to SUB buffer (DE points to filename)
	MVI	C,8	;Load counter for 8 characters of filename
	MVI	M,'$'	;First write '$1'
	CALL	INCPTR	;Increment file buffer pointer and write if full
	MVI	M,'1'
	CALL	INCPTR
SNAM:	LDAX	D	;Get a character of the name
	CPI	' '	;Don't transfer spaces to SUB buffer
	JZ	SNAM2
	ANI	7FH	;Trim off any nasty attributes
	MOV	M,A	;Put the character into the SUB buffer
	CALL	INCPTR	;Point to next SUB location
SNAM2:	INX	D	;Point to next character of filename
	DCR	C	;Decrement filename counter
	JNZ	SNAM	;Continue until all 8 characters read
	MVI	M,'.'	;Put a '.' into the SUB buffer to separate fn & ft
	CALL	INCPTR	;Point to next location in SUB buffer
	MVI	C,3	;Now do the 3 character long filetype
SNAM3:	LDAX	D
	CPI	' '
	JZ	SNAM4
	ANI	7FH
	MOV	M,A
	CALL	INCPTR
SNAM4:	INX	D
	DCR	C
	JNZ	SNAM3
	MVI	M,'$'	;Then write '$2<cr><lf>' on the end of the name
	CALL	INCPTR
	MVI	M,'2'
	CALL	INCPTR
	MVI	M,CR
	CALL	INCPTR
	MVI	M,LF
	CALL	INCPTR
	SHLD	SUBPTR	;Save the new SUB buffer pointer
	POP	B	;Restore all the registers
	POP	D
	POP	H
	RET		;Then return back to DONAME
;
;Increment the HL file buffer pointer, and write the buffer if full
;
INCPTR:	INX	H		;See if buffer is full
	MVI	A,(SUBBUF+80H) AND 0FFH
	CMP	L	;(See if LSH of HL = LSH of SUBBUF+80H)
	RNZ			;Return if buffer not full, else flush to disk
WRTSBF:	LXI	H,SUBBUF	;Reset pointer to start of buffer
WRTSB2:	PUSH	H
	PUSH	D
	PUSH	B
	LXI	D,SUBBUF	;Set DMA address to SUB buffer
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,LFCB		;Write the buffer to disk
	MVI	C,WRITE
	CALL	BDOS
	LXI	D,CPMBUFF	;Now set DMA address back to default
	MVI	C,SETDMA	; so that other routines can read directory
	CALL	BDOS
	POP	B
	POP	D
	POP	H
	ORA	A		;Notify console and abort if write error
	JNZ	WRERR
	RET
;
CKNONE:	LDA	GOTFLG		;Some new files found?
	ORA	A
	JNZ	NOTFND		;Jump if yes
	LDA	PRTFLG		;Print names?
	ORA	A
	JNZ	NOTFND		;Jump if yes
	CALL	ILPRT		;Else say no new files found and fall through
	DB	'++NONE++',CR,LF,0
;
;Print the files not found
;
NOTFND: LDA	SETFLG	;IS THIS 'D SET'?
	ORA	A
	JNZ	FINI	;DONE IF SO
	LDA	PRTFLG	;ARE WE PRINTING?
	ORA	A
	JNZ	CKNON2	;DONE IF NOT
;
;If this D.COM is dedicated ("DRIVE" is non-zero),
;then be sure to print the "FILES NOT FOUND"
	LDA	DRIVE
	ORA	A
	JNZ	NOCHK
	LDA	FCB	;DRIVE SPECIFIED?
	ORA	A
	JNZ	FINI	;SKIP NOT FOUND IF SO
;
NOCHK:	CALL	HEAD2	;PRINT NOT FND HEADER
	LXI	H,NAMES ;START OF TABLE
	LXI	D,11
;
LINE2:	MVI	B,NPL
	CALL	LINMRK
;
NEXT2:	MOV	A,M	;FIRST CHAR OF NAME
	ORA	A	;MARKED FOUND?
	JZ	NOPRNT	;JUMP IF SO
	INR	A	;CHECK FOR TABLE END
	JZ	CKNON2	;JUMP IF END
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
;
;Print header
;
HEAD1:	CALL	ILPRT	;PRINT:
	DB	CR,LF,'-->New files',0
	JMP	HEAD3
;
HEAD2:	CALL	ILPRT	;PRINT:
	DB	CR,LF,CR,LF,'-->Deleted files',0
;
HEAD3:	LDA	DATE
	CPI	' '
	JZ	NODATE
	CALL	SYSCK
	JZ	NODATE
	CALL	ILPRT	;PRINT:
	DB	' since '
DATE:	DB	'        '	;EIGHT SPACES
	DB	0		;STRING TERMINATOR
;
NODATE: MVI	A,':'
	CALL	TYPE
	JMP	CRLF
;
CKNON2: LDA	GOTNF
	ORA	A
	JNZ	FINI	;JMP IF GOT NO 'NOT FOUND'S
	LDA	PRTFLG
	ORA	A
	JNZ	FINI
	CALL	ILPRT	;PRINT: (THEN FALL INTO 'FINI')
	DB	'++NONE++',CR,LF,0
;
;Finished.  If building table, write back.
;           If making a SUB file, then flush the file buffer and close it.
FINI:	LDA	SUBFLG	;See if SUB file is to be written
	ORA	A
	JNZ	WRTSUB	;Jump if so,
	LDA	SETFLG	;Else see if SET was performed
	ORA	A
	JZ	EXIT	;Jump out if not,
	JMP	WRBACK	;Else write the program back to disk
;
;Write the SUB file to the currently logged in disk as 'D.SUB'
WRTSUB:	LHLD	SUBPTR	;Fill unused part of last sector with EOF's
	XCHG
	LXI	H,SUBBUF+7FH
WNXTS:	MVI	M,1AH
	MOV	A,L
	DCX	H
	CMP	E
	JNZ	WNXTS
	CALL	WRTSB2	;Write the last sector to disk
	MVI	C,CLOSE	;Close the file
	LXI	D,LFCB
	CALL	BDOS
	INR	A	;If close error, then notify console and abort
	JZ	BADWCL
	JMP	EXIT	;Exit back to CP/M
;
BADWCL:	CALL	MSGXIT
	DB	'BAD CLOSE, SUB file incomplete$'
;
;Set up the name in the table
;
SETUP:
	IF	NOSYS
	CALL	SYSCK
	JZ	SETU2
	LDA	SYSFLG
	RAL
	JC	SETSKP
	ENDIF		;NOSYS
;
SETU2:	CALL	FINDFF	;FIND END OF TABLE
	XCHG		;SETUP FOR MOVE
;(HL = name, DE = end of table)
	LXI	B,11
	CALL	MOVER
	MVI	A,0FFH	;GET TABLE END FLAG
	STAX	D	;STORE IT
;
SETSKP: POP	B	;DELETE STACK GARBAGE
	JMP	NEXT	;GET NEXT ENTRY
;
;Routine to type 'C' characters from memory (HL)
;
TYPMEM:	MOV	A,M
	CALL	TYPE
	INX	H
	DCR	C
	JNZ	TYPMEM
	RET
;
;Inline print routine - prints string pointed to
;by stack until a zero is found.  Returns to caller
;at next address after the zero terminator.
;
ILPRT:	XTHL		;SAVE HL, GET MSG ADRS
;
ILPLP:	MOV	A,M	;GET CHAR
	CALL	TYPE	;OUTPUT IT
	INX	H	;POINT TO NEXT
	MOV	A,M	;TEST
	ORA	A	;..FOR END
	JNZ	ILPLP
	XTHL		;RESTORE HL, RET ADDR
	RET		;RET PAST MSG
;
CRLF:	CALL	ILPRT	;PRINT:
	DB	CR,LF,0
	RET
;
SPACE:	MVI	A,' '	;FALL INTO 'TYPE'

;Print character in A to console
;
TYPE:	PUSH	B
	PUSH	D
	PUSH	H
	MOV	C,A	;CHAR TO C FOR CBIOS
TYPEC:	CALL	$-$	;SUPPLIED AT START
;
;See if console key pressed
;
TYPES:	CALL	$-$	;SUPPLIED AT START
	ORA	A	;KEY PRESSED?
	CNZ	CKKB	;YES, SEE WHICH ONE
	POP	H
	POP	D
	POP	B
	RET
;
CKKB:	CALL	CI	;GET CHAR
	CPI	'S'-40H	;PAUSE?
	CZ	CI	;YES, GET NEXT CHAR
	CPI	'C'-40H	;ABORT?
	RNZ		;NO, RETURN
	CALL	MSGXIT
	DB	CR,LF,'++ABORTED++$'
;
;Move (BC) bytes from (HL) to (DE)
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
;
;Compare routine
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
	RET		;EQUAL MEANS Z=1
;
;Routine to find 0FFH at end of table
;
FINDFF:	LXI	H,NAMES
;
FINDLP:	MOV	A,M
	INX	H
	INR	A	;0FFH?
	JNZ	FINDLP
	DCX	H	;BACK UP TO TABLE END
	RET
;
;Delete the name from the table
;
DELNAM:	LXI	H,NAMES
;
DELLP:	MOV	A,M
	CPI	0FFH
	STC
	RZ		;NOT FOUND
	LXI	D,FCB+17
	LXI	B,11
	CALL	COMPR
	JZ	DELETE
	DAD	B	;CALC NEXT
	JMP	DELLP
;
;Delete the name
;
DELETE:	XCHG		;NEXT NAME TO DE
	LXI	H,-11	;TO BACK UP..
	DAD	D	;..TO NAME TO DEL
;
DELCH:	LDAX	D
	MOV	M,A
	INX	H
	INX	D
	INR	A	;MOVED THE 0FFH?
	JNZ	DELCH
	ORA	A	;SHOW FOUND
	RET
;
;Fill FCB with all '?'
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
;
;Write back the program - note that you may set any of the
;CP/M 2.x attribute bits in the file name (be sure to define
;all 11 characters of the name).
;
WRBACK: LXI	D,FCB+1
	CALL	WRBK2
WRBK1:	DB	'D'+80H		;<--PUT 'D'+80H HERE TO SET TAG
	DB	'       COM'	;SEE COMMENT ABOVE
	DB	0		;EXTENT NUMBER
;
WRBK2:	POP	H
	LXI	B,WRBK2-WRBK1
	CALL	MOVER
	MVI	C,ERASE
	LXI	D,FCB
	CALL	BDOS
	XRA	A	;GET 0
	STA	SETFLG	;CLEAR THE FLAGS..
	STA	GOTFLG
	STA	GOTNF
	STA	SYSTOO
	STA	FCBRNO	;ZERO RECORD NUMBER
	MVI	C,MAKE
	LXI	D,FCB
	CALL	BDOS
;
;Before writing back, find end of table
	CALL	FINDFF
	MOV	B,H	;B=END PAGE
	INR	B	;FOR COMPARE
	LXI	D,100H+BIAS	;STARTING ADDR
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
	ORA	A	;SUCCESSFUL WRITE?
	JNZ	WRERR	;..NO
	LXI	H,80H	;POINT TO..
	DAD	D	;..NEXT BLOCK
	XCHG		;ADDR TO DE
	MOV	A,D	;GET PAGE
	CMP	B	;PAST TABLE END?
	JC	WRLP	;LOOP UNTIL DONE
	MVI	C,CLOSE
	LXI	D,FCB
	CALL	BDOS
	INR	A	;SUCCESSFUL CLOSE?
	JZ	BADCLS	;..NO, PRINT ERR MSG
	CALL	MSGXIT ;OK, EXIT W/MSG
	DB	'++DONE++$'
;
WRERR:	CALL	MSGXIT
	DB	'++WRITE ERROR++$'
;
BADCLS:	CALL	MSGXIT
	DB	'++BAD CLOSE, D.COM CLOBBERED!!++$'
;
;Get console input via direct CBIOS call
;
CI	PUSH	B	;CONSOLE INPUT
	PUSH	D
	PUSH	H
CIC	CALL	$-$	;SUPPLIED AT START
	POP	H
	POP	D
	POP	B
	RET
;
;Exit with message (error or informational)
;
MSGXIT:	POP	D	;GET MSG
	MVI	C,PRINT
	CALL	BDOS
;
;Exit, restoring DMA and stack, then return to CCP
;
EXIT:	LXI	D,CPMBUFF	;RESET DMA ADR TO NORMAL
	MVI	C,SETDMA
	CALL	BDOS
	LHLD	STACK	;GET OLD STACK
	SPHL		;RESTORE IT
	RET		;Return to CCP
;
LINMRK: PUSH	B
	PUSH	D
	PUSH	H
	LDA	FCB	;GET DRIVE NAME FROM FCB
	ORA	A	;ANY THERE?
	JNZ	GOTDRV	;YES, GO PRINT IT
	MVI	C,CURDSK ;ELSE GET CURRENT DISK
	CALL	BDOS
	INR	A	;MAKE 'A'=1
;
GOTDRV:	ADI	40H	;MAKE ASCII
	CALL	TYPE	;PRINT DRIVE NAME
	CALL	ILPRT	;PRINT
	DB	': ',0
	POP	H
	POP	D
	POP	B
	RET
;
;Test for system file override
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
;
	DS	64	;ROOM FOR STACK
STACK:	DS	2	;OLD STACK STORED HERE
SUBFLG	DB	00H	;Flag to order SUB file built
SUBPTR	DW	0000H	;Pointer to end of SUB file
GOTFLG:	DB	0
GOTNF:	DB	0
SYSTOO:	DB	0,0,0
SYSOK:	DB	'S  '	;SYS SUPPRESSION OVERRIDE CHARS
SETFLG:	DB	0	;1 => SETUP TABLE
PRTFLG:	DB	0	;PRINT ONLY SOME
SYSFLG:	DB	0	;$SYS ATTRIB INDICATOR
LFCB	DS	36H	;Local FCB used by SUB file write routines
SUBBUF	DS	128	;Buffer used by SUB file write routines
NAMES	EQU	$	;Names NOT to print are stored here (i.e. current DIR)
;
;Note the names are initially built by the "D SET" command
;
	DB	0FFH	;END OF TABLE
;
;  Miscellaneous BDOS equates
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
