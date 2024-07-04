;**************** BYPASS CUSTOMIZING SECTION ************************
	ORG	100H
	JMP	START
;********************************************************************
;
; TITLE: DLABEL.ASM		Author: R.Bascom
;
P$LOGON	DB	'DLABEL 1.0   24/11/85',0Dh,0Ah,0Ah,'$'
;
; PURPOSE: To print an alphabetically sorted disk directory on a 
;	   label in small (condensed) font.
;
; FEATURE: (1)	The condensed font is used for the main directory.
;	   (2)	The program can be repeated, using the same drive
;		and optional filenames.  Allowing for labeling 
;		numerous disks at one time.
;
; USAGE:   DLABELER [D][FILENAME.TYP]
;
;		   	   D = disk (i.e. A:, B:, ect)
;		filename.typ = filename using conventional wildcards
;
TRUE	EQU	0FFh
FALSE	EQU	00h
;
;*********************** PROGRAM EQUATES ****************************
;
MAXFILS		EQU	255	;maximum number of directory entries
BDOS		EQU	5
FCB		EQU	5Ch     ;first file control block
;
CR		EQU	0Dh	;carriage return
LF		EQU	0Ah	;line feed
ESC		EQU	1Bh	;escape
BELL		EQU	7	;bell
CTL$C		EQU	3	;end of text
;
;
;*********************** BDOS EQUATES *******************************
;
B$CONIN		EQU	1	;read CON byte
B$CONOUT	EQU	2	;write CON byte
B$LISTOUT	EQU	5	;write PRN byte
B$DIRCONIO	EQU	6	;direct CON input and output
B$PRINTS	EQU	9	;write a $ terminated string to CON
B$CONST		EQU	11	;read CON status
B$RESETDSK	EQU	13	;reset disk system
B$SEARCHF	EQU	17	;search for first name match
B$SEARCHN	EQU	18	;search for next name match
;
;******************** CUSTOMIZING SECTION ***************************
;
V$COLUMNS	DB	60	;number of label columns (maximum of 
				;250 columns) based on char per inch
				;of condensed fontŠ;
V$ROWS		DB	8 	;number of label rows based on the
				;line spacing
