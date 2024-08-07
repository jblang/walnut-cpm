;
;			DIRS.ASM
;		     revised 10/15/80
;
;		SORTED DIRECTORY PROGRAM
;		by Keith Petersen, W8SDZ
;
;DISPLAY FORMAT IS SAME AS CP/M 2.x DIR, EXCEPT IS SORTED
;ALPHABETICALLY. SUGGESTED AS A REPLACEMENT FOR THE "DIR"
;COMMAND IN CP/M-2. PRESENT VERSION ALLOWS MAX. OF 256 NAMES.
;
;PRINTS A 4-WIDE DIRECTORY, SORTED ALPHABETICALLY.
;COMPATIBLE WITH CP/M 1.4 AND 2.x. IGNORES "SYS" FILES.
;
;BASED ON 'FMAP' BY WARD CHRISTENSEN.
;
;DIRS FILENAME.FILETYPE or just DIRS
;
;ALLOWS '*' OR '?' TYPE SPECIFICATIONS
;DRIVE NAME BY ALSO BE SPECIFIED
;
; 10/15/80 - Trap file table overflow into BDOS (should only be
;		a problem with MP/M, where TPA can be tiny). (BRR)
; 10/01/80 - Say 'File not found.' instead of 'NO FILE' and
;		display user number heading if CHKUSR enabled.
;		Take 'NO FILE' path if first search succeeds,
;		but nothing qualifies for the sort.
;		(BRR)
; 09/08/80 - CHKUSR conditional assembly added to force match of
;		current user number, as required in MP/M to
;		prevent user 0 files from showing up in all
;		areas.  Also used in CP/M 2.2 systems containing
;		BDOSPAT.  (BRR)
; 09/07/80 - Modified to assemble with RMAC and externalized
;		page 0 for use with MP/M.  (Must be linked
;		with PG0EQU.ASM)
;	     Also modified to allow (via conditional assembly)
;		'S' option to display system files.
;	     (by Bruce R. Ratoff)
;
;
FALSE	EQU	0		;DEFINE LOGICAL FALSE
TRUE	EQU	NOT FALSE	;DEFINE LOGICAL TRUE
;
ALTCPM	EQU	FALSE	;PUT TRUE HERE FOR H8 OR TRS-80
RMAC	EQU	TRUE 	;PUT TRUE HERE FOR ASSEMBLY BY RMAC
SOPT	EQU	TRUE 	;PUT TRUE TO ALLOW 'DIR *.* S' FORM
CHKUSR	EQU	TRUE 	;PUT TRUE IF USER # MATCH REQUIRED
;
	IF	ALTCPM
BASE	EQU	4200H
TPA	EQU	4300H
	ENDIF
	IF	RMAC
	EXTRN	BASE,FCB,BDOS	;MAKE BASE EXTERNAL
	ENDIF
	IF	(NOT ALTCPM) AND (NOT RMAC)
BASE	EQU	$	;WILL DEFAULT TO 0 (OR 100H WITH MAC +R OPTION)
TPA	EQU	100H
	ENDIF
;
	IF	NOT RMAC
FCB	EQU	BASE+5CH
BDOS	EQU	BASE+5
	ENDIF
;
NPL	EQU	4	;NUMBER OF NAMES PER LINE
DELIM	EQU	':'	;FENCE (DELIMITER) CHARACTER
;
	IF	NOT RMAC
	ORG	TPA
	ENDIF
;
;SAVE THE STACK
START	LXI	H,0
	DAD	SP	;H=STACK
	SHLD	STACK	;SAVE IT
	LXI	SP,STACK ;GET NEW STACK
;
	IF	SOPT
	LDA	FCB+17	;SAVE S OPTION FLAG
	STA	SOPFLG	;(BLANK OR LETTER S)
	ENDIF
;
	IF	CHKUSR
	MVI	E,0FFH
	MVI	C,CURUSR	;INTERROGATE USER NUMBER
	CALL	BDOS
	STA	USERNO
	LXI	D,USRMSG	;DISPLAY IT
	MVI	C,PRINT
	CALL	BDOS
	LDA	USERNO
	CPI	10
	JC	DUX
	MVI	A,'1'
	CALL	TYPE
	LDA	USERNO
	SUI	10