;
V$SPACES	DB	1       ;lines btwn labels (based on line spacing)
;
;This string is the divider fence that is printed between filenames and can 
;be changed as desired.  The divider is not printed before the first or after
;the last filename on a line.  String can have a maximum of of 5 chars and
;must end with $.   NOTE the first byte is the char count.
;
V$FENCE	DB	3			;char count (# of divider chars)
	DB	' | '			;the divider chars
	DB	'$'			;end of string
	DB	0,0			;spares
;
;******************** PRINTER CONTROL STRINGS ***********************
;
;This string is used to set line spacing (usually to 9 LPI) and small print
;font (usually condensed).  It may include any printer characteristics you
;desire.  String can have a maximum of 15 chars and must end with $.
;
V$CONDENST:
	DB	ESC,'B',3		;set pitch to condensed (17 CPI)
	DB	ESC,'A',8		;set line spacing to 8/72
	DB	'$'			;end of string 
	DB	0,0,0,0,0,0,0,0,0,0,0	;spares
;
;This string is used to return printer to its normal line spacing (usually
;6 LPI) and normal print font (usually 10 CPI).  It may also include any 
;printer characteristics you desire.  String can have a maximum of 15 chars
;and must end with $.
;
V$RESETST:
	DB	ESC,'@'			;reset the printer
	DB	'$'			;end of string 
	DB	0,0,0,0,0,0,0,0,0,0,0,0	;spares
;
;****************** END OF CUSTOMIZING SECTION *************************

;***********************************************************************
;***********************************************************************
;		        M A I N   P R O G R A M
;***********************************************************************
;
START:
	LXI	SP,STACK	;get new stack
;
;save disk for restarting later
;
	LXI	H,FCB
	MOV	A,M
	STA	SAVEFCB
;
;type logonŠ;
	LXI	D,P$LOGON
	MVI	C,B$PRINTS
	CALL	BDOS
;----------------
;
;calculate label width (in number of filenames/fences across the label)
;
	LDA	V$FENCE		;number of fence chars
	MVI	H,12		;plus number chars for filename
	ADD	H
	MOV	B,A		;B = number of chars per filename/fence
;
	XRA	A		;clear flags
	LDA	V$COLUMNS	;number of columns
	CPI	251		;maximum number of columns is 250 (FAh)
	JNC	COLERR		;err if max num of colums is exceeded
	MOV	H,A	
	LDA	V$FENCE		;plus length of one fence
	ADD	H		;A = line length and one fence length
;
	MVI	C,0		;C is the dividend
	ANA	A		;prepare for divide - clear carry
;	
;mod divide A by B
;
LWID:
	SUB	B		;repeated subtraction
	JC	LWID1
	INR	C		;count the number of subtractions
	JMP	LWID
LWID1:
	MOV	A,C		;
	CPI	0		;check for zero filename width
	JZ	LWIDERR		;  then error
	STA	LBLWID		;  else save the width
;----------------
;
;check number of rows 
;
CKROWS:
	LDA	V$ROWS
	CPI	0
	JZ	ROWERR		;err if zero rows calculated
;----------------
;
;set maximum number of files
;
SETMFIL:
	LDA	V$ROWS		;get the number of filenames wide
	MOV	B,A
	LDA	LBLWID		;get the number of rows
	MOV	C,A
	XRA	A		;zero A and clear carry
SETMFIL1:Š	ADD	C
	JC	MFILERR		;error if count exceeds 255 (FFh)
	DCR	B
	JNZ	SETMFIL1
	STA	MAXFIL		;maximum possible filenames on a label
;----------------
;
;got something - set up the printer
;
	LXI	H,V$CONDENST	;set condensed print
	CALL	WRPRNT		;send initialization string to printer 
;----------------
;
;able to restart the program here using the same command tail
;
REINIT:
	MVI	A,0	
	STA	COUNT		;clear counters
	STA	SCOUNT
	STA	WCOUNT
	STA	LCOUNT
	STA	SWITCH
;----------------
;
;does the command tail exist?
;
	LDA	SAVEFCB		;restore disk
	STA	FCB
	LXI	H,FCB+1		;set pointer first char of FCB
	MOV	A,M
	CPI	' '
	JNZ	GOTFCB		;yes, comand tail exists
;
;command tail does not exist
;
	MVI	B,11		;initial filename and filetype count
QLOOP:
	MVI	M,'?'		;store '?' in FCB
	INX	H
	DCR  	B
	JNZ	QLOOP
;
;look up the FCB in the directory
;
GOTFCB:
	LDA	V$ROWS		;initialize # of lines remaining on
	STA	LCOUNT		;   label to full count
	MVI	C,B$SEARCHF 	;search for first name match
	LXI	D,FCB
	CALL	BDOS		;read first
	INR	A		;were there any?
	STA	TEMP		;save extent
	JZ	FNFERR		;didn't get any
	LDA	TEMP		;reload extent
;----------------Š;
;point to directory entry 
;
SOME:
	DCR	A		;undo previous INR A
	ANI	3		;make modulus 4
	ADD	A		;multiply
	ADD	A		;  by 32 because
	ADD	A		;  each directory
	ADD	A		;  entry is 32
	ADD	A		;  bytes long
	LXI	H,81H		;point to buffer (skip to FN/FT)
	ADD	L		;point to entry
	MOV	L,A		;save (can't carry to H)
	LDA	MAXFIL		;is there room in table for entry ?
	MOV	B,A
	LDA	COUNT
	CMP	B
	JZ	TMFERR		;err - too many files for the label
;
;move entry to table
;
	XCHG			;entry to DE
	LHLD	NEXTT		;next table entry to HL
	MVI	B,31		;entry length
TMOVE:
	LDAX	D		;get entry char
	MOV	M,A		;store in table
	INX	D
	INX	H
	DCR	B		;more?
	JNZ	TMOVE
	SHLD	NEXTT		;save updated table adx
	LDA	COUNT		;get previous count
	INR	A
	STA	COUNT
;
;read more directory entries		
;
	MVI	C,B$SEARCHN 	;search for next name match
	LXI	D,FCB
	CALL	BDOS		;read dir entry
	INR	A		;check for end (0FFh)
	JNZ	SOME		;more 
;----------------
;
;sort filenames
;
	LDA	COUNT		;init the order table
	STA	SCOUNT		;save as # to sort
	LXI	H,ORDER
	LXI	D,TABLE
	LXI	B,31		;entry length
BLDORD:	
	MOV	M,E		;save LO order adxŠ	INX	H
	MOV	M,D		;save HI order adx
	INX	H
	XCHG			;table adx to HL
	DAD	B		;point to next entry
	XCHG
	DCR	A		;more?
	JNZ	BLDORD		;  yes
SORT	XRA	A		;get a zero
	STA	SWITCH		;show none switched
	LDA	SCOUNT		;get count
	DCR	A		;use 1 less
	STA	TEMP		;save # to compare
	STA	SCOUNT		;save highest entry
	JZ	DONE		;exit if no more
	LXI	H,ORDER 	;point to order table
SORTLP	CALL	COMPR		;compare 2 entries
	CM	SWAP		;swap if not in order
	INX	H		;bump order
	INX	H		;  table pointer
	LDA	TEMP		;get count
	DCR	A
	STA	TEMP
	JNZ	SORTLP		;continue
;
;one pass of sort done
;
	LDA	SWITCH		;any swaps done?
	ORA	A
	JNZ	SORT
;
;sort is all done - print entries
;
DONE	LXI	D,ORDER		;DE point to 1st entry in ORDER
	PUSH	D		;Save DE
	LDA	LBLWID		;get initial count of filenames per line
	STA	WCOUNT		;   and save it for a counter
;----------------
;
;print the label
;
PRINT:
	MVI	C,B$CONST	;check status of keyboard
	CALL	BDOS		;are any keys pressed?
	DCR	A
	JZ	0		;yes, abort
	POP	D		;restore DE
	LDAX	D		;no - get memory byte addressed by DE
	MOV	L,A		;   and put in L
	INX	D		;move to next location in ORDER
	LDAX	D		;get memory byte addressed by DE
	MOV	H,A		;   and put in L
	INX	D		;move to next location in ORDER
	PUSH	D		;   and save DE
	MVI	B,8		;file name lengthŠ	CALL	TYPEIT		;type filename
	MVI	E,'.'
	CALL	TYPE  
	MVI	B,3		;get the filetype
	CALL	TYPEIT
;
;check for last directory entry
;
	LDA     COUNT		;decrement count of file names to print
	DCR	A
	STA	COUNT
	JZ	TOP		;exit if count is zero
;
;check for maximum directory entries on current row
;
WFENCE	LDA	WCOUNT		;decrement # of entries left on this
	DCR	A		;  line for filenames
	STA	WCOUNT
	JZ	NXTLIN		;no more room on line so skip divider fence
;
;divider fence goes to the printer
;
	LXI	H,V$FENCE+1	;since there is room for another filename 
  	CALL	WRPRNT		;   put divider fence btwn filenames
	JMP	PRINT
;
;end of current line
;
NXTLIN:
	CALL	CRLF		;output CR/LF 
	JMP	PRINT		;go to print next line and file name
;----------------
;
;completed printing the directory entries, now set up for next label
;
TOP:
	LDA	LCOUNT		;number of remaining lines in the label
	CPI	0		;done?
	JZ	TOP2		;yes, then space out btwn labels
	CALL	CRLF		;no, send out CR/LF 
	JMP	TOP		;try again
;
TOP2:
	LDA	V$SPACES	;get number of lines btween labels
TOP3:
	CPI	0		;done
	JZ	AGAIN		;yes, then ask if another label desired
	PUSH	A		;no, spaceing line count
	CALL	CRLF		;send out CR/LF
	POP 	A		;restore spacing line count
	DCR	A		;decrement count
	JMP	TOP3		;try again
;----------------
;
;do another label or exit?Š;
AGAIN:	
	LDA	SAVEFCB
	CPI	0
	JNZ	AGAIN1		;zero means use current disk
	LDA	4		;get curent disk and user
	ANI	0Fh		;bits 0-3 are the current disk
	INR	A
AGAIN1:
	ADI	'@'		;change to alfa 1->A, 2->B,...ect.
	STA	CDR1		;set drive in prompt
	CALL	ILPRT
	DB	'Mount another DISK TO BE LABELED in Drive '
CDR1:
	DB	'A:'		;hot-patched to show correct drive
	DB	' Ready? (Y/N): ',0
AGAIN2:
	MVI	C,B$DIRCONIO	;direct input from keyboard
	MVI	E,TRUE		;  true = read keyboard char 
	CALL	BDOS
	CPI	'N'		;N exits
	JZ	EXIT
	CPI	'n'		;and little n too
	JZ	EXIT
	CPI	' '		;accept space as yes
	JZ	AGAIN3
	CPI	CR		;accept CR as yes
	JZ	AGAIN3
	CPI	'Y'		;accept Y
	JZ	AGAIN3
	CPI	'y'		;and little y
	JNZ	AGAIN2		;anything else is not accepted
;
AGAIN3:
	CALL	ILPRT
	DB	CR,'                                          '
	DB	'                    ',CR,0
	MVI	C,B$RESETDSK	;reset the disks
	CALL	BDOS		
	JMP	REINIT	
;----------------
;
;reset the printer and return to CP/M 
;
EXIT:
	MVI	A,CR		;CR
	CALL	CRTOUT
	MVI	A,LF		;LF
	CALL	CRTOUT
	LXI	H,V$RESETST	;reset printer to Normal mode
	CALL	WRPRNT
	JMP	0
;--------------------------------------------------------------------
;
;			S U B R O U T I N E SŠ;
; Inline print subroutine
;
ILPRT:	XTHL			;get starting address of string to 'HL'
;
ILPLP:	MOV	A,M
	PUSH	H
	CALL	CRTOUT		;show the character on the CRT
	POP	H
	INX	H
	MOV	A,M
	ORA	A
	JNZ	ILPLP
	INX	H
	XTHL			;return address to top of stack
	RET
;----------------
;
; Displays one character on the CRT
;
CRTOUT:	PUSH	PSW		;save the character
	MVI	C,B$CONOUT
	MOV	E,A		;get the character into 'E' reg.
	CALL	BDOS		;show the character on the crt
	POP	PSW		;get the character back
	RET
;----------------
;
;char in E goes to the printer
;
TYPE	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,B$LISTOUT
	CALL	BDOS
	POP	H
	POP 	D
	POP	B
	RET
;----------------
;
;string specified by HL goes to the printer
;
WRPRNT	MVI	A,'$'
	CMP	M
	RZ 
	MOV	E,M
	CALL	TYPE
	INX	H
	JMP	WRPRNT
;----------------
;
;string specified by HL and length in B goes to the printer
;with any tag bits stripped off
;ŠTYPEIT:
	MOV	A,M		;get rid of any tag bits in name
	ANI	07Fh		; for print out
	MOV	E,A
	CALL	TYPE
	INX	H
	DCR	B
	JNZ	TYPEIT
	RET
;----------------
;
;CR/LF go to the printer and
;reset label width counter and decrement line counter
;
CRLF:
	MVI	E,CR		;get CR character in E
	CALL	TYPE		; and output it
	MVI	E,LF		;get LF character in E
	CALL	TYPE		; and output it
;
	LDA	LBLWID		;reset number of filenames across label
	STA	WCOUNT
;
	LDA	LCOUNT		;decrement line count
	DCR	A 
	STA	LCOUNT 
;
	RET
;---------------- 
;
;compare routine for sort
;
COMPR:
	PUSH	H		;save table adx
	MOV	E,M		;load LO
	INX	H
	MOV	D,M		;load HI
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
;
;BC and DE now point to entries to be compared
;
	XCHG
CMPLP:
	MOV	A,M		;get rid of any tag bit in name
	ANI	07FH		; before comparing names for sort
	MOV	M,A
	LDAX	B
	ANI	07FH
	CMP	M
	INX	H
	INX	B
	JZ	CMPLPŠ	POP	H
	RET			;cond code tells all
;----------------
;
;swap entries in the order table
;
SWAP:
	MVI	A,1
	STA	SWITCH		;show a swap was made
	MOV	C,M
	INX	H
	PUSH	H		;save table adx+1
	MOV	B,M
	INX	H
	MOV	E,M
	MOV	M,C
	INX	H
	MOV	D,M
	MOV	M,B
	POP	H
	MOV	M,D
	DCX	H		;back pointer to correct location
	MOV	M,E
	RET
;----------------
;
;		E R R O R   R O U T I N E S
;
COLERR:
	CALL	ILPRT
	DB	CR,LF,'++ YOUR SETTINGS ALLOW MORE THAN 250 COLUMNS ++'
	DB	BELL,0
	JMP	0
;
LWIDERR:
	CALL	ILPRT
	DB	CR,LF,'++ YOUR SETTINGS DO NOT ALLOW AT LEAST 12 COLUMNS ++'
	DB	BELL,0
	JMP	0
;
ROWERR:
	CALL	ILPRT
	DB	CR,LF,'++ YOUR SETTINGS DO NOT ALLOW ANY ROWS ON A LABEL ++'
	DB	BELL,0
	JMP	0
;
MFILERR:
	CALL	ILPRT
	DB	CR,LF,'++ YOUR SETTINGS ALLOW MORE THAN 255 FILENAMES ++'
	DB	BELL,0
	JMP	0
;
FNFERR:
	CALL	ILPRT	
        DB	CR,LF,'++ FILE(S) NOT FOUND ++',CR,LF,0Š	JMP	AGAIN		;try another disk or exit
;
TMFERR:
	CALL	ILPRT
	DB	CR,LF,'++ TOO MANY FILENAMES ++',CR,LF,0
	JMP	AGAIN		;try another disk or exit 
;
;
;
;	
;
NEXTT	DW	TABLE		;next table entry
LBLWID	DB	0		;label width = (V$COLUMNS+V$FENCE)/(12+V$FENCE)
MAXFIL	DB	0		;max number of disk filenames on one label
COUNT	DB	0		;entry count
SCOUNT	DB	0		;# to sort
WCOUNT	DB	0		;# of filename sapces left across line
LCOUNT	DB	0		;# of lines remaining on this Label
SWITCH	DB	0		;swap switch for sort
SAVEFCB DB	0		;save disk FCB
TEMP	DS	1
ORDER	DS	2*MAXFILS	;order table
	DS	50		;stack area
STACK
TABLE	DB	0		;read entries from here to top of BDOS
	END	100H
	