DUX	ADI	'0'
	CALL	TYPE
	LXI	D,USRMS2
	MVI	C,PRINT
	CALL	BDOS
	ENDIF
;
	LXI	H,FCB
	MOV	A,M	;GET DRIVE NAME
	ORA	A	;ANY SPECIFIED?
	JNZ	START2	;YES SKIP NEXT ROUTINE
	MVI	C,CURDSK
	CALL	BDOS	;GET CURRENT DISK NR
	INR	A	;MAKE A:=1
;
START2	ADI	'A'-1	;MAKE IT PRINTABLE
	STA	DRNAM	;SAVE FOR LATER
	LXI	H,FCB+1	;POINT TO NAME
	MOV	A,M	;ANY SPECIFIED?
	CPI	' '
	JNZ	GOTFCB
;NO FCB - MAKE FCB ALL '?'
	MVI	B,11	;FN+FT COUNT
QLOOP	MVI	M,'?'	;STORE '?' IN FCB
	INX	H
	DCR	B
	JNZ	QLOOP
;LOOK UP THE FCB IN THE DIRECTORY
GOTFCB	MVI	C,FSRCHF ;GET 'SEARCH FIRST' FNC
	LXI	D,FCB
	CALL	BDOS	;READ FIRST
	INR	A	;WERE THERE ANY?
	JNZ	SOME	;GOT SOME
NONE	CALL	ERXIT
	IF	NOT CHKUSR
	DB	'NO FILE$'
	ENDIF
	IF	CHKUSR
	DB	'File not found.$'
;
USRMSG	DB	'Directory for user $'
USRMS2	DB	':',13,10,'$'
	ENDIF
;
;READ MORE DIRECTORY ENTRIES
MOREDIR	MVI	C,FSRCHN ;SEARCH NEXT
	LXI	D,FCB
	CALL	BDOS	;READ DIR ENTRY
	INR	A	;CHECK FOR END (0FFH)
	JZ	SPRINT	;NO MORE - SORT & PRINT
;POINT TO DIRECTORY ENTRY 
SOME	DCR	A	;UNDO PREV 'INR A'
	ANI	3	;MAKE MODULUS 4
	ADD	A	;MULTIPLY...
	ADD	A	;..BY 32 BECAUSE
	ADD	A	;..EACH DIRECTORY
	ADD	A	;..ENTRY IS 32
	ADD	A	;..BYTES LONG
	LXI	H,BASE+81H ;POINT TO BUFFER
			;(SKIP TO FN/FT)
	ADD	L	;POINT TO ENTRY
	ADI	9	;POINT TO SYS BYTE
	MOV	L,A	;SAVE (CAN'T CARRY TO H)
;
	IF	SOPT
	LDA	SOPFLG	;DID USER REQUEST SYS FILES?
	CPI	'S'
	JZ	SYSFOK
	ENDIF
;
	MOV	A,M	;GET SYS BYTE
	ANI	80H	;CHECK BIT 7
	JNZ	MOREDIR	;SKIP THAT FILE
SYSFOK	MOV	A,L	;GO BACK NOW
	SUI	9	;BACK TO FT/FN START
	MOV	L,A	;HL POINTS TO ENTRY NOW
;
	IF	CHKUSR
	DCX	H	;POINT TO USER BYTE IN FCB
	LDA	USERNO	;GET CURRENT USER
	CMP	M
	JNZ	MOREDIR	;IGNORE IF DIFFERENT
	INX	H
	ENDIF
;
;MOVE ENTRY TO TABLE
	XCHG		;ENTRY TO DE
	LHLD	NEXTT	;NEXT TABLE ENTRY TO HL
	MVI	B,11	;ENTRY LENGTH
TMOVE	LDAX	D	;GET ENTRY CHAR
	ANI	7FH	;REMOVE ATTRIBUTES
	MOV	M,A	;STORE IN TABLE
	INX	D
	INX	H
	DCR	B	;MORE?
	JNZ	TMOVE
	SHLD	NEXTT	;SAVE UPDATED TABLE ADDR
	LDA	COUNT	;GET PREV COUNT
	INR	A
	STA	COUNT
	LXI	D,11	;SIZE OF NEXT ENTRY
	DAD	D
	XCHG		;FUTURE NEXTT IS IN DE
	LHLD	BDOS+1	;PICK UP TPA END
	MOV	A,E
	SUB	L	;COMPARE NEXTT-TPA END
	MOV	A,D
	SBB	H
	JC	MOREDIR	;IF TPA END>NEXTT THEN LOOP BACK FOR MORE
	CALL	ERXIT
	DB	'Out of memory.',13,10,'$'
;
;
;SORT AND PRINT
SPRINT	LDA	COUNT	;GET FILE NAME COUNT
	ORA	A	;ANY FOUND?
	JZ	NONE	;NO, EXIT
;INIT THE ORDER TABLE
	LXI	H,ORDER
	LXI	D,TABLE
	LXI	B,11	;ENTRY LENGTH
BLDORD	MOV	M,E	;SAVE LO ORD ADDR
	INX	H
	MOV	M,D	;SAVE HI ORD ADDR
	INX	H
	XCHG		;TABLE ADDR TO HL
	DAD	B	;POINT TO NEXT ENTRY
	XCHG
	DCR	A	;MORE?
	JNZ	BLDORD	;..YES
	LDA	COUNT	;GET COUNT
	STA	SCOUNT	;SAVE AS # TO SORT
	DCR	A	;ONLY 1 ENTRY?
	JZ	DONE	;..YES, SO SKIP SORT
SORT	XRA	A	;GET A ZERO
	STA	SWITCH	;SHOW NONE SWITCHED
	LDA	SCOUNT	;GET COUNT
	DCR	A	;USE 1 LESS
	STA	TEMP	;SAVE # TO COMPARE
	STA	SCOUNT	;SAVE HIGHEST ENTRY
	JZ	DONE	;EXIT IF NO MORE
	LXI	H,ORDER ;POINT TO ORDER TABLE
SORTLP	CALL	COMPR	;COMPARE 2 ENTRIES
	CM	SWAP	;SWAP IF NOT IN ORDER
	INX	H	;BUMP ORDER
	INX	H	;..TABLE POINTER
	LDA	TEMP	;GET COUNT
	DCR	A
	STA	TEMP
	JNZ	SORTLP	;CONTINUE
;ONE PASS OF SORT DONE
	LDA	SWITCH	;ANY SWAPS DONE?
	ORA	A
	JNZ	SORT
;SORT IS ALL DONE - PRINT ENTRIES
DONE	LXI	H,ORDER
	SHLD	NEXTT
;
;PRINT AN ENTRY
	CALL	DRPRNT	;PRINT DRIVE NAME
	MVI	C,NPL	;NR. OF NAMES PER LINE
ENTRY:	PUSH	B
	MVI	C,CONST	;CK STATUS OF KB
	CALL	BDOS	;ANY KEY PRESSED?
	POP	B
	ORA	A
	JNZ	ABORT	;YES, ABORT
	CALL	FENCE	;PRINT FENCE CHAR AND SPACE
	LHLD	NEXTT	;GET ORDER TABLE POINTER
	MOV	E,M	;GET LO ADDR
	INX	H
	MOV	D,M	;GET HI ADDR
	INX	H
	SHLD	NEXTT	;SAVE UPDATED TABLE POINTER
	XCHG		;TABLE ENTRY TO HL
	MVI	B,8	;FILE NAME LENGTH
	CALL	TYPEIT	;TYPE FILENAME
	CALL	PERIOD	;PERIOD AFTER FN
	MVI	B,3	;GET THE FILETYPE
	CALL	TYPEIT
	CALL	SPACE	;SPACE OVER ONE
;SEE IF MORE ENTRIES
	LDA	COUNT
	DCR	A
	JZ	EXIT
	STA	COUNT
	DCR	C	;ONE LESS ON THIS LINE
	CZ	CRLF	;PRINT CR-LF AND DRIVE NAME
	JMP	ENTRY
;
PERIOD	MVI	A,'.'
	JMP	TYPE
;
DRPRNT	LDA	DRNAM	;GET SAVED DRIVE NAME
	JMP	TYPE	;PRINT IT
;
FENCE	MVI	A,DELIM	;FENCE CHARACTER
	CALL	TYPE	;PRINT IT, FALL INTO SPACE
;
SPACE	MVI	A,' '
;
;TYPE CHAR IN A
TYPE	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A
	MVI	C,WRCHR
	CALL	BDOS
	POP	H
	POP 	D
	POP	B
	RET
;
TYPEIT	MOV	A,M
	CALL	TYPE
	INX	H
	DCR	B
	JNZ	TYPEIT
	RET
;
CRLF	MVI	A,13	;PRINT
	CALL	TYPE
	MVI	A,10	;LF
	CALL	TYPE
	CALL	DRPRNT
	MVI	C,NPL	;NUMBER OF NAMES PER LINE
	RET
;
;COMPARE ROUTINE FOR SORT
COMPR	PUSH	H	;SAVE TABLE ADDR
	MOV	E,M	;LOAD LO
	INX	H
	MOV	D,M	;LOAD HI
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
;BC, DE NOW POINT TO ENTRIES TO BE COMPARED
	XCHG
CMPLP	LDAX	B
	CMP	M
	INX	H
	INX	B
	JZ	CMPLP
	POP	H
	RET		;COND CODE TELLS ALL
;
;SWAP ENTRIES IN THE ORDER TABLE
SWAP	MVI	A,1
	STA	SWITCH	;SHOW A SWAP WAS MADE
	MOV	C,M
	INX	H
	PUSH	H	;SAVE TABLE ADDR+1
	MOV	B,M
	INX	H
	MOV	E,M
	MOV	M,C
	INX	H
	MOV	D,M
	MOV	M,B
	POP	H
	MOV	M,D
	DCX	H	;BACK POINTER TO CORRECT LOC'N
	MOV	M,E
	RET
;
;ERROR EXIT
ERXIT	POP	D	;GET MSG
	MVI	C,PRINT
	JMP	CALLB	;PRINT MSG, EXIT
;
;ABORT - READ CHAR ENTERED
ABORT	MVI	C,RDCHR
CALLB	CALL	BDOS	;DELETE THE CHAR
;
;FALL INTO EXIT
;EXIT - ALL DONE , RESTORE STACK
EXIT	LHLD	STACK	;GET OLD STACK
	SPHL		;MOVE TO STACK
	RET		;..AND RETURN
;
NEXTT	DW	TABLE	;NEXT TABLE ENTRY
COUNT	DB	0	;ENTRY COUNT
SCOUNT	DB	0	;# TO SORT
SWITCH	DB	0	;SWAP SWITCH FOR SORT
BUFAD	DW	BASE+80H ;OUTPUT ADDR
ORDER	DS	512	;ORDER TABLE (ROOM FOR 256 NAMES)
	DS	60	;STACK AREA
STACK	DS	2	;SAVE OLD STACK HERE
SOPFLG	DS	1	;SET TO 'S' TO ALLOW SYS FILES TO PRINT
USERNO	DS	1	;CONTAINS CURRENT USER NUMBER
DRNAM	DS	1	;SAVE DRIVE NAME HERE
TEMP	DS	1	;SAVE DIR ENTRY
TABLE	EQU	$	;READ ENTRIES IN HERE
	DB	'...........'	;DUMMY FIRST ENTRY TO FORCE .COM FILE SIZE
;
; BDOS EQUATES
;
RDCHR	EQU	1	;READ CHAR FROM CONSOLE
WRCHR	EQU	2	;WRITE CHR TO CONSOLE
PRINT	EQU	9	;PRINT CONSOLE BUFF
CONST	EQU	11	;CHECK CONS STAT
FOPEN	EQU	15	;0FFH=NOT FOUND
FCLOSE	EQU	16	;   "	"
FSRCHF	EQU	17	;   "	"
FSRCHN	EQU	18	;   "	"
CURDSK	EQU	25	;GET CURRENTLY LOGGED DISK NAME
CURUSR	EQU	32	;GET CURRENTLY LOGGED USER NUMBER (2.X ONLY)
;
	END
